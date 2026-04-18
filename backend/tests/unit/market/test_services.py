import pytest
from datetime import date, timedelta
from sqlalchemy.ext.asyncio import AsyncSession

from src.apps.market.services import MarketService
from src.apps.market.supabase_schemas import HistoricDataRow
from tests.factories import StockMetadataFactory, MarketDataOHLCVFactory


@pytest.mark.asyncio
class TestMarketService:
    """Unit tests for MarketService."""

    async def test_get_all_stocks(self, db_session: AsyncSession):
        # Create some stocks
        stocks = [StockMetadataFactory() for _ in range(3)]
        for s in stocks:
            db_session.add(s)
        await db_session.commit()

        active_stocks = await MarketService.get_all_stocks(db_session, active_only=True)
        assert len(active_stocks) == 3

    async def test_get_stock(self, db_session: AsyncSession):
        stock = StockMetadataFactory(symbol="AAPL", company_name="Apple Inc")
        db_session.add(stock)
        await db_session.commit()

        found = await MarketService.get_stock(db_session, "AAPL")
        assert found is not None
        assert found.company_name == "Apple Inc"
        
        not_found = await MarketService.get_stock(db_session, "GOOGL")
        assert not_found is None

    async def test_talib_indicator_catalog_exposes_chart_mapping(self):
        catalog = MarketService.get_talib_indicator_catalog()
        by_name = {item.name: item for item in catalog}

        assert len(catalog) > 100
        assert by_name["RSI"].group == "Momentum Indicators"
        assert by_name["RSI"].chart_supported is True
        assert by_name["RSI"].chart_indicator_id == "RSI"
        assert by_name["CDLDOJI"].chart_supported is False

    async def test_get_talib_indicator_latest_returns_latest_values(self, monkeypatch):
        history = []
        start = date(2025, 1, 1)
        for index in range(260):
            close = 100 + index * 0.4
            history.append(
                HistoricDataRow(
                    date=(start + timedelta(days=index)).isoformat(),
                    symbol="NABIL",
                    open=close - 1.0,
                    high=close + 1.5,
                    low=close - 1.5,
                    close=close,
                    ltp=close + 0.1,
                    vol=200_000 + index * 500,
                )
            )

        async def _fake_history(*_args, **_kwargs):
            return history

        monkeypatch.setattr("src.apps.market.services.SupabaseMarketService.get_historic_data", _fake_history)

        result = await MarketService.get_talib_indicator_latest("NABIL", "RSI")

        assert result is not None
        assert result.symbol == "NABIL"
        assert result.indicator == "RSI"
        assert result.as_of_date == history[-1].date
        assert result.values["real"] is not None
