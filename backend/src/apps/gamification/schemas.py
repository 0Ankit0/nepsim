"""Gamification app — Pydantic response schemas."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class AchievementResponse(BaseModel):
    id: int
    slug: str
    title: str
    description: str
    icon_name: str
    tier: str
    is_active: bool

    model_config = {"from_attributes": True}


class UserAchievementResponse(BaseModel):
    achievement: AchievementResponse
    unlocked_at: datetime
    simulation_id: Optional[int]

    model_config = {"from_attributes": True}


class UserProgressResponse(BaseModel):
    user_id: int
    # Simulation stats
    total_simulations: int
    total_trades: int
    average_pnl_pct: float
    best_pnl_pct: float
    worst_pnl_pct: float
    overall_win_rate: float
    best_streak: int
    # Skill scores
    timing_score: float
    selection_score: float
    risk_score: float
    patience_score: float
    # Learning
    lessons_completed: int
    quizzes_passed: int
    updated_at: datetime

    model_config = {"from_attributes": True}
