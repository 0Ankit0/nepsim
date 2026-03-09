"""
NEPSIM Gamification App — SQLModel database models.

Tables:
- achievements      : Badge/achievement definitions
- user_achievements : Records of badges unlocked by each user
- user_progress     : Aggregated skill ratings and simulation stats per user
"""
from datetime import datetime
from typing import Optional
from sqlmodel import Field, SQLModel


# ─── Achievement (definition) ─────────────────────────────────────────────────

class AchievementBase(SQLModel):
    slug: str = Field(
        unique=True,
        index=True,
        max_length=80,
        description="Machine-readable identifier (e.g. first_profit, five_simulations)",
    )
    title: str = Field(max_length=100)
    description: str = Field(max_length=300)
    icon_name: str = Field(
        max_length=80,
        description="Icon asset name or emoji shortcode used in the mobile app",
    )
    # Rarity / tier
    tier: str = Field(
        default="bronze",
        max_length=20,
        description="bronze | silver | gold | platinum",
    )
    # Optional threshold value used by the unlock service
    threshold_value: Optional[float] = Field(
        default=None,
        description="Numeric threshold to unlock (e.g. profit % for 'ten_percent_profit')",
    )
    is_active: bool = Field(default=True)


class Achievement(AchievementBase, table=True):
    __tablename__ = "achievements"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)


# ─── UserAchievement (unlocked instance) ─────────────────────────────────────

class UserAchievementBase(SQLModel):
    user_id: int = Field(foreign_key="user.id", index=True)
    achievement_id: int = Field(foreign_key="achievements.id")
    simulation_id: Optional[int] = Field(
        default=None,
        foreign_key="simulations.id",
        description="Simulation during which this achievement was unlocked (if applicable)",
    )


class UserAchievement(UserAchievementBase, table=True):
    __tablename__ = "user_achievements"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    unlocked_at: datetime = Field(default_factory=datetime.now)


# ─── UserProgress ────────────────────────────────────────────────────────────

class UserProgressBase(SQLModel):
    user_id: int = Field(
        foreign_key="user.id",
        unique=True,
        index=True,
    )
    # Simulation aggregate stats
    total_simulations: int = Field(default=0)
    total_trades: int = Field(default=0)
    average_pnl_pct: float = Field(
        default=0.0,
        description="Average return % across all completed simulations",
    )
    best_pnl_pct: float = Field(default=0.0)
    worst_pnl_pct: float = Field(default=0.0)
    overall_win_rate: float = Field(default=0.0, description="Win rate 0.0–1.0 across all sims")
    best_streak: int = Field(default=0, description="Longest streak of profitable simulations")

    # Skill ratings (0–100, AI-derived average across simulations)
    timing_score: float = Field(default=0.0)
    selection_score: float = Field(default=0.0)
    risk_score: float = Field(default=0.0)
    patience_score: float = Field(default=0.0)

    # Learning progress
    lessons_completed: int = Field(default=0)
    quizzes_passed: int = Field(default=0)
    total_quiz_score: int = Field(default=0)


class UserProgress(UserProgressBase, table=True):
    __tablename__ = "user_progress"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
