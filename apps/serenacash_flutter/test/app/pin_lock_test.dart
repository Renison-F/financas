import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/app.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/data/notifications/bill_reminders.dart';
import 'package:serenacash/data/security/pin.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/features/settings/settings_screen.dart';
import 'package:serenacash/ui/icons.dart';

import 'harness.dart';
import 'kv_factory.dart';

/// Same app as [TestApp.build], with a cheap Argon2id profile so the PIN derivation finishes in a test.
Widget _appWithFastPin(TestApp app) => ProviderScope(
  overrides: [
    databaseProvider.overrideWith((ref) async => app.db),
    secretStoreProvider.overrideWithValue(app.secrets),
    clockProvider.overrideWithValue(app.clock),
    idGeneratorProvider.overrideWithValue(SequentialIdGenerator('t')),
    billRemindersProvider.overrideWithValue(const NoopBillReminders()),
    pinManagerProvider.overrideWithValue(
      PinManager(
        app.secrets,
        params: const PinKdfParams(memoryKiB: 16, iterations: 1),
      ),
    ),
  ],
  child: const SerenaCashApp(),
);

Future<void> _pumpReal(WidgetTester tester) async {
  // The PIN derivation is real async work; let it run, then rebuild.
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Mais'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Configurações'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Configurações'));
  await tester.pumpAndSettle();
  expect(find.byType(SettingsScreen), findsOneWidget);
  await tester.scrollUntilVisible(
    find.text('Proteger com PIN'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _answerPinDialog(WidgetTester tester, String pin) async {
  await tester.enterText(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    ),
    pin,
  );
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadTestFonts);

  testWidgets(
    'PIN: set in settings, lock screen layout, wrong PIN then right PIN unlocks',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await tester.pumpWidget(_appWithFastPin(app));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await _openSettings(tester);
      await tester.tap(find.text('Proteger com PIN'));
      await tester.pumpAndSettle();
      expect(find.text('Definir PIN'), findsOneWidget);

      // First dialog closes, second opens: the first dialog's field must not be used after dispose.
      await _answerPinDialog(tester, '4826');
      expect(tester.takeException(), isNull);
      expect(find.text('Confirme o PIN'), findsOneWidget);

      await _answerPinDialog(tester, '4826');
      await _pumpReal(tester);
      expect(tester.takeException(), isNull);

      // Enabling the PIN locks the app.
      expect(find.text('Bloqueado'), findsOneWidget);
      final lock = find.byWidgetPredicate(
        (w) => w is SIcon && w.name == SIconName.lock && w.size == 40,
      );
      expect(lock, findsOneWidget);
      expect(tester.getSize(lock), const Size(40, 40));

      final pinField = find.byType(TextField);
      await tester.enterText(pinField, '0000');
      await tester.tap(find.text('Usar PIN'));
      await _pumpReal(tester);
      expect(find.text('PIN incorreto.'), findsOneWidget);
      expect(tester.widget<TextField>(pinField).controller!.text, isEmpty);

      await tester.enterText(pinField, '4826');
      await tester.tap(find.text('Usar PIN'));
      await _pumpReal(tester);
      expect(find.text('Bloqueado'), findsNothing);
    },
  );
}
