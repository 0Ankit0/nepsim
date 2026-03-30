'use client';

import {
  CandlestickSeries,
  ColorType,
  createChart,
  HistogramSeries,
  LineSeries,
  LineStyle,
  type CandlestickData,
  type HistogramData,
  type Time,
} from 'lightweight-charts';
import { useEffect, useMemo, useRef, useState } from 'react';
import type { IndicatorRow } from '@/api/market';
import type { ChartLayoutSettings, PriceBar } from './chart-config';
import { getIndicatorMeta } from './chart-config';
import { makeConstantLineData, makeLineData } from './data-utils';

interface MarketChartCanvasProps {
  priceBars: PriceBar[];
  indicators: IndicatorRow[];
  settings: ChartLayoutSettings;
  highlightedRange?: {
    startDate: string;
    endDate: string;
  } | null;
  drawingTool?: 'none' | 'trendline' | 'fib' | 'xabcd' | 'long';
  clearDrawingsNonce?: number;
  isLoading?: boolean;
  emptyMessage?: string;
}

export function MarketChartCanvas({
  priceBars,
  indicators,
  settings,
  highlightedRange = null,
  drawingTool = 'none',
  clearDrawingsNonce = 0,
  isLoading = false,
  emptyMessage = 'No historic chart data is available for this symbol.',
}: MarketChartCanvasProps) {
  const chartContainerRef = useRef<HTMLDivElement>(null);
  const [pendingDrawingPoints, setPendingDrawingPoints] = useState<Array<{ time: Time; price: number }>>([]);
  const [drawings, setDrawings] = useState<Array<{ id: string; type: 'trendline' | 'fib' | 'xabcd' | 'long'; points: Array<{ time: Time; price: number }> }>>([]);

  const requiredPoints = useMemo(
    () =>
      drawingTool === 'trendline'
        ? 2
        : drawingTool === 'fib'
          ? 2
          : drawingTool === 'long'
            ? 2
            : drawingTool === 'xabcd'
              ? 5
              : 0,
    [drawingTool]
  );

  useEffect(() => {
    setPendingDrawingPoints([]);
  }, [drawingTool]);

  useEffect(() => {
    setDrawings([]);
    setPendingDrawingPoints([]);
  }, [clearDrawingsNonce]);

  const visiblePanelCount = useMemo(
    () =>
      (settings.showVolume ? 1 : 0) +
      settings.indicators.filter((indicator) => indicator.visible && getIndicatorMeta(indicator.id).group === 'pane').length,
    [settings.indicators, settings.showVolume]
  );

  const chartHeight = Math.min(980, 420 + visiblePanelCount * 140);

  useEffect(() => {
    if (!chartContainerRef.current || priceBars.length === 0) {
      return;
    }

    const chart = createChart(chartContainerRef.current, {
      autoSize: true,
      layout: {
        background: { type: ColorType.Solid, color: '#ffffff' },
        textColor: '#4b5563',
      },
      grid: {
        vertLines: { color: '#f1f5f9' },
        horzLines: { color: '#f1f5f9' },
      },
      rightPriceScale: {
        borderColor: '#e5e7eb',
      },
      timeScale: {
        borderColor: '#e5e7eb',
        timeVisible: true,
      },
      crosshair: {
        vertLine: {
          color: '#94a3b8',
          width: 1,
          style: LineStyle.Dashed,
          visible: true,
          labelVisible: true,
        },
        horzLine: {
          color: '#94a3b8',
          width: 1,
          style: LineStyle.Dashed,
          visible: true,
          labelVisible: true,
        },
      },
    });

    const candleData: CandlestickData<Time>[] = priceBars.map((bar) => ({
      time: bar.time,
      open: bar.open,
      high: bar.high,
      low: bar.low,
      close: bar.close,
    }));

    const closeLineData = priceBars.map((bar) => ({
      time: bar.time,
      value: bar.close,
    }));

    let primarySeries;

    if (settings.chartStyle === 'candlestick') {
      const series = chart.addSeries(
        CandlestickSeries,
        {
          upColor: '#10b981',
          downColor: '#f43f5e',
          borderVisible: false,
          wickUpColor: '#10b981',
          wickDownColor: '#f43f5e',
          priceLineVisible: false,
        },
        0
      );
      series.setData(candleData);
      primarySeries = series;
    } else {
      const series = chart.addSeries(
        LineSeries,
        {
          color: '#2563eb',
          lineWidth: 2,
          crosshairMarkerVisible: false,
          lastValueVisible: true,
          priceLineVisible: false,
        },
        0
      );
      series.setData(closeLineData);
      primarySeries = series;
    }

    if (highlightedRange) {
      const start = highlightedRange.startDate;
      const end = highlightedRange.endDate;

      const highlightedCloseData = priceBars.flatMap((bar) => {
        if (bar.date < start || bar.date > end) {
          return [];
        }

        return [{ time: bar.time, value: bar.close }];
      });

      if (highlightedCloseData.length > 0) {
        const highlightedSeries = chart.addSeries(
          LineSeries,
          {
            color: '#f59e0b',
            lineWidth: 4,
            crosshairMarkerVisible: false,
            lastValueVisible: false,
            priceLineVisible: false,
          },
          0
        );
        highlightedSeries.setData(highlightedCloseData);
      }
    }

    const renderTime = (value: Time) => {
      if (typeof value === 'string') return value;
      if (typeof value === 'number') return value;
      return `${value.year}-${String(value.month).padStart(2, '0')}-${String(value.day).padStart(2, '0')}`;
    };

    for (const drawing of drawings) {
      if (drawing.type === 'trendline' && drawing.points.length >= 2) {
        const trendLine = chart.addSeries(
          LineSeries,
          { color: '#0ea5e9', lineWidth: 2, crosshairMarkerVisible: false, lastValueVisible: false, priceLineVisible: false },
          0
        );
        trendLine.setData(drawing.points.slice(0, 2).map((point) => ({ time: point.time, value: point.price })));
      }

      if (drawing.type === 'fib' && drawing.points.length >= 2) {
        const [pointA, pointB] = drawing.points;
        const levels = [0, 0.236, 0.382, 0.5, 0.618, 0.786, 1];
        const span = pointB.price - pointA.price;
        const startTime = renderTime(pointA.time) <= renderTime(pointB.time) ? pointA.time : pointB.time;
        const endTime = renderTime(pointA.time) <= renderTime(pointB.time) ? pointB.time : pointA.time;

        for (const level of levels) {
          const fibLine = chart.addSeries(
            LineSeries,
            {
              color: '#a855f7',
              lineWidth: level === 0 || level === 1 ? 2 : 1,
              lineStyle: LineStyle.Dashed,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            0
          );
          fibLine.setData([
            { time: startTime, value: pointA.price + span * level },
            { time: endTime, value: pointA.price + span * level },
          ]);
        }
      }

      if (drawing.type === 'xabcd' && drawing.points.length >= 5) {
        const xabcdLine = chart.addSeries(
          LineSeries,
          { color: '#f97316', lineWidth: 2, crosshairMarkerVisible: true, lastValueVisible: false, priceLineVisible: false },
          0
        );
        xabcdLine.setData(drawing.points.map((point) => ({ time: point.time, value: point.price })));
      }

      if (drawing.type === 'long' && drawing.points.length >= 2) {
        const [entryPoint, targetPoint] = drawing.points;
        const priceDistance = targetPoint.price - entryPoint.price;
        const stopPrice = entryPoint.price - Math.abs(priceDistance);
        const startTime = renderTime(entryPoint.time) <= renderTime(targetPoint.time) ? entryPoint.time : targetPoint.time;
        const endTime = renderTime(entryPoint.time) <= renderTime(targetPoint.time) ? targetPoint.time : entryPoint.time;
        const levels = [
          { price: entryPoint.price, color: '#2563eb' },
          { price: targetPoint.price, color: '#16a34a' },
          { price: stopPrice, color: '#dc2626' },
        ];

        for (const level of levels) {
          const levelSeries = chart.addSeries(
            LineSeries,
            {
              color: level.color,
              lineWidth: 2,
              lineStyle: LineStyle.Dashed,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            0
          );
          levelSeries.setData([
            { time: startTime, value: level.price },
            { time: endTime, value: level.price },
          ]);
        }
      }
    }

    if (pendingDrawingPoints.length > 0) {
      const pendingSeries = chart.addSeries(
        LineSeries,
        {
          color: '#64748b',
          lineWidth: 1,
          lineStyle: LineStyle.Dotted,
          crosshairMarkerVisible: true,
          lastValueVisible: false,
          priceLineVisible: false,
        },
        0
      );
      pendingSeries.setData(pendingDrawingPoints.map((point) => ({ time: point.time, value: point.price })));
    }

    chart.subscribeClick((param) => {
      if (drawingTool === 'none' || !param.point || param.time == null || !primarySeries) {
        return;
      }

      const price = primarySeries.coordinateToPrice(param.point.y);
      if (price == null || !Number.isFinite(price)) {
        return;
      }

      setPendingDrawingPoints((current) => {
        const nextPoints = [...current, { time: param.time as Time, price }];
        if (requiredPoints > 0 && nextPoints.length >= requiredPoints) {
          setDrawings((existing) => [
            ...existing,
            {
              id: `drawing-${Date.now()}-${Math.round(Math.random() * 1_000_000)}`,
              type: drawingTool as 'trendline' | 'fib' | 'xabcd' | 'long',
              points: nextPoints,
            },
          ]);
          return [];
        }
        return nextPoints;
      });
    });

    const overlayIndicators = settings.indicators.filter(
      (indicator) => indicator.visible && getIndicatorMeta(indicator.id).group === 'overlay'
    );

    for (const indicator of overlayIndicators) {
      switch (indicator.id) {
        case 'sma20': {
          const series = chart.addSeries(
            LineSeries,
            {
              color: '#8b5cf6',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            0
          );
          series.setData(makeLineData(indicators, (row) => row.sma_20));
          break;
        }
        case 'sma50': {
          const series = chart.addSeries(
            LineSeries,
            {
              color: '#f97316',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            0
          );
          series.setData(makeLineData(indicators, (row) => row.sma_50));
          break;
        }
        case 'ema12': {
          const series = chart.addSeries(
            LineSeries,
            {
              color: '#06b6d4',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            0
          );
          series.setData(makeLineData(indicators, (row) => row.ema_12));
          break;
        }
        case 'ema26': {
          const series = chart.addSeries(
            LineSeries,
            {
              color: '#ec4899',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            0
          );
          series.setData(makeLineData(indicators, (row) => row.ema_26));
          break;
        }
        case 'bollinger': {
          const upperBand = chart.addSeries(
            LineSeries,
            {
              color: '#14b8a6',
              lineWidth: 1,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            0
          );
          upperBand.setData(makeLineData(indicators, (row) => row.bb_upper));

          const lowerBand = chart.addSeries(
            LineSeries,
            {
              color: '#14b8a6',
              lineWidth: 1,
              lineStyle: LineStyle.Dotted,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            0
          );
          lowerBand.setData(makeLineData(indicators, (row) => row.bb_lower));
          break;
        }
        default:
          break;
      }
    }

    let nextPaneIndex = 1;

    if (settings.showVolume) {
      const volumeData: HistogramData<Time>[] = priceBars.map((bar) => ({
        time: bar.time,
        value: bar.volume,
        color: bar.close >= bar.open ? '#10b98166' : '#f43f5e66',
      }));

      const volumeSeries = chart.addSeries(
        HistogramSeries,
        {
          color: '#94a3b8',
          priceFormat: { type: 'volume' },
          lastValueVisible: false,
          priceLineVisible: false,
        },
        nextPaneIndex
      );
      volumeSeries.setData(volumeData);
      volumeSeries.priceScale().applyOptions({
        scaleMargins: { top: 0.15, bottom: 0 },
      });
      nextPaneIndex += 1;
    }

    const panelIndicators = settings.indicators.filter(
      (indicator) => indicator.visible && getIndicatorMeta(indicator.id).group === 'pane'
    );

    for (const indicator of panelIndicators) {
      switch (indicator.id) {
        case 'rsi14': {
          const rsiSeries = chart.addSeries(
            LineSeries,
            {
              color: '#7c3aed',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          rsiSeries.setData(makeLineData(indicators, (row) => row.rsi_14));
          rsiSeries.priceScale().applyOptions({
            scaleMargins: { top: 0.15, bottom: 0.15 },
          });

          const upperGuide = chart.addSeries(
            LineSeries,
            {
              color: '#cbd5e1',
              lineWidth: 1,
              lineStyle: LineStyle.Dashed,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          upperGuide.setData(makeConstantLineData(indicators, 70));

          const lowerGuide = chart.addSeries(
            LineSeries,
            {
              color: '#cbd5e1',
              lineWidth: 1,
              lineStyle: LineStyle.Dashed,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          lowerGuide.setData(makeConstantLineData(indicators, 30));
          nextPaneIndex += 1;
          break;
        }
        case 'macd': {
          const histogram = chart.addSeries(
            HistogramSeries,
            {
              color: '#94a3b8',
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          histogram.setData(
            indicators.flatMap((row) => {
              if (!row.date || row.macd_hist == null) {
                return [];
              }

              return [
                {
                  time: row.date,
                  value: row.macd_hist,
                  color: row.macd_hist >= 0 ? '#10b98199' : '#f43f5e99',
                },
              ];
            })
          );

          const macdLine = chart.addSeries(
            LineSeries,
            {
              color: '#2563eb',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          macdLine.setData(makeLineData(indicators, (row) => row.macd_line));

          const signalLine = chart.addSeries(
            LineSeries,
            {
              color: '#f97316',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          signalLine.setData(makeLineData(indicators, (row) => row.macd_signal));
          nextPaneIndex += 1;
          break;
        }
        case 'stochastic': {
          const kSeries = chart.addSeries(
            LineSeries,
            {
              color: '#2563eb',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          kSeries.setData(makeLineData(indicators, (row) => row.stoch_k));

          const dSeries = chart.addSeries(
            LineSeries,
            {
              color: '#ec4899',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          dSeries.setData(makeLineData(indicators, (row) => row.stoch_d));

          const upperGuide = chart.addSeries(
            LineSeries,
            {
              color: '#cbd5e1',
              lineWidth: 1,
              lineStyle: LineStyle.Dashed,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          upperGuide.setData(makeConstantLineData(indicators, 80));

          const lowerGuide = chart.addSeries(
            LineSeries,
            {
              color: '#cbd5e1',
              lineWidth: 1,
              lineStyle: LineStyle.Dashed,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          lowerGuide.setData(makeConstantLineData(indicators, 20));
          nextPaneIndex += 1;
          break;
        }
        case 'adx': {
          const adxSeries = chart.addSeries(
            LineSeries,
            {
              color: '#0f172a',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          adxSeries.setData(makeLineData(indicators, (row) => row.adx_14));

          const plusDiSeries = chart.addSeries(
            LineSeries,
            {
              color: '#10b981',
              lineWidth: 1,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          plusDiSeries.setData(makeLineData(indicators, (row) => row.plus_di));

          const minusDiSeries = chart.addSeries(
            LineSeries,
            {
              color: '#f43f5e',
              lineWidth: 1,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          minusDiSeries.setData(makeLineData(indicators, (row) => row.minus_di));

          const guide = chart.addSeries(
            LineSeries,
            {
              color: '#cbd5e1',
              lineWidth: 1,
              lineStyle: LineStyle.Dashed,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
            },
            nextPaneIndex
          );
          guide.setData(makeConstantLineData(indicators, 25));
          nextPaneIndex += 1;
          break;
        }
        case 'obv': {
          const obvSeries = chart.addSeries(
            LineSeries,
            {
              color: '#f59e0b',
              lineWidth: 2,
              crosshairMarkerVisible: false,
              lastValueVisible: false,
              priceLineVisible: false,
              priceFormat: { type: 'volume' },
            },
            nextPaneIndex
          );
          obvSeries.setData(makeLineData(indicators, (row) => row.obv));
          nextPaneIndex += 1;
          break;
        }
        default:
          break;
      }
    }

    chart.priceScale('right', 0).applyOptions({
      scaleMargins: { top: 0.08, bottom: 0.08 },
    });

    const panes = chart.panes();
    if (panes[0]) {
      panes[0].setStretchFactor(visiblePanelCount > 0 ? 4 : 1);
    }

    for (let paneIndex = 1; paneIndex < panes.length; paneIndex += 1) {
      panes[paneIndex]?.setStretchFactor(1);
    }

    chart.timeScale().fitContent();

    return () => {
      chart.remove();
    };
  }, [
    clearDrawingsNonce,
    drawingTool,
    drawings,
    highlightedRange,
    indicators,
    pendingDrawingPoints,
    priceBars,
    requiredPoints,
    settings.chartStyle,
    settings.indicators,
    settings.showVolume,
    visiblePanelCount,
  ]);

  if (priceBars.length === 0) {
    return (
      <div className="flex h-105 items-center justify-center rounded-xl border border-dashed border-gray-200 bg-gray-50 text-sm text-gray-500">
        {isLoading ? 'Loading chart data...' : emptyMessage}
      </div>
    );
  }

  return <div ref={chartContainerRef} className="w-full rounded-xl border border-gray-100" style={{ height: `${chartHeight}px` }} />;
}
