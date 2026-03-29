"""
Market app — Supabase service layer.

Queries the three Supabase tables:
  - historicdata  (daily OHLCV + extended NEPSE data)
  - indicators    (pre-computed technical indicators)
  - indices       (NEPSE index snapshots)
"""
from __future__ import annotations

import logging
from typing import Optional

from src.db.supabase import get_supabase_client
from .supabase_schemas import (
    HistoricDataRow,
    IndicatorRow,
    IndexRow,
)

logger = logging.getLogger(__name__)

_MAX_ROWS = 5000  # Supabase default page size cap


class SupabaseMarketService:
    """Read-only service that fetches live NEPSE data from Supabase."""

    # ── Helpers ──────────────────────────────────────────────────────────────

    @staticmethod
    def _safe_list(result) -> list[dict]:
        """Extract data safely from a Supabase APIResponse."""
        try:
            return result.data or []
        except Exception:
            return []

    # ── Symbols ──────────────────────────────────────────────────────────────

    @staticmethod
    async def list_symbols() -> list[str]:
        """Return distinct NEPSE symbols present in historicdata."""
        client = await get_supabase_client()
        if not client:
            return []
        try:
            result = await (
                client.table("historicdata")
                .select("symbol")
                .limit(_MAX_ROWS)
                .execute()
            )
            rows = SupabaseMarketService._safe_list(result)
            seen: set[str] = set()
            symbols: list[str] = []
            for r in rows:
                sym = r.get("symbol")
                if sym and sym not in seen:
                    seen.add(sym)
                    symbols.append(sym)
            return sorted(symbols)
        except Exception as exc:
            logger.error("list_symbols error: %s", exc)
            return []

    # ── Historic Data ─────────────────────────────────────────────────────────

    @staticmethod
    async def get_historic_data(
        symbol: str,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        limit: int = 500,
    ) -> list[HistoricDataRow]:
        """
        Fetch daily OHLCV rows from historicdata for the given symbol.
        Dates are strings in 'YYYY-MM-DD' format (as stored in Supabase).
        Results ordered ascending by date.
        """
        client = await get_supabase_client()
        if not client:
            return []
        try:
            query = (
                client.table("historicdata")
                .select("*")
                .eq("symbol", symbol.upper())
                .order("date", desc=False)
                .limit(min(limit, _MAX_ROWS))
            )
            if start_date:
                query = query.gte("date", start_date)
            if end_date:
                query = query.lte("date", end_date)

            result = await query.execute()
            rows = SupabaseMarketService._safe_list(result)
            return [HistoricDataRow(**r) for r in rows]
        except Exception as exc:
            logger.error("get_historic_data error: %s", exc)
            return []

    @staticmethod
    async def get_latest_quote(
        symbol: str,
        as_of_date: Optional[str] = None,
    ) -> Optional[HistoricDataRow]:
        """Return the most recent historicdata row for a symbol up to `as_of_date`."""
        client = await get_supabase_client()
        if not client:
            return None
        try:
            query = (
                client.table("historicdata")
                .select("*")
                .eq("symbol", symbol.upper())
                .order("date", desc=True)
                .limit(1)
            )
            if as_of_date:
                query = query.lte("date", as_of_date)

            result = await query.execute()
            rows = SupabaseMarketService._safe_list(result)
            return HistoricDataRow(**rows[0]) if rows else None
        except Exception as exc:
            logger.error("get_latest_quote error: %s", exc)
            return None

    # ── Indicators ────────────────────────────────────────────────────────────

    @staticmethod
    async def get_indicators(
        symbol: str,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        limit: int = 500,
    ) -> list[IndicatorRow]:
        """Fetch pre-computed indicator rows from Supabase."""
        client = await get_supabase_client()
        if not client:
            return []
        try:
            query = (
                client.table("indicators")
                .select("*")
                .eq("symbol", symbol.upper())
                .order("date", desc=False)
                .limit(min(limit, _MAX_ROWS))
            )
            if start_date:
                query = query.gte("date", start_date)
            if end_date:
                query = query.lte("date", end_date)

            result = await query.execute()
            rows = SupabaseMarketService._safe_list(result)
            return [IndicatorRow(**r) for r in rows]
        except Exception as exc:
            logger.error("get_indicators error: %s", exc)
            return []

    @staticmethod
    async def get_latest_indicators(
        symbol: str,
        as_of_date: Optional[str] = None,
    ) -> Optional[IndicatorRow]:
        """Return the most recent indicator snapshot for a symbol up to `as_of_date`."""
        client = await get_supabase_client()
        if not client:
            return None
        try:
            query = (
                client.table("indicators")
                .select("*")
                .eq("symbol", symbol.upper())
                .order("date", desc=True)
                .limit(1)
            )
            if as_of_date:
                query = query.lte("date", as_of_date)

            result = await query.execute()
            rows = SupabaseMarketService._safe_list(result)
            return IndicatorRow(**rows[0]) if rows else None
        except Exception as exc:
            logger.error("get_latest_indicators error: %s", exc)
            return None

    # ── Indices ───────────────────────────────────────────────────────────────

    @staticmethod
    async def get_indices(
        index_name: Optional[str] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        limit: int = 500,
    ) -> list[IndexRow]:
        """Fetch NEPSE index rows. Optionally filter by index name."""
        client = await get_supabase_client()
        if not client:
            return []
        try:
            query = (
                client.table("indices")
                .select("*")
                .order("date", desc=False)
                .limit(min(limit, _MAX_ROWS))
            )
            if index_name:
                query = query.eq("index", index_name)
            if start_date:
                query = query.gte("date", start_date)
            if end_date:
                query = query.lte("date", end_date)

            result = await query.execute()
            rows = SupabaseMarketService._safe_list(result)
            return [IndexRow(**r) for r in rows]
        except Exception as exc:
            logger.error("get_indices error: %s", exc)
            return []

    @staticmethod
    async def get_latest_indices(index_name: Optional[str] = None) -> list[IndexRow]:
        """
        Return the latest row(s) from the indices table.
        If index_name is given, returns one row; otherwise returns
        the most recent row per distinct index name.
        """
        client = await get_supabase_client()
        if not client:
            return []
        try:
            # Pull recent rows and deduplicate by index name (most recent per index)
            query = (
                client.table("indices")
                .select("*")
                .order("date", desc=True)
                .limit(100)
            )
            if index_name:
                query = query.eq("index", index_name)

            result = await query.execute()
            rows = SupabaseMarketService._safe_list(result)

            # Deduplicate: keep first occurrence (latest) per index name
            seen: set[str] = set()
            latest: list[IndexRow] = []
            for r in rows:
                name = r.get("index", "")
                if name not in seen:
                    seen.add(name)
                    latest.append(IndexRow(**r))
            return latest
        except Exception as exc:
            logger.error("get_latest_indices error: %s", exc)
            return []

    # ── Bulk Latest Quotes ────────────────────────────────────────────────────

    @staticmethod
    async def get_all_latest_quotes() -> list[HistoricDataRow]:
        """
        Return the most recent trading day's data for every symbol.

        Strategy: find the most recent date in historicdata, then fetch all
        rows for that date in a single query — avoids N+1 calls.
        """
        client = await get_supabase_client()
        if not client:
            return []
        try:
            # 1) Find the latest date present
            date_res = await (
                client.table("historicdata")
                .select("date")
                .order("date", desc=True)
                .limit(1)
                .execute()
            )
            date_rows = SupabaseMarketService._safe_list(date_res)
            if not date_rows:
                return []
            latest_date = date_rows[0].get("date")
            if not latest_date:
                return []

            # 2) Fetch all symbols for that date
            result = await (
                client.table("historicdata")
                .select("*")
                .eq("date", latest_date)
                .order("symbol", desc=False)
                .limit(_MAX_ROWS)
                .execute()
            )
            rows = SupabaseMarketService._safe_list(result)
            return [HistoricDataRow(**r) for r in rows]
        except Exception as exc:
            logger.error("get_all_latest_quotes error: %s", exc)
            return []

    # ── Benchmark helper (used by ai_analysis) ────────────────────────────────

    @staticmethod
    async def get_index_return_pct(
        index_name: str,
        start_date: str,
        end_date: str,
    ) -> Optional[float]:
        """
        Compute the percentage return of a NEPSE index between two dates.
        Returns None if insufficient data is available.
        """
        client = await get_supabase_client()
        if not client:
            return None
        try:
            # First row on/after start_date
            start_res = await (
                client.table("indices")
                .select("current")
                .eq("index", index_name)
                .gte("date", start_date)
                .order("date", desc=False)
                .limit(1)
                .execute()
            )
            # Last row on/before end_date
            end_res = await (
                client.table("indices")
                .select("current")
                .eq("index", index_name)
                .lte("date", end_date)
                .order("date", desc=True)
                .limit(1)
                .execute()
            )
            start_rows = SupabaseMarketService._safe_list(start_res)
            end_rows = SupabaseMarketService._safe_list(end_res)
            if not start_rows or not end_rows:
                return None
            start_val = start_rows[0].get("current")
            end_val = end_rows[0].get("current")
            if not start_val or not end_val or start_val == 0:
                return None
            return round(((end_val - start_val) / start_val) * 100, 2)
        except Exception as exc:
            logger.error("get_index_return_pct error: %s", exc)
            return None
