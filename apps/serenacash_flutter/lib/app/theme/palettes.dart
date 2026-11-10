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

/// The colours of the app for a brightness and a palette.
SerenaColors colorsFor(Brightness brightness, String paletteId) {
  final base = brightness == Brightness.dark
      ? SerenaColors.dark
      : SerenaColors.light;
  final palette = paletteById(paletteId);
  final p = brightness == Brightness.dark ? palette.dark : palette.light;
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
