"""Market app — service layer. All price/indicator data comes from Supabase.

StockMetadata and ChartDrawing operations still use the local DB.
"""
from __future__ import annotations

from datetime import date
from typing import Optional

import pandas as pd
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, and_

from .models import StockMetadata, ChartDrawing
from .schemas import IndicatorRequest, IndicatorDataPoint
from .supabase_service import SupabaseMarketService


class MarketService:
    """Business logic for market data queries and indicator computation."""

    # ── Stocks (local metadata table — lot size, sector etc.) ───────────────

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

    # ── OHLCV History (Supabase) ─────────────────────────────────────────────

    @staticmethod
    async def get_ohlcv(
        db: AsyncSession,
        symbol: str,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
        limit: int = 500,
    ) -> list:
        """Fetch OHLCV rows from Supabase historicdata table."""
        start_str = start_date.isoformat() if start_date else None
        end_str = end_date.isoformat() if end_date else None
        return await SupabaseMarketService.get_historic_data(
            symbol.upper(), start_str, end_str, limit
        )

    @staticmethod
    async def get_latest_price(
        db: AsyncSession, symbol: str
    ) -> Optional[object]:
        """Return the most recent historicdata row for a symbol."""
        return await SupabaseMarketService.get_latest_quote(symbol.upper())

    @staticmethod
    async def get_price_on_date(
        db: AsyncSession, symbol: str, sim_date: date
    ) -> Optional[float]:
        """
        Get closing price on or before a given simulated date from Supabase.
        Falls back through up to 7 prior days to handle weekends/holidays.
        """
        # Try the given date and up to 7 prior days (to skip weekends/holidays)
        from src.db.supabase import get_supabase_client
        client = await get_supabase_client()
        if not client:
            return None
        try:
            result = await (
                client.table("historicdata")
                .select("ltp, close")
                .eq("symbol", symbol.upper())
                .lte("date", sim_date.isoformat())
                .order("date", desc=True)
                .limit(1)
                .execute()
            )
            rows = result.data or []
            if not rows:
                return None
            row = rows[0]
            # Prefer ltp (last traded price), fall back to close
            return float(row.get("ltp") or row.get("close") or 0) or None
        except Exception:
            return None

    # ── Technical Indicators (Supabase pre-computed) ─────────────────────────

    @staticmethod
    async def compute_indicators(
        db: AsyncSession,
        req: IndicatorRequest,
    ) -> list[IndicatorDataPoint]:
        """
        Return pre-computed indicator values from Supabase indicators table.
        Maps Supabase columns to IndicatorDataPoint fields.
        """
        from datetime import datetime
        start_str = req.start_date.isoformat() if req.start_date else None
        end_str = req.end_date.isoformat() if req.end_date else None
        rows = await SupabaseMarketService.get_indicators(
            req.symbol.upper(), start_str, end_str, limit=1000
        )
        if not rows:
            return []

        ind = req.indicator.lower()
        points: list[IndicatorDataPoint] = []

        def parse_date(d: Optional[str]) -> Optional[date]:
            if not d:
                return None
            try:
                return datetime.fromisoformat(d).date()
            except Exception:
                try:
                    return date.fromisoformat(d)
                except Exception:
                    return None

        def clean(val: Optional[float]) -> Optional[float]:
            if val is None:
                return None
            return round(float(val), 2)

        for row in rows:
            d = parse_date(row.date)
            if not d:
                continue

            if ind == "rsi":
                points.append(IndicatorDataPoint(date=d, value=clean(row.rsi_14)))
            elif ind == "macd":
                points.append(IndicatorDataPoint(
                    date=d,
                    macd=clean(row.macd_line),
                    signal=clean(row.macd_signal),
                    histogram=clean(row.macd_hist),
                ))
            elif ind in ("bb", "bbands", "bollinger"):
                points.append(IndicatorDataPoint(
                    date=d,
                    upper=clean(row.bb_upper),
                    lower=clean(row.bb_lower),
                ))
            elif ind == "ema":
                period = req.period
                ema_map = {9: row.ema_9, 12: row.ema_12, 26: row.ema_26, 200: row.ema_200}
                val = ema_map.get(period, row.ema_9)
                points.append(IndicatorDataPoint(date=d, value=clean(val)))
            elif ind == "sma":
                period = req.period
                sma_map = {5: row.sma_5, 10: row.sma_10, 20: row.sma_20, 50: row.sma_50, 200: row.sma_200}
                val = sma_map.get(period, row.sma_20)
                points.append(IndicatorDataPoint(date=d, value=clean(val)))
            elif ind == "atr":
                points.append(IndicatorDataPoint(date=d, value=clean(row.atr_14)))
            elif ind == "obv":
                points.append(IndicatorDataPoint(date=d, value=clean(row.obv)))
            elif ind == "cci":
                points.append(IndicatorDataPoint(date=d, value=clean(row.cci_20)))
            elif ind in ("stoch", "stochastic"):
                points.append(IndicatorDataPoint(
                    date=d,
                    value=clean(row.stoch_k),
                    signal=clean(row.stoch_d),
                ))
            elif ind == "adx":
                points.append(IndicatorDataPoint(date=d, value=clean(row.adx_14)))
            elif ind in ("williams_r", "wr", "williamsR"):
                points.append(IndicatorDataPoint(date=d, value=clean(row.williams_r)))
            elif ind == "mfi":
                points.append(IndicatorDataPoint(date=d, value=clean(row.mfi_14)))
            elif ind == "vwap":
                # vwap_pct available; actual VWAP value is in historicdata not indicators
                points.append(IndicatorDataPoint(date=d, value=None))
            else:
                # Generic fallback: return None value per date
                points.append(IndicatorDataPoint(date=d, value=None))

        return points

    # ── Chart Drawings (local DB) ────────────────────────────────────────────

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
