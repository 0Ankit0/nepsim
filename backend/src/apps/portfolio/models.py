"""Portfolio App — SQLModel database models."""
from datetime import datetime
from typing import Optional

from sqlmodel import Field, SQLModel


class PortfolioItem(SQLModel, table=True):
    __tablename__ = "portfolio_items"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    symbol: str = Field(max_length=20, index=True)
    quantity: int
    avg_buy_price: float
    buy_date: str  # YYYY-MM-DD text
    notes: Optional[str] = Field(default=None, max_length=500)
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)


class PortfolioAlert(SQLModel, table=True):
    __tablename__ = "portfolio_alerts"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    portfolio_item_id: int = Field(foreign_key="portfolio_items.id", index=True)
    symbol: str = Field(max_length=20)
    alert_type: str  # SELL_STRONG | SELL_CONSIDER | WARNING
    signal_score: float
    analysis_summary: str
    key_signals: str  # JSON-encoded list[str]
    recommended_action: str
    current_price: Optional[float] = None
    created_at: datetime = Field(default_factory=datetime.now)
    is_read: bool = Field(default=False)
