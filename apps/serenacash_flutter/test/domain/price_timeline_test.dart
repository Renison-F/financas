/// Ocorrência 024: evolução do preço de um produto entre compras, comparando igual com igual.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/shopping/shopping.dart';

PriceObservation _o(
  String id,
  int cents,
  String at, {
  String unit = 'un',
  String? store,
  String product = 'p1',
}) => PriceObservation(
  id: id,
  productId: product,
  store: store,
  unit: unit,
  unitPriceCents: cents,
  observedAt: at,
  source: 'label_ocr',
);

void main() {
  test(
    'each purchase is compared with the one before it, in value and in percent',
    () {
      final t = priceTimeline([
        _o('b', 1499, '2026-11-08T21:00:00.000Z', store: 'Costa'),
        _o('a', 1199, '2026-10-05T10:00:00.000Z', store: 'Costa'),
        _o('c', 1499, '2026-12-01T10:00:00.000Z', store: 'Outro'),
      ], 'p1');
      expect(t.map((p) => p.observation.id), [
        'a',
        'b',
        'c',
      ], reason: 'ordem do tempo');
      expect(
        t[0].changeCents,
        isNull,
        reason: 'o primeiro registro não tem com o que comparar',
      );
      expect(t[1].changeCents, 300);
      expect(t[1].changePerMille, 250); // 3,00 sobre 11,99 = 25,0%
      expect(t[2].changeCents, 0);
      expect(t[2].changePerMille, 0);
    },
  );

  test('a price per kilo is never compared with a price per unit', () {
    final t = priceTimeline([
      _o('a', 499, '2026-10-01T10:00:00.000Z'),
      _o('b', 5198, '2026-10-10T10:00:00.000Z', unit: 'kg'),
      _o('c', 549, '2026-10-20T10:00:00.000Z'),
      _o('d', 4990, '2026-10-30T10:00:00.000Z', unit: 'kg'),
    ], 'p1');
    expect(t[1].changeCents, isNull, reason: 'primeiro registro em kg');
    expect(
      t[2].changeCents,
      50,
      reason: 'comparado com o registro anterior em un',
    );
    expect(
      t[3].changeCents,
      -208,
      reason: 'comparado com o registro anterior em kg',
    );
  });

  test('only the product asked for; no record, no series', () {
    final obs = [
      _o('a', 499, '2026-10-01T10:00:00.000Z'),
      _o('x', 999, '2026-10-02T10:00:00.000Z', product: 'p2'),
    ];
    expect(priceTimeline(obs, 'p1').length, 1);
    expect(priceTimeline(obs, 'p3'), isEmpty);
    expect(priceTimeline(const [], 'p1'), isEmpty);
  });

  test('finishing a purchase records each price once, however many times it is computed', () {
    final session = startSession(
      's1',
      '2026-11-08T21:00:00.000Z',
      store: 'Costa',
    );
    final withLine = addToSession(
      session,
      const CartLine(
        id: 'l1',
        productId: 'p1',
        name: 'Vela',
        unit: 'un',
        quantity: 1,
        unitPriceCents: 1199,
        priceSource: 'manual',
        checked: true,
      ),
      '2026-11-08T21:05:00.000Z',
    );
    var n = 0;
    final first = finishSession(
      withLine,
      '2026-11-08T21:40:00.000Z',
      () => 'o${++n}',
    );
    expect(first.observations.length, 1);
    expect(first.observations.single.unitPriceCents, 1199);
    // a finished purchase finished again yields the same single observation, not another one
    final again = finishSession(
      first.session,
      '2026-11-08T21:41:00.000Z',
      () => 'o${++n}',
    );
    expect(again.observations.length, lessThanOrEqualTo(1));
  });
}
