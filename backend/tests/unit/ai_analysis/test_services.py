import pytest
from src.apps.ai_analysis.services import PerformanceCalculator
from src.apps.simulator.models import TradeSide
from tests.factories import TradeFactory


class TestPerformanceCalculator:
    """Unit tests for PerformanceCalculator."""

    def test_compute_basic_metrics(self):
        # Create some mock trades
        t1 = TradeFactory(side=TradeSide.BUY, executed_price=100.0, quantity=10, total_cost=1000.0)
        t2 = TradeFactory(side=TradeSide.SELL, executed_price=120.0, quantity=10, realised_pnl=200.0)
        t3 = TradeFactory(side=TradeSide.BUY, executed_price=200.0, quantity=5, total_cost=1000.0)
        t4 = TradeFactory(side=TradeSide.SELL, executed_price=180.0, quantity=5, realised_pnl=-100.0)
        
        trades = [t1, t2, t3, t4]
        initial_capital = 10000.0
        final_cash = 10100.0  # 10000 - 1000 + 1200 - 1000 + 900
        final_portfolio_value = 0.0
        
        metrics = PerformanceCalculator.compute(
            trades, initial_capital, final_cash, final_portfolio_value
        )
        
        assert metrics["total_pnl"] == 100.0
        assert metrics["total_pnl_pct"] == 1.0
        assert metrics["total_trades"] == 4
        assert metrics["winning_trades"] == 1
        assert metrics["losing_trades"] == 1
        assert metrics["win_rate"] == 0.5
        assert metrics["best_trade_pnl"] == 200.0
        assert metrics["worst_trade_pnl"] == -100.0

    def test_compute_empty_trades(self):
        metrics = PerformanceCalculator.compute([], 10000.0, 10000.0, 0.0)
        assert metrics["total_pnl"] == 0.0
        assert metrics["total_trades"] == 0
        assert metrics["win_rate"] == 0.0
