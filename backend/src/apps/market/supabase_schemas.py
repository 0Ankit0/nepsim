"""
Market app — Pydantic schemas for the three Supabase tables:
  - historicdata
  - indicators
  - indices
"""
from __future__ import annotations

from typing import Optional
from pydantic import BaseModel


# ─── historicdata ────────────────────────────────────────────────────────────

class HistoricDataRow(BaseModel):
    """Mirrors public.historicdata in Supabase."""
    id: Optional[int] = None
    date: Optional[str] = None
    symbol: Optional[str] = None
    conf: Optional[float] = None
    open: Optional[float] = None
    high: Optional[float] = None
    low: Optional[float] = None
    close: Optional[float] = None
    ltp: Optional[float] = None
    close_minus_ltp: Optional[float] = None
    close_minus_ltp_pct: Optional[float] = None
    vwap: Optional[float] = None
    vol: Optional[float] = None
    prev_close: Optional[float] = None
    turnover: Optional[float] = None
    trans: Optional[float] = None
    diff: Optional[float] = None
    range: Optional[float] = None
    diff_pct: Optional[float] = None
    range_pct: Optional[float] = None
    vwap_pct: Optional[float] = None
    weeks_52_high: Optional[float] = None
    weeks_52_low: Optional[float] = None

    model_config = {"from_attributes": True}


class HistoricDataResponse(BaseModel):
    symbol: str
    count: int
    data: list[HistoricDataRow]


class LatestQuoteResponse(BaseModel):
    symbol: str
    date: Optional[str] = None
    ltp: Optional[float] = None
    open: Optional[float] = None
    high: Optional[float] = None
    low: Optional[float] = None
    close: Optional[float] = None
    prev_close: Optional[float] = None
    diff: Optional[float] = None
    diff_pct: Optional[float] = None
    vwap: Optional[float] = None
    vol: Optional[float] = None
    turnover: Optional[float] = None
    weeks_52_high: Optional[float] = None
    weeks_52_low: Optional[float] = None


# ─── indicators ──────────────────────────────────────────────────────────────

class IndicatorRow(BaseModel):
    """Canonical indicator row used by both Supabase reads and computed analysis."""
    id: Optional[int] = None
    date: Optional[str] = None
    symbol: Optional[str] = None
    rsi_6: Optional[float] = None
    rsi_12: Optional[float] = None
    rsi_14: Optional[float] = None
    rsi_24: Optional[float] = None
    macd_line: Optional[float] = None
    macd_signal: Optional[float] = None
    macd_hist: Optional[float] = None
    kdj_k: Optional[float] = None
    kdj_d: Optional[float] = None
    kdj_j: Optional[float] = None
    stoch_k: Optional[float] = None
    stoch_d: Optional[float] = None
    bias_6: Optional[float] = None
    bias_12: Optional[float] = None
    bias_24: Optional[float] = None
    cci_20: Optional[float] = None
    br: Optional[float] = None
    ar: Optional[float] = None
    cr: Optional[float] = None
    cr_ma_10: Optional[float] = None
    cr_ma_20: Optional[float] = None
    cr_ma_40: Optional[float] = None
    cr_ma_60: Optional[float] = None
    psy: Optional[float] = None
    psy_ma_6: Optional[float] = None
    williams_r: Optional[float] = None
    williams_r_6: Optional[float] = None
    williams_r_10: Optional[float] = None
    momentum_5: Optional[float] = None
    mtm_12: Optional[float] = None
    mtm_ma_6: Optional[float] = None
    sma_5: Optional[float] = None
    sma_10: Optional[float] = None
    sma_12_2: Optional[float] = None
    sma_20: Optional[float] = None
    sma_30: Optional[float] = None
    sma_50: Optional[float] = None
    sma_60: Optional[float] = None
    sma_100: Optional[float] = None
    sma_200: Optional[float] = None
    bbi: Optional[float] = None
    ema_6: Optional[float] = None
    ema_9: Optional[float] = None
    ema_12: Optional[float] = None
    ema_20: Optional[float] = None
    ema_26: Optional[float] = None
    ema_50: Optional[float] = None
    ema_100: Optional[float] = None
    ema_200: Optional[float] = None
    adx_14: Optional[float] = None
    dmi_pdi: Optional[float] = None
    dmi_mdi: Optional[float] = None
    dmi_adx: Optional[float] = None
    dmi_adxr: Optional[float] = None
    plus_di: Optional[float] = None
    minus_di: Optional[float] = None
    slope_20: Optional[float] = None
    acceleration: Optional[float] = None
    atr_14: Optional[float] = None
    bb_upper: Optional[float] = None
    bb_middle: Optional[float] = None
    bb_lower: Optional[float] = None
    bb_width_pct: Optional[float] = None
    bb_percent_b: Optional[float] = None
    ichimoku_conversion: Optional[float] = None
    ichimoku_base: Optional[float] = None
    ichimoku_span_a: Optional[float] = None
    ichimoku_span_b: Optional[float] = None
    chandelier_long: Optional[float] = None
    chandelier_short: Optional[float] = None
    supertrend_10_3: Optional[float] = None
    supertrend_direction: Optional[str] = None
    sar: Optional[float] = None
    ao: Optional[float] = None
    obv: Optional[float] = None
    obv_ma_30: Optional[float] = None
    mfi_14: Optional[float] = None
    kvo: Optional[float] = None
    volume_ma_5: Optional[float] = None
    volume_ma_10: Optional[float] = None
    volume_sma_20: Optional[float] = None
    volume_ratio_20: Optional[float] = None
    vr: Optional[float] = None
    vr_ma_6: Optional[float] = None
    roc_12: Optional[float] = None
    roc_ma_6: Optional[float] = None
    roc_10: Optional[float] = None
    roc_20: Optional[float] = None
    dma: Optional[float] = None
    ama: Optional[float] = None
    trix: Optional[float] = None
    trix_ma_9: Optional[float] = None
    emv: Optional[float] = None
    emv_ma: Optional[float] = None
    pvt: Optional[float] = None
    avp: Optional[float] = None
    anchored_vwap: Optional[float] = None
    pivot_point: Optional[float] = None
    support_1: Optional[float] = None
    resistance_1: Optional[float] = None

    model_config = {"from_attributes": True}


class IndicatorsResponse(BaseModel):
    symbol: str
    count: int
    data: list[IndicatorRow]


# ─── indices ─────────────────────────────────────────────────────────────────

class IndexRow(BaseModel):
    """Mirrors public.indices in Supabase."""
    id: Optional[int] = None
    date: Optional[str] = None
    index: Optional[str] = None
    current: Optional[float] = None
    point_change: Optional[float] = None
    pct_change: Optional[float] = None
    turnover: Optional[float] = None

    model_config = {"from_attributes": True}


class IndicesResponse(BaseModel):
    count: int
    data: list[IndexRow]


class LatestIndicesResponse(BaseModel):
    """Latest snapshot — one row per index name."""
    data: list[IndexRow]


class AllLatestQuotesResponse(BaseModel):
    """All symbols' latest quotes from the most recent trading day."""
    date: Optional[str] = None
    count: int
    data: list[HistoricDataRow]
