/// Ocorrências 015 a 020 e 023 no fluxo real: leitura de etiqueta com candidatos, conferência
/// obrigatória de leitura duvidosa, apontar nome e preço na foto, código lido sem cadastro, fotos
/// guardadas como evidência e comparação com o cupom.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/data/ocr/ocr_service.dart';
import 'package:serenacash/domain/shopping/shopping.dart';
import 'package:serenacash/features/shopping/item_review_screen.dart';
import 'package:serenacash/features/shopping/receipt_screen.dart';
import 'package:serenacash/features/shopping/scan_result.dart';
import 'package:serenacash/features/shopping/session_screen.dart';
import 'package:serenacash/features/shopping/voice_sheet.dart';

import 'harness.dart';
import 'kv_factory.dart';

/// A valid 1×1 PNG, standing in for the photo of a label.
final Uint8List _photo = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

OcrPage _page(String name) {
  final j = jsonDecode(
    File('test/fixtures/labels/$name.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return OcrPage(
    width: j['width'] as int,
    height: j['height'] as int,
    lines: [
      for (final l in j['lines'] as List)
        OcrBox.fromJson(l as Map<String, dynamic>),
    ],
  );
}

ScanResult _label(String name) {
  final page = _page(name);
  return ScanResult.label(
    analysis: analyzeLabel(page.lines),
    photo: _photo,
    page: page,
  );
}

Future<(TestApp, ProviderContainer)> _startPurchase(WidgetTester tester) async {
  await setPhone(tester);
  final app = TestApp();
  addTearDown(app.dispose);
  await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
  await pumpApp(tester, app);
  await tester.tap(find.text('Compras'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Iniciar compra'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, 'teste');
  await tester.tap(find.text('Começar'));
  await tester.pumpAndSettle();
  final c = ProviderScope.containerOf(
    tester.element(find.byType(SessionScreen)),
  );
  return (app, c);
}

Future<void> _scan(
  WidgetTester tester,
  ProviderContainer c,
  ScanResult r,
) async {
  c.read(scanResultProvider.notifier).set(r);
  await tester.pumpAndSettle();
  expect(find.byType(ItemReviewScreen), findsOneWidget);
}

bool _enabled(WidgetTester tester, String label) =>
    tester
        .widget<TextButton>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(TextButton),
          ),
        )
        .onPressed !=
    null;

/// The review is a lazy list: what is further down exists only after scrolling to it.
Future<void> _show(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    160,
    scrollable: find
        .descendant(
          of: find.byType(ItemReviewScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadTestFonts);

  testWidgets(
    '016: retail goes to the cart; wholesale only from its minimum; the photo is kept',
    (tester) async {
      final (app, c) = await _startPurchase(tester);
      await _scan(tester, c, _label('etiqueta-agua-999-949'));

      expect(find.text('AGUA S/GAS INDAIA PET EL'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, '0,00'))
            .controller!
            .text,
        '9,99',
      );
      await _show(tester, find.textContaining('Varejo R\$'));
      expect(find.textContaining('Varejo R\$'), findsOneWidget);
      expect(find.textContaining('Por litro'), findsWidgets);
      final wholesale = find.textContaining('a partir de 3 un');
      await _show(tester, wholesale);
      expect(wholesale, findsOneWidget);
      expect(find.textContaining('Subtotal'), findsOneWidget);
      expect(find.textContaining('9,99'), findsWidgets);

      // one bottle, then three with the wholesale condition accepted
      await tester.tap(wholesale);
      await tester.pumpAndSettle();
      expect(find.textContaining('9,99', findRichText: true), findsWidgets);
      await _show(tester, find.text('+'));
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      expect(find.textContaining('19,98'), findsOneWidget); // 2 × retail
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      expect(find.textContaining('28,47'), findsOneWidget); // 3 × wholesale

      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      final line = c
          .read(appControllerProvider)
          .requireValue
          .sessions
          .single
          .lines
          .single;
      expect(line.unitPriceCents, 999);
      expect(line.advertisedPriceCents, 999);
      expect(line.wholesalePriceCents, 949);
      expect(line.wholesaleMinQuantity, 3);
      expect(lineTotal(line).netCents, 2847);

      final ev = await app.db.select(app.db.shoppingEvidence).getSingle();
      expect(ev.role, 'label');
      expect(ev.lineId, line.id);
      expect(ev.data, _photo);
      expect(ev.sha256.length, 64);
      expect(ev.width, 960);
      expect(ev.ocrJson, contains('INDAIA'));
      // the photo never goes to the change log or to any plain table
      final log = await app.db.select(app.db.changeLogEntries).get();
      expect(log.where((e) => (e.payload ?? '').contains('iVBOR')), isEmpty);
    },
  );

  testWidgets(
    '016: a doubtful price cannot be added without being checked or corrected',
    (tester) async {
      final (_, c) = await _startPurchase(tester);
      await _scan(tester, c, _label('etiqueta-vela-1199'));

      expect(find.text('VELA FIAT LUX N7 (BLN'), findsOneWidget);
      expect(find.textContaining('confira na foto'), findsOneWidget);
      expect(find.textContaining('Revisão necessária'), findsOneWidget);
      expect(_enabled(tester, 'Adicionar ao carrinho'), isFalse);
      // the small print amount is shown as what it is and offered as nothing
      await _show(tester, find.textContaining('Valor em letras pequenas'));
      expect(find.textContaining('Valor em letras pequenas'), findsOneWidget);

      // the user reads R$ 11,99 on the photo and types it
      await tester.enterText(find.widgetWithText(TextField, '0,00'), '1199');
      await tester.pumpAndSettle();
      expect(_enabled(tester, 'Adicionar ao carrinho'), isTrue);
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      final line = c
          .read(appControllerProvider)
          .requireValue
          .sessions
          .single
          .lines
          .single;
      expect(line.unitPriceCents, 1199);
      expect(line.priceSource, 'manual');
      // what the engine read stays on record next to what the user confirmed
      expect(line.advertisedPriceCents, 199);
    },
  );

  testWidgets(
    '016: standing by a flagged price takes an explicit confirmation',
    (tester) async {
      final (_, c) = await _startPurchase(tester);
      await _scan(tester, c, _label('etiqueta-cookies-499'));
      expect(_enabled(tester, 'Adicionar ao carrinho'), isFalse);
      final check = find.text('Conferi o preço com a foto');
      await _show(tester, check);
      await tester.tap(check);
      await tester.pumpAndSettle();
      expect(_enabled(tester, 'Adicionar ao carrinho'), isTrue);
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      final line = c
          .read(appControllerProvider)
          .requireValue
          .sessions
          .single
          .lines
          .single;
      expect(line.unitPriceCents, 499);
      expect(line.priceSource, 'label_ocr');
    },
  );

  testWidgets('015/017: name and price are picked by touching the photo', (
    tester,
  ) async {
    final (_, c) = await _startPurchase(tester);
    await _scan(tester, c, _label('etiqueta-abacaxi-899'));

    // the description printed on the label, never the slogan above it
    final nameField = tester.widget<TextField>(find.byType(TextField).first);
    expect(nameField.controller!.text, 'ABACAXI UNIAO UN');
    expect(
      find.text('Tudo fresquinho da horta'),
      findsOneWidget,
    ); // offered as an alternative

    // touching another text of the photo in "Nome" mode adds it; touching again removes it
    final slogan = find.bySemanticsLabel('Tudo fresquinho da horta').first;
    await tester.tap(slogan);
    await tester.pumpAndSettle();
    expect(
      nameField.controller!.text,
      'Tudo fresquinho da horta ABACAXI UNIAO UN',
    );
    await tester.tap(slogan);
    await tester.pumpAndSettle();
    expect(nameField.controller!.text, 'ABACAXI UNIAO UN');

    // "Preço" mode: a text without an amount explains itself; the amount sets the price
    await tester.tap(find.text('Preço'));
    await tester.pumpAndSettle();
    await tester.tap(slogan);
    await tester.pumpAndSettle();
    expect(find.textContaining('não tem um preço'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('8,99').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('não tem um preço'), findsNothing);
    await _show(tester, find.widgetWithText(TextField, '0,00'));
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, '0,00'))
          .controller!
          .text,
      '8,99',
    );
    await tester.tap(find.text('Adicionar ao carrinho'));
    await tester.pumpAndSettle();
    final line = c
        .read(appControllerProvider)
        .requireValue
        .sessions
        .single
        .lines
        .single;
    expect(line.name, 'ABACAXI UNIAO UN');
    expect(line.unitPriceCents, 899);
  });

  testWidgets(
    '018: a code that was read and is not in the catalog is not called a failure, and is kept',
    (tester) async {
      final (_, c) = await _startPurchase(tester);
      await _scan(tester, c, ScanResult.barcode(parseBarcode('7891000100103')));
      expect(find.textContaining('Código 7891000100103 lido'), findsOneWidget);
      expect(find.textContaining('inválido'), findsNothing);
      expect(find.textContaining('falh'), findsNothing);
      await tester.enterText(
        find.byType(TextField).first,
        'Leite integral 1 L',
      );
      await tester.enterText(find.widgetWithText(TextField, '0,00'), '549');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      final s = c.read(appControllerProvider).requireValue;
      expect(s.products.single.barcode, '7891000100103');
      expect(s.products.single.name, 'Leite integral 1 L');

      // the same code again: now it is a product this device knows
      await _scan(tester, c, ScanResult.barcode(parseBarcode('7891000100103')));
      expect(find.textContaining('Produto do seu cadastro'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Leite integral 1 L',
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // a code that does not close as EAN/UPC is still handed over, as read
      await _scan(tester, c, ScanResult.barcode(parseBarcode('7891000100109')));
      expect(
        find.textContaining('não fecha como código de produto padrão'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '014: a photo with nothing legible still reaches the review, attached',
    (tester) async {
      final (app, c) = await _startPurchase(tester);
      await _scan(tester, c, ScanResult.label(photo: _photo));
      expect(find.textContaining('Nada foi lido na foto'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Sabão em pó');
      await tester.enterText(find.widgetWithText(TextField, '0,00'), '1890');
      await tester.pumpAndSettle();
      // from the scanner: the next reading is one tap away
      expect(find.text('Adicionar e ler a próxima'), findsOneWidget);
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      expect(await app.db.select(app.db.shoppingEvidence).get(), hasLength(1));
    },
  );

  testWidgets(
    '020: the receipt screen shows shelf price against charged price',
    (tester) async {
      final (app, c) = await _startPurchase(tester);
      await _scan(tester, c, _label('etiqueta-vela-1199'));
      await _show(tester, find.widgetWithText(TextField, '0,00'));
      await tester.enterText(find.widgetWithText(TextField, '0,00'), '1199');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      await _scan(tester, c, _label('etiqueta-abacaxi-899'));
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finalizar compra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();

      final ctl = c.read(appControllerProvider.notifier);
      final session = c
          .read(appControllerProvider)
          .requireValue
          .sessions
          .single;
      final reading = parseReceipt([
        '001 VELA FIAT LUX N7 C/8 1 UN x 14,99 14,99',
        '002 ABACAXI UNIAO 1 UN x 8,99 8,99',
        '003 SACOLA PLASTICA 1 UN x 0,15 0,15',
        'TOTAL 24,13',
      ], newId: ctl.newId);
      await ctl.saveReceiptLines(
        session.id,
        reconcile(session.lines, reading.lines).lines,
      );

      await tester.scrollUntilVisible(
        find.text('Conferir com o cupom fiscal'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Evidências (2)'), findsOneWidget);
      await tester.tap(find.text('Conferir com o cupom fiscal'));
      await tester.pumpAndSettle();
      expect(find.byType(ReceiptScreen), findsOneWidget);
      expect(find.textContaining('Cobrado R\$'), findsOneWidget);
      expect(find.textContaining('3,00 a mais'), findsWidgets);
      expect(find.text('Preço igual ao anunciado'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Sem par no carrinho'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Sem par no carrinho'), findsOneWidget);

      // nothing in the cart was rewritten by the comparison
      final after = c.read(appControllerProvider).requireValue.sessions.single;
      expect(after.lines.map((l) => l.unitPriceCents), [1199, 899]);
      expect(
        await app.db.select(app.db.shoppingReceiptLines).get(),
        hasLength(3),
      );
    },
  );

  testWidgets(
    '022: a dictated item asks what the amount means and still goes through the review',
    (tester) async {
      await setPhone(tester);
      final voice = _FakeVoice(['5 kg de', '5 kg de arroz, 29 reais']);
      final app = TestApp(
        overrides: [voiceInputProvider.overrideWithValue(voice)],
      );
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await pumpApp(tester, app);
      await tester.tap(find.text('Compras'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar compra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(SessionScreen)),
      );

      await tester.tap(find.text('Falar o item'));
      await tester.pumpAndSettle();
      // the microphone only opens after the user is told what happens with the speech
      expect(find.textContaining('não grava nem guarda áudio'), findsOneWidget);
      expect(voice.listening, isFalse);
      await tester.tap(find.text('Falar'));
      await tester.pumpAndSettle();
      expect(find.text('5 kg de arroz, 29 reais'), findsOneWidget);
      expect(
        find.textContaining('é o total ou o preço de cada unidade'),
        findsOneWidget,
      );
      // nothing is in the cart yet
      expect(
        c.read(appControllerProvider).requireValue.sessions.single.lines,
        isEmpty,
      );

      await tester.tap(find.textContaining('É o total'));
      await tester.pumpAndSettle();
      expect(find.byType(ItemReviewScreen), findsOneWidget);
      expect(
        find.textContaining('Ditado: "5 kg de arroz, 29 reais"'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Arroz',
      );
      expect(
        find.textContaining('29,00'),
        findsOneWidget,
      ); // subtotal = the total that was said
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      final line = c
          .read(appControllerProvider)
          .requireValue
          .sessions
          .single
          .lines
          .single;
      expect(line.name, 'Arroz');
      expect(line.unit, 'kg');
      expect(line.quantity, 5);
      expect(line.unitPriceCents, 580);
      expect(lineTotal(line).netCents, 2900);
      expect(voice.stopped, isTrue, reason: 'o microfone é liberado ao fechar');
    },
  );

  testWidgets(
    '022: without a microphone the sheet says so and nothing breaks',
    (tester) async {
      await setPhone(tester);
      final app = TestApp(
        overrides: [
          voiceInputProvider.overrideWithValue(
            _FakeVoice(const [], available: false),
          ),
        ],
      );
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await pumpApp(tester, app);
      await tester.tap(find.text('Compras'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar compra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Falar o item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Falar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('não está disponível'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.byType(SessionScreen), findsOneWidget);
    },
  );
}

class _FakeVoice implements VoiceInput {
  _FakeVoice(this.phrases, {this.available = true});
  final List<String> phrases;
  final bool available;
  bool listening = false, stopped = false;
  @override
  Future<bool> prepare() async => available;
  @override
  Future<void> listen(void Function(String text, bool isFinal) onText) async {
    listening = true;
    for (var i = 0; i < phrases.length; i++) {
      onText(phrases[i], i == phrases.length - 1);
    }
  }

  @override
  Future<void> stop() async {
    listening = false;
    stopped = true;
  }
}
