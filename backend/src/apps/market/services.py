"""Market app — service layer for NEPSE data queries and indicator computation."""
from __future__ import annotations

from datetime import date
from typing import Optional

import pandas as pd
import ta  # type: ignore  — pure-Python, no numba/llvmlite dependency
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, and_

from .models import StockMetadata, MarketDataOHLCV, ChartDrawing
from .schemas import IndicatorRequest, IndicatorDataPoint, OHLCVPoint


class MarketService:
    """Business logic for market data queries and technical indicator calculation."""

    # ── Stocks ──────────────────────────────────────────────────────────────

    @staticmethod
    async def get_all_stocks(
        db: AsyncSession, active_only: bool = True
    ) -> list[StockMetadata]:
        stmt = select(StockMetadata)
        if active_only:
            stmt = stmt.where(StockMetadata.is_active == True)  # noqa: E712
        result = await db.execute(stmt.order_by(StockMetadata.symbol))
        return result.scalars().all()  # type: ignore

    @staticmethod
    async def get_stock(db: AsyncSession, symbol: str) -> Optional[StockMetadata]:
        result = await db.execute(
            select(StockMetadata).where(StockMetadata.symbol == symbol.upper())
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def create_stock(db: AsyncSession, stock_data: dict) -> StockMetadata:
        stock = StockMetadata(**stock_data)
        stock.symbol = stock.symbol.upper()
        db.add(stock)
        await db.commit()
        await db.refresh(stock)
        return stock

    @staticmethod
    async def update_stock(db: AsyncSession, symbol: str, stock_data: dict) -> Optional[StockMetadata]:
        stock = await MarketService.get_stock(db, symbol)
        if not stock:
            return None
        for key, value in stock_data.items():
            setattr(stock, key, value)
        if "symbol" in stock_data:
            stock.symbol = stock_data["symbol"].upper()
        await db.commit()
        await db.refresh(stock)
        return stock

    @staticmethod
    async def delete_stock(db: AsyncSession, symbol: str) -> bool:
        stock = await MarketService.get_stock(db, symbol)
        if not stock:
            return False
        await db.delete(stock)
        await db.commit()
        return True

    # ── OHLCV History ───────────────────────────────────────────────────────

    @staticmethod
    async def get_ohlcv(
        db: AsyncSession,
        symbol: str,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
        limit: int = 500,
    ) -> list[MarketDataOHLCV]:
        stmt = select(MarketDataOHLCV).where(
            MarketDataOHLCV.symbol == symbol.upper()
        )
        if start_date:
            stmt = stmt.where(MarketDataOHLCV.trade_date >= start_date)
        if end_date:
            stmt = stmt.where(MarketDataOHLCV.trade_date <= end_date)
        stmt = stmt.order_by(MarketDataOHLCV.trade_date.asc()).limit(limit)
        result = await db.execute(stmt)
        return result.scalars().all()  # type: ignore

    @staticmethod
    async def get_latest_price(
        db: AsyncSession, symbol: str
    ) -> Optional[MarketDataOHLCV]:
        result = await db.execute(
            select(MarketDataOHLCV)
            .where(MarketDataOHLCV.symbol == symbol.upper())
            .order_by(MarketDataOHLCV.trade_date.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def get_price_on_date(
        db: AsyncSession, symbol: str, sim_date: date
    ) -> Optional[float]:
        """Get closing price on or before a given simulated date."""
        result = await db.execute(
            select(MarketDataOHLCV)
            .where(
                and_(
                    MarketDataOHLCV.symbol == symbol.upper(),
                    MarketDataOHLCV.trade_date <= sim_date,
                )
            )
            .order_by(MarketDataOHLCV.trade_date.desc())
            .limit(1)
        )
        record = result.scalar_one_or_none()
        return record.close if record else None

    # ── Technical Indicators ─────────────────────────────────────────────────

    @staticmethod
    def _to_dataframe(records: list[MarketDataOHLCV]) -> pd.DataFrame:
        df = pd.DataFrame(
            [
                {
                    "date": r.trade_date,
                    "open": r.open,
                    "high": r.high,
                    "low": r.low,
                    "close": r.close,
                    "volume": float(r.volume),
                }
                for r in records
            ]
        )
        df["date"] = pd.to_datetime(df["date"])
        df = df.set_index("date").sort_index()
        return df

    @staticmethod
    def _clean(val) -> Optional[float]:
        if val is None or (isinstance(val, float) and not (val == val)):
            return None
        return round(float(val), 2)

    @staticmethod
    async def compute_indicators(
        db: AsyncSession,
        req: IndicatorRequest,
    ) -> list[IndicatorDataPoint]:
        """
        Compute requested technical indicator using the `ta` library.
        Supports: rsi, macd, bb/bbands, ema, sma, atr, obv, cci, vwap, stoch, adx, williams_r, mfi
        """
        records = await MarketService.get_ohlcv(
            db, req.symbol, req.start_date, req.end_date, limit=1000
        )
        if not records:
            return []

        df = MarketService._to_dataframe(records)
        ind = req.indicator.lower()
        points: list[IndicatorDataPoint] = []
        clean = MarketService._clean

        # ── RSI ────────────────────────────────────────────────────────────
        if ind == "rsi":
            series = ta.momentum.RSIIndicator(close=df["close"], window=req.period).rsi()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── MACD ───────────────────────────────────────────────────────────
        elif ind == "macd":
            macd_ind = ta.trend.MACD(
                close=df["close"],
                window_slow=req.slow or 26,
                window_fast=req.fast or 12,
                window_sign=req.signal or 9,
            )
            macd_s = macd_ind.macd()
            signal_s = macd_ind.macd_signal()
            hist_s = macd_ind.macd_diff()
            for ts in macd_s.index:
                points.append(IndicatorDataPoint(
                    date=ts.date(),
                    macd=clean(macd_s[ts]),
                    signal=clean(signal_s[ts]),
                    histogram=clean(hist_s[ts]),
                ))

        # ── Bollinger Bands ─────────────────────────────────────────────────
        elif ind in ("bb", "bbands", "bollinger"):
            bb_ind = ta.volatility.BollingerBands(
                close=df["close"],
                window=req.period,
                window_dev=req.std_dev or 2.0,
            )
            upper_s = bb_ind.bollinger_hband()
            middle_s = bb_ind.bollinger_mavg()
            lower_s = bb_ind.bollinger_lband()
            for ts in upper_s.index:
                points.append(IndicatorDataPoint(
                    date=ts.date(),
                    upper=clean(upper_s[ts]),
                    middle=clean(middle_s[ts]),
                    lower=clean(lower_s[ts]),
                ))

        # ── EMA ────────────────────────────────────────────────────────────
        elif ind == "ema":
            series = ta.trend.EMAIndicator(close=df["close"], window=req.period).ema_indicator()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── SMA ────────────────────────────────────────────────────────────
        elif ind == "sma":
            series = ta.trend.SMAIndicator(close=df["close"], window=req.period).sma_indicator()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── ATR ────────────────────────────────────────────────────────────
        elif ind == "atr":
            series = ta.volatility.AverageTrueRange(
                high=df["high"], low=df["low"], close=df["close"], window=req.period
            ).average_true_range()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── OBV ────────────────────────────────────────────────────────────
        elif ind == "obv":
            series = ta.volume.OnBalanceVolumeIndicator(
                close=df["close"], volume=df["volume"]
            ).on_balance_volume()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── CCI ────────────────────────────────────────────────────────────
        elif ind == "cci":
            series = ta.trend.CCIIndicator(
                high=df["high"], low=df["low"], close=df["close"], window=req.period
            ).cci()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── VWAP ───────────────────────────────────────────────────────────
        elif ind == "vwap":
            series = ta.volume.VolumeWeightedAveragePrice(
                high=df["high"], low=df["low"], close=df["close"], volume=df["volume"]
            ).volume_weighted_average_price()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── Stochastic ─────────────────────────────────────────────────────
        elif ind in ("stoch", "stochastic"):
            stoch_ind = ta.momentum.StochasticOscillator(
                high=df["high"], low=df["low"], close=df["close"], window=req.period, smooth_window=3
            )
            stoch_s = stoch_ind.stoch()
            signal_s = stoch_ind.stoch_signal()
            for ts in stoch_s.index:
                points.append(IndicatorDataPoint(
                    date=ts.date(),
                    value=clean(stoch_s[ts]),
                    signal=clean(signal_s[ts]),
                ))

        # ── ADX ────────────────────────────────────────────────────────────
        elif ind == "adx":
            series = ta.trend.ADXIndicator(
                high=df["high"], low=df["low"], close=df["close"], window=req.period
            ).adx()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── Williams %R ────────────────────────────────────────────────────
        elif ind in ("williams_r", "wr", "williamsR"):
            series = ta.momentum.WilliamsRIndicator(
                high=df["high"], low=df["low"], close=df["close"], lbp=req.period
            ).williams_r()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── MFI ────────────────────────────────────────────────────────────
        elif ind == "mfi":
            series = ta.volume.MFIIndicator(
                high=df["high"], low=df["low"], close=df["close"],
                volume=df["volume"], window=req.period
            ).money_flow_index()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        # ── WMA (simple fallback using SMA) ────────────────────────────────
        elif ind == "wma":
            series = ta.trend.WMAIndicator(close=df["close"], window=req.period).wma()
            for ts, val in series.items():
                points.append(IndicatorDataPoint(date=ts.date(), value=clean(val)))

        return points

    # ── Chart Drawings ───────────────────────────────────────────────────────

    @staticmethod
    async def save_drawing(
        db: AsyncSession,
        user_id: int,
        symbol: str,
        drawing_type: str,
        coordinates: str,
        parameters: Optional[str],
        label: Optional[str],
    ) -> ChartDrawing:
        drawing = ChartDrawing(
            user_id=user_id,
            symbol=symbol.upper(),
            drawing_type=drawing_type,  # type: ignore
            coordinates=coordinates,
            parameters=parameters,
            label=label,
        )
        db.add(drawing)
        await db.commit()
        await db.refresh(drawing)
        return drawing

    @staticmethod
    async def get_drawings(
        db: AsyncSession, user_id: int, symbol: str
    ) -> list[ChartDrawing]:
        result = await db.execute(
            select(ChartDrawing).where(
                and_(
                    ChartDrawing.user_id == user_id,
                    ChartDrawing.symbol == symbol.upper(),
                    ChartDrawing.is_visible == True,  # noqa: E712
                )
            )
        )
        return result.scalars().all()  # type: ignore

    @staticmethod
    async def delete_drawing(
        db: AsyncSession, drawing_id: int, user_id: int
    ) -> bool:
        result = await db.execute(
            select(ChartDrawing).where(
                and_(ChartDrawing.id == drawing_id, ChartDrawing.user_id == user_id)
            )
        )
        drawing = result.scalar_one_or_none()
        if not drawing:
            return False
        await db.delete(drawing)
        await db.commit()
        return True

    # ── Data Ingestion ───────────────────────────────────────────────────────

    @staticmethod
    async def import_ohlcv_from_csv(
        db: AsyncSession, symbol: str, csv_content: str
    ) -> int:
        """
        Import OHLCV data from a CSV string.
        Format: date,open,high,low,close,volume
        """
        import csv
        import io
        from datetime import date

        f = io.StringIO(csv_content)
        reader = csv.DictReader(f)
        batch = []
        rows_inserted = 0
        symbol = symbol.upper()

        for row in reader:
            try:
                trade_date = date.fromisoformat(row["date"].strip())
                record = MarketDataOHLCV(
                    symbol=symbol,
                    trade_date=trade_date,
                    open=float(row["open"]),
                    high=float(row["high"]),
                    low=float(row["low"]),
                    close=float(row["close"]),
                    volume=int(float(row.get("volume", 0))),
                )
                batch.append(record)
                rows_inserted += 1
            except (ValueError, KeyError):
                continue

        if batch:
            # Upsert logic (optional, for now simple delete-insert or just insert)
            # To keep it simple, we just add. In production, use UPSERT.
            db.add_all(batch)
            await db.commit()

        return rows_inserted
