import { apiClient } from '@/lib/api-client';

export type SimulationStatus = 'active' | 'paused' | 'ended' | 'analysing' | 'analysis_ready';
export type TradeSide = 'buy' | 'sell';
export type TradeStatus = 'executed' | 'rejected';

export interface PortfolioHolding {
  symbol: string;
  quantity: number;
  average_buy_price: number;
  current_price: number | null;
  current_value: number | null;
  unrealised_pnl: number | null;
  unrealised_pnl_pct: number | null;
}

export interface SimulationResponse {
  id: number;
  user_id: number;
  name: string | null;
  initial_capital: number;
  cash_balance: number;
  status: SimulationStatus;
  period_start: string;
  period_end: string;
  current_sim_date: string;
  seconds_per_day: number;
  started_at: string;
  ended_at: string | null;
  portfolio_value: number | null;
  total_value: number | null;
  total_pnl: number | null;
  total_pnl_pct: number | null;
  holdings: PortfolioHolding[] | null;
}

export interface SimulationSummary {
  id: number;
  name: string | null;
  status: SimulationStatus;
  initial_capital: number;
  seconds_per_day: number;
  started_at: string;
  ended_at: string | null;
  total_pnl: number | null;
  total_pnl_pct: number | null;
  total_trades: number | null;
}

export interface TradeRequest {
  symbol: string;
  side: TradeSide;
  quantity: number;
}

export interface TradeResponse {
  id: number;
  simulation_id: number;
  symbol: string;
  side: TradeSide;
  quantity: number;
  executed_price: number;
  sebon_commission: number;
  broker_commission: number;
  dp_charge: number;
  total_cost: number;
  sim_date: string;
  status: TradeStatus;
  rejection_reason: string | null;
  realised_pnl: number | null;
  created_at: string;
  new_cash_balance: number | null;
  message: string | null;
}

export interface EndSimulationResponse {
  simulation_id: number;
  status: SimulationStatus;
  message: string;
  analysis_task_id: string | null;
}

export interface AnalysisSection {
  title: string;
  detail: string;
  trade_ids?: number[] | null;
  impact_pct?: number | null;
}

export interface TradeCommentary {
  trade_id: number;
  symbol: string;
  side: string;
  sim_date: string;
  commentary: string;
  quality_score?: number | null;
}

export interface AIAnalysisResponse {
  id: number;
  simulation_id: number;
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  
  // Metrics
  total_pnl?: number | null;
  total_pnl_pct?: number | null;
  win_rate?: number | null;
  sharpe_ratio?: number | null;
  max_drawdown?: number | null;
  total_trades?: number | null;
  winning_trades?: number | null;
  losing_trades?: number | null;
  best_trade_pnl?: number | null;
  worst_trade_pnl?: number | null;
  avg_holding_days?: number | null;

  // Benchmarks
  market_return_pct?: number | null;
  buy_hold_return_pct?: number | null;

  summary_narrative?: string | null;
  what_you_did_right?: AnalysisSection[] | null;
  what_you_did_wrong?: AnalysisSection[] | null;
  what_you_could_have_done?: AnalysisSection[] | null;
  trade_by_trade_commentary?: TradeCommentary[] | null;
  
  timing_score?: number | null;
  selection_score?: number | null;
  risk_score?: number | null;
  patience_score?: number | null;

  llm_provider?: string | null;
  created_at?: string;
  completed_at?: string | null;
}

export const simulatorApi = {
  // Create a new simulation session
  createSimulation: async (initial_capital: number, name?: string): Promise<SimulationResponse> => {
    const { data } = await apiClient.post('/simulations/', { initial_capital, name });
    return data;
  },

  // List all simulations for the current user
  listSimulations: async (): Promise<SimulationSummary[]> => {
    const { data } = await apiClient.get('/simulations/');
    return data;
  },

  // Get details of a specific simulation
  getSimulation: async (simulationId: number): Promise<SimulationResponse> => {
    const { data } = await apiClient.get(`/simulations/${simulationId}`);
    return data;
  },

  // Execute a trade (Buy/Sell) in a simulation
  executeTrade: async (simulationId: number, payload: TradeRequest): Promise<TradeResponse> => {
    const { data } = await apiClient.post(`/simulations/${simulationId}/trade`, payload);
    return data;
  },

  // Advance the simulated day by 1
  advanceDay: async (simulationId: number): Promise<SimulationResponse> => {
    const { data } = await apiClient.post(`/simulations/${simulationId}/advance-day`);
    return data;
  },

  pauseSimulation: async (simulationId: number): Promise<SimulationResponse> => {
    const { data } = await apiClient.post(`/simulations/${simulationId}/pause`);
    return data;
  },

  resumeSimulation: async (simulationId: number): Promise<SimulationResponse> => {
    const { data } = await apiClient.post(`/simulations/${simulationId}/resume`);
    return data;
  },

  updateTickConfig: async (simulationId: number, secondsPerDay: number): Promise<SimulationResponse> => {
    const { data } = await apiClient.patch(`/simulations/${simulationId}/tick-config`, { seconds_per_day: secondsPerDay });
    return data;
  },

  // End the simulation manually (triggers AI Analysis generation)
  endSimulation: async (simulationId: number): Promise<EndSimulationResponse> => {
    const { data } = await apiClient.post(`/simulations/${simulationId}/end`);
    return data;
  },

  // Get trade history for a simulation
  getTrades: async (simulationId: number): Promise<TradeResponse[]> => {
    const { data } = await apiClient.get(`/simulations/${simulationId}/trades`);
    return data;
  },

  // Poll for the generated AI Analysis document
  getAiAnalysis: async (simulationId: number): Promise<AIAnalysisResponse> => {
    const { data } = await apiClient.get(`/simulations/${simulationId}/analysis`);
    return data;
  },

  // Retry AI analysis generation
  retryAnalysis: async (simulationId: number): Promise<{ message: string; task_id: string }> => {
    const { data } = await apiClient.post(`/simulations/${simulationId}/analysis/retry`);
    return data;
  },
};
