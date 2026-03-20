"""Watchlist App — Pydantic request/response schemas."""
from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class WatchlistItemCreate(BaseModel):
    symbol: str
    notes: Optional[str] = None
    target_price: Optional[float] = None
    stop_loss: Optional[float] = None


class WatchlistItemUpdate(BaseModel):
    notes: Optional[str] = None
    target_price: Optional[float] = None
    stop_loss: Optional[float] = None


class WatchlistItemResponse(BaseModel):
    id: int
    symbol: str
    notes: Optional[str]
    target_price: Optional[float]
    stop_loss: Optional[float]
    created_at: datetime
    # Enriched from Supabase
    current_price: Optional[float] = None
    diff_pct: Optional[float] = None
    weeks_52_high: Optional[float] = None
    weeks_52_low: Optional[float] = None


class WatchlistAlertResponse(BaseModel):
    id: int
    watchlist_item_id: int
    symbol: str
    alert_type: str
    signal_score: float
    analysis_summary: str
    key_signals: list[str]
    entry_price: Optional[float]
    target_price: Optional[float]
    stop_loss_price: Optional[float]
    created_at: datetime
    is_read: bool
