'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import type { StockListItem, StockDetail, HistoryResponse, IndicatorResponse } from '@/types';

export function useStocks(params?: { active_only?: boolean }) {
  return useQuery({
    queryKey: ['stocks', params],
    queryFn: async () => {
      const response = await apiClient.get<StockListItem[]>('/market/stocks', { params });
      return response.data;
    },
  });
}

export function useStockDetail(symbol: string) {
  return useQuery({
    queryKey: ['stocks', symbol],
    queryFn: async () => {
      const response = await apiClient.get<StockDetail>(`/market/stocks/${symbol}`);
      return response.data;
    },
    enabled: !!symbol,
  });
}

export function useStockHistory(symbol: string, params?: { start_date?: string; end_date?: string; limit?: number }) {
  return useQuery({
    queryKey: ['stocks', symbol, 'history', params],
    queryFn: async () => {
      const response = await apiClient.get<HistoryResponse>(`/market/stocks/${symbol}/history`, { params });
      return response.data;
    },
    enabled: !!symbol,
  });
}

export function useIndicator(symbol: string, params: { indicator: string; period?: number; fast?: number; slow?: number; signal?: number }) {
  return useQuery({
    queryKey: ['stocks', symbol, 'indicators', params],
    queryFn: async () => {
      const response = await apiClient.get<IndicatorResponse>(`/market/stocks/${symbol}/indicators`, { params });
      return response.data;
    },
    enabled: !!symbol && !!params.indicator,
  });
}

export function useUploadMarketData() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ symbol, file }: { symbol: string; file: File }) => {
      const formData = new FormData();
      formData.append('file', file);
      // Assuming there's an endpoint to upload CSV for a specific symbol or global
      // If global, we might not need the symbol.
      const response = await apiClient.post(`/market/stocks/${symbol}/upload`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response.data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['stocks', variables.symbol, 'history'] });
    },
  });
}

export function useCreateStock() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: Partial<StockDetail>) => {
      const response = await apiClient.post<StockDetail>('/market/stocks', data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stocks'] });
    },
  });
}

export function useUpdateStock() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ symbol, data }: { symbol: string; data: Partial<StockDetail> }) => {
      const response = await apiClient.patch<StockDetail>(`/market/stocks/${symbol}`, data);
      return response.data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['stocks', variables.symbol] });
      queryClient.invalidateQueries({ queryKey: ['stocks'] });
    },
  });
}

export function useDeleteStock() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (symbol: string) => {
      await apiClient.delete(`/market/stocks/${symbol}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stocks'] });
    },
  });
}
