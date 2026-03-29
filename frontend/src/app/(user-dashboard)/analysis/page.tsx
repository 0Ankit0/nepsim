'use client';

import React, { useState } from 'react';
import { useTopStocks, useMarketOverview } from '@/hooks/useMarketAnalysis';
import { useSimulation } from '@/hooks/useSimulator';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui';
import { TrendingUp, TrendingDown, ChevronDown, ChevronUp, Info } from 'lucide-react';
import type { AnalysisResult } from '@/api/marketAnalysis';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';

type SignalFilter = 'ALL' | 'STRONG_BUY' | 'BUY' | 'HOLD' | 'SELL' | 'STRONG_SELL';
const SIGNAL_FILTERS: SignalFilter[] = ['ALL', 'STRONG_BUY', 'BUY', 'HOLD', 'SELL', 'STRONG_SELL'];
const LIMIT_OPTIONS = [10, 20, 50];

const signalBadge = (signal: AnalysisResult['signal']) => {
  switch (signal) {
    case 'STRONG_BUY': return 'bg-green-700 text-white';
    case 'BUY': return 'bg-green-500 text-white';
    case 'HOLD': return 'bg-amber-400 text-white';
    case 'SELL': return 'bg-red-500 text-white';
    case 'STRONG_SELL': return 'bg-red-800 text-white';
  }
};

const signalLabel = (signal: AnalysisResult['signal']) =>
  signal.replace('_', ' ');

const fmt = (n?: number | null) =>
  n != null ? `Rs. ${n.toLocaleString('en-IN', { maximumFractionDigits: 2 })}` : '-';

function ScoreBar({ value, color }: { value: number; color: string }) {
  const pct = Math.min(100, Math.max(0, value));
  return (
    <div className="w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
      <div className={`h-full rounded-full ${color}`} style={{ width: `${pct}%` }} />
    </div>
  );
}

export default function AnalysisPage() {
  const searchParams = useSearchParams();
  const [signal, setSignal] = useState<SignalFilter>('ALL');
  const [limit, setLimit] = useState(20);
  const [expandedRow, setExpandedRow] = useState<string | null>(null);
  const simId = searchParams.get('simId');
  const simulationId = simId ? Number.parseInt(simId, 10) : 0;
  const { data: sim } = useSimulation(simulationId || undefined);
  const simulationDate = sim?.current_sim_date?.split('T')[0] ?? undefined;

  const { data: overview, isLoading: overviewLoading } = useMarketOverview(simulationDate);
  const { data: topStocks, isLoading: stocksLoading } = useTopStocks(
    limit,
    signal === 'ALL' ? undefined : signal,
    simulationDate,
  );

  const bullishPct = overview?.bullish_pct ?? 0;
  const bearishPct = overview?.bearish_pct ?? 0;

  const toggleRow = (symbol: string) =>
    setExpandedRow((prev) => (prev === symbol ? null : symbol));

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Market Analysis</h1>
        <p className="text-gray-500 text-sm">AI-powered technical signal analysis for NEPSE stocks</p>
        {simulationDate && (
          <p className="mt-2 text-xs font-medium text-amber-700">
            Simulation guardrail active: all analysis is capped at {simulationDate}.
          </p>
        )}
      </div>

      {/* Market Overview Banner */}
      <Card className="bg-white border-gray-200">
        <CardContent className="p-5">
          {overviewLoading ? (
            <div className="space-y-2">
              <Skeleton className="h-4 w-48 bg-gray-100" />
              <Skeleton className="h-6 w-full bg-gray-100" />
            </div>
          ) : overview ? (
            <div className="space-y-3">
              <div className="flex flex-wrap gap-6 text-sm">
                <div>
                  <span className="text-gray-500">Total Analyzed</span>
                  <p className="text-xl font-bold text-gray-900">{overview.total_analyzed}</p>
                </div>
                <div>
                  <span className="text-gray-500">Strong Buy</span>
                  <p className="text-lg font-bold text-green-700">{overview.strong_buy}</p>
                </div>
                <div>
                  <span className="text-gray-500">Buy</span>
                  <p className="text-lg font-bold text-green-500">{overview.buy}</p>
                </div>
                <div>
                  <span className="text-gray-500">Hold</span>
                  <p className="text-lg font-bold text-amber-500">{overview.hold}</p>
                </div>
                <div>
                  <span className="text-gray-500">Sell</span>
                  <p className="text-lg font-bold text-red-500">{overview.sell}</p>
                </div>
                <div>
                  <span className="text-gray-500">Strong Sell</span>
                  <p className="text-lg font-bold text-red-800">{overview.strong_sell}</p>
                </div>
              </div>
              <div>
                <div className="flex justify-between text-xs text-gray-500 mb-1">
                  <span className="flex items-center gap-1 text-green-600 font-semibold">
                    <TrendingUp className="h-3 w-3" /> Bullish {bullishPct.toFixed(1)}%
                  </span>
                  <span className="flex items-center gap-1 text-red-600 font-semibold">
                    Bearish {bearishPct.toFixed(1)}% <TrendingDown className="h-3 w-3" />
                  </span>
                </div>
                <div className="w-full h-3 bg-red-100 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-green-500 rounded-full transition-all duration-500"
                    style={{ width: `${bullishPct}%` }}
                  />
                </div>
              </div>
            </div>
          ) : null}
        </CardContent>
      </Card>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex items-center gap-1 flex-wrap">
          {SIGNAL_FILTERS.map((f) => (
            <button
              key={f}
              onClick={() => setSignal(f)}
              className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-colors border ${
                signal === f
                  ? 'bg-indigo-600 text-white border-indigo-600'
                  : 'bg-white text-gray-600 border-gray-200 hover:border-indigo-400 hover:text-indigo-600'
              }`}
            >
              {f === 'ALL' ? 'All Signals' : f.replace('_', ' ')}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-1 ml-auto">
          <span className="text-xs text-gray-500">Show:</span>
          {LIMIT_OPTIONS.map((l) => (
            <button
              key={l}
              onClick={() => setLimit(l)}
              className={`px-2.5 py-1 rounded text-xs font-medium transition-colors border ${
                limit === l
                  ? 'bg-indigo-600 text-white border-indigo-600'
                  : 'bg-white text-gray-600 border-gray-200 hover:border-indigo-400'
              }`}
            >
              {l}
            </button>
          ))}
        </div>
      </div>

      {/* Top Stocks Table */}
      <Card className="bg-white border-gray-200 overflow-hidden">
        <CardContent className="p-0 overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider w-10">#</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Symbol</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Signal</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Score</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Price</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Entry</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Target</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Stop</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">R:R</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider min-w-[140px]">Osc / Trend / Vol</th>
                <th className="px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Chart</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {stocksLoading ? (
                Array.from({ length: 8 }).map((_, i) => (
                  <tr key={i}>
                      <td colSpan={11} className="px-4 py-3">
                      <Skeleton className="h-8 w-full bg-gray-50" />
                    </td>
                  </tr>
                ))
              ) : !topStocks || topStocks.results.length === 0 ? (
                <tr>
                  <td colSpan={11} className="px-4 py-20 text-center text-gray-500">
                    <div className="flex flex-col items-center gap-2">
                      <Info className="h-8 w-8 text-gray-300" />
                      <p>No analysis results found for the selected filter.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                topStocks.results.map((row, idx) => {
                  const isExpanded = expandedRow === row.symbol;
                  return (
                    <React.Fragment key={row.symbol}>
                      <tr
                        onClick={() => toggleRow(row.symbol)}
                        className="hover:bg-indigo-50/30 transition-colors cursor-pointer"
                      >
                        <td className="px-4 py-3 text-gray-400 text-xs font-mono">{idx + 1}</td>
                        <td className="px-4 py-3 font-bold text-indigo-700">{row.symbol}</td>
                        <td className="px-4 py-3">
                          <span className={`inline-block text-xs font-semibold px-2 py-0.5 rounded-full ${signalBadge(row.signal)}`}>
                            {signalLabel(row.signal)}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-right font-mono font-semibold text-gray-800">
                          {row.overall_score.toFixed(2)}
                        </td>
                        <td className="px-4 py-3 text-right font-mono text-gray-700">{fmt(row.current_price)}</td>
                        <td className="px-4 py-3 text-right font-mono text-gray-700">{fmt(row.entry_price)}</td>
                        <td className="px-4 py-3 text-right font-mono text-green-600">{fmt(row.target_price)}</td>
                        <td className="px-4 py-3 text-right font-mono text-red-500">{fmt(row.stop_loss)}</td>
                        <td className="px-4 py-3 text-right font-mono text-gray-700">
                          {row.risk_reward_ratio != null ? row.risk_reward_ratio.toFixed(2) : '-'}
                        </td>
                        <td className="px-4 py-3">
                          <div className="space-y-1 min-w-[130px]">
                            <div className="flex items-center gap-1.5">
                              <span className="text-xs text-gray-400 w-6">Osc</span>
                              <div className="flex-1">
                                <ScoreBar value={row.oscillator_score} color="bg-indigo-500" />
                              </div>
                              <span className="text-xs text-gray-500 w-8 text-right">{row.oscillator_score.toFixed(1)}</span>
                            </div>
                            <div className="flex items-center gap-1.5">
                              <span className="text-xs text-gray-400 w-6">Tr</span>
                              <div className="flex-1">
                                <ScoreBar value={row.trend_score} color="bg-blue-500" />
                              </div>
                              <span className="text-xs text-gray-500 w-8 text-right">{row.trend_score.toFixed(1)}</span>
                            </div>
                            <div className="flex items-center gap-1.5">
                              <span className="text-xs text-gray-400 w-6">Vol</span>
                              <div className="flex-1">
                                <ScoreBar value={row.volume_score} color="bg-teal-500" />
                              </div>
                              <span className="text-xs text-gray-500 w-8 text-right">{row.volume_score.toFixed(1)}</span>
                            </div>
                          </div>
                        </td>
                        <td className="px-4 py-3 text-right">
                          <Link
                            href={simId ? `/market/${row.symbol}?simId=${simId}` : `/market/${row.symbol}`}
                            className="text-xs font-semibold text-indigo-600 hover:text-indigo-700"
                            onClick={(event) => event.stopPropagation()}
                          >
                            Open Chart
                          </Link>
                        </td>
                      </tr>
                      {isExpanded && (
                        <tr className="bg-indigo-50/40">
                          <td colSpan={11} className="px-8 py-3">
                            <div className="flex items-start gap-2">
                              <div className="flex-1">
                                <p className="text-xs font-semibold text-gray-600 mb-1.5">Key Signals</p>
                                {row.key_signals.length > 0 ? (
                                  <ul className="space-y-0.5">
                                    {row.key_signals.map((s, i) => (
                                      <li key={i} className="text-xs text-gray-700 flex items-start gap-1.5">
                                        <span className="text-indigo-400 mt-0.5">•</span>
                                        {s}
                                      </li>
                                    ))}
                                  </ul>
                                ) : (
                                  <p className="text-xs text-gray-400">No key signals available.</p>
                                )}
                              </div>
                              <button
                                onClick={() => toggleRow(row.symbol)}
                                className="text-gray-400 hover:text-gray-600 mt-0.5"
                              >
                                <ChevronUp className="h-4 w-4" />
                              </button>
                            </div>
                          </td>
                        </tr>
                      )}
                    </React.Fragment>
                  );
                })
              )}
            </tbody>
          </table>
          {topStocks && (
            <div className="px-5 py-2 border-t border-gray-100 bg-gray-50 text-xs text-gray-400 flex justify-between">
              <span>
                {topStocks.count} results · as of {new Date(topStocks.generated_at).toLocaleString()}
              </span>
              <span>Click row to expand key signals</span>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
