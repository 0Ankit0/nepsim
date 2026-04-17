'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import type { Chart, DeepPartial, KLineData, OverlayCreate, Styles } from 'klinecharts';
import type { ChartLayoutSettings, ChartStyle, OverlayId, PriceBar } from './chart-config';
import { getIndicatorMeta } from './chart-config';

interface MarketChartCanvasProps {
  symbol?: string;
  priceBars: PriceBar[];
  settings: ChartLayoutSettings;
  highlightedRange?: {
    startDate: string;
    endDate: string;
  } | null;
  pendingOverlayId?: OverlayId | '';
  createOverlayNonce?: number;
  clearDrawingsNonce?: number;
  isLoading?: boolean;
  emptyMessage?: string;
}

const DRAWING_GROUP_ID = 'user-drawings';
const HIGHLIGHT_GROUP_ID = 'selected-range';

function inferPricePrecision(priceBars: PriceBar[]): number {
  let maxPrecision = 0;

  for (const bar of priceBars) {
    for (const value of [bar.open, bar.high, bar.low, bar.close]) {
      const text = String(value);
      const decimals = text.includes('.') ? text.split('.')[1]?.length ?? 0 : 0;
      if (decimals > maxPrecision) {
        maxPrecision = decimals;
      }
    }
  }

  return Math.min(Math.max(maxPrecision, 2), 4);
}

function toCandleType(chartStyle: ChartStyle): 'candle_solid' | 'candle_stroke' | 'ohlc' | 'area' {
  if (chartStyle === 'hollow') {
    return 'candle_stroke';
  }
  if (chartStyle === 'ohlc') {
    return 'ohlc';
  }
  if (chartStyle === 'area') {
    return 'area';
  }
  return 'candle_solid';
}

function buildChartStyles(chartStyle: ChartStyle): DeepPartial<Styles> {
  return {
    grid: {
      show: true,
      horizontal: { show: true, size: 1, color: '#eef2f7', style: 'dashed', dashedValue: [4, 4] },
      vertical: { show: true, size: 1, color: '#eef2f7', style: 'dashed', dashedValue: [4, 4] },
    },
    candle: {
      type: toCandleType(chartStyle),
      bar: {
        compareRule: 'current_open',
        upColor: '#10b981',
        downColor: '#f43f5e',
        noChangeColor: '#94a3b8',
        upBorderColor: '#10b981',
        downBorderColor: '#f43f5e',
        noChangeBorderColor: '#94a3b8',
        upWickColor: '#10b981',
        downWickColor: '#f43f5e',
        noChangeWickColor: '#94a3b8',
      },
      area: {
        lineSize: 2,
        lineColor: '#2563eb',
        smooth: false,
        value: 'close',
        backgroundColor: [
          { offset: 0, color: 'rgba(37, 99, 235, 0.02)' },
          { offset: 1, color: 'rgba(37, 99, 235, 0.24)' },
        ],
        point: {
          show: false,
          color: '#2563eb',
          radius: 4,
          rippleColor: 'rgba(37, 99, 235, 0.12)',
          rippleRadius: 8,
          animation: true,
          animationDuration: 1000,
        },
      },
      priceMark: {
        show: true,
        high: { show: true, color: '#94a3b8', textOffset: 6, textSize: 11, textFamily: 'Inter', textWeight: '500' },
        low: { show: true, color: '#94a3b8', textOffset: 6, textSize: 11, textFamily: 'Inter', textWeight: '500' },
        last: {
          show: true,
          compareRule: 'current_open',
          upColor: '#10b981',
          downColor: '#f43f5e',
          noChangeColor: '#94a3b8',
          line: { show: true, style: 'dashed', dashedValue: [4, 4], size: 1 },
          text: {
            show: true,
            style: 'fill',
            color: '#ffffff',
            size: 11,
            family: 'Inter',
            weight: '600',
            borderStyle: 'solid',
            borderSize: 0,
            borderColor: 'transparent',
            borderDashedValue: [2, 2],
            paddingLeft: 6,
            paddingTop: 4,
            paddingRight: 6,
            paddingBottom: 4,
            borderRadius: 6,
          },
          extendTexts: [],
        },
      },
      tooltip: {
        offsetLeft: 8,
        offsetTop: 8,
        offsetRight: 8,
        offsetBottom: 8,
        showRule: 'always',
        showType: 'standard',
        title: {
          show: true,
          size: 12,
          family: 'Inter',
          weight: '600',
          color: '#0f172a',
          marginLeft: 8,
          marginTop: 4,
          marginRight: 8,
          marginBottom: 2,
          template: '{ticker} · {period}',
        },
        legend: {
          size: 11,
          family: 'Inter',
          weight: '500',
          color: '#475569',
          marginLeft: 8,
          marginTop: 2,
          marginRight: 8,
          marginBottom: 4,
          defaultValue: 'n/a',
          template: [
            { title: 'Date', value: '{time}' },
            { title: 'Open', value: '{open}' },
            { title: 'High', value: '{high}' },
            { title: 'Low', value: '{low}' },
            { title: 'Close', value: '{close}' },
            { title: 'Volume', value: '{volume}' },
          ],
        },
        rect: {
          position: 'fixed',
          paddingLeft: 6,
          paddingRight: 6,
          paddingTop: 6,
          paddingBottom: 6,
          offsetLeft: 8,
          offsetTop: 8,
          offsetRight: 8,
          offsetBottom: 8,
          borderRadius: 10,
          borderSize: 1,
          borderColor: '#e2e8f0',
          color: '#ffffff',
        },
        features: [],
      },
    },
    indicator: {
      ohlc: {
        compareRule: 'current_open',
        upColor: 'rgba(16, 185, 129, 0.7)',
        downColor: 'rgba(244, 63, 94, 0.7)',
        noChangeColor: '#94a3b8',
      },
      bars: [{ style: 'fill', borderStyle: 'solid', borderSize: 1, borderDashedValue: [2, 2], upColor: '#10b981', downColor: '#f43f5e', noChangeColor: '#94a3b8' }],
      lines: [
        { style: 'solid', smooth: false, size: 1, dashedValue: [2, 2], color: '#2563eb' },
        { style: 'solid', smooth: false, size: 1, dashedValue: [2, 2], color: '#8b5cf6' },
        { style: 'solid', smooth: false, size: 1, dashedValue: [2, 2], color: '#f59e0b' },
        { style: 'solid', smooth: false, size: 1, dashedValue: [2, 2], color: '#0ea5e9' },
        { style: 'solid', smooth: false, size: 1, dashedValue: [2, 2], color: '#ec4899' },
      ],
      circles: [{ style: 'fill', borderStyle: 'solid', borderSize: 1, borderDashedValue: [2, 2], upColor: '#10b981', downColor: '#f43f5e', noChangeColor: '#94a3b8' }],
      lastValueMark: {
        show: false,
        text: {
          show: false,
          style: 'fill',
          color: '#ffffff',
          size: 11,
          family: 'Inter',
          weight: '600',
          borderStyle: 'solid',
          borderSize: 0,
          borderDashedValue: [2, 2],
          paddingLeft: 4,
          paddingTop: 3,
          paddingRight: 4,
          paddingBottom: 3,
          borderRadius: 4,
        },
      },
      tooltip: {
        offsetLeft: 8,
        offsetTop: 6,
        offsetRight: 8,
        offsetBottom: 6,
        showRule: 'always',
        showType: 'standard',
        title: {
          show: true,
          showName: true,
          showParams: true,
          size: 11,
          family: 'Inter',
          weight: '600',
          color: '#0f172a',
          marginLeft: 8,
          marginTop: 4,
          marginRight: 8,
          marginBottom: 2,
        },
        legend: {
          size: 11,
          family: 'Inter',
          weight: '500',
          color: '#475569',
          marginLeft: 8,
          marginTop: 2,
          marginRight: 8,
          marginBottom: 4,
          defaultValue: 'n/a',
        },
        features: [],
      },
    },
    xAxis: {
      show: true,
      size: 'auto',
      axisLine: { show: true, color: '#cbd5e1', size: 1 },
      tickText: { show: true, color: '#64748b', family: 'Inter', weight: '500', size: 11, marginStart: 6, marginEnd: 6 },
      tickLine: { show: true, size: 1, length: 3, color: '#cbd5e1' },
    },
    yAxis: {
      show: true,
      size: 'auto',
      axisLine: { show: true, color: '#cbd5e1', size: 1 },
      tickText: { show: true, color: '#64748b', family: 'Inter', weight: '500', size: 11, marginStart: 6, marginEnd: 6 },
      tickLine: { show: true, size: 1, length: 3, color: '#cbd5e1' },
    },
    separator: {
      size: 1,
      color: '#e2e8f0',
      fill: true,
      activeBackgroundColor: 'rgba(37, 99, 235, 0.08)',
    },
    crosshair: {
      show: true,
      horizontal: {
        show: true,
        line: { show: true, style: 'dashed', dashedValue: [4, 4], size: 1, color: '#94a3b8' },
        text: {
          show: true,
          style: 'fill',
          color: '#ffffff',
          size: 11,
          family: 'Inter',
          weight: '600',
          borderStyle: 'solid',
          borderDashedValue: [2, 2],
          borderSize: 1,
          borderColor: '#475569',
          borderRadius: 6,
          paddingLeft: 6,
          paddingRight: 6,
          paddingTop: 4,
          paddingBottom: 4,
          backgroundColor: '#475569',
        },
        features: [],
      },
      vertical: {
        show: true,
        line: { show: true, style: 'dashed', dashedValue: [4, 4], size: 1, color: '#94a3b8' },
        text: {
          show: true,
          style: 'fill',
          color: '#ffffff',
          size: 11,
          family: 'Inter',
          weight: '600',
          borderStyle: 'solid',
          borderDashedValue: [2, 2],
          borderSize: 1,
          borderColor: '#475569',
          borderRadius: 6,
          paddingLeft: 6,
          paddingRight: 6,
          paddingTop: 4,
          paddingBottom: 4,
          backgroundColor: '#475569',
        },
      },
    },
    overlay: {
      point: {
        color: '#2563eb',
        borderColor: 'rgba(37, 99, 235, 0.28)',
        borderSize: 1,
        radius: 5,
        activeColor: '#2563eb',
        activeBorderColor: 'rgba(37, 99, 235, 0.28)',
        activeBorderSize: 3,
        activeRadius: 5,
      },
      line: {
        style: 'solid',
        smooth: false,
        color: '#2563eb',
        size: 1,
        dashedValue: [4, 4],
      },
      rect: {
        style: 'fill',
        color: 'rgba(37, 99, 235, 0.12)',
        borderColor: '#2563eb',
        borderSize: 1,
        borderRadius: 0,
        borderStyle: 'solid',
        borderDashedValue: [2, 2],
      },
      polygon: {
        style: 'fill',
        color: 'rgba(37, 99, 235, 0.12)',
        borderColor: '#2563eb',
        borderSize: 1,
        borderStyle: 'solid',
        borderDashedValue: [2, 2],
      },
      circle: {
        style: 'fill',
        color: 'rgba(37, 99, 235, 0.12)',
        borderColor: '#2563eb',
        borderSize: 1,
        borderStyle: 'solid',
        borderDashedValue: [2, 2],
      },
      arc: {
        style: 'solid',
        color: '#2563eb',
        size: 1,
        dashedValue: [2, 2],
      },
      text: {
        style: 'fill',
        color: '#ffffff',
        size: 11,
        family: 'Inter',
        weight: '600',
        borderStyle: 'solid',
        borderDashedValue: [2, 2],
        borderSize: 0,
        borderRadius: 4,
        borderColor: '#2563eb',
        paddingLeft: 4,
        paddingRight: 4,
        paddingTop: 2,
        paddingBottom: 2,
        backgroundColor: '#2563eb',
      },
    },
  };
}

export function MarketChartCanvas({
  symbol,
  priceBars,
  settings,
  highlightedRange = null,
  pendingOverlayId = '',
  createOverlayNonce = 0,
  clearDrawingsNonce = 0,
  isLoading = false,
  emptyMessage = 'No historic chart data is available for this symbol.',
}: MarketChartCanvasProps) {
  const chartContainerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<Chart | null>(null);
  const disposeRef = useRef<((target: HTMLElement | Chart | string) => void) | null>(null);
  const appliedOverlayNonceRef = useRef(0);
  const clearedOverlayNonceRef = useRef(0);
  const [chartReady, setChartReady] = useState(false);

  const klineData = useMemo<KLineData[]>(
    () =>
      priceBars.map((bar) => ({
        timestamp: bar.timestamp,
        open: bar.open,
        high: bar.high,
        low: bar.low,
        close: bar.close,
        volume: bar.volume,
        turnover: bar.turnover,
      })),
    [priceBars]
  );

  const paneIndicatorCount = useMemo(() => {
    const visibleIndicators = new Set(settings.indicators.filter((indicator) => indicator.visible).map((indicator) => indicator.id));
    if (settings.showVolume) {
      visibleIndicators.add('VOL');
    }
    let count = 0;
    for (const indicatorId of visibleIndicators) {
      if (getIndicatorMeta(indicatorId).group === 'pane') {
        count += 1;
      }
    }
    return count;
  }, [settings.indicators, settings.showVolume]);

  const chartHeight = Math.min(1180, 480 + paneIndicatorCount * 132);

  useEffect(() => {
    let isDisposed = false;

    async function initializeChart() {
      if (!chartContainerRef.current) {
        return;
      }

      const { dispose, init } = await import('klinecharts');
      if (isDisposed || !chartContainerRef.current) {
        return;
      }

      disposeRef.current = dispose;
      const chart = init(chartContainerRef.current);
      if (!chart) {
        return;
      }

      chartRef.current = chart;
      chart.setOffsetRightDistance(24);
      chart.setLeftMinVisibleBarCount(20);
      chart.setRightMinVisibleBarCount(4);
      chart.setZoomEnabled(true);
      chart.setScrollEnabled(true);
      chart.setTimezone('Asia/Kathmandu');
      setChartReady(true);
    }

    initializeChart();

    return () => {
      isDisposed = true;
      if (chartRef.current && disposeRef.current) {
        disposeRef.current(chartRef.current);
      }
      chartRef.current = null;
      setChartReady(false);
    };
  }, []);

  useEffect(() => {
    if (!chartReady || !chartRef.current) {
      return;
    }

    chartRef.current.setStyles(buildChartStyles(settings.chartStyle));
  }, [chartReady, settings.chartStyle]);

  useEffect(() => {
    if (!chartReady || !chartRef.current) {
      return;
    }

    chartRef.current.setSymbol({
      ticker: symbol ?? 'NEPSE',
      pricePrecision: inferPricePrecision(priceBars),
      volumePrecision: 0,
    });
    chartRef.current.setPeriod({ span: 1, type: 'day' });
    chartRef.current.setDataLoader({
      getBars: ({ callback }) => {
        callback(klineData);
      },
    });
    chartRef.current.resetData();
    chartRef.current.scrollToRealTime(0);
  }, [chartReady, klineData, priceBars, symbol]);

  useEffect(() => {
    if (!chartReady || !chartRef.current) {
      return;
    }

    for (const indicator of chartRef.current.getIndicators()) {
      chartRef.current.removeIndicator({ id: indicator.id });
    }

    const requestedIndicators = new Set(settings.indicators.filter((indicator) => indicator.visible).map((indicator) => indicator.id));
    if (settings.showVolume) {
      requestedIndicators.add('VOL');
    }

    let paneOrder = 1;
    for (const indicatorId of requestedIndicators) {
      const meta = getIndicatorMeta(indicatorId);
      if (meta.group === 'overlay') {
        chartRef.current.createIndicator(indicatorId, true, { id: 'candle_pane' });
        continue;
      }

      chartRef.current.createIndicator(indicatorId, false, {
        id: `pane-${indicatorId.toLowerCase()}`,
        order: paneOrder,
        height: indicatorId === 'VOL' ? 150 : 132,
        minHeight: 88,
        dragEnabled: true,
      });
      paneOrder += 1;
    }
  }, [chartReady, settings.indicators, settings.showVolume]);

  useEffect(() => {
    if (!chartReady || !chartRef.current) {
      return;
    }

    chartRef.current.removeOverlay({ groupId: HIGHLIGHT_GROUP_ID });
    if (!highlightedRange) {
      return;
    }

    const startBar = priceBars.find((bar) => bar.date === highlightedRange.startDate);
    const endBar = priceBars.find((bar) => bar.date === highlightedRange.endDate);
    const overlays: OverlayCreate[] = [startBar, endBar]
      .filter((bar): bar is PriceBar => Boolean(bar))
      .map((bar, index) => ({
        name: 'verticalStraightLine' as const,
        id: `${HIGHLIGHT_GROUP_ID}-${index}`,
        groupId: HIGHLIGHT_GROUP_ID,
        lock: true,
        points: [{ timestamp: bar.timestamp, value: bar.close }],
        styles: {
          line: {
            color: '#f59e0b',
            style: 'dashed',
            size: 1,
            dashedValue: [4, 4],
          },
        },
      }));

    if (overlays.length > 0) {
      chartRef.current.createOverlay(overlays);
    }
  }, [chartReady, highlightedRange, priceBars]);

  useEffect(() => {
    if (!chartReady || !chartRef.current || !pendingOverlayId || createOverlayNonce === 0 || createOverlayNonce === appliedOverlayNonceRef.current) {
      return;
    }

    chartRef.current.createOverlay({
      name: pendingOverlayId,
      groupId: DRAWING_GROUP_ID,
    });
    appliedOverlayNonceRef.current = createOverlayNonce;
  }, [chartReady, createOverlayNonce, pendingOverlayId]);

  useEffect(() => {
    if (!chartReady || !chartRef.current || clearDrawingsNonce === 0 || clearDrawingsNonce === clearedOverlayNonceRef.current) {
      return;
    }

    chartRef.current.removeOverlay({ groupId: DRAWING_GROUP_ID });
    clearedOverlayNonceRef.current = clearDrawingsNonce;
  }, [chartReady, clearDrawingsNonce]);

  if (!isLoading && priceBars.length === 0) {
    return (
      <div className="flex h-[460px] items-center justify-center rounded-xl border border-dashed border-gray-200 bg-gray-50 text-sm text-gray-500">
        {emptyMessage}
      </div>
    );
  }

  return (
    <div className="relative overflow-hidden rounded-2xl border border-gray-100 bg-white">
      <div ref={chartContainerRef} style={{ height: chartHeight, width: '100%' }} />
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-white/70 text-sm font-medium text-gray-500 backdrop-blur-sm">
          Loading chart...
        </div>
      )}
    </div>
  );
}
