import pytest
from datetime import date, timedelta
from sqlalchemy.ext.asyncio import AsyncSession

from src.apps.market.services import MarketService
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

    async def test_get_ohlcv(self, db_session: AsyncSession):
        symbol = "NEPSE"
        today = date.today()
        
        # Create data points
        for i in range(5):
            point = MarketDataOHLCVFactory(
                symbol=symbol,
                trade_date=today - timedelta(days=i)
            )
            db_session.add(point)
        
        await db_session.commit()

        history = await MarketService.get_ohlcv(db_session, symbol)
        assert len(history) == 5
        # Verify order (asc)
        assert history[0].trade_date < history[-1].trade_date

    async def test_get_latest_price(self, db_session: AsyncSession):
        symbol = "NEPSE"
        today = date.today()
        
        # Create data points
        db_session.add(MarketDataOHLCVFactory(symbol=symbol, trade_date=today - timedelta(days=2), close=100))
        db_session.add(MarketDataOHLCVFactory(symbol=symbol, trade_date=today - timedelta(days=1), close=110))
        
        await db_session.commit()

        latest = await MarketService.get_latest_price(db_session, symbol)
        assert latest is not None
        assert latest.close == 110
        assert latest.trade_date == today - timedelta(days=1)
