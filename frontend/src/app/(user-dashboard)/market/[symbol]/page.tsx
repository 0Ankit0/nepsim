'use client';

import { use, useEffect, useRef, Suspense } from 'react';
import { createChart, ColorType, IChartApi, ISeriesApi } from 'lightweight-charts';
import { useNepseQuote, useNepseHistory, useNepseLatestIndicators } from '@/hooks/useMarket';
import { useExecuteTrade } from '@/hooks/useSimulator';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { TrendingUp, TrendingDown, ArrowLeft, ShoppingCart, Loader2 } from 'lucide-react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import { useState } from 'react';

function SymbolDashboard({ symbol }: { symbol: string }) {
  const searchParams = useSearchParams();
  const simId = searchParams.get('simId');

  const { data: quote, isLoading: isQuoteLoading } = useNepseQuote(symbol);
  const { data: history, isLoading: isHistoryLoading } = useNepseHistory(symbol);
  const { data: indicators } = useNepseLatestIndicators(symbol);
  
  const executeTrade = useExecuteTrade(simId ? parseInt(simId) : 0);
  const [tradeQuantity, setTradeQuantity] = useState('10');

  const chartContainerRef = useRef<HTMLDivElement>(null);
  const chartInstance = useRef<IChartApi | null>(null);
  const seriesInstance = useRef<ISeriesApi<"Candlestick"> | null>(null);
  const volumeSeriesInstance = useRef<ISeriesApi<"Histogram"> | null>(null);

  useEffect(() => {
    if (!chartContainerRef.current || !history?.data) return;

    if (!chartInstance.current) {
        chartInstance.current = createChart(chartContainerRef.current, {
            layout: { background: { type: ColorType.Solid, color: 'transparent' }, textColor: '#4b5563' },
            grid: { vertLines: { color: '#f3f4f6' }, horzLines: { color: '#f3f4f6' } },
            width: chartContainerRef.current.clientWidth,
            height: 400,
            timeScale: { timeVisible: false, borderColor: '#e5e7eb' },
            rightPriceScale: { borderColor: '#e5e7eb' },
        });

        seriesInstance.current = (chartInstance.current as any).addCandlestickSeries({
            upColor: '#10b981', downColor: '#f43f5e', borderVisible: false, wickUpColor: '#10b981', wickDownColor: '#f43f5e',
        });

        volumeSeriesInstance.current = (chartInstance.current as any).addHistogramSeries({
            color: '#e5e7eb', priceFormat: { type: 'volume' }, priceScaleId: '', scaleMargins: { top: 0.8, bottom: 0 },
        });

        const handleResize = () => {
          if (chartContainerRef.current && chartInstance.current) {
            chartInstance.current.applyOptions({ width: chartContainerRef.current.clientWidth });
          }
        };
        window.addEventListener('resize', handleResize);
        
        return () => {
            window.removeEventListener('resize', handleResize);
            chartInstance.current?.remove();
            chartInstance.current = null;
        };
    }

  }, [history]);

  useEffect(() => {
    if (seriesInstance.current && volumeSeriesInstance.current && history?.data) {
        const sorted = [...history.data].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        const candleData = sorted.map(r => ({
            time: r.date.split('T')[0],
            open: r.open ?? 0,
            high: r.high ?? 0,
            low: r.low ?? 0,
            close: r.close ?? 0,
        }));
        
        const uniqueCandles = [];
        const seen = new Set();
        for (const item of candleData) {
            if (!seen.has(item.time)) {
                seen.add(item.time);
                uniqueCandles.push(item);
            }
        }
        
        seriesInstance.current.setData(uniqueCandles as any);

        const volumeData = uniqueCandles.map((r, i) => ({
            time: r.time,
            value: sorted[i].vol ?? 0,
            color: (r.close ?? 0) >= (r.open ?? 0) ? '#10b98140' : '#f43f5e40'
        }));
        volumeSeriesInstance.current.setData(volumeData as any);
        chartInstance.current?.timeScale().fitContent();
    }
  }, [history]);

  const isUp = (quote?.diff_pct || 0) >= 0;

  const handleTrade = (side: 'buy' | 'sell') => {
      const quantity = parseInt(tradeQuantity);
      if (isNaN(quantity) || quantity <= 0) return alert('Enter a valid quantity');
      executeTrade.mutate(
          { symbol, side, quantity },
          {
              onSuccess: () => alert(`Successfully placed ${side} order for ${quantity} shares of ${symbol}!`),
              onError: (err: any) => alert(err.response?.data?.detail || 'Trade Failed')
          }
      );
  };

  return (
    <div className="space-y-6">
      <Link href={simId ? `/simulator/${simId}` : `/market`} className="text-sm font-medium text-indigo-600 hover:text-indigo-700 flex items-center gap-1 w-fit">
        <ArrowLeft className="h-4 w-4" /> {simId ? `Back to Simulator #${simId}` : 'Back to Market'}
      </Link>

      <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">{symbol}</h1>
          <p className="text-gray-500">Live NEPSE Datasource</p>
        </div>
        
        {!isQuoteLoading && quote && (
            <div className="text-right">
                <div className="text-3xl font-mono relative font-bold text-gray-900">
                    Rs. {quote.ltp?.toLocaleString()}
                </div>
                <div className={`flex items-center justify-end gap-1 font-bold ${isUp ? 'text-emerald-600' : 'text-rose-600'}`}>
                    {isUp ? <TrendingUp className="h-4 w-4" /> : <TrendingDown className="h-4 w-4" />}
                    {Math.abs(quote.diff || 0).toFixed(2)} ({Math.abs(quote.diff_pct || 0).toFixed(2)}%)
                </div>
            </div>
        )}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2 overflow-hidden shadow-sm border-gray-100">
            <CardHeader className="bg-gray-50/50 border-b border-gray-100 py-3">
                <CardTitle className="text-sm text-gray-600 font-semibold flex justify-between">
                    OHLCV Price History
                    {isHistoryLoading && <span className="text-indigo-500 animate-pulse">Loading Chart...</span>}
                </CardTitle>
            </CardHeader>
            <CardContent className="p-4">
                <div ref={chartContainerRef} className="w-full h-[400px]" />
            </CardContent>
        </Card>

        <div className="space-y-6">
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
                            <label className="text-xs font-bold text-gray-600 uppercase tracking-wider">Quantity (Shares)</label>
                            <Input 
                                type="number" 
                                min="10" 
                                step="10" 
                                value={tradeQuantity} 
                                onChange={e => setTradeQuantity(e.target.value)} 
                                className="font-mono text-lg"
                            />
                        </div>
                        <div className="grid grid-cols-2 gap-3 pt-2">
                            <Button 
                                className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold"
                                onClick={() => handleTrade('buy')}
                                disabled={executeTrade.isPending}
                            >
                                {executeTrade.isPending && executeTrade.variables?.side === 'buy' ? <Loader2 className="h-4 w-4 animate-spin mr-2" /> : null}
                                Buy
                            </Button>
                            <Button 
                                className="w-full bg-rose-600 hover:bg-rose-700 text-white font-bold"
                                onClick={() => handleTrade('sell')}
                                disabled={executeTrade.isPending}
                            >
                                {executeTrade.isPending && executeTrade.variables?.side === 'sell' ? <Loader2 className="h-4 w-4 animate-spin mr-2" /> : null}
                                Sell
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            )}

            <Card className="shadow-sm border-gray-100">
                <CardHeader className="bg-gray-50/50 border-b border-gray-100 py-3">
                    <CardTitle className="text-sm text-gray-600 font-semibold">Latest Snapshot</CardTitle>
                </CardHeader>
                <CardContent className="p-4 space-y-3 text-sm">
                    <div className="flex justify-between border-b pb-2"><span className="text-gray-500">Close</span><span className="font-mono font-medium">{quote?.close || '-'}</span></div>
                    <div className="flex justify-between border-b pb-2"><span className="text-gray-500">Open</span><span className="font-mono font-medium">{quote?.open || '-'}</span></div>
                    <div className="flex justify-between border-b pb-2"><span className="text-gray-500">High / Low</span><span className="font-mono font-medium">{quote?.high || '-'} / {quote?.low || '-'}</span></div>
                    <div className="flex justify-between border-b pb-2"><span className="text-gray-500">Volume</span><span className="font-mono font-medium">{quote?.vol?.toLocaleString() || '-'}</span></div>
                    <div className="flex justify-between"><span className="text-gray-500">52W Range</span><span className="font-mono font-medium text-xs">{quote?.weeks_52_low} - {quote?.weeks_52_high}</span></div>
                </CardContent>
            </Card>

            <Card className="shadow-sm border-gray-100">
                <CardHeader className="bg-gray-50/50 border-b border-gray-100 py-3">
                    <CardTitle className="text-sm text-gray-600 font-semibold">Technical Indicators</CardTitle>
                </CardHeader>
                <CardContent className="p-4 grid grid-cols-2 gap-4 text-sm">
                    <div>
                        <div className="text-gray-500 text-xs uppercase tracking-wider">RSI (14)</div>
                        <div className="font-mono font-bold text-lg">{indicators?.rsi_14?.toFixed(2) || '-'}</div>
                    </div>
                    <div>
                        <div className="text-gray-500 text-xs uppercase tracking-wider">MACD</div>
                        <div className="font-mono font-bold text-lg">{indicators?.macd_line?.toFixed(2) || '-'}</div>
                    </div>
                    <div>
                        <div className="text-gray-500 text-xs uppercase tracking-wider">Bollinger Up</div>
                        <div className="font-mono font-bold">{indicators?.bb_upper?.toFixed(2) || '-'}</div>
                    </div>
                    <div>
                        <div className="text-gray-500 text-xs uppercase tracking-wider">Bollinger Low</div>
                        <div className="font-mono font-bold">{indicators?.bb_lower?.toFixed(2) || '-'}</div>
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
