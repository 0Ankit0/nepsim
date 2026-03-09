export type SimulationStatus = 'active' | 'paused' | 'ended';
export type TradeType = 'buy' | 'sell';

export interface Simulation {
  id: number;
  user_id: number;
  status: SimulationStatus;
  initial_capital: number;
  current_balance: number;
  start_date: string;
  end_date?: string;
  current_sim_date: string;
  total_pnl_pct: number;
  created_at: string;
}

export interface Trade {
  id: number;
  simulation_id: number;
  symbol: string;
  trade_type: TradeType;
  quantity: number;
  price: number;
  executed_at: string;
  broker_commission: number;
  sebon_fee: number;
  dp_fee: number;
}

export interface SimulationPortfolio {
  symbol: string;
  quantity: number;
  average_price: number;
  current_price: number;
  pnl_pct: number;
}

export interface SimulationDetail extends Simulation {
  portfolio: SimulationPortfolio[];
  trades: Trade[];
}

export interface AnalysisSection {
  title: string;
  description: string;
  impact_on_pnl: string;
}

export interface TradeCommentary {
  symbol: string;
  action: string;
  price: number;
  ai_comment: string;
  alternative_action?: string;
}

export interface AIAnalysis {
  id: number;
  simulation_id: number;
  executive_summary: string;
  what_you_did_right: AnalysisSection[];
  what_you_did_wrong: AnalysisSection[];
  what_you_could_have_done: AnalysisSection[];
  trade_by_trade_commentary: TradeCommentary[];
  overall_skill_rating: number;
  generated_at: string;
}

