// @ts-nocheck

'use client';

import { useState } from 'react';
import {
  useStocks,
  useCreateStock,
  useUpdateStock,
  useDeleteStock,
  useUploadMarketData,
} from '@/hooks';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui';
import {
  TrendingUp, Search, Pencil, Trash2, Plus, Upload, Check, X, Building2, Layers,
} from 'lucide-react';
import type { StockListItem, StockDetail } from '@/types';

function StockRow({ 
  stock, 
  onEdit, 
  onDelete, 
  onUpload 
}: {
  stock: StockListItem;
  onEdit: (stock: StockListItem) => void;
  onDelete: (symbol: string) => void;
  onUpload: (symbol: string) => void;
}) {
  return (
    <tr className="border-b border-slate-800 hover:bg-slate-800/50 transition-colors">
      <td className="px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="h-8 w-8 rounded bg-indigo-900/50 flex items-center justify-center text-indigo-400 font-bold border border-indigo-500/30">
            {stock.symbol[0]}
          </div>
          <div>
            <p className="text-sm font-bold text-white">{stock.symbol}</p>
            <p className="text-xs text-slate-400 truncate max-w-[200px]">{stock.company_name}</p>
          </div>
        </div>
      </td>
      <td className="px-4 py-3 text-sm text-slate-300">{stock.sector}</td>
      <td className="px-4 py-3">
        <span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium ${
          stock.is_active ? 'bg-emerald-900/30 text-emerald-400' : 'bg-rose-900/30 text-rose-400'
        }`}>
          {stock.is_active ? <Check className="h-3 w-3" /> : <X className="h-3 w-3" />}
          {stock.is_active ? 'Active' : 'Inactive'}
        </span>
      </td>
      <td className="px-4 py-3 text-sm font-mono text-indigo-300">
        {stock.current_price ? `Rs. ${stock.current_price.toFixed(2)}` : 'N/A'}
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-1">
          <button
            onClick={() => onUpload(stock.symbol)}
            className="p-1.5 text-slate-400 hover:text-indigo-400 rounded hover:bg-slate-700"
            title="Upload CSV Data"
          >
            <Upload className="h-4 w-4" />
          </button>
          <button
            onClick={() => onEdit(stock)}
            className="p-1.5 text-slate-400 hover:text-white rounded hover:bg-slate-700"
            title="Edit"
          >
            <Pencil className="h-4 w-4" />
          </button>
          <button
            onClick={() => onDelete(stock.symbol)}
            className="p-1.5 text-rose-400 hover:text-rose-300 rounded hover:bg-rose-900/20"
            title="Delete"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      </td>
    </tr>
  );
}

function StockModal({ 
  stock, 
  onClose,
  isEdit = false
}: { 
  stock?: Partial<StockDetail>; 
  onClose: () => void;
  isEdit?: boolean;
}) {
  const createStock = useCreateStock();
  const updateStock = useUpdateStock();
  
  const [formData, setFormData] = useState({
    symbol: stock?.symbol ?? '',
    company_name: stock?.company_name ?? '',
    sector: stock?.sector ?? 'Banking',
    lot_size: stock?.lot_size ?? 10,
    face_value: stock?.face_value ?? 100.0,
    tick_size: stock?.tick_size ?? 0.1,
    is_active: stock?.is_active ?? true,
  });

  const handleSave = () => {
    if (isEdit && stock?.symbol) {
      updateStock.mutate({ symbol: stock.symbol, data: formData }, { onSuccess: onClose });
    } else {
      createStock.mutate(formData as any, { onSuccess: onClose });
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <Card className="w-full max-w-lg bg-slate-900 border-slate-700 shadow-2xl">
        <CardHeader>
          <CardTitle className="text-white flex items-center gap-2 text-xl">
            {isEdit ? <Pencil className="h-5 w-5 text-indigo-400" /> : <Plus className="h-5 w-5 text-indigo-400" />}
            {isEdit ? `Edit Stock: ${stock?.symbol}` : 'Add New Stock'}
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Symbol</label>
              <Input
                placeholder="e.g. NABIL"
                value={formData.symbol}
                onChange={(e) => setFormData({ ...formData, symbol: e.target.value })}
                disabled={isEdit}
                className="bg-slate-800 border-slate-700 text-white"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Sector</label>
              <select
                value={formData.sector}
                onChange={(e) => setFormData({ ...formData, sector: e.target.value })}
                className="w-full h-10 px-3 py-2 rounded-md border border-slate-700 bg-slate-800 text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                {['Banking', 'Hydropower', 'Insurance', 'Finance', 'Telecom', 'Manufacturing', 'Hotel', 'Others'].map(s => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>
          </div>
          
          <div className="space-y-2">
            <label className="text-sm font-medium text-slate-300">Company Name</label>
            <Input
              placeholder="Full company name"
              value={formData.company_name}
              onChange={(e) => setFormData({ ...formData, company_name: e.target.value })}
              className="bg-slate-800 border-slate-700 text-white"
            />
          </div>

          <div className="grid grid-cols-3 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Lot Size</label>
              <Input
                type="number"
                value={formData.lot_size}
                onChange={(e) => setFormData({ ...formData, lot_size: parseInt(e.target.value) })}
                className="bg-slate-800 border-slate-700 text-white"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Tick Size</label>
              <Input
                type="number"
                step="0.01"
                value={formData.tick_size}
                onChange={(e) => setFormData({ ...formData, tick_size: parseFloat(e.target.value) })}
                className="bg-slate-800 border-slate-700 text-white"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Face Value</label>
              <Input
                type="number"
                value={formData.face_value}
                onChange={(e) => setFormData({ ...formData, face_value: parseFloat(e.target.value) })}
                className="bg-slate-800 border-slate-700 text-white"
              />
            </div>
          </div>

          <label className="flex items-center gap-2 cursor-pointer pb-2">
            <input
              type="checkbox"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              className="rounded border-slate-700 bg-slate-800 text-indigo-600 focus:ring-indigo-500"
            />
            <span className="text-sm text-slate-300 font-medium">Is Active for Simulation</span>
          </label>

          <div className="flex gap-3 justify-end pt-2">
            <Button variant="outline" onClick={onClose} className="border-slate-700 text-slate-300 hover:bg-slate-800">Cancel</Button>
            <Button 
              onClick={handleSave} 
              isLoading={createStock.isPending || updateStock.isPending}
              className="bg-indigo-600 hover:bg-indigo-700 text-white"
            >
              {isEdit ? 'Update Stock' : 'Create Stock'}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

function UploadModal({ symbol, onClose }: { symbol: string; onClose: () => void }) {
  const uploadData = useUploadMarketData();
  const [file, setFile] = useState<File | null>(null);

  const handleUpload = () => {
    if (file) {
      uploadData.mutate({ symbol, file }, { onSuccess: onClose });
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <Card className="w-full max-w-md bg-slate-900 border-slate-700 shadow-2xl">
        <CardHeader>
          <CardTitle className="text-white flex items-center gap-2">
            <Upload className="h-5 w-5 text-indigo-400" />
            Upload Prices: {symbol}
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-slate-400">
            Select a CSV file containing historical OHLCV data. 
            Format: <code className="text-indigo-300 bg-slate-800 px-1 rounded">date,open,high,low,close,volume</code>
          </p>
          
          <div className="border-2 border-dashed border-slate-700 rounded-lg p-8 flex flex-col items-center justify-center gap-3 bg-slate-800/30">
            <Input
              type="file"
              accept=".csv"
              onChange={(e) => setFile(e.target.files?.[0] ?? null)}
              className="bg-slate-800 border-slate-700 text-white file:bg-indigo-600 file:text-white file:border-0 file:rounded file:px-2 file:py-1 file:mr-3 cursor-pointer"
            />
            {file && <p className="text-xs text-emerald-400 font-medium">Selected: {file.name}</p>}
          </div>

          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={onClose} className="border-slate-700 text-slate-300 hover:bg-slate-800 font-medium">Cancel</Button>
            <Button 
              onClick={handleUpload} 
              isLoading={uploadData.isPending}
              disabled={!file}
              className="bg-indigo-600 hover:bg-indigo-700 text-white font-medium"
            >
              Start Upload
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

export default function MarketAdminPage() {
  const { data: stocks, isLoading } = useStocks({ active_only: false });
  const deleteStock = useDeleteStock();
  
  const [search, setSearch] = useState('');
  const [editingStock, setEditingStock] = useState<StockListItem | null>(null);
  const [uploadingSymbol, setUploadingSymbol] = useState<string | null>(null);
  const [isAdding, setIsAdding] = useState(false);

  const filteredStocks = (stocks ?? []).filter(s => 
    s.symbol.toLowerCase().includes(search.toLowerCase()) || 
    s.company_name.toLowerCase().includes(search.toLowerCase())
  );

  const handleDelete = (symbol: string) => {
    if (confirm(`Are you sure you want to delete ${symbol}? This will remove all historical data and drawings.`)) {
      deleteStock.mutate(symbol);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            <TrendingUp className="h-6 w-6 text-indigo-400" />
            Market Data Admin
          </h1>
          <p className="text-slate-400">Manage NEPSE stocks and historical price data</p>
        </div>
        <Button onClick={() => setIsAdding(true)} className="bg-indigo-600 hover:bg-indigo-700 text-white shadow-lg shadow-indigo-500/20">
          <Plus className="h-4 w-4 mr-2" />
          Add New Stock
        </Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <Card className="lg:col-span-1 bg-slate-900 border-slate-700 h-fit">
          <CardHeader>
            <CardTitle className="text-md text-slate-200">Stats Overview</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between p-3 bg-slate-800 rounded-lg">
              <div className="flex items-center gap-2 text-slate-400 text-sm">
                <Building2 className="h-4 w-4" />
                Total Stocks
              </div>
              <span className="text-lg font-bold text-white">{stocks?.length ?? 0}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-slate-800 rounded-lg">
              <div className="flex items-center gap-2 text-slate-400 text-sm">
                <Check className="h-4 w-4 text-emerald-400" />
                Active
              </div>
              <span className="text-lg font-bold text-emerald-400">
                {stocks?.filter(s => s.is_active).length ?? 0}
              </span>
            </div>
            <div className="flex items-center gap-3 pt-2 text-xs text-slate-500 italic">
              <Layers className="h-3 w-3" />
              Historical data is stored as daily OHLCV bars.
            </div>
          </CardContent>
        </Card>

        <div className="lg:col-span-3 space-y-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
            <Input
              placeholder="Search by symbol or company name..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-10 bg-slate-900 border-slate-700 text-white focus:ring-indigo-500 w-full"
            />
          </div>

          <Card className="bg-slate-900 border-slate-700">
            <CardContent className="p-0 overflow-x-auto">
              <table className="w-full text-left">
                <thead className="bg-slate-950/50 border-b border-slate-800">
                  <tr>
                    <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Symbol</th>
                    <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Sector</th>
                    <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Status</th>
                    <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Latest Price</th>
                    <th className="px-4 py-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800">
                  {isLoading ? (
                    <tr>
                      <td colSpan={5} className="p-8">
                        <Skeleton className="h-10 w-full bg-slate-800" />
                      </td>
                    </tr>
                  ) : filteredStocks.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="p-8 text-center text-slate-500">
                        No stocks found matching your criteria.
                      </td>
                    </tr>
                  ) : (
                    filteredStocks.map((stock) => (
                      <StockRow
                        key={stock.symbol}
                        stock={stock}
                        onEdit={(s) => setEditingStock(s)}
                        onDelete={handleDelete}
                        onUpload={setUploadingSymbol}
                      />
                    ))
                  )}
                </tbody>
              </table>
            </CardContent>
          </Card>
        </div>
      </div>

      {isAdding && (
        <StockModal onClose={() => setIsAdding(false)} />
      )}
      {editingStock && (
        <StockModal 
          stock={editingStock} 
          isEdit 
          onClose={() => setEditingStock(null)} 
        />
      )}
      {uploadingSymbol && (
        <UploadModal 
          symbol={uploadingSymbol} 
          onClose={() => setUploadingSymbol(null)} 
        />
      )}
    </div>
  );
}
