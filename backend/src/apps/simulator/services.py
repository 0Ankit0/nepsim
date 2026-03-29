"""
Simulator service — core trading simulation engine.

Enforces NEPSE trading rules:
 - Daily resolution only (one price per trading day)
 - SEBON fee: 0.015% of turnover
 - Broker fee: ~0.40% (simplified flat rate)
 - DP (CDSC) charge: NPR 25 per transaction
 - Minimum lot sizes respected
 - Cannot exceed available cash on buy
 - Cannot sell more than held quantity
"""
from __future__ import annotations

import random
from datetime import date, datetime, timedelta
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, and_

from ..market.services import MarketService
from .models import (
    Simulation, SimulationPortfolio, SimulationStatus,
    Trade, TradeSide, TradeStatus,
)
from .schemas import TradeRequest


# ─── Fee constants (NEPSE / SEBON rules) ─────────────────────────────────────
SEBON_RATE = 0.00015    # 0.015% of turnover
BROKER_RATE = 0.004     # 0.4% of turnover (simplified)
DP_CHARGE = 25.0        # NPR 25 CDSC charge per transaction
SLIPPAGE_RATE = 0.002   # 0.2% average market-impact slippage


class InsufficientFundsError(Exception):
    pass

class InsufficientSharesError(Exception):
    pass

class MarketClosedError(Exception):
    pass

class StockNotAvailableError(Exception):
    pass


class SimulatorService:

    # ── Simulation Lifecycle ─────────────────────────────────────────────────

    @staticmethod
    async def create_simulation(
        db: AsyncSession,
        user_id: int,
        initial_capital: float,
        name: Optional[str],
    ) -> Simulation:
        """
        Create a new simulation session.
        Randomly selects a past 60-trading-day window from Supabase historicdata.
        """
        from src.db.supabase import get_supabase_client

        min_date: Optional[date] = None
        max_date: Optional[date] = None

        client = await get_supabase_client()
        if client:
            try:
                # Get earliest date
                min_res = await (
                    client.table("historicdata")
                    .select("date")
                    .order("date", desc=False)
                    .limit(1)
                    .execute()
                )
                # Get latest date
                max_res = await (
                    client.table("historicdata")
                    .select("date")
                    .order("date", desc=True)
                    .limit(1)
                    .execute()
                )
                if min_res.data and max_res.data:
                    min_date = date.fromisoformat(min_res.data[0]["date"])
                    max_date = date.fromisoformat(max_res.data[0]["date"])
            except Exception:
                pass

        if not min_date or not max_date:
            # Fallback: use a synthetic window for development
            min_date = date(2020, 1, 1)
            max_date = date(2023, 12, 31)

        # Pick a random 60-day window from within available data
        window_days = 60
        range_days = (max_date - min_date).days - window_days
        if range_days <= 0:
            range_days = 1
        start_offset = random.randint(0, range_days)
        period_start = datetime.combine(min_date + timedelta(days=start_offset), datetime.min.time())
        period_end = datetime.combine(min_date + timedelta(days=start_offset + window_days), datetime.min.time())

        sim = Simulation(
            user_id=user_id,
            initial_capital=initial_capital,
            cash_balance=initial_capital,
            status=SimulationStatus.ACTIVE,
            period_start=period_start,
            period_end=period_end,
            current_sim_date=period_start,
            name=name,
        )
        db.add(sim)
        await db.commit()
        await db.refresh(sim)
        return sim


    @staticmethod
    async def get_simulation(
        db: AsyncSession, simulation_id: int, user_id: int
    ) -> Optional[Simulation]:
        result = await db.execute(
            select(Simulation).where(
                and_(Simulation.id == simulation_id, Simulation.user_id == user_id)
            )
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def list_simulations(
        db: AsyncSession, user_id: int
    ) -> list[Simulation]:
        result = await db.execute(
            select(Simulation)
            .where(Simulation.user_id == user_id)
            .order_by(Simulation.started_at.desc())
        )
        return result.scalars().all()  # type: ignore

    @staticmethod
    async def end_simulation(
        db: AsyncSession, simulation_id: int, user_id: int
    ) -> Simulation:
        sim = await SimulatorService.get_simulation(db, simulation_id, user_id)
        if not sim or sim.status not in (SimulationStatus.ACTIVE, SimulationStatus.PAUSED):
            raise ValueError("Simulation not found or already ended.")
        sim.status = SimulationStatus.ANALYSING
        sim.ended_at = datetime.now()
        sim.updated_at = datetime.now()
        db.add(sim)
        await db.commit()
        await db.refresh(sim)
        return sim

    @staticmethod
    async def pause_simulation(db: AsyncSession, simulation_id: int, user_id: int) -> Simulation:
        sim = await SimulatorService.get_simulation(db, simulation_id, user_id)
        if not sim or sim.status != SimulationStatus.ACTIVE:
            raise ValueError("Simulation not found or not active.")

        sim.status = SimulationStatus.PAUSED
        sim.updated_at = datetime.now()
        db.add(sim)
        await db.commit()
        await db.refresh(sim)
        return sim

    @staticmethod
    async def resume_simulation(db: AsyncSession, simulation_id: int, user_id: int) -> Simulation:
        sim = await SimulatorService.get_simulation(db, simulation_id, user_id)
        if not sim or sim.status != SimulationStatus.PAUSED:
            raise ValueError("Simulation not found or not paused.")

        sim.status = SimulationStatus.ACTIVE
        sim.updated_at = datetime.now()
        db.add(sim)
        await db.commit()
        await db.refresh(sim)
        return sim

    @staticmethod
    async def update_tick_config(
        db: AsyncSession,
        simulation_id: int,
        user_id: int,
        seconds_per_day: int,
    ) -> Simulation:
        sim = await SimulatorService.get_simulation(db, simulation_id, user_id)
        if not sim or sim.status not in (SimulationStatus.ACTIVE, SimulationStatus.PAUSED):
            raise ValueError("Simulation not found or not configurable.")

        sim.seconds_per_day = seconds_per_day
        sim.updated_at = datetime.now()
        db.add(sim)
        await db.commit()
        await db.refresh(sim)
        return sim

    # ── Portfolio ───────────────────────────────────────────────────────────

    @staticmethod
    async def get_holdings(
        db: AsyncSession, simulation_id: int
    ) -> list[SimulationPortfolio]:
        result = await db.execute(
            select(SimulationPortfolio).where(
                and_(
                    SimulationPortfolio.simulation_id == simulation_id,
                    SimulationPortfolio.quantity > 0,
                )
            )
        )
        return result.scalars().all()  # type: ignore

    # ── Trade Execution ──────────────────────────────────────────────────────

    @staticmethod
    async def execute_trade(
        db: AsyncSession,
        simulation_id: int,
        user_id: int,
        req: TradeRequest,
    ) -> Trade:
        sim = await SimulatorService.get_simulation(db, simulation_id, user_id)
        if not sim or sim.status != SimulationStatus.ACTIVE:
            raise ValueError("Simulation not found or not active.")

        sim_date = sim.current_sim_date
        symbol = req.symbol.upper()

        # ── Get closing price for this sim day ──────────────────────────────
        price = await MarketService.get_price_on_date(db, symbol, sim_date.date())
        if price is None:
            raise StockNotAvailableError(
                f"{symbol} has no price data for {sim_date.date()}. "
                "Try a different stock or date."
            )

        # ── Apply slippage ────────────────────────────────────────────────
        slippage = price * SLIPPAGE_RATE
        if req.side == TradeSide.BUY:
            executed_price = round(price + slippage, 2)
        else:
            executed_price = round(price - slippage, 2)

        # ── Fee calculation ───────────────────────────────────────────────
        turnover = executed_price * req.quantity
        sebon_fee = round(turnover * SEBON_RATE, 2)
        broker_fee = round(turnover * BROKER_RATE, 2)
        total_cost = round(turnover + sebon_fee + broker_fee + DP_CHARGE, 2)

        # ── Validation ────────────────────────────────────────────────────
        if req.side == TradeSide.BUY:
            total_deduct = total_cost  # buy: cash goes out
            if total_deduct > sim.cash_balance:
                max_shares = int(
                    (sim.cash_balance - sebon_fee - broker_fee - DP_CHARGE)
                    / (executed_price * (1 + SEBON_RATE + BROKER_RATE))
                )
                raise InsufficientFundsError(
                    f"Insufficient funds. You can buy at most {max(0, max_shares)} shares "
                    f"with NPR {sim.cash_balance:,.2f} available."
                )
        else:
            # Sell: check holdings
            holding_result = await db.execute(
                select(SimulationPortfolio).where(
                    and_(
                        SimulationPortfolio.simulation_id == simulation_id,
                        SimulationPortfolio.symbol == symbol,
                    )
                )
            )
            holding = holding_result.scalar_one_or_none()
            held_qty = holding.quantity if holding else 0
            if req.quantity > held_qty:
                raise InsufficientSharesError(
                    f"You only hold {held_qty} shares of {symbol}. Cannot sell {req.quantity}."
                )

        # ── Realised P&L (for sells) ─────────────────────────────────────
        realised_pnl: Optional[float] = None
        holding_for_pnl = None
        if req.side == TradeSide.SELL:
            hr2 = await db.execute(
                select(SimulationPortfolio).where(
                    and_(
                        SimulationPortfolio.simulation_id == simulation_id,
                        SimulationPortfolio.symbol == symbol,
                    )
                )
            )
            holding_for_pnl = hr2.scalar_one_or_none()
            if holding_for_pnl:
                gross_proceeds = executed_price * req.quantity
                cost_basis = holding_for_pnl.average_buy_price * req.quantity
                realised_pnl = round(gross_proceeds - cost_basis - sebon_fee - broker_fee - DP_CHARGE, 2)

        # ── Persist Trade ─────────────────────────────────────────────────
        trade = Trade(
            simulation_id=simulation_id,
            user_id=user_id,
            symbol=symbol,
            side=req.side,
            quantity=req.quantity,
            requested_price=price,
            executed_price=executed_price,
            sebon_commission=sebon_fee,
            broker_commission=broker_fee,
            dp_charge=DP_CHARGE,
            total_cost=total_cost,
            sim_date=sim_date,
            status=TradeStatus.EXECUTED,
            realised_pnl=realised_pnl,
        )
        db.add(trade)

        # ── Update Portfolio ───────────────────────────────────────────────
        await SimulatorService._update_portfolio(
            db, simulation_id, symbol, req.side, req.quantity, executed_price
        )

        # ── Update Cash Balance ────────────────────────────────────────────
        if req.side == TradeSide.BUY:
            sim.cash_balance = round(sim.cash_balance - total_cost, 2)
        else:
            net_proceeds = round(turnover - sebon_fee - broker_fee - DP_CHARGE, 2)
            sim.cash_balance = round(sim.cash_balance + net_proceeds, 2)

        sim.updated_at = datetime.now()
        db.add(sim)
        await db.commit()
        await db.refresh(trade)
        return trade

    @staticmethod
    async def _update_portfolio(
        db: AsyncSession,
        simulation_id: int,
        symbol: str,
        side: TradeSide,
        quantity: int,
        executed_price: float,
    ) -> None:
        result = await db.execute(
            select(SimulationPortfolio).where(
                and_(
                    SimulationPortfolio.simulation_id == simulation_id,
                    SimulationPortfolio.symbol == symbol,
                )
            )
        )
        holding = result.scalar_one_or_none()

        if side == TradeSide.BUY:
            if holding:
                # VWAP average price
                total_cost_before = holding.average_buy_price * holding.quantity
                new_total_cost = total_cost_before + executed_price * quantity
                holding.quantity += quantity
                holding.average_buy_price = round(new_total_cost / holding.quantity, 4)
                holding.last_updated = datetime.now()
                db.add(holding)
            else:
                new_holding = SimulationPortfolio(
                    simulation_id=simulation_id,
                    symbol=symbol,
                    quantity=quantity,
                    average_buy_price=executed_price,
                )
                db.add(new_holding)
        else:  # SELL
            if holding:
                holding.quantity = max(0, holding.quantity - quantity)
                holding.last_updated = datetime.now()
                db.add(holding)

    # ── Advance Simulation Day ────────────────────────────────────────────────

    @staticmethod
    async def advance_day(db: AsyncSession, simulation_id: int, user_id: int) -> Simulation:
        sim = await SimulatorService.get_simulation(db, simulation_id, user_id)
        if not sim or sim.status != SimulationStatus.ACTIVE:
            raise ValueError("Simulation not found or not active.")
        # Advance by 1 calendar day (weekends still advance; data skips take care of holidays)
        sim.current_sim_date = sim.current_sim_date + timedelta(days=1)
        sim.updated_at = datetime.now()
        # Auto-end if we've passed period_end
        if sim.current_sim_date > sim.period_end:
            sim.status = SimulationStatus.ENDED
            sim.ended_at = datetime.now()
        db.add(sim)
        await db.commit()
        await db.refresh(sim)
        return sim
