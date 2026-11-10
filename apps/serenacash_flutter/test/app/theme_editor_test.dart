/// Ocorrência 032 (complemento): editor de tema com trava de contraste, estilos de cartão, tamanho
/// do texto, movimento reduzido e gráficos compactos. Nada disto muda as cores de sinal.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/theme/appearance.dart';
import 'package:serenacash/app/theme/palettes.dart';
import 'package:serenacash/app/theme/tokens.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:go_router/go_router.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/features/settings/theme_editor_screen.dart';
import 'package:serenacash/l10n/app_localizations.dart';
import 'package:serenacash/ui/components/components.dart';

import 'harness.dart';
import 'kv_factory.dart';

final _l = lookupAppLocalizations(const Locale('pt'));

BuildContext _home(WidgetTester tester) =>
    tester.element(find.byType(HomeScreen, skipOffstage: false));

/// The real app, already past the first-run screens. Returns its provider container.
Future<ProviderContainer> _boot(
  WidgetTester tester, {
  bool phone = true,
}) async {
  if (phone) await setPhone(tester);
  final app = TestApp();
  addTearDown(app.dispose);
  await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
  await pumpApp(tester, app);
  return ProviderScope.containerOf(_home(tester));
}

Future<void> _go(WidgetTester tester, String route) async {
  unawaited(GoRouter.of(_home(tester)).push(route));
  await tester.pumpAndSettle();
}

/// Colours a user could pick, including the ones that cannot be read as they are.
const _seeds = <String, Color>{
  'amarelo vivo': Color(0xFFFFEB3B),
  'branco': Color(0xFFFFFFFF),
  'preto': Color(0xFF000000),
  'vermelho': Color(0xFFE53935),
  'rosa claro': Color(0xFFF8BBD0),
  'verde limão': Color(0xFFC6FF00),
  'azul': Color(0xFF1565C0),
  'cinza médio': Color(0xFF808080),
  'laranja': Color(0xFFFF6D00),
  'roxo': Color(0xFF6A1B9A),
};

void main() {
  setUpAll(loadTestFonts);

  group('032: custom palette', () {
    for (final seed in _seeds.entries) {
      for (final brightness in Brightness.values) {
        test(
          '${seed.key} / ${brightness.name}: every tone derived from it can be read',
          () {
            // the worst case: the same colour for both seeds
            final c = colorsFor(
              brightness,
              customPaletteId,
              custom: CustomSeeds(seed.value, seed.value),
            );
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
                greaterThanOrEqualTo(minTextContrast),
                reason: '${e.key}: ${ratio.toStringAsFixed(2)}:1',
              );
            }
            expect(
              contrastRatio(c.accent, c.surface),
              greaterThanOrEqualTo(minMarkContrast),
            );
          },
        );
      }
    }

    test('a colour that can already be read is used exactly as chosen in the light theme', () {
      const chosen = Color(0xFF1565C0);
      expect(readableOnLight(chosen), isTrue);
      final c = colorsFor(
        Brightness.light,
        customPaletteId,
        custom: const CustomSeeds(chosen, Color(0xFFB45309)),
      );
      expect(c.primary, chosen);
      expect(c.accent, const Color(0xFFB45309));
    });

    test('a colour too light is refused, and the correction keeps its hue', () {
      const yellow = Color(0xFFFFEB3B);
      expect(readableOnLight(yellow), isFalse);
      final fixed = readableTone(yellow);
      expect(readableOnLight(fixed), isTrue);
      expect(
        (HSLColor.fromColor(fixed).hue - HSLColor.fromColor(yellow).hue).abs(),
        lessThan(2),
      );
      // already readable: nothing changes
      expect(readableTone(const Color(0xFF0B5563)), const Color(0xFF0B5563));
    });

    test(
      'the colours that carry meaning do not follow the palette the user made',
      () {
        for (final brightness in Brightness.values) {
          final base = colorsFor(brightness, 'teal');
          final c = colorsFor(
            brightness,
            customPaletteId,
            custom: const CustomSeeds(Color(0xFFE53935), Color(0xFF2E7D32)),
          );
          expect(c.positive, base.positive);
          expect(c.negative, base.negative);
          expect(c.warning, base.warning);
          expect(c.text, base.text);
          expect(c.surface, base.surface);
          expect(c.bg, base.bg);
        }
      },
    );

    test('"custom" without colours saved falls back to the brand default', () {
      expect(
        colorsFor(Brightness.light, customPaletteId).primary,
        SerenaColors.light.primary,
      );
      expect(CustomSeeds.fromArgb(null, null), isNull);
    });

    test(
      'colour codes: accepted with or without #, refused when malformed',
      () {
        expect(parseHex('#0b5563'), const Color(0xFF0B5563));
        expect(parseHex(' 0B5563 '), const Color(0xFF0B5563));
        expect(parseHex('#0B55'), isNull);
        expect(parseHex('#GGGGGG'), isNull);
        expect(parseHex(''), isNull);
        expect(hexOf(const Color(0xFF0B5563)), '#0B5563');
      },
    );
  });

  group('032: preferences', () {
    test('new appearance fields default when absent and are written only when changed', () {
      const old = UserPrefs(displayName: 'Ana');
      final json = old.toJson();
      for (final k in [
        'customPrimary',
        'customAccent',
        'cardStyle',
        'chartStyle',
        'motion',
        'textSize',
        'productLookup',
        'dailyAlerts',
      ]) {
        expect(json.containsKey(k), isFalse, reason: k);
      }
      final back = UserPrefs.fromJson(
        jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
      );
      expect(back.cardStyle, 'flat');
      expect(back.chartStyle, 'detailed');
      expect(back.motion, 'system');
      expect(back.textSize, 'standard');
      expect(isDefaultAppearance(back), isTrue);
    });

    test('a full appearance survives a round trip and "restore" keeps the custom colours', () {
      const p = UserPrefs(
        palette: customPaletteId,
        customPrimary: 0xFF1565C0,
        customAccent: 0xFFB45309,
        cardStyle: 'elevated',
        chartStyle: 'compact',
        motion: 'reduced',
        textSize: 'larger',
        density: 'compact',
      );
      final back = UserPrefs.fromJson(
        jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>,
      );
      expect(back.palette, customPaletteId);
      expect(back.customPrimary, 0xFF1565C0);
      expect(back.customAccent, 0xFFB45309);
      expect(back.cardStyle, 'elevated');
      expect(back.chartStyle, 'compact');
      expect(back.motion, 'reduced');
      expect(back.textSize, 'larger');
      expect(isDefaultAppearance(back), isFalse);
      final reset = withDefaultAppearance(back);
      expect(isDefaultAppearance(reset), isTrue);
      expect(reset.customPrimary, 0xFF1565C0, reason: 'continua disponível');
    });

    test('unknown values read as the default instead of failing', () {
      expect(cardStyleOf('???'), CardStyle.flat);
      expect(textFactorOf('???'), 1);
      final t = themeFor(
        Brightness.light,
        const UserPrefs(cardStyle: 'x', chartStyle: 'y'),
      );
      expect(t.extension<SerenaLook>()!.cardStyle, CardStyle.flat);
      expect(t.extension<SerenaLook>()!.compactCharts, isFalse);
    });

    test('text size multiplies the device size and stops at the ceiling', () {
      const device = TextScaler.linear(1.3);
      expect(const AppTextScaler(device, 1.2).scale(10), closeTo(15.6, 1e-9));
      // 1.8 × 1.2 would be 2.16: held at 2.0
      expect(
        const AppTextScaler(TextScaler.linear(1.8), 1.2).scale(10),
        closeTo(20, 1e-9),
      );
      // the device already asks for more than the ceiling: the device wins, the app adds nothing
      expect(
        const AppTextScaler(TextScaler.linear(2.4), 1.2).scale(10),
        closeTo(24, 1e-9),
      );
    });
  });

  group('032: in the app', () {
    testWidgets('card style, text size and reduced motion reach every screen', (
      tester,
    ) async {
      final c = await _boot(tester);
      final ctl = c.read(appControllerProvider.notifier);
      BuildContext ctx() => tester.element(find.byType(SCard).first);

      expect(ctx().look.cardStyle, CardStyle.flat);
      expect(ctx().reduceMotion, isFalse);
      final before = MediaQuery.textScalerOf(ctx()).scale(10);

      await ctl.setPrefs(
        (p) => p.copyWith(
          cardStyle: 'outlined',
          textSize: 'large',
          motion: 'reduced',
          chartStyle: 'compact',
        ),
      );
      await tester.pumpAndSettle();

      expect(ctx().look.cardStyle, CardStyle.outlined);
      expect(ctx().look.compactCharts, isTrue);
      expect(ctx().reduceMotion, isTrue);
      expect(
        MediaQuery.textScalerOf(ctx()).scale(10),
        closeTo(before * 1.1, 1e-9),
      );
      expect(tester.takeException(), isNull);

      for (final style in ['elevated', 'tinted', 'flat']) {
        await ctl.setPrefs((p) => p.copyWith(cardStyle: style));
        await tester.pumpAndSettle();
        expect(ctx().look.cardStyle, cardStyleOf(style));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
      'editor: an unreadable colour cannot be applied until it is corrected',
      (tester) async {
        final c = await _boot(tester);
        await _go(tester, '/settings/theme');
        final l = _l;
        expect(find.text(l.themeEditorTitle), findsOneWidget);
        expect(find.byType(ThemePreview), findsOneWidget);

        // starts from the colours in use, which are readable
        SButton apply() =>
            tester.widget<SButton>(find.widgetWithText(SButton, l.themeApply));
        await tester.scrollUntilVisible(
          find.widgetWithText(SButton, l.themeApply),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(apply().onPressed, isNotNull);

        // a yellow that cannot be read on a light screen
        await tester.scrollUntilVisible(
          find.bySemanticsLabel(l.themeHexOf(l.themePrimary)),
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(find.byType(TextField).first, '#FFEB3B');
        await tester.pumpAndSettle();
        expect(find.textContaining('4,5:1'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.widgetWithText(SButton, l.themeApply),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(apply().onPressed, isNull, reason: 'recusada');

        // one touch brings it to the nearest readable tone
        await tester.scrollUntilVisible(
          find.text(l.themeFix),
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(l.themeFix));
        await tester.pumpAndSettle();
        expect(find.text(l.themeFix), findsNothing);
        await tester.scrollUntilVisible(
          find.widgetWithText(SButton, l.themeApply),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(apply().onPressed, isNotNull);
        await tester.tap(find.widgetWithText(SButton, l.themeApply));
        await tester.pumpAndSettle();

        final p = c.read(prefsProvider);
        expect(p.palette, customPaletteId);
        final saved = Color(p.customPrimary!);
        expect(readableOnLight(saved), isTrue);
        expect(
          Theme.of(tester.element(find.byType(SCard).first))
              .colorScheme
              .primary,
          saved,
          reason: 'o tema do app passou a usar a cor escolhida',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('editor on a small screen with large text has no overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await _boot(tester, phone: false);
      await c
          .read(appControllerProvider.notifier)
          .setPrefs((p) => p.copyWith(textSize: 'larger', theme: 'dark'));
      await tester.pumpAndSettle();
      await _go(tester, '/settings/theme');
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      GoRouter.of(_home(tester)).pop();
      await tester.pumpAndSettle();
      await _go(tester, '/settings');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
