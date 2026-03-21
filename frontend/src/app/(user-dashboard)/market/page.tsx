'use client';

import { useState, useMemo } from 'react';
import { useAllNepseQuotes, useNepseLatestIndices } from '@/hooks/useMarket';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui';
import { Search, Info, ArrowUpRight, TrendingUp, TrendingDown } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import type { HistoricDataRow } from '@/api/market';

export default function MarketPage() {
  const [search, setSearch] = useState('');
  const { data: allQuotes, isLoading } = useAllNepseQuotes();
  const { data: latestIndices } = useNepseLatestIndices();

  const nepseIndex = latestIndices?.data?.find(i => i.index === 'NEPSE');

  const filteredRows = useMemo<HistoricDataRow[]>(() => {
    const rows = allQuotes?.data ?? [];
    if (!search) return rows;
    return rows.filter(r => r.symbol?.toLowerCase().includes(search.toLowerCase()));
  }, [allQuotes, search]);

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">NEPSE Market</h1>
          <p className="text-gray-500">
            Live prices from Supabase
            {allQuotes?.date && (
              <span className="ml-2 text-xs text-gray-400">· as of {allQuotes.date}</span>
            )}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <div className="px-3 py-1 bg-emerald-50 text-emerald-700 rounded-full text-xs font-bold border border-emerald-100 flex items-center gap-1">
            <div className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
            {nepseIndex
              ? `NEPSE: ${nepseIndex.current?.toLocaleString()} (${nepseIndex.pct_change?.toFixed(2)}%)`
              : 'NEPSE INDEX: Loading...'}
          </div>
        </div>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <Input
          placeholder="Search by symbol..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-10 bg-white border-gray-200 text-gray-900 focus:ring-indigo-500 w-full"
        />
      </div>

      <Card className="bg-white border-gray-200 overflow-hidden">
        <CardContent className="p-0 overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Symbol</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">LTP</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Change %</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Volume</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Turnover</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {isLoading ? (
                Array.from({ length: 8 }).map((_, i) => (
                  <tr key={i}>
                    <td colSpan={6} className="px-5 py-3">
                      <Skeleton className="h-8 w-full bg-gray-50" />
                    </td>
                  </tr>
                ))
              ) : filteredRows.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-5 py-20 text-center text-gray-500">
                    <div className="flex flex-col items-center gap-2">
                      <Info className="h-8 w-8 text-gray-300" />
                      <p>No symbols found matching &quot;{search}&quot;.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredRows.map((row) => {
                  const isUp = (row.diff_pct ?? 0) >= 0;
                  return (
                    <tr key={row.symbol} className="hover:bg-indigo-50/30 transition-colors group">
                      <td className="px-5 py-3 font-bold text-indigo-700">{row.symbol}</td>
                      <td className="px-5 py-3 font-mono text-right font-medium text-gray-900">
                        {row.ltp != null ? `Rs. ${row.ltp.toLocaleString()}` : '-'}
                      </td>
                      <td className={`px-5 py-3 text-right font-semibold ${isUp ? 'text-emerald-600' : 'text-rose-600'}`}>
                        <span className="inline-flex items-center justify-end gap-0.5">
                          {isUp ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />}
                          {row.diff_pct != null ? `${row.diff_pct > 0 ? '+' : ''}${row.diff_pct.toFixed(2)}%` : '-'}
                        </span>
                      </td>
                      <td className="px-5 py-3 font-mono text-right text-gray-600">
                        {row.vol != null ? row.vol.toLocaleString() : '-'}
                      </td>
                      <td className="px-5 py-3 font-mono text-right text-gray-600">
                        {row.turnover != null ? `Rs. ${(row.turnover / 1_000_000).toFixed(1)}M` : '-'}
                      </td>
                      <td className="px-5 py-3 text-right">
                        <Link href={`/market/${row.symbol}`}>
                          <Button size="sm" variant="ghost" className="text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50">
                            Chart / Trade <ArrowUpRight className="h-3 w-3 ml-1" />
                          </Button>
                        </Link>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </CardContent>
      </Card>
    </div>
  );
}
