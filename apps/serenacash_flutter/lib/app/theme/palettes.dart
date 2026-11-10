/// Colour palettes the user can choose. A palette changes the accent of the app: the action colour,
/// its containers, the secondary accent and the summary panel. It never touches the colours that
/// carry meaning (income, expense, warning), the text or the surfaces: those stay what they are in
/// every palette, light and dark.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

class Palette {
  const Palette({required this.id, required this.light, required this.dark});
  final String id;
  final PaletteColors light, dark;
}

class PaletteColors {
  const PaletteColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.accent,
    required this.hero,
    required this.onHero,
    required this.onHeroMuted,
  });
  final Color primary,
      onPrimary,
      primaryContainer,
      onPrimaryContainer,
      accent,
      hero,
      onHero,
      onHeroMuted;
}

const _white = Color(0xFFFFFFFF), _ink = Color(0xFF0C1517);

/// The palettes, in the order they are offered. `teal` is the brand default.
const palettes = <Palette>[
  Palette(
    id: 'teal',
    light: PaletteColors(
      primary: Color(0xFF0B5563),
      onPrimary: _white,
      primaryContainer: Color(0xFFD4ECEF),
      onPrimaryContainer: Color(0xFF083E48),
      accent: Color(0xFFC0703E),
      hero: Color(0xFF0B5563),
      onHero: _white,
      onHeroMuted: Color(0xFFCDE6EA),
    ),
    dark: PaletteColors(
      primary: Color(0xFF6FC8D6),
      onPrimary: _ink,
      primaryContainer: Color(0xFF123F48),
      onPrimaryContainer: Color(0xFFC8ECF2),
      accent: Color(0xFFF0B48A),
      hero: Color(0xFF123F48),
      onHero: Color(0xFFEAF7F9),
      onHeroMuted: Color(0xFFA9D3DA),
    ),
  ),
  Palette(
    id: 'blue',
    light: PaletteColors(
      primary: Color(0xFF1D4E89),
      onPrimary: _white,
      primaryContainer: Color(0xFFD9E6F5),
      onPrimaryContainer: Color(0xFF123560),
      accent: Color(0xFFB8621B),
      hero: Color(0xFF1D4E89),
      onHero: _white,
      onHeroMuted: Color(0xFFCFE0F3),
    ),
    dark: PaletteColors(
      primary: Color(0xFF8DB8EE),
      onPrimary: _ink,
      primaryContainer: Color(0xFF1B3A5F),
      onPrimaryContainer: Color(0xFFD4E4F8),
      accent: Color(0xFFF0B48A),
      hero: Color(0xFF1B3A5F),
      onHero: Color(0xFFEEF4FB),
      onHeroMuted: Color(0xFFB4CDEA),
    ),
  ),
  Palette(
    id: 'green',
    light: PaletteColors(
      primary: Color(0xFF1F6B45),
      onPrimary: _white,
      primaryContainer: Color(0xFFD8EEDF),
      onPrimaryContainer: Color(0xFF134A30),
      accent: Color(0xFF8A5A14),
      hero: Color(0xFF1F6B45),
      onHero: _white,
      onHeroMuted: Color(0xFFCFE9D8),
    ),
    dark: PaletteColors(
      primary: Color(0xFF7FD0A0),
      onPrimary: _ink,
      primaryContainer: Color(0xFF184A31),
      onPrimaryContainer: Color(0xFFCFEFDB),
      accent: Color(0xFFE9C27A),
      hero: Color(0xFF184A31),
      onHero: Color(0xFFEDF8F1),
      onHeroMuted: Color(0xFFAEDBC0),
    ),
  ),
  Palette(
    id: 'terracotta',
    light: PaletteColors(
      primary: Color(0xFF9A4A22),
      onPrimary: _white,
      primaryContainer: Color(0xFFF6E0D2),
      onPrimaryContainer: Color(0xFF6B3115),
      accent: Color(0xFF0B5563),
      hero: Color(0xFF9A4A22),
      onHero: _white,
      onHeroMuted: Color(0xFFF3D9C8),
    ),
    dark: PaletteColors(
      primary: Color(0xFFF0B48A),
      onPrimary: _ink,
      primaryContainer: Color(0xFF5A2E14),
      onPrimaryContainer: Color(0xFFFBE3D2),
      accent: Color(0xFF6FC8D6),
      hero: Color(0xFF5A2E14),
      onHero: Color(0xFFFDF1E8),
      onHeroMuted: Color(0xFFE8C3AA),
    ),
  ),
  Palette(
    id: 'graphite',
    light: PaletteColors(
      primary: Color(0xFF36454F),
      onPrimary: _white,
      primaryContainer: Color(0xFFE1E6E9),
      onPrimaryContainer: Color(0xFF232F37),
      accent: Color(0xFFC0703E),
      hero: Color(0xFF36454F),
      onHero: _white,
      onHeroMuted: Color(0xFFD5DDE2),
    ),
    dark: PaletteColors(
      primary: Color(0xFFB8C4CC),
      onPrimary: _ink,
      primaryContainer: Color(0xFF2E3A42),
      onPrimaryContainer: Color(0xFFE1E8EC),
      accent: Color(0xFFF0B48A),
      hero: Color(0xFF2E3A42),
      onHero: Color(0xFFF1F4F6),
      onHeroMuted: Color(0xFFC0CBD2),
    ),
  ),
  Palette(
    id: 'wine',
    light: PaletteColors(
      primary: Color(0xFF7A2E4A),
      onPrimary: _white,
      primaryContainer: Color(0xFFF4DCE4),
      onPrimaryContainer: Color(0xFF551F33),
      accent: Color(0xFF8A5A14),
      hero: Color(0xFF7A2E4A),
      onHero: _white,
      onHeroMuted: Color(0xFFF0D3DD),
    ),
    dark: PaletteColors(
      primary: Color(0xFFEBA3BC),
      onPrimary: _ink,
      primaryContainer: Color(0xFF55263A),
      onPrimaryContainer: Color(0xFFF8DCE6),
      accent: Color(0xFFE9C27A),
      hero: Color(0xFF55263A),
      onHero: Color(0xFFFCEFF3),
      onHeroMuted: Color(0xFFE2B6C6),
    ),
  ),
];

Palette paletteById(String id) =>
    palettes.firstWhere((p) => p.id == id, orElse: () => palettes.first);

/// Id of the palette the user made in the theme editor.
const customPaletteId = 'custom';

/// Minimum contrast of text (WCAG AA) and of marks such as icons and chart slices.
const minTextContrast = 4.5, minMarkContrast = 3.0;

/// The two colours the user chooses; every other tone of a custom palette comes from them.
class CustomSeeds {
  const CustomSeeds(this.primary, this.accent);
  final Color primary, accent;

  /// Seeds stored in the preferences, or null when the user never made a palette.
  static CustomSeeds? fromArgb(int? primary, int? accent) => primary == null
      ? null
      : CustomSeeds(
          Color(primary | 0xFF000000),
          Color((accent ?? primary) | 0xFF000000),
        );
}

Color _hsl(double hue, double saturation, double lightness) =>
    HSLColor.fromAHSL(
      1,
      hue % 360,
      saturation.clamp(0.0, 1.0),
      lightness.clamp(0.0, 1.0),
    ).toColor();

/// [c] with its lightness moved away from [against], one step at a time, until the pair reaches
/// [min]. The hue is kept; a colour that already passes comes back unchanged.
Color ensureContrast(Color c, Color against, double min) {
  if (contrastRatio(c, against) >= min) return c;
  final hsl = HSLColor.fromColor(c);
  final darken = _luminance(against) > 0.4;
  var l = hsl.lightness;
  while (l > 0 && l < 1) {
    l = (l + (darken ? -0.01 : 0.01)).clamp(0.0, 1.0);
    final next = hsl.withLightness(l).toColor();
    if (contrastRatio(next, against) >= min) return next;
  }
  return darken ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
}

Color _onColor(Color background) =>
    contrastRatio(_white, background) >= minTextContrast ? _white : _ink;

/// The action colour as it must be to be read on the light theme: this is what the theme editor
/// requires of the colour chosen before it lets the user apply it.
bool readableOnLight(Color primary) =>
    contrastRatio(primary, SerenaColors.light.bg) >= minTextContrast &&
    contrastRatio(primary, SerenaColors.light.surface) >= minTextContrast;

/// Same for the secondary colour, used for marks and chart slices (3:1).
bool visibleOnLight(Color accent) =>
    contrastRatio(accent, SerenaColors.light.surface) >= minMarkContrast;

/// The nearest tone of [primary] that can be read on the light theme.
Color readableTone(Color primary) => ensureContrast(
  ensureContrast(primary, SerenaColors.light.bg, minTextContrast),
  SerenaColors.light.surface,
  minTextContrast,
);

/// The nearest tone of [accent] that shows on a light card.
Color visibleTone(Color accent) =>
    ensureContrast(accent, SerenaColors.light.surface, minMarkContrast);

/// The tones of a palette made by the user. In the light theme the action colour is the one
/// chosen (darkened only if it could not be read); in the dark theme it is a lighter tone of the
/// same hue. Every pair used for text is brought to 4.5:1, so no choice can produce an
/// unreadable screen, including preferences edited by hand or restored from a backup.
PaletteColors customColors(CustomSeeds seeds, Brightness brightness) {
  final hp = HSLColor.fromColor(seeds.primary);
  final ha = HSLColor.fromColor(seeds.accent);
  if (brightness == Brightness.light) {
    final primary = readableTone(seeds.primary);
    final onPrimary = _onColor(primary);
    final container = _hsl(hp.hue, math.min(hp.saturation, 0.55), 0.9);
    return PaletteColors(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: container,
      onPrimaryContainer: ensureContrast(
        _hsl(hp.hue, hp.saturation, 0.22),
        container,
        minTextContrast,
      ),
      accent: visibleTone(seeds.accent),
      hero: primary,
      onHero: onPrimary,
      onHeroMuted: ensureContrast(
        Color.lerp(onPrimary, primary, 0.2)!,
        primary,
        minTextContrast,
      ),
    );
  }
  final dark = SerenaColors.dark;
  final primary = ensureContrast(
    ensureContrast(
      _hsl(hp.hue, math.min(hp.saturation, 0.65), math.max(hp.lightness, 0.66)),
      dark.surface,
      minTextContrast,
    ),
    dark.bg,
    minTextContrast,
  );
  final container = _hsl(hp.hue, math.min(hp.saturation, 0.6), 0.19);
  return PaletteColors(
    primary: primary,
    onPrimary: _onColor(primary),
    primaryContainer: container,
    onPrimaryContainer: ensureContrast(
      _hsl(hp.hue, math.min(hp.saturation, 0.55), 0.88),
      container,
      minTextContrast,
    ),
    accent: ensureContrast(
      _hsl(ha.hue, math.min(ha.saturation, 0.75), math.max(ha.lightness, 0.7)),
      dark.surface,
      minMarkContrast,
    ),
    hero: container,
    onHero: ensureContrast(
      _hsl(hp.hue, 0.35, 0.95),
      container,
      minTextContrast,
    ),
    onHeroMuted: ensureContrast(
      _hsl(hp.hue, 0.35, 0.78),
      container,
      minTextContrast,
    ),
  );
}

/// The colours of the app for a brightness and a palette. [custom] is used when the palette is the
/// one made by the user; without seeds that id falls back to the brand default.
SerenaColors colorsFor(
  Brightness brightness,
  String paletteId, {
  CustomSeeds? custom,
}) {
  final base = brightness == Brightness.dark
      ? SerenaColors.dark
      : SerenaColors.light;
  final palette = paletteById(paletteId);
  final p = paletteId == customPaletteId && custom != null
      ? customColors(custom, brightness)
      : brightness == Brightness.dark
      ? palette.dark
      : palette.light;
  return SerenaColors(
    bg: base.bg,
    surface: base.surface,
    surfaceInset: base.surfaceInset,
    border: base.border,
    borderStrong: base.borderStrong,
    text: base.text,
    textMuted: base.textMuted,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.primaryContainer,
    onPrimaryContainer: p.onPrimaryContainer,
    accent: p.accent,
    positive: base.positive,
    positiveContainer: base.positiveContainer,
    negative: base.negative,
    negativeContainer: base.negativeContainer,
    warning: base.warning,
    warningContainer: base.warningContainer,
    overlay: base.overlay,
    shadow: base.shadow,
    hero: p.hero,
    onHero: p.onHero,
    onHeroMuted: p.onHeroMuted,
    heroDivider: p.onHero.withValues(alpha: 0.2),
  );
}

double _channel(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

/// WCAG contrast ratio between two opaque colours (1 to 21).
double contrastRatio(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
