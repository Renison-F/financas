import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/data/security/secret_store.dart';
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
  await openMenu(tester, 'Configurações');
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
      expect(tester.widget<TextField>(pinField).obscureText, isTrue);
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

  testWidgets(
    'lock screen: five wrong PINs start a pause, the field is disabled and the way out is stated',
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

      await _openSettings(tester);
      await tester.tap(find.text('Proteger com PIN'));
      await tester.pumpAndSettle();
      await _answerPinDialog(tester, '4826');
      await _answerPinDialog(tester, '4826');
      await _pumpReal(tester);
      expect(find.text('Bloqueado'), findsOneWidget);

      Future<void> wrong() async {
        await tester.enterText(find.byType(TextField), '0000');
        await tester.tap(find.text('Usar PIN'));
        await _pumpReal(tester);
      }

      await wrong();
      await wrong();
      expect(find.text('PIN incorreto.'), findsOneWidget);
      await wrong();
      // The last free tries are counted out loud.
      expect(find.textContaining('Restam 2 tentativas'), findsOneWidget);
      await wrong();
      expect(find.textContaining('Resta 1 tentativa'), findsOneWidget);
      await wrong();
      expect(find.textContaining('Muitas tentativas'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);

      // The right PIN is not accepted during the pause.
      await tester.tap(find.text('Usar PIN'), warnIfMissed: false);
      await _pumpReal(tester);
      expect(find.text('Bloqueado'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // The way out is explained before anything is erased, and cancelling changes nothing.
      await tester.tap(find.text('Esqueci o PIN'));
      await tester.pumpAndSettle();
      expect(find.text('O PIN não pode ser recuperado'), findsOneWidget);
      expect(find.text('Apagar dados e recomeçar'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Bloqueado'), findsOneWidget);
      expect(await app.secrets.read(SecretKeys.pinVerifier), isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'turning the PIN off asks for the current PIN: a wrong one keeps the lock, the right one removes it',
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

      await _openSettings(tester);
      await tester.tap(find.text('Proteger com PIN'));
      await tester.pumpAndSettle();
      await _answerPinDialog(tester, '4826');
      await _answerPinDialog(tester, '4826');
      await _pumpReal(tester);
      // Unlock: the settings screen is still underneath.
      await tester.enterText(find.byType(TextField), '4826');
      await tester.tap(find.text('Usar PIN'));
      await _pumpReal(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.tap(find.text('Proteger com PIN'));
      await tester.pumpAndSettle();
      expect(find.text('Confirme o PIN para desativar'), findsOneWidget);
      await _answerPinDialog(tester, '1111');
      await _pumpReal(tester);
      expect(await app.secrets.read(SecretKeys.pinVerifier), isNotNull);
      expect(find.text('PIN incorreto.'), findsOneWidget);

      await tester.tap(find.text('Proteger com PIN'));
      await tester.pumpAndSettle();
      await _answerPinDialog(tester, '4826');
      await _pumpReal(tester);
      expect(await app.secrets.read(SecretKeys.pinVerifier), isNull);
      expect(await app.secrets.read(SecretKeys.pinAttempts), isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'locking on background keeps what was being typed: the form is still there after unlocking',
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

      await _openSettings(tester);
      await tester.tap(find.text('Proteger com PIN'));
      await tester.pumpAndSettle();
      await _answerPinDialog(tester, '4826');
      await _answerPinDialog(tester, '4826');
      await _pumpReal(tester);
      await tester.enterText(find.byType(TextField), '4826');
      await tester.tap(find.text('Usar PIN'));
      await _pumpReal(tester);
      // System back (the header with the back arrow is scrolled out of view).
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await addEntry(tester);
      await tester.enterText(find.byType(TextField).at(0), '15990');
      await tester.enterText(
        find.byType(TextField).at(1),
        'Farmácia da esquina',
      );
      await tester.pumpAndSettle();

      // The app goes to the background and comes back: it is locked, and nothing of it is on screen.
      for (final state in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();
      expect(find.text('Bloqueado'), findsOneWidget);
      expect(find.text('Farmácia da esquina'), findsNothing);
      expect(find.textContaining('159,90'), findsNothing);

      await tester.enterText(find.byType(TextField), '4826');
      await tester.tap(find.text('Usar PIN'));
      await _pumpReal(tester);
      expect(find.text('Bloqueado'), findsNothing);
      expect(
        find.widgetWithText(TextField, 'Farmácia da esquina'),
        findsOneWidget,
      );
      expect(find.textContaining('159,90'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
