"""Market app — service layer. All price/indicator data comes from Supabase.

StockMetadata and ChartDrawing operations still use the local DB.
"""
from __future__ import annotations

from datetime import date
from typing import Any, Optional

import numpy as np
from sqlalchemy.ext.asyncio import AsyncSession
import talib
from sqlmodel import select, and_
from talib import abstract

from .models import StockMetadata, ChartDrawing
from .schemas import IndicatorRequest, IndicatorDataPoint, TaLibIndicatorCatalogItem, TaLibIndicatorValueResponse
from .supabase_service import SupabaseMarketService
from .technical_analysis import compute_indicator_history, compute_latest_indicator


_CHART_SUPPORTED_TALIB_INDICATORS: dict[str, str] = {
    "ADX": "DMI",
    "AROONOSC": "AO",
    "BBANDS": "BOLL",
    "CCI": "CCI",
    "EMA": "EMA",
    "MACD": "MACD",
    "MOM": "MTM",
    "OBV": "OBV",
    "ROC": "ROC",
    "RSI": "RSI",
    "SAR": "SAR",
    "SMA": "SMA",
    "STOCH": "KDJ",
    "TRIX": "TRIX",
    "WILLR": "WR",
}


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
            if isinstance(row, dict):
                value = row.get("ltp") or row.get("close")
                if isinstance(value, (int, float, str)):
                    try:
                        return float(value)
                    except (TypeError, ValueError):
                        return None
                return None
            return None
        except Exception:
            return None

    # ── Technical Indicators (Supabase pre-computed) ─────────────────────────

    @staticmethod
    async def compute_indicators(
        db: AsyncSession,
        req: IndicatorRequest,
    ) -> list[IndicatorDataPoint]:
        """
        Return computed indicator values from OHLCV history using TA-Lib defaults.
        """
        start_str = req.start_date.isoformat() if req.start_date else None
        end_str = req.end_date.isoformat() if req.end_date else None
        history = await SupabaseMarketService.get_historic_data(
            req.symbol.upper(), start_str, end_str, limit=2000
        )
        rows = compute_indicator_history(history)
        if not rows:
            return []

        ind = req.indicator.lower()
        points: list[IndicatorDataPoint] = []

        for row in rows:
            d = date.fromisoformat(row.date) if row.date else None
            if not d:
                continue

            if ind == "rsi":
                points.append(IndicatorDataPoint(date=d, value=row.rsi_14))
            elif ind == "macd":
                points.append(IndicatorDataPoint(
                    date=d,
                    macd=row.macd_line,
                    signal=row.macd_signal,
                    histogram=row.macd_hist,
                ))
            elif ind in ("bb", "bbands", "bollinger"):
                points.append(IndicatorDataPoint(
                    date=d,
                    upper=row.bb_upper,
                    middle=row.bb_middle,
                    lower=row.bb_lower,
                ))
            elif ind == "ema":
                period = req.period
                ema_map = {
                    9: row.ema_9,
                    12: row.ema_12,
                    20: row.ema_20,
                    26: row.ema_26,
                    50: row.ema_50,
                    100: row.ema_100,
                    200: row.ema_200,
                }
                points.append(IndicatorDataPoint(date=d, value=ema_map.get(period)))
            elif ind == "sma":
                period = req.period
                sma_map = {
                    5: row.sma_5,
                    10: row.sma_10,
                    20: row.sma_20,
                    50: row.sma_50,
                    100: row.sma_100,
                    200: row.sma_200,
                }
                points.append(IndicatorDataPoint(date=d, value=sma_map.get(period)))
            elif ind == "atr":
                points.append(IndicatorDataPoint(date=d, value=row.atr_14))
            elif ind == "obv":
                points.append(IndicatorDataPoint(date=d, value=row.obv))
            elif ind == "cci":
                points.append(IndicatorDataPoint(date=d, value=row.cci_20))
            elif ind in ("stoch", "stochastic"):
                points.append(IndicatorDataPoint(
                    date=d,
                    value=row.stoch_k,
                    signal=row.stoch_d,
                ))
            elif ind == "adx":
                points.append(IndicatorDataPoint(date=d, value=row.adx_14))
            elif ind in ("williams_r", "wr", "williamsR"):
                points.append(IndicatorDataPoint(date=d, value=row.williams_r))
            elif ind == "mfi":
                points.append(IndicatorDataPoint(date=d, value=row.mfi_14))
            elif ind == "vwap":
                points.append(IndicatorDataPoint(date=d, value=row.anchored_vwap))
            elif ind == "roc":
                points.append(IndicatorDataPoint(date=d, value=row.roc_10))
            elif ind == "supertrend":
                points.append(IndicatorDataPoint(date=d, value=row.supertrend_10_3))
            elif ind == "volume_ratio":
                points.append(IndicatorDataPoint(date=d, value=row.volume_ratio_20))
            elif ind == "ichimoku":
                points.append(IndicatorDataPoint(
                    date=d,
                    value=row.ichimoku_conversion,
                    signal=row.ichimoku_base,
                    upper=row.ichimoku_span_a,
                    lower=row.ichimoku_span_b,
                ))
            else:
                points.append(IndicatorDataPoint(date=d, value=None))

        return points

    @staticmethod
    async def get_indicator_history(
        symbol: str,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        limit: int = 500,
    ) -> list:
        history = await SupabaseMarketService.get_historic_data(
            symbol.upper(),
            start_date=start_date,
            end_date=end_date,
            limit=min(limit, 5000),
        )
        rows = compute_indicator_history(history)
        return rows[-limit:] if limit > 0 else rows

    @staticmethod
    async def get_latest_indicator_snapshot(symbol: str) -> Optional[object]:
        history = await SupabaseMarketService.get_historic_data(symbol.upper(), limit=400)
        return compute_latest_indicator(history)

    @staticmethod
    def get_talib_indicator_catalog() -> list[TaLibIndicatorCatalogItem]:
        catalog: list[TaLibIndicatorCatalogItem] = []

        for name in sorted(talib.get_functions()):
            function = abstract.Function(name)
            info = function.info

            raw_input_names = info.get("input_names", {})
            input_names: list[str] = []
            if isinstance(raw_input_names, dict):
                for value in raw_input_names.values():
                    if isinstance(value, list):
                        input_names.extend(str(item) for item in value)
                    elif value:
                        input_names.append(str(value))
            elif isinstance(raw_input_names, list):
                input_names.extend(str(item) for item in raw_input_names)
            elif raw_input_names:
                input_names.append(str(raw_input_names))

            chart_indicator_id = _CHART_SUPPORTED_TALIB_INDICATORS.get(name)
            catalog.append(
                TaLibIndicatorCatalogItem(
                    name=name,
                    display_name=str(info.get("display_name") or name),
                    group=str(info.get("group") or "Other"),
                    function_flags=[str(flag) for flag in (info.get("function_flags") or [])],
                    input_names=input_names,
                    output_names=[str(output) for output in function.output_names],
                    chart_indicator_id=chart_indicator_id,
                    chart_supported=chart_indicator_id is not None,
                )
            )

        return catalog

    @staticmethod
    def _build_talib_inputs(history: list) -> dict[str, np.ndarray]:
        rows = [row for row in history if (row.close or row.ltp) is not None]

        def _number(value: Optional[float], fallback: float = 0.0) -> float:
            try:
                return float(value) if value is not None else fallback
            except (TypeError, ValueError):
                return fallback

        return {
            "open": np.array([_number(row.open, _number(row.close, _number(row.ltp))) for row in rows], dtype=float),
            "high": np.array([_number(row.high, _number(row.close, _number(row.ltp))) for row in rows], dtype=float),
            "low": np.array([_number(row.low, _number(row.close, _number(row.ltp))) for row in rows], dtype=float),
            "close": np.array([_number(row.close, _number(row.ltp)) for row in rows], dtype=float),
            "volume": np.array([_number(row.vol) for row in rows], dtype=float),
        }

    @staticmethod
    def _latest_talib_value(output: Any) -> Optional[float]:
        if isinstance(output, np.ndarray):
            values = output.tolist()
        elif isinstance(output, list):
            values = output
        else:
            values = [output]

        for value in reversed(values):
            if value is None:
                continue
            try:
                number = float(value)
            except (TypeError, ValueError):
                continue
            if np.isfinite(number):
                return round(number, 4)
        return None

    @staticmethod
    async def get_talib_indicator_latest(
        symbol: str,
        indicator_name: str,
        as_of_date: Optional[str] = None,
    ) -> Optional[TaLibIndicatorValueResponse]:
        indicator_key = indicator_name.upper()
        catalog = {entry.name: entry for entry in MarketService.get_talib_indicator_catalog()}
        catalog_item = catalog.get(indicator_key)
        if catalog_item is None:
            return None

        history = await SupabaseMarketService.get_historic_data(
            symbol.upper(),
            end_date=as_of_date,
            limit=2000,
        )
        if not history:
            return None

        inputs = MarketService._build_talib_inputs(history)
        if len(inputs["close"]) == 0:
            return None

        function = abstract.Function(indicator_key)
        outputs = function(inputs)
        output_names = list(function.output_names)
        values: dict[str, Optional[float]] = {}

        if isinstance(outputs, list):
            for output_name, output in zip(output_names, outputs):
                values[output_name] = MarketService._latest_talib_value(output)
        else:
            output_name = output_names[0] if output_names else "value"
            values[output_name] = MarketService._latest_talib_value(outputs)

        return TaLibIndicatorValueResponse(
            symbol=symbol.upper(),
            indicator=indicator_key,
            display_name=catalog_item.display_name,
            group=catalog_item.group,
            as_of_date=history[-1].date if history else as_of_date,
            values=values,
        )

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
