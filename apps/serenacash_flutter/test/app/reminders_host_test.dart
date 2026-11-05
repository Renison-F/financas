import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/app.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/data/notifications/bill_reminders.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/features/transactions/transaction_form_screen.dart';

import 'harness.dart';

class FakeBillReminders implements BillReminders {
  FakeBillReminders({this.permitted = true});
  bool permitted;
  String? launchRoute;
  int scheduleCalls = 0;
  int lastBillCount = -1;
  final _opened = StreamController<String>.broadcast();

  void tap(String route) => _opened.add(route);

  @override
  Future<bool> requestPermission() async => permitted;
  @override
  Future<bool> hasPermission() async => permitted;
  @override
  Future<int> schedule(Ledger ledger, String today) async {
    scheduleCalls++;
    lastBillCount = ledger.transactions
        .where((t) => t.status == TransactionStatus.planned)
        .length;
    return lastBillCount;
  }

  @override
  Future<String?> takeLaunchRoute() async {
    final r = launchRoute;
    launchRoute = null;
    return r;
  }

  @override
  Stream<String> get openedRoutes => _opened.stream;
}

Widget _app(TestApp app, BillReminders reminders) => ProviderScope(
  overrides: [
    databaseProvider.overrideWith((ref) async => app.db),
    secretStoreProvider.overrideWithValue(app.secrets),
    clockProvider.overrideWithValue(app.clock),
    idGeneratorProvider.overrideWithValue(SequentialIdGenerator('t')),
    billRemindersProvider.overrideWithValue(reminders),
  ],
  child: const SerenaCashApp(),
);

Future<void> _boot(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

/// Onboarding with one account and the planned bill "Aluguel".
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

String _billId(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(SerenaCashApp)),
  );
  return container
      .read(ledgerProvider)
      .transactions
      .firstWhere((t) => t.description == 'Aluguel')
      .id;
}

void main() {
  setUpAll(loadTestFonts);

  testWidgets('tapping a reminder while the app runs opens that bill', (
    tester,
  ) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    final reminders = FakeBillReminders();
    await _boot(tester, _app(app, reminders));
    await _onboard(tester);

    reminders.tap('/transaction?id=${_billId(tester)}');
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    expect(find.text('Editar lançamento'), findsOneWidget);
    expect(find.text('Aluguel'), findsWidgets);
  });

  testWidgets('a reminder for a bill that no longer exists opens nothing', (
    tester,
  ) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    final reminders = FakeBillReminders();
    await _boot(tester, _app(app, reminders));
    await _onboard(tester);

    reminders.tap('/transaction?id=does-not-exist');
    reminders.tap('/privacy');
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('a reminder that launched the app opens the bill after loading', (
    tester,
  ) async {
    await setPhone(tester);
    final app = TestApp();
    addTearDown(app.dispose);
    final reminders = FakeBillReminders();
    await _boot(tester, _app(app, reminders));
    await _onboard(tester);
    final id = _billId(tester);

    // Cold start: a new app instance over the same database, launched by the notification.
    await tester.pumpWidget(const SizedBox());
    reminders.launchRoute = '/transaction?id=$id';
    await _boot(tester, _app(app, reminders));
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    expect(find.text('Aluguel'), findsWidgets);
  });

  testWidgets(
    'reminders follow the ledger when notifications are allowed, and stay off when they are not',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      final allowed = FakeBillReminders();
      await _boot(tester, _app(app, allowed));
      await _onboard(tester);
      await tester.pump(const Duration(seconds: 2));
      expect(allowed.scheduleCalls, greaterThan(0));
      expect(allowed.lastBillCount, greaterThan(0));

      await tester.pumpWidget(const SizedBox());
      final denied = FakeBillReminders(permitted: false);
      await _boot(tester, _app(app, denied));
      await tester.pump(const Duration(seconds: 2));
      expect(denied.scheduleCalls, 0);
    },
  );
}
