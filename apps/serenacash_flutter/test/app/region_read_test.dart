/// Ocorrência 017 (complemento): marcar uma área da foto da etiqueta e reler só ela. O recorte é
/// feito de verdade sobre uma imagem; a leitura do texto é um dublê, porque o OCR só existe no
/// aparelho.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/ocr/ocr_service.dart';
import 'package:serenacash/data/ocr/region_reader.dart';
import 'package:serenacash/domain/money/money.dart';
import 'package:serenacash/domain/shopping/shopping.dart';
import 'package:serenacash/features/shopping/item_review_screen.dart';
import 'package:serenacash/features/shopping/region_layer.dart';
import 'package:serenacash/features/shopping/scan_result.dart';
import 'package:serenacash/features/shopping/session_screen.dart';
import 'package:serenacash/l10n/app_localizations.dart';

import 'harness.dart';
import 'kv_factory.dart';

final _l = lookupAppLocalizations(const Locale('pt'));

/// A 200×100 picture: left half red, right half blue. Enough to tell which part was cut out.
Future<Uint8List> _twoHalves() async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 100, 100),
    ui.Paint()..color = const ui.Color(0xFFFF0000),
  );
  canvas.drawRect(
    const ui.Rect.fromLTWH(100, 0, 100, 100),
    ui.Paint()..color = const ui.Color(0xFF0000FF),
  );
  final image = await recorder.endRecording().toImage(200, 100);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

Future<({int width, int height, int centre})> _describe(Uint8List png) async {
  final codec = await ui.instantiateImageCodec(png);
  final image = (await codec.getNextFrame()).image;
  final raw = (await image.toByteData())!;
  final o = ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4;
  final r = (
    width: image.width,
    height: image.height,
    centre:
        (raw.getUint8(o) << 16) |
        (raw.getUint8(o + 1) << 8) |
        raw.getUint8(o + 2),
  );
  image.dispose();
  codec.dispose();
  return r;
}

/// Stands in for the OCR of a region: records what was asked and answers with fixed lines.
class _FakeRegionReader implements RegionReader {
  _FakeRegionReader(this.answer);
  List<OcrBox> Function(ui.Rect region) answer;
  final asked = <ui.Rect>[];
  Object? failure;
  @override
  Future<List<OcrBox>> read(Uint8List photo, ui.Rect region) async {
    asked.add(region);
    if (failure != null) throw failure!;
    return answer(region);
  }
}

OcrBox _line(String text, {double top = 0}) =>
    OcrBox(text: text, left: 0, top: top, width: 100, height: 20);

Future<_FakeRegionReader> _openReview(
  WidgetTester tester, {
  required Uint8List photo,
}) async {
  await setPhone(tester);
  final reader = _FakeRegionReader((_) => const []);
  final app = TestApp(
    overrides: [regionReaderProvider.overrideWithValue(reader)],
  );
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
  // A photo on which the engine read nothing useful: exactly when marking an area is needed.
  const page = OcrPage(lines: [], width: 200, height: 100);
  c
      .read(scanResultProvider.notifier)
      .set(
        ScanResult.label(
          analysis: analyzeLabel(page.lines),
          photo: photo,
          page: page,
        ),
      );
  await tester.pumpAndSettle();
  expect(find.byType(ItemReviewScreen), findsOneWidget);
  return reader;
}

Future<void> _mark(WidgetTester tester, Offset from, Offset to) async {
  final box = tester.getRect(find.byType(RegionLayer));
  Offset at(Offset f) =>
      Offset(box.left + box.width * f.dx, box.top + box.height * f.dy);
  final g = await tester.startGesture(at(from));
  await g.moveTo(at(Offset.lerp(from, to, 0.5)!));
  await g.moveTo(at(to));
  await g.up();
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadTestFonts);

  group('017: cutting a region out of the photo', () {
    testWidgets(
      'the cut-out is the marked part, enlarged, and the original is untouched',
      (tester) async {
        await tester.runAsync(() async {
          final photo = await _twoHalves();
          final before = Uint8List.fromList(photo);
          // right half, upper part
          final cut = await cropImage(
            photo,
            const ui.Rect.fromLTRB(0.5, 0, 1, 0.5),
          );
          final d = await _describe(cut);
          expect(d.width, 300, reason: '100 px ampliados 3×');
          expect(d.height, 150);
          expect(d.centre, 0x0000FF, reason: 'a metade azul');
          final left = await _describe(
            await cropImage(photo, const ui.Rect.fromLTRB(0, 0.2, 0.4, 0.8)),
          );
          expect(left.centre, 0xFF0000, reason: 'a metade vermelha');
          expect(photo, before, reason: 'a foto original não muda');
          // values outside the photo are brought to its edges; an empty region is refused
          final all = await _describe(
            await cropImage(photo, const ui.Rect.fromLTRB(-1, -1, 2, 2)),
          );
          expect(all.width / all.height, closeTo(2, 0.02));
          await expectLater(
            cropImage(photo, const ui.Rect.fromLTRB(0.5, 0.5, 0.5, 0.5)),
            throwsArgumentError,
          );
        });
      },
    );

    test('lines come back in reading order', () {
      final ordered = inReadingOrder([
        const OcrBox(text: 'c', left: 0, top: 60, width: 50, height: 20),
        const OcrBox(text: 'b', left: 80, top: 3, width: 50, height: 20),
        const OcrBox(text: 'a', left: 0, top: 0, width: 50, height: 20),
      ]);
      expect(ordered.map((x) => x.text).join(), 'abc');
    });

    test('amounts are found whatever the separator, and never inside a longer number', () {
      expect(pricesIn('R\$ 16,99'), [1699]);
      expect(pricesIn('4 , 99 un'), [499]);
      expect(pricesIn('9.99  9,49 a partir de 3'), [999, 949]);
      expect(pricesIn('7891000100103'), isEmpty);
      expect(pricesIn('Pá para lixo'), isEmpty);
    });

    test(
      'without OCR on the device the reader says so instead of inventing text',
      () async {
        await expectLater(
          const OcrRegionReader(UnavailableOcr())
              .read(Uint8List(0), const ui.Rect.fromLTRB(0, 0, 1, 1)),
          throwsA(isA<OcrUnavailable>()),
        );
      },
    );
  });

  group('017: in the review of the item', () {
    late Uint8List photo;
    setUpAll(() async {
      photo = (await TestWidgetsFlutterBinding.ensureInitialized().runAsync(
        _twoHalves,
      ))!;
    });

    testWidgets('marking an area and reading it fills in the name', (
      tester,
    ) async {
      final reader = await _openReview(tester, photo: photo);
      expect(find.byType(RegionLayer), findsNothing);
      await tester.tap(find.text(_l.regionStart));
      await tester.pumpAndSettle();
      expect(find.byType(RegionLayer), findsOneWidget);
      // nothing marked yet: there is nothing to read
      expect(
        tester
            .widget<TextButton>(
              find.ancestor(
                of: find.text(_l.regionRead),
                matching: find.byType(TextButton),
              ),
            )
            .onPressed,
        isNull,
      );

      await _mark(tester, const Offset(0.1, 0.2), const Offset(0.6, 0.7));
      reader.answer = (_) => [
        _line('NOVIÇA CIPA PLUS', top: 30),
        _line('PÁ PARA LIXO'),
      ];
      await tester.tap(find.text(_l.regionRead));
      await tester.pumpAndSettle();

      final asked = reader.asked.single;
      expect(asked.left, closeTo(0.1, 0.03));
      expect(asked.top, closeTo(0.2, 0.05));
      expect(asked.right, closeTo(0.6, 0.03));
      expect(asked.bottom, closeTo(0.7, 0.05));
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'NOVIÇA CIPA PLUS PÁ PARA LIXO',
        reason: 'na ordem em que o leitor devolveu, já ordenada por ele',
      );
      expect(
        find.byType(RegionLayer),
        findsNothing,
        reason: 'marcação encerrada',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'price: one amount is used; several are offered; none is said plainly',
      (tester) async {
        final reader = await _openReview(tester, photo: photo);
        await tester.tap(find.text(_l.regionStart));
        await tester.pumpAndSettle();
        await tester.tap(find.text(_l.reviewPickPrice));
        await tester.pumpAndSettle();
        await _mark(tester, const Offset(0.5, 0.1), const Offset(0.95, 0.9));

        // no amount in what was read: said, with the text, and nothing is filled in
        reader.answer = (_) => [_line('OFERTA VÁLIDA')];
        await tester.tap(find.text(_l.regionRead));
        await tester.pumpAndSettle();
        expect(find.text(_l.regionNoPrice('OFERTA VÁLIDA')), findsOneWidget);

        // two amounts: the user chooses, the app does not guess
        reader.answer = (_) => [
          _line('R\$ 9,99'),
          _line('ATACADO 9,49', top: 30),
        ];
        await tester.tap(find.text(_l.regionRead));
        await tester.pumpAndSettle();
        expect(find.text(_l.regionManyPrices), findsOneWidget);
        expect(find.text(formatBRL(999)), findsOneWidget);
        expect(find.text(formatBRL(949)), findsOneWidget);
        await tester.tap(find.text(formatBRL(999)));
        await tester.pumpAndSettle();
        expect(find.byType(RegionLayer), findsNothing);
        expect(find.text(_l.regionManyPrices), findsNothing);

        // one amount: used directly
        await tester.tap(find.text(_l.regionStart));
        await tester.pumpAndSettle();
        await _mark(tester, const Offset(0.5, 0.1), const Offset(0.95, 0.9));
        reader.answer = (_) => [_line('16,99')];
        await tester.tap(find.text(_l.regionRead));
        await tester.pumpAndSettle();
        expect(find.byType(RegionLayer), findsNothing);
        expect(reader.asked.length, 3);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'the rectangle can be moved and resized; failures are told and nothing is filled in',
      (tester) async {
        final reader = await _openReview(tester, photo: photo);
        await tester.tap(find.text(_l.regionStart));
        await tester.pumpAndSettle();
        await _mark(tester, const Offset(0.2, 0.2), const Offset(0.5, 0.6));
        // drag the bottom-right corner outwards, then the inside to the right
        await _mark(tester, const Offset(0.5, 0.6), const Offset(0.7, 0.8));
        await _mark(tester, const Offset(0.4, 0.5), const Offset(0.6, 0.5));
        reader.failure = const OcrUnavailable();
        await tester.tap(find.text(_l.regionRead));
        await tester.pumpAndSettle();
        final r = reader.asked.single;
        expect(r.left, closeTo(0.4, 0.04), reason: 'movido 0,2 para a direita');
        expect(r.right, closeTo(0.9, 0.04));
        expect(r.top, closeTo(0.2, 0.06));
        expect(r.bottom, closeTo(0.8, 0.06));
        expect(find.text(_l.regionUnavailable), findsOneWidget);

        reader.failure = StateError('x');
        await tester.tap(find.text(_l.regionRead));
        await tester.pumpAndSettle();
        expect(find.text(_l.regionFailed), findsOneWidget);

        reader.failure = null;
        reader.answer = (_) => const [];
        await tester.tap(find.text(_l.regionRead));
        await tester.pumpAndSettle();
        expect(find.text(_l.regionNothingRead), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          isEmpty,
        );

        await tester.tap(find.text(_l.regionStop));
        await tester.pumpAndSettle();
        expect(find.byType(RegionLayer), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
