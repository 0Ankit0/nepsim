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
import {
  cloneSettings,
  createLayoutNotice,
  DEFAULT_LAYOUT_SETTINGS,
  getIndicatorMeta,
  INDICATOR_CATALOG,
  LAYOUT_STORAGE_KEY,
  OVERLAY_CATALOG,
  normalizeStoredLayout,
  upsertIndicator,
  type IndicatorId,
  type IndicatorPreset,
  type LayoutNotice,
  type OverlayId,
  type SavedChartLayout,
} from '@/components/market-chart/chart-config';
import { MarketChartLayoutsPanel } from '@/components/market-chart/layouts-panel';
import { MarketChartToolsPanel } from '@/components/market-chart/tools-panel';
import {
  buildIndicatorHistory,
  buildPriceBars,
  filterByRange,
  formatCompactVolume,
  formatMoney,
  formatNumber,
  toDateKey,
} from '@/components/market-chart/data-utils';
import { useNepseHistory, useNepseIndicators, useNepseQuote, useSymbols } from '@/hooks/useMarket';
import { useExecuteTrade, useSimulation } from '@/hooks/useSimulator';
import type { HistoricDataRow } from '@/api/market';

function SymbolDashboard({ symbol }: { symbol: string }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const simId = searchParams.get('simId');
  const simulationId = simId ? Number.parseInt(simId, 10) : 0;

  const { data: sim } = useSimulation(simulationId || undefined);
  const simulationDate = sim ? toDateKey(sim.current_sim_date) : undefined;
  const { data: liveQuote, isLoading: isQuoteLoading } = useNepseQuote(symbol);
  const { data: history, isLoading: isHistoryLoading } = useNepseHistory(symbol, undefined, simulationDate ?? undefined, 5000);
  const { data: indicatorHistory, isLoading: isIndicatorHistoryLoading } = useNepseIndicators(
    symbol,
    undefined,
    simulationDate ?? undefined,
    5000
  );
  const { data: symbols, isLoading: isSymbolsLoading } = useSymbols();

  const executeTrade = useExecuteTrade(simulationId);

  const [tradeQuantity, setTradeQuantity] = useState('10');
  const [symbolSearch, setSymbolSearch] = useState(symbol);
  const [symbolSearchMessage, setSymbolSearchMessage] = useState<string | null>(null);
  const [symbolResultsOpen, setSymbolResultsOpen] = useState(false);
  const [layoutName, setLayoutName] = useState('');
  const [layoutNotice, setLayoutNotice] = useState<LayoutNotice | null>(null);
  const [savedLayouts, setSavedLayouts] = useState<SavedChartLayout[]>([]);
  const [chartSettings, setChartSettings] = useState(() => cloneSettings(DEFAULT_LAYOUT_SETTINGS));
  const [pendingIndicatorId, setPendingIndicatorId] = useState<IndicatorId | ''>('');
  const [pendingOverlayId, setPendingOverlayId] = useState<OverlayId | ''>(OVERLAY_CATALOG[0]?.id ?? '');
  const [createOverlayNonce, setCreateOverlayNonce] = useState(0);
  const [clearDrawingsNonce, setClearDrawingsNonce] = useState(0);

  useEffect(() => {
    setSymbolSearch(symbol);
    setSymbolSearchMessage(null);
  }, [symbol]);

  useEffect(() => {
    const rawLayouts = window.localStorage.getItem(LAYOUT_STORAGE_KEY);
    if (!rawLayouts) return;

    try {
      const parsed = JSON.parse(rawLayouts) as unknown;
      if (!Array.isArray(parsed)) {
        throw new Error('Expected an array of layouts.');
      }

      const nextLayouts = parsed
        .map(normalizeStoredLayout)
        .filter((layout): layout is SavedChartLayout => layout !== null);

      setSavedLayouts(nextLayouts);
    } catch (error) {
      console.error('Unable to load market chart layouts.', error);
      window.localStorage.removeItem(LAYOUT_STORAGE_KEY);
      setLayoutNotice(createLayoutNotice('error', 'Saved chart layouts were reset because the stored data was invalid.'));
    }
  }, []);

  const priceBars = useMemo(() => buildPriceBars(history?.data ?? []), [history?.data]);
  const indicators = useMemo(() => buildIndicatorHistory(indicatorHistory?.data ?? []), [indicatorHistory?.data]);
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

  const filteredPriceBars = useMemo(() => filterByRange(priceBars, chartSettings.range), [chartSettings.range, priceBars]);

  const latestIndicatorSnapshot = indicators.length > 0 ? indicators[indicators.length - 1] : null;

  const availableIndicators = useMemo(
    () => INDICATOR_CATALOG.filter((candidate) => !chartSettings.indicators.some((indicator) => indicator.id === candidate.id)),
    [chartSettings.indicators]
  );

  useEffect(() => {
    if (availableIndicators.length === 0) {
      setPendingIndicatorId('');
      return;
    }

    if (pendingIndicatorId && availableIndicators.some((indicator) => indicator.id === pendingIndicatorId)) {
      return;
    }

    setPendingIndicatorId(availableIndicators[0]?.id ?? '');
  }, [availableIndicators, pendingIndicatorId]);

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

  const saveLayouts = (nextLayouts: SavedChartLayout[]) => {
    window.localStorage.setItem(LAYOUT_STORAGE_KEY, JSON.stringify(nextLayouts));
    setSavedLayouts(nextLayouts);
  };

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

  const handleAddIndicator = () => {
    if (!pendingIndicatorId) {
      setLayoutNotice(createLayoutNotice('info', 'All available indicators are already in the current layout.'));
      return;
    }

    const meta = getIndicatorMeta(pendingIndicatorId);
    setChartSettings((current) => ({
      ...current,
      indicators: upsertIndicator(current.indicators, { id: pendingIndicatorId, visible: true }),
    }));
    setLayoutNotice(createLayoutNotice('success', `${meta.label} was added to the chart.`));
  };

  const handleToggleIndicatorVisibility = (indicatorId: IndicatorId) => {
    const meta = getIndicatorMeta(indicatorId);
    setChartSettings((current) => ({
      ...current,
      indicators: current.indicators.map((indicator) =>
        indicator.id === indicatorId ? { ...indicator, visible: !indicator.visible } : indicator
      ),
    }));
    setLayoutNotice(createLayoutNotice('info', `${meta.label} visibility was updated.`));
  };

  const handleRemoveIndicator = (indicatorId: IndicatorId) => {
    const meta = getIndicatorMeta(indicatorId);
    setChartSettings((current) => ({
      ...current,
      indicators: current.indicators.filter((indicator) => indicator.id !== indicatorId),
    }));
    setLayoutNotice(createLayoutNotice('info', `${meta.label} was removed from the chart.`));
  };

  const applyPreset = (preset: IndicatorPreset) => {
    if (preset === 'reset') {
      setChartSettings(cloneSettings(DEFAULT_LAYOUT_SETTINGS));
      setLayoutNotice(createLayoutNotice('info', 'Chart settings were reset to the default layout.'));
      return;
    }

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
      setLayoutNotice(createLayoutNotice('success', 'Trend preset applied.'));
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
      setLayoutNotice(createLayoutNotice('success', 'Momentum preset applied.'));
      return;
    }

    setChartSettings(cloneSettings(DEFAULT_LAYOUT_SETTINGS));
    setLayoutNotice(createLayoutNotice('info', 'Chart settings were reset to the default layout.'));
  };

  const handleSaveLayout = () => {
    const trimmedName = layoutName.trim();

    if (!trimmedName) {
      setLayoutNotice(createLayoutNotice('error', 'Enter a layout name before saving the current chart setup.'));
      return;
    }

    const nextLayout: SavedChartLayout = {
      id: `layout-${Date.now()}-${Math.round(Math.random() * 1_000_000)}`,
      name: trimmedName,
      updatedAt: new Date().toISOString(),
      settings: cloneSettings(chartSettings),
    };

    const existingIndex = savedLayouts.findIndex((layout) => layout.name.toLowerCase() === trimmedName.toLowerCase());
    const nextLayouts =
      existingIndex >= 0
        ? savedLayouts.map((layout, index) => (index === existingIndex ? { ...nextLayout, id: layout.id } : layout))
        : [nextLayout, ...savedLayouts].slice(0, 12);

    try {
      saveLayouts(nextLayouts);
      setLayoutNotice(
        createLayoutNotice('success', existingIndex >= 0 ? `Updated layout "${trimmedName}".` : `Saved layout "${trimmedName}".`)
      );
      setLayoutName('');
    } catch (error) {
      console.error('Unable to save market chart layouts.', error);
      setLayoutNotice(createLayoutNotice('error', 'Unable to save the layout to this browser.'));
    }
  };

  const handleLoadLayout = (layoutId: string) => {
    const layout = savedLayouts.find((item) => item.id === layoutId);
    if (!layout) {
      setLayoutNotice(createLayoutNotice('error', 'That saved layout is no longer available.'));
      return;
    }

    setChartSettings(cloneSettings(layout.settings));
    setLayoutNotice(createLayoutNotice('success', `Loaded layout "${layout.name}".`));
  };

  const handleDeleteLayout = (layoutId: string) => {
    const layout = savedLayouts.find((item) => item.id === layoutId);
    if (!layout) {
      setLayoutNotice(createLayoutNotice('error', 'That saved layout is no longer available.'));
      return;
    }

    try {
      const nextLayouts = savedLayouts.filter((item) => item.id !== layoutId);
      saveLayouts(nextLayouts);
      setLayoutNotice(createLayoutNotice('info', `Deleted layout "${layout.name}".`));
    } catch (error) {
      console.error('Unable to delete market chart layout.', error);
      setLayoutNotice(createLayoutNotice('error', 'Unable to update saved layouts in this browser.'));
    }
  };

  const handleToggleVolume = () => {
    setChartSettings((current) => ({ ...current, showVolume: !current.showVolume }));
    setLayoutNotice(
      createLayoutNotice('info', chartSettings.showVolume ? 'Volume panel hidden from the chart.' : 'Volume panel added to the chart.')
    );
  };

  const handleTrade = (side: 'buy' | 'sell') => {
    const quantity = Number.parseInt(tradeQuantity, 10);

    if (!Number.isFinite(quantity) || quantity <= 0) {
      window.alert('Enter a valid quantity');
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
            window.alert(error.response?.data?.detail ?? 'Trade Failed');
            return;
          }

          window.alert(error instanceof Error ? error.message : 'Trade Failed');
        },
      }
    );
  };

  return (
    <div className="space-y-6">
      <Link href={simId ? `/simulator/${simId}` : '/market'} className="text-sm font-medium text-indigo-600 hover:text-indigo-700 flex items-center gap-1 w-fit">
        <ArrowLeft className="h-4 w-4" /> {simId ? `Back to Simulator #${simId}` : 'Back to Market'}
      </Link>

      <div className="flex flex-col gap-4 xl:flex-row xl:items-start xl:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-3">
            <h1 className="text-3xl font-bold text-gray-900">{symbol}</h1>
            <span className="rounded-full bg-indigo-50 px-3 py-1 text-xs font-semibold text-indigo-700 border border-indigo-100">
              Advanced Chart Workspace
            </span>
          </div>
          <p className="text-gray-500">Search symbols, switch durations, save layouts, and manage indicator panels directly on the chart.</p>
          {simulationDate && (
            <p className="text-xs font-medium text-indigo-600">Simulation view through {simulationDate}</p>
          )}
        </div>

        {!isQuoteLoading && quote && (
          <div className="rounded-2xl border border-gray-200 bg-white px-5 py-4 shadow-sm min-w-65">
            <div className="text-xs font-semibold uppercase tracking-wider text-gray-400">Latest Price</div>
            <div className="mt-2 text-3xl font-mono font-bold text-gray-900">{formatMoney(quote.ltp)}</div>
            <div className={`mt-1 flex items-center gap-1 font-bold ${isUp ? 'text-emerald-600' : 'text-rose-600'}`}>
              {isUp ? <TrendingUp className="h-4 w-4" /> : <TrendingDown className="h-4 w-4" />}
              {quote.diff != null ? `${quote.diff >= 0 ? '+' : ''}${quote.diff.toFixed(2)}` : '-'}{' '}
              ({quote.diff_pct != null ? `${quote.diff_pct >= 0 ? '+' : ''}${quote.diff_pct.toFixed(2)}%` : '-'})
            </div>
            <div className="mt-2 text-xs text-gray-400">Updated {quote.date ?? '-'}</div>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
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
          chartSettings={chartSettings}
          onChartStyleChange={(chartStyle) => setChartSettings((current) => ({ ...current, chartStyle }))}
          onRangeChange={(range) => setChartSettings((current) => ({ ...current, range }))}
          pendingOverlayId={pendingOverlayId}
          createOverlayNonce={createOverlayNonce}
          clearDrawingsNonce={clearDrawingsNonce}
          priceBars={filteredPriceBars}
          isHistoryLoading={isHistoryLoading}
          isIndicatorHistoryLoading={isIndicatorHistoryLoading}
        />

        <div className="space-y-6">
          <MarketChartToolsPanel
            chartSettings={chartSettings}
            availableIndicators={availableIndicators}
            pendingIndicatorId={pendingIndicatorId}
            onPendingIndicatorChange={setPendingIndicatorId}
            onAddIndicator={handleAddIndicator}
            onApplyPreset={applyPreset}
            onToggleIndicatorVisibility={handleToggleIndicatorVisibility}
            onRemoveIndicator={handleRemoveIndicator}
            onToggleVolume={handleToggleVolume}
            availableOverlays={OVERLAY_CATALOG}
            pendingOverlayId={pendingOverlayId}
            onPendingOverlayChange={setPendingOverlayId}
            onAddOverlay={() => {
              if (!pendingOverlayId) {
                setLayoutNotice(createLayoutNotice('info', 'Pick a drawing tool before adding it to the chart.'));
                return;
              }
              setCreateOverlayNonce((current) => current + 1);
              setLayoutNotice(createLayoutNotice('success', 'Drawing tool armed on the chart. Click inside the chart to place it.'));
            }}
            onClearOverlays={() => {
              setClearDrawingsNonce((current) => current + 1);
              setLayoutNotice(createLayoutNotice('info', 'Chart drawings were cleared.'));
            }}
          />

          <MarketChartLayoutsPanel
            layoutName={layoutName}
            onLayoutNameChange={setLayoutName}
            onSaveLayout={handleSaveLayout}
            layoutNotice={layoutNotice}
            savedLayouts={savedLayouts}
            onLoadLayout={handleLoadLayout}
            onDeleteLayout={handleDeleteLayout}
          />

          {simId && (
            <Card className="shadow-lg border-indigo-200">
              <CardHeader className="bg-indigo-600 text-white rounded-t-xl py-4">
                <CardTitle className="text-sm flex items-center gap-2">
                  <ShoppingCart className="h-4 w-4" />
                  Execute Simulation Trade
                </CardTitle>
              </CardHeader>
              <CardContent className="p-4 space-y-4">
                <div className="space-y-2">
                  <label htmlFor="trade-quantity" className="text-xs font-bold text-gray-600 uppercase tracking-wider">
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
                    className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold"
                    onClick={() => handleTrade('buy')}
                    disabled={executeTrade.isPending}
                  >
                    {executeTrade.isPending && executeTrade.variables?.side === 'buy' ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                    Buy
                  </Button>
                  <Button
                    type="button"
                    className="w-full bg-rose-600 hover:bg-rose-700 text-white font-bold"
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

          <Card className="shadow-sm border-gray-100">
            <CardHeader className="border-b border-gray-100 bg-gray-50/50 py-3">
              <CardTitle className="text-sm font-semibold text-gray-600">Latest Snapshot</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 p-4 text-sm">
              <div className="flex justify-between border-b pb-2">
                <span className="text-gray-500">Close</span>
                <span className="font-mono font-medium">{formatNumber(quote?.close)}</span>
              </div>
              <div className="flex justify-between border-b pb-2">
                <span className="text-gray-500">Open</span>
                <span className="font-mono font-medium">{formatNumber(quote?.open)}</span>
              </div>
              <div className="flex justify-between border-b pb-2">
                <span className="text-gray-500">High / Low</span>
                <span className="font-mono font-medium">
                  {formatNumber(quote?.high)} / {formatNumber(quote?.low)}
                </span>
              </div>
              <div className="flex justify-between border-b pb-2">
                <span className="text-gray-500">Volume</span>
                <span className="font-mono font-medium">{quote?.vol != null ? formatCompactVolume(quote.vol) : '-'}</span>
              </div>
              <div className="flex justify-between border-b pb-2">
                <span className="text-gray-500">VWAP</span>
                <span className="font-mono font-medium">{formatNumber(quote?.vwap)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">52W Range</span>
                <span className="font-mono font-medium text-xs">
                  {formatNumber(quote?.weeks_52_low)} - {formatNumber(quote?.weeks_52_high)}
                </span>
              </div>
            </CardContent>
          </Card>

          <Card className="shadow-sm border-gray-100">
            <CardHeader className="border-b border-gray-100 bg-gray-50/50 py-3">
              <CardTitle className="text-sm font-semibold text-gray-600">Indicator Snapshot</CardTitle>
            </CardHeader>
            <CardContent className="grid grid-cols-2 gap-4 p-4 text-sm">
              <div>
                <div className="text-gray-500 text-xs uppercase tracking-wider">RSI (14)</div>
                <div className="font-mono font-bold text-lg">{formatNumber(latestIndicatorSnapshot?.rsi_14)}</div>
              </div>
              <div>
                <div className="text-gray-500 text-xs uppercase tracking-wider">MACD</div>
                <div className="font-mono font-bold text-lg">{formatNumber(latestIndicatorSnapshot?.macd_line)}</div>
              </div>
              <div>
                <div className="text-gray-500 text-xs uppercase tracking-wider">SMA 20</div>
                <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.sma_20)}</div>
              </div>
              <div>
                <div className="text-gray-500 text-xs uppercase tracking-wider">SMA 50</div>
                <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.sma_50)}</div>
              </div>
              <div>
                <div className="text-gray-500 text-xs uppercase tracking-wider">BB Upper</div>
                <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.bb_upper)}</div>
              </div>
              <div>
                <div className="text-gray-500 text-xs uppercase tracking-wider">ADX (14)</div>
                <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.adx_14)}</div>
              </div>
              <div>
                <div className="text-gray-500 text-xs uppercase tracking-wider">ATR (14)</div>
                <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.atr_14)}</div>
              </div>
              <div>
                <div className="text-gray-500 text-xs uppercase tracking-wider">Rel. Volume</div>
                <div className="font-mono font-bold">{formatNumber(latestIndicatorSnapshot?.volume_ratio_20)}</div>
              </div>
            </CardContent>
          </Card>
        </div>
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
