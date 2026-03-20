"""Market Analysis App — Pydantic response schemas."""
from __future__ import annotations

from typing import Optional

from pydantic import BaseModel


class AnalysisResultSchema(BaseModel):
    symbol: str
    signal: str  # STRONG_BUY | BUY | HOLD | SELL | STRONG_SELL
    overall_score: float
    oscillator_score: float
    trend_score: float
    volume_score: float
    volatility_score: float
    key_signals: list[str]
    current_price: Optional[float] = None
    entry_price: Optional[float] = None
    target_price: Optional[float] = None
    stop_loss: Optional[float] = None
    risk_reward_ratio: Optional[float] = None
    analysis_date: str


class TopStocksResponse(BaseModel):
    generated_at: str
    count: int
    results: list[AnalysisResultSchema]


class MarketOverviewSchema(BaseModel):
    date: str
    total_analyzed: int
    strong_buy: int
    buy: int
    hold: int
    sell: int
    strong_sell: int
    bullish_pct: float
    bearish_pct: float


# ─── 360 View Schemas ────────────────────────────────────────────────────────

class PricePoint(BaseModel):
    date: str
    open: Optional[float] = None
    high: Optional[float] = None
    low: Optional[float] = None
    close: Optional[float] = None
    ltp: Optional[float] = None
    vol: Optional[float] = None
    vwap: Optional[float] = None
    turnover: Optional[float] = None


class IndicatorSignalSchema(BaseModel):
    name: str
    value: Optional[float] = None
    signal: str          # BULLISH | BEARISH | NEUTRAL
    interpretation: str


class PerformanceMetricsSchema(BaseModel):
    week_1_pct: Optional[float] = None
    month_1_pct: Optional[float] = None
    month_3_pct: Optional[float] = None
    month_6_pct: Optional[float] = None
    year_1_pct: Optional[float] = None
    ytd_pct: Optional[float] = None
    max_drawdown_pct: Optional[float] = None
    volatility_20d_annualized: Optional[float] = None
    avg_volume_20d: Optional[float] = None


class SimilarPeriodSchema(BaseModel):
    start_date: str
    end_date: str
    similarity_score: float   # 0–100
    forward_30d_return_pct: Optional[float] = None
    outcome: str              # BULLISH | BEARISH | NEUTRAL
    description: str


class TrendAnalysisSchema(BaseModel):
    primary_trend: str        # UPTREND | DOWNTREND | SIDEWAYS
    trend_strength: str       # STRONG | MODERATE | WEAK
    ma_alignment: str         # BULLISH | BEARISH | MIXED
    support_level: Optional[float] = None
    resistance_level: Optional[float] = None
    price_vs_sma20: Optional[str] = None   # ABOVE | BELOW
    price_vs_sma50: Optional[str] = None
    price_vs_sma200: Optional[str] = None
    golden_cross: bool = False
    death_cross: bool = False
    ichimoku_signal: Optional[str] = None  # BULLISH | BEARISH | NEUTRAL
    summary: str


class Stock360Schema(BaseModel):
    symbol: str
    analysis_date: str

    # Latest quote snapshot
    current_price: Optional[float] = None
    open_price: Optional[float] = None
    high_price: Optional[float] = None
    low_price: Optional[float] = None
    volume: Optional[float] = None
    turnover: Optional[float] = None
    vwap: Optional[float] = None
    week_52_high: Optional[float] = None
    week_52_low: Optional[float] = None
    change_pct: Optional[float] = None
    prev_close: Optional[float] = None

    # Core signal (from existing engine)
    signal: str
    overall_score: float
    oscillator_score: float
    trend_score: float
    volume_score: float
    volatility_score: float
    key_signals: list[str]
    entry_price: Optional[float] = None
    target_price: Optional[float] = None
    stop_loss: Optional[float] = None
    risk_reward_ratio: Optional[float] = None

    # Extended 360 data
    indicator_signals: list[IndicatorSignalSchema]
    performance: PerformanceMetricsSchema
    trend_analysis: TrendAnalysisSchema
    similar_periods: list[SimilarPeriodSchema]
    price_history: list[PricePoint]   # Full available history for chart
    ai_summary: Optional[str] = None
