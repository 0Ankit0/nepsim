import { apiClient } from '@/lib/api-client';

export interface WatchlistItemResponse {
  id: number;
  symbol: string;
  notes?: string;
  target_price?: number;
  stop_loss?: number;
  created_at: string;
  current_price?: number;
  diff_pct?: number;
  weeks_52_high?: number;
  weeks_52_low?: number;
}

export interface WatchlistItemCreate {
  symbol: string;
  notes?: string;
  target_price?: number;
  stop_loss?: number;
}

export interface WatchlistItemUpdate {
  notes?: string;
  target_price?: number;
  stop_loss?: number;
}

export interface WatchlistAlertResponse {
  id: number;
  watchlist_item_id: number;
  symbol: string;
  alert_type: string; // BUY_STRONG | BUY_CONSIDER | ACCUMULATE | WAIT
  signal_score: number;
  analysis_summary: string;
  key_signals: string[];
  entry_price?: number;
  target_price?: number;
  stop_loss_price?: number;
  created_at: string;
  is_read: boolean;
}

export const watchlistApi = {
  getItems: async (): Promise<WatchlistItemResponse[]> => {
    const { data } = await apiClient.get('/watchlist/');
    return data;
  },

  addItem: async (payload: WatchlistItemCreate): Promise<WatchlistItemResponse> => {
    const { data } = await apiClient.post('/watchlist/', payload);
    return data;
  },

  updateItem: async (id: number, payload: WatchlistItemUpdate): Promise<WatchlistItemResponse> => {
    const { data } = await apiClient.patch(`/watchlist/${id}`, payload);
    return data;
  },

  removeItem: async (id: number): Promise<void> => {
    await apiClient.delete(`/watchlist/${id}`);
  },

  checkSignals: async (): Promise<WatchlistAlertResponse[]> => {
    const { data } = await apiClient.post('/watchlist/check-signals');
    return data;
  },

  getAlerts: async (): Promise<WatchlistAlertResponse[]> => {
    const { data } = await apiClient.get('/watchlist/alerts');
    return data;
  },

  markAlertRead: async (id: number): Promise<WatchlistAlertResponse> => {
    const { data } = await apiClient.patch(`/watchlist/alerts/${id}/read`);
    return data;
  },
};
