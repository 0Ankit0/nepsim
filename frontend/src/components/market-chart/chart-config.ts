export type ChartStyle = 'candlestick' | 'hollow' | 'ohlc' | 'area';
export type ChartTheme = 'dark' | 'light';
export type ChartRange = '1D' | '2D' | '1W' | '1M' | '3M' | '6M' | '1Y' | 'ALL';
export type IndicatorId =
  | 'AVP'
  | 'AO'
  | 'BIAS'
  | 'BOLL'
  | 'BRAR'
  | 'BBI'
  | 'CCI'
  | 'CR'
  | 'DMA'
  | 'DMI'
  | 'EMV'
  | 'EMA'
  | 'MTM'
  | 'MA'
  | 'MACD'
  | 'OBV'
  | 'PVT'
  | 'PSY'
  | 'ROC'
  | 'RSI'
  | 'SMA'
  | 'KDJ'
  | 'SAR'
  | 'TRIX'
  | 'VOL'
  | 'VR'
  | 'WR';
export type OverlayId =
  | 'fibonacciLine'
  | 'horizontalRayLine'
  | 'horizontalSegment'
  | 'horizontalStraightLine'
  | 'parallelStraightLine'
  | 'priceChannelLine'
  | 'priceLine'
  | 'rayLine'
  | 'segment'
  | 'straightLine'
  | 'verticalRayLine'
  | 'verticalSegment'
  | 'verticalStraightLine'
  | 'simpleAnnotation'
  | 'simpleTag';
export type IndicatorGroup = 'overlay' | 'pane';
export type LayoutTone = 'success' | 'error' | 'info';
export type IndicatorPreset = 'trend' | 'momentum' | 'reset';

export interface IndicatorCatalogEntry {
  id: IndicatorId;
  label: string;
  description: string;
  group: IndicatorGroup;
  settings: string[];
}

export interface OverlayCatalogEntry {
  id: OverlayId;
  label: string;
  description: string;
}

export interface ActiveIndicator {
  id: IndicatorId;
  visible: boolean;
}

export interface ChartLayoutSettings {
  chartStyle: ChartStyle;
  theme: ChartTheme;
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
  timestamp: number;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
  turnover?: number;
}

export const RANGE_OPTIONS: ChartRange[] = ['1D', '2D', '1W', '1M', '3M', '6M', '1Y', 'ALL'];

export const INDICATOR_CATALOG: IndicatorCatalogEntry[] = [
  { id: 'MA', label: 'MA', description: 'Price overlay with the KLineChart moving-average defaults.', group: 'overlay', settings: ['Periods: 5, 10, 30, 60'] },
  { id: 'EMA', label: 'EMA', description: 'Exponential moving averages over the candle pane.', group: 'overlay', settings: ['Periods: 6, 12, 20'] },
  { id: 'SMA', label: 'SMA', description: 'Chinese-style smoothed moving average overlay.', group: 'overlay', settings: ['Period: 12', 'Weight: 2'] },
  { id: 'BBI', label: 'BBI', description: 'Bull and Bear Index overlay for long-term balance.', group: 'overlay', settings: ['Periods: 3, 6, 12, 24'] },
  { id: 'BOLL', label: 'BOLL', description: 'Bollinger Bands around price.', group: 'overlay', settings: ['Length: 20', 'StdDev: 2'] },
  { id: 'SAR', label: 'SAR', description: 'Stop and reverse dots directly on price.', group: 'overlay', settings: ['Start AF: 2', 'Step: 2', 'Max AF: 20'] },
  { id: 'VOL', label: 'VOL', description: 'Volume bars plus moving averages in a dedicated pane.', group: 'pane', settings: ['Periods: 5, 10, 20'] },
  { id: 'MACD', label: 'MACD', description: 'MACD line, signal line, and histogram.', group: 'pane', settings: ['Fast: 12', 'Slow: 26', 'Signal: 9'] },
  { id: 'KDJ', label: 'KDJ', description: 'K, D, and J momentum oscillator.', group: 'pane', settings: ['Periods: 9, 3, 3'] },
  { id: 'RSI', label: 'RSI', description: 'Relative strength index trio.', group: 'pane', settings: ['Periods: 6, 12, 24'] },
  { id: 'BIAS', label: 'BIAS', description: 'Price deviation from recent averages.', group: 'pane', settings: ['Periods: 6, 12, 24'] },
  { id: 'BRAR', label: 'BRAR', description: 'BR and AR sentiment lines.', group: 'pane', settings: ['Period: 26'] },
  { id: 'CCI', label: 'CCI', description: 'Commodity channel index momentum panel.', group: 'pane', settings: ['Period: 20'] },
  { id: 'DMI', label: 'DMI', description: 'Directional movement with ADX and ADXR.', group: 'pane', settings: ['Periods: 14, 6'] },
  { id: 'CR', label: 'CR', description: 'Current Ratio energy bands.', group: 'pane', settings: ['Periods: 26, 10, 20, 40, 60'] },
  { id: 'PSY', label: 'PSY', description: 'Psychological line and its moving average.', group: 'pane', settings: ['Periods: 12, 6'] },
  { id: 'DMA', label: 'DMA', description: 'Difference of moving averages with signal average.', group: 'pane', settings: ['Periods: 10, 50, 10'] },
  { id: 'TRIX', label: 'TRIX', description: 'Triple-smoothed rate of change plus signal.', group: 'pane', settings: ['Periods: 12, 9'] },
  { id: 'OBV', label: 'OBV', description: 'On-balance volume and 30-period average.', group: 'pane', settings: ['Period: 30'] },
  { id: 'VR', label: 'VR', description: 'Volume ratio and MAVR.', group: 'pane', settings: ['Periods: 26, 6'] },
  { id: 'WR', label: 'WR', description: 'Williams %R trio.', group: 'pane', settings: ['Periods: 6, 10, 14'] },
  { id: 'MTM', label: 'MTM', description: 'Momentum and its signal average.', group: 'pane', settings: ['Periods: 12, 6'] },
  { id: 'EMV', label: 'EMV', description: 'Ease of movement and MAEMV.', group: 'pane', settings: ['Periods: 14, 9'] },
  { id: 'ROC', label: 'ROC', description: 'Rate of change plus MAROC.', group: 'pane', settings: ['Periods: 12, 6'] },
  { id: 'PVT', label: 'PVT', description: 'Price-volume trend accumulation.', group: 'pane', settings: ['Uses: Close, Volume'] },
  { id: 'AO', label: 'AO', description: 'Awesome Oscillator histogram.', group: 'pane', settings: ['Periods: 5, 34'] },
  { id: 'AVP', label: 'AVP', description: 'Average price from cumulative turnover and volume.', group: 'pane', settings: ['Uses: Turnover, Volume'] },
];

export const OVERLAY_CATALOG: OverlayCatalogEntry[] = [
  { id: 'segment', label: 'Segment', description: 'Two-point trend segment.' },
  { id: 'straightLine', label: 'Straight line', description: 'Infinite trend line through two points.' },
  { id: 'rayLine', label: 'Ray line', description: 'One-sided ray through two points.' },
  { id: 'parallelStraightLine', label: 'Parallel channel', description: 'Parallel straight-line channel tool.' },
  { id: 'priceChannelLine', label: 'Price channel', description: 'Price channel with three anchor points.' },
  { id: 'fibonacciLine', label: 'Fibonacci line', description: 'Fibonacci retracement drawing.' },
  { id: 'priceLine', label: 'Price line', description: 'Horizontal price marker.' },
  { id: 'horizontalStraightLine', label: 'Horizontal line', description: 'Infinite horizontal guide.' },
  { id: 'horizontalRayLine', label: 'Horizontal ray', description: 'One-sided horizontal guide.' },
  { id: 'horizontalSegment', label: 'Horizontal segment', description: 'Horizontal segment between two points.' },
  { id: 'verticalStraightLine', label: 'Vertical line', description: 'Infinite vertical marker.' },
  { id: 'verticalRayLine', label: 'Vertical ray', description: 'One-sided vertical guide.' },
  { id: 'verticalSegment', label: 'Vertical segment', description: 'Vertical segment between two points.' },
  { id: 'simpleAnnotation', label: 'Annotation', description: 'Free annotation marker.' },
  { id: 'simpleTag', label: 'Tag', description: 'Pinned text tag marker.' },
];

export const DEFAULT_LAYOUT_SETTINGS: ChartLayoutSettings = {
  chartStyle: 'candlestick',
  theme: 'dark',
  range: '1Y',
  showVolume: true,
  indicators: [
    { id: 'MA', visible: true },
    { id: 'BOLL', visible: true },
    { id: 'MACD', visible: true },
    { id: 'RSI', visible: true },
  ],
};

export const LAYOUT_STORAGE_KEY = 'market-chart-layouts-v2';

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

export function isIndicatorId(value: string): value is IndicatorId {
  return INDICATOR_CATALOG.some((indicator) => indicator.id === value);
}

export function isOverlayId(value: string): value is OverlayId {
  return OVERLAY_CATALOG.some((overlay) => overlay.id === value);
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

  const chartStyle =
    input.chartStyle === 'hollow' || input.chartStyle === 'ohlc' || input.chartStyle === 'area'
      ? input.chartStyle
      : DEFAULT_LAYOUT_SETTINGS.chartStyle;
  const theme = input.theme === 'light' ? 'light' : DEFAULT_LAYOUT_SETTINGS.theme;
  const range = RANGE_OPTIONS.includes(input.range as ChartRange) ? (input.range as ChartRange) : DEFAULT_LAYOUT_SETTINGS.range;

  return {
    chartStyle,
    theme,
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

export function getOverlayMeta(overlayId: OverlayId): OverlayCatalogEntry {
  const overlay = OVERLAY_CATALOG.find((entry) => entry.id === overlayId);
  if (!overlay) {
    throw new Error(`Unknown overlay id: ${overlayId}`);
  }
  return overlay;
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

function canUseLocalStorage() {
  return typeof window !== 'undefined' && typeof window.localStorage !== 'undefined';
}

export function readStoredLayouts(): SavedChartLayout[] {
  if (!canUseLocalStorage()) {
    return [];
  }

  try {
    const raw = window.localStorage.getItem(LAYOUT_STORAGE_KEY);
    if (!raw) {
      return [];
    }

    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) {
      return [];
    }

    return parsed
      .map((item) => normalizeStoredLayout(item))
      .filter((item): item is SavedChartLayout => item !== null)
      .sort((left, right) => right.updatedAt.localeCompare(left.updatedAt));
  } catch {
    return [];
  }
}

export function writeStoredLayouts(layouts: SavedChartLayout[]) {
  if (!canUseLocalStorage()) {
    return;
  }

  window.localStorage.setItem(LAYOUT_STORAGE_KEY, JSON.stringify(layouts));
}
