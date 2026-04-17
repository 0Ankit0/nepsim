'use client';

import React, { useMemo, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { Search, TrendingUp, TrendingDown, Minus, AlertCircle, RefreshCw, ChevronDown, ChevronUp } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { useStock360View } from '@/hooks/useMarketAnalysis';
import { useSimulation } from '@/hooks/useSimulator';
import type { IndicatorSignal, SimilarPeriod, PricePoint } from '@/api/marketAnalysis';
import { MarketChartCanvas } from '@/components/market-chart/chart-canvas';
import { MarketChartToolsPanel } from '@/components/market-chart/tools-panel';
import {
  DEFAULT_LAYOUT_SETTINGS,
  INDICATOR_CATALOG,
  OVERLAY_CATALOG,
  getIndicatorMeta,
  upsertIndicator,
  type ChartLayoutSettings,
  type ChartRange,
  type IndicatorId,
  type IndicatorPreset,
  type OverlayId,
  type PriceBar,
} from '@/components/market-chart/chart-config';
import { toDateKey } from '@/components/market-chart/data-utils';

// ─── Signal helpers ───────────────────────────────────────────────────────────

const SIGNAL_STYLE: Record<string, { bg: string; text: string; label: string }> = {
  STRONG_BUY:  { bg: 'bg-emerald-100', text: 'text-emerald-800', label: 'Strong Buy' },
  BUY:         { bg: 'bg-green-100',   text: 'text-green-800',   label: 'Buy' },
  HOLD:        { bg: 'bg-yellow-100',  text: 'text-yellow-800',  label: 'Hold' },
  SELL:        { bg: 'bg-orange-100',  text: 'text-orange-800',  label: 'Sell' },
  STRONG_SELL: { bg: 'bg-red-100',     text: 'text-red-800',     label: 'Strong Sell' },
};

const IND_SIGNAL_STYLE: Record<string, string> = {
  BULLISH: 'text-emerald-600',
  BEARISH: 'text-red-500',
  NEUTRAL: 'text-gray-500',
};

const fmt = (v?: number, dec = 2) =>
  v !== undefined && v !== null ? v.toFixed(dec) : '—';

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

// ─── Chart component ──────────────────────────────────────────────────────────

const PRICE_HISTORY_RANGES: ChartRange[] = ['1D', '2D', '1W', '1M', '3M', '6M', '1Y', 'ALL'];

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

function PriceChart({
  symbol,
  history,
  selectedPeriod,
}: {
  symbol: string;
  history: PricePoint[];
  selectedPeriod: SimilarPeriod | null;
}) {
  const [chartSettings, setChartSettings] = useState<ChartLayoutSettings>(() => ({ ...DEFAULT_LAYOUT_SETTINGS, range: '1Y' }));
  const [pendingIndicatorId, setPendingIndicatorId] = useState<IndicatorId | ''>('');
  const [pendingOverlayId, setPendingOverlayId] = useState<OverlayId | ''>(OVERLAY_CATALOG[0]?.id ?? '');
  const [createOverlayNonce, setCreateOverlayNonce] = useState(0);
  const [clearDrawingsNonce, setClearDrawingsNonce] = useState(0);

  const priceBars = useMemo(() => buildPriceHistoryBars(history), [history]);
  const filteredPriceBars = useMemo(() => filterPriceHistoryByRange(priceBars, chartSettings.range), [priceBars, chartSettings.range]);
  const availableIndicators = useMemo(
    () => INDICATOR_CATALOG.filter((candidate) => !chartSettings.indicators.some((indicator) => indicator.id === candidate.id)),
    [chartSettings.indicators]
  );

  React.useEffect(() => {
    if (availableIndicators.length === 0) {
      setPendingIndicatorId('');
      return;
    }
    if (pendingIndicatorId && availableIndicators.some((indicator) => indicator.id === pendingIndicatorId)) {
      return;
    }
    setPendingIndicatorId(availableIndicators[0]?.id ?? '');
  }, [availableIndicators, pendingIndicatorId]);

  const applyPreset = (preset: IndicatorPreset) => {
    if (preset === 'trend') {
      setChartSettings((current) => ({
        ...current,
        indicators: [
          { id: 'MA', visible: true },
          { id: 'EMA', visible: true },
          { id: 'SMA', visible: true },
          { id: 'BBI', visible: true },
          { id: 'BOLL', visible: true },
          { id: 'SAR', visible: true },
          { id: 'DMI', visible: true },
        ],
      }));
      return;
    }
    if (preset === 'momentum') {
      setChartSettings((current) => ({
        ...current,
        indicators: [
          { id: 'RSI', visible: true },
          { id: 'MACD', visible: true },
          { id: 'KDJ', visible: true },
          { id: 'ROC', visible: true },
          { id: 'MTM', visible: true },
          { id: 'AO', visible: true },
        ],
      }));
      return;
    }
    setChartSettings({ ...DEFAULT_LAYOUT_SETTINGS, range: chartSettings.range });
  };

  return (
    <div className="grid grid-cols-1 xl:grid-cols-3 gap-4">
      <div className="xl:col-span-2">
        <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex flex-wrap gap-2">
            {(['candlestick', 'hollow', 'ohlc', 'area'] as const).map((mode) => (
              <Button
                key={mode}
                type="button"
                size="sm"
                variant={chartSettings.chartStyle === mode ? 'primary' : 'outline'}
                onClick={() => setChartSettings((current) => ({ ...current, chartStyle: mode }))}
              >
                {mode === 'candlestick' ? 'Candles' : mode === 'hollow' ? 'Hollow' : mode === 'ohlc' ? 'OHLC' : 'Area'}
              </Button>
            ))}
          </div>
          <div className="flex flex-wrap gap-2">
            {PRICE_HISTORY_RANGES.map((nextRange) => (
              <Button
                key={nextRange}
                type="button"
                size="sm"
                variant={chartSettings.range === nextRange ? 'primary' : 'outline'}
                onClick={() => setChartSettings((current) => ({ ...current, range: nextRange }))}
              >
                {nextRange}
              </Button>
            ))}
          </div>
        </div>
        <MarketChartCanvas
          symbol={symbol}
          priceBars={filteredPriceBars}
          highlightedRange={
            selectedPeriod
              ? {
                  startDate: toDateKey(selectedPeriod.start_date) ?? selectedPeriod.start_date,
                  endDate: toDateKey(selectedPeriod.end_date) ?? selectedPeriod.end_date,
                }
              : null
          }
          pendingOverlayId={pendingOverlayId}
          createOverlayNonce={createOverlayNonce}
          clearDrawingsNonce={clearDrawingsNonce}
          settings={chartSettings}
          emptyMessage="No price history is available for this symbol yet."
        />
      </div>
      <MarketChartToolsPanel
        chartSettings={chartSettings}
        availableIndicators={availableIndicators}
        pendingIndicatorId={pendingIndicatorId}
        onPendingIndicatorChange={setPendingIndicatorId}
        onAddIndicator={() => {
          if (!pendingIndicatorId) return;
          getIndicatorMeta(pendingIndicatorId);
          setChartSettings((current) => ({
            ...current,
            indicators: upsertIndicator(current.indicators, { id: pendingIndicatorId, visible: true }),
          }));
        }}
        onApplyPreset={applyPreset}
        onToggleIndicatorVisibility={(indicatorId) => {
          setChartSettings((current) => ({
            ...current,
            indicators: current.indicators.map((indicator) => (indicator.id === indicatorId ? { ...indicator, visible: !indicator.visible } : indicator)),
          }));
        }}
        onRemoveIndicator={(indicatorId) => {
          setChartSettings((current) => ({
            ...current,
            indicators: current.indicators.filter((indicator) => indicator.id !== indicatorId),
          }));
        }}
        onToggleVolume={() => setChartSettings((current) => ({ ...current, showVolume: !current.showVolume }))}
        availableOverlays={OVERLAY_CATALOG}
        pendingOverlayId={pendingOverlayId}
        onPendingOverlayChange={setPendingOverlayId}
        onAddOverlay={() => {
          if (!pendingOverlayId) return;
          setCreateOverlayNonce((current) => current + 1);
        }}
        onClearOverlays={() => setClearDrawingsNonce((current) => current + 1)}
      />
    </div>
  );
}

// ─── Score bar ────────────────────────────────────────────────────────────────

function ScoreBar({ label, value, color = 'bg-blue-500' }: { label: string; value: number; color?: string }) {
  return (
    <div>
      <div className="flex justify-between text-xs mb-1">
        <span className="text-gray-600">{label}</span>
        <span className="font-semibold">{value.toFixed(0)}/100</span>
      </div>
      <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
        <div className={`h-full rounded-full transition-all ${color}`} style={{ width: `${value}%` }} />
      </div>
    </div>
  );
}

// ─── Indicator card ───────────────────────────────────────────────────────────

function IndicatorCard({ ind }: { ind: IndicatorSignal }) {
  const [expanded, setExpanded] = useState(false);
  const icon = ind.signal === 'BULLISH'
    ? <TrendingUp className="h-4 w-4 text-emerald-500" />
    : ind.signal === 'BEARISH'
    ? <TrendingDown className="h-4 w-4 text-red-500" />
    : <Minus className="h-4 w-4 text-gray-400" />;

  const border = ind.signal === 'BULLISH' ? 'border-l-emerald-400' : ind.signal === 'BEARISH' ? 'border-l-red-400' : 'border-l-gray-300';

  return (
    <div className={`border-l-4 ${border} bg-white rounded-r-lg p-3 shadow-sm cursor-pointer hover:shadow-md transition-shadow`} onClick={() => setExpanded(!expanded)}>
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          {icon}
          <span className="text-sm font-medium text-gray-800">{ind.name}</span>
        </div>
        <div className="flex items-center gap-2">
          {ind.value !== undefined && ind.value !== null && (
            <span className="text-xs text-gray-500">{ind.value.toFixed(2)}</span>
          )}
          <span className={`text-xs font-semibold ${IND_SIGNAL_STYLE[ind.signal]}`}>{ind.signal}</span>
          {expanded ? <ChevronUp className="h-3 w-3 text-gray-400" /> : <ChevronDown className="h-3 w-3 text-gray-400" />}
        </div>
      </div>
      {expanded && (
        <p className="mt-2 text-xs text-gray-600 leading-relaxed">{ind.interpretation}</p>
      )}
    </div>
  );
}

// ─── Similar period card ──────────────────────────────────────────────────────

function SimilarPeriodCard({ period }: { period: SimilarPeriod }) {
  const outcomeColor = period.outcome === 'BULLISH' ? 'bg-emerald-100 text-emerald-700' : period.outcome === 'BEARISH' ? 'bg-red-100 text-red-700' : 'bg-gray-100 text-gray-600';
  return (
    <div className="bg-white rounded-lg p-4 shadow-sm border border-gray-100">
      <div className="flex items-start justify-between mb-2">
        <div>
          <p className="text-xs text-gray-500">{period.start_date} → {period.end_date}</p>
          <div className="flex items-center gap-2 mt-1">
            <span className="text-xs font-medium text-blue-600">Similarity: {period.similarity_score}%</span>
            <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${outcomeColor}`}>{period.outcome}</span>
          </div>
        </div>
        {period.forward_30d_return_pct !== undefined && period.forward_30d_return_pct !== null && (
          <div className="text-right">
            <p className="text-xs text-gray-400">30d after</p>
            <p className={`text-sm font-bold ${period.forward_30d_return_pct >= 0 ? 'text-emerald-600' : 'text-red-500'}`}>
              {period.forward_30d_return_pct >= 0 ? '+' : ''}{period.forward_30d_return_pct.toFixed(1)}%
            </p>
          </div>
        )}
      </div>
      <p className="text-xs text-gray-600 leading-relaxed">{period.description}</p>
    </div>
  );
}

// ─── Main page ────────────────────────────────────────────────────────────────

export default function Stock360Page() {
  const searchParams = useSearchParams();
  const initialSymbol = searchParams.get('symbol')?.trim().toUpperCase() ?? '';
  const simId = searchParams.get('simId');
  const simulationId = simId ? Number.parseInt(simId, 10) : 0;
  const { data: sim } = useSimulation(simulationId || undefined);
  const simulationDate = sim?.current_sim_date?.split('T')[0] ?? undefined;

  const [inputValue, setInputValue] = useState(initialSymbol);
  const [activeSymbol, setActiveSymbol] = useState(initialSymbol);
  const [selectedPatternIndex, setSelectedPatternIndex] = useState<number>(-1);

  const { data, isLoading, isError, refetch } = useStock360View(activeSymbol, simulationDate);

  const handleSearch = () => {
    const sym = inputValue.trim().toUpperCase();
    if (sym) setActiveSymbol(sym);
  };

  const signal = data ? SIGNAL_STYLE[data.signal] ?? SIGNAL_STYLE.HOLD : null;
  const selectedSimilarPeriod =
    data && selectedPatternIndex >= 0 && selectedPatternIndex < data.similar_periods.length ? data.similar_periods[selectedPatternIndex] : null;

  React.useEffect(() => {
    setSelectedPatternIndex(-1);
  }, [activeSymbol]);

  return (
    <div className="max-w-6xl mx-auto space-y-6 py-6 px-4">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Stock 360° View</h1>
        <p className="text-sm text-gray-500 mt-1">
          Enter any NEPSE symbol to get a comprehensive historic analysis, indicator breakdown, trend view, and similar patterns.
        </p>
        {simulationDate && (
          <p className="mt-2 text-xs font-medium text-amber-700">
            Simulation guardrail active: 360 data is capped at {simulationDate}.
          </p>
        )}
      </div>

      {/* Search */}
      <Card>
        <CardContent className="p-4">
          <div className="flex gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                className="pl-9 uppercase"
                placeholder="Enter stock symbol (e.g. NABIL, NICA, SCB...)"
                value={inputValue}
                onChange={e => setInputValue(e.target.value.toUpperCase())}
                onKeyDown={e => e.key === 'Enter' && handleSearch()}
              />
            </div>
            <Button onClick={handleSearch} disabled={!inputValue.trim()}>
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

      {/* Loading */}
      {isLoading && (
        <div className="text-center py-16 text-gray-500">
          <div className="animate-spin h-10 w-10 border-4 border-blue-500 border-t-transparent rounded-full mx-auto mb-4" />
          <p>Analyzing {activeSymbol}…</p>
          <p className="text-xs mt-1">Fetching full history, indicators, and running pattern matching</p>
        </div>
      )}

      {/* Error */}
      {isError && !isLoading && (
        <Card>
          <CardContent className="p-8 text-center">
            <AlertCircle className="h-10 w-10 text-red-400 mx-auto mb-3" />
            <p className="text-gray-700 font-medium">Symbol not found or no data available</p>
            <p className="text-sm text-gray-500 mt-1">Try checking the symbol name (e.g. NABIL, NICA, SCB)</p>
          </CardContent>
        </Card>
      )}

      {/* Empty state */}
      {!activeSymbol && !isLoading && (
        <div className="text-center py-16 text-gray-400">
          <Search className="h-16 w-16 mx-auto mb-4 opacity-30" />
          <p className="text-lg font-medium">Search for a NEPSE stock symbol</p>
          <p className="text-sm mt-1">Get full historic analysis, technical indicators, trend breakdown, and similar historical patterns</p>
        </div>
      )}

      {/* 360 View Content */}
      {data && !isLoading && (
        <div className="space-y-6">
          {/* Top overview row */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {/* Symbol header */}
            <Card className="md:col-span-2">
              <CardContent className="p-5">
                <div className="flex items-start justify-between">
                  <div>
                    <div className="flex items-center gap-3">
                      <h2 className="text-3xl font-bold text-gray-900">{data.symbol}</h2>
                      {signal && (
                        <span className={`px-3 py-1 rounded-full text-sm font-semibold ${signal.bg} ${signal.text}`}>
                          {signal.label}
                        </span>
                      )}
                    </div>
                    <div className="flex items-baseline gap-3 mt-2">
                      <span className="text-2xl font-semibold text-gray-800">Rs. {fmt(data.current_price)}</span>
                      {data.change_pct !== undefined && (
                        <span className={`text-sm font-medium ${(data.change_pct ?? 0) >= 0 ? 'text-emerald-600' : 'text-red-500'}`}>
                          {(data.change_pct ?? 0) >= 0 ? '▲' : '▼'} {Math.abs(data.change_pct ?? 0).toFixed(2)}%
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-gray-400 mt-1">As of {data.analysis_date}</p>
                  </div>
                  <div className="text-right space-y-1">
                    <p className="text-xs text-gray-500">Overall Score</p>
                    <p className="text-4xl font-bold text-blue-600">{data.overall_score.toFixed(0)}</p>
                    <p className="text-xs text-gray-400">/ 100</p>
                  </div>
                </div>

                <div className="grid grid-cols-4 gap-3 mt-4 pt-4 border-t border-gray-100">
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

            {/* Score breakdown */}
            <Card>
              <CardContent className="p-5 space-y-4">
                <h3 className="text-sm font-semibold text-gray-700">Score Breakdown</h3>
                <ScoreBar label="Oscillator" value={data.oscillator_score} color="bg-purple-500" />
                <ScoreBar label="Trend" value={data.trend_score} color="bg-blue-500" />
                <ScoreBar label="Volume" value={data.volume_score} color="bg-amber-500" />
                <ScoreBar label="Volatility" value={data.volatility_score} color="bg-rose-500" />
                {data.entry_price && (
                  <div className="pt-3 border-t border-gray-100 space-y-1 text-xs">
                    <div className="flex justify-between"><span className="text-gray-500">Entry</span><span className="font-medium">Rs. {fmt(data.entry_price)}</span></div>
                    <div className="flex justify-between"><span className="text-gray-500">Target</span><span className="font-medium text-emerald-600">Rs. {fmt(data.target_price)}</span></div>
                    <div className="flex justify-between"><span className="text-gray-500">Stop Loss</span><span className="font-medium text-red-500">Rs. {fmt(data.stop_loss)}</span></div>
                    <div className="flex justify-between"><span className="text-gray-500">R:R</span><span className="font-medium">{fmt(data.risk_reward_ratio)}x</span></div>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Price Chart */}
          <Card>
            <CardContent className="p-5">
              <h3 className="text-sm font-semibold text-gray-700 mb-4">Price History</h3>
               <PriceChart symbol={data.symbol} history={data.price_history} selectedPeriod={selectedSimilarPeriod} />
             </CardContent>
           </Card>

          <Card className="border-indigo-100 bg-gradient-to-br from-indigo-50 via-white to-sky-50">
            <CardContent className="p-5">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <h3 className="text-sm font-semibold text-gray-700">Gemini Technical Read</h3>
                  <p className="text-xs text-gray-500 mt-1">Backend-generated commentary from the computed technical snapshot.</p>
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

          {/* Performance + Trend row */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Performance */}
            <Card>
              <CardContent className="p-5">
                <h3 className="text-sm font-semibold text-gray-700 mb-4">Performance</h3>
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

            {/* Trend Analysis */}
            <Card>
              <CardContent className="p-5">
                <h3 className="text-sm font-semibold text-gray-700 mb-4">Trend Analysis</h3>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-500">Primary Trend</span>
                    <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                      data.trend_analysis.primary_trend === 'UPTREND' ? 'bg-emerald-100 text-emerald-700' :
                      data.trend_analysis.primary_trend === 'DOWNTREND' ? 'bg-red-100 text-red-700' :
                      'bg-gray-100 text-gray-600'
                    }`}>{data.trend_analysis.primary_trend}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-500">Strength</span>
                    <span className="text-sm font-medium text-gray-700">{data.trend_analysis.trend_strength}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-500">MA Alignment</span>
                    <span className={`text-sm font-medium ${
                      data.trend_analysis.ma_alignment === 'BULLISH' ? 'text-emerald-600' :
                      data.trend_analysis.ma_alignment === 'BEARISH' ? 'text-red-500' : 'text-gray-600'
                    }`}>{data.trend_analysis.ma_alignment}</span>
                  </div>
                  {data.trend_analysis.golden_cross && (
                    <div className="text-xs bg-emerald-50 text-emerald-700 px-3 py-2 rounded-lg font-medium">✅ Golden Cross active (SMA50 &gt; SMA200)</div>
                  )}
                  {data.trend_analysis.death_cross && (
                    <div className="text-xs bg-red-50 text-red-700 px-3 py-2 rounded-lg font-medium">⚠️ Death Cross active (SMA50 &lt; SMA200)</div>
                  )}
                  {data.trend_analysis.ichimoku_signal && (
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-500">Ichimoku</span>
                      <span className={`text-sm font-medium ${IND_SIGNAL_STYLE[data.trend_analysis.ichimoku_signal]}`}>{data.trend_analysis.ichimoku_signal}</span>
                    </div>
                  )}
                  <div className="pt-2 border-t border-gray-100">
                    <div className="flex justify-between text-xs mb-1">
                      <span className="text-gray-400">Support</span>
                      <span className="font-medium text-emerald-600">Rs. {fmt(data.trend_analysis.support_level)}</span>
                    </div>
                    <div className="flex justify-between text-xs">
                      <span className="text-gray-400">Resistance</span>
                      <span className="font-medium text-red-500">Rs. {fmt(data.trend_analysis.resistance_level)}</span>
                    </div>
                  </div>
                  <p className="text-xs text-gray-500 leading-relaxed pt-2 border-t border-gray-100">{data.trend_analysis.summary}</p>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Key Signals */}
          {data.key_signals.length > 0 && (
            <Card>
              <CardContent className="p-5">
                <h3 className="text-sm font-semibold text-gray-700 mb-3">Key Signals</h3>
                <div className="flex flex-wrap gap-2">
                  {data.key_signals.map((sig, i) => (
                    <span key={i} className="px-3 py-1 bg-blue-50 text-blue-700 text-xs rounded-full font-medium">{sig}</span>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}

          {/* Indicator Dashboard */}
          <Card>
            <CardContent className="p-5">
              <h3 className="text-sm font-semibold text-gray-700 mb-4">Indicator Analysis</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {data.indicator_signals.map((ind, i) => (
                  <IndicatorCard key={i} ind={ind} />
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Similar Historical Periods */}
          {data.similar_periods.length > 0 && (
            <Card>
              <CardContent className="p-5">
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <h3 className="text-sm font-semibold text-gray-700">Similar Historical Patterns</h3>
                    <p className="text-xs text-gray-400 mt-0.5">Periods with similar indicator fingerprints — shows what happened next</p>
                  </div>
                  <div className="w-72">
                    <label htmlFor="pattern-select" className="block text-xs font-semibold uppercase tracking-wider text-gray-500 mb-1">
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
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
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
                <div className="mt-4 p-3 bg-amber-50 rounded-lg text-xs text-amber-700">
                  ⚠️ <strong>Disclaimer:</strong> Past patterns are not guaranteed to repeat. Use this analysis as one of many inputs for your investment decisions, not as financial advice.
                </div>
              </CardContent>
            </Card>
          )}

          {/* MA Position Table */}
          <Card>
            <CardContent className="p-5">
              <h3 className="text-sm font-semibold text-gray-700 mb-3">Price vs Moving Averages</h3>
              <div className="grid grid-cols-3 gap-3 text-center">
                {[
                  ['SMA 20', data.trend_analysis.price_vs_sma20],
                  ['SMA 50', data.trend_analysis.price_vs_sma50],
                  ['SMA 200', data.trend_analysis.price_vs_sma200],
                ].map(([label, pos]) => (
                  <div key={label as string} className={`rounded-lg p-3 ${pos === 'ABOVE' ? 'bg-emerald-50' : pos === 'BELOW' ? 'bg-red-50' : 'bg-gray-50'}`}>
                    <p className="text-xs text-gray-500">{label}</p>
                    <p className={`text-sm font-semibold mt-1 ${pos === 'ABOVE' ? 'text-emerald-600' : pos === 'BELOW' ? 'text-red-500' : 'text-gray-400'}`}>
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
