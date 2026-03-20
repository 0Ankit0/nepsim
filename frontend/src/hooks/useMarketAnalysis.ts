import { useQuery } from '@tanstack/react-query';
import { marketAnalysisApi } from '@/api/marketAnalysis';

export const useTopStocks = (limit: number = 20, signal?: string) => {
  return useQuery({
    queryKey: ['market-analysis', 'top-stocks', limit, signal],
    queryFn: () => marketAnalysisApi.getTopStocks(limit, signal),
    staleTime: 5 * 60 * 1000,
  });
};

export const useMarketOverview = () => {
  return useQuery({
    queryKey: ['market-analysis', 'overview'],
    queryFn: () => marketAnalysisApi.getMarketOverview(),
    staleTime: 5 * 60 * 1000,
  });
};

export const useStockAnalysis = (symbol: string) => {
  return useQuery({
    queryKey: ['market-analysis', symbol],
    queryFn: () => marketAnalysisApi.getStockAnalysis(symbol),
    enabled: !!symbol,
  });
};

export const useStock360View = (symbol: string) => {
  return useQuery({
    queryKey: ['market-analysis', '360', symbol],
    queryFn: () => marketAnalysisApi.getStock360View(symbol),
    enabled: !!symbol,
    staleTime: 10 * 60 * 1000,
  });
};
