"""Simulator app — Pydantic request/response schemas."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

from .models import SimulationStatus, TradeSide, TradeStatus


# ─── Simulation ───────────────────────────────────────────────────────────────

class SimulationCreate(BaseModel):
    initial_capital: float = Field(default=100_000.0, ge=10_000, le=10_000_000,
                                   description="Starting capital in NPR")
    name: Optional[str] = Field(default=None, max_length=100)


class PortfolioHolding(BaseModel):
    symbol: str
    quantity: int
    average_buy_price: float
    current_price: Optional[float] = None
    current_value: Optional[float] = None
    unrealised_pnl: Optional[float] = None
    unrealised_pnl_pct: Optional[float] = None

    model_config = {"from_attributes": True}


class SimulationResponse(BaseModel):
    id: int
    user_id: int
    name: Optional[str]
    initial_capital: float
    cash_balance: float
    status: SimulationStatus
    period_start: datetime
    period_end: datetime
    current_sim_date: datetime
    seconds_per_day: int
    started_at: datetime
    ended_at: Optional[datetime]
    # Enriched fields (computed by service)
    portfolio_value: Optional[float] = None
    total_value: Optional[float] = None   # cash + portfolio
    total_pnl: Optional[float] = None
    total_pnl_pct: Optional[float] = None
    holdings: Optional[list[PortfolioHolding]] = None

    model_config = {"from_attributes": True}


class SimulationSummary(BaseModel):
    """Compact version for the simulation history list."""
    id: int
    name: Optional[str]
    status: SimulationStatus
    initial_capital: float
    seconds_per_day: int
    started_at: datetime
    ended_at: Optional[datetime]
    total_pnl: Optional[float] = None
    total_pnl_pct: Optional[float] = None
    total_trades: Optional[int] = None

    model_config = {"from_attributes": True}


# ─── Trade ────────────────────────────────────────────────────────────────────

class TradeRequest(BaseModel):
    symbol: str = Field(max_length=20)
    side: TradeSide
    quantity: int = Field(ge=1, description="Number of shares to buy/sell. Must be >= lot_size.")


class TradeResponse(BaseModel):
    id: int
    simulation_id: int
    symbol: str
    side: TradeSide
    quantity: int
    executed_price: float
    sebon_commission: float
    broker_commission: float
    dp_charge: float
    total_cost: float
    sim_date: datetime
    status: TradeStatus
    rejection_reason: Optional[str]
    realised_pnl: Optional[float]
    created_at: datetime
    # Updated balances returned inline for instant UI update
    new_cash_balance: Optional[float] = None
    message: Optional[str] = None

    model_config = {"from_attributes": True}


class EndSimulationResponse(BaseModel):
    simulation_id: int
    status: SimulationStatus
    message: str
    analysis_task_id: Optional[str] = None


class SimulationTickConfigUpdate(BaseModel):
    seconds_per_day: int = Field(ge=1, le=300, description="Real seconds per simulated trading day")
