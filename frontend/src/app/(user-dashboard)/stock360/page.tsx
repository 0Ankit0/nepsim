'use client';

import React, { useMemo, useRef, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { Search, TrendingUp, TrendingDown, Minus, AlertCircle, RefreshCw, ChevronDown, ChevronUp } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { useStock360View } from '@/hooks/useMarketAnalysis';
import { useSymbols, useTaLibIndicatorCatalog } from '@/hooks/useMarket';
import { useSimulation } from '@/hooks/useSimulator';
import type { IndicatorSignal, SimilarPeriod, PricePoint } from '@/api/marketAnalysis';
import type { TaLibIndicatorCatalogItem } from '@/api/market';
import { MarketChartCard } from '@/components/market-chart/chart-card';
import type { ChartRange, PriceBar } from '@/components/market-chart/chart-config';
import { toDateKey } from '@/components/market-chart/data-utils';

const SIGNAL_STYLE: Record<string, { bg: string; text: string; label: string }> = {
  STRONG_BUY: { bg: 'bg-emerald-100', text: 'text-emerald-800', label: 'Strong Buy' },
  BUY: { bg: 'bg-green-100', text: 'text-green-800', label: 'Buy' },
  HOLD: { bg: 'bg-yellow-100', text: 'text-yellow-800', label: 'Hold' },
  SELL: { bg: 'bg-orange-100', text: 'text-orange-800', label: 'Sell' },
  STRONG_SELL: { bg: 'bg-red-100', text: 'text-red-800', label: 'Strong Sell' },
};

const IND_SIGNAL_STYLE: Record<string, string> = {
  BULLISH: 'text-emerald-600',
  BEARISH: 'text-red-500',
  NEUTRAL: 'text-gray-500',
};

const fmt = (v?: number, dec = 2) => (v !== undefined && v !== null ? v.toFixed(dec) : '—');

const fmtPct = (v?: number) => {
  if (v === undefined || v === null) return '—';
  const color = v >= 0 ? 'text-emerald-600' : 'text-red-500';
  return <span className={color}>{v >= 0 ? '+' : ''}{v.toFixed(2)}%</span>;
};

const fmtVol = (v?: number) => {
  if (!v) return '—';
  if (v >= 1_000_000) return `${(v / 1_000_000).toFixed(2)}M`;
  if (v >= 1_000) return `${(v / 1_000).toFixed(1)}K`;
  return v.toFixed(0);
};

function buildPriceHistoryBars(history: PricePoint[]): PriceBar[] {
  const uniqueRows = new Map<string, PriceBar>();
  const sortedRows = [...history].sort((left, right) => (toDateKey(left.date) ?? '').localeCompare(toDateKey(right.date) ?? ''));

  for (const row of sortedRows) {
    const date = toDateKey(row.date);
    const close = row.close ?? row.ltp;
    const timestamp = date ? Date.parse(`${date}T00:00:00Z`) : Number.NaN;

    if (!date || Number.isNaN(timestamp) || row.open == null || row.high == null || row.low == null || close == null) {
      continue;
    }

    uniqueRows.set(date, {
      date,
      timestamp,
      open: row.open,
      high: row.high,
      low: row.low,
      close,
      volume: row.vol ?? 0,
      turnover: row.turnover,
    });
  }

  return Array.from(uniqueRows.values()).sort((left, right) => left.date.localeCompare(right.date));
}

function filterPriceHistoryByRange<T extends { date: string }>(rows: T[], range: ChartRange): T[] {
  if (rows.length === 0 || range === 'ALL') {
    return rows;
  }

  if (range === '1D') {
    return rows.slice(-1);
  }

  if (range === '2D') {
    return rows.slice(-2);
  }

  const daysBackMap: Record<Exclude<ChartRange, '1D' | '2D' | 'ALL'>, number> = {
    '1W': 7,
    '1M': 30,
    '3M': 90,
    '6M': 180,
    '1Y': 365,
  };

  const daysBack = daysBackMap[range as keyof typeof daysBackMap];
  if (!daysBack) {
    return rows;
  }

  const anchor = new Date(rows[rows.length - 1].date);
  if (Number.isNaN(anchor.getTime())) {
    return rows;
  }

  const cutoff = new Date(anchor);
  cutoff.setDate(cutoff.getDate() - daysBack);

  return rows.filter((row) => {
    const rowDate = new Date(row.date);
    return !Number.isNaN(rowDate.getTime()) && rowDate >= cutoff;
  });
}

function useClickOutside(ref: React.RefObject<HTMLElement | null>, onOutsideClick: () => void) {
  React.useEffect(() => {
    const handleMouseDown = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        onOutsideClick();
      }
    };

    document.addEventListener('mousedown', handleMouseDown);
    return () => document.removeEventListener('mousedown', handleMouseDown);
  }, [onOutsideClick, ref]);
}

function PriceChart({
  symbol,
  history,
  selectedPeriod,
  symbols,
  simulationStartDate,
  simulationDate,
  talibCatalog,
}: {
  symbol: string;
  history: PricePoint[];
  selectedPeriod: SimilarPeriod | null;
  symbols?: string[];
  simulationStartDate?: string;
  simulationDate?: string;
  talibCatalog?: TaLibIndicatorCatalogItem[];
}) {
  const [selectedRange, setSelectedRange] = useState<ChartRange>('1Y');

  const boundedHistory = useMemo(
    () =>
      !simulationStartDate
        ? history
        : history.filter((row) => {
            const date = toDateKey(row.date);
            return Boolean(date && date >= simulationStartDate);
          }),
    [history, simulationStartDate]
  );
  const priceBars = useMemo(() => buildPriceHistoryBars(boundedHistory), [boundedHistory]);
  const filteredPriceBars = useMemo(() => filterPriceHistoryByRange(priceBars, selectedRange), [priceBars, selectedRange]);

  return (
    <div className="space-y-4">
      <MarketChartCard
        symbol={symbol}
        title="Pro price history workspace"
        description="Daily-only price history with chart themes, saved layouts, and searchable TA-Lib-backed indicators."
        badgeLabel="Stock 360 workspace"
        selectedRange={selectedRange}
        onRangeChange={setSelectedRange}
        priceBars={filteredPriceBars}
        allSymbols={symbols}
        talibCatalog={talibCatalog}
        indicatorAsOfDate={simulationDate}
        highlightedRange={
          selectedPeriod
            ? {
                startDate: toDateKey(selectedPeriod.start_date) ?? selectedPeriod.start_date,
                endDate: toDateKey(selectedPeriod.end_date) ?? selectedPeriod.end_date,
              }
            : null
        }
        isHistoryLoading={false}
        emptyMessage="No price history is available for this symbol yet."
      />
    </div>
  );
}

function ScoreBar({ label, value, color = 'bg-blue-500' }: { label: string; value: number; color?: string }) {
  return (
    <div>
      <div className="mb-1 flex justify-between text-xs">
        <span className="text-gray-600">{label}</span>
        <span className="font-semibold">{value.toFixed(0)}/100</span>
      </div>
      <div className="h-2 overflow-hidden rounded-full bg-gray-100">
        <div className={`h-full rounded-full transition-all ${color}`} style={{ width: `${value}%` }} />
      </div>
    </div>
  );
}

function IndicatorCard({ ind }: { ind: IndicatorSignal }) {
  const [expanded, setExpanded] = useState(false);
  const icon =
    ind.signal === 'BULLISH' ? (
      <TrendingUp className="h-4 w-4 text-emerald-500" />
    ) : ind.signal === 'BEARISH' ? (
      <TrendingDown className="h-4 w-4 text-red-500" />
    ) : (
      <Minus className="h-4 w-4 text-gray-400" />
    );

  const border =
    ind.signal === 'BULLISH' ? 'border-l-emerald-400' : ind.signal === 'BEARISH' ? 'border-l-red-400' : 'border-l-gray-300';

  return (
    <div
      className={`cursor-pointer rounded-r-lg border-l-4 ${border} bg-white p-3 shadow-sm transition-shadow hover:shadow-md`}
      onClick={() => setExpanded(!expanded)}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          {icon}
          <span className="text-sm font-medium text-gray-800">{ind.name}</span>
        </div>
        <div className="flex items-center gap-2">
          {ind.value !== undefined && ind.value !== null && <span className="text-xs text-gray-500">{ind.value.toFixed(2)}</span>}
          <span className={`text-xs font-semibold ${IND_SIGNAL_STYLE[ind.signal]}`}>{ind.signal}</span>
          {expanded ? <ChevronUp className="h-3 w-3 text-gray-400" /> : <ChevronDown className="h-3 w-3 text-gray-400" />}
        </div>
      </div>
      {expanded && <p className="mt-2 text-xs leading-relaxed text-gray-600">{ind.interpretation}</p>}
    </div>
  );
}

function SimilarPeriodCard({ period }: { period: SimilarPeriod }) {
  const outcomeColor =
    period.outcome === 'BULLISH'
      ? 'bg-emerald-100 text-emerald-700'
      : period.outcome === 'BEARISH'
        ? 'bg-red-100 text-red-700'
        : 'bg-gray-100 text-gray-600';

  return (
    <div className="rounded-lg border border-gray-100 bg-white p-4 shadow-sm">
      <div className="mb-2 flex items-start justify-between">
        <div>
          <p className="text-xs text-gray-500">
            {period.start_date} → {period.end_date}
          </p>
          <div className="mt-1 flex items-center gap-2">
            <span className="text-xs font-medium text-blue-600">Similarity: {period.similarity_score}%</span>
            <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${outcomeColor}`}>{period.outcome}</span>
          </div>
        </div>
        {period.forward_30d_return_pct !== undefined && period.forward_30d_return_pct !== null && (
          <div className="text-right">
            <p className="text-xs text-gray-400">30d after</p>
            <p className={`text-sm font-bold ${period.forward_30d_return_pct >= 0 ? 'text-emerald-600' : 'text-red-500'}`}>
              {period.forward_30d_return_pct >= 0 ? '+' : ''}
              {period.forward_30d_return_pct.toFixed(1)}%
            </p>
          </div>
        )}
      </div>
      <p className="text-xs leading-relaxed text-gray-600">{period.description}</p>
    </div>
  );
}

export default function Stock360Page() {
  const searchParams = useSearchParams();
  const initialSymbol = searchParams.get('symbol')?.trim().toUpperCase() ?? '';
  const simId = searchParams.get('simId');
  const simulationId = simId ? Number.parseInt(simId, 10) : 0;
  const { data: sim } = useSimulation(simulationId || undefined);
  const simulationStartDate = sim?.period_start?.split('T')[0] ?? undefined;
  const simulationDate = sim?.current_sim_date?.split('T')[0] ?? undefined;
  const { data: symbols, isLoading: isSymbolsLoading } = useSymbols();
  const { data: talibCatalog } = useTaLibIndicatorCatalog();

  const [inputValue, setInputValue] = useState(initialSymbol);
  const [activeSymbol, setActiveSymbol] = useState(initialSymbol);
  const [selectedPatternIndex, setSelectedPatternIndex] = useState<number>(-1);
  const [symbolResultsOpen, setSymbolResultsOpen] = useState(false);
  const [searchMessage, setSearchMessage] = useState<string | null>(null);

  const { data, isLoading, isError, refetch } = useStock360View(activeSymbol, simulationDate);
  const searchRef = useRef<HTMLDivElement>(null);

  useClickOutside(searchRef, () => setSymbolResultsOpen(false));

  const symbolMatches = useMemo(() => {
    if (!symbols || inputValue.trim().length === 0) return [];

    const query = inputValue.trim().toUpperCase();
    return [...symbols]
      .filter((candidate) => candidate.includes(query))
      .sort((left, right) => {
        const leftStartsWith = left.startsWith(query) ? 0 : 1;
        const rightStartsWith = right.startsWith(query) ? 0 : 1;
        if (leftStartsWith !== rightStartsWith) {
          return leftStartsWith - rightStartsWith;
        }
        return left.localeCompare(right);
      })
      .slice(0, 8);
  }, [inputValue, symbols]);

  const handleSearch = (candidate?: string) => {
    const sym = (candidate ?? inputValue).trim().toUpperCase();

    if (!sym) {
      setSearchMessage('Enter a NEPSE symbol to analyze.');
      return;
    }

    if (symbols && !symbols.includes(sym)) {
      setSearchMessage(`No NEPSE symbol matched "${sym}".`);
      setSymbolResultsOpen(true);
      return;
    }

    setSearchMessage(null);
    setSymbolResultsOpen(false);
    setActiveSymbol(sym);
  };

  const signal = data ? SIGNAL_STYLE[data.signal] ?? SIGNAL_STYLE.HOLD : null;
  const selectedSimilarPeriod =
    data && selectedPatternIndex >= 0 && selectedPatternIndex < data.similar_periods.length ? data.similar_periods[selectedPatternIndex] : null;

  React.useEffect(() => {
    setSelectedPatternIndex(-1);
  }, [activeSymbol]);

  return (
    <div className="mx-auto max-w-6xl space-y-6 px-4 py-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Stock 360° View</h1>
        <p className="mt-1 text-sm text-gray-500">
          Enter any NEPSE symbol to get a comprehensive historic analysis, indicator breakdown, trend view, and similar patterns.
        </p>
        {simulationDate && (
          <p className="mt-2 text-xs font-medium text-amber-700">
            Simulation guardrail active: chart data is capped to {simulationStartDate ?? simulationDate} through {simulationDate}.
          </p>
        )}
      </div>

      <Card>
        <CardContent className="p-4">
          <div className="flex gap-3">
            <div ref={searchRef} className="relative flex-1">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
              <Input
                className="pl-9 uppercase"
                placeholder="Enter stock symbol (e.g. NABIL, NICA, SCB...)"
                value={inputValue}
                onFocus={() => setSymbolResultsOpen(true)}
                onChange={(event) => {
                  setInputValue(event.target.value.toUpperCase());
                  setSearchMessage(null);
                  setSymbolResultsOpen(true);
                }}
                onKeyDown={(event) => {
                  if (event.key === 'Enter') {
                    event.preventDefault();
                    handleSearch(symbolMatches[0] ?? inputValue);
                  }
                  if (event.key === 'Escape') {
                    setSymbolResultsOpen(false);
                  }
                }}
              />
              {symbolResultsOpen && inputValue.trim() && (
                <div className="absolute z-20 mt-2 w-full overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
                  {symbolMatches.length > 0 ? (
                    <ul className="max-h-72 overflow-y-auto py-1">
                      {symbolMatches.map((match) => (
                        <li key={match}>
                          <button
                            type="button"
                            className="flex w-full items-center justify-between px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50"
                            onClick={() => handleSearch(match)}
                          >
                            <span className="font-semibold text-gray-900">{match}</span>
                            <span className="text-xs text-gray-400">Analyze</span>
                          </button>
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <div className="px-4 py-3 text-sm text-gray-500">
                      {isSymbolsLoading ? 'Loading symbols...' : `No symbols matched "${inputValue.trim().toUpperCase()}".`}
                    </div>
                  )}
                </div>
              )}
              {searchMessage && <p className="mt-2 text-xs font-medium text-rose-600">{searchMessage}</p>}
            </div>
            <Button onClick={() => handleSearch(symbolMatches[0] ?? inputValue)} disabled={!inputValue.trim()}>
              Analyze
            </Button>
            {activeSymbol && (
              <Button variant="outline" onClick={() => refetch()} disabled={isLoading}>
                <RefreshCw className={`h-4 w-4 ${isLoading ? 'animate-spin' : ''}`} />
              </Button>
            )}
          </div>
        </CardContent>
      </Card>

      {isLoading && (
        <div className="py-16 text-center text-gray-500">
          <div className="mx-auto mb-4 h-10 w-10 animate-spin rounded-full border-4 border-blue-500 border-t-transparent" />
          <p>Analyzing {activeSymbol}…</p>
          <p className="mt-1 text-xs">Fetching full history, indicators, and running pattern matching</p>
        </div>
      )}

      {isError && !isLoading && (
        <Card>
          <CardContent className="p-8 text-center">
            <AlertCircle className="mx-auto mb-3 h-10 w-10 text-red-400" />
            <p className="font-medium text-gray-700">Symbol not found or no data available</p>
            <p className="mt-1 text-sm text-gray-500">Try checking the symbol name (e.g. NABIL, NICA, SCB)</p>
          </CardContent>
        </Card>
      )}

      {!activeSymbol && !isLoading && (
        <div className="py-16 text-center text-gray-400">
          <Search className="mx-auto mb-4 h-16 w-16 opacity-30" />
          <p className="text-lg font-medium">Search for a NEPSE stock symbol</p>
          <p className="mt-1 text-sm">Get full historic analysis, technical indicators, trend breakdown, and similar historical patterns</p>
        </div>
      )}

      {data && !isLoading && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
            <Card className="md:col-span-2">
              <CardContent className="p-5">
                <div className="flex items-start justify-between">
                  <div>
                    <div className="flex items-center gap-3">
                      <h2 className="text-3xl font-bold text-gray-900">{data.symbol}</h2>
                      {signal && (
                        <span className={`rounded-full px-3 py-1 text-sm font-semibold ${signal.bg} ${signal.text}`}>
                          {signal.label}
                        </span>
                      )}
                    </div>
                    <div className="mt-2 flex items-baseline gap-3">
                      <span className="text-2xl font-semibold text-gray-800">Rs. {fmt(data.current_price)}</span>
                      {data.change_pct !== undefined && (
                        <span className={`text-sm font-medium ${(data.change_pct ?? 0) >= 0 ? 'text-emerald-600' : 'text-red-500'}`}>
                          {(data.change_pct ?? 0) >= 0 ? '▲' : '▼'} {Math.abs(data.change_pct ?? 0).toFixed(2)}%
                        </span>
                      )}
                    </div>
                    <p className="mt-1 text-xs text-gray-400">As of {data.analysis_date}</p>
                  </div>
                  <div className="space-y-1 text-right">
                    <p className="text-xs text-gray-500">Overall Score</p>
                    <p className="text-4xl font-bold text-blue-600">{data.overall_score.toFixed(0)}</p>
                    <p className="text-xs text-gray-400">/ 100</p>
                  </div>
                </div>

                <div className="mt-4 grid grid-cols-4 gap-3 border-t border-gray-100 pt-4">
                  {[
                    ['Open', fmt(data.open_price)],
                    ['High', fmt(data.high_price)],
                    ['Low', fmt(data.low_price)],
                    ['Prev Close', fmt(data.prev_close)],
                    ['VWAP', fmt(data.vwap)],
                    ['Volume', fmtVol(data.volume)],
                    ['52W High', fmt(data.week_52_high)],
                    ['52W Low', fmt(data.week_52_low)],
                  ].map(([label, val]) => (
                    <div key={label as string}>
                      <p className="text-xs text-gray-400">{label}</p>
                      <p className="text-sm font-medium text-gray-700">{val}</p>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="space-y-4 p-5">
                <h3 className="text-sm font-semibold text-gray-700">Score Breakdown</h3>
                <ScoreBar label="Oscillator" value={data.oscillator_score} color="bg-purple-500" />
                <ScoreBar label="Trend" value={data.trend_score} color="bg-blue-500" />
                <ScoreBar label="Volume" value={data.volume_score} color="bg-amber-500" />
                <ScoreBar label="Volatility" value={data.volatility_score} color="bg-rose-500" />
                {data.entry_price && (
                  <div className="space-y-1 border-t border-gray-100 pt-3 text-xs">
                    <div className="flex justify-between">
                      <span className="text-gray-500">Entry</span>
                      <span className="font-medium">Rs. {fmt(data.entry_price)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Target</span>
                      <span className="font-medium text-emerald-600">Rs. {fmt(data.target_price)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">Stop Loss</span>
                      <span className="font-medium text-red-500">Rs. {fmt(data.stop_loss)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">R:R</span>
                      <span className="font-medium">{fmt(data.risk_reward_ratio)}x</span>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardContent className="p-5">
              <h3 className="mb-4 text-sm font-semibold text-gray-700">Price History</h3>
                <PriceChart
                  symbol={data.symbol}
                  history={data.price_history}
                  selectedPeriod={selectedSimilarPeriod}
                  symbols={symbols}
                  simulationStartDate={simulationStartDate}
                  simulationDate={simulationDate}
                  talibCatalog={talibCatalog?.data}
                />
            </CardContent>
          </Card>

          <Card className="border-indigo-100 bg-gradient-to-br from-indigo-50 via-white to-sky-50">
            <CardContent className="p-5">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <h3 className="text-sm font-semibold text-gray-700">Gemini Technical Read</h3>
                  <p className="mt-1 text-xs text-gray-500">Backend-generated commentary from the computed technical snapshot.</p>
                </div>
                <span className="rounded-full border border-indigo-200 bg-white px-3 py-1 text-[11px] font-semibold uppercase tracking-wider text-indigo-600">
                  Gemini
                </span>
              </div>
              <p className="mt-4 text-sm leading-7 text-gray-700">
                {data.ai_summary ?? 'Gemini commentary is unavailable right now, but the computed technical breakdown below is still current.'}
              </p>
            </CardContent>
          </Card>

          <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <Card>
              <CardContent className="p-5">
                <h3 className="mb-4 text-sm font-semibold text-gray-700">Performance</h3>
                <table className="w-full text-sm">
                  <tbody>
                    {[
                      ['1 Week', data.performance.week_1_pct],
                      ['1 Month', data.performance.month_1_pct],
                      ['3 Months', data.performance.month_3_pct],
                      ['6 Months', data.performance.month_6_pct],
                      ['1 Year', data.performance.year_1_pct],
                      ['Year to Date', data.performance.ytd_pct],
                    ].map(([label, val]) => (
                      <tr key={label as string} className="border-b border-gray-50">
                        <td className="py-2 text-gray-500">{label}</td>
                        <td className="py-2 text-right font-medium">{fmtPct(val as number | undefined)}</td>
                      </tr>
                    ))}
                    <tr className="border-b border-gray-50">
                      <td className="py-2 text-gray-500">Max Drawdown</td>
                      <td className="py-2 text-right font-medium text-red-500">
                        {data.performance.max_drawdown_pct ? `-${data.performance.max_drawdown_pct.toFixed(2)}%` : '—'}
                      </td>
                    </tr>
                    <tr>
                      <td className="py-2 text-gray-500">Volatility (20d ann.)</td>
                      <td className="py-2 text-right font-medium">{fmt(data.performance.volatility_20d_annualized)}%</td>
                    </tr>
                  </tbody>
                </table>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-5">
                <h3 className="mb-4 text-sm font-semibold text-gray-700">Trend Analysis</h3>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-500">Primary Trend</span>
                    <span
                      className={`rounded-full px-3 py-1 text-xs font-semibold ${
                        data.trend_analysis.primary_trend === 'UPTREND'
                          ? 'bg-emerald-100 text-emerald-700'
                          : data.trend_analysis.primary_trend === 'DOWNTREND'
                            ? 'bg-red-100 text-red-700'
                            : 'bg-gray-100 text-gray-600'
                      }`}
                    >
                      {data.trend_analysis.primary_trend}
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-500">Strength</span>
                    <span className="text-sm font-medium text-gray-700">{data.trend_analysis.trend_strength}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-500">MA Alignment</span>
                    <span
                      className={`text-sm font-medium ${
                        data.trend_analysis.ma_alignment === 'BULLISH'
                          ? 'text-emerald-600'
                          : data.trend_analysis.ma_alignment === 'BEARISH'
                            ? 'text-red-500'
                            : 'text-gray-600'
                      }`}
                    >
                      {data.trend_analysis.ma_alignment}
                    </span>
                  </div>
                  {data.trend_analysis.golden_cross && (
                    <div className="rounded-lg bg-emerald-50 px-3 py-2 text-xs font-medium text-emerald-700">
                      Golden Cross active (SMA50 &gt; SMA200)
                    </div>
                  )}
                  {data.trend_analysis.death_cross && (
                    <div className="rounded-lg bg-red-50 px-3 py-2 text-xs font-medium text-red-700">
                      Death Cross active (SMA50 &lt; SMA200)
                    </div>
                  )}
                  {data.trend_analysis.ichimoku_signal && (
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-500">Ichimoku</span>
                      <span className={`text-sm font-medium ${IND_SIGNAL_STYLE[data.trend_analysis.ichimoku_signal]}`}>
                        {data.trend_analysis.ichimoku_signal}
                      </span>
                    </div>
                  )}
                  <div className="border-t border-gray-100 pt-2">
                    <div className="mb-1 flex justify-between text-xs">
                      <span className="text-gray-400">Support</span>
                      <span className="font-medium text-emerald-600">Rs. {fmt(data.trend_analysis.support_level)}</span>
                    </div>
                    <div className="flex justify-between text-xs">
                      <span className="text-gray-400">Resistance</span>
                      <span className="font-medium text-red-500">Rs. {fmt(data.trend_analysis.resistance_level)}</span>
                    </div>
                  </div>
                  <p className="border-t border-gray-100 pt-2 text-xs leading-relaxed text-gray-500">{data.trend_analysis.summary}</p>
                </div>
              </CardContent>
            </Card>
          </div>

          {data.key_signals.length > 0 && (
            <Card>
              <CardContent className="p-5">
                <h3 className="mb-3 text-sm font-semibold text-gray-700">Key Signals</h3>
                <div className="flex flex-wrap gap-2">
                  {data.key_signals.map((sig, i) => (
                    <span key={i} className="rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">
                      {sig}
                    </span>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}

          <Card>
            <CardContent className="p-5">
              <h3 className="mb-4 text-sm font-semibold text-gray-700">Indicator Analysis</h3>
              <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                {data.indicator_signals.map((ind, i) => (
                  <IndicatorCard key={i} ind={ind} />
                ))}
              </div>
            </CardContent>
          </Card>

          {data.similar_periods.length > 0 && (
            <Card>
              <CardContent className="p-5">
                <div className="mb-4 flex items-start justify-between">
                  <div>
                    <h3 className="text-sm font-semibold text-gray-700">Similar Historical Patterns</h3>
                    <p className="mt-0.5 text-xs text-gray-400">
                      Periods with similar indicator fingerprints — shows what happened next
                    </p>
                  </div>
                  <div className="w-72">
                    <label htmlFor="pattern-select" className="mb-1 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                      Highlight on chart
                    </label>
                    <select
                      id="pattern-select"
                      className="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-700 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      value={selectedPatternIndex}
                      onChange={(event) => setSelectedPatternIndex(Number.parseInt(event.target.value, 10))}
                    >
                      <option value={-1}>None</option>
                      {data.similar_periods.map((period, index) => (
                        <option key={`${period.start_date}-${period.end_date}-${index}`} value={index}>
                          {period.start_date} → {period.end_date} ({period.similarity_score}%)
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                <div className="grid grid-cols-1 gap-3 md:grid-cols-2 lg:grid-cols-3">
                  {data.similar_periods.map((p, i) => (
                    <div
                      key={i}
                      role="button"
                      tabIndex={0}
                      className={`rounded-lg transition-all ${selectedPatternIndex === i ? 'ring-2 ring-amber-400 ring-offset-2' : ''}`}
                      onClick={() => setSelectedPatternIndex(i)}
                      onKeyDown={(event) => {
                        if (event.key === 'Enter' || event.key === ' ') {
                          event.preventDefault();
                          setSelectedPatternIndex(i);
                        }
                      }}
                    >
                      <SimilarPeriodCard period={p} />
                    </div>
                  ))}
                </div>
                <div className="mt-4 rounded-lg bg-amber-50 p-3 text-xs text-amber-700">
                  <strong>Disclaimer:</strong> Past patterns are not guaranteed to repeat. Use this analysis as one of many inputs for
                  your investment decisions, not as financial advice.
                </div>
              </CardContent>
            </Card>
          )}

          <Card>
            <CardContent className="p-5">
              <h3 className="mb-3 text-sm font-semibold text-gray-700">Price vs Moving Averages</h3>
              <div className="grid grid-cols-3 gap-3 text-center">
                {[
                  ['SMA 20', data.trend_analysis.price_vs_sma20],
                  ['SMA 50', data.trend_analysis.price_vs_sma50],
                  ['SMA 200', data.trend_analysis.price_vs_sma200],
                ].map(([label, pos]) => (
                  <div
                    key={label as string}
                    className={`rounded-lg p-3 ${pos === 'ABOVE' ? 'bg-emerald-50' : pos === 'BELOW' ? 'bg-red-50' : 'bg-gray-50'}`}
                  >
                    <p className="text-xs text-gray-500">{label}</p>
                    <p
                      className={`mt-1 text-sm font-semibold ${
                        pos === 'ABOVE' ? 'text-emerald-600' : pos === 'BELOW' ? 'text-red-500' : 'text-gray-400'
                      }`}
                    >
                      {pos ?? '—'}
                    </p>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
