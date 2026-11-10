/// Ocorrência 022: entender um item ditado sem adivinhar o que é ambíguo.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/shopping/voice.dart';

void main() {
  test('"5 kg de arroz, 29 reais": the amount may be the total or the price per kilo', () {
    final s = parseSpokenItem('5 kg de arroz, 29 reais');
    expect(s.name, 'Arroz');
    expect(s.quantity, 5);
    expect(s.unit, 'kg');
    expect(s.amountCents, 2900);
    expect(s.meaning, SpokenPrice.ambiguous);
    // the two readings give different unit prices; neither is chosen for the user
    expect(s.unitPriceCents(amountIsTotal: true), 580);
    expect(s.unitPriceCents(amountIsTotal: false), 2900);
  });

  test('said as a total', () {
    final s = parseSpokenItem('5 quilos de arroz custando R\$ 29 no total');
    expect(s.meaning, SpokenPrice.total);
    expect(s.name, 'Arroz');
    expect(s.quantity, 5);
    expect(s.unit, 'kg');
    expect(s.unitPriceCents(amountIsTotal: true), 580);
  });

  test('said per unit', () {
    for (final t in [
      '5 kg de arroz a 29 reais o quilo',
      '5 quilos de arroz por 29 reais cada',
      '5 kg de arroz 29 reais por quilo',
    ]) {
      final s = parseSpokenItem(t);
      expect(s.meaning, SpokenPrice.perUnit, reason: t);
      expect(s.amountCents, 2900, reason: t);
      expect(s.name, 'Arroz', reason: t);
      expect(s.quantity, 5, reason: t);
    }
  });

  test('one unit: the amount is the price of that unit', () {
    final s = parseSpokenItem('pão de forma 9,99');
    expect(s.name, 'Pao de forma');
    expect(s.quantity, 1);
    expect(s.unit, 'un');
    expect(s.amountCents, 999);
    expect(s.meaning, SpokenPrice.perUnit);
  });

  test('ways of saying money', () {
    expect(parseSpokenItem('vela R\$ 11,99').amountCents, 1199);
    expect(parseSpokenItem('vela 11 reais e 99 centavos').amountCents, 1199);
    expect(parseSpokenItem('vela 11 reais e 99').amountCents, 1199);
    expect(parseSpokenItem('vela por 12').amountCents, 1200);
    expect(parseSpokenItem('vela 1 real').amountCents, 100);
    expect(
      parseSpokenItem('vela 4,5').amountCents,
      isNull,
      reason: 'um decimal só não é dinheiro',
    );
  });

  test('quantities in words, dozens, and units glued to the number', () {
    var s = parseSpokenItem('dois litros de leite 5,49 cada');
    expect(
      (s.quantity, s.unit, s.name, s.amountCents),
      (2.0, 'l', 'Leite', 549),
    );
    expect(s.meaning, SpokenPrice.perUnit);
    s = parseSpokenItem('meia dúzia de ovos 8 reais');
    expect((s.quantity, s.unit, s.name), (6.0, 'un', 'Ovos'));
    expect(s.meaning, SpokenPrice.ambiguous);
    s = parseSpokenItem('500g de queijo 24,90');
    expect(
      (s.quantity, s.unit, s.name, s.amountCents),
      (500.0, 'g', 'Queijo', 2490),
    );
    s = parseSpokenItem('3 pacotes de café 18,90 cada');
    expect((s.quantity, s.unit, s.name), (3.0, 'un', 'Cafe'));
    s = parseSpokenItem('meio quilo de carne moída');
    expect(
      (s.quantity, s.unit, s.name, s.amountCents),
      (0.5, 'kg', 'Carne moida', null),
    );
    expect(s.meaning, SpokenPrice.none);
  });

  test('a number that is part of the product is not taken as price or quantity by accident', () {
    final s = parseSpokenItem('refrigerante 2 litros 8,99');
    expect(s.amountCents, 899);
    expect(s.name, contains('Refrigerante'));
    final t = parseSpokenItem('papel higiênico 12 rolos');
    expect(t.amountCents, isNull);
    expect(t.name, 'Papel higienico 12 rolos');
  });

  test('no price said: nothing is invented', () {
    final s = parseSpokenItem('arroz');
    expect(s.name, 'Arroz');
    expect(s.amountCents, isNull);
    expect(s.meaning, SpokenPrice.none);
    expect(s.unitPriceCents(amountIsTotal: false), isNull);
  });

  test('"cancelar" gives up instead of becoming a product', () {
    expect(parseSpokenItem('cancelar').cancel, isTrue);
    expect(parseSpokenItem('Cancela isso').cancel, isTrue);
    expect(parseSpokenItem('arroz').cancel, isFalse);
  });

  test('empty or noise: an empty item, not an error', () {
    final s = parseSpokenItem('   ');
    expect(s.name, '');
    expect(s.quantity, 1);
    expect(s.amountCents, isNull);
  });
}
