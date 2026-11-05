/// Walks the main screens with the demo ledger and checks that each one renders without layout errors,
/// in light and dark, at a regular and at a narrow width with enlarged text. With `--update-goldens` it
/// also writes one screenshot per screen (documentation, never compared).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/app.dart';
import 'package:serenacash/app/router.dart';
import 'package:serenacash/app/state/app_controller.dart';

import 'harness.dart';
import 'home_redesign_test.dart' show seedDemo;
import 'kv_factory.dart';

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SerenaCashApp)));

/// Screens pushed over the tabs, by route.
const _stack = <(String, String)>[
  ('accounts', '/accounts'),
  ('cards', '/cards'),
  ('budgets', '/budgets'),
  ('goals', '/goals'),
  ('loans', '/loans'),
  ('calendar', '/calendar'),
  ('bills', '/bills'),
  ('reports', '/reports'),
  ('report_categories', '/reports/categories'),
  ('report_cashflow', '/reports/cashflow'),
  ('report_projection', '/reports/projection'),
  ('available', '/available'),
  ('settings', '/settings'),
  ('customize', '/customize'),
  ('categories', '/categories'),
  ('export', '/export'),
  ('import', '/import'),
  ('transaction_new', '/transaction?kind=expense'),
];

Future<void> _tour(
  WidgetTester tester, {
  required String suffix,
  bool shots = true,
}) async {
  final router = _container(tester).read(routerProvider);
  Future<void> check(String name) async {
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'screen $name');
    if (shots) await screenshot(tester, 'tour_${name}_$suffix');
  }

  for (final (name, route) in [('plan', '/plan'), ('shopping', '/shopping')]) {
    router.go(route);
    await check(name);
  }
  router.go('/');
  await tester.pumpAndSettle();
  for (final (name, route) in _stack) {
    unawaited(router.push(route));
    await check(name);
    // Scroll to the end as well: an overflow further down must not go unnoticed.
    await tester.dragFrom(
      tester.getCenter(find.byType(MaterialApp)),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'screen $name (scrolled)');
    router.pop();
    await tester.pumpAndSettle();
  }
}

Future<void> _boot(WidgetTester tester) async {
  final app = TestApp();
  addTearDown(app.dispose);
  await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
  await pumpApp(tester, app);
  await seedDemo(tester);
}

void main() {
  setUpAll(loadTestFonts);

  testWidgets('every main screen renders with data (light)', (tester) async {
    // 1× on purpose: small images are enough to review layout and hierarchy.
    await setPhone(tester, scale: 1);
    await _boot(tester);
    await _tour(tester, suffix: 'light');
  });

  testWidgets('every main screen renders with data (dark)', (tester) async {
    await setPhone(tester, scale: 1);
    await _boot(tester);
    final c = _container(tester);
    await tester.runAsync(
      () => c
          .read(appControllerProvider.notifier)
          .setPrefs((p) => p.copyWith(theme: 'dark')),
    );
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    await _tour(tester, suffix: 'dark');
  });

  testWidgets('every main screen survives a narrow phone with text at 150%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _boot(tester);
    await _tour(tester, suffix: 'narrow', shots: false);
  });
}
