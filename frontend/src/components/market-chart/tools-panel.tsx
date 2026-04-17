'use client';

import { Eye, EyeOff, Plus, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import type {
  ChartLayoutSettings,
  IndicatorCatalogEntry,
  IndicatorId,
  IndicatorPreset,
  OverlayCatalogEntry,
  OverlayId,
} from './chart-config';
import { getIndicatorMeta, getOverlayMeta } from './chart-config';

interface MarketChartToolsPanelProps {
  chartSettings: ChartLayoutSettings;
  availableIndicators: IndicatorCatalogEntry[];
  pendingIndicatorId: IndicatorId | '';
  onPendingIndicatorChange: (value: IndicatorId | '') => void;
  onAddIndicator: () => void;
  onApplyPreset: (preset: IndicatorPreset) => void;
  onToggleIndicatorVisibility: (indicatorId: IndicatorId) => void;
  onRemoveIndicator: (indicatorId: IndicatorId) => void;
  onToggleVolume: () => void;
  availableOverlays: OverlayCatalogEntry[];
  pendingOverlayId: OverlayId | '';
  onPendingOverlayChange: (value: OverlayId | '') => void;
  onAddOverlay: () => void;
  onClearOverlays: () => void;
}

export function MarketChartToolsPanel({
  chartSettings,
  availableIndicators,
  pendingIndicatorId,
  onPendingIndicatorChange,
  onAddIndicator,
  onApplyPreset,
  onToggleIndicatorVisibility,
  onRemoveIndicator,
  onToggleVolume,
  availableOverlays,
  pendingOverlayId,
  onPendingOverlayChange,
  onAddOverlay,
  onClearOverlays,
}: MarketChartToolsPanelProps) {
  return (
    <Card className="shadow-sm border-gray-100">
      <CardHeader className="border-b border-gray-100 bg-gray-50/50 py-3">
        <CardTitle className="text-sm font-semibold text-gray-600">Chart Tools</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4 p-4">
        <div className="rounded-xl border border-gray-200 bg-gray-50 px-4 py-3">
          <div className="flex items-center justify-between gap-3">
            <div>
              <p className="text-sm font-semibold text-gray-800">Volume panel</p>
              <p className="text-xs text-gray-500">Toggle the built-in VOL pane without changing your saved indicator stack.</p>
            </div>
            <Button type="button" size="sm" variant={chartSettings.showVolume ? 'primary' : 'outline'} onClick={onToggleVolume}>
              {chartSettings.showVolume ? 'Hide' : 'Show'}
            </Button>
          </div>
        </div>

        <div className="space-y-2">
          <label htmlFor="indicator-picker" className="text-xs font-semibold uppercase tracking-wider text-gray-500">
            Add indicator
          </label>
          <div className="flex gap-2">
            <select
              id="indicator-picker"
              value={pendingIndicatorId}
              onChange={(event) => onPendingIndicatorChange(event.target.value as IndicatorId | '')}
              className="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-700 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {availableIndicators.length === 0 ? (
                <option value="">All indicators already added</option>
              ) : (
                availableIndicators.map((indicator) => (
                  <option key={indicator.id} value={indicator.id}>
                    {indicator.label}
                  </option>
                ))
              )}
            </select>
            <Button type="button" size="sm" onClick={onAddIndicator} disabled={!pendingIndicatorId}>
              <Plus className="mr-1 h-4 w-4" /> Add
            </Button>
          </div>
        </div>

        <div className="space-y-2">
          <label htmlFor="overlay-picker" className="text-xs font-semibold uppercase tracking-wider text-gray-500">
            Add drawing tool
          </label>
          <div className="flex gap-2">
            <select
              id="overlay-picker"
              value={pendingOverlayId}
              onChange={(event) => onPendingOverlayChange(event.target.value as OverlayId | '')}
              className="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-700 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {availableOverlays.map((overlay) => (
                <option key={overlay.id} value={overlay.id}>
                  {overlay.label}
                </option>
              ))}
            </select>
            <Button type="button" size="sm" variant="outline" onClick={onAddOverlay} disabled={!pendingOverlayId}>
              Draw
            </Button>
          </div>
          {pendingOverlayId && <p className="text-[11px] text-gray-400">{getOverlayMeta(pendingOverlayId).description}</p>}
          <Button type="button" size="sm" variant="ghost" className="px-0 text-gray-500 hover:text-gray-700" onClick={onClearOverlays}>
            Clear drawings
          </Button>
        </div>

        <div className="flex flex-wrap gap-2">
          <Button type="button" size="sm" variant="outline" onClick={() => onApplyPreset('trend')}>
            Trend preset
          </Button>
          <Button type="button" size="sm" variant="outline" onClick={() => onApplyPreset('momentum')}>
            Momentum preset
          </Button>
          <Button type="button" size="sm" variant="ghost" onClick={() => onApplyPreset('reset')}>
            Reset chart
          </Button>
        </div>

        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <p className="text-xs font-semibold uppercase tracking-wider text-gray-500">Active indicators</p>
            <p className="text-xs text-gray-400">{chartSettings.indicators.filter((indicator) => indicator.visible).length} visible</p>
          </div>

          {chartSettings.indicators.length === 0 ? (
            <div className="rounded-xl border border-dashed border-gray-200 px-4 py-6 text-center text-sm text-gray-500">
              No indicators added yet. Pick one from the list above to extend the chart.
            </div>
          ) : (
            <div className="space-y-2">
              {chartSettings.indicators.map((indicator) => {
                const meta = getIndicatorMeta(indicator.id);
                return (
                  <div key={indicator.id} className="rounded-xl border border-gray-200 px-4 py-3">
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="flex items-center gap-2">
                          <p className="text-sm font-semibold text-gray-900">{meta.label}</p>
                          <span className="rounded-full bg-gray-100 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-gray-500">
                            {meta.group === 'overlay' ? 'Overlay' : 'Panel'}
                          </span>
                          {!indicator.visible && (
                            <span className="rounded-full bg-amber-50 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-amber-600 border border-amber-100">
                              Hidden
                            </span>
                          )}
                        </div>
                        <p className="mt-1 text-xs text-gray-500">{meta.description}</p>
                        <p className="mt-2 text-[11px] text-gray-400">{meta.settings.join(' · ')}</p>
                      </div>

                      <div className="flex items-center gap-1">
                        <Button
                          type="button"
                          size="sm"
                          variant="ghost"
                          className="px-2"
                          onClick={() => onToggleIndicatorVisibility(indicator.id)}
                        >
                          {indicator.visible ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </Button>
                        <Button
                          type="button"
                          size="sm"
                          variant="ghost"
                          className="px-2 text-rose-600 hover:bg-rose-50 hover:text-rose-700"
                          onClick={() => onRemoveIndicator(indicator.id)}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
