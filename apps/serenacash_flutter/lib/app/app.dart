import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/security/lock_gate.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'state/app_controller.dart';
import 'theme/theme.dart';
import 'theme/tokens.dart';

export '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class SerenaCashApp extends ConsumerWidget {
  const SerenaCashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final mode = switch (prefs.theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final router = ref.watch(routerProvider);
    final locale = prefs.locale == 'en'
        ? const Locale('en')
        : prefs.locale.startsWith('pt')
        ? const Locale('pt')
        : null;
    return MaterialApp.router(
      title: 'SerenaCash',
      debugShowCheckedModeBanner: false,
      theme: serenaTheme(Brightness.light),
      darkTheme: serenaTheme(Brightness.dark),
      themeMode: mode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) => LockGate(child: child ?? const SizedBox()),
    );
  }
}

/// Shown while the encrypted database opens; an error here is fatal and explained plainly.
class BootScreen extends StatelessWidget {
  const BootScreen({super.key, this.error});
  final Object? error;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: error == null
              ? CircularProgressIndicator(color: c.primary)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).loadingError,
                      style: Type.title.copyWith(color: c.text),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      '$error',
                      style: Type.caption.copyWith(color: c.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
