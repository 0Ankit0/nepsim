"""Portfolio App — FastAPI router."""
from __future__ import annotations

import json
from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from src.db.session import get_session
from src.apps.iam.api.deps import get_current_user
from src.apps.iam.models.user import User
from src.apps.market.supabase_service import SupabaseMarketService
from src.apps.market_analysis.services import analyze_symbol_from_supabase
from src.apps.market_analysis.schemas import AnalysisResultSchema

from .models import PortfolioAlert, PortfolioItem
from .schemas import (
    PortfolioAlertResponse,
    PortfolioItemCreate,
    PortfolioItemResponse,
    PortfolioItemUpdate,
)

router = APIRouter(prefix="/portfolio", tags=["Portfolio"])


async def _enrich_item(item: PortfolioItem) -> PortfolioItemResponse:
    """Enrich a PortfolioItem with live price data from Supabase."""
    quote = await SupabaseMarketService.get_latest_quote(item.symbol)
    ltp = quote.ltp if quote else None
    cost_basis = item.quantity * item.avg_buy_price
    current_value = round(ltp * item.quantity, 2) if ltp is not None else None
    unrealised_pnl = round(current_value - cost_basis, 2) if current_value is not None else None
    unrealised_pnl_pct = (
        round((unrealised_pnl / cost_basis) * 100, 2)
        if unrealised_pnl is not None and cost_basis
        else None
    )
    return PortfolioItemResponse(
        id=item.id,
        symbol=item.symbol,
        quantity=item.quantity,
        avg_buy_price=item.avg_buy_price,
        buy_date=item.buy_date,
        notes=item.notes,
        created_at=item.created_at,
        current_price=ltp,
        current_value=current_value,
        cost_basis=cost_basis,
        unrealised_pnl=unrealised_pnl,
        unrealised_pnl_pct=unrealised_pnl_pct,
        weeks_52_high=quote.weeks_52_high if quote else None,
        weeks_52_low=quote.weeks_52_low if quote else None,
    )


def _alert_to_schema(alert: PortfolioAlert) -> PortfolioAlertResponse:
    try:
        key_signals = json.loads(alert.key_signals)
    except Exception:
        key_signals = []
    return PortfolioAlertResponse(
        id=alert.id,
        portfolio_item_id=alert.portfolio_item_id,
        symbol=alert.symbol,
        alert_type=alert.alert_type,
        signal_score=alert.signal_score,
        analysis_summary=alert.analysis_summary,
        key_signals=key_signals,
        recommended_action=alert.recommended_action,
        current_price=alert.current_price,
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

@router.get("/alerts", response_model=list[PortfolioAlertResponse])
async def list_alerts(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Get all portfolio alerts — unread first, then read, newest first."""
    result = await db.execute(
        select(PortfolioAlert)
        .where(PortfolioAlert.user_id == current_user.id)
        .order_by(PortfolioAlert.is_read.asc(), PortfolioAlert.created_at.desc())
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
        select(PortfolioAlert).where(
            PortfolioAlert.id == alert_id,
            PortfolioAlert.user_id == current_user.id,
        )
    )
    alert = result.scalars().first()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")
    alert.is_read = True
    db.add(alert)
    await db.commit()
    return {"ok": True}


@router.post("/analyze-all", response_model=list[PortfolioAlertResponse])
async def analyze_all(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """
    Run analysis on every portfolio item. Creates PortfolioAlert records
    for SELL, STRONG_SELL signals, or any item with overall_score < 45.
    Returns the newly created alerts.
    """
    result = await db.execute(
        select(PortfolioItem).where(PortfolioItem.user_id == current_user.id)
    )
    items = result.scalars().all()

    new_alerts: list[PortfolioAlert] = []
    for item in items:
        analysis = await analyze_symbol_from_supabase(item.symbol)
        if not analysis:
            continue

        should_alert = (
            analysis.signal in ("SELL", "STRONG_SELL") or analysis.overall_score < 45
        )
        if not should_alert:
            continue

        if analysis.signal == "STRONG_SELL":
            alert_type = "SELL_STRONG"
            recommended_action = "Consider selling immediately to limit losses."
        elif analysis.signal == "SELL":
            alert_type = "SELL_CONSIDER"
            recommended_action = "Review position; consider partial or full exit."
        else:
            alert_type = "WARNING"
            recommended_action = "Monitor closely; weak technical signals detected."

        top_signals = analysis.key_signals[:3]
        summary_parts = [f"Score: {analysis.overall_score:.1f}"]
        if top_signals:
            summary_parts.append(", ".join(top_signals))
        analysis_summary = " | ".join(summary_parts)

        alert = PortfolioAlert(
            user_id=current_user.id,
            portfolio_item_id=item.id,
            symbol=item.symbol,
            alert_type=alert_type,
            signal_score=analysis.overall_score,
            analysis_summary=analysis_summary,
            key_signals=json.dumps(analysis.key_signals),
            recommended_action=recommended_action,
            current_price=analysis.current_price,
        )
        db.add(alert)
        new_alerts.append(alert)

    if new_alerts:
        await db.commit()
        for a in new_alerts:
            await db.refresh(a)

    return [_alert_to_schema(a) for a in new_alerts]


# ── Collection routes ──────────────────────────────────────────────────────────

@router.get("/", response_model=list[PortfolioItemResponse])
async def list_portfolio(
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """List all portfolio items enriched with current market prices."""
    result = await db.execute(
        select(PortfolioItem).where(PortfolioItem.user_id == current_user.id)
    )
    items = result.scalars().all()
    return [await _enrich_item(i) for i in items]


@router.post("/", response_model=PortfolioItemResponse, status_code=status.HTTP_201_CREATED)
async def create_portfolio_item(
    payload: PortfolioItemCreate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    item = PortfolioItem(
        user_id=current_user.id,
        symbol=payload.symbol.upper(),
        quantity=payload.quantity,
        avg_buy_price=payload.avg_buy_price,
        buy_date=payload.buy_date,
        notes=payload.notes,
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
        select(PortfolioItem).where(
            PortfolioItem.id == item_id,
            PortfolioItem.user_id == current_user.id,
        )
    )
    item = result.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail="Portfolio item not found.")
    analysis = await analyze_symbol_from_supabase(item.symbol)
    if not analysis:
        raise HTTPException(status_code=404, detail=f"No market data available for '{item.symbol}'.")
    return _analysis_to_schema(analysis)


@router.patch("/{item_id}", response_model=PortfolioItemResponse)
async def update_portfolio_item(
    item_id: int,
    payload: PortfolioItemUpdate,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(PortfolioItem).where(
            PortfolioItem.id == item_id,
            PortfolioItem.user_id == current_user.id,
        )
    )
    item = result.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail="Portfolio item not found.")
    if payload.quantity is not None:
        item.quantity = payload.quantity
    if payload.avg_buy_price is not None:
        item.avg_buy_price = payload.avg_buy_price
    if payload.notes is not None:
        item.notes = payload.notes
    item.updated_at = datetime.now()
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return await _enrich_item(item)


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_portfolio_item(
    item_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(PortfolioItem).where(
            PortfolioItem.id == item_id,
            PortfolioItem.user_id == current_user.id,
        )
    )
    item = result.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail="Portfolio item not found.")
    await db.delete(item)
    await db.commit()
