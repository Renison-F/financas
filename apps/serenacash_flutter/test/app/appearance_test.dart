/// Ocorrências 009, 026 e 032: paletas com contraste verificado, cores de sinal que não mudam com a
/// paleta, preferência persistente e nenhuma expressão lúdica nos textos.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/app_drawer.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/theme/palettes.dart';
import 'package:serenacash/app/theme/theme.dart';
import 'package:serenacash/app/theme/tokens.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/features/home/home_screen.dart';

import 'harness.dart';
import 'kv_factory.dart';

void main() {
  setUpAll(loadTestFonts);

  group('032: palettes', () {
    for (final palette in palettes) {
      for (final brightness in Brightness.values) {
        test(
          '${palette.id} / ${brightness.name}: readable (WCAG AA) everywhere it is used',
          () {
            final c = colorsFor(brightness, palette.id);
            final pairs = {
              'texto do botão principal': (c.onPrimary, c.primary),
              'cor de ação sobre cartão': (c.primary, c.surface),
              'cor de ação sobre o fundo': (c.primary, c.bg),
              'texto sobre o contêiner': (
                c.onPrimaryContainer,
                c.primaryContainer,
              ),
              'texto do painel-resumo': (c.onHero, c.hero),
              'texto secundário do painel-resumo': (c.onHeroMuted, c.hero),
            };
            for (final e in pairs.entries) {
              final ratio = contrastRatio(e.value.$1, e.value.$2);
              expect(
                ratio,
                greaterThanOrEqualTo(4.5),
                reason: '${e.key}: ${ratio.toStringAsFixed(2)}:1',
              );
            }
            // the secondary accent is used for marks and chart slices: 3:1 against the card
            expect(contrastRatio(c.accent, c.surface), greaterThanOrEqualTo(3));
          },
        );
      }
    }

    test('the colours that carry meaning are the same in every palette', () {
      for (final brightness in Brightness.values) {
        final base = colorsFor(brightness, 'teal');
        for (final palette in palettes) {
          final c = colorsFor(brightness, palette.id);
          expect(c.positive, base.positive, reason: palette.id);
          expect(c.negative, base.negative, reason: palette.id);
          expect(c.warning, base.warning, reason: palette.id);
          expect(c.text, base.text, reason: palette.id);
          expect(c.textMuted, base.textMuted, reason: palette.id);
          expect(c.surface, base.surface, reason: palette.id);
          expect(c.bg, base.bg, reason: palette.id);
        }
      }
    });

    test(
      'an unknown palette falls back to the brand default instead of failing',
      () {
        expect(
          colorsFor(Brightness.light, 'does-not-exist').primary,
          SerenaColors.light.primary,
        );
        expect(
          serenaTheme(Brightness.dark, palette: 'x').colorScheme.primary,
          SerenaColors.dark.primary,
        );
      },
    );

    test('the default palette is the one the app already had', () {
      for (final brightness in Brightness.values) {
        final base = brightness == Brightness.dark
            ? SerenaColors.dark
            : SerenaColors.light;
        final c = colorsFor(brightness, 'teal');
        expect(c.primary, base.primary);
        expect(c.primaryContainer, base.primaryContainer);
        expect(c.accent, base.accent);
        expect(c.hero, base.hero);
      }
    });

    test('preferences written before palettes existed read as the default, and stay byte-identical', () {
      const old = UserPrefs(displayName: 'Ana');
      final json = old.toJson();
      expect(json.containsKey('palette'), isFalse);
      expect(json.containsKey('density'), isFalse);
      expect(json.containsKey('dailyTargets'), isFalse);
      final back = UserPrefs.fromJson(
        jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
      );
      expect(back.palette, 'teal');
      expect(back.density, 'comfortable');
      final custom = old.copyWith(palette: 'wine', density: 'compact');
      final again = UserPrefs.fromJson(
        jsonDecode(jsonEncode(custom.toJson())) as Map<String, dynamic>,
      );
      expect(again.palette, 'wine');
      expect(again.density, 'compact');
      expect(again.displayName, 'Ana');
    });
  });

  testWidgets(
    '032: choosing a palette recolours the whole app and survives a restart',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await pumpApp(tester, app);
      BuildContext ctx() =>
          tester.element(find.byType(HomeScreen, skipOffstage: false));
      expect(ctx().colors.primary, SerenaColors.light.primary);
      expect(ctx().compact, isFalse);

      await openMenu(tester, 'Configurações');
      await tester.scrollUntilVisible(
        find.text('Cor do aplicativo'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.bySemanticsLabel('Vinho'));
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(ctx());
      expect(c.read(prefsProvider).palette, 'wine');
      expect(ctx().colors.primary, colorsFor(Brightness.light, 'wine').primary);
      expect(ctx().colors.negative, SerenaColors.light.negative);

      await tester.scrollUntilVisible(
        find.text('Compacta'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Compacta'));
      await tester.pumpAndSettle();
      expect(ctx().compact, isTrue);

      // the choice is on disk: reloading brings it back
      await c.read(appControllerProvider.notifier).reload();
      await tester.pumpAndSettle();
      expect(c.read(prefsProvider).palette, 'wine');
      expect(c.read(prefsProvider).density, 'compact');

      // and one tap restores the default
      await tester.scrollUntilVisible(
        find.text('Restaurar aparência padrão'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Restaurar aparência padrão'));
      await tester.pumpAndSettle();
      expect(c.read(prefsProvider).palette, 'teal');
      expect(ctx().colors.primary, SerenaColors.light.primary);
      expect(ctx().compact, isFalse);
    },
  );

  test(
    '026: no playful or emotional wording is left in any text of the app',
    () {
      final banned = RegExp(
        r'seren[oa]s?\b|agitad|tranquil|em paz|calm[oa]\b|\bzen\b|relax',
        caseSensitive: false,
      );
      for (final file in ['lib/l10n/app_pt.arb', 'lib/l10n/app_en.arb']) {
        final arb =
            jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>;
        for (final e in arb.entries) {
          if (e.key.startsWith('@') || e.value is! String) continue;
          // the product name itself is not wording
          final text = (e.value as String).replaceAll('SerenaCash', '');
          expect(
            banned.hasMatch(text),
            isFalse,
            reason: '$file › ${e.key}: "${e.value}"',
          );
        }
      }
      final english = RegExp(
        r'serene|agitated|at peace|all calm',
        caseSensitive: false,
      );
      final en = jsonDecode(
        File('lib/l10n/app_en.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      for (final e in en.entries) {
        if (e.value is String) {
          expect(english.hasMatch(e.value as String), isFalse, reason: e.key);
        }
      }
    },
  );

  test('the version shown in the menu is the one in pubspec.yaml', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    final m = RegExp(r'version:\s*(\S+)\+(\d+)').firstMatch(line)!;
    expect(appVersion, '${m[1]} (build ${m[2]})');
  });
}
