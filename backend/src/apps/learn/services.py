"""Learn app — service layer for lessons, quizzes and AI insights."""
from __future__ import annotations

import json
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, and_, func

from .models import Lesson, Quiz, QuizQuestion, UserQuizResult
from .schemas import QuizSubmission, QuizResult


class LearnService:

    # ── Lessons ──────────────────────────────────────────────────────────────

    @staticmethod
    async def get_lessons(db: AsyncSession, published_only: bool = True) -> list[Lesson]:
        stmt = select(Lesson)
        if published_only:
            stmt = stmt.where(Lesson.is_published == True)  # noqa: E712
        stmt = stmt.order_by(Lesson.section, Lesson.order_index)
        result = await db.execute(stmt)
        return result.scalars().all()  # type: ignore

    @staticmethod
    async def get_lesson(db: AsyncSession, lesson_id: int) -> Optional[Lesson]:
        result = await db.execute(
            select(Lesson).where(Lesson.id == lesson_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def create_lesson(db: AsyncSession, lesson_data: dict) -> Lesson:
        lesson = Lesson(**lesson_data)
        db.add(lesson)
        await db.commit()
        await db.refresh(lesson)
        return lesson

    @staticmethod
    async def update_lesson(db: AsyncSession, lesson_id: int, lesson_data: dict) -> Optional[Lesson]:
        lesson = await LearnService.get_lesson(db, lesson_id)
        if not lesson:
            return None
        for key, value in lesson_data.items():
            setattr(lesson, key, value)
        await db.commit()
        await db.refresh(lesson)
        return lesson

    @staticmethod
    async def delete_lesson(db: AsyncSession, lesson_id: int) -> bool:
        lesson = await LearnService.get_lesson(db, lesson_id)
        if not lesson:
            return False
        await db.delete(lesson)
        await db.commit()
        return True

    @staticmethod
    async def create_quiz(db: AsyncSession, quiz_data: dict, questions: list[dict] = []) -> Quiz:
        quiz = Quiz(**quiz_data)
        db.add(quiz)
        await db.flush()
        
        for q_data in questions:
            q = QuizQuestion(quiz_id=quiz.id, **q_data)
            db.add(q)
            
        await db.commit()
        await db.refresh(quiz)
        return quiz

    @staticmethod
    async def update_quiz(db: AsyncSession, quiz_id: int, quiz_data: dict) -> Optional[Quiz]:
        result = await db.execute(select(Quiz).where(Quiz.id == quiz_id))
        quiz = result.scalar_one_or_none()
        if not quiz:
            return None
        for key, value in quiz_data.items():
            setattr(quiz, key, value)
        await db.commit()
        await db.refresh(quiz)
        return quiz

    @staticmethod
    async def get_quiz_for_lesson(db: AsyncSession, lesson_id: int) -> Optional[Quiz]:
        result = await db.execute(
            select(Quiz).where(Quiz.lesson_id == lesson_id)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def get_quiz_questions(db: AsyncSession, quiz_id: int) -> list[QuizQuestion]:
        result = await db.execute(
            select(QuizQuestion)
            .where(QuizQuestion.quiz_id == quiz_id)
            .order_by(QuizQuestion.order_index)
        )
        return result.scalars().all()  # type: ignore

    # ── Completed lessons ─────────────────────────────────────────────────────

    @staticmethod
    async def get_user_completed_lessons(
        db: AsyncSession, user_id: int
    ) -> set[int]:
        """Return set of lesson IDs for which user has passed the quiz."""
        result = await db.execute(
            select(UserQuizResult.lesson_id).where(
                and_(
                    UserQuizResult.user_id == user_id,
                    UserQuizResult.passed == True,  # noqa: E712
                )
            )
        )
        return set(result.scalars().all())

    # ── Quiz Submission ───────────────────────────────────────────────────────

    @staticmethod
    async def submit_quiz(
        db: AsyncSession,
        user_id: int,
        quiz_id: int,
        submission: QuizSubmission,
    ) -> QuizResult:
        # Load quiz and questions
        quiz_result = await db.execute(select(Quiz).where(Quiz.id == quiz_id))
        quiz = quiz_result.scalar_one_or_none()
        if not quiz:
            raise ValueError(f"Quiz {quiz_id} not found.")

        questions = await LearnService.get_quiz_questions(db, quiz_id)
        if not questions:
            raise ValueError("Quiz has no questions.")

        question_results = []
        correct_count = 0

        for q in questions:
            selected = submission.answers.get(q.id)
            is_correct = selected == q.correct_option_index
            if is_correct:
                correct_count += 1
            question_results.append({
                "question_id": q.id,
                "question_text": q.question_text,
                "selected_option": selected,
                "correct_option": q.correct_option_index,
                "is_correct": is_correct,
                "explanation": q.explanation,
            })

        total = len(questions)
        score = round((correct_count / total) * 100) if total > 0 else 0
        passed = score >= quiz.passing_score

        # Persist result
        qr = UserQuizResult(
            user_id=user_id,
            quiz_id=quiz_id,
            lesson_id=quiz.lesson_id,
            answers=json.dumps(submission.answers),
            score=score,
            passed=passed,
            time_taken_seconds=submission.time_taken_seconds,
        )
        db.add(qr)
        await db.commit()

        return QuizResult(
            quiz_id=quiz_id,
            lesson_id=quiz.lesson_id,
            score=score,
            passed=passed,
            passing_score=quiz.passing_score,
            correct_count=correct_count,
            total_questions=total,
            question_results=question_results,
        )

    # ── AI Insights (on-demand) ───────────────────────────────────────────────

    @staticmethod
    async def generate_ai_insight(
        symbol: Optional[str],
        concept: Optional[str],
        context: Optional[str],
    ) -> str:
        """Generate a plain-English educational explanation via LLM."""
        from src.apps.core.config import settings

        topic = concept or symbol or "stock market"
        prompt = (
            f"Explain '{topic}' in simple terms for a beginner NEPSE stock trader. "
            f"Use a real NEPSE example if possible. "
            f"{'Additional context: ' + context if context else ''} "
            "Keep it under 150 words. Be clear and encouraging."
        )

        provider = getattr(settings, "LLM_PROVIDER", "openai").lower()

        try:
            if provider == "anthropic":
                import anthropic
                client = anthropic.Anthropic(api_key=getattr(settings, "ANTHROPIC_API_KEY", ""))
                msg = client.messages.create(
                    model="claude-3-haiku-20240307",
                    max_tokens=300,
                    messages=[{"role": "user", "content": prompt}],
                )
                return msg.content[0].text
            else:
                from openai import AsyncOpenAI
                client = AsyncOpenAI(api_key=getattr(settings, "OPENAI_API_KEY", ""))
                resp = await client.chat.completions.create(
                    model="gpt-4o-mini",
                    messages=[{"role": "user", "content": prompt}],
                    max_tokens=300,
                )
                return resp.choices[0].message.content or ""
        except Exception:
            return (
                f"'{topic}' is an important financial concept. "
                "AI explanations are temporarily unavailable. "
                "Please check our learning section for detailed explanations."
            )
