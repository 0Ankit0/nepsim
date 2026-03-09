'use client';

import { useState } from 'react';
import { useSimulations, useDeleteSimulation } from '@/hooks';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui';
import { 
  Activity, Play, Plus, Clock, TrendingUp, 
  Trash2, ArrowRight, Wallet, History, AlertCircle 
} from 'lucide-react';
import Link from 'next/link';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';

export default function SimulatorPage() {
  const [initialCapital, setInitialCapital] = useState('1000000');
  const { data: simulations, isLoading } = useSimulations({ limit: 20 });
  const queryClient = useQueryClient();
  
  const startSimulation = useMutation({
    mutationFn: async (capital: number) => {
        const response = await apiClient.post('/simulator/simulations/', { initial_capital: capital });
        return response.data;
    },
    onSuccess: () => {
        queryClient.invalidateQueries({ queryKey: ['simulations'] });
    }
  });

  const activeSimulations = (simulations ?? []).filter(s => s.status === 'active');
  const pastSimulations = (simulations ?? []).filter(s => s.status !== 'active');

  const handleStart = () => {
    const capital = parseInt(initialCapital);
    if (isNaN(capital) || capital < 10000) return;
    startSimulation.mutate(capital);
  };

  return (
    <div className="max-w-6xl mx-auto space-y-8">
      <div className="text-center space-y-2">
        <h1 className="text-3xl font-bold text-gray-900">Trading Simulator</h1>
        <p className="text-gray-500 max-w-2xl mx-auto">
          Practice your trading strategies in a risk-free environment using historical NEPSE data. 
          Get AI insights on your performance and improve your decision making.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Start New Simulation */}
        <Card className="lg:col-span-1 border-indigo-100 shadow-sm">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Plus className="h-5 w-5 text-indigo-600" />
              New Simulation
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Initial Capital (NPR)</label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 font-medium">Rs.</span>
                <Input
                  type="number"
                  value={initialCapital}
                  onChange={(e) => setInitialCapital(e.target.value)}
                  className="pl-10 font-mono"
                  min="10000"
                />
              </div>
              <p className="text-[10px] text-gray-500">Minimum recommended: Rs. 100,000</p>
            </div>
            
            <Button 
                onClick={handleStart} 
                disabled={startSimulation.isPending || activeSimulations.length >= 3}
                className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-6"
            >
                {startSimulation.isPending ? 'Starting...' : 'Start Simulation'}
            </Button>
            
            {activeSimulations.length >= 3 && (
                <div className="p-3 bg-amber-50 rounded-lg border border-amber-100 flex gap-2">
                    <AlertCircle className="h-4 w-4 text-amber-600 flex-shrink-0 mt-0.5" />
                    <p className="text-xs text-amber-800">
                        You have reached the maximum number of active simulations. Finish or delete one to start a new one.
                    </p>
                </div>
            )}
          </CardContent>
        </Card>

        {/* Active & Past Simulations */}
        <div className="lg:col-span-2 space-y-6">
          <section className="space-y-4">
            <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
              <Clock className="h-5 w-5 text-emerald-600" />
              Active Sessions
            </h2>
            {isLoading ? (
                <Skeleton className="h-32 w-full" />
            ) : activeSimulations.length === 0 ? (
                <div className="p-8 border-2 border-dashed border-gray-200 rounded-xl text-center text-gray-500">
                    No active simulations. Start one to begin trading.
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {activeSimulations.map(sim => (
                        <Card key={sim.id} className="border-emerald-100 hover:border-emerald-500 transition-colors group">
                            <CardContent className="p-4">
                                <div className="flex justify-between items-start mb-4">
                                    <div className="h-10 w-10 bg-emerald-50 rounded-lg flex items-center justify-center">
                                        <Activity className="h-5 w-5 text-emerald-600" />
                                    </div>
                                    <span className="bg-emerald-100 text-emerald-700 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase">
                                        Active
                                    </span>
                                </div>
                                <div className="space-y-4">
                                    <div>
                                        <p className="text-xs text-gray-500">Current Balance</p>
                                        <p className="text-xl font-bold text-gray-900">Rs. {sim.current_balance.toLocaleString()}</p>
                                    </div>
                                    <div className="flex justify-between items-center bg-gray-50 p-2 rounded-lg">
                                        <div className="text-center flex-1 border-r border-gray-200">
                                            <p className="text-[10px] text-gray-500 uppercase">P&L</p>
                                            <p className={`text-sm font-bold ${sim.total_pnl_pct >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                                                {sim.total_pnl_pct >= 0 ? '+' : ''}{sim.total_pnl_pct.toFixed(2)}%
                                            </p>
                                        </div>
                                        <div className="text-center flex-1">
                                            <p className="text-[10px] text-gray-500 uppercase">Day</p>
                                            <p className="text-sm font-bold text-gray-900">14</p>
                                        </div>
                                    </div>
                                    <Link href={`/simulator/${sim.id}`}>
                                        <Button className="w-full bg-gray-900 hover:bg-black text-white gap-2">
                                            Continue <ArrowRight className="h-4 w-4" />
                                        </Button>
                                    </Link>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}
          </section>

          <section className="space-y-4">
            <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
              <History className="h-5 w-5 text-indigo-600" />
              Recent History
            </h2>
            <Card className="overflow-hidden border-gray-200">
                <CardContent className="p-0">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-gray-50 border-b border-gray-100">
                            <tr>
                                <th className="px-4 py-3 font-semibold text-gray-500">ID</th>
                                <th className="px-4 py-3 font-semibold text-gray-500">Status</th>
                                <th className="px-4 py-3 font-semibold text-gray-500 text-right">Final P&L</th>
                                <th className="px-4 py-3 font-semibold text-gray-500">Date</th>
                                <th className="px-4 py-3 font-semibold text-gray-500 text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {pastSimulations.length === 0 ? (
                                <tr>
                                    <td colSpan={5} className="px-4 py-8 text-center text-gray-400 italic">No past simulations found</td>
                                </tr>
                            ) : (
                                pastSimulations.map(sim => (
                                    <tr key={sim.id} className="hover:bg-gray-50/50">
                                        <td className="px-4 py-3 font-medium text-gray-700">#{sim.id}</td>
                                        <td className="px-4 py-3">
                                            <span className="text-[10px] font-bold uppercase text-gray-500">{sim.status}</span>
                                        </td>
                                        <td className="px-4 py-3 text-right">
                                            <span className={`font-bold ${sim.total_pnl_pct >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                                                {sim.total_pnl_pct >= 0 ? '+' : ''}{sim.total_pnl_pct.toFixed(2)}%
                                            </span>
                                        </td>
                                        <td className="px-4 py-3 text-gray-500 text-xs">
                                            {new Date(sim.created_at).toLocaleDateString()}
                                        </td>
                                        <td className="px-4 py-3 text-center">
                                            <Link href={`/simulator/${sim.id}`}>
                                                <Button variant="ghost" size="sm" className="text-indigo-600">Details</Button>
                                            </Link>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </CardContent>
            </Card>
          </section>
        </div>
      </div>
    </div>
  );
}
