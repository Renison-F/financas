import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/money/money.dart';

import '../fixtures/fixture_loader.dart';

RoundingMode _mode(String s) => switch (s) {
  'half-up' => RoundingMode.halfUp,
  'down' => RoundingMode.down,
  _ => RoundingMode.halfEven,
};

void main() {
  group('money fixtures (TypeScript equivalence)', () {
    for (final c in loadFixtures('money')) {
      test(c.name, () {
        final i = c.inputMap;
        dynamic actual;
        if (c.name.startsWith('cents ')) {
          actual = cents((i['amount'] as num).toDouble());
        } else if (c.name.startsWith('mul ')) {
          actual = mulCents(
            i['cents'] as int,
            (i['factor'] as num).toDouble(),
            _mode(i['mode'] as String),
          );
        } else if (c.name.startsWith('div ')) {
          actual = divCents(
            i['cents'] as int,
            (i['divisor'] as num).toDouble(),
          );
        } else if (c.name.startsWith('percentOf')) {
          actual = percentOf(
            i['cents'] as int,
            (i['percent'] as num).toDouble(),
          );
        } else if (c.name.startsWith('allocate')) {
          actual = allocate(
            i['total'] as int,
            i['n'] as int,
            i['remainderOn'] == 'last' ? RemainderOn.last : RemainderOn.first,
          );
        } else if (c.name.startsWith('parse ')) {
          actual = parseMoneyBR(i['text'] as String);
        } else if (c.name.startsWith('format hidden')) {
          actual = formatBRL(i['cents'] as int, hidden: true);
        } else if (c.name.startsWith('format ')) {
          actual = formatBRL(i['cents'] as int);
        } else if (c.name.startsWith('add ')) {
          actual = addCents(i['a'] as int, i['b'] as int);
        } else {
          fail('unmapped fixture ${c.name}');
        }
        expect(
          jsonEquals(actual, c.expected),
          isTrue,
          reason: 'expected ${c.expected} got $actual (${c.note})',
        );
      });
    }
  });
  group('money extra rules', () {
    test('rejects non-finite and overflow', () {
      expect(() => cents(double.nan), throwsA(isA<MoneyError>()));
      expect(() => addCents(maxSafeCents, 1), throwsA(isA<MoneyError>()));
      expect(() => allocate(100, 0), throwsA(isA<MoneyError>()));
      expect(() => divCents(1, 0), throwsA(isA<MoneyError>()));
    });
    test('allocate sums exactly for every n in a range', () {
      for (var n = 1; n <= 60; n++) {
        final parts = allocate(123457, n);
        expect(parts.fold<int>(0, (a, b) => a + b), 123457);
        expect(
          parts.reduce((a, b) => a > b ? a : b) -
              parts.reduce((a, b) => a < b ? a : b),
          lessThanOrEqualTo(1),
        );
      }
    });
    test('no drift over 10.000 additions of one cent', () {
      var t = 0;
      for (var i = 0; i < 10000; i++) {
        t = addCents(t, 1);
      }
      expect(t, 10000);
    });
  });
}
