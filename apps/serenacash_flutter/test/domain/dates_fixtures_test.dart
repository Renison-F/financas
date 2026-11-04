import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/dates/dates.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  group('dates fixtures (TypeScript equivalence)', () {
    for (final c in loadFixtures('dates')) {
      test(c.name, () {
        final i = c.inputMap;
        dynamic actual;
        if (c.name.startsWith('addMonthsClamped')) {
          actual = addMonthsClamped(
            i['date'] as String,
            i['months'] as int,
            i['anchorDay'] as int?,
          );
        } else if (c.name.startsWith('addDays')) {
          actual = addDays(i['date'] as String, i['days'] as int);
        } else if (c.name.startsWith('daysInMonth')) {
          actual = daysInMonth(i['year'] as int, i['month'] as int);
        } else if (c.name.startsWith('diffDays')) {
          actual = diffDays(i['from'] as String, i['to'] as String);
        } else if (c.name.startsWith('weekday')) {
          actual = weekdayOf(i['date'] as String);
        } else if (c.name.startsWith('lastMonthKeys')) {
          actual = lastMonthKeys(i['end'] as String, i['n'] as int);
        } else if (c.name.startsWith('monthKeyToDate')) {
          actual = monthKeyToDate(i['key'] as String, i['day'] as int);
        } else if (c.name.startsWith('endOfMonth')) {
          actual = endOfMonth(i['key'] as String);
        } else {
          fail('unmapped fixture ${c.name}');
        }
        expect(
          jsonEquals(actual, c.expected),
          isTrue,
          reason: 'expected ${c.expected} got $actual',
        );
      });
    }
  });
  test('validation and local clock', () {
    expect(isISODate('2026-02-30'), isFalse);
    expect(isISODate('2024-02-29'), isTrue);
    expect(isMonthKey('2026-13'), isFalse);
    expect(todayISO(() => DateTime(2026, 11, 4, 23, 59)), '2026-11-04');
    expect(monthKeysBetween('2026-11', '2027-01'), [
      '2026-11',
      '2026-12',
      '2027-01',
    ]);
    expect(addMonthsClamped('2026-01-15', -13), '2024-12-15');
  });
}
