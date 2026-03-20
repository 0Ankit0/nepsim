import { apiClient } from '@/lib/api-client';

export interface PortfolioItemResponse {
  id: number;
  symbol: string;
  quantity: number;
  avg_buy_price: number;
  buy_date: string;
  notes?: string;
  created_at: string;
  current_price?: number;
  current_value?: number;
  cost_basis: number;
  unrealised_pnl?: number;
  unrealised_pnl_pct?: number;
  weeks_52_high?: number;
  weeks_52_low?: number;
}

export interface PortfolioItemCreate {
  symbol: string;
  quantity: number;
  avg_buy_price: number;
  buy_date: string;
  notes?: string;
}

export interface PortfolioItemUpdate {
  symbol?: string;
  quantity?: number;
  avg_buy_price?: number;
  buy_date?: string;
  notes?: string;
}

export interface PortfolioAlertResponse {
  id: number;
  portfolio_item_id: number;
  symbol: string;
  alert_type: string; // SELL_STRONG | SELL_CONSIDER | WARNING | HOLD
  signal_score: number;
  analysis_summary: string;
  key_signals: string[];
  recommended_action: string;
  current_price?: number;
  created_at: string;
  is_read: boolean;
}

export const portfolioApi = {
  getItems: async (): Promise<PortfolioItemResponse[]> => {
    const { data } = await apiClient.get('/portfolio/');
    return data;
  },

  addItem: async (payload: PortfolioItemCreate): Promise<PortfolioItemResponse> => {
    const { data } = await apiClient.post('/portfolio/', payload);
    return data;
  },

  updateItem: async (id: number, payload: PortfolioItemUpdate): Promise<PortfolioItemResponse> => {
    const { data } = await apiClient.patch(`/portfolio/${id}`, payload);
    return data;
  },

  removeItem: async (id: number): Promise<void> => {
    await apiClient.delete(`/portfolio/${id}`);
  },

  analyzeAll: async (): Promise<PortfolioAlertResponse[]> => {
    const { data } = await apiClient.post('/portfolio/analyze-all');
    return data;
  },

  getAlerts: async (): Promise<PortfolioAlertResponse[]> => {
    const { data } = await apiClient.get('/portfolio/alerts');
    return data;
  },

  markAlertRead: async (id: number): Promise<PortfolioAlertResponse> => {
    const { data } = await apiClient.patch(`/portfolio/alerts/${id}/read`);
    return data;
  },
};
