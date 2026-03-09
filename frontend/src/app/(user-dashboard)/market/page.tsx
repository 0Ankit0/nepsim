'use client';

import { useState } from 'react';
import { useStocks } from '@/hooks';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui';
import { Search, TrendingUp, TrendingDown, Info, ArrowUpRight } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function MarketPage() {
  const [search, setSearch] = useState('');
  const { data: stocks, isLoading } = useStocks({ limit: 100 });

  const filteredStocks = (stocks?.items ?? []).filter(s => 
    s.symbol.toLowerCase().includes(search.toLowerCase()) ||
    s.name.toLowerCase().includes(search.toLowerCase()) ||
    s.sector.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">NEPSE Market</h1>
          <p className="text-gray-500">Live prices and historical data for all listed symbols</p>
        </div>
        <div className="flex items-center gap-2">
            <div className="px-3 py-1 bg-emerald-50 text-emerald-700 rounded-full text-xs font-bold border border-emerald-100 flex items-center gap-1">
                <div className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                NEPSE INDEX: 2,124.50 (+1.2%)
            </div>
        </div>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <Input
          placeholder="Search by symbol, name, or sector..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-10 bg-white border-gray-200 text-gray-900 focus:ring-indigo-500 w-full"
        />
      </div>

      <Card className="bg-white border-gray-200 overflow-hidden">
        <CardContent className="p-0 overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Symbol</th>
                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Company Name</th>
                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Sector</th>
                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">LTP (Rs.)</th>
                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Change (%)</th>
                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Volume</th>
                <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider text-center">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i}>
                    <td colSpan={7} className="px-6 py-4">
                      <Skeleton className="h-12 w-full bg-gray-50" />
                    </td>
                  </tr>
                ))
              ) : filteredStocks.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-20 text-center text-gray-500">
                    <div className="flex flex-col items-center gap-2">
                        <Info className="h-8 w-8 text-gray-300" />
                        <p>No symbols found matching your search.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredStocks.map((stock) => (
                  <tr key={stock.symbol} className="hover:bg-indigo-50/30 transition-colors group">
                    <td className="px-6 py-4 font-bold text-indigo-700">
                      {stock.symbol}
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm font-medium text-gray-900">{stock.name}</div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800">
                        {stock.sector}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right font-mono text-sm font-bold text-gray-900">
                      {stock.last_price.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className={`inline-flex items-center gap-1 font-bold ${stock.change_pct >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                        {stock.change_pct >= 0 ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />}
                        {Math.abs(stock.change_pct).toFixed(2)}%
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right text-sm text-gray-500">
                      {stock.volume.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 text-center">
                        <Link href={`/market/${stock.symbol}`}>
                            <Button size="sm" variant="ghost" className="text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50">
                                <ArrowUpRight className="h-4 w-4" />
                            </Button>
                        </Link>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </CardContent>
      </Card>
    </div>
  );
}
