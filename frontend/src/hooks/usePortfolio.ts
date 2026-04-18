import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { portfolioApi, PortfolioItemCreate, PortfolioItemUpdate } from '@/api/portfolio';

export const usePortfolioItems = () => {
  return useQuery({
    queryKey: ['portfolio'],
    queryFn: () => portfolioApi.getItems(),
  });
};

export const usePortfolioAlerts = () => {
  return useQuery({
    queryKey: ['portfolio', 'alerts'],
    queryFn: () => portfolioApi.getAlerts(),
  });
};

export const useAddPortfolioItem = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: PortfolioItemCreate) => portfolioApi.addItem(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['portfolio'] });
    },
  });
};

export const useUpdatePortfolioItem = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: PortfolioItemUpdate }) =>
      portfolioApi.updateItem(id, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['portfolio'] });
    },
  });
};

export const useRemovePortfolioItem = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => portfolioApi.removeItem(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['portfolio'] });
    },
  });
};

export const useAnalyzeAllPortfolio = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => portfolioApi.analyzeAll(),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['portfolio', 'alerts'] });
    },
  });
};

export const useMarkPortfolioAlertRead = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => portfolioApi.markAlertRead(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['portfolio', 'alerts'] });
    },
  });
};
