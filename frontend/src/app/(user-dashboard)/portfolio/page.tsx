'use client';

import { useState } from 'react';
import {
  usePortfolioItems,
  usePortfolioAlerts,
  useAddPortfolioItem,
  useRemovePortfolioItem,
  useAnalyzeAllPortfolio,
  useMarkPortfolioAlertRead,
} from '@/hooks/usePortfolio';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Skeleton } from '@/components/ui';
import { Plus, Trash2, BarChart2, X, AlertTriangle, TrendingDown, Info } from 'lucide-react';

const fmt = (n?: number | null) =>
  n != null ? `Rs. ${n.toLocaleString('en-IN', { maximumFractionDigits: 2 })}` : '-';

const pctFmt = (n?: number | null) =>
  n != null ? `${n >= 0 ? '+' : ''}${n.toFixed(2)}%` : '-';

const alertBadgeClass = (type: string) => {
  switch (type) {
    case 'SELL_STRONG': return 'bg-red-100 text-red-700 border border-red-200';
    case 'SELL_CONSIDER': return 'bg-orange-100 text-orange-700 border border-orange-200';
    case 'WARNING': return 'bg-yellow-100 text-yellow-700 border border-yellow-200';
    default: return 'bg-gray-100 text-gray-600 border border-gray-200';
  }
};

interface AddForm {
  symbol: string;
  quantity: string;
  avg_buy_price: string;
  buy_date: string;
  notes: string;
}

const defaultForm: AddForm = { symbol: '', quantity: '', avg_buy_price: '', buy_date: '', notes: '' };

export default function PortfolioPage() {
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState<AddForm>(defaultForm);
  const [confirmDeleteId, setConfirmDeleteId] = useState<number | null>(null);

  const { data: items = [], isLoading: itemsLoading } = usePortfolioItems();
  const { data: alerts = [], isLoading: alertsLoading } = usePortfolioAlerts();
  const addItem = useAddPortfolioItem();
  const removeItem = useRemovePortfolioItem();
  const analyzeAll = useAnalyzeAllPortfolio();
  const markRead = useMarkPortfolioAlertRead();

  const totalCostBasis = items.reduce((s, i) => s + (i.cost_basis ?? 0), 0);
  const totalCurrentValue = items.reduce((s, i) => s + (i.current_value ?? 0), 0);
  const totalPnl = totalCurrentValue - totalCostBasis;
  const totalPnlPct = totalCostBasis > 0 ? (totalPnl / totalCostBasis) * 100 : 0;

  const unreadAlerts = alerts.filter((a) => !a.is_read);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    await addItem.mutateAsync({
      symbol: form.symbol.toUpperCase(),
      quantity: Number(form.quantity),
      avg_buy_price: Number(form.avg_buy_price),
      buy_date: form.buy_date,
      notes: form.notes || undefined,
    });
    setForm(defaultForm);
    setShowForm(false);
  };

  const handleDelete = async (id: number) => {
    await removeItem.mutateAsync(id);
    setConfirmDeleteId(null);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Portfolio</h1>
          <p className="text-gray-500 text-sm">Track your real stock holdings and P&amp;L</p>
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => analyzeAll.mutate()}
            disabled={analyzeAll.isPending || items.length === 0}
            variant="ghost"
            className="text-indigo-600 hover:bg-indigo-50 border border-indigo-200"
          >
            <BarChart2 className="h-4 w-4 mr-1.5" />
            {analyzeAll.isPending ? 'Analysing…' : 'Run Analysis'}
          </Button>
          <Button onClick={() => setShowForm((v) => !v)} className="bg-indigo-600 hover:bg-indigo-700 text-white">
            <Plus className="h-4 w-4 mr-1.5" />
            Add Stock
          </Button>
        </div>
      </div>

      {/* Add Form */}
      {showForm && (
        <Card className="bg-white border-gray-200">
          <CardContent className="p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-900">Add New Holding</h2>
              <button onClick={() => setShowForm(false)} className="text-gray-400 hover:text-gray-600">
                <X className="h-4 w-4" />
              </button>
            </div>
            <form onSubmit={handleAdd} className="grid grid-cols-2 md:grid-cols-3 gap-4">
              <div className="space-y-1">
                <Label htmlFor="symbol">Symbol *</Label>
                <Input
                  id="symbol"
                  placeholder="e.g. NABIL"
                  value={form.symbol}
                  onChange={(e) => setForm((f) => ({ ...f, symbol: e.target.value }))}
                  required
                />
              </div>
              <div className="space-y-1">
                <Label htmlFor="quantity">Quantity *</Label>
                <Input
                  id="quantity"
                  type="number"
                  min="1"
                  placeholder="e.g. 100"
                  value={form.quantity}
                  onChange={(e) => setForm((f) => ({ ...f, quantity: e.target.value }))}
                  required
                />
              </div>
              <div className="space-y-1">
                <Label htmlFor="avg_buy_price">Avg Buy Price *</Label>
                <Input
                  id="avg_buy_price"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="e.g. 1200.00"
                  value={form.avg_buy_price}
                  onChange={(e) => setForm((f) => ({ ...f, avg_buy_price: e.target.value }))}
                  required
                />
              </div>
              <div className="space-y-1">
                <Label htmlFor="buy_date">Buy Date *</Label>
                <Input
                  id="buy_date"
                  type="date"
                  value={form.buy_date}
                  onChange={(e) => setForm((f) => ({ ...f, buy_date: e.target.value }))}
                  required
                />
              </div>
              <div className="space-y-1 col-span-2">
                <Label htmlFor="notes">Notes</Label>
                <Input
                  id="notes"
                  placeholder="Optional notes"
                  value={form.notes}
                  onChange={(e) => setForm((f) => ({ ...f, notes: e.target.value }))}
                />
              </div>
              <div className="col-span-2 md:col-span-3 flex gap-2 justify-end pt-2">
                <Button type="button" variant="ghost" onClick={() => setShowForm(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={addItem.isPending} className="bg-indigo-600 hover:bg-indigo-700 text-white">
                  {addItem.isPending ? 'Adding…' : 'Add Holding'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Summary Cards */}
      {!itemsLoading && items.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <Card className="bg-white border-gray-200">
            <CardContent className="p-4">
              <p className="text-xs text-gray-500 uppercase tracking-wider mb-1">Total Cost Basis</p>
              <p className="text-xl font-bold text-gray-900">{fmt(totalCostBasis)}</p>
            </CardContent>
          </Card>
          <Card className="bg-white border-gray-200">
            <CardContent className="p-4">
              <p className="text-xs text-gray-500 uppercase tracking-wider mb-1">Total Current Value</p>
              <p className="text-xl font-bold text-gray-900">{fmt(totalCurrentValue)}</p>
            </CardContent>
          </Card>
          <Card className="bg-white border-gray-200">
            <CardContent className="p-4">
              <p className="text-xs text-gray-500 uppercase tracking-wider mb-1">Total P&amp;L</p>
              <p className={`text-xl font-bold ${totalPnl >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                {fmt(totalPnl)}{' '}
                <span className="text-sm font-medium">({pctFmt(totalPnlPct)})</span>
              </p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Alerts Section */}
      {!alertsLoading && unreadAlerts.length > 0 && (
        <div className="space-y-2">
          <h2 className="text-sm font-semibold text-gray-700 flex items-center gap-1.5">
            <AlertTriangle className="h-4 w-4 text-orange-500" />
            Portfolio Alerts ({unreadAlerts.length})
          </h2>
          <div className="space-y-2">
            {unreadAlerts.map((alert) => (
              <Card key={alert.id} className="bg-white border-gray-200">
                <CardContent className="p-4 flex flex-col sm:flex-row sm:items-start gap-3">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="font-bold text-indigo-700">{alert.symbol}</span>
                      <span className={`text-xs font-semibold px-2 py-0.5 rounded-full ${alertBadgeClass(alert.alert_type)}`}>
                        {alert.alert_type.replace('_', ' ')}
                      </span>
                      <span className="text-xs text-gray-400">Score: {alert.signal_score}</span>
                    </div>
                    <p className="text-sm text-gray-700 mb-1">{alert.analysis_summary}</p>
                    {alert.key_signals.length > 0 && (
                      <ul className="list-disc list-inside text-xs text-gray-500 space-y-0.5">
                        {alert.key_signals.map((s, i) => <li key={i}>{s}</li>)}
                      </ul>
                    )}
                    <p className="text-xs text-gray-600 mt-1 font-medium">
                      Recommended: {alert.recommended_action}
                    </p>
                  </div>
                  <Button
                    size="sm"
                    variant="ghost"
                    onClick={() => markRead.mutate(alert.id)}
                    className="text-gray-400 hover:text-gray-600 shrink-0"
                  >
                    <X className="h-3.5 w-3.5" />
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}

      {/* Portfolio Table */}
      <Card className="bg-white border-gray-200 overflow-hidden">
        <CardContent className="p-0 overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Symbol</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Qty</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Avg Price</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Cost Basis</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Current Price</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Current Value</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">P&amp;L</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">P&amp;L%</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {itemsLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i}>
                    <td colSpan={9} className="px-5 py-3">
                      <Skeleton className="h-8 w-full bg-gray-50" />
                    </td>
                  </tr>
                ))
              ) : items.length === 0 ? (
                <tr>
                  <td colSpan={9} className="px-5 py-20 text-center text-gray-500">
                    <div className="flex flex-col items-center gap-2">
                      <Info className="h-8 w-8 text-gray-300" />
                      <p>No holdings yet. Click &quot;Add Stock&quot; to get started.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                items.map((item) => {
                  const pnl = item.unrealised_pnl;
                  const pnlPct = item.unrealised_pnl_pct;
                  const isUp = (pnl ?? 0) >= 0;
                  return (
                    <tr key={item.id} className="hover:bg-indigo-50/30 transition-colors">
                      <td className="px-5 py-3 font-bold text-indigo-700">{item.symbol}</td>
                      <td className="px-5 py-3 text-right text-gray-700">{item.quantity.toLocaleString()}</td>
                      <td className="px-5 py-3 text-right font-mono text-gray-700">{fmt(item.avg_buy_price)}</td>
                      <td className="px-5 py-3 text-right font-mono text-gray-700">{fmt(item.cost_basis)}</td>
                      <td className="px-5 py-3 text-right font-mono text-gray-700">{fmt(item.current_price)}</td>
                      <td className="px-5 py-3 text-right font-mono text-gray-700">{fmt(item.current_value)}</td>
                      <td className={`px-5 py-3 text-right font-mono font-semibold ${pnl != null ? (isUp ? 'text-green-600' : 'text-red-600') : 'text-gray-400'}`}>
                        {pnl != null ? fmt(pnl) : '-'}
                      </td>
                      <td className={`px-5 py-3 text-right font-semibold ${pnlPct != null ? (isUp ? 'text-green-600' : 'text-red-600') : 'text-gray-400'}`}>
                        {pctFmt(pnlPct)}
                      </td>
                      <td className="px-5 py-3 text-right">
                        {confirmDeleteId === item.id ? (
                          <div className="flex items-center justify-end gap-1">
                            <span className="text-xs text-gray-500">Confirm?</span>
                            <Button size="sm" variant="ghost" onClick={() => handleDelete(item.id)} className="text-red-600 hover:bg-red-50 text-xs px-2 py-1 h-auto">
                              Yes
                            </Button>
                            <Button size="sm" variant="ghost" onClick={() => setConfirmDeleteId(null)} className="text-gray-500 text-xs px-2 py-1 h-auto">
                              No
                            </Button>
                          </div>
                        ) : (
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => setConfirmDeleteId(item.id)}
                            className="text-gray-400 hover:text-red-600 hover:bg-red-50"
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </Button>
                        )}
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
