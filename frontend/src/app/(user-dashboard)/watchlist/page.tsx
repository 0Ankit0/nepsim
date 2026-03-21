'use client';

import { useState } from 'react';
import {
  useWatchlistItems,
  useWatchlistAlerts,
  useAddWatchlistItem,
  useRemoveWatchlistItem,
  useCheckWatchlistSignals,
  useMarkWatchlistAlertRead,
} from '@/hooks/useWatchlist';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Skeleton } from '@/components/ui';
import { Plus, Trash2, Radar, X, TrendingUp, Info } from 'lucide-react';

const fmt = (n?: number | null) =>
  n != null ? `Rs. ${n.toLocaleString('en-IN', { maximumFractionDigits: 2 })}` : '-';

const alertBadgeClass = (type: string) => {
  switch (type) {
    case 'BUY_STRONG': return 'bg-green-100 text-green-700 border border-green-200';
    case 'BUY_CONSIDER': return 'bg-blue-100 text-blue-700 border border-blue-200';
    case 'ACCUMULATE': return 'bg-teal-100 text-teal-700 border border-teal-200';
    default: return 'bg-gray-100 text-gray-600 border border-gray-200';
  }
};

interface AddForm {
  symbol: string;
  target_price: string;
  stop_loss: string;
  notes: string;
}

const defaultForm: AddForm = { symbol: '', target_price: '', stop_loss: '', notes: '' };

export default function WatchlistPage() {
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState<AddForm>(defaultForm);
  const [confirmDeleteId, setConfirmDeleteId] = useState<number | null>(null);

  const { data: items = [], isLoading: itemsLoading } = useWatchlistItems();
  const { data: alerts = [], isLoading: alertsLoading } = useWatchlistAlerts();
  const addItem = useAddWatchlistItem();
  const removeItem = useRemoveWatchlistItem();
  const checkSignals = useCheckWatchlistSignals();
  const markRead = useMarkWatchlistAlertRead();

  const unreadAlerts = alerts.filter((a) => !a.is_read);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    await addItem.mutateAsync({
      symbol: form.symbol.toUpperCase(),
      target_price: form.target_price ? Number(form.target_price) : undefined,
      stop_loss: form.stop_loss ? Number(form.stop_loss) : undefined,
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
          <h1 className="text-2xl font-bold text-gray-900">My Watchlist</h1>
          <p className="text-gray-500 text-sm">Monitor stocks and receive buy signal alerts</p>
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => checkSignals.mutate()}
            disabled={checkSignals.isPending || items.length === 0}
            variant="ghost"
            className="text-indigo-600 hover:bg-indigo-50 border border-indigo-200"
          >
            <Radar className="h-4 w-4 mr-1.5" />
            {checkSignals.isPending ? 'Checking…' : 'Check Signals'}
          </Button>
          <Button onClick={() => setShowForm((v) => !v)} className="bg-indigo-600 hover:bg-indigo-700 text-white">
            <Plus className="h-4 w-4 mr-1.5" />
            Add to Watchlist
          </Button>
        </div>
      </div>

      {/* Add Form */}
      {showForm && (
        <Card className="bg-white border-gray-200">
          <CardContent className="p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-900">Add to Watchlist</h2>
              <button onClick={() => setShowForm(false)} className="text-gray-400 hover:text-gray-600">
                <X className="h-4 w-4" />
              </button>
            </div>
            <form onSubmit={handleAdd} className="grid grid-cols-2 md:grid-cols-4 gap-4">
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
                <Label htmlFor="target_price">Target Price</Label>
                <Input
                  id="target_price"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="e.g. 1500"
                  value={form.target_price}
                  onChange={(e) => setForm((f) => ({ ...f, target_price: e.target.value }))}
                />
              </div>
              <div className="space-y-1">
                <Label htmlFor="stop_loss">Stop Loss</Label>
                <Input
                  id="stop_loss"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="e.g. 900"
                  value={form.stop_loss}
                  onChange={(e) => setForm((f) => ({ ...f, stop_loss: e.target.value }))}
                />
              </div>
              <div className="space-y-1">
                <Label htmlFor="notes">Notes</Label>
                <Input
                  id="notes"
                  placeholder="Optional"
                  value={form.notes}
                  onChange={(e) => setForm((f) => ({ ...f, notes: e.target.value }))}
                />
              </div>
              <div className="col-span-2 md:col-span-4 flex gap-2 justify-end pt-2">
                <Button type="button" variant="ghost" onClick={() => setShowForm(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={addItem.isPending} className="bg-indigo-600 hover:bg-indigo-700 text-white">
                  {addItem.isPending ? 'Adding…' : 'Add Stock'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Buy Signal Alerts */}
      {!alertsLoading && unreadAlerts.length > 0 && (
        <div className="space-y-2">
          <h2 className="text-sm font-semibold text-gray-700 flex items-center gap-1.5">
            <TrendingUp className="h-4 w-4 text-green-500" />
            Buy Signal Alerts ({unreadAlerts.length})
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
                    <div className="flex flex-wrap gap-4 text-xs text-gray-600 mb-1">
                      {alert.entry_price != null && <span>Entry: <strong>{fmt(alert.entry_price)}</strong></span>}
                      {alert.target_price != null && <span>Target: <strong className="text-green-600">{fmt(alert.target_price)}</strong></span>}
                      {alert.stop_loss_price != null && <span>Stop: <strong className="text-red-600">{fmt(alert.stop_loss_price)}</strong></span>}
                    </div>
                    {alert.key_signals.length > 0 && (
                      <ul className="list-disc list-inside text-xs text-gray-500 space-y-0.5">
                        {alert.key_signals.map((s, i) => <li key={i}>{s}</li>)}
                      </ul>
                    )}
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

      {/* Watchlist Table */}
      <Card className="bg-white border-gray-200 overflow-hidden">
        <CardContent className="p-0 overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Symbol</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Current Price</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Change%</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Target</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Stop Loss</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Notes</th>
                <th className="px-5 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {itemsLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i}>
                    <td colSpan={7} className="px-5 py-3">
                      <Skeleton className="h-8 w-full bg-gray-50" />
                    </td>
                  </tr>
                ))
              ) : items.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-5 py-20 text-center text-gray-500">
                    <div className="flex flex-col items-center gap-2">
                      <Info className="h-8 w-8 text-gray-300" />
                      <p>Your watchlist is empty. Click &quot;Add to Watchlist&quot; to start tracking stocks.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                items.map((item) => {
                  const isUp = (item.diff_pct ?? 0) >= 0;
                  return (
                    <tr key={item.id} className="hover:bg-indigo-50/30 transition-colors">
                      <td className="px-5 py-3 font-bold text-indigo-700">{item.symbol}</td>
                      <td className="px-5 py-3 text-right font-mono text-gray-700">{fmt(item.current_price)}</td>
                      <td className={`px-5 py-3 text-right font-semibold ${item.diff_pct != null ? (isUp ? 'text-green-600' : 'text-red-600') : 'text-gray-400'}`}>
                        {item.diff_pct != null ? `${item.diff_pct >= 0 ? '+' : ''}${item.diff_pct.toFixed(2)}%` : '-'}
                      </td>
                      <td className="px-5 py-3 text-right font-mono text-gray-700">{fmt(item.target_price)}</td>
                      <td className="px-5 py-3 text-right font-mono text-gray-700">{fmt(item.stop_loss)}</td>
                      <td className="px-5 py-3 text-gray-500 text-xs max-w-[180px] truncate">{item.notes ?? '-'}</td>
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
