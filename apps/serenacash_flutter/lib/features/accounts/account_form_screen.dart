import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/billing/billing.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';

const accountColors = [
  '#0B5563',
  '#176B4E',
  '#C0703E',
  '#8A5200',
  '#A93A29',
  '#4F5E61',
];

Color colorFromHex(String hex, Color fallback) {
  final h = hex.replaceAll('#', '');
  final v = h.length == 6 ? int.tryParse(h, radix: 16) : null;
  return v == null ? fallback : Color(0xFF000000 | v);
}

/// Spoken name of a palette color, so a screen reader does not read the hex code.
String colorName(AppLocalizations l, String hex) => switch (hex.toUpperCase()) {
  '#0B5563' => l.colorTeal,
  '#176B4E' => l.colorGreen,
  '#C0703E' => l.colorCopper,
  '#8A5200' => l.colorAmber,
  '#A93A29' => l.colorRed,
  '#4F5E61' => l.colorGray,
  '#2E7FA8' => l.colorSky,
  '#1F5F9E' => l.colorBlue,
  '#5B7F2B' => l.colorOlive,
  '#A6791E' => l.colorGold,
  '#B84E5E' => l.colorRose,
  '#7A5A44' => l.colorBrown,
  '#74848A' => l.colorLightGray,
  _ => l.colorOther(hex),
};

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.colors = accountColors,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final List<String> colors;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 0,
    runSpacing: 0,
    children: [
      for (final h in colors)
        Semantics(
          selected: h == value,
          button: true,
          label: colorName(context.l10n, h),
          excludeSemantics: true,
          child: InkWell(
            onTap: () => onChanged(h),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorFromHex(h, context.colors.primary),
                shape: BoxShape.circle,
                border: Border.all(
                  color: h == value ? context.colors.text : Colors.transparent,
                  width: 2,
                ),
              ),
              child: h == value
                  ? const Center(
                      child: SIcon(
                        SIconName.check,
                        size: 18,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
        ),
    ],
  );
}

class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key, this.id});
  final String? id;
  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  late final existing = widget.id == null
      ? null
      : ref.read(ledgerProvider).accountById(widget.id!);
  late final _name = TextEditingController(text: existing?.name ?? '');
  late String _type = existing?.type ?? 'checking';
  late int? _opening = existing?.openingBalanceCents;
  late String _openingDate = existing?.openingDate ?? ref.read(todayProvider);
  late bool _include = existing?.includeInAvailability ?? true;
  late String _color = existing?.color ?? accountColors.first;
  int? _adjust;
  String? _error;

  Future<void> _save() async {
    final l = context.l10n;
    final s = ref.read(appControllerProvider).requireValue;
    if (_name.text.trim().isEmpty) {
      return setState(() => _error = l.nameAccountErr);
    }
    final lim = withinLimit(
      s.access,
      'accounts',
      s.ledger.accounts.where((a) => a.isActive).length,
    );
    if (existing == null && !lim.ok) {
      unawaited(context.push('/paywall?feature=unlimited_accounts'));
      return;
    }
    final saved = await ref
        .read(appControllerProvider.notifier)
        .saveAccount(
          id: existing?.id,
          name: _name.text.trim(),
          type: _type,
          openingBalanceCents: _opening ?? 0,
          openingDate: _openingDate,
          includeInAvailability: _include,
          color: _color,
        );
    // Whoever opened this form on the way (a transfer, for instance) gets the account back.
    if (mounted) context.pop(saved.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final lim = withinLimit(
      s.access,
      'accounts',
      s.ledger.accounts.where((a) => a.isActive).length,
    );
    return StackScreen(
      title: existing != null ? l.editAccount : l.newAccount,
      actions: [
        SButton(label: l.save, variant: SButtonVariant.ghost, onPressed: _save),
      ],
      children: [
        STextField(
          label: l.name,
          controller: _name,
          placeholder: l.accountNameHint,
          error: _error,
          autofocus: existing == null,
        ),
        Field(
          label: l.type,
          child: Segmented<String>(
            options: [
              ('checking', l.typeBank),
              ('digital_wallet', l.typeDigital),
              ('cash', l.typeCash),
              ('savings', l.typeSavings),
            ],
            value: _type,
            onChanged: (v) => setState(() => _type = v),
          ),
        ),
        MoneyField(
          label: existing != null ? l.openingBalanceOnDate : l.currentBalance,
          cents: _opening,
          onChanged: (v) => setState(() => _opening = v),
          help: existing != null ? l.openingHelpEdit : l.openingHelpNew,
        ),
        DateField(
          label: l.openingDate,
          value: _openingDate,
          onChanged: (d) => setState(() => _openingDate = d),
          today: s.today,
          todayLabel: l.today,
          yesterdayLabel: l.yesterday,
          tomorrowLabel: l.tomorrow,
          invalidLabel: l.invalidDate,
          calendarLabel: l.openCalendar,
        ),
        ToggleRow(
          label: l.includeInAvailability,
          value: _include,
          help: l.includeHelp,
          onChanged: (v) => setState(() => _include = v),
        ),
        Field(
          label: l.color,
          child: ColorPicker(
            value: _color,
            onChanged: (v) => setState(() => _color = v),
          ),
        ),
        if (existing != null)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.adjustBalance,
                  style: Type.title.copyWith(color: c.text),
                ),
                const SizedBox(height: 6),
                Text(
                  l.adjustHelp(
                    formatBRL(
                      accountBalance(s.ledger, existing!.id),
                      hidden: hidden,
                    ),
                  ),
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Spacing.sm),
                MoneyField(
                  label: l.realBalanceToday,
                  cents: _adjust,
                  onChanged: (v) => setState(() => _adjust = v),
                ),
                const SizedBox(height: Spacing.sm),
                SButton(
                  label: l.registerAdjustment,
                  variant: SButtonVariant.secondary,
                  onPressed: _adjust == null
                      ? null
                      : () async {
                          await ref
                              .read(appControllerProvider.notifier)
                              .adjustBalance(
                                existing!.id,
                                _adjust!,
                                s.today,
                                l.balanceAdjustment,
                              );
                          if (context.mounted) context.pop();
                        },
                ),
              ],
            ),
          ),
        if (!lim.ok && existing == null)
          Text(
            l.freeLimitAccounts(lim.limit ?? 0),
            style: Type.bodySmall.copyWith(color: c.warning),
          ),
      ],
    );
  }
}
