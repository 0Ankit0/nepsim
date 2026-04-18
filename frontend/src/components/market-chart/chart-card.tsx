'use client';

import { Check, LayoutTemplate, MoonStar, Plus, Search, Sparkles, SunMedium } from 'lucide-react';
import { useEffect, useMemo, useRef, useState } from 'react';
import type { TaLibIndicatorCatalogItem } from '@/api/market';
import { useTaLibIndicatorLatest } from '@/hooks/useMarket';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import {
  DEFAULT_LAYOUT_SETTINGS,
  INDICATOR_CATALOG,
  RANGE_OPTIONS,
  type ActiveIndicator,
  type ChartRange,
  type ChartTheme,
  type PriceBar,
  type SavedChartLayout,
  createLayoutNotice,
  getIndicatorMeta,
  readStoredLayouts,
  writeStoredLayouts,
  upsertIndicator,
} from './chart-config';
import { MarketChartCanvas } from './chart-canvas';

interface MarketChartCardProps {
  symbol: string;
  priceBars: PriceBar[];
  selectedRange: ChartRange;
  onRangeChange: (range: ChartRange) => void;
  allSymbols?: string[];
  isHistoryLoading: boolean;
  highlightedRange?: {
    startDate: string;
    endDate: string;
  } | null;
  talibCatalog?: TaLibIndicatorCatalogItem[];
  indicatorAsOfDate?: string;
  title?: string;
  description?: string;
  badgeLabel?: string;
  emptyMessage?: string;
  symbolSearch?: string;
  onSymbolSearchChange?: (value: string) => void;
  onOpenSymbol?: (candidate?: string) => void;
  symbolSearchMessage?: string | null;
  symbolMatches?: string[];
  symbolResultsOpen?: boolean;
  onSymbolResultsOpenChange?: (open: boolean) => void;
  isSymbolsLoading?: boolean;
  hideSymbolSearch?: boolean;
}

function useClickOutside(ref: React.RefObject<HTMLElement | null>, onOutsideClick: () => void) {
  useEffect(() => {
    const handleMouseDown = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        onOutsideClick();
      }
    };

    document.addEventListener('mousedown', handleMouseDown);
    return () => document.removeEventListener('mousedown', handleMouseDown);
  }, [onOutsideClick, ref]);
}

function formatOutputLabel(value: string) {
  return value.replace(/_/g, ' ');
}

export function MarketChartCard({
  symbol,
  priceBars,
  selectedRange,
  onRangeChange,
  allSymbols,
  isHistoryLoading,
  highlightedRange = null,
  talibCatalog = [],
  indicatorAsOfDate,
  title,
  description,
  badgeLabel = 'Pro chart workspace',
  emptyMessage,
  symbolSearch = '',
  onSymbolSearchChange,
  onOpenSymbol,
  symbolSearchMessage = null,
  symbolMatches = [],
  symbolResultsOpen = false,
  onSymbolResultsOpenChange,
  isSymbolsLoading = false,
  hideSymbolSearch = false,
}: MarketChartCardProps) {
  const symbolSearchRef = useRef<HTMLDivElement>(null);
  const [theme, setTheme] = useState<ChartTheme>(DEFAULT_LAYOUT_SETTINGS.theme);
  const [activeIndicators, setActiveIndicators] = useState<ActiveIndicator[]>(DEFAULT_LAYOUT_SETTINGS.indicators);
  const [savedLayouts, setSavedLayouts] = useState<SavedChartLayout[]>([]);
  const [selectedLayoutId, setSelectedLayoutId] = useState('');
  const [layoutNotice, setLayoutNotice] = useState<ReturnType<typeof createLayoutNotice> | null>(null);
  const [indicatorQuery, setIndicatorQuery] = useState('');
  const [selectedTalibIndicator, setSelectedTalibIndicator] = useState<string>('RSI');

  useClickOutside(symbolSearchRef, () => onSymbolResultsOpenChange?.(false));

  useEffect(() => {
    setSavedLayouts(readStoredLayouts());
  }, []);

  useEffect(() => {
    if (!talibCatalog.length) {
      return;
    }

    const exists = talibCatalog.some((indicator) => indicator.name === selectedTalibIndicator);
    if (!exists) {
      setSelectedTalibIndicator(talibCatalog[0].name);
    }
  }, [selectedTalibIndicator, talibCatalog]);

  useEffect(() => {
    if (!layoutNotice) {
      return;
    }

    const timeout = window.setTimeout(() => setLayoutNotice(null), 2500);
    return () => window.clearTimeout(timeout);
  }, [layoutNotice]);

  const { data: talibSnapshot } = useTaLibIndicatorLatest(symbol, selectedTalibIndicator, indicatorAsOfDate);

  const visibleIndicators = useMemo(
    () => activeIndicators.filter((indicator) => indicator.visible),
    [activeIndicators]
  );
  const mainIndicators = useMemo(
    () => visibleIndicators.filter((indicator) => getIndicatorMeta(indicator.id).group === 'overlay').map((indicator) => indicator.id),
    [visibleIndicators]
  );
  const subIndicators = useMemo(
    () => visibleIndicators.filter((indicator) => getIndicatorMeta(indicator.id).group === 'pane').map((indicator) => indicator.id),
    [visibleIndicators]
  );

  const normalizedQuery = indicatorQuery.trim().toUpperCase();
  const chartIndicatorMatches = useMemo(
    () =>
      INDICATOR_CATALOG.filter((indicator) => {
        if (!normalizedQuery) {
          return true;
        }
        return (
          indicator.id.includes(normalizedQuery) ||
          indicator.label.toUpperCase().includes(normalizedQuery) ||
          indicator.description.toUpperCase().includes(normalizedQuery)
        );
      }).slice(0, 10),
    [normalizedQuery]
  );
  const talibMatches = useMemo(
    () =>
      talibCatalog.filter((indicator) => {
        if (!normalizedQuery) {
          return true;
        }
        return (
          indicator.name.includes(normalizedQuery) ||
          indicator.display_name.toUpperCase().includes(normalizedQuery) ||
          indicator.group.toUpperCase().includes(normalizedQuery)
        );
      }).slice(0, 10),
    [normalizedQuery, talibCatalog]
  );

  const preferredSymbol = () => {
    const query = symbolSearch.trim().toUpperCase();
    const exactMatch = symbolMatches.find((match) => match === query);
    return exactMatch ?? symbolMatches[0] ?? symbolSearch;
  };

  const handleToggleIndicator = (indicatorId: ActiveIndicator['id']) => {
    const current = activeIndicators.find((indicator) => indicator.id === indicatorId);
    const next = upsertIndicator(activeIndicators, {
      id: indicatorId,
      visible: !(current?.visible ?? false),
    });
    setActiveIndicators(next);
  };

  const handleEnsureIndicatorVisible = (indicatorId: ActiveIndicator['id']) => {
    setActiveIndicators((currentIndicators) =>
      upsertIndicator(currentIndicators, {
        id: indicatorId,
        visible: true,
      })
    );
  };

  const handleSaveLayout = () => {
    const name = window.prompt('Layout name');
    if (!name?.trim()) {
      return;
    }

    const now = new Date().toISOString();
    const layout: SavedChartLayout = {
      id: `${name.trim().toLowerCase().replace(/\s+/g, '-')}-${Date.now()}`,
      name: name.trim(),
      updatedAt: now,
      settings: {
        ...DEFAULT_LAYOUT_SETTINGS,
        theme,
        range: selectedRange,
        indicators: activeIndicators,
      },
    };

    const nextLayouts = [layout, ...savedLayouts.filter((entry) => entry.name.toLowerCase() !== layout.name.toLowerCase())];
    writeStoredLayouts(nextLayouts);
    setSavedLayouts(nextLayouts);
    setSelectedLayoutId(layout.id);
    setLayoutNotice(createLayoutNotice('success', `Saved layout "${layout.name}".`));
  };

  const handleLoadLayout = () => {
    const layout = savedLayouts.find((entry) => entry.id === selectedLayoutId);
    if (!layout) {
      return;
    }

    setTheme(layout.settings.theme);
    setActiveIndicators(layout.settings.indicators);
    onRangeChange(layout.settings.range);
    setLayoutNotice(createLayoutNotice('info', `Loaded layout "${layout.name}".`));
  };

  return (
    <Card className="overflow-hidden border-slate-200/80 bg-white/90 shadow-[0_24px_80px_rgba(15,23,42,0.08)]">
      <CardHeader className="space-y-5 border-b border-slate-200 bg-[radial-gradient(circle_at_top_left,_rgba(14,165,233,0.12),_transparent_40%),linear-gradient(180deg,rgba(248,250,252,0.96),rgba(255,255,255,0.98))] py-5">
        <div className="flex flex-col gap-4 xl:flex-row xl:items-start xl:justify-between">
          <div className="space-y-2">
            <div className="inline-flex items-center gap-2 rounded-full border border-sky-200 bg-sky-50 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.24em] text-sky-700">
              <Sparkles className="h-3.5 w-3.5" />
              {badgeLabel}
            </div>
            <div>
              <CardTitle className="font-sans text-xl font-semibold text-slate-950">
                {title ?? `${symbol.toUpperCase()} chart desk`}
              </CardTitle>
              <p className="mt-1 text-sm text-slate-500">
                {description ?? 'Daily-only chart workspace with built-in drawings, a theme toggle, layout memory, and searchable indicators.'}
              </p>
            </div>
          </div>

          <div className="flex flex-wrap gap-2">
            {RANGE_OPTIONS.map((range) => (
              <Button
                key={range}
                type="button"
                size="sm"
                variant={selectedRange === range ? 'primary' : 'outline'}
                className={selectedRange === range ? 'bg-slate-900 text-white hover:bg-slate-800' : 'border-slate-300 text-slate-700'}
                onClick={() => onRangeChange(range)}
              >
                {range === 'ALL' ? 'All time' : range}
              </Button>
            ))}
          </div>
        </div>

        <div className="grid gap-4 xl:grid-cols-[minmax(0,1.4fr)_minmax(320px,0.9fr)]">
          <div className="space-y-4">
            {!hideSymbolSearch && onSymbolSearchChange && onOpenSymbol && onSymbolResultsOpenChange && (
              <div ref={symbolSearchRef} className="relative w-full">
                <Search className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                <Input
                  value={symbolSearch}
                  placeholder="Search and open another NEPSE symbol"
                  className="h-12 rounded-2xl border-slate-300 bg-white pl-11 pr-28 uppercase shadow-sm"
                  onFocus={() => onSymbolResultsOpenChange(true)}
                  onChange={(event) => {
                    onSymbolSearchChange(event.target.value.toUpperCase());
                    onSymbolResultsOpenChange(true);
                  }}
                  onKeyDown={(event) => {
                    if (event.key === 'Enter') {
                      event.preventDefault();
                      onOpenSymbol(preferredSymbol());
                    }

                    if (event.key === 'Escape') {
                      onSymbolResultsOpenChange(false);
                    }
                  }}
                />
                <div className="absolute inset-y-0 right-2 flex items-center">
                  <Button type="button" size="sm" className="rounded-xl bg-slate-900 px-4 text-white hover:bg-slate-800" onClick={() => onOpenSymbol(preferredSymbol())}>
                    Open
                  </Button>
                </div>

                {symbolResultsOpen && symbolSearch.trim() && (
                  <div className="absolute z-20 mt-2 w-full overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-xl">
                    {symbolMatches.length > 0 ? (
                      <ul className="max-h-72 overflow-y-auto py-1">
                        {symbolMatches.map((match) => (
                          <li key={match}>
                            <button
                              type="button"
                              className="flex w-full items-center justify-between px-4 py-3 text-left text-sm text-slate-700 transition-colors hover:bg-slate-50"
                              onClick={() => onOpenSymbol(match)}
                            >
                              <span className="font-semibold text-slate-950">{match}</span>
                              <span className="text-xs text-slate-400">Open chart</span>
                            </button>
                          </li>
                        ))}
                      </ul>
                    ) : (
                      <div className="px-4 py-3 text-sm text-slate-500">
                        {isSymbolsLoading ? 'Loading symbols...' : `No symbols matched "${symbolSearch.trim().toUpperCase()}".`}
                      </div>
                    )}
                  </div>
                )}

                {symbolSearchMessage && <p className="mt-2 text-xs font-medium text-rose-600">{symbolSearchMessage}</p>}
              </div>
            )}

            <div className="flex flex-wrap items-center gap-2">
              <div className="inline-flex overflow-hidden rounded-2xl border border-slate-300 bg-white shadow-sm">
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  className={`rounded-none px-4 ${theme === 'dark' ? 'bg-slate-900 text-white hover:bg-slate-800' : 'text-slate-600'}`}
                  onClick={() => setTheme('dark')}
                >
                  <MoonStar className="mr-1.5 h-4 w-4" />
                  Dark
                </Button>
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  className={`rounded-none px-4 ${theme === 'light' ? 'bg-slate-900 text-white hover:bg-slate-800' : 'text-slate-600'}`}
                  onClick={() => setTheme('light')}
                >
                  <SunMedium className="mr-1.5 h-4 w-4" />
                  Light
                </Button>
              </div>

              <select
                value={selectedLayoutId}
                onChange={(event) => setSelectedLayoutId(event.target.value)}
                className="h-9 min-w-44 rounded-xl border border-slate-300 bg-white px-3 text-sm text-slate-700 shadow-sm focus:border-slate-400 focus:outline-none"
              >
                <option value="">Select saved layout</option>
                {savedLayouts.map((layout) => (
                  <option key={layout.id} value={layout.id}>
                    {layout.name}
                  </option>
                ))}
              </select>

              <Button type="button" size="sm" variant="outline" className="border-slate-300" onClick={handleSaveLayout}>
                <LayoutTemplate className="mr-1.5 h-4 w-4" />
                Save layout
              </Button>
              <Button type="button" size="sm" variant="outline" className="border-slate-300" onClick={handleLoadLayout} disabled={!selectedLayoutId}>
                Load layout
              </Button>
            </div>

            {layoutNotice && (
              <div className={`rounded-2xl px-4 py-3 text-sm ${
                layoutNotice.tone === 'success'
                  ? 'border border-emerald-200 bg-emerald-50 text-emerald-700'
                  : 'border border-sky-200 bg-sky-50 text-sky-700'
              }`}>
                {layoutNotice.message}
              </div>
            )}

            <div className="rounded-3xl border border-slate-200 bg-white/90 p-4 shadow-sm">
              <div className="mb-3 flex items-center justify-between gap-3">
                <div>
                  <p className="text-sm font-semibold text-slate-900">Indicator browser</p>
                  <p className="mt-1 text-xs text-slate-500">Search chart overlays and the full TA-Lib function catalog from one place.</p>
                </div>
              </div>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                <Input
                  value={indicatorQuery}
                  onChange={(event) => setIndicatorQuery(event.target.value.toUpperCase())}
                  placeholder="Search indicators (e.g. RSI, MACD, ATR, CDLDOJI)"
                  className="h-11 rounded-2xl border-slate-300 pl-10"
                />
              </div>
              <div className="mt-4 grid gap-4 xl:grid-cols-[minmax(0,1fr)_minmax(0,1fr)]">
                <div className="space-y-3">
                  <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-400">Chart indicators</p>
                  <div className="space-y-2">
                    {chartIndicatorMatches.map((indicator) => {
                      const isActive = visibleIndicators.some((activeIndicator) => activeIndicator.id === indicator.id);
                      return (
                        <div key={indicator.id} className="rounded-2xl border border-slate-200 px-3 py-3">
                          <div className="flex items-start justify-between gap-3">
                            <div>
                              <p className="text-sm font-semibold text-slate-900">{indicator.label}</p>
                              <p className="mt-1 text-xs text-slate-500">{indicator.description}</p>
                            </div>
                            <Button
                              type="button"
                              size="sm"
                              variant={isActive ? 'outline' : 'primary'}
                              className={isActive ? 'border-emerald-300 text-emerald-700' : 'bg-slate-900 text-white hover:bg-slate-800'}
                              onClick={() => handleToggleIndicator(indicator.id)}
                            >
                              {isActive ? <Check className="mr-1.5 h-3.5 w-3.5" /> : <Plus className="mr-1.5 h-3.5 w-3.5" />}
                              {isActive ? 'Visible' : 'Add'}
                            </Button>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>

                <div className="space-y-3">
                  <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-400">TA-Lib catalog</p>
                  <div className="space-y-2">
                    {talibMatches.map((indicator) => (
                      <button
                        key={indicator.name}
                        type="button"
                        className={`w-full rounded-2xl border px-3 py-3 text-left transition-colors ${
                          selectedTalibIndicator === indicator.name
                            ? 'border-sky-300 bg-sky-50'
                            : 'border-slate-200 bg-white hover:bg-slate-50'
                        }`}
                        onClick={() => {
                          setSelectedTalibIndicator(indicator.name);
                          if (indicator.chart_indicator_id) {
                            handleEnsureIndicatorVisible(indicator.chart_indicator_id as ActiveIndicator['id']);
                          }
                        }}
                      >
                        <div className="flex items-start justify-between gap-3">
                          <div>
                            <p className="text-sm font-semibold text-slate-900">{indicator.name}</p>
                            <p className="mt-1 text-xs text-slate-500">{indicator.display_name}</p>
                          </div>
                          <span className="rounded-full border border-slate-200 px-2 py-1 text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-500">
                            {indicator.group}
                          </span>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {talibSnapshot && (
                <div className="mt-4 rounded-2xl border border-slate-200 bg-slate-50/80 p-4">
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    <div>
                      <p className="text-sm font-semibold text-slate-900">{talibSnapshot.indicator} latest values</p>
                      <p className="mt-1 text-xs text-slate-500">
                        {talibSnapshot.display_name} · {talibSnapshot.group}
                        {talibSnapshot.as_of_date ? ` · as of ${talibSnapshot.as_of_date}` : ''}
                      </p>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      {Object.entries(talibSnapshot.values).map(([key, value]) => (
                        <div key={key} className="rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 shadow-sm">
                          <span className="mr-2 text-xs uppercase tracking-[0.14em] text-slate-400">{formatOutputLabel(key)}</span>
                          <span className="font-semibold text-slate-900">{value ?? '—'}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          <div className="rounded-3xl border border-slate-200 bg-white/90 p-4 shadow-sm">
            <p className="text-sm font-semibold text-slate-900">Active chart setup</p>
            <div className="mt-3 flex flex-wrap gap-2">
              {visibleIndicators.length > 0 ? (
                visibleIndicators.map((indicator) => (
                  <button
                    key={indicator.id}
                    type="button"
                    className="rounded-full border border-slate-300 bg-slate-50 px-3 py-1 text-xs font-semibold text-slate-700"
                    onClick={() => handleToggleIndicator(indicator.id)}
                  >
                    {indicator.id}
                  </button>
                ))
              ) : (
                <span className="text-sm text-slate-500">No chart indicators selected.</span>
              )}
            </div>
            <div className="mt-4 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-xs text-slate-500">
              The chart toolbar is now limited to daily-or-higher periods. Use the range pills above for All time and other window shortcuts.
            </div>
          </div>
        </div>
      </CardHeader>

      <CardContent className="p-4">
        <MarketChartCanvas
          symbol={symbol}
          priceBars={priceBars}
          symbols={allSymbols}
          highlightedRange={highlightedRange}
          mainIndicators={mainIndicators}
          subIndicators={subIndicators}
          theme={theme}
          isLoading={isHistoryLoading}
          emptyMessage={emptyMessage}
        />
      </CardContent>
    </Card>
  );
}
