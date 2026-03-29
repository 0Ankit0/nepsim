"""Simulator app — FastAPI router."""
import json
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from src.db.session import get_session
from src.apps.iam.api.deps import get_current_user
from src.apps.iam.models.user import User
from .models import Simulation, Trade
from .schemas import (
    SimulationCreate, SimulationResponse, SimulationSummary,
    TradeRequest, TradeResponse, EndSimulationResponse,
    PortfolioHolding, SimulationTickConfigUpdate,
)
from .services import (
    SimulatorService, InsufficientFundsError,
    InsufficientSharesError, StockNotAvailableError,
)

router = APIRouter(prefix="/simulations", tags=["Simulation"])


def _enrich_simulation(sim: Simulation) -> dict:
    d = sim.model_dump()
    d["portfolio_value"] = None
    d["total_value"] = sim.cash_balance
    d["total_pnl"] = round(sim.cash_balance - sim.initial_capital, 2)
    d["total_pnl_pct"] = round(
        ((sim.cash_balance - sim.initial_capital) / sim.initial_capital) * 100, 2
    )
    return d


# ─── List / Create ────────────────────────────────────────────────────────────

@router.get("/", response_model=list[SimulationSummary])
async def list_simulations(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """List all of the current user's simulations."""
    sims = await SimulatorService.list_simulations(db, current_user.id)
    return sims


@router.post("/", response_model=SimulationResponse, status_code=status.HTTP_201_CREATED)
async def create_simulation(
    payload: SimulationCreate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Start a new simulation with a randomly selected historical NEPSE period."""
    sim = await SimulatorService.create_simulation(
        db,
        user_id=current_user.id,
        initial_capital=payload.initial_capital,
        name=payload.name,
    )
    return sim


# ─── Simulation Detail ────────────────────────────────────────────────────────

@router.get("/{simulation_id}", response_model=SimulationResponse)
async def get_simulation(
    simulation_id: int,
    include_holdings: bool = Query(True),
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    sim = await SimulatorService.get_simulation(db, simulation_id, current_user.id)
    if not sim:
        raise HTTPException(status_code=404, detail="Simulation not found.")

    holdings_list: Optional[list[PortfolioHolding]] = None
    if include_holdings:
        from src.apps.market.services import MarketService
        holdings = await SimulatorService.get_holdings(db, simulation_id)
        portfolio_value = 0.0
        holdings_list = []
        for h in holdings:
            price = await MarketService.get_price_on_date(
                db, h.symbol, sim.current_sim_date.date()
            )
            current_val = (price or h.average_buy_price) * h.quantity
            unrealised = round(current_val - h.average_buy_price * h.quantity, 2)
            unrealised_pct = round((unrealised / (h.average_buy_price * h.quantity)) * 100, 2) if h.average_buy_price else 0.0
            portfolio_value += current_val
            holdings_list.append(PortfolioHolding(
                symbol=h.symbol,
                quantity=h.quantity,
                average_buy_price=h.average_buy_price,
                current_price=price,
                current_value=round(current_val, 2),
                unrealised_pnl=unrealised,
                unrealised_pnl_pct=unrealised_pct,
            ))

    data = _enrich_simulation(sim)
    if holdings_list is not None:
        data["holdings"] = [h.model_dump() for h in holdings_list]
        data["portfolio_value"] = round(sum(h.current_value or 0 for h in holdings_list), 2)
        data["total_value"] = round(sim.cash_balance + (data["portfolio_value"] or 0), 2)
        data["total_pnl"] = round(data["total_value"] - sim.initial_capital, 2)
        data["total_pnl_pct"] = round((data["total_pnl"] / sim.initial_capital) * 100, 2)

    return SimulationResponse(**{k: v for k, v in data.items() if k in SimulationResponse.model_fields})


# ─── Trade ────────────────────────────────────────────────────────────────────

@router.post("/{simulation_id}/trade", response_model=TradeResponse)
async def execute_trade(
    simulation_id: int,
    payload: TradeRequest,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Execute a buy or sell order within the simulation at today's simulated price."""
    try:
        trade = await SimulatorService.execute_trade(
            db, simulation_id, current_user.id, payload
        )
        # Load updated sim for return
        sim = await SimulatorService.get_simulation(db, simulation_id, current_user.id)
        response_data = trade.model_dump()
        response_data["new_cash_balance"] = sim.cash_balance if sim else None
        return TradeResponse(**response_data)
    except InsufficientFundsError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except InsufficientSharesError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except StockNotAvailableError as e:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


# ─── Advance Day ──────────────────────────────────────────────────────────────

@router.post("/{simulation_id}/advance-day", response_model=SimulationResponse)
async def advance_day(
    simulation_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Advance the simulated market by one trading day."""
    try:
        sim = await SimulatorService.advance_day(db, simulation_id, current_user.id)
        return sim
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{simulation_id}/pause", response_model=SimulationResponse)
async def pause_simulation(
    simulation_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    try:
        sim = await SimulatorService.pause_simulation(db, simulation_id, current_user.id)
        return sim
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{simulation_id}/resume", response_model=SimulationResponse)
async def resume_simulation(
    simulation_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    try:
        sim = await SimulatorService.resume_simulation(db, simulation_id, current_user.id)
        return sim
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.patch("/{simulation_id}/tick-config", response_model=SimulationResponse)
async def update_tick_config(
    simulation_id: int,
    payload: SimulationTickConfigUpdate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    try:
        sim = await SimulatorService.update_tick_config(db, simulation_id, current_user.id, payload.seconds_per_day)
        return sim
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


# ─── End Simulation ───────────────────────────────────────────────────────────

@router.post("/{simulation_id}/end", response_model=EndSimulationResponse)
async def end_simulation(
    simulation_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """End the simulation and trigger AI analysis generation (async Celery task)."""
    try:
        sim = await SimulatorService.end_simulation(db, simulation_id, current_user.id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    # Dispatch Celery task
    task_id: Optional[str] = None
    try:
        from src.apps.ai_analysis.tasks import generate_analysis_task
        task = generate_analysis_task.delay(simulation_id, current_user.id)
        task_id = task.id
    except Exception:
        task_id = None  # Fail silently; user can retry analysis view

    return EndSimulationResponse(
        simulation_id=sim.id,
        status=sim.status,
        message="Simulation ended. AI analysis is being generated. Check back in 30 seconds.",
        analysis_task_id=task_id,
    )


# ─── Trade History ────────────────────────────────────────────────────────────

@router.get("/{simulation_id}/trades", response_model=list[TradeResponse])
async def get_trades(
    simulation_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    sim = await SimulatorService.get_simulation(db, simulation_id, current_user.id)
    if not sim:
        raise HTTPException(status_code=404, detail="Simulation not found.")
    result = await db.execute(
        select(Trade)
        .where(Trade.simulation_id == simulation_id)
        .order_by(Trade.created_at.asc())
    )
    trades = result.scalars().all()
    return [TradeResponse(**t.model_dump()) for t in trades]
