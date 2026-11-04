/// Calendar dates are modelled as ISO strings "YYYY-MM-DD" and month keys as "YYYY-MM".
///
/// They are calendar values (no time, no timezone). All math is done on (year, month, day) integers
/// through UTC epoch days, never through local DateTime, which removes DST/timezone drift.
/// Mirrors `packages/core/src/dates/dates.ts`.
library;

typedef ISODate = String;
typedef MonthKey = String;

class DateParts {
  const DateParts(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;
}

int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

final _isoRe = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final _monthRe = RegExp(r'^\d{4}-\d{2}$');

bool isISODate(Object? s) {
  if (s is! String || !_isoRe.hasMatch(s)) return false;
  final p = parts(s);
  return p.month >= 1 &&
      p.month <= 12 &&
      p.day >= 1 &&
      p.day <= daysInMonth(p.year, p.month);
}

bool isMonthKey(Object? s) {
  if (s is! String || !_monthRe.hasMatch(s)) return false;
  final m = int.parse(s.substring(5, 7));
  return m >= 1 && m <= 12;
}

DateParts parts(ISODate date) => DateParts(
  int.parse(date.substring(0, 4)),
  int.parse(date.substring(5, 7)),
  int.parse(date.substring(8, 10)),
);

String _pad(int n) => n.toString().padLeft(2, '0');

ISODate fromParts(int year, int month, int day) =>
    '$year-${_pad(month)}-${_pad(day)}';

int clampDay(int year, int month, int day) =>
    day.clamp(1, daysInMonth(year, month));

MonthKey monthKeyOf(ISODate date) => date.substring(0, 7);
MonthKey monthKey(int year, int month) => '$year-${_pad(month)}';
ISODate startOfMonth(MonthKey key) => '$key-01';

ISODate endOfMonth(MonthKey key) {
  final y = int.parse(key.substring(0, 4));
  final m = int.parse(key.substring(5, 7));
  return fromParts(y, m, daysInMonth(y, m));
}

ISODate monthKeyToDate(MonthKey key, int day) {
  final y = int.parse(key.substring(0, 4));
  final m = int.parse(key.substring(5, 7));
  return fromParts(y, m, clampDay(y, m, day));
}

/// Adds months, clamping to month length. `anchorDay` keeps the original day across a series.
ISODate addMonthsClamped(ISODate date, int months, [int? anchorDay]) {
  final p = parts(date);
  final total = p.year * 12 + (p.month - 1) + months;
  final y = total ~/ 12 - (total < 0 && total % 12 != 0 ? 1 : 0);
  final m = ((total % 12) + 12) % 12 + 1;
  return fromParts(y, m, clampDay(y, m, anchorDay ?? p.day));
}

MonthKey addMonthsToKey(MonthKey key, int months) =>
    monthKeyOf(addMonthsClamped(startOfMonth(key), months));

int _toEpochDay(ISODate date) {
  final p = parts(date);
  return DateTime.utc(p.year, p.month, p.day).millisecondsSinceEpoch ~/
      86400000;
}

ISODate _fromEpochDay(int n) {
  final d = DateTime.fromMillisecondsSinceEpoch(n * 86400000, isUtc: true);
  return fromParts(d.year, d.month, d.day);
}

ISODate addDays(ISODate date, int days) =>
    _fromEpochDay(_toEpochDay(date) + days);
int diffDays(ISODate from, ISODate to) => _toEpochDay(to) - _toEpochDay(from);
int compareISO(ISODate a, ISODate b) => a.compareTo(b).sign;

/// 0 = Sunday … 6 = Saturday (JavaScript convention).
int weekdayOf(ISODate date) {
  final p = parts(date);
  return DateTime.utc(p.year, p.month, p.day).weekday % 7;
}

typedef Clock = DateTime Function();
DateTime systemClock() => DateTime.now();

/// Today's local calendar date (the device's wall-clock calendar).
ISODate todayISO([Clock clock = systemClock]) {
  final d = clock();
  return fromParts(d.year, d.month, d.day);
}

MonthKey currentMonthKey([Clock clock = systemClock]) =>
    monthKeyOf(todayISO(clock));

List<MonthKey> lastMonthKeys(MonthKey endKey, int n) => [
  for (var i = n - 1; i >= 0; i--) addMonthsToKey(endKey, -i),
];

List<MonthKey> monthKeysBetween(MonthKey startKey, MonthKey endKey) {
  final out = <MonthKey>[];
  var k = startKey;
  while (k.compareTo(endKey) <= 0) {
    out.add(k);
    k = addMonthsToKey(k, 1);
  }
  return out;
}
