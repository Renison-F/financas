/// Recurring series expansion. Mirrors `packages/core/src/domain/recurrence.ts`.
library;

import '../dates/dates.dart';
import '../entities/entities.dart';

const _monthStep = {'monthly': 1, 'bimonthly': 2, 'quarterly': 3, 'semiannual': 6, 'yearly': 12};
const _dayStep = {'daily': 1, 'weekly': 7, 'biweekly': 14};

const frequencyLabelsPt = {'daily': 'Todo dia', 'weekly': 'Toda semana', 'biweekly': 'A cada 2 semanas', 'monthly': 'Todo mês', 'bimonthly': 'A cada 2 meses', 'quarterly': 'A cada 3 meses', 'semiannual': 'A cada 6 meses', 'yearly': 'Todo ano'};

ISODate nthOccurrence(RecurrenceRule rule, int n) {
  final months = _monthStep[rule.frequency];
  if (months != null) return addMonthsClamped(rule.startDate, months * n, rule.anchorDay ?? parts(rule.startDate).day);
  final days = _dayStep[rule.frequency];
  if (days != null) return addDays(rule.startDate, days * n);
  throw ArgumentError('Frequência desconhecida: ${rule.frequency}');
}

/// Concrete dates inside [from, to] (inclusive), honoring count/endDate; never more than `maxOccurrences`.
List<ISODate> occurrencesBetween(RecurrenceRule rule, ISODate from, ISODate to, {int maxOccurrences = 1000}) {
  final out = <ISODate>[];
  for (var n = 0; n < maxOccurrences; n++) {
    if (rule.count != null && n >= rule.count!) break;
    final d = nthOccurrence(rule, n);
    if (rule.endDate != null && compareISO(d, rule.endDate!) > 0) break;
    if (compareISO(d, to) > 0) break;
    if (compareISO(d, from) >= 0) out.add(d);
  }
  return out;
}

/// The next occurrence strictly after `after`, or null when the series has ended.
ISODate? nextOccurrence(RecurrenceRule rule, ISODate after, {int maxOccurrences = 1000}) {
  for (var n = 0; n < maxOccurrences; n++) {
    if (rule.count != null && n >= rule.count!) return null;
    final d = nthOccurrence(rule, n);
    if (rule.endDate != null && compareISO(d, rule.endDate!) > 0) return null;
    if (compareISO(d, after) > 0) return d;
  }
  return null;
}
