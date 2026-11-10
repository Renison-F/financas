/// Home screen: first access, account without movements, and with data. The demo data below exists only
/// in this test, on an in-memory database; nothing here ships in the app or touches real storage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/app.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/state/app_state.dart';
import 'package:serenacash/domain/dates/dates.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/features/home/customize_screen.dart';
import 'package:serenacash/features/home/home_parts.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/features/transactions/transaction_form_screen.dart';
import 'package:serenacash/ui/components/components.dart';

import 'harness.dart';
import 'kv_factory.dart';

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SerenaCashApp)));

/// Demo ledger shaped like the reference mockup: R$ 5.480,50 in accounts, R$ 3.140,00 committed
/// (bills 1.290,00 + card invoice 850,00 + reserve 1.000,00), so "pode gastar" is R$ 2.340,50.
Future<void> seedDemo(WidgetTester tester) async {
  final c = _container(tester);
  final ctl = c.read(appControllerProvider.notifier);
  final today = c.read(todayProvider);
  await tester.runAsync(() async {
    final main = await ctl.saveAccount(
      name: 'Conta corrente',
      type: 'checking',
      openingBalanceCents: 0,
      openingDate: addDays(today, -10),
    );
    await ctl.saveAccount(
      name: 'Carteira',
      type: 'cash',
      openingBalanceCents: 0,
      openingDate: addDays(today, -10),
    );
    final ledger = c.read(ledgerProvider);
    String? cat(String name) =>
        ledger.categories.where((k) => k.name == name).firstOrNull?.id;
    final card = await ctl.saveCard(
      name: 'Cartão principal',
      limitCents: 500000,
      closingDay: 28,
      dueDay: 5,
    );
    await ctl.saveTransaction(
      TransactionInput(
        kind: TransactionKind.income,
        amountCents: 820000,
        date: addDays(today, -1),
        description: 'Salário',
        accountId: main.id,
        categoryId: cat('Salário'),
      ),
    );
    await ctl.saveTransaction(
      TransactionInput(
        kind: TransactionKind.expense,
        amountCents: 253310,
        date: addDays(today, -2),
        description: 'Compras do mês',
        accountId: main.id,
        categoryId: cat('Compras'),
      ),
    );
    await ctl.saveTransaction(
      TransactionInput(
        kind: TransactionKind.expense,
        amountCents: 18640,
        date: today,
        description: 'Supermercado',
        accountId: main.id,
        categoryId: cat('Alimentação'),
      ),
    );
    await ctl.saveTransaction(
      TransactionInput(
        kind: TransactionKind.cardPurchase,
        amountCents: 85000,
        date: today,
        description: 'Eletrônicos',
        cardId: card.id,
        categoryId: cat('Compras'),
      ),
    );
    await ctl.saveTransaction(
      TransactionInput(
        kind: TransactionKind.expense,
        amountCents: 120000,
        date: addDays(today, 1),
        dueDate: addDays(today, 1),
        description: 'Aluguel',
        accountId: main.id,
        categoryId: cat('Moradia'),
        status: TransactionStatus.planned,
      ),
    );
    await ctl.saveTransaction(
      TransactionInput(
        kind: TransactionKind.expense,
        amountCents: 9000,
        date: addDays(today, 3),
        dueDate: addDays(today, 3),
        description: 'Internet',
        accountId: main.id,
        categoryId: cat('Moradia'),
        status: TransactionStatus.planned,
      ),
    );
    final goal = await ctl.saveGoal(
      name: 'Reserva de emergência',
      targetCents: 1000000,
      kind: 'emergency',
      accountId: main.id,
      reserved: true,
    );
    await ctl.saveTransaction(
      TransactionInput(
        kind: TransactionKind.goalDeposit,
        amountCents: 100000,
        date: addDays(today, -3),
        description: 'Guardado',
        // The reserve sits inside the same account: source and destination are the same.
        accountId: main.id,
        toAccountId: main.id,
        goalId: goal.id,
      ),
    );
  });
  await tester.pumpAndSettle();
}

Future<TestApp> _boot(WidgetTester tester, {bool demo = false}) async {
  final app = TestApp();
  addTearDown(app.dispose);
  await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
  await pumpApp(tester, app);
  expect(find.byType(HomeScreen), findsOneWidget);
  if (demo) await seedDemo(tester);
  return app;
}

/// Amounts on screen, e.g. "2.340,50" (dates such as 15/11 do not match).
final _amount = RegExp(r'\d,\d{2}');

void main() {
  setUpAll(loadTestFonts);

  testWidgets('first access asks for an account and shows no invented amount', (
    tester,
  ) async {
    await setPhone(tester);
    await _boot(tester);

    expect(find.text('Configure seu saldo'), findsOneWidget);
    expect(
      find.text('Adicione sua primeira conta para saber quanto pode gastar.'),
      findsOneWidget,
    );
    expect(find.text('Adicionar conta'), findsOneWidget);
    // Unknown is not zero: no "R$ 0,00" anywhere, and no "pode gastar" figure.
    expect(find.textContaining(_amount), findsNothing);
    expect(find.textContaining('Pode gastar'), findsNothing);
    // The other sections are one line each.
    expect(find.text('Nenhuma conta prevista'), findsOneWidget);
    expect(find.text('Adicione seu primeiro cartão'), findsOneWidget);
    expect(find.byType(EmptyRow), findsWidgets);
    await screenshot(tester, 'home_first_access_light');

    await tester.tap(find.text('Adicionar conta'));
    await tester.pumpAndSettle();
    expect(find.text('Nova conta'), findsOneWidget);
  });

  testWidgets(
    'an account without movements shows its amount and a compact empty list',
    (tester) async {
      await setPhone(tester);
      await _boot(tester);
      final c = _container(tester);
      await tester.runAsync(
        () => c
            .read(appControllerProvider.notifier)
            .saveAccount(
              name: 'Conta corrente',
              type: 'checking',
              openingBalanceCents: 150000,
              openingDate: c.read(todayProvider),
            ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Configure seu saldo'), findsNothing);
      expect(find.text('Pode gastar neste mês'), findsOneWidget);
      expect(find.textContaining('1.500'), findsWidgets);
      // the balance of the period sits right under the summary, so the list is further down
      await tester.scrollUntilVisible(
        find.text('Nenhum lançamento ainda'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Nenhum lançamento ainda'), findsOneWidget);
      await screenshot(tester, 'home_no_movements_light');
    },
  );

  testWidgets(
    'with data: summary and its two figures, bills, card invoice and latest entries',
    (tester) async {
      await setPhone(tester);
      await _boot(tester, demo: true);

      // Summary: the amount and the figures that explain it (5.480,50 − 3.140,00 = 2.340,50).
      expect(find.text('Pode gastar neste mês'), findsOneWidget);
      final panel = find.byType(SummaryPanel);
      expect(
        find.descendant(of: panel, matching: find.textContaining('2.340')),
        findsOneWidget,
      );
      expect(find.text('Saldo em contas'), findsOneWidget);
      expect(
        find.descendant(of: panel, matching: find.textContaining('5.480,50')),
        findsOneWidget,
      );
      expect(find.text('Compromissos do mês'), findsOneWidget);
      expect(find.text('Após os compromissos previstos'), findsOneWidget);
      expect(
        find.descendant(of: panel, matching: find.textContaining('3.140,00')),
        findsOneWidget,
      );

      // Quick actions, as in the reference.
      expect(find.text('Lançamento'), findsOneWidget);
      expect(find.text('Conta a pagar'), findsOneWidget);
      expect(find.text('Contas'), findsOneWidget);

      // Bills: total pending, and due dates told apart in words.
      await tester.scrollUntilVisible(
        find.text('Internet'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Contas a pagar'), findsOneWidget);
      expect(find.textContaining('1.290,00'), findsWidgets);
      expect(find.text('Vence amanhã'), findsOneWidget);
      expect(find.text('Vence em 3 dias'), findsOneWidget);
      expect(find.text('Ver todas'), findsOneWidget);

      // Card: which card, how much, when.
      await tester.scrollUntilVisible(
        find.text('Cartão principal'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Cartões e faturas'), findsOneWidget);
      expect(find.text('Ver cartões'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^R\$\s850,00$')), findsOneWidget);
      expect(find.text('Vencimento'), findsOneWidget);

      // Latest entries: income marked with a plus.
      await tester.scrollUntilVisible(
        find.text('Salário'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Últimos lançamentos'), findsOneWidget);
      expect(find.textContaining('+ R\$'), findsOneWidget);
      expect(find.textContaining('- R\$'), findsWidgets);
      expect(find.textContaining('Hoje · Alimentação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('with data: screenshots in light and dark, full page', (
    tester,
  ) async {
    // Tall viewport so the whole page fits one capture.
    tester.view.physicalSize = const Size(390 * 2, 1560 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await _boot(tester, demo: true);
    await screenshot(tester, 'home_data_light');

    await tester.tap(find.byTooltip('Usar tema escuro'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(HomeScreen))).brightness,
      Brightness.dark,
    );
    expect(_container(tester).read(prefsProvider).theme, 'dark');
    await screenshot(tester, 'home_data_dark');

    await tester.tap(find.byTooltip('Usar tema claro'));
    await tester.pumpAndSettle();
    expect(_container(tester).read(prefsProvider).theme, 'light');
  });

  testWidgets('hiding values covers every amount on the screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2, 1560 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await _boot(tester, demo: true);
    expect(find.textContaining(_amount), findsWidgets);

    await tester.tap(find.byTooltip('Ocultar valores'));
    await tester.pumpAndSettle();
    expect(find.textContaining(_amount), findsNothing);
    expect(find.textContaining('••••'), findsWidgets);
    await screenshot(tester, 'home_data_hidden_light');

    await tester.tap(find.byTooltip('Mostrar valores'));
    await tester.pumpAndSettle();
    expect(find.textContaining(_amount), findsWidgets);
  });

  testWidgets('quick actions and the period control lead where they say', (
    tester,
  ) async {
    await setPhone(tester);
    await _boot(tester, demo: true);

    await tester.tap(find.text('Conta a pagar'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    expect(find.textContaining('Ainda não paguei'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // "Lançamento" asks which kind of entry, the same sheet the "+" button opens.
    await tester.tap(find.text('Lançamento'));
    await tester.pumpAndSettle();
    expect(find.text('Conta a receber'), findsOneWidget);
    await pickAddOption(tester, 'Receita');
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contas'));
    await tester.pumpAndSettle();
    expect(find.text('Conta corrente'), findsWidgets);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(HomeHeader));
    await tester.pumpAndSettle();
    expect(find.byType(CustomizeScreen), findsOneWidget);
  });

  testWidgets(
    'narrow screen with large text and large amounts does not overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _boot(tester, demo: true);
      final c = _container(tester);
      final main = c
          .read(ledgerProvider)
          .accounts
          .firstWhere((a) => a.name == 'Conta corrente');
      await tester.runAsync(
        () => c
            .read(appControllerProvider.notifier)
            .saveTransaction(
              TransactionInput(
                kind: TransactionKind.income,
                amountCents: 123456789012,
                date: c.read(todayProvider),
                description: 'Recebimento com uma descrição propositalmente muito longa para testar',
                accountId: main.id,
              ),
            ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await screenshot(tester, 'home_data_narrow_large_text_top');

      // Walk the whole page: an overflow anywhere would surface as an exception.
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 12; i++) {
        await tester.drag(scrollable, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await screenshot(tester, 'home_data_narrow_large_text');
    },
  );
}
