'use client';

import { Search } from 'lucide-react';
import { useEffect, useRef } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import type { ChartLayoutSettings, ChartStyle, OverlayId, PriceBar } from './chart-config';
import { RANGE_OPTIONS } from './chart-config';
import { MarketChartCanvas } from './chart-canvas';

interface MarketChartCardProps {
  symbol: string;
  symbolSearch: string;
  onSymbolSearchChange: (value: string) => void;
  onOpenSymbol: (candidate?: string) => void;
  symbolSearchMessage: string | null;
  symbolMatches: string[];
  symbolResultsOpen: boolean;
  onSymbolResultsOpenChange: (open: boolean) => void;
  isSymbolsLoading: boolean;
  chartSettings: ChartLayoutSettings;
  onChartStyleChange: (style: ChartStyle) => void;
  onRangeChange: (range: ChartLayoutSettings['range']) => void;
  pendingOverlayId?: OverlayId | '';
  createOverlayNonce?: number;
  clearDrawingsNonce?: number;
  priceBars: PriceBar[];
  isHistoryLoading: boolean;
  isIndicatorHistoryLoading: boolean;
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

export function MarketChartCard({
  symbol,
  symbolSearch,
  onSymbolSearchChange,
  onOpenSymbol,
  symbolSearchMessage,
  symbolMatches,
  symbolResultsOpen,
  onSymbolResultsOpenChange,
  isSymbolsLoading,
  chartSettings,
  onChartStyleChange,
  onRangeChange,
  pendingOverlayId = '',
  createOverlayNonce = 0,
  clearDrawingsNonce = 0,
  priceBars,
  isHistoryLoading,
  isIndicatorHistoryLoading,
}: MarketChartCardProps) {
  const symbolSearchRef = useRef<HTMLDivElement>(null);

  useClickOutside(symbolSearchRef, () => onSymbolResultsOpenChange(false));

  const preferredSymbol = () => {
    const query = symbolSearch.trim().toUpperCase();
    const exactMatch = symbolMatches.find((match) => match === query);
    return exactMatch ?? symbolMatches[0] ?? symbolSearch;
  };

  return (
    <Card className="xl:col-span-2 overflow-hidden shadow-sm border-gray-100">
      <CardHeader className="border-b border-gray-100 bg-gray-50/50 py-4 space-y-4">
        <div className="flex flex-col gap-4 xl:flex-row xl:items-start xl:justify-between">
          <div>
            <CardTitle className="text-sm font-semibold text-gray-600">KLineChart Workspace</CardTitle>
            <p className="mt-1 text-xs text-gray-500">
              {isHistoryLoading || isIndicatorHistoryLoading
                ? 'Loading price history and chart panes...'
                : `${priceBars.length} bars in view · native KLineChart indicators and drawings`}
            </p>
          </div>

          <div className="flex flex-wrap gap-2">
            {(['candlestick', 'hollow', 'ohlc', 'area'] as ChartStyle[]).map((mode) => (
              <Button
                key={mode}
                type="button"
                size="sm"
                variant={chartSettings.chartStyle === mode ? 'primary' : 'outline'}
                onClick={() => onChartStyleChange(mode)}
              >
                {mode === 'candlestick' ? 'Candles' : mode === 'hollow' ? 'Hollow' : mode === 'ohlc' ? 'OHLC' : 'Area'}
              </Button>
            ))}
          </div>
        </div>

        <div className="flex flex-col gap-3 xl:flex-row xl:items-center xl:justify-between">
          <div ref={symbolSearchRef} className="relative w-full max-w-xl">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
            <Input
              value={symbolSearch}
              placeholder="Search and open another stock symbol"
              className="pl-10 pr-28 uppercase"
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
              <Button type="button" size="sm" onClick={() => onOpenSymbol(preferredSymbol())}>
                Open
              </Button>
            </div>

            {symbolResultsOpen && symbolSearch.trim() && (
              <div className="absolute z-20 mt-2 w-full overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
                {symbolMatches.length > 0 ? (
                  <ul className="max-h-72 overflow-y-auto py-1">
                    {symbolMatches.map((match) => (
                      <li key={match}>
                        <button
                          type="button"
                          className="flex w-full items-center justify-between px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50"
                          onClick={() => onOpenSymbol(match)}
                        >
                          <span className="font-semibold text-gray-900">{match}</span>
                          <span className="text-xs text-gray-400">Open chart</span>
                        </button>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <div className="px-4 py-3 text-sm text-gray-500">
                    {isSymbolsLoading ? 'Loading symbols...' : `No symbols matched "${symbolSearch.trim().toUpperCase()}".`}
                  </div>
                )}
              </div>
            )}

            {symbolSearchMessage && <p className="mt-2 text-xs font-medium text-rose-600">{symbolSearchMessage}</p>}
          </div>

          <div className="flex flex-wrap gap-2">
            {RANGE_OPTIONS.map((range) => (
              <Button
                key={range}
                type="button"
                size="sm"
                variant={chartSettings.range === range ? 'primary' : 'outline'}
                onClick={() => onRangeChange(range)}
              >
                {range}
              </Button>
            ))}
          </div>
        </div>
      </CardHeader>

      <CardContent className="p-4">
        <MarketChartCanvas
          symbol={symbol}
          priceBars={priceBars}
          settings={chartSettings}
          pendingOverlayId={pendingOverlayId}
          createOverlayNonce={createOverlayNonce}
          clearDrawingsNonce={clearDrawingsNonce}
          isLoading={isHistoryLoading || isIndicatorHistoryLoading}
        />
      </CardContent>
    </Card>
  );
}
