import { addDays, addMonthsClamped, compareISO, parts, type ISODate } from '../dates/dates';
import type { RecurrenceFrequency, RecurrenceRule } from './types';

const MONTH_STEP: Partial<Record<RecurrenceFrequency, number>> = { monthly: 1, bimonthly: 2, quarterly: 3, semiannual: 6, yearly: 12 };
const DAY_STEP: Partial<Record<RecurrenceFrequency, number>> = { daily: 1, weekly: 7, biweekly: 14 };

export function nthOccurrence(rule: RecurrenceRule, n: number): ISODate {
  const months = MONTH_STEP[rule.frequency];
  if (months !== undefined) return addMonthsClamped(rule.startDate, months * n, rule.anchorDay ?? parts(rule.startDate).day);
  const days = DAY_STEP[rule.frequency];
  if (days !== undefined) return addDays(rule.startDate, days * n);
  throw new RangeError(`Frequência desconhecida: ${rule.frequency}`);
}

/**
 * Expands a rule into concrete dates inside [from, to] (inclusive), honoring count/endDate.
 * Never generates more than `maxOccurrences` items (safety against runaway loops).
 */
export function occurrencesBetween(rule: RecurrenceRule, from: ISODate, to: ISODate, maxOccurrences = 1000): ISODate[] {
  const out: ISODate[] = [];
  for (let n = 0; n < maxOccurrences; n++) {
    if (rule.count !== undefined && n >= rule.count) break;
    const d = nthOccurrence(rule, n);
    if (rule.endDate && compareISO(d, rule.endDate) > 0) break;
    if (compareISO(d, to) > 0) break;
    if (compareISO(d, from) >= 0) out.push(d);
  }
  return out;
}

/** The next occurrence strictly after `after`, or null when the series has ended. */
export function nextOccurrence(rule: RecurrenceRule, after: ISODate, maxOccurrences = 1000): ISODate | null {
  for (let n = 0; n < maxOccurrences; n++) {
    if (rule.count !== undefined && n >= rule.count) return null;
    const d = nthOccurrence(rule, n);
    if (rule.endDate && compareISO(d, rule.endDate) > 0) return null;
    if (compareISO(d, after) > 0) return d;
  }
  return null;
}

export const FREQUENCY_LABELS_PT: Record<RecurrenceFrequency, string> = {
  daily: 'Todo dia', weekly: 'Toda semana', biweekly: 'A cada 2 semanas', monthly: 'Todo mês', bimonthly: 'A cada 2 meses', quarterly: 'A cada 3 meses', semiannual: 'A cada 6 meses', yearly: 'Todo ano',
};
