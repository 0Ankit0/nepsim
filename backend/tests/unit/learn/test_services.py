import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from src.apps.learn.services import LearnService
from src.apps.learn.schemas import QuizSubmission
from src.apps.learn.models import QuizQuestion
from tests.factories import LessonFactory, QuizFactory


@pytest.mark.asyncio
class TestLearnService:
    """Unit tests for LearnService."""

    async def test_create_lesson(self, db_session: AsyncSession):
        lesson_data = {
            "title": "Introduction to Technical Analysis",
            "section": "Basics",
            "content_html": "<p>Learn the basics of TA.</p>",
            "difficulty_level": "beginner",
            "read_time_minutes": 10,
            "order_index": 1
        }
        
        lesson = await LearnService.create_lesson(db_session, lesson_data)
        
        assert lesson.title == "Introduction to Technical Analysis"
        assert lesson.section == "Basics"
        assert lesson.read_time_minutes == 10

    async def test_get_lesson(self, db_session: AsyncSession):
        lesson = LessonFactory()
        db_session.add(lesson)
        await db_session.commit()

        found = await LearnService.get_lesson(db_session, lesson.id)
        assert found is not None
        assert found.id == lesson.id

    async def test_submit_quiz_success(self, db_session: AsyncSession):
        # Create lesson and quiz
        lesson = LessonFactory()
        db_session.add(lesson)
        await db_session.commit()
        await db_session.refresh(lesson)
        
        quiz = QuizFactory(lesson_id=lesson.id, passing_score=50)
        db_session.add(quiz)
        await db_session.commit()
        await db_session.refresh(quiz)
        
        # Add a question
        q1 = QuizQuestion(
            quiz_id=quiz.id,
            question_text="What is NEPSE?",
            options='["Nepal Stock Exchange", "New York Stock Exchange"]',
            correct_option_index=0,
            explanation="NEPSE is the Nepal Stock Exchange.",
            order_index=1
        )
        db_session.add(q1)
        await db_session.commit()

        # Submit answer
        submission = QuizSubmission(answers={q1.id: 0})
        result = await LearnService.submit_quiz(db_session, user_id=1, quiz_id=quiz.id, submission=submission)
        
        assert result.score == 100
        assert result.passed is True
        assert result.correct_count == 1
        assert result.total_questions == 1

    async def test_submit_quiz_fail(self, db_session: AsyncSession):
        # Create lesson and quiz
        lesson = LessonFactory()
        db_session.add(lesson)
        await db_session.commit()
        await db_session.refresh(lesson)
        
        quiz = QuizFactory(lesson_id=lesson.id, passing_score=50)
        db_session.add(quiz)
        await db_session.commit()
        await db_session.refresh(quiz)
        
        # Add a question
        q1 = QuizQuestion(
            quiz_id=quiz.id,
            question_text="What is RSI?",
            options='["Indicator", "Stock"]',
            correct_option_index=0,
            explanation="RSI is a momentum indicator.",
            order_index=1
        )
        db_session.add(q1)
        await db_session.commit()

        # Submit wrong answer
        submission = QuizSubmission(answers={q1.id: 1})
        result = await LearnService.submit_quiz(db_session, user_id=1, quiz_id=quiz.id, submission=submission)
        
        assert result.score == 0
        assert result.passed is False
        assert result.correct_count == 0
