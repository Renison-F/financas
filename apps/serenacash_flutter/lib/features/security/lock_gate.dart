/// Locks the UI behind biometrics and/or PIN when the preference is on; locks again on background.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../app/app.dart';
import '../../app/di.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/entities/entities.dart';
import '../../ui/components/components.dart';

final localAuthProvider = Provider<LocalAuthentication>(
  (_) => LocalAuthentication(),
);

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

  Future<void> _checkPin() async {
    final ok = await ref.read(pinManagerProvider).verify(_pin.text);
    if (!mounted) return;
    setState(() {
      _unlocked = ok;
      _error = ok ? null : context.l10n.pinWrong;
    });
    _pin.clear();
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    if (!app.hasValue) return widget.child;
    final p = app.value!.ledger.prefs;
    if (!(p.biometricLock || p.pinEnabled) || _unlocked) return widget.child;
    if (p.biometricLock && !_tried) {
      _tried = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometrics());
    }
    final c = context.colors;
    final l = context.l10n;
    // LockGate sits in MaterialApp.builder, above the app Navigator, so the lock screen needs its own
    // Overlay: without one the PIN field throws on every edit and stops syncing with the keyboard.
    return Overlay.wrap(child: _lockScreen(c, l, p));
  }

  Widget _lockScreen(SerenaColors c, AppLocalizations l, UserPrefs p) {
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
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
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.sm),
                      child: Text(
                        _error!,
                        style: Type.bodySmall.copyWith(color: c.negative),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: Spacing.lg),
                  if (p.pinEnabled) ...[
                    STextField(
                      label: l.pinLabel,
                      controller: _pin,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _checkPin(),
                      autofocus: !p.biometricLock,
                    ),
                    const SizedBox(height: Spacing.sm),
                    SButton(
                      label: l.usePin,
                      icon: SIconName.lock,
                      onPressed: _checkPin,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
