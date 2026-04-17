"""Technical-analysis helpers computed from OHLCV history."""
from __future__ import annotations

import math
from typing import Optional

import numpy as np
import pandas as pd
import talib

from .supabase_schemas import HistoricDataRow, IndicatorRow

RSI_PERIOD = 14
MACD_FAST = 12
MACD_SLOW = 26
MACD_SIGNAL = 9
STOCH_K = 14
STOCH_SMOOTH = 3
CCI_PERIOD = 20
WILLIAMS_R_PERIOD = 14
MFI_PERIOD = 14
ADX_PERIOD = 14
ATR_PERIOD = 14
BBANDS_PERIOD = 20
BBANDS_STDDEV = 2.0
ICHIMOKU_CONVERSION = 9
ICHIMOKU_BASE = 26
ICHIMOKU_SPAN_B = 52
SUPER_TREND_PERIOD = 10
SUPER_TREND_MULTIPLIER = 3.0
CHANDELIER_PERIOD = 22
CHANDELIER_MULTIPLIER = 3.0
VOLUME_SMA_PERIOD = 20


def _finite_float(value: object, digits: int = 4) -> Optional[float]:
    if value is None:
        return None
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    if not math.isfinite(number):
        return None
    return round(number, digits)


def _rolling_mean(series: pd.Series, period: int) -> pd.Series:
    return series.rolling(period).mean()


def _compute_cn_sma(close: pd.Series, period: int, weight: int) -> pd.Series:
    values = [math.nan] * len(close)
    close_sum = 0.0
    sma_value = math.nan
    for index, current_close in enumerate(close):
        close_sum += float(current_close)
        if index < period - 1:
            continue
        if index == period - 1:
            sma_value = close_sum / period
        else:
            sma_value = (float(current_close) * weight + sma_value * (period - weight + 1)) / (period + 1)
        values[index] = sma_value
    return pd.Series(values)


def _compute_bias(close: pd.Series, period: int) -> pd.Series:
    average = _rolling_mean(close, period)
    return pd.Series(np.where(average.abs() > 0, (close - average) / average * 100.0, np.nan))


def _compute_kdj(high: pd.Series, low: pd.Series, close: pd.Series, period: int, k_period: int, d_period: int) -> tuple[pd.Series, pd.Series, pd.Series]:
    k_values = [math.nan] * len(close)
    d_values = [math.nan] * len(close)
    j_values = [math.nan] * len(close)
    for index in range(len(close)):
        if index < period - 1:
            continue
        window_high = float(high.iloc[index - (period - 1): index + 1].max())
        window_low = float(low.iloc[index - (period - 1): index + 1].min())
        denominator = window_high - window_low
        rsv = (float(close.iloc[index]) - window_low) / (denominator if denominator != 0 else 1.0) * 100.0
        prev_k = k_values[index - 1] if index > 0 and math.isfinite(k_values[index - 1]) else 50.0
        prev_d = d_values[index - 1] if index > 0 and math.isfinite(d_values[index - 1]) else 50.0
        k_value = ((k_period - 1) * prev_k + rsv) / k_period
        d_value = ((d_period - 1) * prev_d + k_value) / d_period
        j_value = 3.0 * k_value - 2.0 * d_value
        k_values[index] = k_value
        d_values[index] = d_value
        j_values[index] = j_value
    return pd.Series(k_values), pd.Series(d_values), pd.Series(j_values)


def _compute_rsi_source(close: pd.Series, periods: tuple[int, ...]) -> dict[int, pd.Series]:
    sums_up = {period: 0.0 for period in periods}
    sums_down = {period: 0.0 for period in periods}
    results = {period: [math.nan] * len(close) for period in periods}
    close_values = close.tolist()

    for index, current_close in enumerate(close_values):
        prev_close = close_values[index - 1] if index > 0 else current_close
        diff = float(current_close) - float(prev_close)
        for period in periods:
            if diff > 0:
                sums_up[period] += diff
            else:
                sums_down[period] += abs(diff)
            if index < period - 1:
                continue
            if sums_down[period] != 0:
                results[period][index] = 100.0 - (100.0 / (1.0 + sums_up[period] / sums_down[period]))
            else:
                results[period][index] = 0.0
            ago_close = float(close_values[index - (period - 1)])
            ago_prev_close = float(close_values[index - period]) if index - period >= 0 else ago_close
            ago_diff = ago_close - ago_prev_close
            if ago_diff > 0:
                sums_up[period] -= ago_diff
            else:
                sums_down[period] -= abs(ago_diff)

    return {period: pd.Series(values) for period, values in results.items()}


def _compute_dmi_source(high: pd.Series, low: pd.Series, close: pd.Series, period: int, adxr_period: int) -> tuple[pd.Series, pd.Series, pd.Series, pd.Series]:
    pdi_values = [math.nan] * len(close)
    mdi_values = [math.nan] * len(close)
    adx_values = [math.nan] * len(close)
    adxr_values = [math.nan] * len(close)

    tr_sum = 0.0
    h_sum = 0.0
    l_sum = 0.0
    mtr = 0.0
    dmp = 0.0
    dmm = 0.0
    dx_sum = 0.0
    adx = 0.0

    for index in range(len(close)):
        prev_close = float(close.iloc[index - 1]) if index > 0 else float(close.iloc[index])
        prev_high = float(high.iloc[index - 1]) if index > 0 else float(high.iloc[index])
        prev_low = float(low.iloc[index - 1]) if index > 0 else float(low.iloc[index])
        current_high = float(high.iloc[index])
        current_low = float(low.iloc[index])

        tr = max(current_high - current_low, abs(current_high - prev_close), abs(prev_close - current_low))
        hd = current_high - prev_high
        ld = prev_low - current_low
        positive_move = hd if hd > 0 and hd > ld else 0.0
        negative_move = ld if ld > 0 and ld > hd else 0.0

        tr_sum += tr
        h_sum += positive_move
        l_sum += negative_move

        if index < period - 1:
            continue

        if index > period - 1:
            mtr = mtr - mtr / period + tr
            dmp = dmp - dmp / period + positive_move
            dmm = dmm - dmm / period + negative_move
        else:
            mtr = tr_sum
            dmp = h_sum
            dmm = l_sum

        pdi = dmp * 100.0 / mtr if mtr != 0 else 0.0
        mdi = dmm * 100.0 / mtr if mtr != 0 else 0.0
        pdi_values[index] = pdi
        mdi_values[index] = mdi

        dx = abs(mdi - pdi) / (mdi + pdi) * 100.0 if (mdi + pdi) != 0 else 0.0
        dx_sum += dx

        if index < period * 2 - 2:
            continue

        if index > period * 2 - 2:
            adx = (adx * (period - 1) + dx) / period
        else:
            adx = dx_sum / period
        adx_values[index] = adx

        if index >= period * 2 + adxr_period - 3:
            prior_adx = adx_values[index - (adxr_period - 1)]
            if prior_adx is not None and math.isfinite(prior_adx):
                adxr_values[index] = (prior_adx + adx) / 2.0

    return pd.Series(pdi_values), pd.Series(mdi_values), pd.Series(adx_values), pd.Series(adxr_values)


def _compute_brar(high: pd.Series, low: pd.Series, open_: pd.Series, close: pd.Series, period: int) -> tuple[pd.Series, pd.Series]:
    br_values = [math.nan] * len(close)
    ar_values = [math.nan] * len(close)
    hcy = cyl = ho = ol = 0.0

    for index in range(len(close)):
        current_high = float(high.iloc[index])
        current_low = float(low.iloc[index])
        current_open = float(open_.iloc[index])
        prev_close = float(close.iloc[index - 1]) if index > 0 else float(close.iloc[index])

        ho += current_high - current_open
        ol += current_open - current_low
        hcy += current_high - prev_close
        cyl += prev_close - current_low

        if index < period - 1:
            continue

        ar_values[index] = ho / ol * 100.0 if ol != 0 else 0.0
        br_values[index] = hcy / cyl * 100.0 if cyl != 0 else 0.0

        ago_high = float(high.iloc[index - (period - 1)])
        ago_low = float(low.iloc[index - (period - 1)])
        ago_open = float(open_.iloc[index - (period - 1)])
        ago_prev_close_index = index - period
        ago_prev_close = float(close.iloc[ago_prev_close_index]) if ago_prev_close_index >= 0 else float(close.iloc[index - (period - 1)])
        hcy -= ago_high - ago_prev_close
        cyl -= ago_prev_close - ago_low
        ho -= ago_high - ago_open
        ol -= ago_open - ago_low

    return pd.Series(br_values), pd.Series(ar_values)


def _compute_cr(high: pd.Series, low: pd.Series, open_: pd.Series, close: pd.Series, period: int, ma_periods: tuple[int, int, int, int]) -> tuple[pd.Series, pd.Series, pd.Series, pd.Series, pd.Series]:
    cr_values = [math.nan] * len(close)
    ma_lists = {value: [] for value in ma_periods}
    ma_sums = {value: 0.0 for value in ma_periods}
    ma_results = {value: [math.nan] * len(close) for value in ma_periods}

    for index in range(len(close)):
        prev_index = index - 1 if index > 0 else index
        prev_mid = (float(high.iloc[prev_index]) + float(close.iloc[prev_index]) + float(low.iloc[prev_index]) + float(open_.iloc[prev_index])) / 4.0
        high_delta = max(0.0, float(high.iloc[index]) - prev_mid)
        low_delta = max(0.0, prev_mid - float(low.iloc[index]))

        if index < period - 1:
            continue

        cr_value = high_delta / low_delta * 100.0 if low_delta != 0 else 0.0
        cr_values[index] = cr_value

        for ma_period in ma_periods:
            ma_sums[ma_period] += cr_value
            if index < period + ma_period - 2:
                continue
            ma_lists[ma_period].append(ma_sums[ma_period] / ma_period)
            forward_period = math.ceil(ma_period / 2.5 + 1)
            if index >= period + ma_period + forward_period - 3:
                ma_results[ma_period][index] = ma_lists[ma_period][len(ma_lists[ma_period]) - 1 - forward_period]
            prior_cr = cr_values[index - (ma_period - 1)]
            if prior_cr is not None and math.isfinite(prior_cr):
                ma_sums[ma_period] -= prior_cr

    return (
        pd.Series(cr_values),
        pd.Series(ma_results[ma_periods[0]]),
        pd.Series(ma_results[ma_periods[1]]),
        pd.Series(ma_results[ma_periods[2]]),
        pd.Series(ma_results[ma_periods[3]]),
    )


def _compute_psy(close: pd.Series, period: int, ma_period: int) -> tuple[pd.Series, pd.Series]:
    psy_values = [math.nan] * len(close)
    ma_values = [math.nan] * len(close)
    up_flags: list[int] = []
    up_count = 0
    psy_sum = 0.0
    close_values = close.tolist()

    for index, current_close in enumerate(close_values):
        prev_close = close_values[index - 1] if index > 0 else current_close
        up_flag = 1 if float(current_close) - float(prev_close) > 0 else 0
        up_flags.append(up_flag)
        up_count += up_flag
        if index < period - 1:
            continue
        psy_value = up_count / period * 100.0
        psy_values[index] = psy_value
        psy_sum += psy_value
        if index >= period + ma_period - 2:
            ma_values[index] = psy_sum / ma_period
            prior_psy = psy_values[index - (ma_period - 1)]
            if prior_psy is not None and math.isfinite(prior_psy):
                psy_sum -= prior_psy
        up_count -= up_flags[index - (period - 1)]

    return pd.Series(psy_values), pd.Series(ma_values)


def _compute_vr(close: pd.Series, volume: pd.Series, period: int, ma_period: int) -> tuple[pd.Series, pd.Series]:
    vr_values = [math.nan] * len(close)
    ma_values = [math.nan] * len(close)
    vr_sum = 0.0
    uvs = dvs = pvs = 0.0
    close_values = close.tolist()
    volume_values = volume.tolist()

    for index, current_close in enumerate(close_values):
        prev_close = close_values[index - 1] if index > 0 else current_close
        current_volume = float(volume_values[index] or 0.0)
        if float(current_close) > float(prev_close):
            uvs += current_volume
        elif float(current_close) < float(prev_close):
            dvs += current_volume
        else:
            pvs += current_volume

        if index < period - 1:
            continue

        half_pvs = pvs / 2.0
        vr_value = (uvs + half_pvs) / (dvs + half_pvs) * 100.0 if (dvs + half_pvs) != 0 else 0.0
        vr_values[index] = vr_value
        vr_sum += vr_value
        if index >= period + ma_period - 2:
            ma_values[index] = vr_sum / ma_period
            prior_vr = vr_values[index - (ma_period - 1)]
            if prior_vr is not None and math.isfinite(prior_vr):
                vr_sum -= prior_vr

        ago_close = float(close_values[index - (period - 1)])
        ago_prev_close = float(close_values[index - period]) if index - period >= 0 else ago_close
        ago_volume = float(volume_values[index - (period - 1)] or 0.0)
        if ago_close > ago_prev_close:
            uvs -= ago_volume
        elif ago_close < ago_prev_close:
            dvs -= ago_volume
        else:
            pvs -= ago_volume

    return pd.Series(vr_values), pd.Series(ma_values)


def _compute_dma(close: pd.Series, short_period: int, long_period: int, signal_period: int) -> tuple[pd.Series, pd.Series]:
    short_ma = _rolling_mean(close, short_period)
    long_ma = _rolling_mean(close, long_period)
    dma = short_ma - long_ma
    ama = _rolling_mean(dma, signal_period)
    return dma, ama


def _compute_emv(high: pd.Series, low: pd.Series, volume: pd.Series, period: int) -> tuple[pd.Series, pd.Series]:
    emv_values = [math.nan] * len(high)
    ma_values = [math.nan] * len(high)
    emv_sum = 0.0
    emv_list: list[float] = []

    for index in range(len(high)):
        if index == 0:
            continue
        distance_moved = (float(high.iloc[index]) + float(low.iloc[index])) / 2.0 - (float(high.iloc[index - 1]) + float(low.iloc[index - 1])) / 2.0
        current_range = float(high.iloc[index]) - float(low.iloc[index])
        current_volume = float(volume.iloc[index] or 0.0)
        if current_volume == 0 or current_range == 0:
            emv_value = 0.0
        else:
            ratio = current_volume / 100_000_000.0 / current_range
            emv_value = distance_moved / ratio
        emv_values[index] = emv_value
        emv_sum += emv_value
        emv_list.append(emv_value)
        if index >= period:
            ma_values[index] = emv_sum / period
            emv_sum -= emv_list[index - period]

    return pd.Series(emv_values), pd.Series(ma_values)


def _compute_ao(high: pd.Series, low: pd.Series, short_period: int, long_period: int) -> pd.Series:
    midpoint = (high + low) / 2.0
    short_ma = _rolling_mean(midpoint, short_period)
    long_ma = _rolling_mean(midpoint, long_period)
    return short_ma - long_ma


def _compute_pvt(close: pd.Series, volume: pd.Series) -> pd.Series:
    values = [math.nan] * len(close)
    running_total = 0.0
    close_values = close.tolist()
    volume_values = volume.tolist()
    for index, current_close in enumerate(close_values):
        prev_close = close_values[index - 1] if index > 0 else current_close
        raw_volume = volume_values[index]
        current_volume = 1.0 if raw_volume is None or (isinstance(raw_volume, float) and math.isnan(raw_volume)) else float(raw_volume)
        denominator = float(prev_close) * current_volume
        contribution = (float(current_close) - float(prev_close)) / denominator if denominator != 0 else 0.0
        running_total += contribution
        values[index] = running_total
    return pd.Series(values)


def _compute_trix(close: pd.Series, period: int, ma_period: int) -> tuple[pd.Series, pd.Series]:
    trix = talib.TRIX(close.to_numpy(), timeperiod=period)
    trix_ma = talib.SMA(trix, timeperiod=ma_period)
    return pd.Series(trix), pd.Series(trix_ma)


def _build_frame(history: list[HistoricDataRow]) -> pd.DataFrame:
    rows = [
        {
            "date": row.date,
            "symbol": row.symbol,
            "open": row.open,
            "high": row.high,
            "low": row.low,
            "close": row.close if row.close is not None else row.ltp,
            "ltp": row.ltp if row.ltp is not None else row.close,
            "volume": row.vol,
            "vwap": row.vwap,
        }
        for row in history
        if row.date
    ]
    if not rows:
        return pd.DataFrame()

    frame = pd.DataFrame(rows).sort_values("date", kind="stable").reset_index(drop=True)
    close = pd.to_numeric(frame["close"], errors="coerce")
    ltp = pd.to_numeric(frame["ltp"], errors="coerce")
    close = close.fillna(ltp)
    frame["close"] = close
    frame["open"] = pd.to_numeric(frame["open"], errors="coerce").fillna(close)
    frame["high"] = pd.to_numeric(frame["high"], errors="coerce").fillna(close)
    frame["low"] = pd.to_numeric(frame["low"], errors="coerce").fillna(close)
    frame["volume"] = pd.to_numeric(frame["volume"], errors="coerce").fillna(0.0)
    frame["vwap"] = pd.to_numeric(frame["vwap"], errors="coerce")
    return frame


def _compute_supertrend(
    high: pd.Series,
    low: pd.Series,
    close: pd.Series,
    atr: pd.Series,
    multiplier: float,
) -> tuple[pd.Series, pd.Series]:
    hl2 = (high + low) / 2.0
    basic_upper = hl2 + multiplier * atr
    basic_lower = hl2 - multiplier * atr

    upper_band = [math.nan] * len(close)
    lower_band = [math.nan] * len(close)
    supertrend = [math.nan] * len(close)
    direction = [math.nan] * len(close)

    for index in range(len(close)):
        current_atr = atr.iloc[index]
        if pd.isna(current_atr):
            continue

        if index == 0:
            upper_band[index] = basic_upper.iloc[index]
            lower_band[index] = basic_lower.iloc[index]
            supertrend[index] = lower_band[index] if close.iloc[index] >= lower_band[index] else upper_band[index]
            direction[index] = 1.0 if close.iloc[index] >= lower_band[index] else -1.0
            continue

        previous_upper = upper_band[index - 1]
        previous_lower = lower_band[index - 1]
        previous_close = close.iloc[index - 1]

        current_upper = basic_upper.iloc[index]
        current_lower = basic_lower.iloc[index]

        upper_band[index] = (
            current_upper
            if pd.isna(previous_upper) or current_upper < previous_upper or previous_close > previous_upper
            else previous_upper
        )
        lower_band[index] = (
            current_lower
            if pd.isna(previous_lower) or current_lower > previous_lower or previous_close < previous_lower
            else previous_lower
        )

        previous_supertrend = supertrend[index - 1]
        if pd.isna(previous_supertrend):
            is_bullish = close.iloc[index] >= lower_band[index]
        elif math.isclose(previous_supertrend, previous_upper, rel_tol=1e-9, abs_tol=1e-9):
            is_bullish = close.iloc[index] > upper_band[index]
        else:
            is_bullish = close.iloc[index] >= lower_band[index]

        supertrend[index] = lower_band[index] if is_bullish else upper_band[index]
        direction[index] = 1.0 if is_bullish else -1.0

    return pd.Series(supertrend), pd.Series(direction)


def compute_indicator_history(history: list[HistoricDataRow]) -> list[IndicatorRow]:
    frame = _build_frame(history)
    if frame.empty:
        return []

    open_ = frame["open"].astype(float)
    close = frame["close"].astype(float)
    high = frame["high"].astype(float)
    low = frame["low"].astype(float)
    volume = frame["volume"].astype(float)
    turnover = pd.to_numeric(frame["turnover"], errors="coerce").fillna(0.0) if "turnover" in frame else pd.Series(np.zeros(len(frame)))
    symbol = str(frame["symbol"].dropna().iloc[-1]) if frame["symbol"].dropna().any() else None

    rsi_kline = _compute_rsi_source(close, (6, 12, 24))
    rsi_14 = talib.RSI(close.to_numpy(), timeperiod=RSI_PERIOD)
    macd_line, macd_signal, macd_hist = talib.MACD(
        close.to_numpy(),
        fastperiod=MACD_FAST,
        slowperiod=MACD_SLOW,
        signalperiod=MACD_SIGNAL,
    )
    kdj_k, kdj_d, kdj_j = _compute_kdj(high, low, close, 9, 3, 3)
    stoch_k, stoch_d = talib.STOCH(
        high.to_numpy(),
        low.to_numpy(),
        close.to_numpy(),
        fastk_period=STOCH_K,
        slowk_period=STOCH_SMOOTH,
        slowk_matype=0,
        slowd_period=STOCH_SMOOTH,
        slowd_matype=0,
    )
    bias_6 = _compute_bias(close, 6)
    bias_12 = _compute_bias(close, 12)
    bias_24 = _compute_bias(close, 24)
    cci_20 = talib.CCI(high.to_numpy(), low.to_numpy(), close.to_numpy(), timeperiod=CCI_PERIOD)
    br, ar = _compute_brar(high, low, open_, close, 26)
    cr, cr_ma_10, cr_ma_20, cr_ma_40, cr_ma_60 = _compute_cr(high, low, open_, close, 26, (10, 20, 40, 60))
    psy, psy_ma_6 = _compute_psy(close, 12, 6)
    williams_r_6 = talib.WILLR(high.to_numpy(), low.to_numpy(), close.to_numpy(), timeperiod=6)
    williams_r_10 = talib.WILLR(high.to_numpy(), low.to_numpy(), close.to_numpy(), timeperiod=10)
    williams_r = talib.WILLR(high.to_numpy(), low.to_numpy(), close.to_numpy(), timeperiod=WILLIAMS_R_PERIOD)
    momentum_5 = talib.MOM(close.to_numpy(), timeperiod=5)
    mtm_12 = talib.MOM(close.to_numpy(), timeperiod=12)
    mtm_ma_6 = talib.SMA(mtm_12, timeperiod=6)
    sma_5 = talib.SMA(close.to_numpy(), timeperiod=5)
    sma_10 = talib.SMA(close.to_numpy(), timeperiod=10)
    sma_12_2 = _compute_cn_sma(close, 12, 2)
    sma_20 = talib.SMA(close.to_numpy(), timeperiod=20)
    sma_30 = talib.SMA(close.to_numpy(), timeperiod=30)
    sma_50 = talib.SMA(close.to_numpy(), timeperiod=50)
    sma_60 = talib.SMA(close.to_numpy(), timeperiod=60)
    sma_100 = talib.SMA(close.to_numpy(), timeperiod=100)
    sma_200 = talib.SMA(close.to_numpy(), timeperiod=200)
    bbi = (pd.Series(talib.SMA(close.to_numpy(), timeperiod=3)) + pd.Series(talib.SMA(close.to_numpy(), timeperiod=6)) + pd.Series(talib.SMA(close.to_numpy(), timeperiod=12)) + pd.Series(talib.SMA(close.to_numpy(), timeperiod=24))) / 4.0
    ema_6 = talib.EMA(close.to_numpy(), timeperiod=6)
    ema_9 = talib.EMA(close.to_numpy(), timeperiod=9)
    ema_12 = talib.EMA(close.to_numpy(), timeperiod=12)
    ema_20 = talib.EMA(close.to_numpy(), timeperiod=20)
    ema_26 = talib.EMA(close.to_numpy(), timeperiod=26)
    ema_50 = talib.EMA(close.to_numpy(), timeperiod=50)
    ema_100 = talib.EMA(close.to_numpy(), timeperiod=100)
    ema_200 = talib.EMA(close.to_numpy(), timeperiod=200)
    adx_14 = talib.ADX(high.to_numpy(), low.to_numpy(), close.to_numpy(), timeperiod=ADX_PERIOD)
    dmi_pdi, dmi_mdi, dmi_adx, dmi_adxr = _compute_dmi_source(high, low, close, 14, 6)
    plus_di = talib.PLUS_DI(high.to_numpy(), low.to_numpy(), close.to_numpy(), timeperiod=ADX_PERIOD)
    minus_di = talib.MINUS_DI(high.to_numpy(), low.to_numpy(), close.to_numpy(), timeperiod=ADX_PERIOD)
    slope_20 = talib.LINEARREG_SLOPE(close.to_numpy(), timeperiod=20)
    acceleration = np.concatenate(([np.nan], np.diff(slope_20)))
    atr_14 = talib.ATR(high.to_numpy(), low.to_numpy(), close.to_numpy(), timeperiod=ATR_PERIOD)
    bb_upper, bb_middle, bb_lower = talib.BBANDS(
        close.to_numpy(),
        timeperiod=BBANDS_PERIOD,
        nbdevup=BBANDS_STDDEV,
        nbdevdn=BBANDS_STDDEV,
        matype=0,
    )
    obv = talib.OBV(close.to_numpy(), volume.to_numpy())
    obv_ma_30 = talib.SMA(obv, timeperiod=30)
    mfi_14 = talib.MFI(high.to_numpy(), low.to_numpy(), close.to_numpy(), volume.to_numpy(), timeperiod=MFI_PERIOD)
    volume_ma_5 = talib.SMA(volume.to_numpy(), timeperiod=5)
    volume_ma_10 = talib.SMA(volume.to_numpy(), timeperiod=10)
    volume_sma_20 = talib.SMA(volume.to_numpy(), timeperiod=VOLUME_SMA_PERIOD)
    vr, vr_ma_6 = _compute_vr(close, volume, 26, 6)
    roc_12 = talib.ROC(close.to_numpy(), timeperiod=12)
    roc_ma_6 = talib.SMA(roc_12, timeperiod=6)
    roc_10 = talib.ROC(close.to_numpy(), timeperiod=10)
    roc_20 = talib.ROC(close.to_numpy(), timeperiod=20)
    dma, ama = _compute_dma(close, 10, 50, 10)
    trix, trix_ma_9 = _compute_trix(close, 12, 9)
    emv, emv_ma = _compute_emv(high, low, volume, 14)
    sar = talib.SAR(high.to_numpy(), low.to_numpy(), acceleration=0.02, maximum=0.2)
    ao = _compute_ao(high, low, 5, 34)
    pvt = _compute_pvt(close, volume)

    frame["ichimoku_conversion"] = (high.rolling(ICHIMOKU_CONVERSION).max() + low.rolling(ICHIMOKU_CONVERSION).min()) / 2.0
    frame["ichimoku_base"] = (high.rolling(ICHIMOKU_BASE).max() + low.rolling(ICHIMOKU_BASE).min()) / 2.0
    frame["ichimoku_span_a"] = (frame["ichimoku_conversion"] + frame["ichimoku_base"]) / 2.0
    frame["ichimoku_span_b"] = (high.rolling(ICHIMOKU_SPAN_B).max() + low.rolling(ICHIMOKU_SPAN_B).min()) / 2.0

    atr_series = pd.Series(atr_14)
    highest_high_22 = high.rolling(CHANDELIER_PERIOD).max()
    lowest_low_22 = low.rolling(CHANDELIER_PERIOD).min()
    chandelier_long = highest_high_22 - atr_series * CHANDELIER_MULTIPLIER
    chandelier_short = lowest_low_22 + atr_series * CHANDELIER_MULTIPLIER
    supertrend_10_3, supertrend_direction = _compute_supertrend(
        high=high,
        low=low,
        close=close,
        atr=atr_series,
        multiplier=SUPER_TREND_MULTIPLIER,
    )

    bb_range = pd.Series(bb_upper) - pd.Series(bb_lower)
    bb_width_pct = np.where(pd.Series(bb_middle).abs() > 0, bb_range / pd.Series(bb_middle) * 100.0, np.nan)
    bb_percent_b = np.where(bb_range.abs() > 0, (close.to_numpy() - bb_lower) / bb_range * 100.0, np.nan)
    volume_ratio_20 = np.where(pd.Series(volume_sma_20).abs() > 0, volume.to_numpy() / volume_sma_20, np.nan)

    typical_price = (high + low + close) / 3.0
    cumulative_volume = volume.cumsum()
    anchored_vwap = np.where(cumulative_volume > 0, (typical_price * volume).cumsum() / cumulative_volume, np.nan)
    cumulative_turnover = turnover.cumsum()
    avp = np.where(cumulative_volume > 0, cumulative_turnover / cumulative_volume, np.nan)
    prior_high = high.shift(1)
    prior_low = low.shift(1)
    prior_close = close.shift(1)
    pivot_point = (prior_high + prior_low + prior_close) / 3.0
    support_1 = pivot_point * 2.0 - prior_high
    resistance_1 = pivot_point * 2.0 - prior_low

    indicator_rows: list[IndicatorRow] = []
    for index, record in frame.iterrows():
        direction_value = supertrend_direction.iloc[index] if index < len(supertrend_direction) else math.nan
        indicator_rows.append(
            IndicatorRow(
                date=str(record["date"]),
                symbol=symbol,
                rsi_6=_finite_float(rsi_kline[6].iloc[index]),
                rsi_12=_finite_float(rsi_kline[12].iloc[index]),
                rsi_14=_finite_float(rsi_14[index]),
                rsi_24=_finite_float(rsi_kline[24].iloc[index]),
                macd_line=_finite_float(macd_line[index]),
                macd_signal=_finite_float(macd_signal[index]),
                macd_hist=_finite_float(macd_hist[index]),
                kdj_k=_finite_float(kdj_k.iloc[index]),
                kdj_d=_finite_float(kdj_d.iloc[index]),
                kdj_j=_finite_float(kdj_j.iloc[index]),
                stoch_k=_finite_float(stoch_k[index]),
                stoch_d=_finite_float(stoch_d[index]),
                bias_6=_finite_float(bias_6.iloc[index]),
                bias_12=_finite_float(bias_12.iloc[index]),
                bias_24=_finite_float(bias_24.iloc[index]),
                cci_20=_finite_float(cci_20[index]),
                br=_finite_float(br.iloc[index]),
                ar=_finite_float(ar.iloc[index]),
                cr=_finite_float(cr.iloc[index]),
                cr_ma_10=_finite_float(cr_ma_10.iloc[index]),
                cr_ma_20=_finite_float(cr_ma_20.iloc[index]),
                cr_ma_40=_finite_float(cr_ma_40.iloc[index]),
                cr_ma_60=_finite_float(cr_ma_60.iloc[index]),
                psy=_finite_float(psy.iloc[index]),
                psy_ma_6=_finite_float(psy_ma_6.iloc[index]),
                williams_r=_finite_float(williams_r[index]),
                williams_r_6=_finite_float(williams_r_6[index]),
                williams_r_10=_finite_float(williams_r_10[index]),
                momentum_5=_finite_float(momentum_5[index]),
                mtm_12=_finite_float(mtm_12[index]),
                mtm_ma_6=_finite_float(mtm_ma_6[index]),
                sma_5=_finite_float(sma_5[index]),
                sma_10=_finite_float(sma_10[index]),
                sma_12_2=_finite_float(sma_12_2.iloc[index]),
                sma_20=_finite_float(sma_20[index]),
                sma_30=_finite_float(sma_30[index]),
                sma_50=_finite_float(sma_50[index]),
                sma_60=_finite_float(sma_60[index]),
                sma_100=_finite_float(sma_100[index]),
                sma_200=_finite_float(sma_200[index]),
                bbi=_finite_float(bbi.iloc[index]),
                ema_6=_finite_float(ema_6[index]),
                ema_9=_finite_float(ema_9[index]),
                ema_12=_finite_float(ema_12[index]),
                ema_20=_finite_float(ema_20[index]),
                ema_26=_finite_float(ema_26[index]),
                ema_50=_finite_float(ema_50[index]),
                ema_100=_finite_float(ema_100[index]),
                ema_200=_finite_float(ema_200[index]),
                adx_14=_finite_float(adx_14[index]),
                dmi_pdi=_finite_float(dmi_pdi.iloc[index]),
                dmi_mdi=_finite_float(dmi_mdi.iloc[index]),
                dmi_adx=_finite_float(dmi_adx.iloc[index]),
                dmi_adxr=_finite_float(dmi_adxr.iloc[index]),
                plus_di=_finite_float(plus_di[index]),
                minus_di=_finite_float(minus_di[index]),
                slope_20=_finite_float(slope_20[index]),
                acceleration=_finite_float(acceleration[index]),
                atr_14=_finite_float(atr_14[index]),
                bb_upper=_finite_float(bb_upper[index]),
                bb_middle=_finite_float(bb_middle[index]),
                bb_lower=_finite_float(bb_lower[index]),
                bb_width_pct=_finite_float(bb_width_pct[index]),
                bb_percent_b=_finite_float(bb_percent_b[index]),
                ichimoku_conversion=_finite_float(frame["ichimoku_conversion"].iloc[index]),
                ichimoku_base=_finite_float(frame["ichimoku_base"].iloc[index]),
                ichimoku_span_a=_finite_float(frame["ichimoku_span_a"].iloc[index]),
                ichimoku_span_b=_finite_float(frame["ichimoku_span_b"].iloc[index]),
                chandelier_long=_finite_float(chandelier_long.iloc[index]),
                chandelier_short=_finite_float(chandelier_short.iloc[index]),
                supertrend_10_3=_finite_float(supertrend_10_3.iloc[index]),
                supertrend_direction=(
                    "BULLISH"
                    if _finite_float(direction_value) and _finite_float(direction_value) > 0
                    else "BEARISH"
                    if _finite_float(direction_value) and _finite_float(direction_value) < 0
                    else None
                ),
                sar=_finite_float(sar[index]),
                ao=_finite_float(ao.iloc[index]),
                obv=_finite_float(obv[index], digits=2),
                obv_ma_30=_finite_float(obv_ma_30[index], digits=2),
                mfi_14=_finite_float(mfi_14[index]),
                kvo=None,
                volume_ma_5=_finite_float(volume_ma_5[index], digits=2),
                volume_ma_10=_finite_float(volume_ma_10[index], digits=2),
                volume_sma_20=_finite_float(volume_sma_20[index], digits=2),
                volume_ratio_20=_finite_float(volume_ratio_20[index]),
                vr=_finite_float(vr.iloc[index]),
                vr_ma_6=_finite_float(vr_ma_6.iloc[index]),
                roc_12=_finite_float(roc_12[index]),
                roc_ma_6=_finite_float(roc_ma_6[index]),
                roc_10=_finite_float(roc_10[index]),
                roc_20=_finite_float(roc_20[index]),
                dma=_finite_float(dma.iloc[index]),
                ama=_finite_float(ama.iloc[index]),
                trix=_finite_float(trix.iloc[index]),
                trix_ma_9=_finite_float(trix_ma_9.iloc[index]),
                emv=_finite_float(emv.iloc[index]),
                emv_ma=_finite_float(emv_ma.iloc[index]),
                pvt=_finite_float(pvt.iloc[index], digits=8),
                avp=_finite_float(avp[index]),
                anchored_vwap=_finite_float(anchored_vwap[index]),
                pivot_point=_finite_float(pivot_point.iloc[index]),
                support_1=_finite_float(support_1.iloc[index]),
                resistance_1=_finite_float(resistance_1.iloc[index]),
            )
        )
    return indicator_rows


def compute_latest_indicator(history: list[HistoricDataRow]) -> Optional[IndicatorRow]:
    rows = compute_indicator_history(history)
    return rows[-1] if rows else None
