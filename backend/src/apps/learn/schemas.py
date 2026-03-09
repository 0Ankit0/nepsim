"""Learn app — Pydantic request/response schemas."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class LessonSummary(BaseModel):
    id: int
    title: str
    section: str
    difficulty_level: str
    order_index: int
    read_time_minutes: int
    has_quiz: bool = False

    model_config = {"from_attributes": True}


class QuizQuestionResponse(BaseModel):
    id: int
    question_text: str
    options: str      # JSON array string — client parses
    order_index: int
    # explanation only sent after submission, not during quiz
    explanation: Optional[str] = None

    model_config = {"from_attributes": True}


class QuizResponse(BaseModel):
    id: int
    lesson_id: int
    title: str
    passing_score: int
    time_limit_seconds: Optional[int]
    questions: list[QuizQuestionResponse] = []

    model_config = {"from_attributes": True}


class LessonDetail(BaseModel):
    id: int
    title: str
    section: str
    content_html: str
    image_urls: Optional[str]   # JSON array string
    difficulty_level: str
    read_time_minutes: int
    quiz: Optional[QuizResponse] = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class CurriculumSection(BaseModel):
    section: str
    lessons: list[LessonSummary]


class LessonCreate(BaseModel):
    title: str
    section: str
    content_html: str
    difficulty_level: str = "beginner"
    read_time_minutes: int = 5
    order_index: int = 1
    image_urls: Optional[str] = None


class LessonUpdate(BaseModel):
    title: Optional[str] = None
    section: Optional[str] = None
    content_html: Optional[str] = None
    difficulty_level: Optional[str] = None
    read_time_minutes: Optional[int] = None
    order_index: Optional[int] = None
    image_urls: Optional[str] = None


class QuizQuestionCreate(BaseModel):
    question_text: str
    options: str
    correct_option_index: int
    order_index: int = 0
    explanation: Optional[str] = None


class QuizCreate(BaseModel):
    lesson_id: int
    title: str
    passing_score: int = 70
    time_limit_seconds: Optional[int] = None
    questions: list[QuizQuestionCreate] = []


class QuizUpdate(BaseModel):
    title: Optional[str] = None
    passing_score: Optional[int] = None
    time_limit_seconds: Optional[int] = None


class QuizSubmission(BaseModel):
    answers: dict[int, int] = Field(
        description="Map of question_id → selected_option_index"
    )
    time_taken_seconds: Optional[int] = None


class QuizResult(BaseModel):
    quiz_id: int
    lesson_id: int
    score: int
    passed: bool
    passing_score: int
    correct_count: int
    total_questions: int
    # Per-question breakdown with explanations
    question_results: list[dict]
