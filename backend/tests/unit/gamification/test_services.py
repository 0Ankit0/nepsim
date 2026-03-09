import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from src.apps.gamification.services import GamificationService
from tests.factories import UserProgressFactory, AchievementFactory, SimulationFactory


@pytest.mark.asyncio
class TestGamificationService:
    """Unit tests for GamificationService."""

    async def test_get_or_create_progress(self, db_session: AsyncSession):
        user_id = 1
        progress = await GamificationService.get_or_create_progress(db_session, user_id)
        
        assert progress.user_id == user_id
        assert progress.total_simulations == 0
        
        # Call again should return same record
        progress2 = await GamificationService.get_or_create_progress(db_session, user_id)
        assert progress2.id == progress.id

    async def test_check_and_unlock_achievements(self, db_session: AsyncSession):
        user_id = 1
        # Create achievement definition
        achievement = AchievementFactory(slug="first_simulation", name="First Sim", is_active=True)
        db_session.add(achievement)
        
        # User progress with 1 simulation
        progress = UserProgressFactory(user_id=user_id, total_simulations=1)
        db_session.add(progress)
        
        sim = SimulationFactory(user_id=user_id)
        db_session.add(sim)
        await db_session.commit()
        await db_session.refresh(sim)

        newly_unlocked = await GamificationService.check_and_unlock_achievements(
            db_session, user_id, sim.id
        )
        
        assert len(newly_unlocked) == 1
        assert newly_unlocked[0].achievement_id == achievement.id

    async def test_unlock_no_duplicates(self, db_session: AsyncSession):
        user_id = 1
        achievement = AchievementFactory(slug="first_simulation", is_active=True)
        db_session.add(achievement)
        
        progress = UserProgressFactory(user_id=user_id, total_simulations=1)
        db_session.add(progress)
        
        sim = SimulationFactory(user_id=user_id)
        db_session.add(sim)
        await db_session.commit()
        await db_session.refresh(sim)

        # Unlock once
        await GamificationService.check_and_unlock_achievements(db_session, user_id, sim.id)
        
        # Try unlocking again
        again = await GamificationService.check_and_unlock_achievements(db_session, user_id, sim.id)
        assert len(again) == 0
