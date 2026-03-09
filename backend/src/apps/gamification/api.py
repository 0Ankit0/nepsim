"""Gamification app — FastAPI router."""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.session import get_session
from src.apps.iam.api.deps import get_current_user
from src.apps.iam.models.user import User
from .services import GamificationService
from .schemas import UserProgressResponse, UserAchievementResponse, AchievementResponse

router = APIRouter(prefix="/users/me", tags=["Gamification & Progress"])


@router.get("/progress", response_model=UserProgressResponse)
async def get_my_progress(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Get the authenticated user's aggregated skill ratings and simulation stats."""
    progress = await GamificationService.get_or_create_progress(db, current_user.id)
    return progress


@router.get("/achievements", response_model=list[UserAchievementResponse])
async def get_my_achievements(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Get all achievements unlocked by the authenticated user."""
    pairs = await GamificationService.get_user_achievements(db, current_user.id)
    return [
        UserAchievementResponse(
            achievement=AchievementResponse(**achv.model_dump()),
            unlocked_at=ua.unlocked_at,
            simulation_id=ua.simulation_id,
        )
        for ua, achv in pairs
    ]
