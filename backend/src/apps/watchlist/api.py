"""Watchlist App — FastAPI router."""
from __future__ import annotations

import json

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from src.db.session import get_session
from src.apps.iam.api.deps import get_current_user
from src.apps.iam.models.user import User
from src.apps.market.supabase_service import SupabaseMarketService
from src.apps.market_analysis.services import analyze_symbol_from_supabase
from src.apps.market_analysis.schemas import AnalysisResultSchema

from .models import WatchlistAlert, WatchlistItem
from .schemas import (
    WatchlistAlertResponse,
    WatchlistItemCreate,
    WatchlistItemResponse,
    WatchlistItemUpdate,
)

router = APIRouter(prefix="/watchlist", tags=["Watchlist"])


async def _enrich_item(item: WatchlistItem) -> WatchlistItemResponse:
    """Enrich a WatchlistItem with live price data from Supabase."""
    quote = await SupabaseMarketService.get_latest_quote(item.symbol)
    return WatchlistItemResponse(
        id=item.id,
        symbol=item.symbol,
        notes=item.notes,
        target_price=item.target_price,
        stop_loss=item.stop_loss,
        created_at=item.created_at,
        current_price=quote.ltp if quote else None,
        diff_pct=quote.diff_pct if quote else None,
        weeks_52_high=quote.weeks_52_high if quote else None,
        weeks_52_low=quote.weeks_52_low if quote else None,
    )


def _alert_to_schema(alert: WatchlistAlert) -> WatchlistAlertResponse:
    try:
        key_signals = json.loads(alert.key_signals)
    except Exception:
        key_signals = []
    return WatchlistAlertResponse(
        id=alert.id,
        watchlist_item_id=alert.watchlist_item_id,
        symbol=alert.symbol,
        alert_type=alert.alert_type,
        signal_score=alert.signal_score,
        analysis_summary=alert.analysis_summary,
        key_signals=key_signals,
        entry_price=alert.entry_price,
        target_price=alert.target_price,
        stop_loss_price=alert.stop_loss_price,
        created_at=alert.created_at,
        is_read=alert.is_read,
    )


def _analysis_to_schema(analysis) -> AnalysisResultSchema:
    return AnalysisResultSchema(
        symbol=analysis.symbol,
        signal=analysis.signal,
        overall_score=analysis.overall_score,
        oscillator_score=analysis.oscillator_score,
        trend_score=analysis.trend_score,
        volume_score=analysis.volume_score,
        volatility_score=analysis.volatility_score,
        key_signals=analysis.key_signals,
        current_price=analysis.current_price,
        entry_price=analysis.entry_price,
        target_price=analysis.target_price,
        stop_loss=analysis.stop_loss,
        risk_reward_ratio=analysis.risk_reward_ratio,
        analysis_date=analysis.analysis_date,
    )


# ── Fixed-path routes first (before path-param routes) ────────────────────────

@router.get("/alerts", response_model=list[WatchlistAlertResponse])
async def list_alerts(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Get all watchlist alerts — unread first, then read, newest first."""
    result = await db.execute(
        select(WatchlistAlert)
        .where(WatchlistAlert.user_id == current_user.id)
        .order_by(WatchlistAlert.is_read.asc(), WatchlistAlert.created_at.desc())
    )
    alerts = result.scalars().all()
    return [_alert_to_schema(a) for a in alerts]


@router.patch("/alerts/{alert_id}/read")
async def mark_alert_read(
    alert_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(WatchlistAlert).where(
            WatchlistAlert.id == alert_id,
            WatchlistAlert.user_id == current_user.id,
        )
    )
    alert = result.scalars().first()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")
    alert.is_read = True
    db.add(alert)
    await db.commit()
    return {"ok": True}


@router.post("/check-signals", response_model=list[WatchlistAlertResponse])
async def check_signals(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """
    Run analysis on all watchlist items. Creates WatchlistAlert records
    for BUY / STRONG_BUY signals or any item with overall_score >= 55.
    Returns the newly created alerts.
    """
    result = await db.execute(
        select(WatchlistItem).where(WatchlistItem.user_id == current_user.id)
    )
    items = result.scalars().all()

    new_alerts: list[WatchlistAlert] = []
    for item in items:
        analysis = await analyze_symbol_from_supabase(item.symbol)
        if not analysis or analysis.overall_score < 55:
            continue

        if analysis.signal == "STRONG_BUY":
            alert_type = "BUY_STRONG"
        elif analysis.signal == "BUY":
            alert_type = "BUY_CONSIDER"
        else:
            alert_type = "ACCUMULATE"

        top_signals = analysis.key_signals[:3]
        summary_parts = [f"Score: {analysis.overall_score:.1f}"]
        if top_signals:
            summary_parts.append(", ".join(top_signals))
        analysis_summary = " | ".join(summary_parts)

        alert = WatchlistAlert(
            user_id=current_user.id,
            watchlist_item_id=item.id,
            symbol=item.symbol,
            alert_type=alert_type,
            signal_score=analysis.overall_score,
            analysis_summary=analysis_summary,
            key_signals=json.dumps(analysis.key_signals),
            entry_price=analysis.entry_price,
            target_price=analysis.target_price,
            stop_loss_price=analysis.stop_loss,
        )
        db.add(alert)
        new_alerts.append(alert)

    if new_alerts:
        await db.commit()
        for a in new_alerts:
            await db.refresh(a)

    return [_alert_to_schema(a) for a in new_alerts]


# ── Collection routes ──────────────────────────────────────────────────────────

@router.get("/", response_model=list[WatchlistItemResponse])
async def list_watchlist(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """List all watchlist items enriched with current market prices."""
    result = await db.execute(
        select(WatchlistItem).where(WatchlistItem.user_id == current_user.id)
    )
    items = result.scalars().all()
    return [await _enrich_item(i) for i in items]


@router.post("/", response_model=WatchlistItemResponse, status_code=status.HTTP_201_CREATED)
async def create_watchlist_item(
    payload: WatchlistItemCreate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    item = WatchlistItem(
        user_id=current_user.id,
        symbol=payload.symbol.upper(),
        notes=payload.notes,
        target_price=payload.target_price,
        stop_loss=payload.stop_loss,
    )
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return await _enrich_item(item)


# ── Item-specific routes ───────────────────────────────────────────────────────

@router.get("/{item_id}/analysis", response_model=AnalysisResultSchema)
async def get_item_analysis(
    item_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(WatchlistItem).where(
            WatchlistItem.id == item_id,
            WatchlistItem.user_id == current_user.id,
        )
    )
    item = result.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail="Watchlist item not found.")
    analysis = await analyze_symbol_from_supabase(item.symbol)
    if not analysis:
        raise HTTPException(status_code=404, detail=f"No market data available for '{item.symbol}'.")
    return _analysis_to_schema(analysis)


@router.patch("/{item_id}", response_model=WatchlistItemResponse)
async def update_watchlist_item(
    item_id: int,
    payload: WatchlistItemUpdate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(WatchlistItem).where(
            WatchlistItem.id == item_id,
            WatchlistItem.user_id == current_user.id,
        )
    )
    item = result.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail="Watchlist item not found.")
    if payload.notes is not None:
        item.notes = payload.notes
    if payload.target_price is not None:
        item.target_price = payload.target_price
    if payload.stop_loss is not None:
        item.stop_loss = payload.stop_loss
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return await _enrich_item(item)


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_watchlist_item(
    item_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(WatchlistItem).where(
            WatchlistItem.id == item_id,
            WatchlistItem.user_id == current_user.id,
        )
    )
    item = result.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail="Watchlist item not found.")
    await db.delete(item)
    await db.commit()
