/// Regressões das ocorrências trazidas da homologação física (docs/flutter-migration/15):
/// 001 e 025 (barras do sistema e teclado), 002 e 003 (lançamento), 004 e 005 (calendário),
/// 011 (confirmação do aparelho), 012 (planejamento anual) e 021 (cursor).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/state/app_state.dart';
import 'package:serenacash/data/security/device_auth.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ledger/ledger.dart';
import 'package:serenacash/features/accounts/account_form_screen.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/features/shopping/item_review_screen.dart';
import 'package:serenacash/features/transactions/transaction_form_screen.dart';

import 'harness.dart';
import 'kv_factory.dart';

/// A phone with the three-button navigation bar (48 dp) drawn over the app, as Android 15 does.
Future<void> _threeButtonPhone(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  double keyboard = 0,
}) async {
  const dpr = 2.0;
  tester.view.physicalSize = size * dpr;
  tester.view.devicePixelRatio = dpr;
  tester.view.viewPadding = const FakeViewPadding(
    top: 24 * dpr,
    bottom: 48 * dpr,
  );
  tester.view.padding = FakeViewPadding(
    top: 24 * dpr,
    bottom: keyboard > 0 ? 0 : 48 * dpr,
  );
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard * dpr);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

Future<TestApp> _bootOnboarded(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  final app = TestApp(overrides: overrides);
  addTearDown(app.dispose);
  await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
  await pumpApp(tester, app);
  return app;
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));

class _FakeDeviceAuth implements DeviceAuth {
  _FakeDeviceAuth(this.answers);
  final List<DeviceAuthStatus> answers;
  int asked = 0, openedSettings = 0;
  @override
  Future<bool> hasBiometrics() async => true;
  @override
  Future<DeviceAuthStatus> confirm(String reason) async =>
      answers[asked++ % answers.length];
  @override
  Future<bool> openSecuritySettings() async {
    openedSettings++;
    return true;
  }
}

void main() {
  setUpAll(loadTestFonts);

  for (final (name, size, scale) in [
    ('390×844, fonte 1,0', const Size(390, 844), 1.0),
    ('390×844, fonte 1,3', const Size(390, 844), 1.3),
    ('360×640, fonte 1,6', const Size(360, 640), 1.6),
  ]) {
    testWidgets(
      '001: every option of "Adicionar" stays above the system bar ($name)',
      (tester) async {
        await _threeButtonPhone(tester, size: size, textScale: scale);
        await _bootOnboarded(tester);
        await tester.tap(find.byTooltip('Adicionar'));
        await tester.pumpAndSettle();
        final sheet = find.byType(BottomSheet);
        final last = find.descendant(
          of: sheet,
          matching: find.text('Conta a receber'),
        );
        // the last option may need scrolling on a small screen with a large font, never more
        await tester.ensureVisible(last);
        await tester.pumpAndSettle();
        final safeBottom = size.height - 48;
        final row = tester.getRect(
          find.ancestor(of: last, matching: find.byType(InkWell)).first,
        );
        expect(
          row.bottom,
          lessThanOrEqualTo(safeBottom + 0.5),
          reason: 'a última opção termina acima da barra de três botões',
        );
        expect(tester.getRect(sheet).bottom, moreOrLessEquals(size.height));
        await tester.tap(last);
        await tester.pumpAndSettle();
        expect(find.byType(TransactionFormScreen), findsOneWidget);
        expect(find.text('Receita'), findsWidgets);
      },
    );
  }

  testWidgets('001: confirmation sheets end above the system bar too', (
    tester,
  ) async {
    await _threeButtonPhone(tester, textScale: 1.3);
    await _bootOnboarded(tester);
    final c = _container(tester);
    final acc = await c
        .read(appControllerProvider.notifier)
        .saveAccount(name: 'c6', type: 'checking', openingBalanceCents: 10000);
    await c
        .read(appControllerProvider.notifier)
        .saveTransaction(
          TransactionInput(
            kind: TransactionKind.expense,
            amountCents: 450,
            date: c.read(todayProvider),
            description: 'padaria',
            accountId: acc.id,
          ),
        );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lançamentos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('padaria').first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Excluir lançamento'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Excluir lançamento'));
    await tester.pumpAndSettle();
    final cancel = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('Cancelar'),
    );
    expect(
      tester.getRect(cancel).bottom,
      lessThanOrEqualTo(844 - 48),
      reason: 'o botão Cancelar da folha de confirmação fica acima da barra',
    );
  });

  testWidgets(
    '002: an expense already typed goes to the card without starting over',
    (tester) async {
      await setPhone(tester);
      await _bootOnboarded(tester);
      final c = _container(tester);
      final ctl = c.read(appControllerProvider.notifier);
      final acc = await ctl.saveAccount(
        name: 'c6',
        type: 'checking',
        openingBalanceCents: 100000,
      );
      final card = await ctl.saveCard(
        name: 'carol',
        limitCents: 300000,
        closingDay: 20,
        dueDay: 27,
      );
      await tester.pumpAndSettle();

      await addEntry(tester, 'Despesa');
      await tester.enterText(find.byType(TextField).at(0), '4500');
      await tester.enterText(find.byType(TextField).at(1), 'padaria');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escolher categoria'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alimentação').last);
      await tester.pumpAndSettle();
      expect(find.text('Alimentação'), findsOneWidget);

      await tester.ensureVisible(find.text('Cartão de crédito'));
      await tester.tap(find.text('Cartão de crédito'));
      await tester.pumpAndSettle();
      // everything typed is still there, and the card replaces the account
      expect(find.text('padaria'), findsOneWidget);
      expect(
        find.text('R\$ 45,00'),
        findsNothing,
      ); // field shows the masked value
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        '45,00',
      );
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('carol'), findsOneWidget);
      expect(
        find.textContaining('Nenhuma conta é debitada agora'),
        findsOneWidget,
      );

      // back to the account and to the card again: still nothing lost
      await tester.tap(find.text('Conta ou carteira'));
      await tester.pumpAndSettle();
      expect(find.text('Alimentação'), findsOneWidget);
      await tester.tap(find.text('Cartão de crédito'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      final ledger = c.read(ledgerProvider);
      final t = ledger.transactions.single;
      expect(t.kind, TransactionKind.cardPurchase);
      expect(t.amountCents, 4500);
      expect(t.description, 'padaria');
      expect(t.cardId, card.id);
      expect(t.accountId, isNull);
      expect(t.dueDate, isNull);
      expect(ledger.categoryById(t.categoryId)?.name, 'Alimentação');
      // the account is not charged on the day of the purchase
      expect(accountBalance(ledger, acc.id), 100000);
    },
  );

  testWidgets(
    '002: a planned expense switched to the card does not become a bill',
    (tester) async {
      await setPhone(tester);
      await _bootOnboarded(tester);
      final c = _container(tester);
      final ctl = c.read(appControllerProvider.notifier);
      await ctl.saveAccount(
        name: 'c6',
        type: 'checking',
        openingBalanceCents: 0,
      );
      await ctl.saveCard(
        name: 'carol',
        limitCents: 300000,
        closingDay: 20,
        dueDay: 27,
      );
      await tester.pumpAndSettle();
      await addEntry(tester, 'Conta a pagar');
      await tester.enterText(find.byType(TextField).at(0), '9000');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cartão de crédito'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      final t = c.read(ledgerProvider).transactions.single;
      expect(t.kind, TransactionKind.cardPurchase);
      expect(t.status, TransactionStatus.settled);
      expect(t.dueDate, isNull);
    },
  );

  testWidgets(
    '002: the transfer warning does not follow the user to another kind of entry',
    (tester) async {
      await setPhone(tester);
      await _bootOnboarded(tester);
      final c = _container(tester);
      await c
          .read(appControllerProvider.notifier)
          .saveAccount(name: 'c6', type: 'checking', openingBalanceCents: 0);
      await tester.pumpAndSettle();
      await addEntry(tester, 'Transferência');
      await tester.enterText(find.byType(TextField).at(0), '1000');
      await tester.pumpAndSettle();
      // with one account only, the form says what is missing before any attempt
      expect(find.textContaining('precisa de duas contas'), findsOneWidget);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Escolha duas contas diferentes.'), findsOneWidget);
      await tester.tap(find.text('Despesa'));
      await tester.pumpAndSettle();
      expect(find.text('Escolha duas contas diferentes.'), findsNothing);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      final t = c.read(ledgerProvider).transactions.single;
      expect(t.kind, TransactionKind.expense);
      expect(t.amountCents, 1000);
    },
  );

  testWidgets(
    '003: a new account is created from the transfer and comes back selected',
    (tester) async {
      await setPhone(tester);
      await _bootOnboarded(tester);
      final c = _container(tester);
      final from = await c
          .read(appControllerProvider.notifier)
          .saveAccount(
            name: 'c6',
            type: 'checking',
            openingBalanceCents: 50000,
          );
      await tester.pumpAndSettle();
      await addEntry(tester, 'Transferência');
      await tester.enterText(find.byType(TextField).at(0), '1000');
      await tester.enterText(find.byType(TextField).at(1), 'reserva do mês');
      await tester.pumpAndSettle();

      // cancelling the account form creates nothing and keeps the draft
      await tester.tap(find.text('Nova conta').last);
      await tester.pumpAndSettle();
      expect(find.byType(AccountFormScreen), findsOneWidget);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(c.read(ledgerProvider).accounts.length, 1);
      expect(find.text('reserva do mês'), findsOneWidget);

      await tester.tap(find.text('Nova conta').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'poupança');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountFormScreen), findsNothing);
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      // back on the transfer: what was typed is intact and the new account is the destination
      expect(find.text('reserva do mês'), findsOneWidget);
      final ledgerAfterCreate = c.read(ledgerProvider);
      expect(ledgerAfterCreate.accounts.length, 2);
      expect(
        ledgerAfterCreate.transactions,
        isEmpty,
        reason: 'cadastrar a conta não movimenta dinheiro',
      );
      final to = ledgerAfterCreate.accounts.firstWhere(
        (a) => a.name == 'poupança',
      );

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      final ledger = c.read(ledgerProvider);
      final t = ledger.transactions.single;
      expect(t.kind, TransactionKind.transfer);
      expect(t.accountId, from.id);
      expect(t.toAccountId, to.id);
      expect(accountBalance(ledger, from.id), 49000);
      expect(accountBalance(ledger, to.id), 1000);
    },
  );

  testWidgets('004: the due date opens a calendar and still accepts typing', (
    tester,
  ) async {
    await setPhone(tester);
    await _bootOnboarded(tester);
    final c = _container(tester);
    await c
        .read(appControllerProvider.notifier)
        .saveAccount(name: 'c6', type: 'checking', openingBalanceCents: 0);
    await tester.pumpAndSettle();
    await addEntry(tester, 'Conta a pagar');
    await tester.enterText(find.byType(TextField).at(0), '450');
    await tester.enterText(find.byType(TextField).at(1), 'padaria');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byTooltip('Abrir calendário'));
    await tester.tap(find.byTooltip('Abrir calendário'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    // cancelling changes nothing in the form
    await tester.tap(find.text('Cancelar').last);
    await tester.pumpAndSettle();
    expect(find.text('04/11/2026'), findsOneWidget);
    expect(find.text('padaria'), findsOneWidget);

    await tester.tap(find.byTooltip('Abrir calendário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('20/11/2026'), findsOneWidget);
    expect(find.text('padaria'), findsOneWidget);

    // typing still works, a past date is accepted and a date that does not exist is refused
    final date = find.widgetWithText(TextField, '20/11/2026');
    await tester.enterText(date, '29022028');
    await tester.pumpAndSettle();
    expect(find.text('29/02/2028'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, '29/02/2028'),
      '30022027',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Data inválida'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, '30/02/2027'),
      '15032024',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    final t = c.read(ledgerProvider).transactions.single;
    expect(t.date, '2024-03-15');
    expect(t.status, TransactionStatus.planned);
  });

  testWidgets('005: the first due date of a loan opens the same calendar', (
    tester,
  ) async {
    await setPhone(tester);
    await _bootOnboarded(tester);
    await openMenu(tester, 'Empréstimos');
    await tester.tap(find.text('Novo').first);
    await tester.pumpAndSettle();
    expect(find.text('Novo empréstimo'), findsOneWidget);
    // a message from a failed attempt goes away as soon as the form is edited
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Preencha nome, valor'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), '4000000');
    await tester.pumpAndSettle();
    expect(find.textContaining('Preencha nome, valor'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Abrir calendário'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Abrir calendário'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('20/11/2026'), findsOneWidget);
  });

  testWidgets('011: the lock is only turned on when the device confirms', (
    tester,
  ) async {
    await setPhone(tester);
    final device = _FakeDeviceAuth([
      DeviceAuthStatus.notSetUp,
      DeviceAuthStatus.canceled,
      DeviceAuthStatus.lockedOut,
      DeviceAuthStatus.unavailable,
      DeviceAuthStatus.confirmed,
      DeviceAuthStatus.canceled,
      DeviceAuthStatus.confirmed,
    ]);
    await _bootOnboarded(
      tester,
      overrides: [deviceAuthProvider.overrideWithValue(device)],
    );
    final c = _container(tester);
    await openMenu(tester, 'Configurações');
    final toggle = find.text('Pedir confirmação do aparelho ao abrir');
    await tester.scrollUntilVisible(
      toggle,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    Future<void> attempt(String expected) async {
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining(expected), findsOneWidget);
      expect(c.read(prefsProvider).biometricLock, isFalse);
    }

    await attempt('não tem bloqueio de tela nem biometria');
    // the one cause the user can fix leads to where it is fixed
    await tester.tap(find.text('Abrir configurações'));
    await tester.pumpAndSettle();
    expect(device.openedSettings, 1);
    await attempt('Confirmação cancelada');
    ScaffoldMessenger.of(tester.element(toggle)).clearSnackBars();
    await tester.pumpAndSettle();
    await attempt('suspendeu a biometria');
    ScaffoldMessenger.of(tester.element(toggle)).clearSnackBars();
    await tester.pumpAndSettle();
    await attempt('não conseguiu abrir a confirmação');
    ScaffoldMessenger.of(tester.element(toggle)).clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(c.read(prefsProvider).biometricLock, isTrue);
    // one question to turn it on, and no second prompt right after: the app stays open
    expect(device.asked, 5);
    expect(find.text('Desbloquear'), findsNothing);
    expect(toggle, findsOneWidget);

    // turning it off is confirmed by the device too
    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('o bloqueio continua ativado'), findsOneWidget);
    expect(c.read(prefsProvider).biometricLock, isTrue);
    ScaffoldMessenger.of(tester.element(toggle)).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(c.read(prefsProvider).biometricLock, isFalse);
    expect(device.asked, 7);
  });

  test(
    '011: every error code of the plugin maps to a reason the app can explain',
    () {
      expect(deviceAuthStatusFor('userCanceled'), DeviceAuthStatus.canceled);
      expect(deviceAuthStatusFor('systemCanceled'), DeviceAuthStatus.canceled);
      expect(deviceAuthStatusFor('timeout'), DeviceAuthStatus.canceled);
      expect(
        deviceAuthStatusFor('noCredentialsSet'),
        DeviceAuthStatus.notSetUp,
      );
      expect(
        deviceAuthStatusFor('noBiometricsEnrolled'),
        DeviceAuthStatus.notSetUp,
      );
      expect(
        deviceAuthStatusFor('noBiometricHardware'),
        DeviceAuthStatus.noHardware,
      );
      expect(
        deviceAuthStatusFor('temporaryLockout'),
        DeviceAuthStatus.lockedOut,
      );
      expect(
        deviceAuthStatusFor('biometricLockout'),
        DeviceAuthStatus.lockedOut,
      );
      // the code the phone returned before the fix (activity of the wrong type) and anything new
      expect(
        deviceAuthStatusFor('uiUnavailable'),
        DeviceAuthStatus.unavailable,
      );
      expect(deviceAuthStatusFor('somethingNew'), DeviceAuthStatus.unavailable);
    },
  );

  testWidgets(
    '012: an earlier year shows no budget and no goal from the future',
    (tester) async {
      await setPhone(tester);
      await _bootOnboarded(tester);
      final c = _container(tester);
      final ctl = c.read(appControllerProvider.notifier);
      await ctl.saveBudget(limitCents: 85000);
      await ctl.saveGoal(name: 'reserva', targetCents: 500000);
      await tester.pumpAndSettle();
      await openMenu(tester, 'Planejamento anual');
      expect(find.text('2026'), findsOneWidget);
      expect(
        find.textContaining('850,00'),
        findsNWidgets(2),
      ); // November and December
      expect(find.textContaining('reserva: faltam'), findsOneWidget);

      await tester.tap(find.byTooltip('Ano anterior'));
      await tester.pumpAndSettle();
      expect(find.text('2025'), findsOneWidget);
      expect(find.textContaining('850,00'), findsNothing);
      expect(
        find.text('Nenhum lançamento e nenhum orçamento em 2025.'),
        findsOneWidget,
      );
      expect(find.text('Nenhuma meta existia em 2025.'), findsOneWidget);
      expect(find.textContaining('reserva'), findsNothing);

      await tester.tap(find.byTooltip('Próximo ano'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Próximo ano'));
      await tester.pumpAndSettle();
      expect(find.text('2027'), findsOneWidget);
      expect(find.textContaining('850,00'), findsNWidgets(12));
      expect(find.textContaining('reserva: faltam'), findsOneWidget);
      expect(find.textContaining('sem prazo definido'), findsOneWidget);
    },
  );

  testWidgets(
    '021: typing in the middle of the product name keeps the cursor there',
    (tester) async {
      await setPhone(tester);
      await _bootOnboarded(tester);
      await tester.tap(find.text('Compras'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar compra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();
      expect(find.byType(ItemReviewScreen), findsOneWidget);

      final nameField = find.widgetWithText(TextField, 'Nome do produto');
      await tester.enterText(nameField, 'PAO DE FORMA PULL.MALL 430G TRAD');
      await tester.pumpAndSettle();
      final controller = tester
          .widget<TextField>(find.byType(TextField).first)
          .controller!;

      // the user puts the cursor after "PULL" and fixes the brand one key at a time
      await tester.showKeyboard(find.byType(TextField).first);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'PAO DE FORMA PULLM.MALL 430G TRAD',
          selection: TextSelection.collapsed(offset: 18),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.text, 'PAO DE FORMA PULLM.MALL 430G TRAD');
      expect(controller.selection.baseOffset, 18);

      // backspace in the middle, then a composing region (as the keyboard's suggestions do)
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'PAO DE FORMA PULLMMALL 430G TRAD',
          selection: TextSelection.collapsed(offset: 18),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.selection.baseOffset, 18);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'PAO DE FORMA PULLMAN 430G TRAD',
          selection: TextSelection.collapsed(offset: 20),
          composing: TextRange(start: 13, end: 20),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.text, 'PAO DE FORMA PULLMAN 430G TRAD');
      expect(controller.selection.baseOffset, 20);
      expect(controller.value.composing, const TextRange(start: 13, end: 20));

      // changing price and quantity afterwards rebuilds the screen and still leaves the name alone
      await tester.enterText(find.widgetWithText(TextField, '0,00'), '999');
      await tester.pumpAndSettle();
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      expect(
        identical(
          tester.widget<TextField>(find.byType(TextField).first).controller,
          controller,
        ),
        isTrue,
        reason: 'o campo mantém o mesmo controlador entre reconstruções',
      );
      expect(controller.text, 'PAO DE FORMA PULLMAN 430G TRAD');
      expect(find.textContaining('19,98'), findsOneWidget);
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      expect(find.text('PAO DE FORMA PULLMAN 430G TRAD'), findsOneWidget);
    },
  );

  testWidgets(
    '025: with the keyboard open the item review keeps title and action in sight',
    (tester) async {
      await _threeButtonPhone(tester, textScale: 1.3);
      await _bootOnboarded(tester);
      await tester.tap(find.text('Compras'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar compra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      // the three actions of the cart sit above the navigation bar
      expect(
        tester.getRect(find.text('Finalizar compra')).bottom,
        lessThanOrEqualTo(844 - 48),
      );
      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome do produto'),
        'Vela',
      );
      await tester.enterText(find.widgetWithText(TextField, '0,00'), '1199');
      await tester.pumpAndSettle();

      // keyboard up: 300 dp at the bottom belong to it
      await _threeButtonPhone(tester, textScale: 1.3, keyboard: 300);
      await tester.pumpAndSettle();
      final title = tester.getRect(find.text('Confirmar item'));
      final action = tester.getRect(find.text('Adicionar ao carrinho'));
      expect(
        title.top,
        greaterThanOrEqualTo(24),
        reason: 'abaixo da barra de status',
      );
      expect(
        action.bottom,
        lessThanOrEqualTo(844 - 300),
        reason: 'o botão de adicionar fica acima do teclado',
      );
      await tester.tap(find.text('Adicionar ao carrinho'));
      await tester.pumpAndSettle();
      expect(find.byType(ItemReviewScreen), findsNothing);
      expect(find.text('Vela'), findsOneWidget);
    },
  );
}
