/// Material 3 ThemeData built from the SerenaCash tokens; light, dark and system (ThemeMode) are supported.
library;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData serenaTheme(Brightness brightness) {
  final c = brightness == Brightness.dark
      ? SerenaColors.dark
      : SerenaColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.primaryContainer,
    onPrimaryContainer: c.onPrimaryContainer,
    secondary: c.accent,
    onSecondary: c.onPrimary,
    error: c.negative,
    onError: c.onPrimary,
    errorContainer: c.negativeContainer,
    onErrorContainer: c.negative,
    surface: c.surface,
    onSurface: c.text,
    surfaceContainerHighest: c.surfaceInset,
    onSurfaceVariant: c.textMuted,
    outline: c.borderStrong,
    outlineVariant: c.border,
    shadow: c.shadow,
    scrim: c.overlay,
    inverseSurface: c.text,
    onInverseSurface: c.surface,
    inversePrimary: c.primaryContainer,
    tertiary: c.positive,
    onTertiary: c.onPrimary,
    tertiaryContainer: c.positiveContainer,
    onTertiaryContainer: c.positive,
    surfaceTint: Colors.transparent,
  );
  final text = TextTheme(
    displayLarge: Type.display.copyWith(color: c.text),
    headlineMedium: Type.headline.copyWith(color: c.text),
    titleLarge: Type.title.copyWith(color: c.text),
    titleMedium: Type.body.copyWith(color: c.text, fontWeight: FontWeight.w600),
    bodyLarge: Type.body.copyWith(color: c.text),
    bodyMedium: Type.bodySmall.copyWith(color: c.text),
    bodySmall: Type.caption.copyWith(color: c.textMuted),
    labelLarge: Type.label.copyWith(color: c.text, fontSize: 16),
    labelMedium: Type.label.copyWith(color: c.text),
    labelSmall: Type.caption.copyWith(color: c.textMuted),
  );
  final shape14 = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.md),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    textTheme: text,
    extensions: [c],
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: Type.title.copyWith(color: c.text),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        minimumSize: const Size(0, Touch.comfortable),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: shape14,
        textStyle: Type.label.copyWith(fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: const Size(0, Touch.min),
        shape: shape14,
        textStyle: Type.label.copyWith(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.onPrimaryContainer,
        backgroundColor: c.primaryContainer,
        side: BorderSide.none,
        minimumSize: const Size(0, Touch.comfortable),
        shape: shape14,
        textStyle: Type.label.copyWith(fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: Type.body.copyWith(color: c.textMuted),
      labelStyle: Type.label.copyWith(color: c.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.borderStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.borderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.negative),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.negative, width: 2),
      ),
      errorStyle: Type.caption.copyWith(color: c.negative),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surfaceInset,
      selectedColor: c.primaryContainer,
      labelStyle: Type.label.copyWith(color: c.text, fontSize: 14),
      secondaryLabelStyle: Type.label.copyWith(
        color: c.onPrimaryContainer,
        fontSize: 14,
      ),
      shape: const StadiumBorder(),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showCheckmark: true,
      checkmarkColor: c.onPrimaryContainer,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(c.surface),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.primary : c.borderStrong,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primaryContainer,
      indicatorShape: const StadiumBorder(),
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => Type.label.copyWith(
          fontSize: 11,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
          color: s.contains(WidgetState.selected)
              ? c.onPrimaryContainer
              : c.textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? c.primary : c.textMuted,
          size: 24,
        ),
      ),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      ),
      showDragHandle: true,
      dragHandleColor: c.border,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.text,
      contentTextStyle: Type.bodySmall.copyWith(color: c.surface),
      actionTextColor: c.primaryContainer,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 8,
      iconColor: c.textMuted,
      textColor: c.text,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.surfaceInset,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
