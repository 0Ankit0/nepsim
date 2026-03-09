"""AI Analysis app — FastAPI router."""
import json
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from src.db.session import get_session
from src.apps.iam.api.deps import get_current_user
from src.apps.iam.models.user import User
from src.apps.simulator.services import SimulatorService
from .models import AIAnalysis
from .schemas import AIAnalysisResponse, AIInsightRequest, AIInsightResponse, AnalysisSection, TradeCommentary

router = APIRouter(tags=["AI Analysis"])


def _parse_json_field(raw: Optional[str]) -> Optional[list]:
    if raw is None:
        return None
    try:
        return json.loads(raw)
    except Exception:
        return None


@router.get("/simulations/{simulation_id}/analysis", response_model=AIAnalysisResponse)
async def get_analysis(
    simulation_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """
    Retrieve AI analysis for a completed simulation.
    If PENDING or PROCESSING, returns the current status so the client can poll.
    """
    # Verify ownership
    sim = await SimulatorService.get_simulation(db, simulation_id, current_user.id)
    if not sim:
        raise HTTPException(status_code=404, detail="Simulation not found.")

    result = await db.execute(
        select(AIAnalysis).where(AIAnalysis.simulation_id == simulation_id)
    )
    analysis = result.scalar_one_or_none()

    if not analysis:
        raise HTTPException(
            status_code=status.HTTP_202_ACCEPTED,
            detail="Analysis is still being generated. Please retry in a few seconds.",
        )

    # Parse JSON blob fields into structured types
    right = _parse_json_field(analysis.what_you_did_right)
    wrong = _parse_json_field(analysis.what_you_did_wrong)
    could = _parse_json_field(analysis.what_you_could_have_done)
    tbc = _parse_json_field(analysis.trade_by_trade_commentary)

    def to_sections(raw_list: Optional[list]) -> Optional[list[AnalysisSection]]:
        if not raw_list:
            return None
        return [AnalysisSection(**item) for item in raw_list if isinstance(item, dict)]

    def to_commentaries(raw_list: Optional[list]) -> Optional[list[TradeCommentary]]:
        if not raw_list:
            return None
        return [TradeCommentary(**item) for item in raw_list if isinstance(item, dict)]

    data = analysis.model_dump()
    data["what_you_did_right"] = to_sections(right)
    data["what_you_did_wrong"] = to_sections(wrong)
    data["what_you_could_have_done"] = to_sections(could)
    data["trade_by_trade_commentary"] = to_commentaries(tbc)

    return AIAnalysisResponse(**data)


@router.post("/simulations/{simulation_id}/analysis/retry", status_code=status.HTTP_202_ACCEPTED)
async def retry_analysis(
    simulation_id: int,
    db: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    """Re-trigger AI analysis for a simulation where generation failed."""
    sim = await SimulatorService.get_simulation(db, simulation_id, current_user.id)
    if not sim:
        raise HTTPException(status_code=404, detail="Simulation not found.")

    try:
        from src.apps.ai_analysis.tasks import generate_analysis_task
        task = generate_analysis_task.delay(simulation_id, current_user.id)
        return {"message": "Analysis re-triggered.", "task_id": task.id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Could not retry analysis: {e}")


@router.post("/learn/ai-insights", response_model=AIInsightResponse)
async def get_ai_insight(
    payload: AIInsightRequest,
    _: User = Depends(get_current_user),
):
    """On-demand AI explanation of a financial concept or symbol."""
    from src.apps.learn.services import LearnService
    explanation = await LearnService.generate_ai_insight(
        symbol=payload.symbol,
        concept=payload.concept,
        context=payload.context,
    )
    return AIInsightResponse(
        symbol=payload.symbol,
        concept=payload.concept,
        explanation=explanation,
    )
