import pytest
from datetime import date
from unittest.mock import patch
from sqlalchemy.ext.asyncio import AsyncSession

from src.apps.simulator.services import SimulatorService, InsufficientFundsError, InsufficientSharesError
from src.apps.simulator.models import SimulationStatus, TradeSide
from src.apps.simulator.schemas import TradeRequest
from tests.factories import SimulationFactory, MarketDataOHLCVFactory


@pytest.mark.asyncio
class TestSimulatorService:
    """Unit tests for SimulatorService."""

    async def test_create_simulation(self, db_session: AsyncSession):
        user_id = 1
        initial_capital = 100000.0
        
        # Need some market data for the random window to work
        point = MarketDataOHLCVFactory(trade_date=date(2023, 1, 1))
        db_session.add(point)
        await db_session.commit()

        sim = await SimulatorService.create_simulation(
            db_session, user_id, initial_capital, "Test Sim"
        )
        
        assert sim.user_id == user_id
        assert sim.initial_capital == initial_capital
        assert sim.cash_balance == initial_capital
        assert sim.status == SimulationStatus.ACTIVE
        assert sim.name == "Test Sim"

    @patch("src.apps.simulator.services.SimulatorService._find_next_market_date")
    @patch("src.apps.simulator.services.SimulatorService._get_market_bounds")
    async def test_create_simulation_uses_selected_start_date(self, mock_get_bounds, mock_find_next_market_date, db_session: AsyncSession):
        mock_get_bounds.return_value = (date(2024, 1, 1), date(2024, 12, 31))
        mock_find_next_market_date.return_value = date(2024, 3, 18)

        sim = await SimulatorService.create_simulation(
            db_session,
            user_id=1,
            initial_capital=150000.0,
            name="March Replay",
            start_date=date(2024, 3, 16),
        )

        assert sim.period_start.date() == date(2024, 3, 18)
        assert sim.current_sim_date.date() == date(2024, 3, 18)
        assert sim.period_end.date() == date(2024, 5, 17)

    async def test_get_simulation(self, db_session: AsyncSession):
        sim = SimulationFactory(user_id=1)
        db_session.add(sim)
        await db_session.commit()

        found = await SimulatorService.get_simulation(db_session, sim.id, 1)
        assert found is not None
        assert found.id == sim.id

        not_found = await SimulatorService.get_simulation(db_session, 999, 1)
        assert not_found is None

    @patch("src.apps.market.services.MarketService.get_price_on_date")
    async def test_execute_trade_buy(self, mock_get_price, db_session: AsyncSession):
        user_id = 1
        sim = SimulationFactory(user_id=user_id, cash_balance=100000.0)
        db_session.add(sim)
        await db_session.commit()

        symbol = "NABIL"
        mock_get_price.return_value = 500.0  # NPR 500 per share

        req = TradeRequest(symbol=symbol, side=TradeSide.BUY, quantity=100)
        trade = await SimulatorService.execute_trade(db_session, sim.id, user_id, req)

        assert trade.symbol == symbol
        assert trade.side == TradeSide.BUY
        assert trade.quantity == 100
        assert trade.executed_price > 500.0  # including slippage
        
        # Check cash balance updated
        await db_session.refresh(sim)
        assert sim.cash_balance < 100000.0

    @patch("src.apps.market.services.MarketService.get_price_on_date")
    async def test_execute_trade_insufficient_funds(self, mock_get_price, db_session: AsyncSession):
        user_id = 1
        sim = SimulationFactory(user_id=user_id, cash_balance=1000.0)
        db_session.add(sim)
        await db_session.commit()

        mock_get_price.return_value = 500.0
        req = TradeRequest(symbol="NABIL", side=TradeSide.BUY, quantity=100)
        
        with pytest.raises(InsufficientFundsError):
            await SimulatorService.execute_trade(db_session, sim.id, user_id, req)
