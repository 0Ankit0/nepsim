'use client';

import { useQuery } from '@tanstack/react-query';
import { marketApi } from '@/api/market';
import type { HistoricDataRow, IndicatorRow, LatestQuoteResponse, AllLatestQuotesResponse } from '@/api/market';

// Re-export new Supabase-backed hooks (preferred for all market data)
export { useSymbols, useAllNepseQuotes, useNepseQuote, useNepseHistory, useNepseIndicators, useNepseLatestIndicators, useNepseLatestIndices } from '@/hooks/useMarket';

// Admin-only: stock metadata CRUD (local DB)
export function useStockHistory(symbol: string, params?: { start_date?: string; end_date?: string; limit?: number }) {
  return useQuery({
    queryKey: ['market', 'history', symbol, params],
    queryFn: () => marketApi.getHistory(symbol, params?.start_date, params?.end_date, params?.limit),
    enabled: !!symbol,
  });
}

export function useStockQuote(symbol: string) {
  return useQuery({
    queryKey: ['market', 'quote', symbol],
    queryFn: () => marketApi.getQuote(symbol),
    enabled: !!symbol,
    refetchInterval: 5 * 60 * 1000,
  });
}
