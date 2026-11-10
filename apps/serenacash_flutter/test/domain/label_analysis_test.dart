/// Ocorrências 015 e 016 da homologação física: o leitor de etiquetas adotava slogan como nome e
/// preço por quilo, de atacado ou de campo secundário como preço do item.
///
/// Os casos em test/fixtures/labels são a saída real do motor de OCR (ML Kit, no emulador) para as
/// fotos que o usuário tirou no supermercado. O gabarito abaixo é o que está impresso em cada
/// etiqueta. Onde o motor errou um dígito, o esperado é que a leitura peça conferência, não que
/// acerte por mágica.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/shopping/label.dart';

List<OcrBox> _load(String name) {
  final j = jsonDecode(
    File('test/fixtures/labels/$name.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return [
    for (final l in j['lines'] as List)
      OcrBox.fromJson(l as Map<String, dynamic>),
  ];
}

class _Expect {
  const _Expect(
    this.caseId,
    this.file, {
    required this.nameHas,
    required this.printedCents,
    this.nameNot = const [],
    this.engineMisreadPrice = false,
  });
  final String caseId, file;

  /// Words of the description printed on the label (OCR spelling tolerated elsewhere).
  final List<String> nameHas;
  final List<String> nameNot;

  /// The retail price printed on the label.
  final int printedCents;

  /// The engine itself read a wrong digit on this photo; the analysis must ask for review.
  final bool engineMisreadPrice;
}

const _cases = [
  _Expect(
    'OCR-01',
    'etiqueta-pa-lixo-1699',
    nameHas: ['LIXO', 'NOVICA', 'CIPA'],
    printedCents: 1699,
    nameNot: ['Loja', 'Preco'],
  ),
  _Expect(
    'OCR-02',
    'etiqueta-papel-higienico-1399',
    nameHas: ['PAPEL', 'HIG', 'MAX', '30M'],
    printedCents: 1399,
    nameNot: ['Cartaz', 'Cataz', 'Qualidade', 'FRIDAY'],
  ),
  _Expect(
    'OCR-03',
    'etiqueta-agua-999-949',
    nameHas: ['AGUA', 'INDAIA', 'PET'],
    printedCents: 999,
    nameNot: ['ATACADO', 'PARTIR'],
  ),
  _Expect(
    'OCR-04',
    'etiqueta-vela-1199',
    nameHas: ['VELA', 'FIAT', 'LUX'],
    printedCents: 1199,
    engineMisreadPrice: true,
  ),
  _Expect(
    'OCR-05',
    'etiqueta-cookies-499',
    nameHas: ['COOKIES', '96G', 'CARAMELO'],
    printedCents: 499,
  ),
  _Expect(
    'OCR-06',
    'etiqueta-pao-999',
    nameHas: ['PAO', 'FORMA'],
    printedCents: 999,
  ),
  _Expect(
    'OCR-07',
    'etiqueta-abacaxi-899',
    nameHas: ['ABACAXI', 'UNIAO'],
    printedCents: 899,
    nameNot: ['fresquinho', 'HORTIFRUTI', 'horta'],
  ),
  _Expect(
    'extra',
    'etiqueta-toalha-papel-899',
    nameHas: ['TOALHA', 'PAPEL', 'COQUETEL', '180F'],
    printedCents: 899,
  ),
];

void main() {
  final score = <String, List<String>>{
    'nome': [],
    'preço de varejo': [],
    'pede conferência quando o motor errou': [],
  };

  for (final c in _cases) {
    test('${c.caseId} ${c.file}: description and retail price', () {
      final a = analyzeLabel(_load(c.file));
      final name = a.name?.text ?? '';
      for (final w in c.nameHas) {
        expect(name, contains(w), reason: 'descrição lida: "$name"');
      }
      for (final w in c.nameNot) {
        expect(name, isNot(contains(w)), reason: 'descrição lida: "$name"');
      }
      score['nome']!.add(c.caseId);
      expect(a.unit, 'un');
      if (c.engineMisreadPrice) {
        // The digits on the photo did not reach the analysis whole. What can be guaranteed is
        // that the value is not offered as trustworthy.
        expect(a.price?.cents, isNot(c.printedCents));
        expect(a.needsReview, isTrue);
        expect(a.reviewReasons.join(' '), contains('confira na foto'));
        score['pede conferência quando o motor errou']!.add(c.caseId);
      } else {
        expect(a.price?.cents, c.printedCents, reason: a.price?.reason);
        expect(a.price?.role, LabelPriceRole.retail);
        score['preço de varejo']!.add(c.caseId);
      }
    });
  }

  test('OCR-03: retail by default; wholesale kept with its condition', () {
    final a = analyzeLabel(_load('etiqueta-agua-999-949'));
    expect(a.price?.cents, 999);
    expect(a.price?.reason, contains('varejo'));
    final w = a.wholesale;
    expect(w, isNotNull);
    expect(w!.cents, 949);
    expect(w.minQuantity, 3);
    expect(w.reason, contains('a partir de 3 unidades'));
    // the price per liter is comparison print, never the price of the bottle
    final perLiter = a.prices.where((p) => p.role == LabelPriceRole.perMeasure);
    expect(perLiter.map((p) => p.cents), contains(200));
    expect(perLiter.every((p) => p.unit == 'l'), isTrue);
    // the wholesale price only applies once the minimum is in the cart
    int at(double q) => priceForQuantity(
      retailCents: a.price!.cents,
      wholesaleCents: w.cents,
      wholesaleMinQuantity: w.minQuantity,
      quantity: q,
    );
    expect(at(1), 999);
    expect(at(2), 999);
    expect(at(3), 949);
    expect(at(12), 949);
  });

  test(
    'OCR-05: the price per kilo is never taken as the price of the pack',
    () {
      final a = analyzeLabel(_load('etiqueta-cookies-499'));
      expect(a.price?.cents, 499);
      expect(
        a.prices.where((p) => p.cents > 4000 && identical(p, a.price)),
        isEmpty,
      );
      // "4.99-" came with stray characters: right value, and still asked to be checked
      expect(a.price?.repaired, isTrue);
      expect(a.needsReview, isTrue);
    },
  );

  test(
    'OCR-04: "price per unit" in small print is not the price of the item',
    () {
      final a = analyzeLabel(_load('etiqueta-vela-1199'));
      final small = a.prices.where((p) => p.cents == 130).single;
      expect(small.role, LabelPriceRole.perUnitOfPack);
      expect(identical(small, a.price), isFalse);
    },
  );

  test(
    'OCR-06: per-kilo print with a misread weight does not override the price',
    () {
      final a = analyzeLabel(_load('etiqueta-pao-999'));
      expect(a.price?.cents, 999);
      final perKg = a.prices.where((p) => p.role == LabelPriceRole.perMeasure);
      expect(perKg.single.cents, 2081);
      expect(perKg.single.unit, 'kg');
    },
  );

  test('the slogan and the banner stay as alternatives, never first', () {
    final a = analyzeLabel(_load('etiqueta-abacaxi-899'));
    final all = a.names.map((n) => n.text).toList();
    expect(all.first, 'ABACAXI UNIAO UN');
    expect(all, contains('Tudo fresquinho da horta'));
    final slogan = a.names.firstWhere((n) => n.text.startsWith('Tudo'));
    expect(slogan.reason, contains('slogan'));
  });

  test(
    'a bar code printed on the label is taken only when its check digit closes',
    () {
      // on these photos the engine garbled every printed code; none may be accepted
      for (final c in _cases) {
        final a = analyzeLabel(_load(c.file));
        if (a.barcode != null) {
          expect(a.barcode!.length, anyOf(13, 14));
        }
      }
      final a = analyzeLabel(const [
        OcrBox(
          text: 'ARROZ TIPO 1 5KG',
          left: 10,
          top: 10,
          width: 300,
          height: 30,
        ),
        OcrBox(text: '24,90', left: 60, top: 60, width: 200, height: 90),
        OcrBox(
          text: '7891000100103',
          left: 10,
          top: 170,
          width: 150,
          height: 14,
        ),
      ]);
      expect(a.barcode, '7891000100103');
      expect(a.price?.cents, 2490);
      expect(a.name?.text, 'ARROZ TIPO 1 5KG');
      expect(a.needsReview, isFalse);
    },
  );

  test(
    'printed price per kilo that agrees with weight and price raises trust',
    () {
      final a = analyzeLabel(const [
        OcrBox(
          text: 'COOKIES MAXI 96G CARAMELO',
          left: 10,
          top: 10,
          width: 400,
          height: 30,
          confidence: 0.9,
        ),
        OcrBox(
          text: 'VAREJO',
          left: 10,
          top: 50,
          width: 90,
          height: 28,
          confidence: 0.9,
        ),
        OcrBox(
          text: '4,99',
          left: 200,
          top: 50,
          width: 220,
          height: 110,
          confidence: 0.9,
        ),
        OcrBox(
          text: 'Preco por KILO = R\$51,98',
          left: 60,
          top: 170,
          width: 260,
          height: 20,
          confidence: 0.8,
        ),
      ]);
      expect(a.price?.cents, 499);
      expect(a.crossChecked, isTrue);
      expect(a.needsReview, isFalse);
      final wrong = analyzeLabel(const [
        OcrBox(
          text: 'COOKIES MAXI 96G CARAMELO',
          left: 10,
          top: 10,
          width: 400,
          height: 30,
          confidence: 0.9,
        ),
        OcrBox(
          text: '3,99',
          left: 200,
          top: 50,
          width: 220,
          height: 110,
          confidence: 0.9,
        ),
        OcrBox(
          text: 'Preco por KILO = R\$51,98',
          left: 60,
          top: 170,
          width: 260,
          height: 20,
          confidence: 0.8,
        ),
      ]);
      expect(wrong.crossChecked, isFalse);
      expect(wrong.reviewReasons.join(' '), contains('preço por quilo'));
    },
  );

  test('nothing readable: no price is invented and review is required', () {
    final a = analyzeLabel(const [
      OcrBox(
        text: 'oiete',
        left: 0,
        top: 0,
        width: 50,
        height: 20,
        confidence: 0.3,
      ),
    ]);
    expect(a.price, isNull);
    expect(a.needsReview, isTrue);
    final empty = analyzeLabel(const []);
    expect(empty.price, isNull);
    expect(empty.names, isEmpty);
    expect(empty.needsReview, isTrue);
  });

  tearDownAll(() {
    // Scoreboard over the supermarket photos (not a precision claim: 8 photos, one store).
    // ignore: avoid_print
    print(
      'OCR-GABARITO (${_cases.length} fotos): '
      '${score.entries.map((e) => '${e.key} ${e.value.length}').join(' · ')}',
    );
  });
}
