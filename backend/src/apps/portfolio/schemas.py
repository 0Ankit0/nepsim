"""Portfolio App — Pydantic request/response schemas."""
from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class PortfolioItemCreate(BaseModel):
    symbol: str
    quantity: int
    avg_buy_price: float
    buy_date: str
    notes: Optional[str] = None


class PortfolioItemUpdate(BaseModel):
    quantity: Optional[int] = None
    avg_buy_price: Optional[float] = None
    notes: Optional[str] = None


class PortfolioItemResponse(BaseModel):
    id: int
    symbol: str
    quantity: int
    avg_buy_price: float
    buy_date: str
    notes: Optional[str]
    created_at: datetime
    # Enriched from Supabase (may be None if data unavailable)
    current_price: Optional[float] = None
    current_value: Optional[float] = None
    cost_basis: float  # quantity * avg_buy_price
    unrealised_pnl: Optional[float] = None
    unrealised_pnl_pct: Optional[float] = None
    weeks_52_high: Optional[float] = None
    weeks_52_low: Optional[float] = None


class PortfolioAlertResponse(BaseModel):
    id: int
    portfolio_item_id: int
    symbol: str
    alert_type: str
    signal_score: float
    analysis_summary: str
    key_signals: list[str]
    recommended_action: str
    current_price: Optional[float]
    created_at: datetime
    is_read: bool
