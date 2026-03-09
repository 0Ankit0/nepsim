'use client';

import { useTransition } from 'react';
import { 
  useSimulationDetail, 
  useAdvanceSimulationDay, 
  useStocks 
} from '@/hooks';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui';
import { 
  Activity, ArrowRight, BarChart3, Calendar, 
  Clock, DollarSign, FastForward, Play, 
  Search, StopCircle, TrendingUp, TrendingDown,
  ArrowUpRight, Wallet, History
} from 'lucide-react';
import Link from 'next/link';
import { useQueryClient, useMutation } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import { useRouter } from 'next/navigation';

export default function TradingDashboardPage({ params }: { params: { id: string } }) {
  const id = parseInt(params.id);
  const { data: sim, isLoading } = useSimulationDetail(id);
  const { data: stocks } = useStocks({ limit: 5 });
  const advanceDay = useAdvanceSimulationDay();
  const queryClient = useQueryClient();
  const router = useRouter();

  const endSimulation = useMutation({
    mutationFn: async () => {
        await apiClient.post(`/simulator/simulations/${id}/end/`);
    },
    onSuccess: () => {
        queryClient.invalidateQueries({ queryKey: ['simulation', id] });
        router.push(`/simulator/${id}/analysis`);
    }
  });

  if (isLoading) return <Skeleton className="h-[80vh] w-full" />;
  if (!sim) return <div className="text-center py-20 text-gray-500">Simulation not found.</div>;

  const isEnded = sim.status === 'ended';
  const totalValue = sim.portfolio?.reduce((acc: number, p: any) => acc + (p.current_price * p.quantity), sim.current_balance) ?? sim.current_balance;
  const totalPnl = ((totalValue - sim.initial_capital) / sim.initial_capital) * 100;
  const isPositive = totalPnl >= 0;

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
          <h1 className="text-2xl font-bold text-gray-900">Trading Dashboard</h1>
        </div>
        {!isEnded && (
          <div className="flex items-center gap-3">
            <Button 
              variant="outline" 
              className="border-rose-200 text-rose-600 hover:bg-rose-50"
              onClick={() => {
                if(confirm('Are you sure you want to end this simulation? You will receive AI analysis of your performance.')) {
                    endSimulation.mutate();
                }
              }}
              disabled={endSimulation.isPending}
            >
              <StopCircle className="h-4 w-4 mr-2" />
              End Simulation
            </Button>
            <Button 
              className="bg-indigo-600 hover:bg-indigo-700"
              onClick={() => advanceDay.mutate(id)}
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
          { label: 'Cash Balance', value: `Rs. ${sim.current_balance.toLocaleString()}`, icon: DollarSign, color: 'text-blue-600', bg: 'bg-blue-50' },
          { label: 'Simulation Date', value: sim.start_date, icon: Calendar, color: 'text-amber-600', bg: 'bg-amber-50' },
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
                                {(sim.portfolio ?? []).length === 0 ? (
                                    <tr>
                                        <td colSpan={5} className="px-6 py-12 text-center text-gray-400 italic">No open positions</td>
                                    </tr>
                                ) : (
                                    sim.portfolio.map((p: any) => {
                                        const pnl = ((p.current_price - p.average_price) / p.average_price) * 100;
                                        return (
                                            <tr key={p.symbol} className="hover:bg-gray-50/50">
                                                <td className="px-6 py-4 font-bold text-indigo-700">{p.symbol}</td>
                                                <td className="px-6 py-4 text-right font-medium">{p.quantity}</td>
                                                <td className="px-6 py-4 text-right">Rs. {p.average_price.toFixed(1)}</td>
                                                <td className="px-6 py-4 text-right">Rs. {p.current_price.toFixed(1)}</td>
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

            <section className="space-y-4">
                <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
                    <History className="h-5 w-5 text-gray-600" />
                    Trading Activity
                </h2>
                <Card className="border-gray-100 overflow-hidden shadow-sm">
                    <CardContent className="p-0">
                        <table className="w-full text-left text-sm">
                            <thead className="bg-gray-50 border-b border-gray-100">
                                <tr>
                                    <th className="px-6 py-4 font-semibold text-gray-500">Symbol</th>
                                    <th className="px-6 py-4 font-semibold text-gray-500">Type</th>
                                    <th className="px-6 py-4 font-semibold text-gray-500 text-right">Price</th>
                                    <th className="px-6 py-4 font-semibold text-gray-500 text-right">Qty</th>
                                    <th className="px-6 py-4 font-semibold text-gray-500 text-right">Total</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100">
                                {(sim.trades ?? []).length === 0 ? (
                                    <tr>
                                        <td colSpan={5} className="px-6 py-12 text-center text-gray-400 italic">No historical trades</td>
                                    </tr>
                                ) : (
                                    sim.trades.map((t: any) => (
                                        <tr key={t.id} className="hover:bg-gray-50/50">
                                            <td className="px-6 py-4 font-bold text-gray-900">{t.symbol}</td>
                                            <td className="px-6 py-4">
                                                <span className={`text-[10px] font-bold uppercase rounded px-1.5 py-0.5 ${t.trade_type === 'buy' ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'}`}>
                                                    {t.trade_type}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4 text-right font-mono">Rs. {t.price.toFixed(1)}</td>
                                            <td className="px-6 py-4 text-right">{t.quantity}</td>
                                            <td className="px-6 py-4 text-right font-bold text-gray-900">Rs. {(t.price * t.quantity).toLocaleString()}</td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </CardContent>
                </Card>
            </section>
        </div>

        <div className="space-y-8">
            {!isEnded && (
                <Card className="border-indigo-100 shadow-lg shadow-indigo-100">
                    <CardHeader className="bg-indigo-600 text-white rounded-t-xl py-4">
                        <CardTitle className="text-sm flex items-center gap-2">
                            <TrendingUp className="h-4 w-4" />
                            Market Quick Trade
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="p-4 space-y-4">
                        <div className="relative">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                            <input 
                                className="w-full pl-10 pr-4 py-2 bg-gray-50 border border-gray-100 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                placeholder="Search symbol..."
                            />
                        </div>
                        <div className="space-y-2">
                            {stocks?.items?.slice(0, 3).map((stock: any) => (
                                <div key={stock.symbol} className="flex items-center justify-between p-3 border border-gray-50 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer group">
                                    <div className="flex items-center gap-3">
                                        <div className="h-8 w-8 bg-white border border-gray-100 rounded flex items-center justify-center font-bold text-[10px] text-gray-600">
                                            {stock.symbol.substring(0, 3)}
                                        </div>
                                        <div>
                                            <p className="text-sm font-bold text-gray-900">{stock.symbol}</p>
                                            <p className="text-[10px] text-gray-500">LTP: Rs. {stock.last_price}</p>
                                        </div>
                                    </div>
                                    <Link href={`/market/${stock.symbol}?simId=${id}`}>
                                        <Button size="sm" variant="ghost" className="text-indigo-600 opacity-0 group-hover:opacity-100 transition-opacity">
                                            Trade
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
                        <Button variant="link" className="text-indigo-600 text-xs font-bold">
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
