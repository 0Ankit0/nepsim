"""
Market Analysis App — Core analysis engine.

Computes a multi-factor stock signal (STRONG_BUY → STRONG_SELL)
from pre-computed technical indicators and the latest quote.
"""
from __future__ import annotations

import asyncio
import logging
import math
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from typing import Optional

from src.apps.market.supabase_service import SupabaseMarketService
from src.apps.market.supabase_schemas import HistoricDataRow, IndicatorRow

logger = logging.getLogger(__name__)

_SEMAPHORE_LIMIT = 20


@dataclass
class AnalysisResult:
    symbol: str
    signal: str  # STRONG_BUY | BUY | HOLD | SELL | STRONG_SELL
    overall_score: float
    oscillator_score: float
    trend_score: float
    volume_score: float
    volatility_score: float
    key_signals: list[str] = field(default_factory=list)
    current_price: Optional[float] = None
    entry_price: Optional[float] = None
    target_price: Optional[float] = None
    stop_loss: Optional[float] = None
    risk_reward_ratio: Optional[float] = None
    analysis_date: str = field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))


def _clamp(value: float, lo: float = 0.0, hi: float = 100.0) -> float:
    return max(lo, min(hi, value))


def analyze_stock(
    symbol: str,
    indicator_dict: IndicatorRow,
    quote_dict: HistoricDataRow,
) -> AnalysisResult:
    """
    Run multi-factor scoring on a stock.
    All category scores start at 50, are adjusted by signal rules, then clamped 0–100.
    Final score is a weighted average of oscillator, trend, volume, volatility.
    """
    ind = indicator_dict
    quote = quote_dict

    ltp = quote.ltp or quote.close or 0.0
    key_signals: list[str] = []

    # ── Oscillator Score (weight 0.35) ────────────────────────────────────────
    osc = 50.0

    rsi = ind.rsi_14
    if rsi is not None:
        if rsi < 25:
            osc += 25
            key_signals.append("Strongly oversold")
        elif rsi < 35:
            osc += 15
            key_signals.append("Oversold buy")
        elif rsi < 45:
            osc += 5
        elif rsi > 75:
            osc -= 25
            key_signals.append("Strongly overbought")
        elif rsi > 65:
            osc -= 15
            key_signals.append("Overbought sell")
        elif rsi > 55:
            osc -= 5

    k, d = ind.stoch_k, ind.stoch_d
    if k is not None and d is not None:
        if k < 20 and d < 20:
            osc += 15
            key_signals.append("Stoch oversold")
        elif k > 80 and d > 80:
            osc -= 15
            key_signals.append("Stoch overbought")
        elif k > d and k < 50:
            osc += 5
            key_signals.append("Bullish crossover below midline")
        elif k < d and k > 50:
            osc -= 5
            key_signals.append("Bearish crossover above midline")

    cci = ind.cci_20
    if cci is not None:
        if cci < -150:
            osc += 15
        elif cci < -100:
            osc += 10
        elif cci > 150:
            osc -= 15
        elif cci > 100:
            osc -= 10

    wr = ind.williams_r
    if wr is not None:
        if wr < -80:
            osc += 10
            key_signals.append("Oversold")
        elif wr > -20:
            osc -= 10
            key_signals.append("Overbought")

    mfi = ind.mfi_14
    if mfi is not None:
        if mfi < 20:
            osc += 10
            key_signals.append("Oversold w/ volume")
        elif mfi > 80:
            osc -= 10
            key_signals.append("Overbought w/ volume")

    osc = _clamp(osc)

    # ── Trend Score (weight 0.35) ─────────────────────────────────────────────
    trend = 50.0

    macd_hist = ind.macd_hist
    macd_line = ind.macd_line
    macd_signal_val = ind.macd_signal
    if macd_hist is not None and macd_line is not None and macd_signal_val is not None:
        if macd_hist > 0 and macd_line > macd_signal_val:
            trend += 20
            key_signals.append("MACD bullish")
        elif macd_hist < 0 and macd_line < macd_signal_val:
            trend -= 20
            key_signals.append("MACD bearish")
        elif macd_hist > 0:
            trend += 5
        elif macd_hist < 0:
            trend -= 5

    adx = ind.adx_14
    plus_di = ind.plus_di
    minus_di = ind.minus_di
    if adx is not None and plus_di is not None and minus_di is not None:
        if adx < 20:
            key_signals.append("Ranging market")
        elif adx > 30 and plus_di > minus_di:
            trend += 20
            key_signals.append("Strong bullish trend")
        elif adx > 25 and plus_di > minus_di:
            trend += 12
        elif adx > 30 and minus_di > plus_di:
            trend -= 20
            key_signals.append("Strong bearish trend")
        elif adx > 25 and minus_di > plus_di:
            trend -= 12

    sma_50 = ind.sma_50
    sma_200 = ind.sma_200
    if sma_50 is not None and sma_200 is not None:
        if sma_50 > sma_200:
            trend += 15
            key_signals.append("Golden cross")
        else:
            trend -= 15
            key_signals.append("Death cross")
    if sma_50 is not None and ltp:
        if ltp > sma_50:
            trend += 8
            key_signals.append("Above SMA50")
        else:
            trend -= 8
            key_signals.append("Below SMA50")

    span_a = ind.ichimoku_span_a
    span_b = ind.ichimoku_span_b
    if span_a is not None and span_b is not None and ltp:
        cloud_top = max(span_a, span_b)
        cloud_bot = min(span_a, span_b)
        if ltp > cloud_top:
            trend += 15
            key_signals.append("Above cloud bullish")
        elif ltp < cloud_bot:
            trend -= 15
            key_signals.append("Below cloud bearish")
        else:
            key_signals.append("Inside cloud - neutral")

    slope = ind.slope_20
    if slope is not None:
        if slope > 0.5:
            trend += 10
            key_signals.append("Upward trend")
        elif slope < -0.5:
            trend -= 10
            key_signals.append("Downward trend")

    trend = _clamp(trend)

    # ── Volume Score (weight 0.20) ────────────────────────────────────────────
    volume = 50.0

    obv = ind.obv
    diff = quote.diff
    if obv is not None and diff is not None:
        if obv > 0 and diff > 0:
            volume += 20
            key_signals.append("OBV confirms price rise")
        elif obv < 0 and diff < 0:
            volume -= 20
            key_signals.append("OBV confirms decline")
        elif obv > 0 and diff < 0:
            volume += 10
            key_signals.append("OBV bullish divergence")

    kvo = ind.kvo
    if kvo is not None:
        if kvo > 0:
            volume += 10
            key_signals.append("Positive volume flow")
        else:
            volume -= 10
            key_signals.append("Negative volume flow")

    mom = ind.momentum_5
    if mom is not None:
        if mom > 0:
            volume += 10
            key_signals.append("Positive momentum")
        else:
            volume -= 10
            key_signals.append("Negative momentum")

    volume = _clamp(volume)

    # ── Volatility Score (weight 0.10) ────────────────────────────────────────
    volatility = 50.0

    bb_upper = ind.bb_upper
    bb_lower = ind.bb_lower
    if bb_upper is not None and bb_lower is not None and ltp:
        bb_range = bb_upper - bb_lower
        if bb_range > 0:
            bb_pos = (ltp - bb_lower) / bb_range
            if bb_pos < 0.2:
                volatility += 15
                key_signals.append("Near lower BB - potential bounce")
            elif bb_pos > 0.8:
                volatility -= 15
                key_signals.append("Near upper BB - potential reversal")

    chand_long = ind.chandelier_long
    if chand_long is not None and ltp:
        if ltp > chand_long:
            volatility += 10
            key_signals.append("Above chandelier exit - stay long")
        else:
            volatility -= 10
            key_signals.append("Below chandelier exit - caution")

    volatility = _clamp(volatility)

    # ── Overall Score ─────────────────────────────────────────────────────────
    overall = _clamp(osc * 0.35 + trend * 0.35 + volume * 0.20 + volatility * 0.10)

    # ── Signal ────────────────────────────────────────────────────────────────
    if overall >= 72:
        signal = "STRONG_BUY"
    elif overall >= 60:
        signal = "BUY"
    elif overall <= 28:
        signal = "STRONG_SELL"
    elif overall <= 40:
        signal = "SELL"
    else:
        signal = "HOLD"

    # ── Entry / Target / Stop (BUY signals only, using ATR) ──────────────────
    entry_price = target_price = stop_loss = risk_reward_ratio = None
    atr = ind.atr_14
    if signal in ("BUY", "STRONG_BUY") and ltp and atr:
        entry_price = ltp
        target_price = round(ltp + atr * 3, 2)
        stop_loss = round(ltp - atr * 1.5, 2)
        diff_to_stop = ltp - stop_loss
        if diff_to_stop != 0:
            risk_reward_ratio = round((target_price - ltp) / diff_to_stop, 2)

    return AnalysisResult(
        symbol=symbol,
        signal=signal,
        overall_score=round(overall, 2),
        oscillator_score=round(osc, 2),
        trend_score=round(trend, 2),
        volume_score=round(volume, 2),
        volatility_score=round(volatility, 2),
        key_signals=key_signals,
        current_price=ltp or None,
        entry_price=entry_price,
        target_price=target_price,
        stop_loss=stop_loss,
        risk_reward_ratio=risk_reward_ratio,
        analysis_date=datetime.now().strftime("%Y-%m-%d"),
    )


async def analyze_symbol_from_supabase(symbol: str) -> Optional[AnalysisResult]:
    """Fetch latest indicators + quote from Supabase and run analysis engine."""
    return await analyze_symbol_from_supabase_as_of(symbol)


async def analyze_symbol_from_supabase_as_of(
    symbol: str,
    as_of_date: Optional[str] = None,
) -> Optional[AnalysisResult]:
    """Fetch indicators + quote from Supabase up to `as_of_date` and run analysis."""
    try:
        indicators, quote = await asyncio.gather(
            SupabaseMarketService.get_latest_indicators(symbol, as_of_date=as_of_date),
            SupabaseMarketService.get_latest_quote(symbol, as_of_date=as_of_date),
        )
        if not indicators or not quote:
            return None

        result = analyze_stock(symbol, indicators, quote)
        result.analysis_date = indicators.date or quote.date or datetime.now().strftime("%Y-%m-%d")
        return result
    except Exception as exc:
        logger.error(
            "analyze_symbol_from_supabase_as_of(%s, %s) error: %s",
            symbol,
            as_of_date,
            exc,
        )
        return None


async def get_top_stocks(
    limit: int = 20,
    signal_filter: Optional[str] = None,
    as_of_date: Optional[str] = None,
) -> list[AnalysisResult]:
    """
    Analyze all NEPSE symbols in parallel (semaphore=20), optionally filter
    by signal, sort by overall_score descending, and return the top `limit`.
    """
    symbols = await SupabaseMarketService.list_symbols()
    if not symbols:
        return []

    semaphore = asyncio.Semaphore(_SEMAPHORE_LIMIT)

    async def _analyze_with_sem(sym: str) -> Optional[AnalysisResult]:
        async with semaphore:
            return await analyze_symbol_from_supabase_as_of(sym, as_of_date=as_of_date)

    results_raw = await asyncio.gather(*[_analyze_with_sem(s) for s in symbols])
    results: list[AnalysisResult] = [r for r in results_raw if r is not None]

    if signal_filter:
        results = [r for r in results if r.signal == signal_filter.upper()]

    results.sort(key=lambda r: r.overall_score, reverse=True)
    return results[:limit]


# ─── 360 View ────────────────────────────────────────────────────────────────

from src.apps.market.supabase_schemas import IndicatorRow, HistoricDataRow
from .schemas import (
    IndicatorSignalSchema,
    PerformanceMetricsSchema,
    SimilarPeriodSchema,
    TrendAnalysisSchema,
    PricePoint,
    Stock360Schema,
)


def _ind_signal(name: str, value: Optional[float], signal: str, interp: str) -> IndicatorSignalSchema:
    return IndicatorSignalSchema(name=name, value=round(value, 2) if value is not None else None, signal=signal, interpretation=interp)


def _build_indicator_signals(ind: IndicatorRow, ltp: float) -> list[IndicatorSignalSchema]:
    signals: list[IndicatorSignalSchema] = []

    # RSI
    rsi = ind.rsi_14
    if rsi is not None:
        if rsi < 30:
            sig, interp = "BULLISH", f"RSI {rsi:.1f} — oversold, potential reversal upward"
        elif rsi > 70:
            sig, interp = "BEARISH", f"RSI {rsi:.1f} — overbought, watch for pullback"
        elif rsi < 45:
            sig, interp = "NEUTRAL", f"RSI {rsi:.1f} — slightly below midline, mild weakness"
        elif rsi > 55:
            sig, interp = "NEUTRAL", f"RSI {rsi:.1f} — slightly above midline, mild strength"
        else:
            sig, interp = "NEUTRAL", f"RSI {rsi:.1f} — neutral zone"
        signals.append(_ind_signal("RSI (14)", rsi, sig, interp))

    # MACD
    macd_l, macd_s, macd_h = ind.macd_line, ind.macd_signal, ind.macd_hist
    if all(v is not None for v in (macd_l, macd_s, macd_h)):
        if macd_h > 0 and macd_l > macd_s:  # type: ignore[operator]
            sig, interp = "BULLISH", f"MACD histogram {macd_h:.2f} — bullish momentum above signal line"
        elif macd_h < 0 and macd_l < macd_s:  # type: ignore[operator]
            sig, interp = "BEARISH", f"MACD histogram {macd_h:.2f} — bearish momentum below signal line"
        else:
            sig, interp = "NEUTRAL", f"MACD histogram {macd_h:.2f} — mixed/crossover zone"
        signals.append(_ind_signal("MACD", macd_h, sig, interp))

    # Stochastic
    k, d = ind.stoch_k, ind.stoch_d
    if k is not None and d is not None:
        if k < 20 and d < 20:
            sig, interp = "BULLISH", f"Stoch K={k:.1f} D={d:.1f} — oversold, watch for bullish crossover"
        elif k > 80 and d > 80:
            sig, interp = "BEARISH", f"Stoch K={k:.1f} D={d:.1f} — overbought, watch for bearish crossover"
        elif k > d:
            sig, interp = "BULLISH", f"Stoch K={k:.1f} > D={d:.1f} — bullish crossover"
        else:
            sig, interp = "BEARISH", f"Stoch K={k:.1f} < D={d:.1f} — bearish crossover"
        signals.append(_ind_signal("Stochastic", k, sig, interp))

    # ADX
    adx, pdi, mdi = ind.adx_14, ind.plus_di, ind.minus_di
    if adx is not None:
        if adx < 20:
            sig, interp = "NEUTRAL", f"ADX {adx:.1f} — weak/ranging market, no clear trend"
        elif pdi is not None and mdi is not None:
            if adx > 25 and pdi > mdi:
                sig, interp = "BULLISH", f"ADX {adx:.1f} with +DI {pdi:.1f} > -DI {mdi:.1f} — strong uptrend"
            elif adx > 25 and mdi > pdi:
                sig, interp = "BEARISH", f"ADX {adx:.1f} with -DI {mdi:.1f} > +DI {pdi:.1f} — strong downtrend"
            else:
                sig, interp = "NEUTRAL", f"ADX {adx:.1f} — moderate trend, DI mixed"
        else:
            sig, interp = "NEUTRAL", f"ADX {adx:.1f} — moderate strength"
        signals.append(_ind_signal("ADX (14)", adx, sig, interp))

    # Bollinger Bands
    bb_upper, bb_lower = ind.bb_upper, ind.bb_lower
    if bb_upper is not None and bb_lower is not None and ltp:
        bb_mid = (bb_upper + bb_lower) / 2
        bb_width_pct = (bb_upper - bb_lower) / bb_mid * 100 if bb_mid else 0
        if ltp > bb_upper:
            sig, interp = "BEARISH", f"Price {ltp:.2f} above upper BB {bb_upper:.2f} — overbought / breakout watch"
        elif ltp < bb_lower:
            sig, interp = "BULLISH", f"Price {ltp:.2f} below lower BB {bb_lower:.2f} — oversold / bounce watch"
        elif ltp > bb_mid:
            sig, interp = "BULLISH", f"Price in upper Bollinger half, bandwidth {bb_width_pct:.1f}%"
        else:
            sig, interp = "BEARISH", f"Price in lower Bollinger half, bandwidth {bb_width_pct:.1f}%"
        signals.append(_ind_signal("Bollinger Bands", ltp, sig, interp))

    # CCI
    cci = ind.cci_20
    if cci is not None:
        if cci < -100:
            sig, interp = "BULLISH", f"CCI {cci:.1f} — deeply oversold territory"
        elif cci > 100:
            sig, interp = "BEARISH", f"CCI {cci:.1f} — deeply overbought territory"
        else:
            sig, interp = "NEUTRAL", f"CCI {cci:.1f} — within normal range"
        signals.append(_ind_signal("CCI (20)", cci, sig, interp))

    # Williams %R
    wr = ind.williams_r
    if wr is not None:
        if wr < -80:
            sig, interp = "BULLISH", f"Williams %R {wr:.1f} — oversold"
        elif wr > -20:
            sig, interp = "BEARISH", f"Williams %R {wr:.1f} — overbought"
        else:
            sig, interp = "NEUTRAL", f"Williams %R {wr:.1f} — neutral"
        signals.append(_ind_signal("Williams %R", wr, sig, interp))

    # MFI
    mfi = ind.mfi_14
    if mfi is not None:
        if mfi < 20:
            sig, interp = "BULLISH", f"MFI {mfi:.1f} — oversold with volume confirmation"
        elif mfi > 80:
            sig, interp = "BEARISH", f"MFI {mfi:.1f} — overbought with volume confirmation"
        else:
            sig, interp = "NEUTRAL", f"MFI {mfi:.1f} — normal money flow"
        signals.append(_ind_signal("MFI (14)", mfi, sig, interp))

    # SMA alignment
    sma5, sma20, sma50, sma200 = ind.sma_5, ind.sma_20, ind.sma_50, ind.sma_200
    if sma50 is not None and sma200 is not None:
        if sma50 > sma200:
            sig, interp = "BULLISH", f"Golden Cross: SMA50 ({sma50:.2f}) > SMA200 ({sma200:.2f})"
        else:
            sig, interp = "BEARISH", f"Death Cross: SMA50 ({sma50:.2f}) < SMA200 ({sma200:.2f})"
        signals.append(_ind_signal("SMA Cross (50/200)", sma50, sig, interp))

    # Ichimoku
    ichi_conv, ichi_base = ind.ichimoku_conversion, ind.ichimoku_base
    span_a, span_b = ind.ichimoku_span_a, ind.ichimoku_span_b
    if all(v is not None for v in (ichi_conv, ichi_base, span_a, span_b)) and ltp:
        cloud_top = max(span_a, span_b)  # type: ignore[type-var]
        cloud_bot = min(span_a, span_b)  # type: ignore[type-var]
        if ltp > cloud_top and ichi_conv > ichi_base:  # type: ignore[operator]
            sig, interp = "BULLISH", "Price above Ichimoku cloud, bullish TK cross"
        elif ltp < cloud_bot and ichi_conv < ichi_base:  # type: ignore[operator]
            sig, interp = "BEARISH", "Price below Ichimoku cloud, bearish TK cross"
        elif ltp > cloud_top:
            sig, interp = "BULLISH", "Price above Ichimoku cloud"
        elif ltp < cloud_bot:
            sig, interp = "BEARISH", "Price below Ichimoku cloud"
        else:
            sig, interp = "NEUTRAL", "Price inside Ichimoku cloud — indecision zone"
        signals.append(_ind_signal("Ichimoku", ltp, sig, interp))

    # OBV (directional only)
    obv = ind.obv
    if obv is not None:
        sig = "BULLISH" if obv > 0 else ("BEARISH" if obv < 0 else "NEUTRAL")
        interp = f"OBV {obv:,.0f} — {'accumulation' if obv > 0 else 'distribution'} phase"
        signals.append(_ind_signal("OBV", obv, sig, interp))

    return signals


def _calc_performance(history: list[HistoricDataRow]) -> PerformanceMetricsSchema:
    """Compute return percentages and risk metrics from ordered price history."""
    if len(history) < 2:
        return PerformanceMetricsSchema()

    closes = [(r.date or "", r.ltp or r.close or 0.0) for r in history if (r.ltp or r.close)]
    if not closes:
        return PerformanceMetricsSchema()

    latest_date_str, latest_price = closes[-1]
    latest_date = datetime.strptime(latest_date_str, "%Y-%m-%d") if latest_date_str else datetime.now()

    def price_n_days_ago(n: int) -> Optional[float]:
        target = latest_date - timedelta(days=n)
        # Find the closest date at or before target
        for date_str, price in reversed(closes[:-1]):
            try:
                d = datetime.strptime(date_str, "%Y-%m-%d")
                if d <= target:
                    return price
            except ValueError:
                continue
        return None

    def return_pct(old_price: Optional[float]) -> Optional[float]:
        if old_price and old_price > 0 and latest_price > 0:
            return round((latest_price - old_price) / old_price * 100, 2)
        return None

    # YTD: from start of current year
    ytd_base: Optional[float] = None
    for date_str, price in closes:
        try:
            d = datetime.strptime(date_str, "%Y-%m-%d")
            if d.year == latest_date.year:
                ytd_base = price
                break
        except ValueError:
            continue

    # Volatility: 20-day daily returns annualized
    recent_20 = closes[-21:]
    daily_returns = []
    for i in range(1, len(recent_20)):
        p0, p1 = recent_20[i - 1][1], recent_20[i][1]
        if p0 > 0 and p1 > 0:
            daily_returns.append(math.log(p1 / p0))
    vol_20d: Optional[float] = None
    if len(daily_returns) >= 5:
        mean_r = sum(daily_returns) / len(daily_returns)
        variance = sum((r - mean_r) ** 2 for r in daily_returns) / len(daily_returns)
        vol_20d = round(math.sqrt(variance) * math.sqrt(252) * 100, 2)

    # Max drawdown (entire history)
    peak = closes[0][1]
    max_dd = 0.0
    for _, price in closes:
        if price > peak:
            peak = price
        dd = (peak - price) / peak * 100 if peak > 0 else 0
        if dd > max_dd:
            max_dd = dd

    # Avg volume 20 days
    vols = [r.vol for r in history[-20:] if r.vol is not None and r.vol > 0]
    avg_vol = round(sum(vols) / len(vols)) if vols else None

    return PerformanceMetricsSchema(
        week_1_pct=return_pct(price_n_days_ago(7)),
        month_1_pct=return_pct(price_n_days_ago(30)),
        month_3_pct=return_pct(price_n_days_ago(90)),
        month_6_pct=return_pct(price_n_days_ago(180)),
        year_1_pct=return_pct(price_n_days_ago(365)),
        ytd_pct=return_pct(ytd_base),
        max_drawdown_pct=round(max_dd, 2) if max_dd else None,
        volatility_20d_annualized=vol_20d,
        avg_volume_20d=avg_vol,
    )


def _build_trend_analysis(ind: IndicatorRow, ltp: float, history: list[HistoricDataRow]) -> TrendAnalysisSchema:
    """Derive trend direction, strength, support/resistance from indicators and price history."""
    sma20, sma50, sma200 = ind.sma_20, ind.sma_50, ind.sma_200
    ema200 = ind.ema_200
    adx = ind.adx_14
    pdi, mdi = ind.plus_di, ind.minus_di

    # MA alignment
    bullish_mas = 0
    bearish_mas = 0
    if sma20 and ltp > sma20:
        bullish_mas += 1
    elif sma20:
        bearish_mas += 1
    if sma50 and ltp > sma50:
        bullish_mas += 1
    elif sma50:
        bearish_mas += 1
    if sma200 and ltp > sma200:
        bullish_mas += 1
    elif sma200:
        bearish_mas += 1

    if bullish_mas >= 2:
        ma_alignment = "BULLISH"
    elif bearish_mas >= 2:
        ma_alignment = "BEARISH"
    else:
        ma_alignment = "MIXED"

    # Primary trend
    if adx is not None and adx > 25:
        if pdi and mdi and pdi > mdi:
            primary_trend = "UPTREND"
        elif pdi and mdi and mdi > pdi:
            primary_trend = "DOWNTREND"
        else:
            primary_trend = "SIDEWAYS"
    elif ma_alignment == "BULLISH":
        primary_trend = "UPTREND"
    elif ma_alignment == "BEARISH":
        primary_trend = "DOWNTREND"
    else:
        primary_trend = "SIDEWAYS"

    # Trend strength
    if adx is not None:
        if adx > 35:
            trend_strength = "STRONG"
        elif adx > 20:
            trend_strength = "MODERATE"
        else:
            trend_strength = "WEAK"
    else:
        trend_strength = "MODERATE" if ma_alignment != "MIXED" else "WEAK"

    # Support & resistance from recent 60 price bars
    recent = history[-60:] if len(history) >= 60 else history
    lows = [r.low for r in recent if r.low is not None and r.low > 0]
    highs = [r.high for r in recent if r.high is not None and r.high > 0]
    support = round(min(lows) * 1.005, 2) if lows else None    # slight buffer above absolute low
    resistance = round(max(highs) * 0.995, 2) if highs else None

    # Golden / death cross
    golden = bool(sma50 and sma200 and sma50 > sma200)
    death = bool(sma50 and sma200 and sma50 < sma200)

    # Ichimoku signal
    span_a, span_b = ind.ichimoku_span_a, ind.ichimoku_span_b
    ichi_conv, ichi_base = ind.ichimoku_conversion, ind.ichimoku_base
    ichimoku_signal: Optional[str] = None
    if all(v is not None for v in (span_a, span_b)) and ltp:
        cloud_top = max(span_a, span_b)  # type: ignore[type-var]
        cloud_bot = min(span_a, span_b)  # type: ignore[type-var]
        if ltp > cloud_top:
            ichimoku_signal = "BULLISH"
        elif ltp < cloud_bot:
            ichimoku_signal = "BEARISH"
        else:
            ichimoku_signal = "NEUTRAL"

    # Build summary text
    cross_txt = "Golden Cross (SMA50>SMA200)" if golden else "Death Cross (SMA50<SMA200)" if death else ""
    ichi_txt = f"Ichimoku: {ichimoku_signal}." if ichimoku_signal else ""
    strength_txt = f"{trend_strength.lower()} {primary_trend.lower().replace('_', ' ')}"
    summary = f"{symbol_placeholder_replace(strength_txt)}. MA alignment: {ma_alignment}. {cross_txt} {ichi_txt}".strip(" .")

    return TrendAnalysisSchema(
        primary_trend=primary_trend,
        trend_strength=trend_strength,
        ma_alignment=ma_alignment,
        support_level=support,
        resistance_level=resistance,
        price_vs_sma20=("ABOVE" if sma20 and ltp > sma20 else "BELOW") if sma20 else None,
        price_vs_sma50=("ABOVE" if sma50 and ltp > sma50 else "BELOW") if sma50 else None,
        price_vs_sma200=("ABOVE" if sma200 and ltp > sma200 else "BELOW") if sma200 else None,
        golden_cross=golden,
        death_cross=death,
        ichimoku_signal=ichimoku_signal,
        summary=summary,
    )


def symbol_placeholder_replace(text: str) -> str:
    """Helper to capitalise first char."""
    return text.capitalize() if text else text


def _find_similar_periods(
    history: list[HistoricDataRow],
    ind_history: list[IndicatorRow],
    lookback: int = 20,
    top_n: int = 5,
) -> list[SimilarPeriodSchema]:
    """
    Find historical periods with similar indicator fingerprints to the current state.
    Uses a normalized feature vector of [rsi, macd_hist_norm, adx_norm, stoch_k, cci_norm, mfi].
    Returns top_n matches (minimum 60 trading days apart from each other).
    """
    if len(ind_history) < lookback + 35:
        return []

    # Build date->row maps for quick lookup
    ind_map = {r.date: r for r in ind_history if r.date}
    hist_map = {r.date: r for r in history if r.date}
    dates = sorted(ind_map.keys())

    def _feature(row: IndicatorRow) -> Optional[list[float]]:
        vals = [
            (row.rsi_14 or 50.0) / 100.0,
            max(-1.0, min(1.0, (row.macd_hist or 0.0) / 10.0)),
            (row.adx_14 or 20.0) / 100.0,
            (row.stoch_k or 50.0) / 100.0,
            max(-1.0, min(1.0, (row.cci_20 or 0.0) / 200.0)),
            (row.mfi_14 or 50.0) / 100.0,
            (row.williams_r or -50.0 + 100.0) / 100.0,  # shift to 0-1
        ]
        if all(not math.isfinite(v) for v in vals):
            return None
        return vals

    def _cosine_sim(a: list[float], b: list[float]) -> float:
        dot = sum(x * y for x, y in zip(a, b))
        mag_a = math.sqrt(sum(x * x for x in a))
        mag_b = math.sqrt(sum(x * x for x in b))
        if mag_a == 0 or mag_b == 0:
            return 0.0
        return dot / (mag_a * mag_b)

    # Current fingerprint = average over last `lookback` indicator rows
    current_rows = [ind_map[d] for d in dates[-lookback:] if d in ind_map]
    if not current_rows:
        return []

    current_features_list = [_feature(r) for r in current_rows if _feature(r)]
    if not current_features_list:
        return []

    n_feat = len(current_features_list[0])
    current_fp = [sum(f[i] for f in current_features_list) / len(current_features_list) for i in range(n_feat)]

    # Score each historical window (exclude last 90 days to avoid trivial matches)
    candidate_dates = dates[:-90] if len(dates) > 90 else []
    candidates: list[tuple[str, float]] = []

    for i in range(lookback, len(candidate_dates)):
        window_dates = candidate_dates[i - lookback:i]
        window_rows = [ind_map[d] for d in window_dates if d in ind_map]
        window_features_list = [_feature(r) for r in window_rows if _feature(r)]
        if not window_features_list:
            continue
        fp = [sum(f[j] for f in window_features_list) / len(window_features_list) for j in range(n_feat)]
        sim = _cosine_sim(current_fp, fp)
        candidates.append((candidate_dates[i], sim))

    # Sort by similarity desc, enforce minimum 60-day separation between selected dates
    candidates.sort(key=lambda x: x[1], reverse=True)
    selected: list[SimilarPeriodSchema] = []
    used_dates: list[str] = []

    for end_date_str, sim_score in candidates:
        if len(selected) >= top_n:
            break
        # Check separation from already selected
        too_close = False
        for ud in used_dates:
            try:
                delta = abs((datetime.strptime(end_date_str, "%Y-%m-%d") - datetime.strptime(ud, "%Y-%m-%d")).days)
                if delta < 60:
                    too_close = True
                    break
            except ValueError:
                continue
        if too_close:
            continue

        # Get start date (lookback bars before end_date)
        end_idx = dates.index(end_date_str) if end_date_str in dates else -1
        start_date_str = dates[max(0, end_idx - lookback)] if end_idx >= 0 else end_date_str

        # Calculate forward 30-day return after this pattern
        forward_price: Optional[float] = None
        end_hist = hist_map.get(end_date_str)
        if end_hist:
            base_price = end_hist.ltp or end_hist.close
            if base_price:
                fwd_target = datetime.strptime(end_date_str, "%Y-%m-%d") + timedelta(days=30)
                for d in sorted(dates):
                    try:
                        if datetime.strptime(d, "%Y-%m-%d") >= fwd_target:
                            fwd_hist = hist_map.get(d)
                            if fwd_hist:
                                forward_price = fwd_hist.ltp or fwd_hist.close
                            break
                    except ValueError:
                        continue
                if forward_price and base_price > 0:
                    fwd_ret = round((forward_price - base_price) / base_price * 100, 2)
                else:
                    fwd_ret = None
            else:
                fwd_ret = None
        else:
            fwd_ret = None

        outcome = "BULLISH" if fwd_ret and fwd_ret > 2 else ("BEARISH" if fwd_ret and fwd_ret < -2 else "NEUTRAL")
        desc = (
            f"Similar indicator pattern from {start_date_str} to {end_date_str}. "
            f"Similarity: {sim_score * 100:.0f}%. "
            + (f"Followed by {fwd_ret:+.1f}% in next 30 days." if fwd_ret is not None else "Forward return unavailable.")
        )

        selected.append(SimilarPeriodSchema(
            start_date=start_date_str,
            end_date=end_date_str,
            similarity_score=round(sim_score * 100, 1),
            forward_30d_return_pct=fwd_ret,
            outcome=outcome,
            description=desc,
        ))
        used_dates.append(end_date_str)

    return selected


async def get_stock_360_view(
    symbol: str,
    as_of_date: Optional[str] = None,
) -> Optional[Stock360Schema]:
    """
    Return a comprehensive 360-degree view of a stock:
    - Full price history for chart
    - All indicator signals with interpretations
    - Performance metrics (returns, volatility, drawdown)
    - Trend analysis (MAs, support/resistance, Ichimoku)
    - Similar historical patterns (cosine similarity on indicator fingerprints)
    - Core signal from the existing analysis engine
    """
    try:
        # Fetch all data in parallel
        latest_quote, latest_ind, history, ind_history = await asyncio.gather(
            SupabaseMarketService.get_latest_quote(symbol, as_of_date=as_of_date),
            SupabaseMarketService.get_latest_indicators(symbol, as_of_date=as_of_date),
            SupabaseMarketService.get_historic_data(symbol, end_date=as_of_date, limit=2000),
            SupabaseMarketService.get_indicators(symbol, end_date=as_of_date, limit=2000),
        )

        if not latest_quote or not latest_ind:
            return None

        ltp = latest_quote.ltp or latest_quote.close or 0.0

        # Run existing signal engine
        core = analyze_stock(symbol, latest_ind, latest_quote)

        # Build extended analysis
        indicator_signals = _build_indicator_signals(latest_ind, ltp)
        performance = _calc_performance(history)
        trend = _build_trend_analysis(latest_ind, ltp, history)
        similar = _find_similar_periods(history, ind_history)

        # Price history for chart (all available data)
        price_history = [
            PricePoint(
                date=r.date or "",
                open=r.open,
                high=r.high,
                low=r.low,
                close=r.close,
                ltp=r.ltp,
                vol=r.vol,
                vwap=r.vwap,
                turnover=r.turnover,
            )
            for r in history
            if r.date
        ]

        return Stock360Schema(
            symbol=symbol,
            analysis_date=latest_ind.date or latest_quote.date or datetime.now().strftime("%Y-%m-%d"),
            current_price=ltp or None,
            open_price=latest_quote.open,
            high_price=latest_quote.high,
            low_price=latest_quote.low,
            volume=latest_quote.vol,
            turnover=latest_quote.turnover,
            vwap=latest_quote.vwap,
            week_52_high=latest_quote.weeks_52_high,
            week_52_low=latest_quote.weeks_52_low,
            change_pct=latest_quote.diff_pct,
            prev_close=latest_quote.prev_close,
            signal=core.signal,
            overall_score=core.overall_score,
            oscillator_score=core.oscillator_score,
            trend_score=core.trend_score,
            volume_score=core.volume_score,
            volatility_score=core.volatility_score,
            key_signals=core.key_signals,
            entry_price=core.entry_price,
            target_price=core.target_price,
            stop_loss=core.stop_loss,
            risk_reward_ratio=core.risk_reward_ratio,
            indicator_signals=indicator_signals,
            performance=performance,
            trend_analysis=trend,
            similar_periods=similar,
            price_history=price_history,
        )
    except Exception as exc:
        logger.error("get_stock_360_view(%s) error: %s", symbol, exc)
        return None
