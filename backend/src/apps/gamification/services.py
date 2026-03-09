"""Gamification service — achievement unlock logic and progress aggregation."""
from __future__ import annotations

from datetime import datetime

from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, and_, func

from ..simulator.models import Trade, Simulation, SimulationStatus
from ..ai_analysis.models import AIAnalysis, AnalysisStatus
from .models import Achievement, UserAchievement, UserProgress


# Achievement slug definitions — added to DB via seed script or admin
ACHIEVEMENT_SLUGS = {
    "first_simulation": "Complete your first simulation",
    "first_trades": "Place your first trade",
    "five_simulations": "Complete 5 simulations",
    "ten_percent_profit": "Achieve 10% profit in a simulation",
    "fifty_percent_profit": "Achieve 50% profit in a simulation",
    "no_loss_simulation": "Complete a simulation without any losing trades",
    "diversified": "Hold 5+ different stocks simultaneously",
    "high_volume": "Execute 20+ trades in a single simulation",
    "patient_investor": "Hold a position for 30+ simulated days",
    "first_learn": "Complete your first lesson",
    "quiz_master": "Pass 10 quizzes",
    "perfect_score": "Get 100% on any quiz",
}


class GamificationService:

    @staticmethod
    async def get_or_create_progress(
        db: AsyncSession, user_id: int
    ) -> UserProgress:
        result = await db.execute(
            select(UserProgress).where(UserProgress.user_id == user_id)
        )
        progress = result.scalar_one_or_none()
        if not progress:
            progress = UserProgress(user_id=user_id)
            db.add(progress)
            await db.commit()
            await db.refresh(progress)
        return progress

    @staticmethod
    async def update_progress_after_simulation(
        db: AsyncSession, user_id: int, simulation_id: int
    ) -> UserProgress:
        """Recalculate aggregated stats and update user progress after any simulation completes."""
        progress = await GamificationService.get_or_create_progress(db, user_id)

        # Count all completed simulations
        result = await db.execute(
            select(func.count(Simulation.id)).where(
                and_(
                    Simulation.user_id == user_id,
                    Simulation.status.in_([SimulationStatus.ENDED, SimulationStatus.ANALYSIS_READY]),
                )
            )
        )
        progress.total_simulations = result.scalar() or 0

        # Aggregate from AI analyses
        analyses_result = await db.execute(
            select(AIAnalysis).where(
                and_(
                    AIAnalysis.user_id == user_id,
                    AIAnalysis.status == AnalysisStatus.COMPLETED,
                    AIAnalysis.total_pnl_pct.isnot(None),
                )
            )
        )
        analyses = analyses_result.scalars().all()
        if analyses:
            pnl_pcts = [a.total_pnl_pct for a in analyses if a.total_pnl_pct is not None]
            progress.average_pnl_pct = round(sum(pnl_pcts) / len(pnl_pcts), 2)
            progress.best_pnl_pct = round(max(pnl_pcts), 2)
            progress.worst_pnl_pct = round(min(pnl_pcts), 2)

            win_rates = [a.win_rate for a in analyses if a.win_rate is not None]
            progress.overall_win_rate = round(sum(win_rates) / len(win_rates), 4) if win_rates else 0.0

            # Skill score averages
            t_scores = [a.timing_score for a in analyses if a.timing_score is not None]
            s_scores = [a.selection_score for a in analyses if a.selection_score is not None]
            r_scores = [a.risk_score for a in analyses if a.risk_score is not None]
            p_scores = [a.patience_score for a in analyses if a.patience_score is not None]
            if t_scores:
                progress.timing_score = round(sum(t_scores) / len(t_scores), 1)
            if s_scores:
                progress.selection_score = round(sum(s_scores) / len(s_scores), 1)
            if r_scores:
                progress.risk_score = round(sum(r_scores) / len(r_scores), 1)
            if p_scores:
                progress.patience_score = round(sum(p_scores) / len(p_scores), 1)

        # Total trades
        trade_result = await db.execute(
            select(func.count(Trade.id)).where(Trade.user_id == user_id)
        )
        progress.total_trades = trade_result.scalar() or 0
        progress.updated_at = datetime.now()
        db.add(progress)
        await db.commit()
        await db.refresh(progress)
        return progress

    @staticmethod
    async def check_and_unlock_achievements(
        db: AsyncSession, user_id: int, simulation_id: int
    ) -> list[UserAchievement]:
        """Evaluate which achievements the user has now earned and persist new unlocks."""
        newly_unlocked: list[UserAchievement] = []

        # Get already unlocked achievement slugs to avoid duplicates
        existing_result = await db.execute(
            select(Achievement.slug).join(
                UserAchievement, UserAchievement.achievement_id == Achievement.id
            ).where(UserAchievement.user_id == user_id)
        )
        already_unlocked = {r for r in existing_result.scalars().all()}

        progress = await GamificationService.get_or_create_progress(db, user_id)
        all_achievements_result = await db.execute(select(Achievement).where(Achievement.is_active == True))  # noqa: E712
        all_achievements = {a.slug: a for a in all_achievements_result.scalars().all()}

        async def unlock(slug: str):
            if slug not in already_unlocked and slug in all_achievements:
                ua = UserAchievement(
                    user_id=user_id,
                    achievement_id=all_achievements[slug].id,
                    simulation_id=simulation_id,
                )
                db.add(ua)
                newly_unlocked.append(ua)

        # Evaluate conditions
        if progress.total_simulations >= 1:
            await unlock("first_simulation")
        if progress.total_simulations >= 5:
            await unlock("five_simulations")
        if progress.total_trades >= 1:
            await unlock("first_trades")
        if progress.best_pnl_pct and progress.best_pnl_pct >= 10.0:
            await unlock("ten_percent_profit")
        if progress.best_pnl_pct and progress.best_pnl_pct >= 50.0:
            await unlock("fifty_percent_profit")

        if newly_unlocked:
            await db.commit()

        return newly_unlocked

    @staticmethod
    async def get_user_achievements(
        db: AsyncSession, user_id: int
    ) -> list[tuple[UserAchievement, Achievement]]:
        result = await db.execute(
            select(UserAchievement, Achievement)
            .join(Achievement, UserAchievement.achievement_id == Achievement.id)
            .where(UserAchievement.user_id == user_id)
            .order_by(UserAchievement.unlocked_at.desc())
        )
        return result.all()  # type: ignore
