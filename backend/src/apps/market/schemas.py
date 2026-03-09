"""Market app — Pydantic request/response schemas."""
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel


# ─── Stock ───────────────────────────────────────────────────────────────────

class StockListItem(BaseModel):
    id: int
    symbol: str
    company_name: str
    sector: str
    lot_size: int
    tick_size: float
    listing_status: str

    model_config = {"from_attributes": True}


class StockDetail(StockListItem):
    face_value: float
    description: Optional[str]
    current_price: Optional[float] = None   # Injected by service from latest OHLCV
    previous_close: Optional[float] = None
    change_pct: Optional[float] = None


class StockCreate(BaseModel):
    symbol: str
    company_name: str
    sector: str
    lot_size: int = 10
    face_value: float = 100.0
    tick_size: float = 0.1
    listing_status: str = "listed"
    description: Optional[str] = None


class StockUpdate(BaseModel):
    symbol: Optional[str] = None
    company_name: Optional[str] = None
    sector: Optional[str] = None
    lot_size: Optional[int] = None
    face_value: Optional[float] = None
    tick_size: Optional[float] = None
    listing_status: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None


# ─── OHLCV ───────────────────────────────────────────────────────────────────

class OHLCVPoint(BaseModel):
    date: date
    open: float
    high: float
    low: float
    close: float
    volume: int
    adjusted_close: Optional[float] = None

    model_config = {"from_attributes": True}


class HistoryResponse(BaseModel):
    symbol: str
    data: list[OHLCVPoint]


# ─── Indicators ──────────────────────────────────────────────────────────────

class IndicatorRequest(BaseModel):
    symbol: str
    indicator: str               # e.g. "rsi", "macd", "bb", "ema", "sma"
    period: int = 14             # lookback window
    fast: Optional[int] = 12    # MACD fast period
    slow: Optional[int] = 26    # MACD slow period
    signal: Optional[int] = 9   # MACD signal
    std_dev: Optional[float] = 2.0  # Bollinger band std
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class IndicatorDataPoint(BaseModel):
    date: date
    value: Optional[float] = None
    # MACD specific
    macd: Optional[float] = None
    signal: Optional[float] = None
    histogram: Optional[float] = None
    # Bollinger specific
    upper: Optional[float] = None
    middle: Optional[float] = None
    lower: Optional[float] = None


class IndicatorResponse(BaseModel):
    symbol: str
    indicator: str
    period: int
    data: list[IndicatorDataPoint]


# ─── Chart Drawings ──────────────────────────────────────────────────────────

class ChartDrawingCreate(BaseModel):
    symbol: str
    drawing_type: str
    coordinates: str    # JSON string
    parameters: Optional[str] = None
    label: Optional[str] = None


class ChartDrawingResponse(BaseModel):
    id: int
    symbol: str
    drawing_type: str
    coordinates: str
    parameters: Optional[str]
    label: Optional[str]
    is_visible: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
