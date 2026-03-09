'use client';

import { useState } from 'react';
import {
  useSimulations,
  useSimulationDetail,
  useDeleteSimulation,
  useAdvanceSimulationDay,
} from '@/hooks';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui';
import {
  Activity, Search, Eye, Trash2, Calendar, User, DollarSign, BarChart3, Clock, FastForward,
} from 'lucide-react';
import type { Simulation, SimulationDetail } from '@/types';

function SimulationRow({ 
  sim, 
  onView 
}: {
  sim: Simulation;
  onView: (sim: Simulation) => void;
}) {
  const isPositive = sim.total_pnl_pct >= 0;
  
  return (
    <tr className="border-b border-slate-800 hover:bg-slate-800/50 transition-colors">
      <td className="px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="h-8 w-8 rounded-full bg-slate-800 flex items-center justify-center border border-slate-700">
            <User className="h-4 w-4 text-indigo-400" />
          </div>
          <span className="text-sm font-medium text-white">UserID: {sim.user_id}</span>
        </div>
      </td>
      <td className="px-4 py-3">
        <span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium ${
          sim.status === 'active' ? 'bg-emerald-900/30 text-emerald-400' : 
          sim.status === 'paused' ? 'bg-amber-900/30 text-amber-400' : 'bg-slate-800 text-slate-400'
        }`}>
          <div className={`h-1.5 w-1.5 rounded-full ${sim.status === 'active' ? 'bg-emerald-400 animate-pulse' : 'bg-current'}`} />
          {sim.status.toUpperCase()}
        </span>
      </td>
      <td className="px-4 py-3 text-sm text-slate-300">
        <div className="flex flex-col">
          <span className="font-mono">Rs. {sim.current_balance.toLocaleString()}</span>
          <span className="text-xs text-slate-500 italic">Initial: Rs. {sim.initial_capital.toLocaleString()}</span>
        </div>
      </td>
      <td className="px-4 py-3 text-sm font-bold">
        <span className={isPositive ? 'text-emerald-400' : 'text-rose-400'}>
          {isPositive ? '+' : ''}{sim.total_pnl_pct.toFixed(2)}%
        </span>
      </td>
      <td className="px-4 py-3 text-sm text-slate-400">
        <div className="flex items-center gap-1.5 text-xs">
          <Calendar className="h-3 w-3" />
          {new Date(sim.created_at).toLocaleDateString()}
        </div>
      </td>
      <td className="px-4 py-3">
        <button
          onClick={() => onView(sim)}
          className="p-1.5 text-indigo-400 hover:text-indigo-300 rounded hover:bg-indigo-900/20"
          title="View Details"
        >
          <Eye className="h-4 w-4" />
        </button>
      </td>
    </tr>
  );
}

function SimulationDetailModal({ id, onClose }: { id: number; onClose: () => void }) {
  const { data: sim, isLoading } = useSimulationDetail(id);
  const advanceDay = useAdvanceSimulationDay();

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <Card className="w-full max-w-4xl bg-slate-900 border-slate-700 shadow-2xl max-h-[90vh] overflow-y-auto">
        <CardHeader className="border-b border-slate-800 pb-4 sticky top-0 bg-slate-900 z-10">
          <div className="flex items-center justify-between">
            <CardTitle className="text-white flex items-center gap-2 text-xl">
              <Activity className="h-5 w-5 text-indigo-400" />
              Simulation #{id} Details
            </CardTitle>
            <div className="flex items-center gap-2">
              {sim?.status === 'active' && (
                <Button 
                  variant="outline" 
                  size="sm" 
                  onClick={() => advanceDay.mutate(id)}
                  isLoading={advanceDay.isPending}
                  className="border-emerald-900/50 text-emerald-400 hover:bg-emerald-900/20"
                >
                  <FastForward className="h-3.5 w-3.5 mr-1.5" />
                  Advance Day
                </Button>
              )}
              <Button variant="outline" onClick={onClose} size="sm" className="border-slate-700 text-slate-300 hover:bg-slate-800">Close</Button>
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-6 space-y-8">
          {isLoading ? (
            <Skeleton className="h-64 w-full bg-slate-800" />
          ) : !sim ? (
            <p className="text-slate-500">Could not load simulation details.</p>
          ) : (
            <>
              {/* Stats Grid */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {[
                  { label: 'Current Balance', value: `Rs. ${sim.current_balance.toLocaleString()}`, icon: DollarSign, color: 'text-indigo-400' },
                  { label: 'Total P&L', value: `${sim.total_pnl_pct.toFixed(2)}%`, icon: BarChart3, color: sim.total_pnl_pct >= 0 ? 'text-emerald-400' : 'text-rose-400' },
                  { label: 'Start Date', value: sim.start_date, icon: Calendar, color: 'text-slate-400' },
                  { label: 'Sim Days Passed', value: '14 days', icon: Clock, color: 'text-slate-400' },
                ].map((stat) => (
                  <div key={stat.label} className="p-4 bg-slate-800/50 rounded-xl border border-slate-800">
                    <p className="text-xs text-slate-500 mb-1">{stat.label}</p>
                    <div className="flex items-center gap-2">
                      <stat.icon className={`h-4 w-4 ${stat.color}`} />
                      <span className="text-lg font-bold text-white">{stat.value}</span>
                    </div>
                  </div>
                ))}
              </div>

              {/* Portfolio & Trades */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div>
                  <h3 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4">Current Portfolio</h3>
                  <div className="bg-slate-950 rounded-lg border border-slate-800 overflow-hidden">
                    <table className="w-full text-left text-sm">
                      <thead className="bg-slate-900">
                        <tr>
                          <th className="px-4 py-2 text-slate-500">Symbol</th>
                          <th className="px-4 py-2 text-slate-500 text-right">Qty</th>
                          <th className="px-4 py-2 text-slate-500 text-right">Avg Price</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(sim.portfolio ?? []).length === 0 ? (
                          <tr><td colSpan={3} className="px-4 py-8 text-center text-slate-600 italic">No open positions</td></tr>
                        ) : (
                          sim.portfolio.map((p) => (
                            <tr key={p.symbol} className="border-t border-slate-900">
                              <td className="px-4 py-2 font-bold text-white">{p.symbol}</td>
                              <td className="px-4 py-2 text-right text-slate-300">{p.quantity}</td>
                              <td className="px-4 py-2 text-right text-indigo-300">Rs. {p.average_price.toFixed(1)}</td>
                            </tr>
                          ))
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>

                <div>
                  <h3 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4">Trade History</h3>
                  <div className="bg-slate-950 rounded-lg border border-slate-800 overflow-hidden max-h-[300px] overflow-y-auto">
                    <table className="w-full text-left text-sm">
                      <thead className="bg-slate-900">
                        <tr>
                          <th className="px-4 py-2 text-slate-500">Symbol</th>
                          <th className="px-4 py-2 text-slate-500">Type</th>
                          <th className="px-4 py-2 text-slate-500 text-right">Price</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(sim.trades ?? []).length === 0 ? (
                          <tr><td colSpan={3} className="px-4 py-8 text-center text-slate-600 italic">No trades executed</td></tr>
                        ) : (
                          sim.trades.map((t) => (
                            <tr key={t.id} className="border-t border-slate-900 hover:bg-slate-900/50">
                              <td className="px-4 py-2 font-bold text-white">{t.symbol}</td>
                              <td className="px-4 py-2">
                                <span className={`text-xs font-bold uppercase ${t.trade_type === 'buy' ? 'text-emerald-400' : 'text-rose-400'}`}>
                                  {t.trade_type}
                                </span>
                              </td>
                              <td className="px-4 py-2 text-right text-slate-300">Rs. {t.price.toFixed(1)}</td>
                            </tr>
                          ))
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

export default function SimulatorAdminPage() {
  const { data: simulations, isLoading } = useSimulations({ limit: 50 });
  const [search, setSearch] = useState('');
  const [selectedSimId, setSelectedSimId] = useState<number | null>(null);

  const filteredSims = (simulations ?? []).filter(s => 
    s.id.toString().includes(search) || 
    s.user_id.toString().includes(search)
  ).sort((a, b) => b.id - a.id);

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            <Activity className="h-6 w-6 text-indigo-400" />
            Simulation Management
          </h1>
          <p className="text-slate-400">Monitor active and historical simulation sessions</p>
        </div>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
        <Input
          placeholder="Search by Simulation ID or User ID..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-10 bg-slate-900 border-slate-700 text-white focus:ring-indigo-500 w-full"
        />
      </div>

      <Card className="bg-slate-900 border-slate-700">
        <CardContent className="p-0 overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-950/50 border-b border-slate-800">
              <tr>
                <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">User</th>
                <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Status</th>
                <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Balance</th>
                <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">P&L</th>
                <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Started</th>
                <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="p-8">
                    <Skeleton className="h-10 w-full bg-slate-800" />
                  </td>
                </tr>
              ) : filteredSims.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-slate-500">
                    No simulations found.
                  </td>
                </tr>
              ) : (
                filteredSims.map((sim) => (
                  <SimulationRow
                    key={sim.id}
                    sim={sim}
                    onView={(s) => setSelectedSimId(s.id)}
                  />
                ))
              )}
            </tbody>
          </table>
        </CardContent>
      </Card>

      {selectedSimId && (
        <SimulationDetailModal 
          id={selectedSimId} 
          onClose={() => setSelectedSimId(null)} 
        />
      )}
    </div>
  );
}
