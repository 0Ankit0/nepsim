import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { watchlistApi, WatchlistItemCreate, WatchlistItemUpdate } from '@/api/watchlist';
import { hasStoredAuthTokens } from '@/lib/api-client';
import {
  addOfflineWatchlistItem,
  checkOfflineWatchlistSignals,
  getOfflineWatchlistAlerts,
  getOfflineWatchlistItems,
  markOfflineWatchlistAlertRead,
  removeOfflineWatchlistItem,
} from '@/lib/offline-data';

export const useWatchlistItems = () => {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['watchlist'],
    queryFn: () => (isAuthenticated ? watchlistApi.getItems() : Promise.resolve(getOfflineWatchlistItems())),
  });
};

export const useWatchlistAlerts = () => {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['watchlist', 'alerts'],
    queryFn: () => (isAuthenticated ? watchlistApi.getAlerts() : Promise.resolve(getOfflineWatchlistAlerts())),
  });
};

export const useAddWatchlistItem = () => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: (payload: WatchlistItemCreate) =>
      isAuthenticated ? watchlistApi.addItem(payload) : Promise.resolve(addOfflineWatchlistItem(payload)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist'] });
    },
  });
};

export const useUpdateWatchlistItem = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: WatchlistItemUpdate }) =>
      watchlistApi.updateItem(id, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist'] });
    },
  });
};

export const useRemoveWatchlistItem = () => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: (id: number) =>
      isAuthenticated ? watchlistApi.removeItem(id) : Promise.resolve(removeOfflineWatchlistItem(id)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist'] });
    },
  });
};

export const useCheckWatchlistSignals = () => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: () =>
      isAuthenticated ? watchlistApi.checkSignals() : Promise.resolve(checkOfflineWatchlistSignals()),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist', 'alerts'] });
    },
  });
};

export const useMarkWatchlistAlertRead = () => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: (id: number) =>
      isAuthenticated ? watchlistApi.markAlertRead(id) : Promise.resolve(markOfflineWatchlistAlertRead(id)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist', 'alerts'] });
    },
  });
};
