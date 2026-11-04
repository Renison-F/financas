/// Money is represented as an integer number of the currency's minor unit (cents).
///
/// All arithmetic is integer arithmetic; rounding only happens at explicit boundaries
/// (multiplication by a factor, division, allocation). Semantics mirror `packages/core/src/money/money.ts`
/// and are verified against the JSON fixtures in `docs/flutter-migration/fixtures/money.json`.
library;

import 'package:intl/intl.dart';

/// Integer cents. Dart `int` is 64-bit on native platforms; we additionally enforce the JS safe-integer
/// range (2^53 − 1) so values round-trip through JSON and the legacy app without loss.
typedef Cents = int;

enum RoundingMode { halfEven, halfUp, down }

const int maxSafeCents = 9007199254740991; // 2^53 - 1

class MoneyError implements Exception {
  MoneyError(this.message);
  final String message;
  @override
  String toString() => 'MoneyError: $message';
}

Cents assertCents(num value) {
  if (value is! int || value.abs() > maxSafeCents) {
    throw MoneyError(
      'Valor monetário inválido (esperado inteiro em centavos): $value',
    );
  }
  return value;
}

/// Converts a decimal amount (e.g. 24.9) to integer cents, removing float noise.
/// Mirrors JS `Math.round(amount * 100 ± 1e-9)` (round half toward +∞).
Cents cents(double amount) {
  if (!amount.isFinite) throw MoneyError('Valor inválido: $amount');
  final scaled = _jsRound(amount * 100 + (amount >= 0 ? 1e-9 : -1e-9));
  return assertCents(scaled == 0 ? 0 : scaled);
}

/// JavaScript Math.round: rounds half toward positive infinity.
int _jsRound(double v) => (v + 0.5).floorToDouble().toInt();

int _roundTo(double value, RoundingMode mode) {
  switch (mode) {
    case RoundingMode.down:
      return value < 0 ? value.ceil() : value.floor();
    case RoundingMode.halfUp:
      final sign = value < 0 ? -1 : 1;
      return sign * (value.abs() + 0.5).floor();
    case RoundingMode.halfEven:
      final sign = value < 0 ? -1 : 1;
      final abs = value.abs();
      final floor = abs.floor();
      final diff = abs - floor;
      const eps = 1e-9;
      if ((diff - 0.5).abs() < eps) {
        return sign * (floor.isEven ? floor : floor + 1);
      }
      return sign * (diff > 0.5 ? floor + 1 : floor);
  }
}

Cents addCents(Cents a, Cents b) {
  final r = assertCents(a) + assertCents(b);
  if (r.abs() > maxSafeCents) throw MoneyError('Estouro de valor monetário');
  return r;
}

Cents subCents(Cents a, Cents b) => addCents(a, -assertCents(b));

Cents negate(Cents a) {
  final r = -assertCents(a);
  return r == 0 ? 0 : r;
}

Cents sumCents(Iterable<Cents> values) => values.fold<Cents>(0, addCents);

/// Multiplies cents by an arbitrary factor (quantity, rate) and rounds once.
/// Tiny binary noise is snapped away at 1e-6 before rounding, exactly like the TypeScript original.
Cents mulCents(
  Cents a,
  double factor, [
  RoundingMode mode = RoundingMode.halfEven,
]) {
  if (!factor.isFinite) throw MoneyError('Fator inválido: $factor');
  final raw = assertCents(a) * factor;
  final snapped = _jsRound(raw * 1e6) / 1e6;
  final r = _roundTo(snapped, mode);
  return assertCents(r == 0 ? 0 : r);
}

Cents divCents(
  Cents a,
  double divisor, [
  RoundingMode mode = RoundingMode.halfEven,
]) {
  if (!divisor.isFinite || divisor == 0) throw MoneyError('Divisão por zero');
  return mulCents(a, 1 / divisor, mode);
}

/// percent in 0..100 (e.g. 15 for 15%)
Cents percentOf(
  Cents a,
  double percent, [
  RoundingMode mode = RoundingMode.halfEven,
]) => mulCents(a, percent / 100, mode);

enum RemainderOn { first, last }

/// Splits `total` into `n` integer parts whose sum is exactly `total`.
/// The remainder (at most n−1 cents) goes one cent at a time to the first parts (default) or the last parts.
List<Cents> allocate(
  Cents total,
  int n, [
  RemainderOn remainderOn = RemainderOn.first,
]) {
  assertCents(total);
  if (n < 1) throw MoneyError('Número de partes inválido: $n');
  final sign = total < 0 ? -1 : 1;
  final abs = total.abs();
  final base = abs ~/ n;
  var remainder = abs - base * n;
  final parts = List<int>.filled(n, base);
  if (remainderOn == RemainderOn.first) {
    for (var i = 0; i < n && remainder > 0; i++, remainder--) {
      parts[i] = base + 1;
    }
  } else {
    for (var i = n - 1; i >= 0 && remainder > 0; i--, remainder--) {
      parts[i] = base + 1;
    }
  }
  return parts.map((p) => p == 0 ? 0 : sign * p).toList();
}

final _digitsOnly = RegExp(r'^\d+$');
final _moneyChars = RegExp(r'^[\d.,]+$');
final _thousandsDot = RegExp(r'^\d{1,3}(\.\d{3})+$');
final _thousandsComma = RegExp(r'^\d{1,3}(,\d{3})+$');
final _frac = RegExp(r'^\d{0,2}$');

/// Parses user/OCR input into cents. Accepts "R$ 1.234,56", "1234,56", "24,9", "24", "1,234.56", "1234.56".
/// Returns null when the text is not a single monetary value.
Cents? parseMoneyBR(String input) {
  var s = input.trim().replaceAll(RegExp(r'\s+'), '');
  if (s.isEmpty) return null;
  var negative = false;
  if (s.startsWith('-')) {
    negative = true;
    s = s.substring(1);
  }
  s = s.replaceFirst(RegExp(r'^R\$', caseSensitive: false), '');
  if (s.startsWith('-')) {
    negative = !negative;
    s = s.substring(1);
  }
  if (!_moneyChars.hasMatch(s)) return null;
  final commas = ','.allMatches(s).length;
  final dots = '.'.allMatches(s).length;
  String intPart;
  var fracPart = '';
  if (commas == 1 && dots == 0) {
    final p = s.split(',');
    intPart = p[0];
    fracPart = p[1];
  } else if (dots == 1 && commas == 0) {
    final p = s.split('.');
    if (p[1].length == 3 && p[0].length <= 3) {
      intPart = p[0] + p[1];
    } else {
      intPart = p[0];
      fracPart = p[1];
    }
  } else if (commas == 1 && dots >= 1) {
    if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
      final p = s.split(',');
      if (!_thousandsDot.hasMatch(p[0])) return null;
      intPart = p[0].replaceAll('.', '');
      fracPart = p[1];
    } else {
      final p = s.split('.');
      if (!_thousandsComma.hasMatch(p[0])) return null;
      intPart = p[0].replaceAll(',', '');
      fracPart = p[1];
    }
  } else if (commas == 0 && dots == 0) {
    intPart = s;
  } else if (commas == 0 && dots > 1) {
    if (!_thousandsDot.hasMatch(s)) return null;
    intPart = s.replaceAll('.', '');
  } else {
    return null;
  }
  if (!_digitsOnly.hasMatch(intPart) || !_frac.hasMatch(fracPart)) return null;
  final padded = ('${fracPart}00').substring(0, 2);
  final big =
      BigInt.parse(intPart) * BigInt.from(100) + BigInt.from(int.parse(padded));
  if (big > BigInt.from(maxSafeCents)) return null;
  final value = big.toInt();
  if (negative) return value == 0 ? 0 : -value;
  return value;
}

/// Formats cents with pt-BR conventions ("R$ 1.234,56"); `hidden` renders the privacy placeholder.
/// Uses a non-breaking space between symbol and amount, like `Intl.NumberFormat('pt-BR')` in JavaScript.
String formatBRL(
  Cents value, {
  bool hidden = false,
  String currency = 'BRL',
  String locale = 'pt_BR',
}) {
  final symbol = _symbolFor(currency);
  if (hidden) return '$symbol ••••';
  final v = assertCents(value);
  final neg = v < 0;
  final abs = v.abs();
  final intPart = abs ~/ 100;
  final frac = (abs % 100).toString().padLeft(2, '0');
  final grouped = NumberFormat.decimalPattern(locale).format(intPart);
  return '${neg ? '-' : ''}$symbol $grouped,$frac';
}

String _symbolFor(String currency) {
  switch (currency) {
    case 'BRL':
      return r'R$';
    case 'USD':
      return r'US$';
    case 'EUR':
      return '€';
    default:
      return currency;
  }
}
