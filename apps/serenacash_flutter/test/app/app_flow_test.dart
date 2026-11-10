import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/database/drift_ledger_repository.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/features/home/home_parts.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/features/onboarding/onboarding_screen.dart';
import 'package:serenacash/features/transactions/transaction_form_screen.dart';
import 'package:serenacash/features/transactions/transactions_screen.dart';
import 'package:serenacash/ui/components/components.dart';

import 'harness.dart';
import 'kv_factory.dart';

void main() {
  setUpAll(loadTestFonts);

  testWidgets(
    'first run: onboarding → account → home with "pode gastar"; new expense appears in the list',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await pumpApp(tester, app);

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Saiba quanto você pode gastar.'), findsOneWidget);
      await screenshot(tester, 'onboarding_welcome_light');

      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      expect(find.text('Quanto você tem agora?'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).last,
        '250000',
      ); // R$ 2.500,00
      await tester.pumpAndSettle();
      expect(find.text('2.500,00'), findsOneWidget);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Contas fixas deste mês'), findsOneWidget);
      await tester.tap(find.text('Aluguel'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '120000');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Você usa cartão de crédito?'), findsOneWidget);
      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Pode gastar neste mês'), findsOneWidget);
      // R$ 2.500 − R$ 1.200 planned rent = R$ 1.300 available (hero shows integer part + cents separately)
      expect(find.textContaining('1.300'), findsWidgets);
      await screenshot(tester, 'home_light');

      // new expense through the FAB
      await addEntry(tester);
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, '0,00').first,
        '4590',
      );
      await tester.enterText(find.byType(TextField).at(1), 'Mercado');
      await tester.pumpAndSettle();
      await screenshot(tester, 'transaction_form_light');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // transactions tab lists it under the current month
      await tester.tap(find.text('Lançamentos'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionsScreen), findsOneWidget);
      expect(find.text('Mercado'), findsOneWidget);
      await screenshot(tester, 'transactions_light');

      // dark theme via settings
      await openMenu(tester);
      await screenshot(tester, 'menu_light');
      await tapMenuRow(tester, 'Configurações');
      await tester.tap(find.text('Escuro'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.dark,
      );
      await screenshot(tester, 'settings_dark');
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      await screenshot(tester, 'home_dark');
    },
  );

  testWidgets(
    'all 24 widgets render on the home screen with the complete preset',
    (tester) async {
      await setPhone(tester, scale: 1);
      tester.view.physicalSize = const Size(390, 4200);
      final app = TestApp();
      addTearDown(app.dispose);
      // Pre-seed: onboarded + complete preset so the home shows everything.
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await app.db.into(app.db.kv).insert(KvCompanionFactory.completeLayout());
      await pumpApp(tester, app);
      expect(find.byType(HomeScreen), findsOneWidget);
      // No data yet: the summary asks for the first account and every section with nothing to show
      // is a single line; the others keep their title.
      final texts = [
        'Configure seu saldo', // Pode gastar
        'Nenhuma conta', // Saldo total, Saldos por conta
        'Receitas',
        'Despesas',
        'Nenhuma conta prevista', // Contas a pagar
        'Contas atrasadas',
        'Próximos 7 dias',
        'Adicione seu primeiro cartão', // Cartões e faturas
        'Compras parceladas',
        'Sem orçamento ainda', // Orçamento do mês
        'Nenhum gasto neste período', // Gastos por categoria
        'Evolução',
        'Nenhuma meta criada', // Metas
        'Reservas',
        'Economia do mês',
        'Assinaturas e recorrentes',
        'Nenhum empréstimo', // Empréstimos
        'Calendário',
        'Nenhum lançamento ainda', // Últimos lançamentos
        'Sugestões',
        'Listas de compras',
        'Assistente de supermercado',
        'Indicadores avançados',
      ];
      for (final t in texts) {
        expect(find.textContaining(t), findsWidgets, reason: t);
      }
      // 24 widgets: the summary panel plus 23 cards.
      expect(find.byType(SummaryPanel), findsOneWidget);
      expect(find.byType(SCard), findsAtLeast(23));
      await screenshot(tester, 'home_complete_light');
    },
  );

  testWidgets('privacy mode hides every amount', (tester) async {
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
        openingBalanceCents: 123456,
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
    expect(find.textContaining('1.234,56'), findsWidgets);
    await tester.tap(find.byTooltip('Ocultar valores'));
    await tester.pumpAndSettle();
    expect(find.textContaining('••••'), findsWidgets);
    expect(find.byTooltip('Mostrar valores'), findsOneWidget);
  });
}
