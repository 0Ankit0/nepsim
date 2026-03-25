import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { portfolioApi, PortfolioItemCreate, PortfolioItemUpdate } from '@/api/portfolio';
import { hasStoredAuthTokens } from '@/lib/api-client';
import {
  addOfflinePortfolioItem,
  analyzeOfflinePortfolio,
  getOfflinePortfolioAlerts,
  getOfflinePortfolioItems,
  markOfflinePortfolioAlertRead,
  removeOfflinePortfolioItem,
} from '@/lib/offline-data';

export const usePortfolioItems = () => {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['portfolio'],
    queryFn: () => (isAuthenticated ? portfolioApi.getItems() : Promise.resolve(getOfflinePortfolioItems())),
  });
};

export const usePortfolioAlerts = () => {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['portfolio', 'alerts'],
    queryFn: () => (isAuthenticated ? portfolioApi.getAlerts() : Promise.resolve(getOfflinePortfolioAlerts())),
  });
};

export const useAddPortfolioItem = () => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: (payload: PortfolioItemCreate) =>
      isAuthenticated ? portfolioApi.addItem(payload) : Promise.resolve(addOfflinePortfolioItem(payload)),
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
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: (id: number) =>
      isAuthenticated ? portfolioApi.removeItem(id) : Promise.resolve(removeOfflinePortfolioItem(id)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['portfolio'] });
    },
  });
};

export const useAnalyzeAllPortfolio = () => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: () =>
      isAuthenticated ? portfolioApi.analyzeAll() : Promise.resolve(analyzeOfflinePortfolio()),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['portfolio', 'alerts'] });
    },
  });
};

export const useMarkPortfolioAlertRead = () => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: (id: number) =>
      isAuthenticated ? portfolioApi.markAlertRead(id) : Promise.resolve(markOfflinePortfolioAlertRead(id)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['portfolio', 'alerts'] });
    },
  });
};
