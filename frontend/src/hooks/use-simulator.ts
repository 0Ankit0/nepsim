'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import type { Simulation, SimulationDetail, Trade } from '@/types';

export function useSimulations(params?: { skip?: number; limit?: number }) {
  return useQuery({
    queryKey: ['simulations', params],
    queryFn: async () => {
      // List all simulations (Admin can see all)
      const response = await apiClient.get<Simulation[]>('/simulations/', { params });
      return response.data;
    },
  });
}

export function useSimulationDetail(id: number) {
  return useQuery({
    queryKey: ['simulations', id],
    queryFn: async () => {
      const response = await apiClient.get<SimulationDetail>(`/simulations/${id}`);
      return response.data;
    },
    enabled: !!id,
  });
}

export function useDeleteSimulation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: number) => {
      await apiClient.delete(`/simulations/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
    },
  });
}

export function useSimulationTrades(id: number) {
  return useQuery({
    queryKey: ['simulations', id, 'trades'],
    queryFn: async () => {
      const response = await apiClient.get<Trade[]>(`/simulations/${id}/trades`);
      return response.data;
    },
    enabled: !!id,
  });
}

export function useAdvanceSimulationDay() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: number) => {
      await apiClient.post(`/simulations/${id}/advance-day`);
    },
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: ['simulations', id] });
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
    },
  });
}

export function useAIAnalysis(simulationId: number) {
    return useQuery({
        queryKey: ['simulations', simulationId, 'analysis'],
        queryFn: async () => {
            const response = await apiClient.get<any>(`/simulations/${simulationId}/analysis`);
            return response.data;
        },
        enabled: !!simulationId,

        retry: (failureCount, error: any) => {
            // Retry if 202 accepted (generating)
            if (error.response?.status === 202) return true;
            return failureCount < 3;
        },
        retryDelay: 3000,
    });
}

