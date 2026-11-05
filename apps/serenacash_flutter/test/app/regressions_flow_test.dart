/// Widget-level checks for the homologation findings: one undo toast, sheet header that fits its
/// actions, hidden secrets and spoken color names.
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serenacash/app/app.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/features/transactions/transaction_form_screen.dart';
import 'package:serenacash/ui/components/components.dart';

import 'harness.dart';
import 'kv_factory.dart';

/// Onboarding with one account and the monthly planned bill "Aluguel".
Future<void> _onboard(WidgetTester tester) async {
  await tester.tap(find.text('Começar'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).last, '250000');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Aluguel'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).last, '120000');
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pular'));
  await tester.pumpAndSettle();
  expect(find.byType(HomeScreen), findsOneWidget);
}

void main() {
  setUpAll(loadTestFonts);

  testWidgets('deleting shows one undo toast, and undoing leaves none behind', (
    tester,
  ) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    await pumpApp(tester, app);
    await _onboard(tester);

    await tester.tap(find.text('Lançamentos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aluguel').first);
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Excluir este e os próximos'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Excluir este e os próximos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir este e os próximos'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    // A second listener would have queued the same toast again.
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Aluguel'), findsWidgets);
  });

  testWidgets(
    'the form header shows "Cancelar" in full, also with large text',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await pumpApp(tester, app);

      for (final scale in [1.0, 1.3]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        await addEntry(tester);
        final cancel = tester.renderObject<RenderParagraph>(
          find.text('Cancelar'),
        );
        expect(
          cancel.didExceedMaxLines,
          isFalse,
          reason: 'Cancelar cortado em escala $scale',
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('account colors are announced by name, with a 48 px target', (
    tester,
  ) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
    await pumpApp(tester, app);
    final handle = tester.ensureSemantics();

    await openMenu(tester, 'Contas e carteiras');
    await tester.tap(find.text('Nova'));
    await tester.pumpAndSettle();

    final teal = find.bySemanticsLabel('Azul-petróleo');
    expect(teal, findsOneWidget);
    expect(find.bySemanticsLabel('#0B5563'), findsNothing);
    final size = tester.getSize(teal);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    handle.dispose();
  });

  testWidgets('backup passphrase is hidden until the user asks to see it', (
    tester,
  ) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
    await pumpApp(tester, app);

    await openMenu(tester, 'Exportar e backup');
    await tester.scrollUntilVisible(
      find.byType(SecretField),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final field = find.descendant(
      of: find.byType(SecretField),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(field).obscureText, isTrue);
    await tester.tap(find.byTooltip('Mostrar'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).obscureText, isFalse);
  });

  testWidgets(
    'onboarding: back returns one step and an interrupted setup never duplicates the account',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await pumpApp(tester, app);
      ProviderContainer container() =>
          ProviderScope.containerOf(tester.element(find.byType(SerenaCashApp)));

      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '250000');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Passo 3 de 4'), findsNothing);
      expect(find.bySemanticsLabel('Passo 3 de 4'), findsOneWidget);
      await tester.tap(find.text('Aluguel'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '120000');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // A monthly bill is stored as a series; what matters is that it is registered once.
      final rentEntries = container()
          .read(ledgerProvider)
          .transactions
          .where((t) => t.description == 'Aluguel')
          .length;
      expect(rentEntries, greaterThan(0));

      // System back: one step, not out of the app. Going forward again repeats nothing.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Passo 3 de 4'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Passo 2 de 4'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '300000');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      var ledger = container().read(ledgerProvider);
      expect(ledger.accounts, hasLength(1));
      expect(ledger.accounts.single.openingBalanceCents, 300000);
      expect(
        ledger.transactions.where((t) => t.description == 'Aluguel'),
        hasLength(rentEntries),
      );

      // The app is closed before the last step and opened again: the setup starts over.
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, app);
      expect(find.text('Começar'), findsOneWidget);
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '548050');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      ledger = container().read(ledgerProvider);
      expect(ledger.accounts, hasLength(1));
      expect(ledger.accounts.single.openingBalanceCents, 548050);
      expect(find.textContaining('5.480,50'), findsWidgets);
    },
  );
}
