import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { watchlistApi, WatchlistItemCreate, WatchlistItemUpdate } from '@/api/watchlist';

export const useWatchlistItems = () => {
  return useQuery({
    queryKey: ['watchlist'],
    queryFn: () => watchlistApi.getItems(),
  });
};

export const useWatchlistAlerts = () => {
  return useQuery({
    queryKey: ['watchlist', 'alerts'],
    queryFn: () => watchlistApi.getAlerts(),
  });
};

export const useAddWatchlistItem = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: WatchlistItemCreate) => watchlistApi.addItem(payload),
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
  return useMutation({
    mutationFn: (id: number) => watchlistApi.removeItem(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist'] });
    },
  });
};

export const useCheckWatchlistSignals = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => watchlistApi.checkSignals(),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist', 'alerts'] });
    },
  });
};

export const useMarkWatchlistAlertRead = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => watchlistApi.markAlertRead(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist', 'alerts'] });
    },
  });
};
