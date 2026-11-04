import { describe, it, expect } from 'vitest';
import { occurrencesBetween, nextOccurrence } from './recurrence';

describe('recurrence', () => {
  it('expands monthly series with day clamping and anchor', () => {
    const r = { id: 'r', frequency: 'monthly' as const, startDate: '2026-01-31' };
    expect(occurrencesBetween(r, '2026-01-01', '2026-05-31')).toEqual(['2026-01-31', '2026-02-28', '2026-03-31', '2026-04-30', '2026-05-31']);
  });
  it('honors count and endDate', () => {
    expect(occurrencesBetween({ id: 'r', frequency: 'monthly', startDate: '2026-01-10', count: 3 }, '2026-01-01', '2027-01-01')).toHaveLength(3);
    expect(occurrencesBetween({ id: 'r', frequency: 'weekly', startDate: '2026-01-01', endDate: '2026-01-20' }, '2026-01-01', '2026-03-01')).toEqual(['2026-01-01', '2026-01-08', '2026-01-15']);
  });
  it('supports yearly, biweekly and quarterly', () => {
    expect(occurrencesBetween({ id: 'r', frequency: 'yearly', startDate: '2024-02-29' }, '2024-01-01', '2026-12-31')).toEqual(['2024-02-29', '2025-02-28', '2026-02-28']);
    expect(occurrencesBetween({ id: 'r', frequency: 'biweekly', startDate: '2026-01-01' }, '2026-01-20', '2026-02-20')).toEqual(['2026-01-29', '2026-02-12']);
    expect(occurrencesBetween({ id: 'r', frequency: 'quarterly', startDate: '2026-01-15' }, '2026-01-01', '2026-12-31')).toHaveLength(4);
  });
  it('finds the next occurrence after a date', () => {
    expect(nextOccurrence({ id: 'r', frequency: 'monthly', startDate: '2026-01-05' }, '2026-11-04')).toBe('2026-11-05');
    expect(nextOccurrence({ id: 'r', frequency: 'monthly', startDate: '2026-01-05', count: 2 }, '2026-11-04')).toBeNull();
  });
});
