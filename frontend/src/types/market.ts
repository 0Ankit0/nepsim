export interface StockListItem {
  symbol: string;
  company_name: string;
  sector: string;
  is_active: boolean;
  current_price?: number;
  previous_close?: number;
  change_pct?: number;
}

export interface StockDetail extends StockListItem {
  face_value: number;
  lot_size: number;
  tick_size: number;
}

export interface OHLCVPoint {
  date: string;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
  adjusted_close?: number;
}

export interface HistoryResponse {
  symbol: string;
  data: OHLCVPoint[];
}

export interface IndicatorResponse {
  symbol: string;
  indicator: string;
  period: number;
  data: Record<string, number | null>[];
}
