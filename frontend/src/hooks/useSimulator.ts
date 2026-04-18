import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { simulatorApi, TradeRequest } from '@/api/simulator';

// Queries
export const useSimulations = () => {
  return useQuery({
    queryKey: ['simulations'],
    queryFn: () => simulatorApi.listSimulations(),
  });
};

export const useSimulation = (id?: number) => {
  return useQuery({
    queryKey: ['simulation', id],
    queryFn: () => simulatorApi.getSimulation(id!),
    enabled: !!id,
  });
};

export const useSimulationAnalysis = (id?: number) => {
  return useQuery({
    queryKey: ['simulation', id, 'analysis'],
    queryFn: () => simulatorApi.getAiAnalysis(id!),
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
  return useMutation({
    mutationFn: ({ capital, name, startDate }: { capital: number; name?: string; startDate?: string }) =>
      simulatorApi.createSimulation(capital, name, startDate),
    onSuccess: (newSim) => {
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
      queryClient.setQueryData(['simulation', newSim.id], newSim);
    },
  });
};

export const useExecuteTrade = (id: number) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (trade: TradeRequest) => simulatorApi.executeTrade(id, trade),
    onSuccess: () => {
      // Refresh the simulation state to get new cash flow/portfolio limits
      queryClient.invalidateQueries({ queryKey: ['simulation', id] });
    },
  });
};

export const useAdvanceDay = (id: number) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => simulatorApi.advanceDay(id),
    onSuccess: (updatedSim) => {
      queryClient.setQueryData(['simulation', id], updatedSim);
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
    },
  });
};

export const usePauseSimulation = (id: number) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => simulatorApi.pauseSimulation(id),
    onSuccess: (updatedSim) => {
      queryClient.setQueryData(['simulation', id], updatedSim);
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
    },
  });
};

export const useResumeSimulation = (id: number) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => simulatorApi.resumeSimulation(id),
    onSuccess: (updatedSim) => {
      queryClient.setQueryData(['simulation', id], updatedSim);
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
    },
  });
};

export const useUpdateTickConfig = (id: number) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (secondsPerDay: number) => simulatorApi.updateTickConfig(id, secondsPerDay),
    onSuccess: (updatedSim) => {
      queryClient.setQueryData(['simulation', id], updatedSim);
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
    },
  });
};

export const useEndSimulation = (id: number) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => simulatorApi.endSimulation(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['simulation', id] });
      queryClient.invalidateQueries({ queryKey: ['simulations'] });
    },
  });
};
