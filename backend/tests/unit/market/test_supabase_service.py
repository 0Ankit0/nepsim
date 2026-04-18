from types import SimpleNamespace

import pytest

from src.apps.market.supabase_service import SupabaseMarketService


class _FakeQuery:
    def __init__(self, rows: list[dict]):
        self._rows = rows
        self.order_desc = False
        self.limit_value: int | None = None
        self.start_date: str | None = None
        self.end_date: str | None = None
        self.symbol: str | None = None

    def select(self, *_args, **_kwargs):
        return self

    def eq(self, field: str, value: str):
        if field == "symbol":
            self.symbol = value
        return self

    def order(self, _field: str, desc: bool = False):
        self.order_desc = desc
        return self

    def limit(self, value: int):
        self.limit_value = value
        return self

    def gte(self, field: str, value: str):
        if field == "date":
            self.start_date = value
        return self

    def lte(self, field: str, value: str):
        if field == "date":
            self.end_date = value
        return self

    async def execute(self):
        rows = [row for row in self._rows if self.symbol is None or row["symbol"] == self.symbol]
        if self.start_date:
            rows = [row for row in rows if row["date"] >= self.start_date]
        if self.end_date:
            rows = [row for row in rows if row["date"] <= self.end_date]
        rows = sorted(rows, key=lambda row: row["date"], reverse=self.order_desc)
        if self.limit_value is not None:
            rows = rows[:self.limit_value]
        return SimpleNamespace(data=rows)


class _FakeClient:
    def __init__(self, rows: list[dict]):
        self.query = _FakeQuery(rows)

    def table(self, name: str):
        assert name == "historicdata"
        return self.query


@pytest.mark.asyncio
async def test_get_historic_data_prefers_latest_window_without_start_date(monkeypatch):
    rows = [
        {"symbol": "NABIL", "date": "2026-01-01", "close": 100, "ltp": 100},
        {"symbol": "NABIL", "date": "2026-01-02", "close": 101, "ltp": 101},
        {"symbol": "NABIL", "date": "2026-01-03", "close": 102, "ltp": 102},
    ]
    client = _FakeClient(rows)

    async def _fake_client():
        return client

    monkeypatch.setattr("src.apps.market.supabase_service.get_supabase_client", _fake_client)

    result = await SupabaseMarketService.get_historic_data("NABIL", limit=2)

    assert client.query.order_desc is True
    assert [row.date for row in result] == ["2026-01-02", "2026-01-03"]


@pytest.mark.asyncio
async def test_get_historic_data_keeps_forward_order_for_bounded_ranges(monkeypatch):
    rows = [
        {"symbol": "NABIL", "date": "2026-01-01", "close": 100, "ltp": 100},
        {"symbol": "NABIL", "date": "2026-01-02", "close": 101, "ltp": 101},
        {"symbol": "NABIL", "date": "2026-01-03", "close": 102, "ltp": 102},
    ]
    client = _FakeClient(rows)

    async def _fake_client():
        return client

    monkeypatch.setattr("src.apps.market.supabase_service.get_supabase_client", _fake_client)

    result = await SupabaseMarketService.get_historic_data("NABIL", start_date="2026-01-02", limit=5)

    assert client.query.order_desc is False
    assert [row.date for row in result] == ["2026-01-02", "2026-01-03"]
