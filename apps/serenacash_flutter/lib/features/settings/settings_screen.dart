import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/di.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../data/notifications/bill_reminders.dart';
import '../../ui/components/components.dart';
import '../security/lock_gate.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _bio = false;
  String? _notif;

  @override
  void initState() {
    super.initState();
    ref
        .read(localAuthProvider)
        .isDeviceSupported()
        .then((ok) async {
          if (!ok) return;
          final kinds = await ref
              .read(localAuthProvider)
              .getAvailableBiometrics();
          if (mounted) setState(() => _bio = kinds.isNotEmpty);
        })
        .catchError((_) {});
  }

  Future<void> _setPin() async {
    final l = context.l10n;
    final pin = await _askPin(l.setPin, l.pinLabel);
    if (pin == null || !mounted) return;
    final confirm = await _askPin(l.confirmPin, l.pinLabel);
    if (!mounted) return;
    if (confirm != pin) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.pinMismatch)));
      return;
    }
    try {
      await ref.read(pinManagerProvider).setPin(pin);
      await ref
          .read(appControllerProvider.notifier)
          .setPrefs((p) => p.copyWith(pinEnabled: true));
    } on ArgumentError {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.pinFormat)));
      }
    }
  }

  Future<String?> _askPin(String title, String label) => showDialog<String>(
    context: context,
    builder: (_) => _PinDialog(title: title, label: label),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final p = ref.watch(prefsProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    Widget label(String s) =>
        Text(s, style: Type.label.copyWith(color: c.textMuted));
    return SScreen(
      title: l.settingsTitle,
      compactTitle: true,
      showBack: true,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.appearance),
              label(l.theme),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SChip(
                    label: l.themeSystem,
                    selected: p.theme == 'system',
                    icon: SIconName.settings,
                    onTap: () =>
                        ctl.setPrefs((x) => x.copyWith(theme: 'system')),
                  ),
                  SChip(
                    label: l.themeLight,
                    selected: p.theme == 'light',
                    icon: SIconName.sun,
                    onTap: () =>
                        ctl.setPrefs((x) => x.copyWith(theme: 'light')),
                  ),
                  SChip(
                    label: l.themeDark,
                    selected: p.theme == 'dark',
                    icon: SIconName.moon,
                    onTap: () => ctl.setPrefs((x) => x.copyWith(theme: 'dark')),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              label(l.language),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SChip(
                    label: l.languageSystem,
                    selected: p.locale == 'system',
                    onTap: () =>
                        ctl.setPrefs((x) => x.copyWith(locale: 'system')),
                  ),
                  SChip(
                    label: 'Português (BR)',
                    selected: p.locale.startsWith('pt'),
                    onTap: () =>
                        ctl.setPrefs((x) => x.copyWith(locale: 'pt-BR')),
                  ),
                  SChip(
                    label: 'English',
                    selected: p.locale == 'en',
                    onTap: () => ctl.setPrefs((x) => x.copyWith(locale: 'en')),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              ToggleRow(
                label: l.hideValues,
                value: p.privacyMode,
                help: l.privacyModeHelp,
                onChanged: (v) =>
                    ctl.setPrefs((x) => x.copyWith(privacyMode: v)),
              ),
              ToggleRow(
                label: l.haptics,
                value: p.hapticsEnabled,
                onChanged: (v) =>
                    ctl.setPrefs((x) => x.copyWith(hapticsEnabled: v)),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.money),
              label(l.currency),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cur in const ['BRL', 'USD', 'EUR'])
                    SChip(
                      label: cur,
                      selected: p.currency == cur,
                      onTap: () =>
                          ctl.setPrefs((x) => x.copyWith(currency: cur)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l.currencyHelp,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Spacing.sm),
              label(l.availabilityHorizon),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SChip(
                    label: l.monthEnd,
                    selected: p.availabilityHorizon == 'month_end',
                    onTap: () => ctl.setPrefs(
                      (x) => x.copyWith(availabilityHorizon: 'month_end'),
                    ),
                  ),
                  SChip(
                    label: l.days30,
                    selected: p.availabilityHorizon == 'days_30',
                    onTap: () => ctl.setPrefs(
                      (x) => x.copyWith(availabilityHorizon: 'days_30'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.security),
              ToggleRow(
                label: l.biometricLock,
                value: p.biometricLock,
                help: _bio ? l.biometricAvailable : l.biometricNotAvailable,
                onChanged: (v) =>
                    ctl.setPrefs((x) => x.copyWith(biometricLock: v)),
              ),
              ToggleRow(
                label: l.pinLock,
                value: p.pinEnabled,
                help: l.pinLockHelp,
                onChanged: (v) async {
                  if (v) {
                    await _setPin();
                  } else {
                    await ref.read(pinManagerProvider).clear();
                    await ctl.setPrefs((x) => x.copyWith(pinEnabled: false));
                  }
                },
              ),
              if (p.pinEnabled)
                Align(
                  alignment: Alignment.centerLeft,
                  child: SButton(
                    label: l.changePin,
                    variant: SButtonVariant.ghost,
                    compact: true,
                    onPressed: _setPin,
                  ),
                ),
              ToggleRow(
                label: l.lockOnBackground,
                value: p.lockOnBackground,
                onChanged: (v) =>
                    ctl.setPrefs((x) => x.copyWith(lockOnBackground: v)),
              ),
              const SizedBox(height: 4),
              Text(
                l.dataLocalHelp,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.reminders),
              Text(
                l.remindersText,
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Spacing.xs),
              SChip(
                label: l.enableReminders,
                onTap: () async {
                  final ok = await ref
                      .read(billRemindersProvider)
                      .requestPermission();
                  if (ok) {
                    await ref
                        .read(billRemindersProvider)
                        .schedule(
                          ref.read(ledgerProvider),
                          ref.read(todayProvider),
                        );
                  }
                  if (mounted) {
                    setState(
                      () =>
                          _notif = ok ? l.remindersEnabled : l.remindersDenied,
                    );
                  }
                },
              ),
              if (_notif != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _notif!,
                    style: Type.caption.copyWith(color: c.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// PIN prompt. The dialog owns its controller so it is disposed only when the route leaves the tree,
/// after the exit animation, never while the field is still being rebuilt.
class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.title, required this.label});
  final String title;
  final String label;
  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctl,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 8,
        decoration: InputDecoration(labelText: widget.label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_ctl.text),
          child: Text(l.ok),
        ),
      ],
    );
  }
}
