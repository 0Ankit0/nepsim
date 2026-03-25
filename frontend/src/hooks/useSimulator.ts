import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { simulatorApi, TradeRequest } from '@/api/simulator';
import { hasStoredAuthTokens } from '@/lib/api-client';
import {
  advanceOfflineSimulationDay,
  createOfflineSimulation,
  endOfflineSimulation,
  executeOfflineTrade,
  getOfflineSimulation,
  getOfflineSimulationAnalysis,
  listOfflineSimulations,
} from '@/lib/offline-data';

// Queries
export const useSimulations = () => {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['simulations'],
    queryFn: () => (isAuthenticated ? simulatorApi.listSimulations() : Promise.resolve(listOfflineSimulations())),
  });
};

export const useSimulation = (id?: number) => {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['simulation', id],
    queryFn: () =>
      isAuthenticated ? simulatorApi.getSimulation(id!) : Promise.resolve(getOfflineSimulation(id!)!),
    enabled: !!id,
  });
};

export const useSimulationAnalysis = (id?: number) => {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['simulation', id, 'analysis'],
    queryFn: () =>
      isAuthenticated
        ? simulatorApi.getAiAnalysis(id!)
        : Promise.resolve(getOfflineSimulationAnalysis(id!)),
    enabled: !!id,
    refetchInterval: (query) => {
      // Poll every 3 seconds if pending/in_progress
      const status = query.state.data?.status;
      if (status === 'pending' || status === 'in_progress') return 3000;
      return false;
    },
  });
};

// Mutations
export const useCreateSimulation = () => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: ({ capital, name }: { capital: number; name?: string }) =>
      isAuthenticated
        ? simulatorApi.createSimulation(capital, name)
        : Promise.resolve(createOfflineSimulation(capital, name)),
    onSuccess: (newSim) => {
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
      queryClient.setQueryData(['simulation', newSim.id], newSim);
    },
  });
};

export const useExecuteTrade = (id: number) => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: (trade: TradeRequest) =>
      isAuthenticated ? simulatorApi.executeTrade(id, trade) : Promise.resolve(executeOfflineTrade(id, trade)),
    onSuccess: () => {
      // Refresh the simulation state to get new cash flow/portfolio limits
      queryClient.invalidateQueries({ queryKey: ['simulation', id] });
    },
  });
};

export const useAdvanceDay = (id: number) => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: () =>
      isAuthenticated ? simulatorApi.advanceDay(id) : Promise.resolve(advanceOfflineSimulationDay(id)),
    onSuccess: (updatedSim) => {
      queryClient.setQueryData(['simulation', id], updatedSim);
    },
  });
};

export const useEndSimulation = (id: number) => {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: () =>
      isAuthenticated ? simulatorApi.endSimulation(id) : Promise.resolve(endOfflineSimulation(id)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['simulation', id] });
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
    },
  });
};
