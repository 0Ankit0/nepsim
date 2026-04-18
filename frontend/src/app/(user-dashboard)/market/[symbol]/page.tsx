'use client';

import { isAxiosError } from 'axios';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { Suspense, use, useEffect, useMemo, useState } from 'react';
import { ArrowLeft, Loader2, ShoppingCart, TrendingDown, TrendingUp } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { MarketChartCard } from '@/components/market-chart/chart-card';
import type { ChartRange } from '@/components/market-chart/chart-config';
import {
  buildIndicatorHistory,
  buildPriceBars,
  filterByRange,
  formatCompactVolume,
  formatMoney,
  formatNumber,
  toDateKey,
} from '@/components/market-chart/data-utils';
import { useNepseHistory, useNepseIndicators, useNepseQuote, useSymbols, useTaLibIndicatorCatalog } from '@/hooks/useMarket';
import { useExecuteTrade, useSimulation } from '@/hooks/useSimulator';
import type { HistoricDataRow } from '@/api/market';

function SymbolDashboard({ symbol }: { symbol: string }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const simId = searchParams.get('simId');
  const simulationId = simId ? Number.parseInt(simId, 10) : 0;

  const { data: sim } = useSimulation(simulationId || undefined);
  const simulationStartDate = sim ? toDateKey(sim.period_start) : undefined;
  const simulationDate = sim ? toDateKey(sim.current_sim_date) : undefined;
  const { data: liveQuote, isLoading: isQuoteLoading } = useNepseQuote(symbol);
  const { data: history, isLoading: isHistoryLoading } = useNepseHistory(
    symbol,
    simulationStartDate ?? undefined,
    simulationDate ?? undefined,
    5000
  );
  const { data: indicatorHistory, isLoading: isIndicatorHistoryLoading } = useNepseIndicators(
    symbol,
    simulationStartDate ?? undefined,
    simulationDate ?? undefined,
    5000
  );
  const { data: symbols, isLoading: isSymbolsLoading } = useSymbols();
  const { data: talibCatalog } = useTaLibIndicatorCatalog();
  const executeTrade = useExecuteTrade(simulationId);

  const [tradeQuantity, setTradeQuantity] = useState('10');
  const [symbolSearch, setSymbolSearch] = useState(symbol);
  const [symbolSearchMessage, setSymbolSearchMessage] = useState<string | null>(null);
  const [symbolResultsOpen, setSymbolResultsOpen] = useState(false);
  const [selectedRange, setSelectedRange] = useState<ChartRange>('1Y');

  useEffect(() => {
    setSymbolSearch(symbol);
    setSymbolSearchMessage(null);
  }, [symbol]);

  const priceBars = useMemo(() => buildPriceBars(history?.data ?? []), [history?.data]);
  const indicators = useMemo(() => buildIndicatorHistory(indicatorHistory?.data ?? []), [indicatorHistory?.data]);
  const latestIndicatorSnapshot = indicators.length > 0 ? indicators[indicators.length - 1] : null;
  const filteredPriceBars = useMemo(() => filterByRange(priceBars, selectedRange), [priceBars, selectedRange]);

  const simulatedQuote = useMemo(() => {
    if (!simulationDate) {
      return liveQuote;
    }

    const rows = [...(history?.data ?? [])].sort((left: HistoricDataRow, right: HistoricDataRow) =>
      (toDateKey(left.date) ?? '').localeCompare(toDateKey(right.date) ?? '')
    );
    const latestRow = rows.length > 0 ? rows[rows.length - 1] : null;
    if (!latestRow) {
      return liveQuote;
    }

    return {
      symbol,
      date: latestRow.date,
      ltp: latestRow.ltp ?? latestRow.close,
      open: latestRow.open,
      high: latestRow.high,
      low: latestRow.low,
      close: latestRow.close,
      prev_close: latestRow.prev_close ?? null,
      diff: latestRow.diff ?? null,
      diff_pct: latestRow.diff_pct ?? null,
      vwap: latestRow.vwap ?? null,
      vol: latestRow.vol ?? null,
      turnover: latestRow.turnover ?? null,
      weeks_52_high: latestRow.weeks_52_high ?? null,
      weeks_52_low: latestRow.weeks_52_low ?? null,
    };
  }, [history?.data, liveQuote, simulationDate, symbol]);

  const symbolMatches = useMemo(() => {
    if (!symbols || symbolSearch.trim().length === 0) return [];

    const query = symbolSearch.trim().toUpperCase();
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
  }, [symbolSearch, symbols]);

  const quote = simulatedQuote;
  const isUp = (quote?.diff_pct ?? 0) >= 0;

  const buildSymbolHref = (nextSymbol: string): string => {
    const basePath = `/market/${encodeURIComponent(nextSymbol.toUpperCase())}`;
    return simId ? `${basePath}?simId=${encodeURIComponent(simId)}` : basePath;
  };

  const handleSymbolSubmit = (candidate?: string) => {
    const nextSymbol = (candidate ?? symbolSearch).trim().toUpperCase();

    if (!nextSymbol) {
      setSymbolSearchMessage('Enter a stock symbol to open its chart.');
      return;
    }

    if (symbols && !symbols.includes(nextSymbol)) {
      setSymbolSearchMessage(`No NEPSE symbol matched "${nextSymbol}".`);
      setSymbolResultsOpen(true);
      return;
    }

    setSymbolSearchMessage(null);
    setSymbolResultsOpen(false);

    if (nextSymbol === symbol) {
      return;
    }

    router.push(buildSymbolHref(nextSymbol));
  };

  const handleTrade = (side: 'buy' | 'sell') => {
    const quantity = Number.parseInt(tradeQuantity, 10);

    if (!Number.isFinite(quantity) || quantity <= 0) {
      window.alert('Enter a valid quantity.');
      return;
    }

    executeTrade.mutate(
      { symbol, side, quantity },
      {
        onSuccess: () => {
          window.alert(`Successfully placed ${side} order for ${quantity} shares of ${symbol}!`);
        },
        onError: (error: unknown) => {
          if (isAxiosError<{ detail?: string }>(error)) {
            window.alert(error.response?.data?.detail ?? 'Trade failed.');
            return;
          }

          window.alert(error instanceof Error ? error.message : 'Trade failed.');
        },
      }
    );
  };

  return (
    <div className="space-y-6">
      <Link
        href={simId ? `/simulator/${simId}` : '/market'}
        className="flex w-fit items-center gap-1 text-sm font-medium text-indigo-600 hover:text-indigo-700"
      >
        <ArrowLeft className="h-4 w-4" /> {simId ? `Back to Simulator #${simId}` : 'Back to Market'}
      </Link>

      <div className="flex flex-col gap-4 xl:flex-row xl:items-start xl:justify-between">
        <div className="space-y-2">
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="text-3xl font-bold text-slate-950">{symbol}</h1>
            <span className="rounded-full border border-sky-200 bg-sky-50 px-3 py-1 text-xs font-semibold text-sky-700">
              Pro chart mode
            </span>
          </div>
          <p className="max-w-3xl text-sm text-slate-500">
            A cleaner chart desk with the drawing toolbar on the left and indicator controls inside the chart itself.
          </p>
          {simulationDate && (
            <p className="text-xs font-medium text-indigo-600">
              Simulation window: {simulationStartDate ?? simulationDate} to {simulationDate}
            </p>
          )}
        </div>

        {!isQuoteLoading && quote && (
          <div className="min-w-72 rounded-3xl border border-slate-200 bg-white px-5 py-4 shadow-sm">
            <div className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-400">Latest price</div>
            <div className="mt-2 text-3xl font-bold text-slate-950">{formatMoney(quote.ltp)}</div>
            <div className={`mt-1 flex items-center gap-1 font-bold ${isUp ? 'text-emerald-600' : 'text-rose-600'}`}>
              {isUp ? <TrendingUp className="h-4 w-4" /> : <TrendingDown className="h-4 w-4" />}
              {quote.diff != null ? `${quote.diff >= 0 ? '+' : ''}${quote.diff.toFixed(2)}` : '-'}{' '}
              ({quote.diff_pct != null ? `${quote.diff_pct >= 0 ? '+' : ''}${quote.diff_pct.toFixed(2)}%` : '-'})
            </div>
            <div className="mt-2 text-xs text-slate-400">Updated {quote.date ?? '-'}</div>
          </div>
        )}
      </div>

      <MarketChartCard
        symbol={symbol}
        symbolSearch={symbolSearch}
        onSymbolSearchChange={(value) => {
          setSymbolSearch(value);
          setSymbolSearchMessage(null);
        }}
        onOpenSymbol={handleSymbolSubmit}
        symbolSearchMessage={symbolSearchMessage}
        symbolMatches={symbolMatches}
        symbolResultsOpen={symbolResultsOpen}
        onSymbolResultsOpenChange={setSymbolResultsOpen}
        isSymbolsLoading={isSymbolsLoading}
        selectedRange={selectedRange}
        onRangeChange={setSelectedRange}
        priceBars={filteredPriceBars}
        allSymbols={symbols}
        isHistoryLoading={isHistoryLoading || isIndicatorHistoryLoading}
        talibCatalog={talibCatalog?.data}
        indicatorAsOfDate={simulationDate ?? undefined}
      />

      <div className={`grid grid-cols-1 gap-6 ${simId ? 'xl:grid-cols-3' : 'xl:grid-cols-2'}`}>
        {simId && (
          <Card className="border-indigo-100 shadow-sm">
            <CardHeader className="border-b border-indigo-100 bg-indigo-600 py-4 text-white">
              <CardTitle className="flex items-center gap-2 text-sm">
                <ShoppingCart className="h-4 w-4" />
                Execute Simulation Trade
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4 p-4">
              <div className="space-y-2">
                <label htmlFor="trade-quantity" className="text-xs font-bold uppercase tracking-wider text-slate-600">
                  Quantity (Shares)
                </label>
                <Input
                  id="trade-quantity"
                  type="number"
                  min="10"
                  step="10"
                  value={tradeQuantity}
                  onChange={(event) => setTradeQuantity(event.target.value)}
                  className="font-mono text-lg"
                />
              </div>
              <div className="grid grid-cols-2 gap-3 pt-2">
                <Button
                  type="button"
                  className="w-full bg-emerald-600 font-bold text-white hover:bg-emerald-700"
                  onClick={() => handleTrade('buy')}
                  disabled={executeTrade.isPending}
                >
                  {executeTrade.isPending && executeTrade.variables?.side === 'buy' ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                  Buy
                </Button>
                <Button
                  type="button"
                  className="w-full bg-rose-600 font-bold text-white hover:bg-rose-700"
                  onClick={() => handleTrade('sell')}
                  disabled={executeTrade.isPending}
                >
                  {executeTrade.isPending && executeTrade.variables?.side === 'sell' ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                  Sell
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        <Card className="border-slate-200 shadow-sm">
          <CardHeader className="border-b border-slate-200 bg-slate-50/80 py-3">
            <CardTitle className="text-sm font-semibold text-slate-600">Latest Snapshot</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3 p-4 text-sm">
            <div className="flex justify-between border-b border-slate-100 pb-2">
              <span className="text-slate-500">Close</span>
              <span className="font-mono font-medium">{formatNumber(quote?.close)}</span>
            </div>
            <div className="flex justify-between border-b border-slate-100 pb-2">
              <span className="text-slate-500">Open</span>
              <span className="font-mono font-medium">{formatNumber(quote?.open)}</span>
            </div>
            <div className="flex justify-between border-b border-slate-100 pb-2">
              <span className="text-slate-500">High / Low</span>
              <span className="font-mono font-medium">
                {formatNumber(quote?.high)} / {formatNumber(quote?.low)}
              </span>
            </div>
            <div className="flex justify-between border-b border-slate-100 pb-2">
              <span className="text-slate-500">Volume</span>
              <span className="font-mono font-medium">{quote?.vol != null ? formatCompactVolume(quote.vol) : '-'}</span>
            </div>
            <div className="flex justify-between border-b border-slate-100 pb-2">
              <span className="text-slate-500">VWAP</span>
              <span className="font-mono font-medium">{formatNumber(quote?.vwap)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">52W Range</span>
              <span className="font-mono text-xs font-medium">
                {formatNumber(quote?.weeks_52_low)} - {formatNumber(quote?.weeks_52_high)}
              </span>
            </div>
          </CardContent>
        </Card>

        <Card className="border-slate-200 shadow-sm">
          <CardHeader className="border-b border-slate-200 bg-slate-50/80 py-3">
            <CardTitle className="text-sm font-semibold text-slate-600">Indicator Snapshot</CardTitle>
          </CardHeader>
          <CardContent className="grid grid-cols-2 gap-4 p-4 text-sm">
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">RSI (14)</div>
              <div className="font-mono text-lg font-bold">{formatNumber(latestIndicatorSnapshot?.rsi_14)}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">MACD</div>
              <div className="font-mono text-lg font-bold">{formatNumber(latestIndicatorSnapshot?.macd_line)}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">SMA 20</div>
              <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.sma_20)}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">SMA 50</div>
              <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.sma_50)}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">BB Upper</div>
              <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.bb_upper)}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">ADX (14)</div>
              <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.adx_14)}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">ATR (14)</div>
              <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.atr_14)}</div>
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">Rel. Volume</div>
              <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.volume_ratio_20)}</div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

export default function SymbolPage({ params }: { params: Promise<{ symbol: string }> }) {
  const resolvedParams = use(params);
  const symbol = decodeURIComponent(resolvedParams.symbol);

  return (
    <Suspense fallback={<div>Loading symbol dashboard...</div>}>
      <SymbolDashboard symbol={symbol} />
    </Suspense>
  );
}
