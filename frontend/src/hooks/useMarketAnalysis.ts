import { useQuery } from '@tanstack/react-query';
import { marketAnalysisApi } from '@/api/marketAnalysis';

export const useTopStocks = (limit: number = 20, signal?: string, asOfDate?: string) => {
  return useQuery({
    queryKey: ['market-analysis', 'top-stocks', limit, signal, asOfDate],
    queryFn: () => marketAnalysisApi.getTopStocks(limit, signal, asOfDate),
    staleTime: 5 * 60 * 1000,
  });
};

export const useMarketOverview = (asOfDate?: string) => {
  return useQuery({
    queryKey: ['market-analysis', 'overview', asOfDate],
    queryFn: () => marketAnalysisApi.getMarketOverview(asOfDate),
    staleTime: 5 * 60 * 1000,
  });
};

export const useStockAnalysis = (symbol: string, asOfDate?: string) => {
  return useQuery({
    queryKey: ['market-analysis', symbol, asOfDate],
    queryFn: () => marketAnalysisApi.getStockAnalysis(symbol, asOfDate),
    enabled: !!symbol,
  });
};

export const useStock360View = (symbol: string, asOfDate?: string) => {
  return useQuery({
    queryKey: ['market-analysis', '360', symbol, asOfDate],
    queryFn: () => marketAnalysisApi.getStock360View(symbol, asOfDate),
    enabled: !!symbol,
    staleTime: 10 * 60 * 1000,
  });
};
