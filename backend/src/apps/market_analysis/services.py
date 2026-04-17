"""
Market Analysis App — Core analysis engine.

Builds detailed stock analysis from OHLCV history using computed technical
indicators and optional Gemini commentary.
"""
from __future__ import annotations

import asyncio
import logging
import math
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from typing import Optional

from src.apps.core.config import settings
from src.apps.market.supabase_schemas import HistoricDataRow, IndicatorRow
from src.apps.market.supabase_service import SupabaseMarketService
from src.apps.market.technical_analysis import compute_indicator_history

from .schemas import (
    IndicatorSignalSchema,
    PerformanceMetricsSchema,
    PricePoint,
    SimilarPeriodSchema,
    Stock360Schema,
    TrendAnalysisSchema,
)

logger = logging.getLogger(__name__)

_SEMAPHORE_LIMIT = 12
_ANALYSIS_HISTORY_LIMIT = 400
_STOCK_360_HISTORY_LIMIT = 2000

_AI_SYSTEM_PROMPT = """You are an expert NEPSE technical analyst.
Use only the supplied market data and indicators. Be balanced and specific.
State what supports the current bias, what weakens it, and the main risk.
Do not guarantee outcomes or give absolute advice. Keep the response concise,
educational, and grounded in the supplied technical data."""


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


def _price(row: HistoricDataRow) -> float:
    return row.ltp or row.close or 0.0


def _latest(history: list[HistoricDataRow]) -> Optional[HistoricDataRow]:
    return history[-1] if history else None


async def _load_symbol_history(
    symbol: str,
    as_of_date: Optional[str],
    limit: int,
) -> list[HistoricDataRow]:
    return await SupabaseMarketService.get_historic_data(
        symbol.upper(),
        end_date=as_of_date,
        limit=limit,
    )


async def _load_analysis_inputs(
    symbol: str,
    as_of_date: Optional[str],
    limit: int,
) -> tuple[Optional[HistoricDataRow], list[HistoricDataRow], list[IndicatorRow], Optional[IndicatorRow]]:
    history = await _load_symbol_history(symbol, as_of_date=as_of_date, limit=limit)
    latest_quote = _latest(history)
    indicator_history = compute_indicator_history(history)
    latest_indicator = indicator_history[-1] if indicator_history else None
    return latest_quote, history, indicator_history, latest_indicator


def analyze_stock(
    symbol: str,
    indicator_dict: IndicatorRow,
    quote_dict: HistoricDataRow,
) -> AnalysisResult:
    """Run multi-factor scoring on a stock using computed indicator data."""
    ind = indicator_dict
    quote = quote_dict
    ltp = _price(quote)
    diff_pct = quote.diff_pct or 0.0
    key_signals: list[str] = []

    def add_signal(message: str) -> None:
        if message not in key_signals:
            key_signals.append(message)

    osc = 50.0
    if ind.rsi_14 is not None:
        if ind.rsi_14 < 30:
            osc += 18
            add_signal(f"RSI {ind.rsi_14:.1f} is oversold")
        elif ind.rsi_14 < 40:
            osc += 8
        elif ind.rsi_14 > 70:
            osc -= 18
            add_signal(f"RSI {ind.rsi_14:.1f} is overbought")
        elif ind.rsi_14 > 60:
            osc -= 8

    if ind.stoch_k is not None and ind.stoch_d is not None:
        if ind.stoch_k < 20 and ind.stoch_d < 20:
            osc += 10
            add_signal("Stochastic is in an oversold zone")
        elif ind.stoch_k > 80 and ind.stoch_d > 80:
            osc -= 10
            add_signal("Stochastic is in an overbought zone")
        if ind.stoch_k > ind.stoch_d and ind.stoch_k < 50:
            osc += 7
            add_signal("Stochastic bullish crossover")
        elif ind.stoch_k < ind.stoch_d and ind.stoch_k > 50:
            osc -= 7
            add_signal("Stochastic bearish crossover")

    if ind.cci_20 is not None:
        if ind.cci_20 < -100:
            osc += 8
            add_signal("CCI is deeply negative")
        elif ind.cci_20 > 100:
            osc -= 8
            add_signal("CCI is stretched higher")

    if ind.williams_r is not None:
        if ind.williams_r < -80:
            osc += 6
        elif ind.williams_r > -20:
            osc -= 6

    if ind.mfi_14 is not None:
        if ind.mfi_14 < 20:
            osc += 7
            add_signal("Money flow is oversold")
        elif ind.mfi_14 > 80:
            osc -= 7
            add_signal("Money flow is overbought")

    if ind.roc_10 is not None:
        if ind.roc_10 > 5:
            osc += 4
        elif ind.roc_10 < -5:
            osc -= 4

    osc = _clamp(osc)

    trend = 50.0
    if ind.macd_line is not None and ind.macd_signal is not None and ind.macd_hist is not None:
        if ind.macd_line > ind.macd_signal and ind.macd_hist > 0:
            trend += 16
            add_signal("MACD is above signal with positive histogram")
        elif ind.macd_line < ind.macd_signal and ind.macd_hist < 0:
            trend -= 16
            add_signal("MACD is below signal with negative histogram")
        elif ind.macd_hist > 0:
            trend += 6
        elif ind.macd_hist < 0:
            trend -= 6

    if ind.adx_14 is not None and ind.plus_di is not None and ind.minus_di is not None:
        if ind.adx_14 > 25 and ind.plus_di > ind.minus_di:
            trend += 14
            add_signal("ADX confirms bullish trend strength")
        elif ind.adx_14 > 25 and ind.minus_di > ind.plus_di:
            trend -= 14
            add_signal("ADX confirms bearish trend strength")
        elif ind.adx_14 < 18:
            add_signal("Trend strength is weak")

    if all(value is not None for value in (ind.ema_20, ind.ema_50, ind.sma_200)) and ltp:
        if ltp > ind.ema_20 > ind.ema_50 > ind.sma_200:  # type: ignore[operator]
            trend += 18
            add_signal("Price is stacked above key moving averages")
        elif ltp < ind.ema_20 < ind.ema_50 < ind.sma_200:  # type: ignore[operator]
            trend -= 18
            add_signal("Price is stacked below key moving averages")

    if ind.sma_50 is not None and ind.sma_200 is not None:
        if ind.sma_50 > ind.sma_200:
            trend += 8
            add_signal("SMA 50 is above SMA 200")
        else:
            trend -= 8
            add_signal("SMA 50 is below SMA 200")

    if ind.supertrend_direction == "BULLISH":
        trend += 10
        add_signal("Supertrend remains bullish")
    elif ind.supertrend_direction == "BEARISH":
        trend -= 10
        add_signal("Supertrend remains bearish")

    if ind.ichimoku_span_a is not None and ind.ichimoku_span_b is not None and ltp:
        cloud_top = max(ind.ichimoku_span_a, ind.ichimoku_span_b)
        cloud_bottom = min(ind.ichimoku_span_a, ind.ichimoku_span_b)
        if ltp > cloud_top:
            trend += 10
            add_signal("Price is above the Ichimoku cloud")
        elif ltp < cloud_bottom:
            trend -= 10
            add_signal("Price is below the Ichimoku cloud")

    if ind.slope_20 is not None:
        if ind.slope_20 > 0.3:
            trend += 6
        elif ind.slope_20 < -0.3:
            trend -= 6

    trend = _clamp(trend)

    volume = 50.0
    if ind.volume_ratio_20 is not None:
        if ind.volume_ratio_20 >= 1.5 and diff_pct > 0:
            volume += 14
            add_signal("Price rise is backed by strong relative volume")
        elif ind.volume_ratio_20 >= 1.2:
            volume += 8
        elif ind.volume_ratio_20 < 0.8 and diff_pct < 0:
            volume -= 8

    if ind.anchored_vwap is not None and ltp:
        if ltp > ind.anchored_vwap:
            volume += 6
            add_signal("Price is trading above anchored VWAP")
        elif ltp < ind.anchored_vwap:
            volume -= 6
            add_signal("Price is trading below anchored VWAP")

    if ind.obv is not None:
        if ind.obv > 0:
            volume += 4
        elif ind.obv < 0:
            volume -= 4

    if ind.mfi_14 is not None:
        if 50 <= ind.mfi_14 <= 80:
            volume += 4
        elif 20 <= ind.mfi_14 < 50:
            volume -= 2

    volume = _clamp(volume)

    volatility = 50.0
    if ind.bb_percent_b is not None:
        if ind.bb_percent_b < 20:
            volatility += 10
            add_signal("Price is near the lower Bollinger band")
        elif ind.bb_percent_b > 80:
            volatility -= 10
            add_signal("Price is near the upper Bollinger band")

    atr_pct = (ind.atr_14 / ltp * 100) if ind.atr_14 and ltp else None
    if atr_pct is not None:
        if 2 <= atr_pct <= 6:
            volatility += 6
        elif atr_pct > 10:
            volatility -= 8
            add_signal("ATR is elevated versus price")

    if ind.chandelier_long is not None and ltp:
        if ltp > ind.chandelier_long:
            volatility += 6
        else:
            volatility -= 6

    if ind.supertrend_direction == "BULLISH":
        volatility += 4
    elif ind.supertrend_direction == "BEARISH":
        volatility -= 4

    volatility = _clamp(volatility)

    overall = _clamp(osc * 0.30 + trend * 0.40 + volume * 0.18 + volatility * 0.12)
    if overall >= 76:
        signal = "STRONG_BUY"
    elif overall >= 62:
        signal = "BUY"
    elif overall <= 24:
        signal = "STRONG_SELL"
    elif overall <= 38:
        signal = "SELL"
    else:
        signal = "HOLD"

    entry_price = target_price = stop_loss = risk_reward_ratio = None
    if signal in {"BUY", "STRONG_BUY"} and ltp and ind.atr_14:
        entry_price = round(ltp, 2)
        target_price = round(ltp + ind.atr_14 * 2.5, 2)
        stop_loss = round(ltp - ind.atr_14 * 1.25, 2)
        if entry_price > stop_loss:
            risk_reward_ratio = round((target_price - entry_price) / (entry_price - stop_loss), 2)
    elif signal in {"SELL", "STRONG_SELL"} and ltp and ind.atr_14:
        entry_price = round(ltp, 2)
        target_price = round(ltp - ind.atr_14 * 2.5, 2)
        stop_loss = round(ltp + ind.atr_14 * 1.25, 2)
        if stop_loss > entry_price:
            risk_reward_ratio = round((entry_price - target_price) / (stop_loss - entry_price), 2)

    return AnalysisResult(
        symbol=symbol,
        signal=signal,
        overall_score=round(overall, 2),
        oscillator_score=round(osc, 2),
        trend_score=round(trend, 2),
        volume_score=round(volume, 2),
        volatility_score=round(volatility, 2),
        key_signals=key_signals[:10],
        current_price=ltp or None,
        entry_price=entry_price,
        target_price=target_price,
        stop_loss=stop_loss,
        risk_reward_ratio=risk_reward_ratio,
        analysis_date=quote.date or datetime.now().strftime("%Y-%m-%d"),
    )


async def analyze_symbol_from_supabase(symbol: str) -> Optional[AnalysisResult]:
    """Fetch recent OHLCV history and compute a detailed analysis."""
    return await analyze_symbol_from_supabase_as_of(symbol)


async def analyze_symbol_from_supabase_as_of(
    symbol: str,
    as_of_date: Optional[str] = None,
) -> Optional[AnalysisResult]:
    try:
        latest_quote, _, _, latest_indicator = await _load_analysis_inputs(
            symbol,
            as_of_date=as_of_date,
            limit=_ANALYSIS_HISTORY_LIMIT,
        )
        if not latest_quote or not latest_indicator:
            return None

        result = analyze_stock(symbol.upper(), latest_indicator, latest_quote)
        result.analysis_date = latest_indicator.date or latest_quote.date or datetime.now().strftime("%Y-%m-%d")
        return result
    except Exception as exc:
        logger.error("analyze_symbol_from_supabase_as_of(%s, %s) error: %s", symbol, as_of_date, exc)
        return None


async def get_top_stocks(
    limit: int = 20,
    signal_filter: Optional[str] = None,
    as_of_date: Optional[str] = None,
) -> list[AnalysisResult]:
    """Analyze all symbols in parallel and return the top ranked results."""
    symbols = await SupabaseMarketService.list_symbols()
    if not symbols:
        return []

    semaphore = asyncio.Semaphore(_SEMAPHORE_LIMIT)

    async def _analyze_with_sem(sym: str) -> Optional[AnalysisResult]:
        async with semaphore:
            return await analyze_symbol_from_supabase_as_of(sym, as_of_date=as_of_date)

    results_raw = await asyncio.gather(*[_analyze_with_sem(symbol) for symbol in symbols])
    results = [result for result in results_raw if result is not None]

    if signal_filter:
        results = [result for result in results if result.signal == signal_filter.upper()]

    results.sort(key=lambda result: result.overall_score, reverse=True)
    return results[:limit]


def _ind_signal(name: str, value: Optional[float], signal: str, interpretation: str) -> IndicatorSignalSchema:
    return IndicatorSignalSchema(
        name=name,
        value=round(value, 2) if value is not None else None,
        signal=signal,
        interpretation=interpretation,
    )


def _build_indicator_signals(ind: IndicatorRow, ltp: float) -> list[IndicatorSignalSchema]:
    signals: list[IndicatorSignalSchema] = []

    if ind.rsi_14 is not None:
        if ind.rsi_14 < 30:
            sig, interp = "BULLISH", f"RSI {ind.rsi_14:.1f} is oversold on the default 14-period setting."
        elif ind.rsi_14 > 70:
            sig, interp = "BEARISH", f"RSI {ind.rsi_14:.1f} is overbought on the default 14-period setting."
        else:
            sig, interp = "NEUTRAL", f"RSI {ind.rsi_14:.1f} is in a neutral momentum range."
        signals.append(_ind_signal("RSI (14)", ind.rsi_14, sig, interp))

    if all(value is not None for value in (ind.macd_line, ind.macd_signal, ind.macd_hist)):
        if ind.macd_line > ind.macd_signal and ind.macd_hist > 0:  # type: ignore[operator]
            sig, interp = "BULLISH", f"MACD ({ind.macd_line:.2f}) is above its signal ({ind.macd_signal:.2f}) with a positive histogram."
        elif ind.macd_line < ind.macd_signal and ind.macd_hist < 0:  # type: ignore[operator]
            sig, interp = "BEARISH", f"MACD ({ind.macd_line:.2f}) is below its signal ({ind.macd_signal:.2f}) with a negative histogram."
        else:
            sig, interp = "NEUTRAL", f"MACD histogram {ind.macd_hist:.2f} is near a transition zone."
        signals.append(_ind_signal("MACD (12,26,9)", ind.macd_hist, sig, interp))

    if ind.stoch_k is not None and ind.stoch_d is not None:
        if ind.stoch_k < 20 and ind.stoch_d < 20:
            sig, interp = "BULLISH", f"Stochastic K/D ({ind.stoch_k:.1f}/{ind.stoch_d:.1f}) is in oversold territory."
        elif ind.stoch_k > 80 and ind.stoch_d > 80:
            sig, interp = "BEARISH", f"Stochastic K/D ({ind.stoch_k:.1f}/{ind.stoch_d:.1f}) is in overbought territory."
        elif ind.stoch_k > ind.stoch_d:
            sig, interp = "BULLISH", f"Stochastic K ({ind.stoch_k:.1f}) is above D ({ind.stoch_d:.1f})."
        else:
            sig, interp = "BEARISH", f"Stochastic K ({ind.stoch_k:.1f}) is below D ({ind.stoch_d:.1f})."
        signals.append(_ind_signal("Stochastic (14,3,3)", ind.stoch_k, sig, interp))

    if ind.adx_14 is not None:
        if ind.plus_di is not None and ind.minus_di is not None and ind.adx_14 > 25:
            if ind.plus_di > ind.minus_di:
                sig, interp = "BULLISH", f"ADX {ind.adx_14:.1f} confirms a strong uptrend with +DI above -DI."
            elif ind.minus_di > ind.plus_di:
                sig, interp = "BEARISH", f"ADX {ind.adx_14:.1f} confirms a strong downtrend with -DI above +DI."
            else:
                sig, interp = "NEUTRAL", f"ADX {ind.adx_14:.1f} shows trend strength but DI lines are mixed."
        elif ind.adx_14 < 18:
            sig, interp = "NEUTRAL", f"ADX {ind.adx_14:.1f} suggests a weak or ranging market."
        else:
            sig, interp = "NEUTRAL", f"ADX {ind.adx_14:.1f} suggests a moderate trend."
        signals.append(_ind_signal("ADX / DMI", ind.adx_14, sig, interp))

    if ind.bb_percent_b is not None and ind.bb_width_pct is not None:
        if ind.bb_percent_b < 20:
            sig, interp = "BULLISH", f"Percent B is {ind.bb_percent_b:.1f}, placing price near the lower Bollinger band."
        elif ind.bb_percent_b > 80:
            sig, interp = "BEARISH", f"Percent B is {ind.bb_percent_b:.1f}, placing price near the upper Bollinger band."
        else:
            sig, interp = "NEUTRAL", f"Price is inside the Bollinger envelope with bandwidth {ind.bb_width_pct:.1f}%."
        signals.append(_ind_signal("Bollinger Bands (20,2)", ind.bb_percent_b, sig, interp))

    if ind.cci_20 is not None:
        if ind.cci_20 < -100:
            sig, interp = "BULLISH", f"CCI {ind.cci_20:.1f} indicates a deeply oversold reading."
        elif ind.cci_20 > 100:
            sig, interp = "BEARISH", f"CCI {ind.cci_20:.1f} indicates a stretched upside reading."
        else:
            sig, interp = "NEUTRAL", f"CCI {ind.cci_20:.1f} is broadly neutral."
        signals.append(_ind_signal("CCI (20)", ind.cci_20, sig, interp))

    if ind.williams_r is not None:
        if ind.williams_r < -80:
            sig, interp = "BULLISH", f"Williams %R {ind.williams_r:.1f} is in oversold territory."
        elif ind.williams_r > -20:
            sig, interp = "BEARISH", f"Williams %R {ind.williams_r:.1f} is in overbought territory."
        else:
            sig, interp = "NEUTRAL", f"Williams %R {ind.williams_r:.1f} is neutral."
        signals.append(_ind_signal("Williams %R (14)", ind.williams_r, sig, interp))

    if ind.mfi_14 is not None:
        if ind.mfi_14 < 20:
            sig, interp = "BULLISH", f"MFI {ind.mfi_14:.1f} shows oversold money flow."
        elif ind.mfi_14 > 80:
            sig, interp = "BEARISH", f"MFI {ind.mfi_14:.1f} shows overbought money flow."
        else:
            sig, interp = "NEUTRAL", f"MFI {ind.mfi_14:.1f} is balanced."
        signals.append(_ind_signal("MFI (14)", ind.mfi_14, sig, interp))

    if ind.supertrend_10_3 is not None and ind.supertrend_direction:
        if ind.supertrend_direction == "BULLISH":
            sig, interp = "BULLISH", f"Supertrend (10,3) is bullish with support near {ind.supertrend_10_3:.2f}."
        else:
            sig, interp = "BEARISH", f"Supertrend (10,3) is bearish with resistance near {ind.supertrend_10_3:.2f}."
        signals.append(_ind_signal("Supertrend (10,3)", ind.supertrend_10_3, sig, interp))

    if ind.anchored_vwap is not None and ltp:
        if ltp > ind.anchored_vwap:
            sig, interp = "BULLISH", f"Price {ltp:.2f} is above anchored VWAP {ind.anchored_vwap:.2f}."
        elif ltp < ind.anchored_vwap:
            sig, interp = "BEARISH", f"Price {ltp:.2f} is below anchored VWAP {ind.anchored_vwap:.2f}."
        else:
            sig, interp = "NEUTRAL", "Price is sitting on anchored VWAP."
        signals.append(_ind_signal("Anchored VWAP", ind.anchored_vwap, sig, interp))

    if ind.volume_ratio_20 is not None:
        if ind.volume_ratio_20 >= 1.5:
            sig, interp = "BULLISH", f"Volume is {ind.volume_ratio_20:.2f}x the 20-day average."
        elif ind.volume_ratio_20 < 0.8:
            sig, interp = "BEARISH", f"Volume is only {ind.volume_ratio_20:.2f}x the 20-day average."
        else:
            sig, interp = "NEUTRAL", f"Volume is {ind.volume_ratio_20:.2f}x the 20-day average."
        signals.append(_ind_signal("Relative Volume (20)", ind.volume_ratio_20, sig, interp))

    if ind.roc_10 is not None:
        if ind.roc_10 > 5:
            sig, interp = "BULLISH", f"10-day ROC is {ind.roc_10:.2f}%."
        elif ind.roc_10 < -5:
            sig, interp = "BEARISH", f"10-day ROC is {ind.roc_10:.2f}%."
        else:
            sig, interp = "NEUTRAL", f"10-day ROC is {ind.roc_10:.2f}%."
        signals.append(_ind_signal("ROC (10)", ind.roc_10, sig, interp))

    if all(value is not None for value in (ind.ichimoku_conversion, ind.ichimoku_base, ind.ichimoku_span_a, ind.ichimoku_span_b)) and ltp:
        cloud_top = max(ind.ichimoku_span_a, ind.ichimoku_span_b)  # type: ignore[type-var]
        cloud_bottom = min(ind.ichimoku_span_a, ind.ichimoku_span_b)  # type: ignore[type-var]
        if ltp > cloud_top and ind.ichimoku_conversion > ind.ichimoku_base:  # type: ignore[operator]
            sig, interp = "BULLISH", "Price is above the cloud and the conversion line is above the base line."
        elif ltp < cloud_bottom and ind.ichimoku_conversion < ind.ichimoku_base:  # type: ignore[operator]
            sig, interp = "BEARISH", "Price is below the cloud and the conversion line is below the base line."
        else:
            sig, interp = "NEUTRAL", "Ichimoku components are mixed."
        signals.append(_ind_signal("Ichimoku (9,26,52)", ltp, sig, interp))

    return signals


def _calc_performance(history: list[HistoricDataRow]) -> PerformanceMetricsSchema:
    """Compute return percentages and risk metrics from ordered price history."""
    if len(history) < 2:
        return PerformanceMetricsSchema()

    closes = [(row.date or "", _price(row)) for row in history if _price(row) > 0]
    if len(closes) < 2:
        return PerformanceMetricsSchema()

    latest_date_str, latest_price = closes[-1]
    latest_date = datetime.strptime(latest_date_str, "%Y-%m-%d") if latest_date_str else datetime.now()

    def price_n_days_ago(days: int) -> Optional[float]:
        target = latest_date - timedelta(days=days)
        for date_str, price in reversed(closes[:-1]):
            try:
                if datetime.strptime(date_str, "%Y-%m-%d") <= target:
                    return price
            except ValueError:
                continue
        return None

    def return_pct(old_price: Optional[float]) -> Optional[float]:
        if old_price and old_price > 0 and latest_price > 0:
            return round((latest_price - old_price) / old_price * 100, 2)
        return None

    ytd_base: Optional[float] = None
    for date_str, price in closes:
        try:
            current_date = datetime.strptime(date_str, "%Y-%m-%d")
        except ValueError:
            continue
        if current_date.year == latest_date.year:
            ytd_base = price
            break

    recent_20 = closes[-21:]
    daily_returns: list[float] = []
    for index in range(1, len(recent_20)):
        previous_price = recent_20[index - 1][1]
        current_price = recent_20[index][1]
        if previous_price > 0 and current_price > 0:
            daily_returns.append(math.log(current_price / previous_price))

    vol_20d: Optional[float] = None
    if len(daily_returns) >= 5:
        mean_return = sum(daily_returns) / len(daily_returns)
        variance = sum((value - mean_return) ** 2 for value in daily_returns) / len(daily_returns)
        vol_20d = round(math.sqrt(variance) * math.sqrt(252) * 100, 2)

    peak = closes[0][1]
    max_drawdown = 0.0
    for _, price in closes:
        peak = max(peak, price)
        drawdown = (peak - price) / peak * 100 if peak > 0 else 0.0
        max_drawdown = max(max_drawdown, drawdown)

    volumes = [row.vol for row in history[-20:] if row.vol is not None and row.vol > 0]
    avg_volume = round(sum(volumes) / len(volumes)) if volumes else None

    return PerformanceMetricsSchema(
        week_1_pct=return_pct(price_n_days_ago(7)),
        month_1_pct=return_pct(price_n_days_ago(30)),
        month_3_pct=return_pct(price_n_days_ago(90)),
        month_6_pct=return_pct(price_n_days_ago(180)),
        year_1_pct=return_pct(price_n_days_ago(365)),
        ytd_pct=return_pct(ytd_base),
        max_drawdown_pct=round(max_drawdown, 2) if max_drawdown else None,
        volatility_20d_annualized=vol_20d,
        avg_volume_20d=avg_volume,
    )


def _build_trend_analysis(ind: IndicatorRow, ltp: float, history: list[HistoricDataRow]) -> TrendAnalysisSchema:
    """Derive trend direction, strength, support/resistance from indicators and price history."""
    bullish_mas = 0
    bearish_mas = 0
    for moving_average in (ind.sma_20, ind.sma_50, ind.sma_200):
        if moving_average is None:
            continue
        if ltp > moving_average:
            bullish_mas += 1
        else:
            bearish_mas += 1

    if bullish_mas >= 2:
        ma_alignment = "BULLISH"
    elif bearish_mas >= 2:
        ma_alignment = "BEARISH"
    else:
        ma_alignment = "MIXED"

    if ind.adx_14 is not None and ind.adx_14 > 25 and ind.plus_di is not None and ind.minus_di is not None:
        if ind.plus_di > ind.minus_di:
            primary_trend = "UPTREND"
        elif ind.minus_di > ind.plus_di:
            primary_trend = "DOWNTREND"
        else:
            primary_trend = "SIDEWAYS"
    elif ind.supertrend_direction == "BULLISH" or ma_alignment == "BULLISH":
        primary_trend = "UPTREND"
    elif ind.supertrend_direction == "BEARISH" or ma_alignment == "BEARISH":
        primary_trend = "DOWNTREND"
    else:
        primary_trend = "SIDEWAYS"

    if ind.adx_14 is not None:
        if ind.adx_14 > 35:
            trend_strength = "STRONG"
        elif ind.adx_14 > 20:
            trend_strength = "MODERATE"
        else:
            trend_strength = "WEAK"
    else:
        trend_strength = "MODERATE" if primary_trend != "SIDEWAYS" else "WEAK"

    recent_history = history[-60:] if len(history) >= 60 else history
    lows = [row.low for row in recent_history if row.low is not None and row.low > 0]
    highs = [row.high for row in recent_history if row.high is not None and row.high > 0]
    support = ind.support_1 or (round(min(lows) * 1.005, 2) if lows else None)
    resistance = ind.resistance_1 or (round(max(highs) * 0.995, 2) if highs else None)

    golden_cross = bool(ind.sma_50 and ind.sma_200 and ind.sma_50 > ind.sma_200)
    death_cross = bool(ind.sma_50 and ind.sma_200 and ind.sma_50 < ind.sma_200)

    ichimoku_signal: Optional[str] = None
    if ind.ichimoku_span_a is not None and ind.ichimoku_span_b is not None and ltp:
        cloud_top = max(ind.ichimoku_span_a, ind.ichimoku_span_b)
        cloud_bottom = min(ind.ichimoku_span_a, ind.ichimoku_span_b)
        if ltp > cloud_top:
            ichimoku_signal = "BULLISH"
        elif ltp < cloud_bottom:
            ichimoku_signal = "BEARISH"
        else:
            ichimoku_signal = "NEUTRAL"

    supertrend_note = f" Supertrend is {ind.supertrend_direction.lower()}." if ind.supertrend_direction else ""
    ichimoku_note = f" Ichimoku is {ichimoku_signal.lower()}." if ichimoku_signal else ""
    summary = (
        f"{primary_trend.capitalize()} bias with {trend_strength.lower()} conviction. "
        f"MA alignment is {ma_alignment.lower()}."
        f"{supertrend_note}{ichimoku_note}"
    ).strip()

    return TrendAnalysisSchema(
        primary_trend=primary_trend,
        trend_strength=trend_strength,
        ma_alignment=ma_alignment,
        support_level=support,
        resistance_level=resistance,
        price_vs_sma20=("ABOVE" if ind.sma_20 and ltp > ind.sma_20 else "BELOW") if ind.sma_20 else None,
        price_vs_sma50=("ABOVE" if ind.sma_50 and ltp > ind.sma_50 else "BELOW") if ind.sma_50 else None,
        price_vs_sma200=("ABOVE" if ind.sma_200 and ltp > ind.sma_200 else "BELOW") if ind.sma_200 else None,
        golden_cross=golden_cross,
        death_cross=death_cross,
        ichimoku_signal=ichimoku_signal,
        summary=summary,
    )


def _find_similar_periods(
    history: list[HistoricDataRow],
    indicator_history: list[IndicatorRow],
    lookback: int = 20,
    top_n: int = 5,
) -> list[SimilarPeriodSchema]:
    """Find historical windows with similar indicator fingerprints."""
    if len(indicator_history) < lookback + 35:
        return []

    indicator_map = {row.date: row for row in indicator_history if row.date}
    history_map = {row.date: row for row in history if row.date}
    dates = sorted(indicator_map.keys())

    def feature(row: IndicatorRow) -> Optional[list[float]]:
        values = [
            (row.rsi_14 or 50.0) / 100.0,
            max(-1.0, min(1.0, (row.macd_hist or 0.0) / 10.0)),
            (row.adx_14 or 20.0) / 100.0,
            (row.stoch_k or 50.0) / 100.0,
            max(-1.0, min(1.0, (row.cci_20 or 0.0) / 200.0)),
            (row.mfi_14 or 50.0) / 100.0,
            ((row.williams_r or -50.0) + 100.0) / 100.0,
            max(-1.0, min(1.0, (row.roc_10 or 0.0) / 15.0)),
            1.0 if row.supertrend_direction == "BULLISH" else 0.0 if row.supertrend_direction == "BEARISH" else 0.5,
        ]
        if all(not math.isfinite(value) for value in values):
            return None
        return values

    def cosine_similarity(left: list[float], right: list[float]) -> float:
        dot = sum(a * b for a, b in zip(left, right))
        magnitude_left = math.sqrt(sum(value * value for value in left))
        magnitude_right = math.sqrt(sum(value * value for value in right))
        if magnitude_left == 0 or magnitude_right == 0:
            return 0.0
        return dot / (magnitude_left * magnitude_right)

    current_rows = [indicator_map[date] for date in dates[-lookback:] if date in indicator_map]
    current_features = [values for row in current_rows if (values := feature(row))]
    if not current_features:
        return []

    feature_count = len(current_features[0])
    current_fingerprint = [
        sum(values[index] for values in current_features) / len(current_features)
        for index in range(feature_count)
    ]

    candidate_dates = dates[:-90] if len(dates) > 90 else []
    candidates: list[tuple[str, float]] = []
    for index in range(lookback, len(candidate_dates)):
        window_dates = candidate_dates[index - lookback:index]
        window_features = [values for date in window_dates if (values := feature(indicator_map[date]))]
        if not window_features:
            continue
        window_fingerprint = [
            sum(values[feature_index] for values in window_features) / len(window_features)
            for feature_index in range(feature_count)
        ]
        candidates.append((candidate_dates[index], cosine_similarity(current_fingerprint, window_fingerprint)))

    candidates.sort(key=lambda item: item[1], reverse=True)
    selected: list[SimilarPeriodSchema] = []
    used_dates: list[str] = []

    for end_date_str, similarity_score in candidates:
        if len(selected) >= top_n:
            break

        try:
            end_date = datetime.strptime(end_date_str, "%Y-%m-%d")
        except ValueError:
            continue

        if any(abs((end_date - datetime.strptime(date_str, "%Y-%m-%d")).days) < 60 for date_str in used_dates):
            continue

        end_index = dates.index(end_date_str)
        start_date_str = dates[max(0, end_index - lookback)]

        forward_return: Optional[float] = None
        end_history = history_map.get(end_date_str)
        base_price = _price(end_history) if end_history else 0.0
        if base_price > 0:
            target_date = end_date + timedelta(days=30)
            for date_str in dates[end_index + 1:]:
                try:
                    if datetime.strptime(date_str, "%Y-%m-%d") >= target_date:
                        future_history = history_map.get(date_str)
                        future_price = _price(future_history) if future_history else 0.0
                        if future_price > 0:
                            forward_return = round((future_price - base_price) / base_price * 100, 2)
                        break
                except ValueError:
                    continue

        outcome = "BULLISH" if forward_return and forward_return > 2 else "BEARISH" if forward_return and forward_return < -2 else "NEUTRAL"
        description = (
            f"Similar indicator state from {start_date_str} to {end_date_str}. "
            f"Similarity score {similarity_score * 100:.0f}%."
        )
        if forward_return is not None:
            description += f" It was followed by {forward_return:+.1f}% over the next 30 days."
        else:
            description += " Forward 30-day return was unavailable."

        selected.append(
            SimilarPeriodSchema(
                start_date=start_date_str,
                end_date=end_date_str,
                similarity_score=round(similarity_score * 100, 1),
                forward_30d_return_pct=forward_return,
                outcome=outcome,
                description=description,
            )
        )
        used_dates.append(end_date_str)

    return selected


async def _generate_ai_summary(
    *,
    symbol: str,
    core: AnalysisResult,
    latest_quote: HistoricDataRow,
    latest_indicator: IndicatorRow,
    trend: TrendAnalysisSchema,
    performance: PerformanceMetricsSchema,
    indicator_signals: list[IndicatorSignalSchema],
) -> Optional[str]:
    api_key = settings.GEMINI_API_KEY.strip()
    if not api_key:
        return None

    try:
        from google import genai as google_genai
    except Exception as exc:
        logger.warning("Gemini client import failed for stock analysis: %s", exc)
        return None

    prompt = f"""
Symbol: {symbol}
Analysis date: {core.analysis_date}
Current price: {core.current_price}
Signal: {core.signal}
Overall score: {core.overall_score}
Oscillator score: {core.oscillator_score}
Trend score: {core.trend_score}
Volume score: {core.volume_score}
Volatility score: {core.volatility_score}
Daily change %: {latest_quote.diff_pct}
Trend summary: {trend.summary}
Support: {trend.support_level}
Resistance: {trend.resistance_level}
1M return: {performance.month_1_pct}
3M return: {performance.month_3_pct}
6M return: {performance.month_6_pct}
Max drawdown %: {performance.max_drawdown_pct}
Latest indicators:
- RSI 14: {latest_indicator.rsi_14}
- MACD hist: {latest_indicator.macd_hist}
- ADX 14: {latest_indicator.adx_14}
- MFI 14: {latest_indicator.mfi_14}
- Relative volume 20: {latest_indicator.volume_ratio_20}
- Supertrend direction: {latest_indicator.supertrend_direction}
- Anchored VWAP: {latest_indicator.anchored_vwap}
- Bollinger %B: {latest_indicator.bb_percent_b}
- ROC 10: {latest_indicator.roc_10}
- ATR 14: {latest_indicator.atr_14}
Top technical observations:
{chr(10).join(f"- {signal.name}: {signal.interpretation}" for signal in indicator_signals[:8])}

Write 4-6 sentences in plain English. Mention the main bullish evidence, the main bearish/risk evidence,
how price is positioned versus trend structure, and what a cautious trader should watch next.
"""

    try:
        client = google_genai.Client(api_key=api_key)
        response = await client.aio.models.generate_content(
            model=settings.GEMINI_STOCK_ANALYSIS_MODEL,
            contents=f"{_AI_SYSTEM_PROMPT}\n\n{prompt}",
        )
    except Exception as exc:
        logger.warning("Gemini stock analysis failed for %s: %s", symbol, exc)
        return None

    text = (response.text or "").strip()
    if not text:
        return None
    return " ".join(line.strip() for line in text.splitlines() if line.strip())


async def get_stock_360_view(
    symbol: str,
    as_of_date: Optional[str] = None,
) -> Optional[Stock360Schema]:
    """
    Return a comprehensive 360-degree view of a stock:
    - full price history for charting
    - computed indicator history from TA-Lib
    - performance, trend, and pattern analysis
    - optional Gemini summary
    """
    try:
        latest_quote, history, indicator_history, latest_indicator = await _load_analysis_inputs(
            symbol,
            as_of_date=as_of_date,
            limit=_STOCK_360_HISTORY_LIMIT,
        )
        if not latest_quote or not latest_indicator:
            return None

        ltp = _price(latest_quote)
        core = analyze_stock(symbol.upper(), latest_indicator, latest_quote)
        indicator_signals = _build_indicator_signals(latest_indicator, ltp)
        performance = _calc_performance(history)
        trend = _build_trend_analysis(latest_indicator, ltp, history)
        similar = _find_similar_periods(history, indicator_history)
        ai_summary = await _generate_ai_summary(
            symbol=symbol.upper(),
            core=core,
            latest_quote=latest_quote,
            latest_indicator=latest_indicator,
            trend=trend,
            performance=performance,
            indicator_signals=indicator_signals,
        )

        price_history = [
            PricePoint(
                date=row.date or "",
                open=row.open,
                high=row.high,
                low=row.low,
                close=row.close,
                ltp=row.ltp,
                vol=row.vol,
                vwap=row.vwap,
                turnover=row.turnover,
            )
            for row in history
            if row.date
        ]

        return Stock360Schema(
            symbol=symbol.upper(),
            analysis_date=latest_indicator.date or latest_quote.date or datetime.now().strftime("%Y-%m-%d"),
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
            indicator_history=indicator_history,
            performance=performance,
            trend_analysis=trend,
            similar_periods=similar,
            price_history=price_history,
            ai_summary=ai_summary,
        )
    except Exception as exc:
        logger.error("get_stock_360_view(%s) error: %s", symbol, exc)
        return None
