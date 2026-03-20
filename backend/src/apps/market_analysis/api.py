"""Market Analysis App — FastAPI router."""
from __future__ import annotations

from datetime import datetime
from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from .schemas import AnalysisResultSchema, MarketOverviewSchema, TopStocksResponse, Stock360Schema
from .services import AnalysisResult, analyze_symbol_from_supabase, get_top_stocks, get_stock_360_view

router = APIRouter(prefix="/market-analysis", tags=["Market Analysis"])


def _to_schema(r: AnalysisResult) -> AnalysisResultSchema:
    return AnalysisResultSchema(
        symbol=r.symbol,
        signal=r.signal,
        overall_score=r.overall_score,
        oscillator_score=r.oscillator_score,
        trend_score=r.trend_score,
        volume_score=r.volume_score,
        volatility_score=r.volatility_score,
        key_signals=r.key_signals,
        current_price=r.current_price,
        entry_price=r.entry_price,
        target_price=r.target_price,
        stop_loss=r.stop_loss,
        risk_reward_ratio=r.risk_reward_ratio,
        analysis_date=r.analysis_date,
    )


@router.get("/top-stocks", response_model=TopStocksResponse)
async def top_stocks(
    limit: int = Query(20, ge=1, le=500),
    signal: Optional[str] = Query(None, description="Filter by signal: STRONG_BUY, BUY, HOLD, SELL, STRONG_SELL"),
):
    """Get top stocks ranked by overall analysis score. Public endpoint."""
    results = await get_top_stocks(limit=limit, signal_filter=signal)
    return TopStocksResponse(
        generated_at=datetime.now().isoformat(),
        count=len(results),
        results=[_to_schema(r) for r in results],
    )


@router.get("/market-overview", response_model=MarketOverviewSchema)
async def market_overview():
    """Get market-wide signal distribution across all NEPSE symbols. Public endpoint."""
    results = await get_top_stocks(limit=9999)
    total = len(results)
    strong_buy = sum(1 for r in results if r.signal == "STRONG_BUY")
    buy = sum(1 for r in results if r.signal == "BUY")
    hold = sum(1 for r in results if r.signal == "HOLD")
    sell = sum(1 for r in results if r.signal == "SELL")
    strong_sell = sum(1 for r in results if r.signal == "STRONG_SELL")
    bullish_pct = round((strong_buy + buy) / total * 100, 2) if total else 0.0
    bearish_pct = round((sell + strong_sell) / total * 100, 2) if total else 0.0
    return MarketOverviewSchema(
        date=datetime.now().strftime("%Y-%m-%d"),
        total_analyzed=total,
        strong_buy=strong_buy,
        buy=buy,
        hold=hold,
        sell=sell,
        strong_sell=strong_sell,
        bullish_pct=bullish_pct,
        bearish_pct=bearish_pct,
    )


@router.get("/360/{symbol}", response_model=Stock360Schema)
async def stock_360_view(symbol: str):
    """
    Return a full 360-degree view of a NEPSE stock including:
    - Price chart history, indicator signals with interpretations,
    - Performance metrics (returns, volatility, max drawdown),
    - Trend analysis (MA alignment, support/resistance, Ichimoku),
    - Similar historical patterns found via indicator fingerprinting.
    """
    result = await get_stock_360_view(symbol.upper())
    if not result:
        raise HTTPException(status_code=404, detail=f"No market data found for symbol '{symbol}'.")
    return result


@router.get("/{symbol}", response_model=AnalysisResultSchema)
async def analyze_symbol(symbol: str):
    """Analyze a single NEPSE symbol. Public endpoint."""
    result = await analyze_symbol_from_supabase(symbol.upper())
    if not result:
        raise HTTPException(status_code=404, detail=f"No market data found for symbol '{symbol}'.")
    return _to_schema(result)
