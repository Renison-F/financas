import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/features/accounts/accounts_screen.dart';
import 'package:serenacash/features/budgets/budgets_screen.dart';
import 'package:serenacash/features/cards/cards_screen.dart';
import 'package:serenacash/features/goals/goals_screen.dart';
import 'package:serenacash/features/loans/loans_screen.dart';
import 'package:serenacash/features/reports/reports_screens.dart';
import 'package:serenacash/features/transactions/transaction_form_screen.dart';

import 'harness.dart';
import 'kv_factory.dart';

Future<void> openMore(WidgetTester tester, String row) async {
  await tester.tap(find.text('Mais'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text(row),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(row));
  await tester.pumpAndSettle();
}

Future<void> typeMoney(WidgetTester tester, String label, String digits) async {
  final field = find
      .descendant(
        of: find
            .ancestor(of: find.text(label), matching: find.byType(Column))
            .first,
        matching: find.byType(TextField),
      )
      .first;
  await tester.enterText(field, digits);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadTestFonts);

  testWidgets(
    'accounts: create, see detail, card: create and pay invoice flow',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await pumpApp(tester, app);

      await openMore(tester, 'Contas e carteiras');
      expect(find.byType(AccountsScreen), findsOneWidget);
      await tester.tap(find.text('Nova'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Nubank');
      await typeMoney(tester, 'Saldo atual', '150000');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Nubank'), findsOneWidget);
      expect(find.textContaining('1.500,00'), findsWidgets);
      await screenshot(tester, 'accounts_light');
      await tester.tap(find.text('Nubank'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountDetailScreen), findsOneWidget);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      // card
      await tester.tap(find.text('Planejar'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Adicionar cartão'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar cartão'));
      await tester.pumpAndSettle();
      expect(find.byType(CardFormScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Cartão roxo');
      await typeMoney(tester, 'Limite', '500000');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Cartão roxo'), findsWidgets);

      // card purchase in 3 installments through the form
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Adicionar lançamento'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      await tester.tap(find.text('Cartão').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, '0,00').first,
        '30000',
      );
      await tester.enterText(find.byType(TextField).at(1), 'Geladeira');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('3x'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('3x'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsNothing);

      // card detail shows the first installment and lets us pay
      await tester.tap(find.text('Planejar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cartão roxo').first);
      await tester.pumpAndSettle();
      expect(find.byType(CardDetailScreen), findsOneWidget);
      expect(find.textContaining('Geladeira (1/3)'), findsOneWidget);
      expect(find.textContaining('100,00'), findsWidgets);
      await screenshot(tester, 'card_detail_light');
    },
  );

  testWidgets('budgets, goals, loans and reports open and save', (
    tester,
  ) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
    await pumpApp(tester, app);
    await tester.tap(find.text('Planejar'));
    await tester.pumpAndSettle();

    // budget
    await tester.tap(find.text('Criar orçamento'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetFormScreen), findsOneWidget);
    await typeMoney(tester, 'Limite mensal', '200000');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2.000,00'), findsWidgets);

    // goal
    await tester.scrollUntilVisible(
      find.text('Criar meta'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Criar meta'));
    await tester.pumpAndSettle();
    expect(find.byType(GoalFormScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Reserva');
    await typeMoney(tester, 'Valor da meta', '1000000');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Reserva'), findsWidgets);

    // loan with preview
    await tester.scrollUntilVisible(
      find.text('Empréstimos e dívidas'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Novo').last);
    await tester.pumpAndSettle();
    expect(find.byType(LoanFormScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Carro');
    await typeMoney(tester, 'Valor emprestado', '1000000');
    await tester.enterText(find.widgetWithText(TextField, '1,99').first, '2');
    await tester.pumpAndSettle();
    expect(find.text('Prévia'), findsOneWidget);
    await screenshot(tester, 'loan_form_light');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Carro'), findsWidgets);

    // reports
    await openMore(tester, 'Relatórios');
    expect(find.byType(ReportsIndexScreen), findsOneWidget);
    await tester.tap(find.text('Fluxo de caixa'));
    await tester.pumpAndSettle();
    expect(find.byType(CashflowReportScreen), findsOneWidget);
    await screenshot(tester, 'cashflow_light');
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projeção de saldo'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectionReportScreen), findsOneWidget);
    expect(find.text('Carro 1/12'), findsWidgets);
  });

  testWidgets('budgets screen shows the pace legend', (tester) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
    await pumpApp(tester, app);
    await tester.tap(find.text('Planejar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar orçamento'));
    await tester.pumpAndSettle();
    await typeMoney(tester, 'Limite mensal', '100000');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver tudo'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetsScreen), findsOneWidget);
    expect(find.textContaining('sereno'), findsWidgets);
    await screenshot(tester, 'budgets_light');
  });
}
