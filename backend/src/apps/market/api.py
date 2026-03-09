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


@router.post("/stocks/{symbol}/upload", status_code=status.HTTP_200_OK)
async def upload_market_data(
    symbol: str,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Admin-only: Upload historical OHLCV data for a symbol via CSV."""
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Only superusers can upload data.")
    
    content = await file.read()
    csv_text = content.decode("utf-8")
    count = await MarketService.import_ohlcv_from_csv(db, symbol, csv_text)
    
    return {"message": f"Successfully imported {count} records for {symbol.upper()}."}


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
    """Historical daily OHLCV data for chart rendering."""
    data = await MarketService.get_ohlcv(db, symbol, start_date, end_date, limit)
    return HistoryResponse(
        symbol=symbol.upper(),
        data=[
            OHLCVPoint(
                date=r.trade_date,
                open=r.open,
                high=r.high,
                low=r.low,
                close=r.close,
                volume=r.volume,
                adjusted_close=r.adjusted_close,
            )
            for r in data
        ],
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
    """Compute technical indicator values for a symbol. Supports 50+ pandas-ta indicators."""
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
