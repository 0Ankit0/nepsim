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
import { useEffect, useMemo, useRef } from 'react';
import type { IndicatorRow } from '@/api/market';
import type { ChartLayoutSettings, PriceBar } from './chart-config';
import { getIndicatorMeta } from './chart-config';
import { makeConstantLineData, makeLineData } from './data-utils';

interface MarketChartCanvasProps {
  priceBars: PriceBar[];
  indicators: IndicatorRow[];
  settings: ChartLayoutSettings;
  isLoading?: boolean;
  emptyMessage?: string;
}

export function MarketChartCanvas({
  priceBars,
  indicators,
  settings,
  isLoading = false,
  emptyMessage = 'No historic chart data is available for this symbol.',
}: MarketChartCanvasProps) {
  const chartContainerRef = useRef<HTMLDivElement>(null);

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
    }

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
  }, [indicators, priceBars, settings.chartStyle, settings.indicators, settings.showVolume, visiblePanelCount]);

  if (priceBars.length === 0) {
    return (
      <div className="flex h-105 items-center justify-center rounded-xl border border-dashed border-gray-200 bg-gray-50 text-sm text-gray-500">
        {isLoading ? 'Loading chart data...' : emptyMessage}
      </div>
    );
  }

  return <div ref={chartContainerRef} className="w-full rounded-xl border border-gray-100" style={{ height: `${chartHeight}px` }} />;
}
