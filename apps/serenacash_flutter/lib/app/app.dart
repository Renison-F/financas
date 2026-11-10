import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/security/lock_gate.dart';
import '../l10n/app_localizations.dart';
import '../data/security/local_vault.dart';
import 'di.dart';
import 'reminders_host.dart';
import 'router.dart';
import 'state/app_controller.dart';
import 'theme/appearance.dart';
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
      theme: themeFor(Brightness.light, prefs),
      darkTheme: themeFor(Brightness.dark, prefs),
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
      builder: (context, child) => AppearanceMedia(
        textSize: prefs.textSize,
        reduceMotion: prefs.motion == 'reduced',
        child: RemindersHost(child: LockGate(child: child ?? const SizedBox())),
      ),
    );
  }
}

/// Shown while the encrypted database opens. When it cannot open, says why in plain words and gives
/// the two ways forward: try again, or erase the local data and start over (a backup exported earlier
/// can be restored afterwards). Nothing is erased or regenerated without that explicit choice.
class BootScreen extends ConsumerStatefulWidget {
  const BootScreen({super.key, this.error});
  final Object? error;
  @override
  ConsumerState<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends ConsumerState<BootScreen> {
  bool _busy = false;

  void _retry() {
    final container = ProviderScope.containerOf(context, listen: false);
    container.invalidate(databaseProvider);
    container.invalidate(appControllerProvider);
  }

  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.bootResetQ),
        content: Text(l.bootResetText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.eraseConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await eraseLocalData(container);
      container.invalidate(appControllerProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final error = widget.error;
    if (error == null || _busy) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(child: CircularProgressIndicator(color: c.primary)),
      );
    }
    final reason = switch (error) {
      VaultError(kind: VaultErrorKind.keyMissing) => l.bootKeyMissing,
      VaultError(kind: VaultErrorKind.keyInvalid) => l.bootKeyInvalid,
      _ => l.bootGeneric,
    };
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.loadingError,
                    style: Type.headline.copyWith(color: c.text),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    reason,
                    style: Type.body.copyWith(color: c.text),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    l.bootRecoverHelp,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.lg),
                  FilledButton(onPressed: _retry, child: Text(l.bootRetry)),
                  const SizedBox(height: Spacing.xs),
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(foregroundColor: c.negative),
                    child: Text(l.bootReset),
                  ),
                  const SizedBox(height: Spacing.md),
                  // The type of failure only: never keys, paths with user data or amounts.
                  Text(
                    l.bootDetails(error.runtimeType.toString()),
                    style: Type.caption.copyWith(color: c.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
