import { describe, it, expect } from 'vitest';
import {
  isISODate, addMonthsClamped, addDays, monthKeyOf, daysInMonth, compareISO, endOfMonth,
  startOfMonth, fromParts, parts, todayISO, lastMonthKeys, monthKeyToDate, diffDays, clampDay, weekdayOf,
} from './dates';

describe('ISO calendar dates', () => {
  it('validates format and real calendar dates', () => {
    expect(isISODate('2026-02-28')).toBe(true);
    expect(isISODate('2026-02-30')).toBe(false);
    expect(isISODate('2024-02-29')).toBe(true);
    expect(isISODate('2026-13-01')).toBe(false);
    expect(isISODate('26-01-01')).toBe(false);
    expect(isISODate('')).toBe(false);
  });
  it('adds months clamping the day to the month length', () => {
    expect(addMonthsClamped('2026-01-31', 1)).toBe('2026-02-28');
    expect(addMonthsClamped('2024-01-31', 1)).toBe('2024-02-29');
    expect(addMonthsClamped('2026-01-31', 2)).toBe('2026-03-31');
    expect(addMonthsClamped('2026-11-15', 2)).toBe('2027-01-15');
    expect(addMonthsClamped('2026-03-31', -1)).toBe('2026-02-28');
  });
  it('keeps the original anchor day across a series (31 -> 28 -> 31)', () => {
    expect(addMonthsClamped('2026-01-31', 1, 31)).toBe('2026-02-28');
    expect(addMonthsClamped('2026-01-31', 2, 31)).toBe('2026-03-31');
  });
  it('adds days across month/year boundaries without timezone drift', () => {
    expect(addDays('2026-12-31', 1)).toBe('2027-01-01');
    expect(addDays('2026-03-01', -1)).toBe('2026-02-28');
    expect(addDays('2026-11-01', 0)).toBe('2026-11-01');
  });
  it('derives month keys, month bounds and lengths', () => {
    expect(monthKeyOf('2026-11-04')).toBe('2026-11');
    expect(daysInMonth(2026, 2)).toBe(28);
    expect(daysInMonth(2024, 2)).toBe(29);
    expect(startOfMonth('2026-11')).toBe('2026-11-01');
    expect(endOfMonth('2026-11')).toBe('2026-11-30');
    expect(monthKeyToDate('2026-02', 31)).toBe('2026-02-28');
    expect(clampDay(2026, 2, 31)).toBe(28);
  });
  it('compares and diffs', () => {
    expect(compareISO('2026-01-01', '2026-01-02')).toBeLessThan(0);
    expect(compareISO('2026-01-02', '2026-01-02')).toBe(0);
    expect(diffDays('2026-01-01', '2026-01-31')).toBe(30);
    expect(diffDays('2026-03-01', '2026-02-01')).toBe(-28);
  });
  it('builds from parts and back', () => {
    expect(fromParts(2026, 1, 5)).toBe('2026-01-05');
    expect(parts('2026-01-05')).toEqual({ year: 2026, month: 1, day: 5 });
    expect(weekdayOf('2026-11-04')).toBe(3); // Wednesday
  });
  it('lists the last N month keys ending at a given month', () => {
    expect(lastMonthKeys('2026-02', 3)).toEqual(['2025-12', '2026-01', '2026-02']);
  });
  it('todayISO uses the provided clock and local calendar', () => {
    const clock = () => new Date(2026, 10, 4, 23, 59); // local time
    expect(todayISO(clock)).toBe('2026-11-04');
  });
});
