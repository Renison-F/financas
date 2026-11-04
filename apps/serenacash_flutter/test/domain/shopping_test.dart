import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/shopping/shopping.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  void check(String fixture, dynamic Function(FixtureCase c) run) {
    group('$fixture fixtures', () {
      for (final c in loadFixtures(fixture)) {
        test(c.name, () {
          final actual = run(c);
          expect(
            jsonEquals(actual, c.expected),
            isTrue,
            reason: '${c.name}\nexpected: ${c.expected}\nactual:   $actual',
          );
        });
      }
    });
  }

  check('shopping_units', (c) {
    final i = c.inputMap;
    if (c.name.startsWith('normalize')) {
      return normalizeQuantity((i['q'] as num).toDouble(), i['unit'] as String);
    }
    if (c.name.startsWith('format')) {
      return formatQuantity((i['q'] as num).toDouble(), i['unit'] as String);
    }
    if (c.name.startsWith('toBase')) {
      final r = toBaseQuantity((i['q'] as num).toDouble(), i['unit'] as String);
      return {'quantity': r.quantity, 'base': r.base};
    }
    return parseUnit(i['token'] as String);
  });

  check('shopping_cart', (c) {
    final i = c.inputMap;
    List<CartLine> lines(dynamic v) => (v as List<dynamic>)
        .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
        .toList();
    if (c.name.startsWith('lineTotal')) {
      return lineTotal(CartLine.fromJson(i['line'] as Map<String, dynamic>))
          .toJson();
    }
    if (c.name.startsWith('cartTotals')) {
      return cartTotals(
        lines(i['lines']),
        (i['budget'] as num?)?.toInt(),
      ).toJson();
    }
    final merged = addLine(
      addLine([], CartLine.fromJson(i['a'] as Map<String, dynamic>)),
      CartLine.fromJson(i['b'] as Map<String, dynamic>),
    );
    return merged.map((l) => l.toJson()).toList();
  });

  check('shopping_codes', (c) {
    final i = c.inputMap;
    if (c.name.startsWith('parseBarcode')) {
      return parseBarcode(i['raw'] as String).toJson();
    }
    if (c.name.startsWith('gtin')) {
      return gtinChecksumValid(i['digits'] as String);
    }
    return parseNFCeQR(i['data'] as String)?.toJson();
  });

  check(
    'shopping_pricetag',
    (c) => parsePriceTag(
      (c.inputMap['lines'] as List<dynamic>)
          .map((e) => OCRLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    ).toJson(),
  );

  check('shopping_lists', (c) {
    const now = '2026-11-04T10:00:00.000Z';
    final i = c.inputMap;
    if (c.name == 'list after adds') {
      const base = ShoppingList(
        id: 'L',
        name: 'Compra do mês',
        store: 'Mercado Bom',
        budgetCents: 30000,
        items: [],
        archived: false,
        createdAt: now,
        updatedAt: now,
      );
      ListItem it(
        String id,
        String name,
        String unit,
        double q,
        String cat, [
        int? price,
        String? src,
      ]) => ListItem(
        id: id,
        name: name,
        unit: unit,
        quantity: q,
        category: cat,
        estimatedUnitPriceCents: price,
        estimateSource: src,
        checked: false,
        sortOrder: 0,
      );
      var l = addItem(
        base,
        it('i1', 'Arroz', 'un', 1, 'Mercearia', 2490, 'history'),
        now,
      );
      l = addItem(l, it('i2', 'arroz', 'un', 1, 'Mercearia'), now);
      l = addItem(l, it('i3', 'Banana', 'kg', 1.5, 'Hortifruti'), now);
      l = addItem(
        l,
        it('i4', 'Sabão', 'un', 1, 'Limpeza', 1290, 'manual'),
        now,
      );
      return l.toJson();
    }
    final list = ShoppingList.fromJson(i['list'] as Map<String, dynamic>);
    if (c.name == 'estimate') return estimateList(list).toJson();
    if (c.name == 'groups') {
      return groupByCategory(list.items)
          .map(
            (g) => {
              'category': g.category,
              'items': g.items.map((x) => x.id).toList(),
            },
          )
          .toList();
    }
    if (c.name == 'progress after toggle') return listProgress(list).toJson();
    final d = duplicateList(list, 'L2', () => 'x', now).toJson();
    d['items'] = (d['items'] as List<dynamic>)
        .map((e) => {...(e as Map<String, dynamic>)}..remove('id'))
        .toList();
    return d;
  });

  check('shopping_products', (c) {
    final i = c.inputMap;
    List<PriceObservation> obs(dynamic v) => (v as List<dynamic>)
        .map((e) => PriceObservation.fromJson(e as Map<String, dynamic>))
        .toList();
    if (c.name.startsWith('find')) {
      final q = i['q'] as Map<String, dynamic>;
      final r = findProduct(
        (i['products'] as List<dynamic>)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        barcode: q['barcode'] as String?,
        store: q['store'] as String?,
        internalCode: q['internalCode'] as String?,
        name: q['name'] as String?,
      );
      return r?.toJson();
    }
    if (c.name.startsWith('history')) {
      return priceHistory(obs(i['obs']), i['productId'] as String).toJson();
    }
    // variation: recompute history from the same observations as the generator
    final hist = i['history'] as Map<String, dynamic>;
    final h = PriceHistory(
      lastCents: (hist['lastCents'] as num?)?.toInt(),
      byStore: const [],
      observations: (hist['observations'] as num).toInt(),
    );
    return priceVariation(h, (i['current'] as num).toInt())?.toJson();
  });

  check('shopping_session', (c) {
    final i = c.inputMap;
    if (c.name == 'start') {
      return startSession(
        'S1',
        i['now'] as String,
        list: ShoppingList.fromJson(i['list'] as Map<String, dynamic>),
      ).toJson();
    }
    if (c.name.startsWith('lineFromListItem')) {
      return lineFromListItem(
        ListItem.fromJson(i['item'] as Map<String, dynamic>),
        'x',
      )?.toJson();
    }
    final s = ShoppingSession.fromJson(i['session'] as Map<String, dynamic>);
    if (c.name == 'totals') return sessionTotals(s).toJson();
    if (c.name == 'plannedVsActual') {
      final r = plannedVsActual(
        s,
        ShoppingList.fromJson(i['list'] as Map<String, dynamic>),
      );
      return {
        'plannedKnownCents': r.plannedKnownCents,
        'actualCents': r.actualCents,
        'differenceCents': r.differenceCents,
        'bought': r.bought,
        'notBought': r.notBought.map((x) => x.id).toList(),
        'extra': r.extra.map((l) => l.id).toList(),
        'perItem': r.perItem
            .map(
              (p) => {
                'item': p.item.id,
                'line': p.line?.id,
                'plannedCents': p.plannedCents,
                'actualCents': p.actualCents,
              },
            )
            .toList(),
      };
    }
    var n = 0;
    if (c.name == 'finish') {
      final r = finishSession(s, i['now'] as String, () => 'id${++n}');
      return {
        'status': r.session.status,
        'observations': r.observations
            .map((o) => o.toJson()..remove('id'))
            .toList(),
        'suggestedTransaction': r.suggestedTransaction?.toJson(),
      };
    }
    return finishSession(
      s,
      '2026-11-04T10:00:00.000Z',
      () => 'id${++n}',
    ).suggestedTransaction?.toJson();
  });
}
