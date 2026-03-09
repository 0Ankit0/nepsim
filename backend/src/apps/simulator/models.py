"""
NEPSIM Simulator App — SQLModel database models.

Tables:
- simulations           : A user's trading simulation session
- simulation_portfolios : Current stock holdings within a simulation
- trades                : Individual buy/sell transactions
"""
from datetime import datetime
from enum import Enum
from typing import Optional
from sqlmodel import Field, SQLModel


# ─── Simulation ──────────────────────────────────────────────────────────────

class SimulationStatus(str, Enum):
    ACTIVE = "active"
    PAUSED = "paused"
    ENDED = "ended"
    ANALYSING = "analysing"  # AI analysis in progress
    ANALYSIS_READY = "analysis_ready"

class SimulationBase(SQLModel):
    user_id: int = Field(foreign_key="user.id", index=True)
    initial_capital: float = Field(
        default=100_000.0,
        description="Starting virtual balance in NPR",
    )
    cash_balance: float = Field(
        description="Current available cash in NPR",
    )
    status: SimulationStatus = Field(
        default=SimulationStatus.ACTIVE,
    )
    # Historical period being replayed (randomly selected on creation)
    period_start: datetime = Field(
        description="Start date of the historical NEPSE period being simulated",
    )
    period_end: datetime = Field(
        description="End date of the historical period",
    )
    current_sim_date: datetime = Field(
        description="Current simulated trading day within the period",
    )
    # Speed config: how many real seconds = 1 simulated trading day
    seconds_per_day: int = Field(
        default=30,
        description="Real-time seconds elapsed per simulated trading day",
    )
    name: Optional[str] = Field(
        default=None,
        max_length=100,
        description="Optional user-given name for this simulation",
    )

class Simulation(SimulationBase, table=True):
    __tablename__ = "simulations"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    started_at: datetime = Field(default_factory=datetime.now)
    ended_at: Optional[datetime] = Field(default=None)
    updated_at: datetime = Field(default_factory=datetime.now)


# ─── SimulationPortfolio ─────────────────────────────────────────────────────

class SimulationPortfolioBase(SQLModel):
    simulation_id: int = Field(foreign_key="simulations.id", index=True)
    symbol: str = Field(max_length=20, index=True)
    quantity: int = Field(description="Number of shares held")
    average_buy_price: float = Field(description="Volume-weighted average cost per share in NPR")

class SimulationPortfolio(SimulationPortfolioBase, table=True):
    __tablename__ = "simulation_portfolios"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    last_updated: datetime = Field(default_factory=datetime.now)


# ─── Trade ───────────────────────────────────────────────────────────────────

class TradeSide(str, Enum):
    BUY = "buy"
    SELL = "sell"

class TradeStatus(str, Enum):
    EXECUTED = "executed"
    REJECTED = "rejected"
    PARTIAL = "partial"

class TradeBase(SQLModel):
    simulation_id: int = Field(foreign_key="simulations.id", index=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    symbol: str = Field(max_length=20, index=True)
    side: TradeSide
    quantity: int = Field(description="Shares bought or sold")
    # Prices
    requested_price: float = Field(description="Day's closing price used as reference in NPR")
    executed_price: float = Field(description="Actual fill price after slippage in NPR")
    # Costs (SEBON + broker fees, NEPSE rules)
    sebon_commission: float = Field(description="SEBON regulatory fee in NPR (0.015% of turnover)")
    broker_commission: float = Field(description="Broker fee in NPR (~0.4% of turnover)")
    dp_charge: float = Field(default=25.0, description="DP (CDSC) charge per transaction in NPR")
    total_cost: float = Field(description="Total transaction cost including all fees in NPR")
    # Sim date on which this trade was placed
    sim_date: datetime = Field(description="Simulated trading day this order was placed")
    status: TradeStatus = Field(default=TradeStatus.EXECUTED)
    rejection_reason: Optional[str] = Field(default=None, max_length=255)
    # P&L (realised only when selling)
    realised_pnl: Optional[float] = Field(
        default=None,
        description="Realised profit/loss in NPR when selling (null for buys)",
    )

class Trade(TradeBase, table=True):
    __tablename__ = "trades"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)
