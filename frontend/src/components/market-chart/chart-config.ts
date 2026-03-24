import type { Time } from 'lightweight-charts';

export type ChartStyle = 'candlestick' | 'line';
export type ChartRange = '1D' | '2D' | '1W' | '1M' | '3M' | '6M' | '1Y' | 'ALL';
export type IndicatorId =
  | 'sma20'
  | 'sma50'
  | 'ema12'
  | 'ema26'
  | 'bollinger'
  | 'rsi14'
  | 'macd'
  | 'stochastic'
  | 'adx'
  | 'obv';
export type IndicatorGroup = 'overlay' | 'pane';
export type LayoutTone = 'success' | 'error' | 'info';
export type IndicatorPreset = 'trend' | 'momentum' | 'reset';

export interface IndicatorCatalogEntry {
  id: IndicatorId;
  label: string;
  description: string;
  group: IndicatorGroup;
}

export interface ActiveIndicator {
  id: IndicatorId;
  visible: boolean;
}

export interface ChartLayoutSettings {
  chartStyle: ChartStyle;
  range: ChartRange;
  showVolume: boolean;
  indicators: ActiveIndicator[];
}

export interface SavedChartLayout {
  id: string;
  name: string;
  updatedAt: string;
  settings: ChartLayoutSettings;
}

export interface LayoutNotice {
  tone: LayoutTone;
  message: string;
}

export interface PriceBar {
  date: string;
  time: Time;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}

export const RANGE_OPTIONS: ChartRange[] = ['1D', '2D', '1W', '1M', '3M', '6M', '1Y', 'ALL'];

export const INDICATOR_CATALOG: IndicatorCatalogEntry[] = [
  { id: 'sma20', label: 'SMA 20', description: '20-day simple moving average overlay.', group: 'overlay' },
  { id: 'sma50', label: 'SMA 50', description: '50-day simple moving average overlay.', group: 'overlay' },
  { id: 'ema12', label: 'EMA 12', description: '12-day exponential moving average overlay.', group: 'overlay' },
  { id: 'ema26', label: 'EMA 26', description: '26-day exponential moving average overlay.', group: 'overlay' },
  { id: 'bollinger', label: 'Bollinger Bands', description: 'Upper and lower volatility bands.', group: 'overlay' },
  { id: 'rsi14', label: 'RSI (14)', description: 'Momentum oscillator with 30/70 guides.', group: 'pane' },
  { id: 'macd', label: 'MACD', description: 'MACD line, signal line, and histogram.', group: 'pane' },
  { id: 'stochastic', label: 'Stochastic', description: 'K and D momentum panel with 20/80 guides.', group: 'pane' },
  { id: 'adx', label: 'ADX / DMI', description: 'ADX with +DI and -DI strength lines.', group: 'pane' },
  { id: 'obv', label: 'OBV', description: 'On-balance volume accumulation panel.', group: 'pane' },
];

export const DEFAULT_LAYOUT_SETTINGS: ChartLayoutSettings = {
  chartStyle: 'candlestick',
  range: '1Y',
  showVolume: true,
  indicators: [
    { id: 'sma20', visible: true },
    { id: 'sma50', visible: true },
    { id: 'rsi14', visible: true },
  ],
};

export const LAYOUT_STORAGE_KEY = 'market-chart-layouts-v1';

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

export function isIndicatorId(value: string): value is IndicatorId {
  return INDICATOR_CATALOG.some((indicator) => indicator.id === value);
}

export function cloneSettings(settings: ChartLayoutSettings): ChartLayoutSettings {
  return {
    ...settings,
    indicators: settings.indicators.map((indicator) => ({ ...indicator })),
  };
}

export function normalizeActiveIndicators(input: unknown): ActiveIndicator[] {
  if (!Array.isArray(input)) {
    return DEFAULT_LAYOUT_SETTINGS.indicators.map((indicator) => ({ ...indicator }));
  }

  const seen = new Set<IndicatorId>();
  const normalized: ActiveIndicator[] = [];

  for (const item of input) {
    if (!isRecord(item) || typeof item.id !== 'string' || !isIndicatorId(item.id) || seen.has(item.id)) {
      continue;
    }

    seen.add(item.id);
    normalized.push({
      id: item.id,
      visible: typeof item.visible === 'boolean' ? item.visible : true,
    });
  }

  return normalized.length > 0
    ? normalized
    : DEFAULT_LAYOUT_SETTINGS.indicators.map((indicator) => ({ ...indicator }));
}

export function normalizeLayoutSettings(input: unknown): ChartLayoutSettings {
  if (!isRecord(input)) {
    return cloneSettings(DEFAULT_LAYOUT_SETTINGS);
  }

  const chartStyle = input.chartStyle === 'line' ? 'line' : DEFAULT_LAYOUT_SETTINGS.chartStyle;
  const range = RANGE_OPTIONS.includes(input.range as ChartRange) ? (input.range as ChartRange) : DEFAULT_LAYOUT_SETTINGS.range;

  return {
    chartStyle,
    range,
    showVolume: typeof input.showVolume === 'boolean' ? input.showVolume : DEFAULT_LAYOUT_SETTINGS.showVolume,
    indicators: normalizeActiveIndicators(input.indicators),
  };
}

export function normalizeStoredLayout(input: unknown): SavedChartLayout | null {
  if (!isRecord(input) || typeof input.name !== 'string' || typeof input.updatedAt !== 'string') {
    return null;
  }

  return {
    id: typeof input.id === 'string' ? input.id : `layout-${Date.now()}-${Math.round(Math.random() * 1_000_000)}`,
    name: input.name,
    updatedAt: input.updatedAt,
    settings: normalizeLayoutSettings(input.settings),
  };
}

export function getIndicatorMeta(indicatorId: IndicatorId): IndicatorCatalogEntry {
  const indicator = INDICATOR_CATALOG.find((entry) => entry.id === indicatorId);
  if (!indicator) {
    throw new Error(`Unknown indicator id: ${indicatorId}`);
  }
  return indicator;
}

export function upsertIndicator(indicators: ActiveIndicator[], nextIndicator: ActiveIndicator): ActiveIndicator[] {
  const existingIndex = indicators.findIndex((indicator) => indicator.id === nextIndicator.id);

  if (existingIndex === -1) {
    return [...indicators, nextIndicator];
  }

  return indicators.map((indicator, index) => (index === existingIndex ? nextIndicator : indicator));
}

export function createLayoutNotice(tone: LayoutTone, message: string): LayoutNotice {
  return { tone, message };
}
