/// Boots the real app (router, DI, controller) on an in-memory database with deterministic clock and ids.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/app.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/notifications/bill_reminders.dart';
import 'package:serenacash/data/security/secret_store.dart';
import 'package:serenacash/domain/ports/ports.dart';

/// Loads the bundled display font and Flutter's Roboto so screenshots render real glyphs (not boxes).
Future<void> loadTestFonts() async {
  final display = FontLoader('BricolageGrotesque')
    ..addFont(_bytes('assets/fonts/BricolageGrotesque-Variable.ttf'));
  await display.load();
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  final roboto = FontLoader('Roboto');
  for (final f in [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]) {
    final file = File('$flutterRoot/bin/cache/artifacts/material_fonts/$f');
    if (file.existsSync()) roboto.addFont(_bytes(file.path));
  }
  await roboto.load();
}

Future<ByteData> _bytes(String path) async {
  final b = await File(path).readAsBytes();
  return ByteData.view(b.buffer);
}

class TestApp {
  TestApp({String now = '2026-11-04T12:00:00.000Z'}) : clock = FixedClock(now);
  final FixedClock clock;
  final db = AppDatabase.inMemory();
  final secrets = InMemorySecretStore();

  Widget build() => ProviderScope(
    overrides: [
      databaseProvider.overrideWith((ref) async => db),
      secretStoreProvider.overrideWithValue(secrets),
      clockProvider.overrideWithValue(clock),
      idGeneratorProvider.overrideWithValue(SequentialIdGenerator('t')),
      billRemindersProvider.overrideWithValue(const NoopBillReminders()),
    ],
    child: const SerenaCashApp(),
  );

  Future<void> dispose() => db.close();
}

/// Phone viewport (390×844 logical, 2× for crisp screenshots).
Future<void> setPhone(WidgetTester tester, {double scale = 2}) async {
  tester.view.physicalSize = Size(390 * scale, 844 * scale);
  tester.view.devicePixelRatio = scale;
  addTearDown(tester.view.reset);
}

Future<void> pumpApp(WidgetTester tester, TestApp app) async {
  await tester.pumpWidget(app.build());
  // database open + controller build
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

/// Screenshots are documentation artifacts (docs/flutter-migration/screenshots), rendered from the real
/// widget tree. They are written only with `flutter test --update-goldens` and never compared on a normal
/// run, so font rasterization differences between machines cannot fail the suite.
Future<void> screenshot(WidgetTester tester, String name) async {
  if (!autoUpdateGoldenFiles) return;
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}
