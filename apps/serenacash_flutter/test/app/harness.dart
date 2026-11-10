/// Boots the real app (router, DI, controller) on an in-memory database with deterministic clock and ids.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
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
  TestApp({String now = '2026-11-04T12:00:00.000Z', this.overrides = const []})
    : clock = FixedClock(now);
  final FixedClock clock;

  /// Extra provider overrides for one test (a fake device confirmation, for instance).
  final List<Override> overrides;
  final db = AppDatabase.inMemory();
  final secrets = InMemorySecretStore();

  Widget build() => ProviderScope(
    overrides: [
      databaseProvider.overrideWith((ref) async => db),
      secretStoreProvider.overrideWithValue(secrets),
      clockProvider.overrideWithValue(clock),
      idGeneratorProvider.overrideWithValue(SequentialIdGenerator('t')),
      billRemindersProvider.overrideWithValue(const NoopBillReminders()),
      ...overrides,
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

/// Opens the side menu from the bottom bar and, when [row] is given, taps that destination.
Future<void> openMenu(WidgetTester tester, [String? row]) async {
  await tester.tap(find.text('Menu'));
  await tester.pumpAndSettle();
  if (row != null) await tapMenuRow(tester, row);
}

/// Taps a destination of the open side menu, scrolling the menu until it is visible.
Future<void> tapMenuRow(WidgetTester tester, String row) async {
  final drawer = find.byType(Drawer);
  final item = find.descendant(of: drawer, matching: find.text(row));
  await tester.scrollUntilVisible(
    item,
    200,
    scrollable: find
        .descendant(of: drawer, matching: find.byType(Scrollable))
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(item);
  await tester.pumpAndSettle();
}

/// Taps the "+" button and picks one kind of entry in the sheet it opens.
Future<void> addEntry(WidgetTester tester, [String option = 'Despesa']) async {
  await tester.tap(find.byTooltip('Adicionar'));
  await tester.pumpAndSettle();
  await pickAddOption(tester, option);
}

/// Picks one kind of entry in the open "Adicionar" sheet.
Future<void> pickAddOption(WidgetTester tester, String option) async {
  await tester.tap(
    find.descendant(of: find.byType(BottomSheet), matching: find.text(option)),
  );
  await tester.pumpAndSettle();
}
