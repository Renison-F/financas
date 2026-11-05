/// Normative tokens mirroring DESIGN.md (SerenaCash). Screens use semantic names only, never raw hex.
library;

import 'package:flutter/material.dart';

@immutable
class SerenaColors extends ThemeExtension<SerenaColors> {
  const SerenaColors({
    required this.bg,
    required this.surface,
    required this.surfaceInset,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.accent,
    required this.positive,
    required this.positiveContainer,
    required this.negative,
    required this.negativeContainer,
    required this.warning,
    required this.warningContainer,
    required this.overlay,
    required this.shadow,
    required this.hero,
    required this.onHero,
    required this.onHeroMuted,
    required this.heroDivider,
  });
  final Color bg,
      surface,
      surfaceInset,
      border,
      borderStrong,
      text,
      textMuted,
      primary,
      onPrimary,
      primaryContainer,
      onPrimaryContainer,
      accent,
      positive,
      positiveContainer,
      negative,
      negativeContainer,
      warning,
      warningContainer,
      overlay,
      shadow,
      // Summary panel of the home screen ("pode gastar"): a solid surface of the action color.
      hero,
      onHero,
      onHeroMuted,
      heroDivider;

  static const light = SerenaColors(
    bg: Color(0xFFF3F6F5),
    surface: Color(0xFFFFFFFF),
    surfaceInset: Color(0xFFE6ECEA),
    border: Color(0xFFD3DCDA),
    borderStrong: Color(0xFF74848A),
    text: Color(0xFF162022),
    textMuted: Color(0xFF4F5E61),
    primary: Color(0xFF0B5563),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD4ECEF),
    onPrimaryContainer: Color(0xFF083E48),
    accent: Color(0xFFC0703E),
    positive: Color(0xFF176B4E),
    positiveContainer: Color(0xFFD7EFE3),
    negative: Color(0xFFA93A29),
    negativeContainer: Color(0xFFF7DDD6),
    warning: Color(0xFF8A5200),
    warningContainer: Color(0xFFF6E3BE),
    overlay: Color(0x73162022),
    shadow: Color(0x24162022),
    hero: Color(0xFF0B5563),
    onHero: Color(0xFFFFFFFF),
    onHeroMuted: Color(0xFFCDE6EA),
    heroDivider: Color(0x33FFFFFF),
  );
  static const dark = SerenaColors(
    bg: Color(0xFF0C1517),
    surface: Color(0xFF152022),
    surfaceInset: Color(0xFF1E2B2E),
    border: Color(0xFF263437),
    borderStrong: Color(0xFF71818A),
    text: Color(0xFFE8EEEC),
    textMuted: Color(0xFFA3B1B3),
    primary: Color(0xFF6FC8D6),
    onPrimary: Color(0xFF0C1517),
    primaryContainer: Color(0xFF123F48),
    onPrimaryContainer: Color(0xFFC8ECF2),
    accent: Color(0xFFF0B48A),
    positive: Color(0xFF6FD3A8),
    positiveContainer: Color(0xFF134A38),
    negative: Color(0xFFF0907F),
    negativeContainer: Color(0xFF4A1F18),
    warning: Color(0xFFF2B86B),
    warningContainer: Color(0xFF4A3410),
    overlay: Color(0x8C000000),
    shadow: Color(0x80000000),
    hero: Color(0xFF123F48),
    onHero: Color(0xFFEAF7F9),
    onHeroMuted: Color(0xFFA9D3DA),
    heroDivider: Color(0x33C8ECF2),
  );

  @override
  SerenaColors copyWith() => this;

  @override
  SerenaColors lerp(ThemeExtension<SerenaColors>? other, double t) {
    if (other is! SerenaColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SerenaColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceInset: l(surfaceInset, other.surfaceInset),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primaryContainer: l(primaryContainer, other.primaryContainer),
      onPrimaryContainer: l(onPrimaryContainer, other.onPrimaryContainer),
      accent: l(accent, other.accent),
      positive: l(positive, other.positive),
      positiveContainer: l(positiveContainer, other.positiveContainer),
      negative: l(negative, other.negative),
      negativeContainer: l(negativeContainer, other.negativeContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      overlay: l(overlay, other.overlay),
      shadow: l(shadow, other.shadow),
      hero: l(hero, other.hero),
      onHero: l(onHero, other.onHero),
      onHeroMuted: l(onHeroMuted, other.onHeroMuted),
      heroDivider: l(heroDivider, other.heroDivider),
    );
  }
}

abstract final class Spacing {
  static const xxs = 4.0,
      xs = 8.0,
      sm = 12.0,
      md = 16.0,
      lg = 24.0,
      xl = 32.0,
      xxl = 48.0;
}

abstract final class Radii {
  static const xs = 6.0, sm = 10.0, md = 14.0, lg = 20.0, pill = 999.0;
}

abstract final class Touch {
  static const min = 44.0, comfortable = 52.0;

  /// Android's 48 dp floor, used where a control is not one of the standard buttons.
  static const target = 48.0;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 120),
      base = Duration(milliseconds: 220),
      slow = Duration(milliseconds: 320);
}

const displayFont = 'BricolageGrotesque';

/// Type roles from DESIGN.md. Body roles use the platform font on purpose.
abstract final class Type {
  static const moneyHero = TextStyle(
    fontFamily: displayFont,
    fontSize: 44,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const display = TextStyle(
    fontFamily: displayFont,
    fontSize: 40,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
  );
  static const headline = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );
  static const title = TextStyle(
    fontFamily: displayFont,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const body = TextStyle(
    fontSize: 17,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const bodySmall = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const label = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  static const moneyRow = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const caption = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
  );
}

extension SerenaContext on BuildContext {
  SerenaColors get colors => Theme.of(this).extension<SerenaColors>()!;
}
