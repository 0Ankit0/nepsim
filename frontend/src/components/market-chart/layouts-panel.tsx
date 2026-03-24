'use client';

import { Save, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import type { LayoutNotice, SavedChartLayout } from './chart-config';

interface MarketChartLayoutsPanelProps {
  layoutName: string;
  onLayoutNameChange: (value: string) => void;
  onSaveLayout: () => void;
  layoutNotice: LayoutNotice | null;
  savedLayouts: SavedChartLayout[];
  onLoadLayout: (layoutId: string) => void;
  onDeleteLayout: (layoutId: string) => void;
}

export function MarketChartLayoutsPanel({
  layoutName,
  onLayoutNameChange,
  onSaveLayout,
  layoutNotice,
  savedLayouts,
  onLoadLayout,
  onDeleteLayout,
}: MarketChartLayoutsPanelProps) {
  const layoutNoticeClasses =
    layoutNotice?.tone === 'error'
      ? 'border-rose-200 bg-rose-50 text-rose-700'
      : layoutNotice?.tone === 'success'
        ? 'border-emerald-200 bg-emerald-50 text-emerald-700'
        : 'border-blue-200 bg-blue-50 text-blue-700';

  return (
    <Card className="shadow-sm border-gray-100">
      <CardHeader className="border-b border-gray-100 bg-gray-50/50 py-3">
        <CardTitle className="text-sm font-semibold text-gray-600">Saved Layouts</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4 p-4">
        <div className="flex gap-2">
          <Input
            value={layoutName}
            placeholder="Name this layout"
            onChange={(event) => onLayoutNameChange(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === 'Enter') {
                event.preventDefault();
                onSaveLayout();
              }
            }}
          />
          <Button type="button" size="sm" onClick={onSaveLayout}>
            <Save className="mr-1 h-4 w-4" /> Save
          </Button>
        </div>

        {layoutNotice && <div className={`rounded-xl border px-3 py-2 text-xs font-medium ${layoutNoticeClasses}`}>{layoutNotice.message}</div>}

        {savedLayouts.length === 0 ? (
          <div className="rounded-xl border border-dashed border-gray-200 px-4 py-6 text-center text-sm text-gray-500">
            Save your favorite indicator setup here and reload it for any stock later.
          </div>
        ) : (
          <div className="space-y-2">
            {savedLayouts.map((layout) => (
              <div key={layout.id} className="rounded-xl border border-gray-200 px-4 py-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="text-sm font-semibold text-gray-900">{layout.name}</p>
                    <p className="mt-1 text-xs text-gray-500">
                      {layout.settings.chartStyle === 'candlestick' ? 'Candles' : 'Line'} · {layout.settings.range} ·{' '}
                      {layout.settings.showVolume ? 'Volume on' : 'Volume off'} · {layout.settings.indicators.length} indicators
                    </p>
                    <p className="mt-1 text-[11px] text-gray-400">Updated {new Date(layout.updatedAt).toLocaleString()}</p>
                  </div>

                  <div className="flex items-center gap-1">
                    <Button type="button" size="sm" variant="outline" onClick={() => onLoadLayout(layout.id)}>
                      Load
                    </Button>
                    <Button
                      type="button"
                      size="sm"
                      variant="ghost"
                      className="px-2 text-rose-600 hover:bg-rose-50 hover:text-rose-700"
                      onClick={() => onDeleteLayout(layout.id)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
