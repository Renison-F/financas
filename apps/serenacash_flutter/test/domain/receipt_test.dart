/// Ocorrências 019, 020 e 016 (preço condicional): leitura do cupom fiscal, pareamento com o
/// carrinho e comparação entre o preço anunciado na gôndola e o preço cobrado.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/shopping/shopping.dart';

CartLine _line(
  String id,
  String name,
  int cents, {
  double qty = 1,
  String? barcode,
  int? wholesale,
  int? wholesaleMin,
}) => CartLine(
  id: id,
  name: name,
  unit: 'un',
  quantity: qty,
  unitPriceCents: cents,
  priceSource: 'label_ocr',
  checked: true,
  barcode: barcode,
  advertisedPriceCents: cents,
  wholesalePriceCents: wholesale,
  wholesaleMinQuantity: wholesaleMin,
);

void main() {
  group('parseReceipt', () {
    test(
      'one row per item: sequence, code, description, quantity × price, total',
      () {
        final r = parseReceipt([
          'COSTA ATACADAO LTDA',
          'CNPJ 00.000.000/0001-00',
          '001 7896007912191 VELA FIAT LUX N7 C/8 1 UN x 14,99 14,99',
          '002 7891962071619 COOKIES BAUDUCCO 96G 2 UN X 4,99 9,98',
          '003 ABACAXI UNIAO UN 1 UN x 8,99 8,99',
          'QTD. TOTAL DE ITENS 3',
          'VALOR TOTAL R\$ 33,96',
          'Cartao de Debito 33,96',
        ]);
        expect(r.lines.length, 3);
        expect(r.lines[0].description, 'VELA FIAT LUX N7 C/8');
        expect(r.lines[0].code, '7896007912191');
        expect(r.lines[0].unitPriceCents, 1499);
        expect(r.lines[0].totalCents, 1499);
        expect(r.lines[1].quantity, 2);
        expect(r.lines[1].unitPriceCents, 499);
        expect(r.lines[1].totalCents, 998);
        expect(r.lines[2].description, 'ABACAXI UNIAO UN');
        expect(r.totalCents, 3396);
        expect(r.warnings, isEmpty);
      },
    );

    test('description on one row and figures on the next', () {
      final r = parseReceipt([
        'PAPEL HIG FD MAX 30M LV12PG11',
        '1 UN x 13,99 13,99',
        'AGUA S/GAS INDAIA PET 5L',
        '3 UN x 9,49 28,47',
        'TOTAL 42,46',
      ]);
      expect(r.lines.map((l) => l.description), [
        'PAPEL HIG FD MAX 30M LV12PG11',
        'AGUA S/GAS INDAIA PET 5L',
      ]);
      expect(r.lines[1].quantity, 3);
      expect(r.lines[1].unitPriceCents, 949);
      expect(r.lines[1].totalCents, 2847);
      expect(r.totalCents, 4246);
    });

    test('weighed item, and a row whose figures do not close is flagged', () {
      final r = parseReceipt([
        'BANANA PRATA KG 1,250 kg x 6,99 8,74',
        'ARROZ TIPO 1 5KG 2 UN x 24,90 59,80',
        'TOTAL 68,54',
      ]);
      expect(r.lines[0].unit, 'kg');
      expect(r.lines[0].quantity, 1.25);
      expect(r.lines[0].totalCents, 874);
      expect(r.warnings.join(' '), contains('ARROZ'));
      expect(r.warnings.join(' '), contains('não fecha'));
    });

    test('items that do not add up to the printed total are reported', () {
      final r = parseReceipt([
        'VELA FIAT LUX 1 UN x 14,99 14,99',
        'TOTAL 33,96',
      ]);
      expect(r.warnings.join(' '), contains('difere do total do cupom'));
    });

    test('nothing readable: no line is invented', () {
      final r = parseReceipt(['obrigado e volte sempre', 'CPF nao informado']);
      expect(r.lines, isEmpty);
      expect(r.warnings.single, contains('Nenhum item'));
    });

    test('boxes of one printed row are joined left to right', () {
      final rows = receiptRows(const [
        OcrBox(text: '14,99', left: 400, top: 101, width: 60, height: 18),
        OcrBox(
          text: 'VELA FIAT LUX 1 UN x 14,99',
          left: 10,
          top: 100,
          width: 300,
          height: 18,
        ),
        OcrBox(text: 'TOTAL', left: 10, top: 140, width: 60, height: 18),
        OcrBox(text: '14,99', left: 400, top: 141, width: 60, height: 18),
      ]);
      expect(rows, ['VELA FIAT LUX 1 UN x 14,99 14,99', 'TOTAL 14,99']);
    });
  });

  group('reconcile', () {
    test('the candle: R\$ 11,99 on the shelf, R\$ 14,99 at the till', () {
      final cart = [
        _line('l1', 'VELA FIAT LUX N7 C/8UN', 1199),
        _line('l2', 'ABACAXI UNIAO UN', 899),
      ];
      final receipt = parseReceipt([
        '001 VELA FIAT LUX N7 C/8 1 UN x 14,99 14,99',
        '002 ABACAXI UNIAO 1 UN x 8,99 8,99',
        'TOTAL 23,98',
      ]).lines;
      final rec = reconcile(cart, receipt);
      final candle = rec.lines[0];
      expect(candle.matchedLineId, 'l1');
      expect(candle.matchStatus, ReceiptMatch.divergent);
      expect(candle.effectiveUnitCents - announcedUnitCents(cart[0]), 300);
      expect(rec.lines[1].matchStatus, ReceiptMatch.equal);
      expect(rec.announcedCents, 2098);
      expect(rec.chargedCents, 2398);
      expect(rec.differenceCents, 300);
      expect(rec.notOnReceipt, isEmpty);
    });

    test('abbreviated receipt text still pairs; a weak pair is only a suspicion', () {
      final cart = [
        _line('l1', 'PAPEL HIG FD MAX 30M LV12PG11', 1399),
        _line('l2', 'TOALHA PAPEL COQUETEL C/1UN 180F', 899),
      ];
      final receipt = parseReceipt([
        'PAP HIG FD MAX 30M 1 UN x 13,99 13,99',
        'TOALHA COZINHA 1 UN x 9,49 9,49',
      ]).lines;
      final rec = reconcile(cart, receipt);
      expect(rec.lines[0].matchedLineId, 'l1');
      expect(rec.lines[0].matchStatus, ReceiptMatch.equal);
      // one word in common and another price: not enough to claim a difference
      expect(
        rec.lines[1].matchStatus,
        anyOf(ReceiptMatch.suspected, ReceiptMatch.unmatched),
      );
      expect(rec.divergent, isEmpty);
    });

    test('the bar code decides, whatever the text says', () {
      final cart = [_line('l1', 'Biscoito', 499, barcode: '7891962071619')];
      final receipt = parseReceipt([
        '7891962071619 CKS BAUD MAXI 96 1 UN x 5,49 5,49',
      ]).lines;
      final rec = reconcile(cart, receipt);
      expect(rec.lines.single.matchScore, 1);
      expect(rec.lines.single.matchStatus, ReceiptMatch.divergent);
    });

    test('wholesale from 3 units: 3 at the lower price is not a divergence', () {
      final cart = [
        _line(
          'l1',
          'AGUA S/GAS INDAIA PET 5L',
          999,
          qty: 3,
          wholesale: 949,
          wholesaleMin: 3,
        ),
      ];
      final receipt = parseReceipt([
        'AGUA S/GAS INDAIA PET 5L 3 UN x 9,49 28,47',
      ]).lines;
      final rec = reconcile(cart, receipt);
      expect(rec.lines.single.matchStatus, ReceiptMatch.equal);
      expect(lineTotal(cart.single).netCents, 2847);
      // with 2 units the retail price stands, in the cart and in the comparison
      final two = _line(
        'l1',
        'AGUA S/GAS INDAIA PET 5L',
        999,
        qty: 2,
        wholesale: 949,
        wholesaleMin: 3,
      );
      expect(lineTotal(two).netCents, 1998);
      expect(announcedUnitCents(two), 999);
    });

    test('items missing on either side are listed, not forced into pairs', () {
      final cart = [
        _line('l1', 'VELA FIAT LUX', 1199),
        _line('l2', 'SABAO EM PO OMO 1KG', 1890),
      ];
      final receipt = parseReceipt([
        'VELA FIAT LUX 1 UN x 11,99 11,99',
        'SACOLA PLASTICA 1 UN x 0,15 0,15',
      ]).lines;
      final rec = reconcile(cart, receipt);
      expect(rec.notOnReceipt.single.id, 'l2');
      expect(rec.lines[1].matchStatus, ReceiptMatch.unmatched);
      expect(rec.lines[1].matchedLineId, isNull);
    });

    test('a pair confirmed by the user is kept, and reconciling twice gives the same result', () {
      final cart = [
        _line('l1', 'TOALHA PAPEL COQUETEL', 899),
        _line('l2', 'TOALHA DE ROSTO', 1500),
      ];
      var receipt = parseReceipt(['TOALHA 1 UN x 15,00 15,00']).lines;
      receipt = [
        receipt.single.copyWith(
          matchedLineId: 'l2',
          matchStatus: ReceiptMatch.confirmed,
        ),
      ];
      final a = reconcile(cart, receipt);
      final b = reconcile(cart, a.lines);
      expect(a.lines.single.matchedLineId, 'l2');
      expect(a.lines.single.matchStatus, ReceiptMatch.confirmed);
      expect(b.lines.single.matchedLineId, 'l2');
      expect(b.notOnReceipt.single.id, 'l1');
      expect(b.chargedCents, a.chargedCents);
    });
  });

  test('descriptionSimilarity: prefixes count, numbers alone do not', () {
    expect(descriptionSimilarity('PAP HIG FD MAX', 'PAPEL HIG FD MAX 30M'), 1);
    expect(descriptionSimilarity('VELA FIAT LUX', 'ABACAXI UNIAO'), 0);
    expect(descriptionSimilarity('12 30', 'PAPEL 12 30'), 0);
  });
}
