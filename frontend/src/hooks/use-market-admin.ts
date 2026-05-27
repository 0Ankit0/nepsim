'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import type { StockDetail, StockListItem } from '@/types';

interface StockPayload {
  symbol: string;
  company_name: string;
  sector: string;
  lot_size: number;
  face_value: number;
  tick_size: number;
  is_active: boolean;
}

export function useStocks(params?: { active_only?: boolean }) {
  return useQuery({
    queryKey: ['market', 'stocks', params],
    queryFn: async () => {
      const response = await apiClient.get<StockListItem[]>('/market/stocks', { params });
      return response.data;
    },
  });
}

export function useCreateStock() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (payload: StockPayload) => {
      const response = await apiClient.post<StockDetail>('/market/stocks', payload);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['market', 'stocks'] });
    },
  });
}

export function useUpdateStock() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ symbol, data }: { symbol: string; data: Partial<StockPayload> }) => {
      const response = await apiClient.patch<StockDetail>(`/market/stocks/${encodeURIComponent(symbol)}`, data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['market', 'stocks'] });
    },
  });
}

export function useDeleteStock() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (symbol: string) => {
      await apiClient.delete(`/market/stocks/${encodeURIComponent(symbol)}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['market', 'stocks'] });
    },
  });
}

export function useUploadMarketData() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ symbol, file }: { symbol: string; file: File }) => {
      const formData = new FormData();
      formData.append('file', file);
      const response = await apiClient.post(`/market/stocks/${encodeURIComponent(symbol)}/upload-csv`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['market', 'stocks'] });
    },
  });
}