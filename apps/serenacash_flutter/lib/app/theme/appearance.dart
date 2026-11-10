/// The appearance preferences of the user turned into what Flutter consumes: a theme for each
/// brightness, and the text size and motion flags of the [MediaQuery] the whole app reads.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';
import 'palettes.dart';
import 'theme.dart';
import 'tokens.dart';

/// Ids of the text sizes, smallest first, and what each multiplies the device size by.
const textSizes = <String, double>{'standard': 1, 'large': 1.1, 'larger': 1.2};

double textFactorOf(String id) => textSizes[id] ?? 1;

/// The text size of the app never pushes text past this multiple of its design size. When the
/// device already asks for more than that, the device wins and the app adds nothing.
const maxTextScale = 2.0;

CustomSeeds? customSeedsOf(UserPrefs p) =>
    CustomSeeds.fromArgb(p.customPrimary, p.customAccent);

ThemeData themeFor(Brightness brightness, UserPrefs p) => serenaTheme(
  brightness,
  palette: p.palette,
  compact: p.density == 'compact',
  custom: customSeedsOf(p),
  look: SerenaLook(
    cardStyle: cardStyleOf(p.cardStyle),
    compactCharts: p.chartStyle == 'compact',
  ),
);

/// True when every appearance preference is the one the app ships with.
bool isDefaultAppearance(UserPrefs p) =>
    p.palette == 'teal' &&
    p.density == 'comfortable' &&
    p.cardStyle == 'flat' &&
    p.chartStyle == 'detailed' &&
    p.motion == 'system' &&
    p.textSize == 'standard';

/// [p] with the appearance back to the default. The theme (light, dark, system) is not an
/// appearance preference in this sense and is kept, and so are the colours of a palette the user
/// made: they stay available to be chosen again.
UserPrefs withDefaultAppearance(UserPrefs p) => p.copyWith(
  palette: 'teal',
  density: 'comfortable',
  cardStyle: 'flat',
  chartStyle: 'detailed',
  motion: 'system',
  textSize: 'standard',
);

/// The text scale of the device multiplied by the size chosen in the app.
@immutable
class AppTextScaler extends TextScaler {
  const AppTextScaler(this.device, this.factor);
  final TextScaler device;
  final double factor;

  @override
  double scale(double fontSize) {
    final base = device.scale(fontSize);
    return math.min(base * factor, math.max(base, fontSize * maxTextScale));
  }

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is AppTextScaler &&
      other.device == device &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(device, factor);
}

/// Applies the text size and the reduced motion chosen in the app on top of what the device says.
/// It sits above every screen, sheet and dialog.
class AppearanceMedia extends StatelessWidget {
  const AppearanceMedia({
    super.key,
    required this.textSize,
    required this.reduceMotion,
    required this.child,
  });
  final String textSize;
  final bool reduceMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final factor = textFactorOf(textSize);
    if (factor == 1 && !reduceMotion) return child;
    return MediaQuery(
      data: mq.copyWith(
        textScaler: factor == 1
            ? mq.textScaler
            : AppTextScaler(mq.textScaler, factor),
        disableAnimations: mq.disableAnimations || reduceMotion,
      ),
      child: child,
    );
  }
}
