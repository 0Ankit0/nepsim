"""
NEPSIM Market App — SQLModel database models.

Tables:
- stock_metadata      : NEPSE-listed stock info (symbol, sector, lot size, etc.)
- market_data_ohlcv   : Daily OHLCV price records
- corporate_actions   : Splits, dividends that adjust historical prices
- chart_drawings      : Per-user, per-symbol persisted chart annotations
"""
from datetime import date, datetime
from enum import Enum
from typing import Optional
from sqlmodel import Field, SQLModel


# ─── StockMetadata ──────────────────────────────────────────────────────────

class StockMetadataBase(SQLModel):
    symbol: str = Field(
        unique=True,
        index=True,
        max_length=20,
        description="NEPSE ticker symbol (e.g. NABIL, SCB)",
    )
    company_name: str = Field(max_length=255, description="Full company name")
    sector: str = Field(
        max_length=100,
        default="General",
        description="Sector (Banking, Hydropower, Insurance, etc.)",
    )
    listing_status: str = Field(
        max_length=20,
        default="listed",
        description="listed | delisted | suspended",
    )
    lot_size: int = Field(
        default=10,
        description="Minimum tradeable lot size (number of shares)",
    )
    tick_size: float = Field(
        default=1.0,
        description="Minimum price movement increment in NPR",
    )
    face_value: float = Field(
        default=100.0,
        description="Par value per share in NPR",
    )
    description: Optional[str] = Field(
        default=None,
        max_length=1000,
        description="Short description of the company",
    )
    is_active: bool = Field(default=True)


class StockMetadata(StockMetadataBase, table=True):
    __tablename__ = "stock_metadata"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)


# ─── MarketDataOHLCV ─────────────────────────────────────────────────────────

class MarketDataOHLCVBase(SQLModel):
    symbol: str = Field(
        index=True,
        max_length=20,
        description="NEPSE ticker symbol",
    )
    trade_date: date = Field(
        index=True,
        description="Trading date (daily resolution — one record per symbol per day)",
    )
    open: float = Field(description="Opening price in NPR")
    high: float = Field(description="Intraday high price in NPR")
    low: float = Field(description="Intraday low price in NPR")
    close: float = Field(description="Closing price in NPR")
    volume: int = Field(description="Shares traded on this day")
    adjusted_close: Optional[float] = Field(
        default=None,
        description="Close price adjusted for corporate actions (splits, dividends)",
    )


class MarketDataOHLCV(MarketDataOHLCVBase, table=True):
    __tablename__ = "market_data_ohlcv"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)


# ─── CorporateAction ──────────────────────────────────────────────────────────

class CorporateActionType(str, Enum):
    SPLIT = "split"
    BONUS_SHARE = "bonus_share"
    RIGHT_SHARE = "right_share"
    CASH_DIVIDEND = "cash_dividend"
    MERGER = "merger"

class CorporateActionBase(SQLModel):
    symbol: str = Field(index=True, max_length=20)
    action_type: CorporateActionType = Field(description="Type of corporate action")
    effective_date: date = Field(index=True, description="Date the adjustment takes effect")
    adjustment_factor: float = Field(
        description="Multiplicative factor applied to historical prices (e.g. 0.5 for 2:1 split)",
    )
    notes: Optional[str] = Field(default=None, max_length=500)


class CorporateAction(CorporateActionBase, table=True):
    __tablename__ = "corporate_actions"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)


# ─── ChartDrawing ─────────────────────────────────────────────────────────────

class DrawingType(str, Enum):
    TRENDLINE = "trendline"
    HORIZONTAL_LINE = "horizontal_line"
    VERTICAL_LINE = "vertical_line"
    FIBONACCI_RETRACEMENT = "fibonacci_retracement"
    FIBONACCI_EXTENSION = "fibonacci_extension"
    PARALLEL_CHANNEL = "parallel_channel"
    RECTANGLE = "rectangle"
    CIRCLE = "circle"
    TRIANGLE = "triangle"
    TEXT_NOTE = "text_note"
    SUPPORT_ZONE = "support_zone"
    RESISTANCE_ZONE = "resistance_zone"
    ARROW = "arrow"
    PRICE_LABEL = "price_label"

class ChartDrawingBase(SQLModel):
    user_id: int = Field(foreign_key="user.id", index=True)
    symbol: str = Field(max_length=20, index=True)
    drawing_type: DrawingType
    # JSON-serialised coordinate/parameter data (points, levels, etc.)
    coordinates: str = Field(description="JSON array of {date, price} anchor points")
    parameters: Optional[str] = Field(
        default=None,
        description="JSON object with drawing-specific params (color, lineWidth, levels)",
    )
    label: Optional[str] = Field(default=None, max_length=100)
    is_visible: bool = Field(default=True)


class ChartDrawing(ChartDrawingBase, table=True):
    __tablename__ = "chart_drawings"  # type: ignore

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
