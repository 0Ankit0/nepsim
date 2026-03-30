import type { HistoricDataRow, IndicatorRow } from '@/api/market';
import type { ChartRange, PriceBar } from './chart-config';
import type { LineData, Time } from 'lightweight-charts';

export function toDateKey(date?: string | null): string | null {
  if (!date) return null;

  const trimmed = date.trim();
  const isoMatch = trimmed.match(/^(\d{4}-\d{2}-\d{2})/);
  if (isoMatch?.[1]) {
    return isoMatch[1];
  }

  const parsed = new Date(trimmed);
  if (Number.isNaN(parsed.getTime())) {
    return null;
  }

  return parsed.toISOString().slice(0, 10);
}

export function buildPriceBars(rows: HistoricDataRow[]): PriceBar[] {
  const uniqueRows = new Map<string, PriceBar>();
  const sortedRows = [...rows].sort((left, right) => (toDateKey(left.date) ?? '').localeCompare(toDateKey(right.date) ?? ''));

  for (const row of sortedRows) {
    const date = toDateKey(row.date);
    const close = row.close ?? row.ltp;

    if (!date || row.open == null || row.high == null || row.low == null || close == null) {
      continue;
    }

    uniqueRows.set(date, {
      date,
      time: date,
      open: row.open,
      high: row.high,
      low: row.low,
      close,
      volume: row.vol ?? 0,
    });
  }

  return Array.from(uniqueRows.values()).sort((left, right) => left.date.localeCompare(right.date));
}

export function buildIndicatorHistory(rows: IndicatorRow[]): IndicatorRow[] {
  const uniqueRows = new Map<string, IndicatorRow>();
  const sortedRows = [...rows].sort((left, right) => (toDateKey(left.date) ?? '').localeCompare(toDateKey(right.date) ?? ''));

  for (const row of sortedRows) {
    const date = toDateKey(row.date);
    if (!date) continue;

    uniqueRows.set(date, {
      ...row,
      date,
    });
  }

  return Array.from(uniqueRows.values()).sort((left, right) => (left.date ?? '').localeCompare(right.date ?? ''));
}

export function filterByRange<T extends { date: string }>(rows: T[], range: ChartRange): T[] {
  if (rows.length === 0 || range === 'ALL') {
    return rows;
  }

  if (range === '1D') {
    return rows.slice(-1);
  }

  if (range === '2D') {
    return rows.slice(-2);
  }

  const anchor = new Date(rows[rows.length - 1].date);
  if (Number.isNaN(anchor.getTime())) {
    return rows;
  }

  const daysBackMap: Record<Exclude<ChartRange, '1D' | '2D' | 'ALL'>, number> = {
    '1W': 7,
    '1M': 30,
    '3M': 90,
    '6M': 180,
    '1Y': 365,
  };

  const daysBack = daysBackMap[range];
  const cutoff = new Date(anchor);
  cutoff.setDate(cutoff.getDate() - daysBack);

  return rows.filter((row) => {
    const rowDate = new Date(row.date);
    return !Number.isNaN(rowDate.getTime()) && rowDate >= cutoff;
  });
}

export function makeLineData(rows: IndicatorRow[], selector: (row: IndicatorRow) => number | null | undefined): LineData<Time>[] {
  return rows.flatMap((row) => {
    const date = row.date ?? '';
    const value = selector(row);

    if (!date || value == null || !Number.isFinite(value)) {
      return [];
    }

    return [{ time: date, value }];
  });
}

export function makeConstantLineData(rows: IndicatorRow[], value: number): LineData<Time>[] {
  return rows.flatMap((row) => {
    if (!row.date) {
      return [];
    }

    return [{ time: row.date, value }];
  });
}

export function formatMoney(value?: number | null): string {
  if (value == null) return '-';
  return `Rs. ${value.toLocaleString('en-IN', { maximumFractionDigits: 2 })}`;
}

export function formatNumber(value?: number | null, digits: number = 2): string {
  if (value == null) return '-';
  return value.toLocaleString('en-IN', { maximumFractionDigits: digits });
}

export function formatCompactVolume(value?: number | null): string {
  if (value == null) return '-';
  if (Math.abs(value) >= 1_000_000) return `${(value / 1_000_000).toFixed(2)}M`;
  if (Math.abs(value) >= 1_000) return `${(value / 1_000).toFixed(1)}K`;
  return value.toLocaleString('en-IN', { maximumFractionDigits: 0 });
}
