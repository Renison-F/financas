/// Ocorrências 008 e 013: fatias e percentuais do gráfico de despesas por categoria.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/reports/reports.dart';
import 'package:serenacash/domain/reports/shares.dart';

CategoryTotal _t(String name, int cents, [int count = 1]) => CategoryTotal(
  categoryId: name,
  name: name,
  color: '#0B5563',
  cents: cents,
  percent: 0,
  count: count,
);

void main() {
  test('shares always add up to 100,0%', () {
    expect(sharesPerMille([4500, 100]), [978, 22]);
    expect(sharesPerMille([1, 1, 1]), [334, 333, 333]);
    expect(sharesPerMille([1, 1, 1]).reduce((a, b) => a + b), 1000);
    for (final values in [
      [3333, 3333, 3334],
      [1, 999999],
      [7, 7, 7, 7, 7, 7, 7],
      [123456, 654321, 111, 9],
    ]) {
      expect(
        sharesPerMille(values).reduce((a, b) => a + b),
        1000,
        reason: '$values',
      );
    }
    expect(perMilleLabel(978), '97,8');
    expect(perMilleLabel(22), '2,2');
    expect(perMilleLabel(1000), '100,0');
  });

  test('nothing spent: no slice at all, never an artificial ring', () {
    expect(sharesPerMille([0, 0]), [0, 0]);
    expect(sharesPerMille([]), isEmpty);
    expect(categorySlices(const []), isEmpty);
    expect(categorySlices([_t('a', 0), _t('b', -500)]), isEmpty);
  });

  test(
    'small categories are grouped into one slice that says what is inside',
    () {
      final slices = categorySlices([
        _t('Moradia', 120000),
        _t('Alimentação', 80000),
        _t('Transporte', 30000),
        _t('Saúde', 20000),
        _t('Lazer', 10000),
        _t('Pets', 5000, 2),
        _t('Presentes', 3000),
        _t('Outros gastos', 2000),
      ], maxSlices: 6);
      expect(slices.length, 6);
      expect(slices.take(5).map((s) => s.name), [
        'Moradia',
        'Alimentação',
        'Transporte',
        'Saúde',
        'Lazer',
      ]);
      final other = slices.last;
      expect(other.isOther, isTrue);
      expect(other.name, 'Outras');
      expect(other.cents, 10000);
      expect(other.count, 4);
      expect(other.members.map((m) => m.name), [
        'Pets',
        'Presentes',
        'Outros gastos',
      ]);
      expect(slices.fold(0, (a, s) => a + s.cents), 270000);
      expect(slices.fold(0, (a, s) => a + s.perMille), 1000);
    },
  );

  test('up to the limit, every category keeps its own slice', () {
    final slices = categorySlices([
      _t('Alimentação', 4500),
      _t('Compras', 100),
    ]);
    expect(slices.map((s) => s.name), ['Alimentação', 'Compras']);
    expect(slices.map((s) => s.perMille), [978, 22]);
    expect(slices.any((s) => s.isOther), isFalse);
  });

  test('a refund larger than the spending leaves the category out instead of a negative slice', () {
    final slices = categorySlices([
      _t('Compras', -2000),
      _t('Alimentação', 4500),
    ]);
    expect(slices.single.name, 'Alimentação');
    expect(slices.single.perMille, 1000);
  });
}
