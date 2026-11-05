/// Locks the UI behind biometrics and/or PIN when the preference is on; locks again on background.
/// PIN attempts are throttled, and there is always a stated way out for someone who cannot unlock:
/// erase the local data and start over (a backup can be restored afterwards).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../app/app.dart';
import '../../app/di.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../data/security/window_security.dart';
import '../../domain/entities/entities.dart';
import '../../ui/components/components.dart';

final localAuthProvider = Provider<LocalAuthentication>(
  (_) => LocalAuthentication(),
);

/// "1:05" for a pause still running.
String lockCountdown(Duration d) {
  final total = d.inSeconds + (d.inMilliseconds % 1000 > 0 ? 1 : 0);
  final m = total ~/ 60, s = total % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _tried = false;
  String? _error;
  final _pin = TextEditingController();

  /// Remaining pause after too many wrong PINs; refreshed every second while it lasts.
  Duration? _pause;
  Timer? _ticker;
  bool _pauseChecked = false;
  bool? _secureApplied;

  bool get _required {
    final p = ref.read(prefsProvider);
    return p.biometricLock || p.pinEnabled;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _pin.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        _required &&
        ref.read(prefsProvider).lockOnBackground) {
      setState(() {
        _unlocked = false;
        _tried = false;
        _error = null;
        _pauseChecked = false;
      });
    }
  }

  Future<void> _biometrics() async {
    final l = context.l10n;
    setState(() => _error = null);
    try {
      final auth = ref.read(localAuthProvider);
      final ok = await auth.authenticate(
        localizedReason: l.unlockPrompt,
        biometricOnly: false,
      );
      if (!mounted) return;
      setState(() {
        _unlocked = ok;
        _error = ok ? null : l.biometricFailed;
      });
    } catch (_) {
      if (mounted) setState(() => _error = l.biometricUnavailable);
    }
  }

  void _watchPause(Duration? pause) {
    _ticker?.cancel();
    _pause = pause;
    if (pause == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final left = await ref.read(pinManagerProvider).lockedFor();
      if (!mounted) return;
      setState(() {
        _pause = left;
        if (left == null) {
          _error = null;
          _ticker?.cancel();
        }
      });
    });
  }

  /// A pause started before the app was closed is still in force when it opens again.
  Future<void> _loadPause() async {
    final left = await ref.read(pinManagerProvider).lockedFor();
    if (mounted && left != null) setState(() => _watchPause(left));
  }

  Future<void> _checkPin() async {
    if (_pause != null) return;
    final l = context.l10n;
    final r = await ref.read(pinManagerProvider).check(_pin.text);
    if (!mounted) return;
    setState(() {
      _unlocked = r.ok;
      _watchPause(r.lockedFor);
      _error = r.ok || r.lockedFor != null
          ? null
          : (r.attemptsLeft != null && r.attemptsLeft! <= 2
                ? l.pinAttemptsLeft(r.attemptsLeft!)
                : l.pinWrong);
    });
    _pin.clear();
  }

  /// The stated way out: nothing is recovered, the local data is erased and the app starts over.
  ///
  /// [sheetContext] is the lock screen's own context: this widget sits above the app Navigator, so
  /// only the lock screen has a Navigator to show the sheets on.
  Future<void> _recover(BuildContext sheetContext, UserPrefs p) async {
    final l = context.l10n;
    final container = ProviderScope.containerOf(context, listen: false);
    final go = await confirmSheet(
      sheetContext,
      title: p.pinEnabled ? l.pinForgotTitle : l.lockRecover,
      text: p.pinEnabled ? l.pinForgotText : l.lockRecoverText,
      confirmLabel: l.bootReset,
      cancelLabel: l.cancel,
    );
    if (!go || !mounted || !sheetContext.mounted) return;
    final sure = await confirmSheet(
      sheetContext,
      title: l.bootResetQ,
      text: l.bootResetText,
      confirmLabel: l.eraseConfirm,
      cancelLabel: l.cancel,
    );
    if (!sure) return;
    await eraseLocalData(container);
    container.invalidate(appControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    if (!app.hasValue) return widget.child;
    final p = app.value!.ledger.prefs;
    final required = p.biometricLock || p.pinEnabled;
    // With a lock on, the window is also kept out of screenshots and of the recent-apps thumbnail.
    if (_secureApplied != required) {
      _secureApplied = required;
      unawaited(ref.read(windowSecurityProvider).setSecure(required));
    }
    if (!required || _unlocked) return widget.child;
    if (p.biometricLock && !_tried) {
      _tried = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometrics());
    }
    if (p.pinEnabled && !_pauseChecked) {
      _pauseChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPause());
    }
    final c = context.colors;
    final l = context.l10n;
    // LockGate sits in MaterialApp.builder, above the app Navigator, so the lock screen needs its own
    // Navigator (sheets, the keyboard overlay): without one the PIN field throws on every edit.
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (context) => _lockScreen(context, c, l, p),
      ),
    );
  }

  Widget _lockScreen(
    BuildContext context,
    SerenaColors c,
    AppLocalizations l,
    UserPrefs p,
  ) {
    final paused = _pause != null;
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
                  // Centered: the column stretches its children and the icon paints to its width.
                  Center(
                    child: SIcon(SIconName.lock, size: 40, color: c.primary),
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    l.unlockTitle,
                    style: Type.headline.copyWith(color: c.text),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    l.unlockText,
                    style: Type.body.copyWith(color: c.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  if (paused || _error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.sm),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          paused
                              ? l.pinLockedFor(lockCountdown(_pause!))
                              : _error!,
                          style: Type.bodySmall.copyWith(color: c.negative),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: Spacing.lg),
                  if (p.pinEnabled) ...[
                    SecretField(
                      label: l.pinLabel,
                      controller: _pin,
                      showLabel: l.showSecret,
                      hideLabel: l.hideSecret,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _checkPin(),
                      autofocus: !p.biometricLock,
                      enabled: !paused,
                    ),
                    const SizedBox(height: Spacing.sm),
                    SButton(
                      label: l.usePin,
                      icon: SIconName.lock,
                      onPressed: paused ? null : _checkPin,
                      fullWidth: true,
                    ),
                  ],
                  if (p.biometricLock) ...[
                    const SizedBox(height: Spacing.sm),
                    SButton(
                      label: p.pinEnabled ? l.useBiometrics : l.unlock,
                      variant: p.pinEnabled
                          ? SButtonVariant.secondary
                          : SButtonVariant.primary,
                      onPressed: _biometrics,
                      fullWidth: true,
                    ),
                  ],
                  const SizedBox(height: Spacing.sm),
                  SButton(
                    label: p.pinEnabled ? l.pinForgot : l.lockRecover,
                    variant: SButtonVariant.ghost,
                    compact: true,
                    onPressed: () => _recover(context, p),
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
