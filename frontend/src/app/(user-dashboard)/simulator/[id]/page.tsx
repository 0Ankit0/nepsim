'use client';

import { 
  useSimulation, 
  useAdvanceDay, 
  useEndSimulation,
  usePauseSimulation,
  useResumeSimulation,
  useUpdateTickConfig,
} from '@/hooks/useSimulator';
import { useSymbols } from '@/hooks/useMarket';
import { useTopStocks } from '@/hooks/useMarketAnalysis';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui';
import { 
  Activity, BarChart3, Calendar, 
  DollarSign, FastForward, Clock,
  StopCircle, TrendingUp, TrendingDown,
  ArrowUpRight, Wallet, ArrowRight, Pause, Play, Sparkles
} from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { use, useEffect, useMemo, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { simulatorApi } from '@/api/simulator';

export default function TradingDashboardPage({ params }: { params: Promise<{ id: string }> }) {
  const { id: rawId } = use(params);
  const id = parseInt(rawId);
  const { data: sim, isLoading } = useSimulation(id);
  const { data: symbols } = useSymbols();
    const simulationDate = sim?.current_sim_date?.split('T')[0];
    const { data: topStocks } = useTopStocks(3, 'BUY', simulationDate);
  
  const advanceDay = useAdvanceDay(id);
  const endSimulation = useEndSimulation(id);
  const pauseSimulation = usePauseSimulation(id);
  const resumeSimulation = useResumeSimulation(id);
  const updateTickConfig = useUpdateTickConfig(id);
  const router = useRouter();
  const queryClient = useQueryClient();
  const [tickSeconds, setTickSeconds] = useState('10');

  const suggestions = useMemo(
    () => (topStocks?.results ?? []).filter((stock) => stock.symbol).slice(0, 3),
    [topStocks?.results]
  );

  useEffect(() => {
    if (!sim || (sim.status !== 'ended' && sim.status !== 'analysing' && sim.status !== 'analysis_ready')) {
      return;
    }

    queryClient.prefetchQuery({
      queryKey: ['simulation', id, 'analysis'],
      queryFn: () => simulatorApi.getAiAnalysis(id),
      retry: false,
    }).catch(() => {
      // Best-effort warmup so the analysis page can open with work already in flight.
    });
  }, [id, queryClient, sim]);

  useEffect(() => {
    if (!sim) {
      return;
    }

    setTickSeconds(String(sim.seconds_per_day));
  }, [sim]);

  useEffect(() => {
    if (!sim || sim.status !== 'active') {
      return;
    }

    const interval = window.setInterval(() => {
      advanceDay.mutate();
    }, Math.max(sim.seconds_per_day, 1) * 1000);

    return () => window.clearInterval(interval);
  }, [advanceDay, sim]);

  const handleEndSimulation = () => {
    if(confirm('Are you sure you want to end this simulation? You will receive AI analysis of your performance.')) {
        endSimulation.mutate(undefined, {
            onSuccess: () => {
                router.push(`/simulator/${id}/analysis`);
            }
        });
    }
  };

  if (isLoading) return <Skeleton className="h-[80vh] w-full" />;
  if (!sim) return <div className="text-center py-20 text-gray-500">Simulation not found.</div>;

  const isEnded = sim.status === 'ended' || sim.status === 'analysing' || sim.status === 'analysis_ready';
  const isPaused = sim.status === 'paused';
  const totalValue = sim.total_value ?? sim.cash_balance;
  const totalPnl = sim.total_pnl_pct ?? 0;
  const isPositive = totalPnl >= 0;

  const handleTickDurationSave = () => {
    const seconds = Number.parseInt(tickSeconds, 10);
    if (!Number.isFinite(seconds) || seconds < 1) {
      window.alert('Enter a valid tick duration in seconds.');
      return;
    }

    updateTickConfig.mutate(seconds);
  };

  return (
    <div className="space-y-8 pb-10">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className={`h-2 w-2 rounded-full ${isEnded ? 'bg-gray-400' : 'bg-emerald-500 animate-pulse'}`} />
            <span className="text-[10px] font-bold uppercase tracking-wider text-gray-500">
                Simulation #{id} • {sim.status}
            </span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900">{sim.name || 'Trading Dashboard'}</h1>
        </div>
        {isEnded && (
          <Link href={`/simulator/${id}/analysis`}>
            <Button className="bg-indigo-600 hover:bg-indigo-700 text-white font-bold">
              View AI Analysis
            </Button>
          </Link>
        )}
        {!isEnded && (
          <div className="flex items-center gap-3">
            <Button
              variant="outline"
              className="border-slate-200 text-slate-700 hover:bg-slate-50"
              onClick={() => (isPaused ? resumeSimulation.mutate() : pauseSimulation.mutate())}
              disabled={pauseSimulation.isPending || resumeSimulation.isPending}
            >
              {isPaused ? <Play className="h-4 w-4 mr-2" /> : <Pause className="h-4 w-4 mr-2" />}
              {isPaused ? 'Resume' : 'Pause'}
            </Button>
            <Button 
              variant="outline" 
              className="border-rose-200 text-rose-600 hover:bg-rose-50"
              onClick={handleEndSimulation}
              disabled={endSimulation.isPending}
            >
              <StopCircle className="h-4 w-4 mr-2" />
              {endSimulation.isPending ? 'Ending...' : 'End Simulation'}
            </Button>
            <Button 
              className="bg-indigo-600 hover:bg-indigo-700 text-white font-bold"
              onClick={() => advanceDay.mutate()}
              disabled={advanceDay.isPending}
            >
              {advanceDay.isPending ? <Clock className="h-4 w-4 animate-spin mr-2" /> : <FastForward className="h-4 w-4 mr-2" />}
              Advance Day
            </Button>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {[
          { label: 'Total Portfolio Value', value: `Rs. ${totalValue.toLocaleString()}`, icon: Wallet, color: 'text-indigo-600', bg: 'bg-indigo-50' },
          { label: 'Total P&L', value: `${totalPnl.toFixed(2)}%`, icon: isPositive ? TrendingUp : TrendingDown, color: isPositive ? 'text-emerald-600' : 'text-rose-600', bg: isPositive ? 'bg-emerald-50' : 'bg-rose-50' },
          { label: 'Cash Balance', value: `Rs. ${sim.cash_balance.toLocaleString()}`, icon: DollarSign, color: 'text-blue-600', bg: 'bg-blue-50' },
          { label: 'Simulation Date', value: new Date(sim.current_sim_date).toLocaleDateString(), icon: Calendar, color: 'text-amber-600', bg: 'bg-amber-50' },
        ].map((stat) => (
          <Card key={stat.label} className="border-none shadow-sm bg-white">
            <CardContent className="p-6">
                <div className="flex items-center gap-3 mb-2">
                    <div className={`p-2 rounded-lg ${stat.bg}`}>
                        <stat.icon className={`h-5 w-5 ${stat.color}`} />
                    </div>
                    <p className="text-xs font-medium text-gray-500">{stat.label}</p>
                </div>
                <p className="text-xl font-bold text-gray-900">{stat.value}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {!isEnded && (
        <Card className="border-gray-100 shadow-sm">
          <CardContent className="flex flex-col gap-4 p-5 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <p className="text-xs font-bold uppercase tracking-wider text-gray-500">Tick Controls</p>
              <p className="mt-1 text-sm text-gray-600">
                {isPaused
                  ? 'Simulation is paused. You can review ideas and resume whenever you are ready.'
                  : `The simulator advances one trading day every ${sim.seconds_per_day} seconds.`}
              </p>
            </div>
            <div className="flex flex-col gap-3 sm:flex-row sm:items-end">
              <div>
                <label htmlFor="tick-seconds" className="mb-1 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                  Seconds per tick
                </label>
                <input
                  id="tick-seconds"
                  type="number"
                  min="1"
                  max="300"
                  value={tickSeconds}
                  onChange={(event) => setTickSeconds(event.target.value)}
                  className="w-32 rounded-lg border border-gray-200 px-3 py-2 text-sm text-gray-900 outline-none focus:border-indigo-500"
                />
              </div>
              <Button variant="outline" onClick={handleTickDurationSave} disabled={updateTickConfig.isPending}>
                Save Tick Duration
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-8">
            <section className="space-y-4">
                <div className="flex items-center justify-between">
                    <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
                        <BarChart3 className="h-5 w-5 text-indigo-600" />
                        Current Holdings
                    </h2>
                    <Link href="/market">
                        <Button variant="ghost" size="sm" className="text-indigo-600">
                            Search Stocks <ArrowUpRight className="h-3.5 w-3.5 ml-1" />
                        </Button>
                    </Link>
                </div>
                <Card className="border-gray-100 overflow-hidden shadow-sm">
                    <CardContent className="p-0">
                        <table className="w-full text-left text-sm">
                            <thead className="bg-gray-50 border-b border-gray-100">
                                <tr>
                                    <th className="px-6 py-4 font-semibold text-gray-500">Symbol</th>
                                    <th className="px-6 py-4 font-semibold text-gray-500 text-right">Quantity</th>
                                    <th className="px-6 py-4 font-semibold text-gray-500 text-right">Avg Price</th>
                                    <th className="px-6 py-4 font-semibold text-gray-500 text-right">Current Price</th>
                                    <th className="px-6 py-4 font-semibold text-gray-500 text-right">P&L</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100">
                                {(sim.holdings ?? []).length === 0 ? (
                                    <tr>
                                        <td colSpan={5} className="px-6 py-12 text-center text-gray-400 italic">No open positions</td>
                                    </tr>
                                ) : (
                                    sim.holdings!.map((p) => {
                                        const pnl = p.unrealised_pnl_pct ?? 0;
                                        return (
                                            <tr key={p.symbol} className="hover:bg-gray-50/50">
                                                <td className="px-6 py-4 font-bold text-indigo-700">{p.symbol}</td>
                                                <td className="px-6 py-4 text-right font-medium">{p.quantity}</td>
                                                <td className="px-6 py-4 text-right">Rs. {p.average_buy_price.toFixed(1)}</td>
                                                <td className="px-6 py-4 text-right">Rs. {p.current_price?.toFixed(1) || '-'}</td>
                                                <td className={`px-6 py-4 text-right font-bold ${pnl >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                                                    {pnl >= 0 ? '+' : ''}{pnl.toFixed(2)}%
                                                </td>
                                            </tr>
                                        );
                                    })
                                )}
                            </tbody>
                        </table>
                    </CardContent>
                </Card>
            </section>


        </div>

        <div className="space-y-8">
            {!isEnded && isPaused && (
                <Card className="border-amber-200 shadow-sm">
                    <CardHeader className="bg-amber-50 border-b border-amber-100">
                        <CardTitle className="text-sm flex items-center gap-2 text-amber-900">
                            <Sparkles className="h-4 w-4 text-amber-600" />
                            Stocks Worth Reviewing While Paused
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-3 p-4">
                        {suggestions.length === 0 ? (
                            <p className="text-sm text-gray-500">No analysis suggestions available right now.</p>
                        ) : (
                            suggestions.map((stock) => (
                                <div key={stock.symbol} className="rounded-xl border border-amber-100 bg-white p-4">
                                    <div className="flex items-start justify-between gap-3">
                                        <div>
                                            <p className="text-sm font-bold text-gray-900">{stock.symbol}</p>
                                            <p className="mt-1 text-xs text-gray-500">{stock.signal.replaceAll('_', ' ')}</p>
                                        </div>
                                        <span className="rounded-full bg-amber-100 px-2 py-1 text-xs font-semibold text-amber-800">
                                            {stock.overall_score.toFixed(0)}/100
                                        </span>
                                    </div>
                                    <p className="mt-3 text-xs text-gray-600 line-clamp-3">
                                        {(stock.key_signals ?? []).join(' • ') || 'Momentum and trend signals look constructive.'}
                                    </p>
                                    <div className="mt-4 flex gap-2">
                                        <Link href={`/market/${stock.symbol}?simId=${id}`} className="flex-1">
                                            <Button variant="outline" className="w-full">Open Chart</Button>
                                        </Link>
                                        <Link href={`/stock360?symbol=${encodeURIComponent(stock.symbol)}&simId=${id}`} className="flex-1">
                                            <Button className="w-full bg-amber-600 hover:bg-amber-700 text-white">360 View</Button>
                                        </Link>
                                    </div>
                                </div>
                            ))
                        )}
                    </CardContent>
                </Card>
            )}

            {!isEnded && (
                <Card className="border-indigo-100 shadow-lg shadow-indigo-100">
                    <CardHeader className="bg-indigo-600 text-white rounded-t-xl py-4">
                        <CardTitle className="text-sm flex items-center gap-2">
                            <TrendingUp className="h-4 w-4" />
                            Market Quick Search
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="p-4 space-y-4">
                        <div className="space-y-2">
                            {(symbols ?? []).slice(0, 5).map((symbol) => (
                                <div key={symbol} className="flex items-center justify-between p-3 border border-gray-50 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer group">
                                    <div className="flex items-center gap-3">
                                        <div>
                                            <p className="text-sm font-bold text-gray-900">{symbol}</p>
                                        </div>
                                    </div>
                                    <Link href={`/market/${symbol}?simId=${id}`}>
                                        <Button size="sm" variant="ghost" className="text-indigo-600 opacity-0 group-hover:opacity-100 transition-opacity">
                                            Trade / Chart
                                        </Button>
                                    </Link>
                                </div>
                            ))}
                        </div>
                        <Link href="/market" className="block">
                            <Button variant="outline" className="w-full text-gray-600 text-xs border-dashed">
                                Browse All Stocks
                            </Button>
                        </Link>
                    </CardContent>
                </Card>
            )}

            <Card className="border-none shadow-sm bg-indigo-50/50">
                <CardContent className="p-6 text-center space-y-4">
                    <div className="h-12 w-12 bg-white rounded-full flex items-center justify-center mx-auto shadow-sm">
                        <Activity className="h-6 w-6 text-indigo-600" />
                    </div>
                    <div>
                        <h3 className="text-sm font-bold text-indigo-900">Need Guidance?</h3>
                        <p className="text-xs text-indigo-700/70 mt-1">
                            Visit our Learning Path to understand technical indicators and market trends.
                        </p>
                    </div>
                    <Link href="/learn" className="block">
                        <Button variant="ghost" className="text-indigo-600 text-xs font-bold">
                            Open Learning Module <ArrowRight className="h-3 w-3 ml-1" />
                        </Button>
                    </Link>
                </CardContent>
            </Card>
        </div>
      </div>
    </div>
  );
}
