import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/features/annual/annual_screen.dart';
import 'package:serenacash/features/history/history_screen.dart';
import 'package:serenacash/features/shopping/list_screens.dart';
import 'package:serenacash/features/shopping/scan_result.dart';
import 'package:serenacash/features/shopping/session_screen.dart';
import 'package:serenacash/domain/shopping/shopping.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serenacash/data/database/drift_ledger_repository.dart';
import 'package:serenacash/domain/entities/entities.dart';

import 'harness.dart';
import 'kv_factory.dart';

void main() {
  setUpAll(loadTestFonts);

  testWidgets(
    'shopping: create list, add items with estimate, start session, add manually, finish and register expense',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await DriftLedgerRepository(app.db).upsertAccount(
        const Account(
          id: 'a1',
          name: 'Conta',
          type: 'checking',
          currency: 'BRL',
          openingBalanceCents: 100000,
          openingDate: '2026-01-01',
          color: '#0B5563',
          archived: false,
          includeInAvailability: true,
          sortOrder: 0,
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
        ),
      );
      await pumpApp(tester, app);

      await tester.tap(find.text('Compras'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criar lista'));
      await tester.pumpAndSettle();
      expect(find.byType(ListFormScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Compra do mês');
      await tester.enterText(find.byType(TextField).at(1), 'Mercado Bom');
      await tester.enterText(find.byType(TextField).at(2), '30000');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criar'));
      await tester.pumpAndSettle();
      expect(find.byType(ListDetailScreen), findsOneWidget);

      // add "Arroz" with a price of R$ 24,90 → estimate R$ 24,90
      await tester.enterText(
        find.widgetWithText(TextField, 'Ex.: Arroz 5kg').first,
        'Arroz',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Categoria e preço estimado'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, '0,00').last,
        '2490',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(TextButton, 'Adicionar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Adicionar'));
      await tester.pumpAndSettle();
      expect(find.text('Arroz'), findsOneWidget);
      expect(find.textContaining('24,90'), findsWidgets);
      await screenshot(tester, 'shopping_list_light');

      // start the session from the list
      await tester.scrollUntilVisible(
        find.text('Iniciar compra com esta lista'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Iniciar compra com esta lista'));
      await tester.pumpAndSettle();
      expect(find.byType(SessionScreen), findsOneWidget);
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      expect(find.text('Total do carrinho'), findsOneWidget);
      // the list item with price can be added with one tap
      await tester.tap(find.textContaining('Arroz · 1 un'));
      await tester.pumpAndSettle();
      expect(find.textContaining('24,90'), findsWidgets);
      expect(find.textContaining('Ainda cabe'), findsOneWidget);

      // manual item: weighed, R$ 6,99/kg × 1,5 kg = R$ 10,49 (half-up)
      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();
      expect(find.text('Confirmar item'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome do produto').first,
        'Banana',
      );
      await tester.tap(find.text('kg'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, '0,00').first,
        '699',
      );
      await tester.enterText(find.widgetWithText(TextField, '1').first, '1,5');
      await tester.pumpAndSettle();
      expect(find.textContaining('10,49'), findsOneWidget);
      await screenshot(tester, 'shopping_confirm_light');
      await tester.ensureVisible(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      expect(find.textContaining('35,39'), findsWidgets); // 24,90 + 10,49
      await screenshot(tester, 'shopping_session_light');

      // finishing asks first; cancelling keeps the cart open
      await tester.tap(find.text('Finalizar compra'));
      await tester.pumpAndSettle();
      expect(find.text('Finalizar a compra?'), findsOneWidget);
      expect(find.textContaining('ficará de fora'), findsNothing);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Resumo'), findsNothing);

      // with an item still in the confirmation panel, the sheet warns it will be left out
      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();
      expect(find.text('Confirmar item'), findsOneWidget);
      await tester.ensureVisible(find.text('Finalizar compra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finalizar compra'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ficará de fora'), findsOneWidget);

      // finish → summary → register expense (idempotent)
      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();
      expect(find.text('Resumo'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('como despesa'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.textContaining('como despesa'));
      await tester.pumpAndSettle();
      expect(find.text('Despesa registrada nas finanças.'), findsOneWidget);
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
      expect(find.byType(ListDetailScreen), findsOneWidget);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lançamentos'));
      await tester.pumpAndSettle();
      expect(find.text('Compras em Mercado Bom'), findsOneWidget);
    },
  );

  testWidgets(
    'scan result from a barcode opens the confirmation sheet with the product name',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await pumpApp(tester, app);
      await tester.tap(find.text('Compras'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar compra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SessionScreen)),
      );
      container
          .read(scanResultProvider.notifier)
          .set(ScanResult.barcode(parseBarcode('7891000100103')));
      await tester.pumpAndSettle();
      expect(find.text('Confirmar item'), findsOneWidget);
      expect(
        find.text('Produto novo: informe o nome e o preço da etiqueta.'),
        findsOneWidget,
      );
      container
          .read(scanResultProvider.notifier)
          .set(
            ScanResult.label(
              parsePriceTag(const [
                OCRLine(text: 'LEITE INTEGRAL 1L', height: 16),
                OCRLine(text: 'R\$ 5,49', height: 44),
              ]),
            ),
          );
      await tester.pumpAndSettle();
      expect(find.textContaining('Confiança da leitura'), findsOneWidget);
    },
  );

  testWidgets('history and annual planning screens render', (tester) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
    await pumpApp(tester, app);
    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Histórico de alterações'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Histórico de alterações'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.textContaining('Categoria · salvo'), findsWidgets);
    await screenshot(tester, 'history_light');
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Planejar'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Planejamento anual'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Ver').last);
    await tester.pumpAndSettle();
    expect(find.byType(AnnualScreen), findsOneWidget);
    await screenshot(tester, 'annual_light');
  });
}
