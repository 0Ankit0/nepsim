"""Learn app — FastAPI router."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.session import get_session
from src.apps.iam.api.deps import get_current_user
from src.apps.iam.models.user import User
from .services import LearnService
from .schemas import (
    CurriculumSection, LessonSummary, LessonDetail,
    QuizResponse, QuizQuestionResponse, QuizSubmission, QuizResult,
    LessonCreate, LessonUpdate, QuizCreate, QuizUpdate,
)

router = APIRouter(prefix="/learn", tags=["Learning & Quizzes"])


@router.get("/lessons", response_model=list[CurriculumSection])
async def get_curriculum(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Return the full structured technical analysis curriculum grouped by section."""
    lessons = await LearnService.get_lessons(db)
    completed = await LearnService.get_user_completed_lessons(db, current_user.id)

    # Group lessons into sections
    section_map: dict[str, list[LessonSummary]] = {}
    for lesson in lessons:
        quiz = await LearnService.get_quiz_for_lesson(db, lesson.id)
        summary = LessonSummary(
            id=lesson.id,
            title=lesson.title,
            section=lesson.section,
            difficulty_level=lesson.difficulty_level,
            order_index=lesson.order_index,
            read_time_minutes=lesson.read_time_minutes,
            has_quiz=quiz is not None,
        )
        section_map.setdefault(lesson.section, []).append(summary)

    return [
        CurriculumSection(section=section, lessons=lessons_in_section)
        for section, lessons_in_section in section_map.items()
    ]


@router.post("/lessons", response_model=LessonDetail, status_code=status.HTTP_201_CREATED)
async def create_lesson(
    payload: LessonCreate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Create a new lesson."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Admin access required.")
    lesson = await LearnService.create_lesson(db, payload.model_dump())
    return await get_lesson(lesson.id, db, current_user)


@router.patch("/lessons/{lesson_id}", response_model=LessonDetail)
async def update_lesson(
    lesson_id: int,
    payload: LessonUpdate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Update lesson content."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Admin access required.")
    lesson = await LearnService.update_lesson(db, lesson_id, payload.model_dump(exclude_unset=True))
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found.")
    return await get_lesson(lesson_id, db, current_user)


@router.delete("/lessons/{lesson_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_lesson(
    lesson_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Delete a lesson."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Admin access required.")
    success = await LearnService.delete_lesson(db, lesson_id)
    if not success:
        raise HTTPException(status_code=404, detail="Lesson not found.")
    return None


@router.post("/quizzes", response_model=QuizResponse, status_code=status.HTTP_201_CREATED)
async def create_quiz(
    payload: QuizCreate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Create a quiz for a lesson."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Admin access required.")
    
    quiz_data = payload.model_dump()
    questions = quiz_data.pop("questions", [])
    
    quiz = await LearnService.create_quiz(db, quiz_data, questions)
    
    # Return full lesson to get updated state
    lesson = await get_lesson(quiz.lesson_id, db, current_user)
    return lesson.quiz


@router.patch("/quizzes/{quiz_id}", response_model=QuizResponse)
async def update_quiz(
    quiz_id: int,
    payload: QuizUpdate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Update quiz metadata."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Admin access required.")
    
    quiz = await LearnService.update_quiz(db, quiz_id, payload.model_dump(exclude_unset=True))
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found.")
        
    lesson = await get_lesson(quiz.lesson_id, db, current_user)
    return lesson.quiz


@router.get("/lessons/{lesson_id}", response_model=LessonDetail)
async def get_lesson(
    lesson_id: int,
    db: AsyncSession = Depends(get_session),
    _: User = Depends(get_current_user),
):
    """Get full lesson content with embedded quiz (questions without answers)."""
    lesson = await LearnService.get_lesson(db, lesson_id)
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found.")

    quiz_data = None
    quiz = await LearnService.get_quiz_for_lesson(db, lesson_id)
    if quiz:
        questions = await LearnService.get_quiz_questions(db, quiz.id)
        quiz_data = QuizResponse(
            id=quiz.id,
            lesson_id=quiz.lesson_id,
            title=quiz.title,
            passing_score=quiz.passing_score,
            time_limit_seconds=quiz.time_limit_seconds,
            questions=[
                QuizQuestionResponse(
                    id=q.id,
                    question_text=q.question_text,
                    options=q.options,
                    order_index=q.order_index,
                    # Explanation intentionally withheld before submission
                )
                for q in questions
            ],
        )

    return LessonDetail(
        id=lesson.id,
        title=lesson.title,
        section=lesson.section,
        content_html=lesson.content_html,
        image_urls=lesson.image_urls,
        difficulty_level=lesson.difficulty_level,
        read_time_minutes=lesson.read_time_minutes,
        quiz=quiz_data,
        created_at=lesson.created_at,
        updated_at=lesson.updated_at,
    )


@router.post("/quizzes/{quiz_id}/submit", response_model=QuizResult)
async def submit_quiz(
    quiz_id: int,
    payload: QuizSubmission,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Submit quiz answers and receive instant scored feedback with explanations."""
    try:
        result = await LearnService.submit_quiz(db, current_user.id, quiz_id, payload)
        return result
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/quiz-progress")
async def get_quiz_progress(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Get set of lesson IDs where the user has passed the quiz."""
    completed = await LearnService.get_user_completed_lessons(db, current_user.id)
    return {"completed_lesson_ids": list(completed)}
