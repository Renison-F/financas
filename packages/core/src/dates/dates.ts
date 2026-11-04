/**
 * Calendar dates are modelled as ISO strings "YYYY-MM-DD" and month keys as "YYYY-MM".
 * They are *calendar* values (no time, no timezone): a bill due on 2026-11-10 is due on
 * that day wherever the user is. All math here is done on (year, month, day) integers,
 * never through Date objects with time components, which removes DST/timezone drift.
 */
export type ISODate = string;
export type MonthKey = string;

export interface DateParts { year: number; month: number; day: number; }

export function daysInMonth(year: number, month: number): number {
  return new Date(Date.UTC(year, month, 0)).getUTCDate();
}

export function isISODate(s: unknown): s is ISODate {
  if (typeof s !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(s)) return false;
  const { year, month, day } = parts(s);
  return month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month);
}

export function isMonthKey(s: unknown): s is MonthKey {
  if (typeof s !== 'string' || !/^\d{4}-\d{2}$/.test(s)) return false;
  const m = Number(s.slice(5, 7));
  return m >= 1 && m <= 12;
}

export function parts(date: ISODate): DateParts {
  return { year: Number(date.slice(0, 4)), month: Number(date.slice(5, 7)), day: Number(date.slice(8, 10)) };
}

const pad = (n: number) => String(n).padStart(2, '0');

export function fromParts(year: number, month: number, day: number): ISODate {
  return `${year}-${pad(month)}-${pad(day)}`;
}

export function clampDay(year: number, month: number, day: number): number {
  return Math.min(Math.max(1, day), daysInMonth(year, month));
}

export function monthKeyOf(date: ISODate): MonthKey { return date.slice(0, 7); }
export function monthKey(year: number, month: number): MonthKey { return `${year}-${pad(month)}`; }
export function startOfMonth(key: MonthKey): ISODate { return `${key}-01`; }
export function endOfMonth(key: MonthKey): ISODate {
  const y = Number(key.slice(0, 4)), m = Number(key.slice(5, 7));
  return fromParts(y, m, daysInMonth(y, m));
}
export function monthKeyToDate(key: MonthKey, day: number): ISODate {
  const y = Number(key.slice(0, 4)), m = Number(key.slice(5, 7));
  return fromParts(y, m, clampDay(y, m, day));
}

/** Adds months, clamping to month length. `anchorDay` keeps the original day across a series. */
export function addMonthsClamped(date: ISODate, months: number, anchorDay?: number): ISODate {
  const p = parts(date);
  const total = p.year * 12 + (p.month - 1) + months;
  const y = Math.floor(total / 12), m = (total % 12) + 1;
  return fromParts(y, m, clampDay(y, m, anchorDay ?? p.day));
}

export function addMonthsToKey(key: MonthKey, months: number): MonthKey {
  return monthKeyOf(addMonthsClamped(startOfMonth(key), months));
}

function toEpochDay(date: ISODate): number {
  const p = parts(date);
  return Math.round(Date.UTC(p.year, p.month - 1, p.day) / 86400000);
}
function fromEpochDay(n: number): ISODate {
  const d = new Date(n * 86400000);
  return fromParts(d.getUTCFullYear(), d.getUTCMonth() + 1, d.getUTCDate());
}

export function addDays(date: ISODate, days: number): ISODate { return fromEpochDay(toEpochDay(date) + days); }
export function diffDays(from: ISODate, to: ISODate): number { return toEpochDay(to) - toEpochDay(from); }
export function compareISO(a: ISODate, b: ISODate): number { return a < b ? -1 : a > b ? 1 : 0; }
/** 0 = Sunday ... 6 = Saturday */
export function weekdayOf(date: ISODate): number { const p = parts(date); return new Date(Date.UTC(p.year, p.month - 1, p.day)).getUTCDay(); }

export type Clock = () => Date;
export const systemClock: Clock = () => new Date();

/** Today's local calendar date (the device's wall-clock calendar). */
export function todayISO(clock: Clock = systemClock): ISODate {
  const d = clock();
  return fromParts(d.getFullYear(), d.getMonth() + 1, d.getDate());
}
export function currentMonthKey(clock: Clock = systemClock): MonthKey { return monthKeyOf(todayISO(clock)); }

export function lastMonthKeys(endKey: MonthKey, n: number): MonthKey[] {
  const out: MonthKey[] = [];
  for (let i = n - 1; i >= 0; i--) out.push(addMonthsToKey(endKey, -i));
  return out;
}

export function monthKeysBetween(startKey: MonthKey, endKey: MonthKey): MonthKey[] {
  const out: MonthKey[] = [];
  let k = startKey;
  while (k <= endKey) { out.push(k); k = addMonthsToKey(k, 1); }
  return out;
}
