/// Ocorrência 018 (complemento): consulta opcional a um catálogo aberto pelo código de barras.
/// Desligada por padrão; ligada, só o número do código é enviado e o que volta é uma sugestão de
/// nome para conferir. "Não encontrado" e "não foi possível consultar" são estados diferentes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/data/catalog/product_catalog.dart';
import 'package:serenacash/domain/shopping/shopping.dart';
import 'package:serenacash/features/shopping/item_review_screen.dart';
import 'package:serenacash/features/shopping/scan_result.dart';
import 'package:serenacash/features/shopping/session_screen.dart';
import 'package:serenacash/l10n/app_localizations.dart';

import 'harness.dart';
import 'kv_factory.dart';

final _l = lookupAppLocalizations(const Locale('pt'));

class _FakeCatalog implements ProductCatalog {
  CatalogLookup answer = const CatalogLookup.notFound();
  final asked = <String>[];
  @override
  String get sourceName => 'Catálogo de teste';
  @override
  Future<CatalogLookup> lookup(String gtin) async {
    asked.add(gtin);
    return answer;
  }
}

Future<(ProviderContainer, _FakeCatalog)> _startPurchase(
  WidgetTester tester,
) async {
  await setPhone(tester);
  final catalog = _FakeCatalog();
  final app = TestApp(
    overrides: [productCatalogProvider.overrideWithValue(catalog)],
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
  return (c, catalog);
}

Future<void> _scan(
  WidgetTester tester,
  ProviderContainer c,
  String code,
) async {
  c
      .read(scanResultProvider.notifier)
      .set(ScanResult.barcode(parseBarcode(code)));
  await tester.pumpAndSettle();
  expect(find.byType(ItemReviewScreen), findsOneWidget);
}

String _name(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller!.text;

Future<void> _cancel(WidgetTester tester) async {
  await tester.tap(find.text('Cancelar'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadTestFonts);

  group('018: reading the answer of the catalogue', () {
    test('a product found gives name, brand and size; the Portuguese name is preferred', () {
      final r = parseOpenFoodFacts(
        '{"code":"3017620422003","product":{"brands":"Ferrero, Nutella",'
        '"generic_name":"Hazelnut spread","product_name":"Nutella",'
        '"product_name_pt":"","quantity":"400 g e"},"status":1}',
      );
      expect(r.status, CatalogStatus.found);
      expect(r.product!.name, 'Nutella');
      expect(r.product!.brand, 'Ferrero');
      expect(r.product!.quantity, '400 g');
      expect(r.product!.suggestedName, 'Nutella 400 g');
      final pt = parseOpenFoodFacts(
        '{"product":{"product_name":"Rice","product_name_pt":"  Arroz   tipo 1 5 kg ",'
        '"quantity":"5 kg"},"status":1}',
      );
      expect(pt.product!.name, 'Arroz tipo 1 5 kg');
      expect(
        pt.product!.suggestedName,
        'Arroz tipo 1 5 kg',
        reason: 'o tamanho já está no nome: não repete',
      );
    });

    test('not found, no usable name and malformed answers are told apart and never throw', () {
      expect(
        parseOpenFoodFacts('{"code":"1","status":0}').status,
        CatalogStatus.notFound,
      );
      expect(
        parseOpenFoodFacts('{"product":{"product_name":"  "},"status":1}')
            .status,
        CatalogStatus.notFound,
      );
      expect(
        parseOpenFoodFacts('{"product":"x","status":1}').status,
        CatalogStatus.notFound,
      );
      expect(
        parseOpenFoodFacts('<html>erro</html>').status,
        CatalogStatus.failed,
      );
      expect(parseOpenFoodFacts('[]').status, CatalogStatus.failed);
      expect(parseOpenFoodFacts('').status, CatalogStatus.failed);
      // a field of the wrong type is ignored, not trusted
      final odd = parseOpenFoodFacts(
        '{"product":{"product_name":"Café","brands":42,"quantity":["x"]},"status":1}',
      );
      expect(odd.product!.name, 'Café');
      expect(odd.product!.brand, isNull);
      expect(odd.product!.quantity, isNull);
      // an absurdly long text is cut
      final long = parseOpenFoodFacts(
        '{"product":{"product_name":"${'a' * 500}"},"status":1}',
      );
      expect(long.product!.name.length, 120);
    });

    test('only digits of a product code are ever sent', () async {
      expect(isLookupCode('7891000100103'), isTrue);
      expect(isLookupCode('12345670'), isTrue);
      expect(isLookupCode('012345678905'), isTrue);
      expect(isLookupCode('123'), isFalse);
      expect(isLookupCode('789100010010A'), isFalse);
      expect(isLookupCode('7891000100103/../x'), isFalse);
      expect(isLookupCode('https://exemplo.com'), isFalse);
      expect(isLookupCode(''), isFalse);
      // a code that is not one is answered without any request being made
      final r = await OpenFoodFactsCatalog().lookup('../../etc');
      expect(r.status, CatalogStatus.notFound);
    });
  });

  group('018: in the purchase', () {
    testWidgets(
      'off by default: nothing is asked, and the user is told the option exists',
      (tester) async {
        final (c, catalog) = await _startPurchase(tester);
        expect(c.read(prefsProvider).productLookup, isFalse);
        await _scan(tester, c, '7891000100103');
        expect(catalog.asked, isEmpty, reason: 'sem consentimento, nada sai');
        expect(_name(tester), isEmpty);
        expect(
          find.text(_l.codeDecodedUnknown('7891000100103')),
          findsOneWidget,
        );
        expect(find.text(_l.catalogOffHint), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'on: found suggests a name to confirm; not found and failure say so; a known code is not asked again',
      (tester) async {
        final (c, catalog) = await _startPurchase(tester);
        await c
            .read(appControllerProvider.notifier)
            .setPrefs((p) => p.copyWith(productLookup: true));
        await tester.pumpAndSettle();

        catalog.answer = const CatalogLookup.failed();
        await _scan(tester, c, '7891000100103');
        expect(catalog.asked, ['7891000100103']);
        expect(_name(tester), isEmpty);
        expect(
          find.text(_l.catalogFailed('Catálogo de teste')),
          findsOneWidget,
        );
        await _cancel(tester);

        catalog.answer = const CatalogLookup.notFound();
        await _scan(tester, c, '7891000100103');
        expect(
          find.text(_l.catalogNotFound('Catálogo de teste')),
          findsOneWidget,
        );
        await _cancel(tester);

        catalog.answer = const CatalogLookup.found(
          CatalogProduct(
            name: 'Leite integral',
            brand: 'Marca',
            quantity: '1 L',
          ),
        );
        await _scan(tester, c, '7891000100103');
        expect(_name(tester), 'Leite integral 1 L');
        expect(find.text(_l.catalogFound('Catálogo de teste')), findsOneWidget);
        // it is a suggestion: without a price nothing can be added yet
        expect(
          tester
              .widget<TextButton>(
                find.ancestor(
                  of: find.text('Adicionar ao carrinho'),
                  matching: find.byType(TextButton),
                ),
              )
              .onPressed,
          isNull,
        );
        // the user corrects the name, gives the price and confirms: the product is theirs now
        await tester.enterText(
          find.byType(TextField).first,
          'Leite integral 1 L caixa',
        );
        await tester.scrollUntilVisible(
          find.widgetWithText(TextField, '0,00'),
          160,
          scrollable: find
              .descendant(
                of: find.byType(ItemReviewScreen),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.enterText(find.widgetWithText(TextField, '0,00'), '599');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Adicionar ao carrinho'));
        await tester.pumpAndSettle();
        final products = c.read(appControllerProvider).requireValue.products;
        expect(products.single.name, 'Leite integral 1 L caixa');
        expect(products.single.barcode, '7891000100103');

        // the same code again: found in the device, the catalogue is not asked
        final before = catalog.asked.length;
        await _scan(tester, c, '7891000100103');
        expect(catalog.asked.length, before);
        expect(find.text(_l.codeFound('7891000100103')), findsOneWidget);
        expect(_name(tester), 'Leite integral 1 L caixa');
        await _cancel(tester);

        // a code that does not close as a product code is never sent
        await _scan(tester, c, '7891000100104');
        expect(catalog.asked.length, before);
        expect(find.text(_l.codeNotStandard('7891000100104')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
