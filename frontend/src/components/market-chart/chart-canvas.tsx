'use client';

import { useEffect, useMemo, useRef } from 'react';
import type { ChartProOptions, Datafeed, Period, SymbolInfo } from '@klinecharts/pro';
import type { KLineData } from 'klinecharts';
import type { ChartTheme, IndicatorId, PriceBar } from './chart-config';

interface MarketChartCanvasProps {
  symbol: string;
  priceBars: PriceBar[];
  symbols?: string[];
  highlightedRange?: {
    startDate: string;
    endDate: string;
  } | null;
  mainIndicators?: IndicatorId[];
  subIndicators?: IndicatorId[];
  theme?: ChartTheme;
  isLoading?: boolean;
  emptyMessage?: string;
}

const DEFAULT_PERIOD: Period = { multiplier: 1, timespan: 'day', text: '1D' };
const SUPPORTED_PERIODS: Period[] = [
  { multiplier: 1, timespan: 'day', text: '1D' },
  { multiplier: 1, timespan: 'week', text: '1W' },
  { multiplier: 1, timespan: 'month', text: '1M' },
];

function inferPricePrecision(priceBars: PriceBar[]): number {
  let maxPrecision = 2;

  for (const bar of priceBars) {
    for (const value of [bar.open, bar.high, bar.low, bar.close]) {
      const [, decimals = ''] = String(value).split('.');
      maxPrecision = Math.max(maxPrecision, decimals.length);
    }
  }

  return Math.min(maxPrecision, 4);
}

function buildSymbolInfo(symbol: string, priceBars: PriceBar[]): SymbolInfo {
  return {
    ticker: symbol.toUpperCase(),
    shortName: symbol.toUpperCase(),
    name: `${symbol.toUpperCase()} · Nepal Stock Exchange`,
    exchange: 'NEPSE',
    market: 'stocks',
    type: 'EQUITY',
    priceCurrency: 'NPR',
    pricePrecision: inferPricePrecision(priceBars),
    volumePrecision: 0,
  };
}

function toKLineData(priceBars: PriceBar[]): KLineData[] {
  return priceBars.map((bar) => ({
    timestamp: bar.timestamp,
    open: bar.open,
    high: bar.high,
    low: bar.low,
    close: bar.close,
    volume: bar.volume,
    turnover: bar.turnover,
  }));
}

function sortSearchMatches(query: string, symbols: string[]) {
  const normalizedQuery = query.trim().toUpperCase();
  return [...symbols]
    .filter((candidate) => candidate.includes(normalizedQuery))
    .sort((left, right) => {
      const leftRank = left.startsWith(normalizedQuery) ? 0 : 1;
      const rightRank = right.startsWith(normalizedQuery) ? 0 : 1;
      if (leftRank !== rightRank) {
        return leftRank - rightRank;
      }
      return left.localeCompare(right);
    })
    .slice(0, 24);
}

export function MarketChartCanvas({
  symbol,
  priceBars,
  symbols,
  highlightedRange = null,
  mainIndicators = ['MA', 'BOLL'],
  subIndicators = ['VOL', 'MACD', 'RSI'],
  theme = 'dark',
  isLoading = false,
  emptyMessage = 'No historic chart data is available for this symbol.',
}: MarketChartCanvasProps) {
  const chartContainerRef = useRef<HTMLDivElement>(null);
  const priceData = useMemo(() => toKLineData(priceBars), [priceBars]);
  const mainIndicatorsKey = mainIndicators.join('|');
  const subIndicatorsKey = subIndicators.join('|');
  const symbolCatalog = useMemo(
    () => Array.from(new Set([symbol.toUpperCase(), ...(symbols ?? []).map((candidate) => candidate.toUpperCase())])),
    [symbol, symbols]
  );
  const chartSignature = useMemo(
    () =>
      JSON.stringify({
        symbol: symbol.toUpperCase(),
        firstBar: priceBars[0]?.date ?? null,
        lastBar: priceBars[priceBars.length - 1]?.date ?? null,
        length: priceBars.length,
        mainIndicatorsKey,
        subIndicatorsKey,
        symbols: symbolCatalog,
      }),
    [mainIndicatorsKey, priceBars, subIndicatorsKey, symbol, symbolCatalog]
  );

  useEffect(() => {
    let isCancelled = false;

    async function initializeChart() {
      if (!chartContainerRef.current || priceData.length === 0) {
        return;
      }

      const { KLineChartPro } = await import('@klinecharts/pro');
      if (isCancelled || !chartContainerRef.current) {
        return;
      }

        const datafeed: Datafeed = {
          searchSymbols: async (search) => {
            const currentSymbol = symbol.toUpperCase();
            const matches = !search?.trim() ? symbolCatalog : sortSearchMatches(search, symbolCatalog);
            if (!matches.includes(currentSymbol)) {
              matches.unshift(currentSymbol);
            }
            return matches.map((candidate) => buildSymbolInfo(candidate, priceBars));
          },
          getHistoryKLineData: async () => priceData,
        subscribe: () => undefined,
        unsubscribe: () => undefined,
      };

      chartContainerRef.current.innerHTML = '';
        const options: ChartProOptions = {
          container: chartContainerRef.current,
          locale: 'en-US',
          theme,
          timezone: 'Asia/Kathmandu',
          drawingBarVisible: true,
          symbol: buildSymbolInfo(symbol, priceBars),
          period: DEFAULT_PERIOD,
          periods: SUPPORTED_PERIODS,
          datafeed,
          mainIndicators: mainIndicatorsKey ? (mainIndicatorsKey.split('|') as IndicatorId[]) : [],
          subIndicators: subIndicatorsKey ? (subIndicatorsKey.split('|') as IndicatorId[]) : [],
      };

      new KLineChartPro(options);
    }

    initializeChart();

    return () => {
      isCancelled = true;
      if (chartContainerRef.current) {
        chartContainerRef.current.innerHTML = '';
      }
    };
  }, [chartSignature, mainIndicatorsKey, priceBars, priceData, subIndicatorsKey, symbol, symbolCatalog, theme]);

  if (!isLoading && priceBars.length === 0) {
    return (
      <div className="flex h-[720px] items-center justify-center rounded-[28px] border border-dashed border-slate-700 bg-[#07101c] px-8 text-center text-sm text-slate-400">
        {emptyMessage}
      </div>
    );
  }

  return (
    <div className="relative overflow-hidden rounded-[28px] border border-slate-800 bg-[#07101c] shadow-[0_24px_80px_rgba(2,6,23,0.48)]">
      <div className="pointer-events-none absolute inset-x-0 top-0 z-0 h-28 bg-gradient-to-b from-sky-500/12 via-sky-500/6 to-transparent" />
      {highlightedRange && (
        <div className="pointer-events-none absolute left-4 top-4 z-10 rounded-full border border-sky-400/20 bg-slate-950/80 px-3 py-1 text-[11px] font-medium tracking-wide text-sky-100 backdrop-blur">
          Pattern focus: {highlightedRange.startDate} to {highlightedRange.endDate}
        </div>
      )}
      <div
        ref={chartContainerRef}
        className="relative z-10 h-[720px] w-full min-w-0 overflow-hidden [&_.klinecharts-pro]:h-full [&_.klinecharts-pro]:w-full"
      />
      <div className="border-t border-slate-800/80 bg-slate-950/80 px-4 py-3 text-[11px] text-slate-400">
        Use the left rail for drawings and the top toolbar for indicators, overlays, and chart settings.
      </div>
      {isLoading && (
        <div className="absolute inset-0 z-20 flex items-center justify-center bg-slate-950/65 text-sm font-medium text-slate-200 backdrop-blur-sm">
          Loading chart...
        </div>
      )}
    </div>
  );
}
