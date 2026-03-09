"""AI Analysis — performance calculator and LLM feedback generator."""
from __future__ import annotations

import json
from datetime import datetime
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, and_

from ..simulator.models import Trade, TradeSide, Simulation
from ..market.services import MarketService
from .models import AIAnalysis, AnalysisStatus
from src.apps.core.config import settings


# ─── Performance Calculator ───────────────────────────────────────────────────

class PerformanceCalculator:
    """Computes portfolio performance metrics from a list of trades."""

    @staticmethod
    def compute(
        trades: list[Trade],
        initial_capital: float,
        final_cash: float,
        final_portfolio_value: float,
    ) -> dict:
        sell_trades = [t for t in trades if t.side == TradeSide.SELL and t.realised_pnl is not None]
        total_sells = len(sell_trades)
        winning = [t for t in sell_trades if (t.realised_pnl or 0) > 0]
        losing = [t for t in sell_trades if (t.realised_pnl or 0) <= 0]

        total_pnl = round(
            (final_cash + final_portfolio_value) - initial_capital, 2
        )
        total_pnl_pct = round((total_pnl / initial_capital) * 100, 2) if initial_capital else 0.0
        win_rate = round(len(winning) / total_sells, 4) if total_sells > 0 else 0.0

        pnls = [t.realised_pnl for t in sell_trades if t.realised_pnl is not None]
        best_trade = max(pnls, default=0.0)
        worst_trade = min(pnls, default=0.0)

        # Simplified Sharpe: mean(returns) / std(returns) * sqrt(252)
        sharpe: Optional[float] = None
        if len(pnls) >= 2:
            try:
                import numpy as np
                arr = np.array(pnls)
                std = arr.std()
                if std > 0:
                    sharpe = round((arr.mean() / std) * (252 ** 0.5), 3)
            except Exception:
                pass

        # Max drawdown on realised P&L sequence
        max_drawdown: Optional[float] = None
        if pnls:
            peak = 0.0
            current = 0.0
            dd = 0.0
            for p in pnls:
                current += p
                peak = max(peak, current)
                drawdown = peak - current
                dd = max(dd, drawdown)
            max_drawdown = round((dd / initial_capital) * 100, 2) if initial_capital else 0.0

        # Average holding period (days) from buy→sell matching
        avg_holding: Optional[float] = None
        buy_dates: dict[str, list[datetime]] = {}
        hold_periods: list[float] = []
        for trade in sorted(trades, key=lambda t: t.created_at):
            sym = trade.symbol
            if trade.side == TradeSide.BUY:
                buy_dates.setdefault(sym, []).append(trade.sim_date)
            elif trade.side == TradeSide.SELL and sym in buy_dates and buy_dates[sym]:
                buy_date = buy_dates[sym].pop(0)
                hold_periods.append((trade.sim_date - buy_date).days)
        if hold_periods:
            avg_holding = round(sum(hold_periods) / len(hold_periods), 1)

        return {
            "total_pnl": total_pnl,
            "total_pnl_pct": total_pnl_pct,
            "win_rate": win_rate,
            "sharpe_ratio": sharpe,
            "max_drawdown": max_drawdown,
            "total_trades": len(trades),
            "winning_trades": len(winning),
            "losing_trades": len(losing),
            "best_trade_pnl": best_trade,
            "worst_trade_pnl": worst_trade,
            "avg_holding_days": avg_holding,
        }


# ─── LLM Feedback Generator ───────────────────────────────────────────────────

SYSTEM_PROMPT = """You are an expert NEPSE stock market analyst and trading coach.
Your role is to provide empathetic, educational, and actionable feedback to help
users improve their trading skills. Always be encouraging, not judgmental.
Focus on teaching concepts using real examples from the user's trades."""

def _build_analysis_prompt(
    trades: list[Trade],
    metrics: dict,
    sim: Simulation,
) -> str:
    trades_summary = []
    for t in trades:
        trades_summary.append({
            "trade_id": t.id,
            "symbol": t.symbol,
            "side": t.side,
            "quantity": t.quantity,
            "executed_price": t.executed_price,
            "sim_date": str(t.sim_date.date()),
            "realised_pnl": t.realised_pnl,
        })

    return f"""
Analyse the following NEPSE simulation trading session and provide structured feedback.

**Simulation Period**: {sim.period_start.date()} to {sim.current_sim_date.date()}
**Initial Capital**: NPR {sim.initial_capital:,.0f}
**Final Cash**: NPR {sim.cash_balance:,.0f}

**Performance Metrics**:
- Total P&L: NPR {metrics['total_pnl']:,.2f} ({metrics['total_pnl_pct']:.2f}%)
- Win Rate: {metrics['win_rate']*100:.1f}%
- Total Trades: {metrics['total_trades']}
- Best Trade: NPR {metrics['best_trade_pnl']:,.2f}
- Worst Trade: NPR {metrics['worst_trade_pnl']:,.2f}
- Avg Holding Period: {metrics['avg_holding_days'] or 'N/A'} days
- Sharpe Ratio: {metrics['sharpe_ratio'] or 'N/A'}

**Trade History** (chronological):
{json.dumps(trades_summary, indent=2)}

Respond with a valid JSON object matching this exact structure:
{{
  "summary_narrative": "2-3 sentence overall performance summary (empathetic tone)",
  "what_you_did_right": [
    {{"title": "Action title", "detail": "Detailed explanation with context", "trade_ids": [1,2], "impact_pct": 2.5}}
  ],
  "what_you_did_wrong": [
    {{"title": "Issue title", "detail": "Educational explanation of the mistake", "trade_ids": [3], "impact_pct": -1.2}}
  ],
  "what_you_could_have_done": [
    {{"title": "Alternative title", "detail": "Actionable counterfactual strategy", "trade_ids": [4], "impact_pct": 3.1}}
  ],
  "trade_by_trade_commentary": [
    {{"trade_id": 1, "symbol": "NABIL", "side": "buy", "sim_date": "2022-03-15", "commentary": "Educational comment", "quality_score": 75}}
  ],
  "timing_score": 65,
  "selection_score": 72,
  "risk_score": 58,
  "patience_score": 80
}}
Scores are integers 0-100. Keep each narrative empathetic and educational, referencing specific NEPSE market context where possible.
"""


async def generate_ai_feedback(
    db: AsyncSession,
    analysis: AIAnalysis,
    trades: list[Trade],
    metrics: dict,
    sim: Simulation,
) -> AIAnalysis:
    """Call LLM to generate structured feedback and update the analysis record."""
    provider = getattr(settings, "LLM_PROVIDER", "openai").lower()
    raw_json_str: Optional[str] = None

    try:
        prompt = _build_analysis_prompt(trades, metrics, sim)

        if provider == "anthropic":
            try:
                import anthropic
                api_key = getattr(settings, "ANTHROPIC_API_KEY", "")
                client = anthropic.Anthropic(api_key=api_key)
                message = client.messages.create(
                    model="claude-3-5-sonnet-20241022",
                    max_tokens=4096,
                    system=SYSTEM_PROMPT,
                    messages=[{"role": "user", "content": prompt}],
                )
                raw_json_str = message.content[0].text
                analysis.llm_provider = "anthropic"
            except Exception:
                provider = "openai"  # fallback

        if provider == "openai" and not raw_json_str:
            try:
                from openai import AsyncOpenAI
                api_key = getattr(settings, "OPENAI_API_KEY", "")
                client = AsyncOpenAI(api_key=api_key)
                resp = await client.chat.completions.create(
                    model="gpt-4o-mini",
                    response_format={"type": "json_object"},
                    messages=[
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {"role": "user", "content": prompt},
                    ],
                    max_tokens=4096,
                )
                raw_json_str = resp.choices[0].message.content
                analysis.llm_provider = "openai"
            except Exception as e:
                raise RuntimeError(f"OpenAI call failed: {e}") from e

        if not raw_json_str:
            raise RuntimeError("No LLM response received.")

        # ── Parse JSON response ───────────────────────────────────────────
        parsed = json.loads(raw_json_str)
        analysis.summary_narrative = parsed.get("summary_narrative")
        analysis.what_you_did_right = json.dumps(parsed.get("what_you_did_right", []))
        analysis.what_you_did_wrong = json.dumps(parsed.get("what_you_did_wrong", []))
        analysis.what_you_could_have_done = json.dumps(parsed.get("what_you_could_have_done", []))
        analysis.trade_by_trade_commentary = json.dumps(parsed.get("trade_by_trade_commentary", []))
        analysis.timing_score = parsed.get("timing_score")
        analysis.selection_score = parsed.get("selection_score")
        analysis.risk_score = parsed.get("risk_score")
        analysis.patience_score = parsed.get("patience_score")
        analysis.status = AnalysisStatus.COMPLETED
        analysis.completed_at = datetime.now()

    except Exception as e:
        # Graceful degradation — store generic feedback
        analysis.status = AnalysisStatus.FAILED
        analysis.failure_reason = str(e)[:500]
        analysis.summary_narrative = (
            "We were unable to generate AI analysis at this time. "
            "Your performance metrics are still available above. Please try again later."
        )
        analysis.llm_provider = "fallback"

    # Persist metric fields
    for k, v in metrics.items():
        if hasattr(analysis, k):
            setattr(analysis, k, v)

    db.add(analysis)
    await db.commit()
    await db.refresh(analysis)
    return analysis
