"""Watchlist App — SQLModel database models."""
from datetime import datetime
from typing import Optional

from sqlmodel import Field, SQLModel


class WatchlistItem(SQLModel, table=True):
    __tablename__ = "watchlist_items"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    symbol: str = Field(max_length=20, index=True)
    notes: Optional[str] = Field(default=None, max_length=500)
    target_price: Optional[float] = None
    stop_loss: Optional[float] = None
    created_at: datetime = Field(default_factory=datetime.now)


class WatchlistAlert(SQLModel, table=True):
    __tablename__ = "watchlist_alerts"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    watchlist_item_id: int = Field(foreign_key="watchlist_items.id", index=True)
    symbol: str = Field(max_length=20)
    alert_type: str  # BUY_STRONG | BUY_CONSIDER | ACCUMULATE | WAIT
    signal_score: float
    analysis_summary: str
    key_signals: str  # JSON-encoded list[str]
    entry_price: Optional[float] = None
    target_price: Optional[float] = None
    stop_loss_price: Optional[float] = None
    created_at: datetime = Field(default_factory=datetime.now)
    is_read: bool = Field(default=False)
