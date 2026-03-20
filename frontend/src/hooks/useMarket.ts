import { useQuery } from '@tanstack/react-query';
import { marketApi } from '@/api/market';

export const useSymbols = () => {
  return useQuery({
    queryKey: ['market', 'symbols'],
    queryFn: () => marketApi.getSymbols(),
    staleTime: 24 * 60 * 60 * 1000, // Symbols list rarely changes
  });
};

export const useAllNepseQuotes = () => {
  return useQuery({
    queryKey: ['market', 'all-quotes'],
    queryFn: () => marketApi.getAllQuotes(),
    staleTime: 5 * 60 * 1000,
    refetchInterval: 5 * 60 * 1000,
  });
};

export const useNepseQuote = (symbol: string) => {
  return useQuery({
    queryKey: ['market', 'quote', symbol],
    queryFn: () => marketApi.getQuote(symbol),
    enabled: !!symbol,
    refetchInterval: 5 * 60 * 1000, // Refetch every 5 minutes
  });
};

export const useNepseHistory = (symbol: string, startDate?: string, endDate?: string, limit?: number) => {
  return useQuery({
    queryKey: ['market', 'history', symbol, startDate, endDate, limit],
    queryFn: () => marketApi.getHistory(symbol, startDate, endDate, limit ?? 500),
    enabled: !!symbol,
  });
};

export const useNepseIndicators = (symbol: string, startDate?: string, endDate?: string) => {
  return useQuery({
    queryKey: ['market', 'indicators', symbol, startDate, endDate],
    queryFn: () => marketApi.getIndicators(symbol, startDate, endDate),
    enabled: !!symbol,
  });
};

export const useNepseLatestIndicators = (symbol: string) => {
  return useQuery({
    queryKey: ['market', 'indicators', 'latest', symbol],
    queryFn: () => marketApi.getLatestIndicators(symbol),
    enabled: !!symbol,
  });
};

export const useNepseLatestIndices = () => {
  return useQuery({
    queryKey: ['market', 'indices', 'latest'],
    queryFn: () => marketApi.getLatestIndices(),
    refetchInterval: 5 * 60 * 1000,
  });
};
