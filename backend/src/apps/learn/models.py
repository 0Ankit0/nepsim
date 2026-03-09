"""
NEPSIM Learn App — SQLModel database models.

Tables:
- lessons           : Technical analysis educational content with rich text + media
- quizzes           : Quiz entity linked to a lesson (one quiz per lesson)
- quiz_questions    : Individual MCQ question within a quiz
- user_quiz_results : User quiz attempt records
"""
from datetime import datetime
from typing import Optional
from sqlmodel import Field, SQLModel


# ─── Lesson ──────────────────────────────────────────────────────────────────

class LessonBase(SQLModel):
    title: str = Field(max_length=200)
    section: str = Field(
        max_length=100,
        description="Curriculum section (Introduction, Chart Patterns, Indicators, Volume, Risk Management)",
    )
    content_html: str = Field(
        description="Rich HTML/Markdown content — text, embedded image tags, diagrams",
    )
    # JSON list of absolute image URLs / asset paths
    image_urls: Optional[str] = Field(
        default=None,
        description="JSON array of image URLs used in this lesson",
    )
    difficulty_level: str = Field(
        default="beginner",
        max_length=20,
        description="beginner | intermediate | advanced",
    )
    # Determines display order within section
    order_index: int = Field(default=0)
    # Estimated reading time in minutes
    read_time_minutes: int = Field(default=5)
    is_published: bool = Field(default=True)


class Lesson(LessonBase, table=True):
    __tablename__ = "lessons"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)


# ─── Quiz ─────────────────────────────────────────────────────────────────────

class QuizBase(SQLModel):
    lesson_id: int = Field(
        foreign_key="lessons.id",
        unique=True,
        index=True,
        description="Each lesson has at most one quiz",
    )
    title: str = Field(max_length=200, default="Quiz")
    passing_score: int = Field(
        default=70,
        description="Minimum % required to mark quiz as passed",
    )
    time_limit_seconds: Optional[int] = Field(
        default=None,
        description="Optional time limit. None = unlimited.",
    )


class Quiz(QuizBase, table=True):
    __tablename__ = "quizzes"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)


# ─── QuizQuestion ─────────────────────────────────────────────────────────────

class QuizQuestionBase(SQLModel):
    quiz_id: int = Field(foreign_key="quizzes.id", index=True)
    question_text: str = Field(max_length=1000)
    # JSON list of option strings e.g. '["RSI","MACD","Bollinger","ATR"]'
    options: str = Field(description="JSON array of answer option strings")
    # 0-based index of the correct option in `options`
    correct_option_index: int
    explanation: str = Field(
        max_length=1000,
        description="Explanation shown after the user answers — educational context",
    )
    order_index: int = Field(default=0)


class QuizQuestion(QuizQuestionBase, table=True):
    __tablename__ = "quiz_questions"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)


# ─── UserQuizResult ───────────────────────────────────────────────────────────

class UserQuizResultBase(SQLModel):
    user_id: int = Field(foreign_key="user.id", index=True)
    quiz_id: int = Field(foreign_key="quizzes.id", index=True)
    lesson_id: int = Field(foreign_key="lessons.id", index=True)
    # JSON dict mapping question_id → selected_option_index
    answers: str = Field(description="JSON object: {question_id: selected_index, ...}")
    score: int = Field(description="Score achieved as a percentage (0–100)")
    passed: bool = Field(description="True if score >= quiz.passing_score")
    time_taken_seconds: Optional[int] = Field(default=None)


class UserQuizResult(UserQuizResultBase, table=True):
    __tablename__ = "user_quiz_results"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    submitted_at: datetime = Field(default_factory=datetime.now)
