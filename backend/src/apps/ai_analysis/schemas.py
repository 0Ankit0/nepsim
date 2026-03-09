"""AI Analysis app — Pydantic response schemas."""
from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel

from .models import AnalysisStatus


class TradeCommentary(BaseModel):
    trade_id: int
    symbol: str
    side: str
    sim_date: str
    commentary: str
    quality_score: Optional[int] = None  # 0-100


class AnalysisSection(BaseModel):
    """One item in the What-Right / What-Wrong / Could-Have-Done lists."""
    title: str
    detail: str
    trade_ids: Optional[list[int]] = None  # trades this point relates to
    impact_pct: Optional[float] = None     # estimated P&L impact


class AIAnalysisResponse(BaseModel):
    id: int
    simulation_id: int
    status: AnalysisStatus

    # Metrics
    total_pnl: Optional[float]
    total_pnl_pct: Optional[float]
    win_rate: Optional[float]
    sharpe_ratio: Optional[float]
    max_drawdown: Optional[float]
    total_trades: Optional[int]
    winning_trades: Optional[int]
    losing_trades: Optional[int]
    best_trade_pnl: Optional[float]
    worst_trade_pnl: Optional[float]
    avg_holding_days: Optional[float]

    # Benchmarks
    market_return_pct: Optional[float]
    buy_hold_return_pct: Optional[float]

    # Narrative sections (parsed from JSON)
    summary_narrative: Optional[str]
    what_you_did_right: Optional[list[AnalysisSection]] = None
    what_you_did_wrong: Optional[list[AnalysisSection]] = None
    what_you_could_have_done: Optional[list[AnalysisSection]] = None
    trade_by_trade_commentary: Optional[list[TradeCommentary]] = None

    # Skill scores
    timing_score: Optional[int]
    selection_score: Optional[int]
    risk_score: Optional[int]
    patience_score: Optional[int]

    llm_provider: Optional[str]
    created_at: datetime
    completed_at: Optional[datetime]

    model_config = {"from_attributes": True}


class AIInsightRequest(BaseModel):
    """On-demand AI contextual explanation."""
    symbol: Optional[str] = None
    concept: Optional[str] = None  # e.g. "P/E ratio", "RSI divergence"
    context: Optional[str] = None  # Additional context to include in prompt


class AIInsightResponse(BaseModel):
    symbol: Optional[str]
    concept: Optional[str]
    explanation: str
    examples: Optional[list[str]] = None
    related_concepts: Optional[list[str]] = None
