import { apiClient } from '@/lib/api-client';

export interface LatestQuoteResponse {
  symbol: string;
  date: string;
  ltp: number | null;
  open: number | null;
  high: number | null;
  low: number | null;
  close: number | null;
  prev_close: number | null;
  diff: number | null;
  diff_pct: number | null;
  vwap: number | null;
  vol: number | null;
  turnover: number | null;
  weeks_52_high: number | null;
  weeks_52_low: number | null;
}

export interface HistoricDataRow {
  id?: number | null;
  date: string;
  symbol?: string | null;
  conf?: number | null;
  open: number | null;
  high: number | null;
  low: number | null;
  close: number | null;
  ltp?: number | null;
  close_minus_ltp?: number | null;
  close_minus_ltp_pct?: number | null;
  vwap?: number | null;
  vol: number | null;
  prev_close?: number | null;
  turnover?: number | null;
  trans?: number | null;
  diff?: number | null;
  range?: number | null;
  diff_pct?: number | null;
  range_pct?: number | null;
  vwap_pct?: number | null;
  weeks_52_high?: number | null;
  weeks_52_low?: number | null;
}

export interface HistoricDataResponse {
  symbol: string;
  count: number;
  data: HistoricDataRow[];
}

export interface IndicatorRow {
  date: string;
  symbol?: string | null;
  rsi_14: number | null;
  macd_line: number | null;
  macd_signal: number | null;
  macd_hist: number | null;
  stoch_k: number | null;
  stoch_d: number | null;
  cci_20: number | null;
  williams_r: number | null;
  momentum_5: number | null;
  sma_5: number | null;
  sma_10: number | null;
  sma_20: number | null;
  sma_50: number | null;
  sma_200: number | null;
  ema_9: number | null;
  ema_12: number | null;
  ema_26: number | null;
  ema_200: number | null;
  adx_14: number | null;
  plus_di: number | null;
  minus_di: number | null;
  slope_20: number | null;
  acceleration: number | null;
  atr_14: number | null;
  bb_upper: number | null;
  bb_lower: number | null;
  ichimoku_conversion: number | null;
  ichimoku_base: number | null;
  ichimoku_span_a: number | null;
  ichimoku_span_b: number | null;
  chandelier_long: number | null;
  chandelier_short: number | null;
  obv: number | null;
  mfi_14: number | null;
  kvo: number | null;
}

export interface IndicatorsResponse {
  symbol: string;
  count: number;
  data: IndicatorRow[];
}

export interface IndexRow {
  date: string;
  index: string;
  current: number | null;
  point_change: number | null;
  pct_change: number | null;
  turnover: number | null;
}

export interface IndicesResponse {
  count: number;
  data: IndexRow[];
}

export interface LatestIndicesResponse {
  data: IndexRow[];
}

export interface AllLatestQuotesResponse {
  date: string | null;
  count: number;
  data: HistoricDataRow[];
}

export const marketApi = {
  // Get all symbols
  getSymbols: async (): Promise<string[]> => {
    const { data } = await apiClient.get('/market/nepse/symbols');
    return data;
  },

  // Get the latest quote for every symbol in one request
  getAllQuotes: async (): Promise<AllLatestQuotesResponse> => {
    const { data } = await apiClient.get('/market/nepse/all-quotes');
    return data;
  },

  // Get historic OHLCV data
  getHistory: async (symbol: string, startDate?: string, endDate?: string, limit: number = 500): Promise<HistoricDataResponse> => {
    const params: Record<string, string | number> = { limit };
    if (startDate) params.start_date = startDate;
    if (endDate) params.end_date = endDate;
    
    const { data } = await apiClient.get(`/market/nepse/${symbol}/history`, { params });
    return data;
  },

  // Get the latest market quote
  getQuote: async (symbol: string): Promise<LatestQuoteResponse> => {
    const { data } = await apiClient.get(`/market/nepse/${symbol}/quote`);
    return data;
  },

  // Get historic technical indicators
  getIndicators: async (symbol: string, startDate?: string, endDate?: string, limit: number = 500): Promise<IndicatorsResponse> => {
    const params: Record<string, string | number> = { limit };
    if (startDate) params.start_date = startDate;
    if (endDate) params.end_date = endDate;

    const { data } = await apiClient.get(`/market/nepse/${symbol}/indicators`, { params });
    return data;
  },

  // Get latest indicators
  getLatestIndicators: async (symbol: string): Promise<IndicatorRow> => {
    const { data } = await apiClient.get(`/market/nepse/${symbol}/indicators/latest`);
    return data;
  },

  // Get historic index data
  getIndices: async (indexName?: string, startDate?: string, endDate?: string, limit: number = 500): Promise<IndicesResponse> => {
    const params: Record<string, string | number> = { limit };
    if (indexName) params.index_name = indexName;
    if (startDate) params.start_date = startDate;
    if (endDate) params.end_date = endDate;

    const { data } = await apiClient.get(`/market/nepse/indices`, { params });
    return data;
  },

  // Get latest index data
  getLatestIndices: async (indexName?: string): Promise<LatestIndicesResponse> => {
    const params: Record<string, string> = {};
    if (indexName) params.index_name = indexName;

    const { data } = await apiClient.get(`/market/nepse/indices/latest`, { params });
    return data;
  },
};
