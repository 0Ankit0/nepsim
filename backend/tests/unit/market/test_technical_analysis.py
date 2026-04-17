from datetime import date, timedelta

from src.apps.market.supabase_schemas import HistoricDataRow
from src.apps.market.technical_analysis import compute_indicator_history, compute_latest_indicator


def _build_history(length: int = 260) -> list[HistoricDataRow]:
    start = date(2023, 1, 1)
    rows: list[HistoricDataRow] = []
    for index in range(length):
        close = 100 + index * 0.35 + ((index % 7) - 3) * 0.4
        high = close + 1.8
        low = close - 1.6
        open_price = close - 0.5
        rows.append(
            HistoricDataRow(
                date=(start + timedelta(days=index)).isoformat(),
                symbol="NABIL",
                open=round(open_price, 2),
                high=round(high, 2),
                low=round(low, 2),
                close=round(close, 2),
                ltp=round(close + 0.15, 2),
                vol=200_000 + index * 1_250,
                vwap=round(close - 0.2, 2),
            )
        )
    return rows


def test_compute_indicator_history_returns_rich_snapshot():
    history = _build_history()
    rows = compute_indicator_history(history)

    assert len(rows) == len(history)
    latest = rows[-1]
    assert latest.rsi_14 is not None
    assert latest.rsi_6 is not None
    assert latest.macd_hist is not None
    assert latest.kdj_j is not None
    assert latest.bias_6 is not None
    assert latest.bbi is not None
    assert latest.sma_200 is not None
    assert latest.ema_50 is not None
    assert latest.bb_middle is not None
    assert latest.volume_ma_10 is not None
    assert latest.volume_ratio_20 is not None
    assert latest.sar is not None
    assert latest.ao is not None
    assert latest.avp is not None
    assert latest.anchored_vwap is not None
    assert latest.supertrend_direction in {"BULLISH", "BEARISH"}


def test_compute_latest_indicator_matches_last_row():
    history = _build_history()
    latest = compute_latest_indicator(history)
    rows = compute_indicator_history(history)

    assert latest is not None
    assert latest.date == rows[-1].date
    assert latest.supertrend_10_3 == rows[-1].supertrend_10_3
