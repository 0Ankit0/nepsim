import { apiClient } from '@/lib/api-client';

export interface AnalysisResult {
  symbol: string;
  signal: 'STRONG_BUY' | 'BUY' | 'HOLD' | 'SELL' | 'STRONG_SELL';
  overall_score: number;
  oscillator_score: number;
  trend_score: number;
  volume_score: number;
  volatility_score: number;
  key_signals: string[];
  current_price?: number;
  entry_price?: number;
  target_price?: number;
  stop_loss?: number;
  risk_reward_ratio?: number;
  analysis_date: string;
}

export interface TopStocksResponse {
  generated_at: string;
  count: number;
  results: AnalysisResult[];
}

export interface MarketOverview {
  date: string;
  total_analyzed: number;
  strong_buy: number;
  buy: number;
  hold: number;
  sell: number;
  strong_sell: number;
  bullish_pct: number;
  bearish_pct: number;
}

// ─── 360 View Types ──────────────────────────────────────────────────────────

export interface PricePoint {
  date: string;
  open?: number;
  high?: number;
  low?: number;
  close?: number;
  ltp?: number;
  vol?: number;
  vwap?: number;
  turnover?: number;
}

export interface IndicatorSignal {
  name: string;
  value?: number;
  signal: 'BULLISH' | 'BEARISH' | 'NEUTRAL';
  interpretation: string;
}

export interface PerformanceMetrics {
  week_1_pct?: number;
  month_1_pct?: number;
  month_3_pct?: number;
  month_6_pct?: number;
  year_1_pct?: number;
  ytd_pct?: number;
  max_drawdown_pct?: number;
  volatility_20d_annualized?: number;
  avg_volume_20d?: number;
}

export interface SimilarPeriod {
  start_date: string;
  end_date: string;
  similarity_score: number;
  forward_30d_return_pct?: number;
  outcome: 'BULLISH' | 'BEARISH' | 'NEUTRAL';
  description: string;
}

export interface TrendAnalysis {
  primary_trend: 'UPTREND' | 'DOWNTREND' | 'SIDEWAYS';
  trend_strength: 'STRONG' | 'MODERATE' | 'WEAK';
  ma_alignment: 'BULLISH' | 'BEARISH' | 'MIXED';
  support_level?: number;
  resistance_level?: number;
  price_vs_sma20?: 'ABOVE' | 'BELOW';
  price_vs_sma50?: 'ABOVE' | 'BELOW';
  price_vs_sma200?: 'ABOVE' | 'BELOW';
  golden_cross: boolean;
  death_cross: boolean;
  ichimoku_signal?: 'BULLISH' | 'BEARISH' | 'NEUTRAL';
  summary: string;
}

export interface Stock360View {
  symbol: string;
  analysis_date: string;
  current_price?: number;
  open_price?: number;
  high_price?: number;
  low_price?: number;
  volume?: number;
  turnover?: number;
  vwap?: number;
  week_52_high?: number;
  week_52_low?: number;
  change_pct?: number;
  prev_close?: number;
  signal: 'STRONG_BUY' | 'BUY' | 'HOLD' | 'SELL' | 'STRONG_SELL';
  overall_score: number;
  oscillator_score: number;
  trend_score: number;
  volume_score: number;
  volatility_score: number;
  key_signals: string[];
  entry_price?: number;
  target_price?: number;
  stop_loss?: number;
  risk_reward_ratio?: number;
  indicator_signals: IndicatorSignal[];
  performance: PerformanceMetrics;
  trend_analysis: TrendAnalysis;
  similar_periods: SimilarPeriod[];
  price_history: PricePoint[];
  ai_summary?: string;
}

export const marketAnalysisApi = {
  getTopStocks: async (limit: number = 20, signal?: string): Promise<TopStocksResponse> => {
    const params: Record<string, string | number> = { limit };
    if (signal && signal !== 'ALL') params.signal = signal;
    const { data } = await apiClient.get('/market-analysis/top-stocks', { params });
    return data;
  },

  getMarketOverview: async (): Promise<MarketOverview> => {
    const { data } = await apiClient.get('/market-analysis/market-overview');
    return data;
  },

  getStockAnalysis: async (symbol: string): Promise<AnalysisResult> => {
    const { data } = await apiClient.get(`/market-analysis/${symbol}`);
    return data;
  },

  getStock360View: async (symbol: string): Promise<Stock360View> => {
    const { data } = await apiClient.get(`/market-analysis/360/${symbol}`);
    return data;
  },
};
