"""Market app — FastAPI router."""
from datetime import date
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.session import get_session
from src.apps.iam.api.deps import get_current_user
from src.apps.iam.models.user import User
from .models import StockMetadata
from .schemas import (
    StockDetail, StockListItem, StockCreate, StockUpdate,
    HistoryResponse, OHLCVPoint,
    IndicatorRequest, IndicatorResponse,
    ChartDrawingCreate, ChartDrawingResponse,
)
from fastapi import UploadFile, File
from .services import MarketService
from .supabase_service import SupabaseMarketService
from .supabase_schemas import (
    HistoricDataResponse,
    HistoricDataRow,
    LatestQuoteResponse,
    IndicatorsResponse,
    IndicatorRow,
    IndicesResponse,
    LatestIndicesResponse,
    AllLatestQuotesResponse,
)

router = APIRouter(prefix="/market", tags=["Market Data"])



# ─── Stocks ──────────────────────────────────────────────────────────────────

@router.get("/stocks", response_model=list[StockListItem])
async def list_stocks(
    active_only: bool = Query(True),
    db: AsyncSession = Depends(get_session),
    _: User = Depends(get_current_user),
):
    """List all NEPSE stocks available in the simulator."""
    stocks = await MarketService.get_all_stocks(db, active_only=active_only)
    return stocks


@router.get("/stocks/{symbol}", response_model=StockDetail)
async def get_stock(
    symbol: str,
    db: AsyncSession = Depends(get_session),
    _: User = Depends(get_current_user),
):
    """Get stock detail with current (latest) market price."""
    stock = await MarketService.get_stock(db, symbol)
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock '{symbol}' not found.")

    latest = await MarketService.get_latest_price(db, symbol)
    current_price = latest.close if latest else None

    # Second-most-recent for change %
    prev_close = None
    change_pct = None
    if latest:
        history = await MarketService.get_ohlcv(db, symbol, limit=2)
        if len(history) >= 2:
            prev_close = history[-2].close
            if prev_close:
                change_pct = round(((current_price - prev_close) / prev_close) * 100, 2)  # type: ignore

    return StockDetail(
        **stock.model_dump(),
        current_price=current_price,
        previous_close=prev_close,
        change_pct=change_pct,
    )


@router.post("/stocks", response_model=StockDetail, status_code=status.HTTP_201_CREATED)
async def create_stock(
    payload: StockCreate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Create a new stock metadata entry."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Only superusers can create stocks.")
    stock = await MarketService.create_stock(db, payload.model_dump())
    return await get_stock(stock.symbol, db, current_user)


@router.patch("/stocks/{symbol}", response_model=StockDetail)
async def update_stock(
    symbol: str,
    payload: StockUpdate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Update stock metadata."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Only superusers can update stocks.")
    stock = await MarketService.update_stock(db, symbol, payload.model_dump(exclude_unset=True))
    if not stock:
        raise HTTPException(status_code=404, detail=f"Stock '{symbol}' not found.")
    return await get_stock(symbol, db, current_user)


@router.delete("/stocks/{symbol}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_stock(
    symbol: str,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Delete a stock and its history."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Only superusers can delete stocks.")
    success = await MarketService.delete_stock(db, symbol)
    if not success:
        raise HTTPException(status_code=404, detail=f"Stock '{symbol}' not found.")
    return None


# ─── OHLCV History ───────────────────────────────────────────────────────────

@router.get("/stocks/{symbol}/history", response_model=HistoryResponse)
async def get_ohlcv_history(
    symbol: str,
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    limit: int = Query(500, le=2000),
    db: AsyncSession = Depends(get_session),
    _: User = Depends(get_current_user),
):
    """Historical daily OHLCV data for chart rendering (Reads from Supabase)."""
    from datetime import datetime
    data = await MarketService.get_ohlcv(db, symbol, start_date, end_date, limit)
    
    points = []
    for r in data:
        if not r.date:
            continue
        try:
            d = datetime.fromisoformat(r.date[:10]).date()
        except ValueError:
            continue
        points.append(
            OHLCVPoint(
                date=d,
                open=r.open or 0.0,
                high=r.high or 0.0,
                low=r.low or 0.0,
                close=r.close or 0.0,
                volume=int(r.vol) if r.vol else 0,
                adjusted_close=None,
            )
        )

    return HistoryResponse(
        symbol=symbol.upper(),
        data=points,
    )


# ─── Technical Indicators ────────────────────────────────────────────────────

@router.get("/stocks/{symbol}/indicators", response_model=IndicatorResponse)
async def compute_indicator(
    symbol: str,
    indicator: str = Query(..., description="Indicator name: rsi, macd, bb, ema, sma, atr, obv, cci, vwap, stoch, etc."),
    period: int = Query(14, ge=2, le=200),
    fast: Optional[int] = Query(None),
    slow: Optional[int] = Query(None),
    signal: Optional[int] = Query(None),
    std_dev: Optional[float] = Query(None),
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    db: AsyncSession = Depends(get_session),
    _: User = Depends(get_current_user),
):
    """Return pre-computed technical indicator values for a symbol from Supabase."""
    req = IndicatorRequest(
        symbol=symbol,
        indicator=indicator,
        period=period,
        fast=fast,
        slow=slow,
        signal=signal,
        std_dev=std_dev,
        start_date=start_date,
        end_date=end_date,
    )
    data = await MarketService.compute_indicators(db, req)
    return IndicatorResponse(symbol=symbol.upper(), indicator=indicator, period=period, data=data)


# ─── Chart Drawings ──────────────────────────────────────────────────────────

@router.post("/chart-drawings", response_model=ChartDrawingResponse, status_code=status.HTTP_201_CREATED)
async def save_chart_drawing(
    payload: ChartDrawingCreate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Persist a chart annotation (trendline, Fibonacci, etc.) for a user+symbol."""
    drawing = await MarketService.save_drawing(
        db,
        user_id=current_user.id,
        symbol=payload.symbol,
        drawing_type=payload.drawing_type,
        coordinates=payload.coordinates,
        parameters=payload.parameters,
        label=payload.label,
    )
    return drawing


@router.get("/chart-drawings/{symbol}", response_model=list[ChartDrawingResponse])
async def get_chart_drawings(
    symbol: str,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    drawings = await MarketService.get_drawings(db, current_user.id, symbol)
    return drawings


@router.delete("/chart-drawings/{drawing_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_chart_drawing(
    drawing_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    deleted = await MarketService.delete_drawing(db, drawing_id, current_user.id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Drawing not found.")


# ─── Live NEPSE Data (Supabase) ───────────────────────────────────────────────
# These routes read directly from the Supabase-hosted tables that are refreshed
# daily with real NEPSE market data.

@router.get(
    "/nepse/symbols",
    response_model=list[str],
    summary="List all NEPSE symbols available in Supabase",
)
async def list_nepse_symbols(
    _: User = Depends(get_current_user),
):
    """Return a sorted list of all symbols present in the historicdata table."""
    return await SupabaseMarketService.list_symbols()


@router.get(
    "/nepse/all-quotes",
    response_model=AllLatestQuotesResponse,
    summary="Latest quote for every NEPSE symbol (single request)",
)
async def get_all_nepse_quotes(
    _: User = Depends(get_current_user),
):
    """
    Returns the most recent trading day's OHLCV + market data for all symbols
    in one Supabase query — ideal for populating a full market watchlist table.
    """
    rows = await SupabaseMarketService.get_all_latest_quotes()
    latest_date = rows[0].date if rows else None
    return AllLatestQuotesResponse(date=latest_date, count=len(rows), data=rows)


@router.get(
    "/nepse/{symbol}/history",
    response_model=HistoricDataResponse,
    summary="Historic daily OHLCV data from Supabase",
)
async def get_nepse_history(
    symbol: str,
    start_date: Optional[str] = Query(None, description="Start date YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="End date YYYY-MM-DD"),
    limit: int = Query(500, ge=1, le=5000),
    _: User = Depends(get_current_user),
):
    """Historical market data rows for a symbol from the Supabase historicdata table."""
    rows = await SupabaseMarketService.get_historic_data(
        symbol.upper(), start_date, end_date, limit
    )
    return HistoricDataResponse(symbol=symbol.upper(), count=len(rows), data=rows)


@router.get(
    "/nepse/{symbol}/quote",
    response_model=LatestQuoteResponse,
    summary="Latest market quote for a NEPSE symbol",
)
async def get_nepse_quote(
    symbol: str,
    _: User = Depends(get_current_user),
):
    """Most recent LTP, OHLCV, 52-week range, and daily change for a symbol."""
    row = await SupabaseMarketService.get_latest_quote(symbol.upper())
    if not row:
        raise HTTPException(
            status_code=404,
            detail=f"No data found for symbol '{symbol.upper()}' in Supabase.",
        )
    return LatestQuoteResponse(
        symbol=symbol.upper(),
        date=row.date,
        ltp=row.ltp,
        open=row.open,
        high=row.high,
        low=row.low,
        close=row.close,
        prev_close=row.prev_close,
        diff=row.diff,
        diff_pct=row.diff_pct,
        vwap=row.vwap,
        vol=row.vol,
        turnover=row.turnover,
        weeks_52_high=row.weeks_52_high,
        weeks_52_low=row.weeks_52_low,
    )


@router.get(
    "/nepse/{symbol}/indicators",
    response_model=IndicatorsResponse,
    summary="Pre-computed technical indicators from Supabase",
)
async def get_nepse_indicators(
    symbol: str,
    start_date: Optional[str] = Query(None, description="Start date YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="End date YYYY-MM-DD"),
    limit: int = Query(500, ge=1, le=5000),
    _: User = Depends(get_current_user),
):
    """All 37 pre-computed indicators (RSI, MACD, Bollinger, Ichimoku, etc.) for a symbol."""
    rows = await SupabaseMarketService.get_indicators(
        symbol.upper(), start_date, end_date, limit
    )
    return IndicatorsResponse(symbol=symbol.upper(), count=len(rows), data=rows)


@router.get(
    "/nepse/{symbol}/indicators/latest",
    response_model=IndicatorRow,
    summary="Latest indicator snapshot for a NEPSE symbol",
)
async def get_nepse_latest_indicators(
    symbol: str,
    _: User = Depends(get_current_user),
):
    """Most recent pre-computed indicator values for quick screening."""
    row = await SupabaseMarketService.get_latest_indicators(symbol.upper())
    if not row:
        raise HTTPException(
            status_code=404,
            detail=f"No indicator data found for '{symbol.upper()}' in Supabase.",
        )
    return row


@router.get(
    "/nepse/indices",
    response_model=IndicesResponse,
    summary="NEPSE index history from Supabase",
)
async def get_nepse_indices(
    index_name: Optional[str] = Query(None, description="Filter by index name (e.g. 'NEPSE')"),
    start_date: Optional[str] = Query(None, description="Start date YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="End date YYYY-MM-DD"),
    limit: int = Query(500, ge=1, le=5000),
    _: User = Depends(get_current_user),
):
    """Historical NEPSE index data. Optionally filter by index name and date range."""
    rows = await SupabaseMarketService.get_indices(index_name, start_date, end_date, limit)
    return IndicesResponse(count=len(rows), data=rows)


@router.get(
    "/nepse/indices/latest",
    response_model=LatestIndicesResponse,
    summary="Latest snapshot of all NEPSE indices",
)
async def get_nepse_latest_indices(
    index_name: Optional[str] = Query(None, description="Filter to a single index"),
    _: User = Depends(get_current_user),
):
    """Most recent row per distinct index — useful for dashboard summary cards."""
    rows = await SupabaseMarketService.get_latest_indices(index_name)
    return LatestIndicesResponse(data=rows)

