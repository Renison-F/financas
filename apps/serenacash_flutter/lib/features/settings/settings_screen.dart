import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/di.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/palettes.dart';
import '../../app/theme/tokens.dart';
import '../../data/notifications/bill_reminders.dart';
import '../../data/security/device_auth.dart';
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
    ref.read(deviceAuthProvider).hasBiometrics().then((has) {
      if (mounted) setState(() => _bio = has);
    });
  }

  /// Asks for the PIN in use before it is changed or removed. An unlocked app left on a table must
  /// not be enough to take the lock away. Wrong answers count as attempts, as on the lock screen.
  Future<bool> _confirmCurrentPin(String title) async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final pins = ref.read(pinManagerProvider);
    if (!await pins.isSet()) return true;
    if (!mounted) return false;
    final current = await _askPin(title, l.pinCurrent);
    if (current == null) return false;
    final r = await pins.check(current);
    if (r.ok) return true;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          r.lockedFor != null
              ? l.pinLockedFor(lockCountdown(r.lockedFor!))
              : l.pinWrong,
        ),
      ),
    );
    return false;
  }

  /// The lock is only turned on after the device proves it can unlock; otherwise the next launch
  /// would stop at a lock screen nobody can pass.
  Future<void> _enableBiometricLock() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final device = ref.read(deviceAuthProvider);
    final status = await device.confirm(l.biometricConfirmToEnable);
    if (status != DeviceAuthStatus.confirmed) {
      // Each reason gets its own words, and the one the user can fix leads to where it is fixed.
      final text = switch (status) {
        DeviceAuthStatus.canceled => l.bioCanceled,
        DeviceAuthStatus.failed => l.bioFailedEnable,
        DeviceAuthStatus.notSetUp => l.bioNotSetUp,
        DeviceAuthStatus.noHardware => l.bioNoHardware,
        DeviceAuthStatus.lockedOut => l.bioLockedOut,
        _ => l.bioUnavailableNow,
      };
      messenger.showSnackBar(
        SnackBar(
          content: Text(text),
          action: status == DeviceAuthStatus.notSetUp
              ? SnackBarAction(
                  label: l.bioOpenSettings,
                  onPressed: device.openSecuritySettings,
                )
              : null,
        ),
      );
      return;
    }
    await ref
        .read(appControllerProvider.notifier)
        .setPrefs((x) => x.copyWith(biometricLock: true));
  }

  /// Turning the lock off is also confirmed by the device, as turning the PIN off asks for the PIN:
  /// an unlocked phone left on a table must not be enough to remove the protection.
  Future<void> _disableBiometricLock() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final status = await ref
        .read(deviceAuthProvider)
        .confirm(l.biometricConfirmToDisable);
    // With no screen lock left on the device there is nothing to confirm against; keeping the app
    // lock on would only lock the owner out.
    const allowed = {
      DeviceAuthStatus.confirmed,
      DeviceAuthStatus.notSetUp,
      DeviceAuthStatus.noHardware,
    };
    if (!allowed.contains(status)) {
      messenger.showSnackBar(SnackBar(content: Text(l.bioDisableDenied)));
      return;
    }
    await ref
        .read(appControllerProvider.notifier)
        .setPrefs((x) => x.copyWith(biometricLock: false));
  }

  Future<void> _setPin() async {
    final l = context.l10n;
    if (!await _confirmCurrentPin(l.changePin) || !mounted) return;
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

  Future<void> _editName(String current) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: current),
    );
    if (name == null) return;
    await ref
        .read(appControllerProvider.notifier)
        .setPrefs((x) => x.copyWith(displayName: name.trim()));
  }

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
              CardHeader(title: l.profile),
              ListRow(
                icon: SIconName.edit,
                title: l.yourName,
                description: p.displayName.isEmpty
                    ? l.yourNameEmpty
                    : p.displayName,
                chevron: true,
                onTap: () => _editName(p.displayName),
              ),
            ],
          ),
        ),
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
              label(l.paletteLabel),
              const SizedBox(height: 8),
              // Each swatch is the action colour of that palette in the theme now on screen. The
              // choice applies at once and can be undone the same way; income, expense and warning
              // colours are the same in every palette.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final pal in palettes)
                    Builder(
                      builder: (context) {
                        final swatch = colorsFor(
                          Theme.of(context).brightness,
                          pal.id,
                        );
                        final name = paletteName(l, pal.id);
                        final selected = p.palette == pal.id;
                        return Semantics(
                          container: true,
                          button: true,
                          selected: selected,
                          label: name,
                          child: InkWell(
                            onTap: () => ctl.setPrefs(
                              (x) => x.copyWith(palette: pal.id),
                            ),
                            borderRadius: BorderRadius.circular(Radii.sm),
                            child: Container(
                              width: 96,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selected ? c.primary : c.border,
                                  width: selected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(Radii.sm),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 11,
                                        backgroundColor: swatch.primary,
                                        child: selected
                                            ? SIcon(
                                                SIconName.check,
                                                size: 14,
                                                color: swatch.onPrimary,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 4),
                                      CircleAvatar(
                                        radius: 6,
                                        backgroundColor: swatch.accent,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ExcludeSemantics(
                                    child: Text(
                                      name,
                                      style: Type.caption.copyWith(
                                        color: c.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              label(l.densityLabel),
              const SizedBox(height: 8),
              Segmented<String>(
                options: [
                  ('comfortable', l.densityComfortable),
                  ('compact', l.densityCompact),
                ],
                value: p.density == 'compact' ? 'compact' : 'comfortable',
                onChanged: (v) => ctl.setPrefs((x) => x.copyWith(density: v)),
              ),
              if (p.palette != 'teal' || p.density != 'comfortable')
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SButton(
                    label: l.appearanceReset,
                    variant: SButtonVariant.ghost,
                    compact: true,
                    onPressed: () => ctl.setPrefs(
                      (x) =>
                          x.copyWith(palette: 'teal', density: 'comfortable'),
                    ),
                  ),
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
                    v ? _enableBiometricLock() : _disableBiometricLock(),
              ),
              ToggleRow(
                label: l.pinLock,
                value: p.pinEnabled,
                help: l.pinLockHelp,
                onChanged: (v) async {
                  if (v) {
                    await _setPin();
                  } else {
                    if (!await _confirmCurrentPin(l.pinDisableTitle)) return;
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
              if (p.pinEnabled || p.biometricLock)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: Text(
                    l.lockScreenProtected,
                    style: Type.caption.copyWith(color: c.textMuted),
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

/// Asks how the user wants to be greeted on the home screen. Owns its controller.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});
  final String initial;
  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _ctl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.yourName),
      content: TextField(
        controller: _ctl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        maxLength: 30,
        decoration: InputDecoration(
          labelText: l.yourNameLabel,
          helperText: l.yourNameHelp,
          helperMaxLines: 2,
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
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

String paletteName(AppLocalizations l, String id) => switch (id) {
  'blue' => l.paletteBlue,
  'green' => l.paletteGreen,
  'terracotta' => l.paletteTerracotta,
  'graphite' => l.paletteGraphite,
  'wine' => l.paletteWine,
  _ => l.paletteTeal,
};
