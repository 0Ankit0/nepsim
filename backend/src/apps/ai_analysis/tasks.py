"""AI Analysis — Celery task for async feedback generation."""
from __future__ import annotations

from src.apps.core.celery_app import celery_app


@celery_app.task(bind=True, max_retries=2, default_retry_delay=30)
def generate_analysis_task(self, simulation_id: int, user_id: int) -> dict:
    """
    Celery task: compute performance metrics and generate AI feedback.
    Runs asynchronously after the user ends a simulation.
    """
    import asyncio
    from sqlmodel import select
    from src.db.session import async_session_factory
    from src.apps.simulator.models import Simulation, Trade, SimulationStatus
    from src.apps.simulator.services import SimulatorService
    from src.apps.market.services import MarketService
    from src.apps.ai_analysis.models import AIAnalysis, AnalysisStatus
    from src.apps.ai_analysis.services import (
        PerformanceCalculator, generate_ai_feedback
    )

    async def _run():
        async with async_session_factory() as db:
            # 1. Load simulation
            result = await db.execute(
                select(Simulation).where(Simulation.id == simulation_id)
            )
            sim = result.scalar_one_or_none()
            if not sim:
                return {"error": "Simulation not found"}

            # 2. Load all trades
            result2 = await db.execute(
                select(Trade).where(Trade.simulation_id == simulation_id)
                .order_by(Trade.created_at.asc())
            )
            trades = result2.scalars().all()

            # 3. Compute portfolio value (holdings × current prices)
            holdings = await SimulatorService.get_holdings(db, simulation_id)
            portfolio_value = 0.0
            for h in holdings:
                price = await MarketService.get_price_on_date(
                    db, h.symbol, sim.current_sim_date.date()
                )
                if price:
                    portfolio_value += price * h.quantity

            # 4. Compute metrics
            metrics = PerformanceCalculator.compute(
                trades, sim.initial_capital, sim.cash_balance, portfolio_value
            )

            # 5. Get or create AIAnalysis record
            ar = await db.execute(
                select(AIAnalysis).where(AIAnalysis.simulation_id == simulation_id)
            )
            analysis = ar.scalar_one_or_none()
            if not analysis:
                analysis = AIAnalysis(
                    simulation_id=simulation_id,
                    user_id=user_id,
                    status=AnalysisStatus.PROCESSING,
                )
                db.add(analysis)
                await db.commit()
                await db.refresh(analysis)

            # 6. Generate LLM feedback
            analysis = await generate_ai_feedback(db, analysis, list(trades), metrics, sim)

            # 7. Mark simulation as analysis_ready
            from src.apps.simulator.models import SimulationStatus
            sim.status = SimulationStatus.ANALYSIS_READY
            db.add(sim)
            await db.commit()

            return {"status": "completed", "analysis_id": analysis.id}

    try:
        return asyncio.run(_run())
    except Exception as exc:
        raise self.retry(exc=exc)
