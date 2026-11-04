/// "Como calculamos": every line of the availability estimate, with the toggles that change it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/dashboard_data.dart';
import '../../app/theme/tokens.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';

class AvailableScreen extends ConsumerWidget {
  const AvailableScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final data = ref.watch(dashboardDataProvider);
    final prefs = ref.watch(prefsProvider);
    final hidden = ref.watch(privacyHiddenProvider);
    if (data == null) return const SizedBox();
    final av = data.availability;
    final neg = av.availableCents < 0;
    final ctl = ref.read(appControllerProvider.notifier);
    return SScreen(
      title: l.canSpendTitle,
      subtitle: l.availableSubtitle(dayMonth(av.horizonEnd), av.mode),
      compactTitle: true,
      actions: [
        SButton(
          label: l.close,
          variant: SButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      children: [
        SCard(
          color: neg ? c.negativeContainer : c.primaryContainer,
          child: Column(
            children: [
              Money(
                av.availableCents,
                role: MoneyRole.hero,
                color: neg ? c.negative : c.onPrimaryContainer,
                hidden: hidden,
                align: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.estimateDisclaimer,
                style: Type.bodySmall.copyWith(
                  color: neg ? c.negative : c.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.theMath, style: Type.title.copyWith(color: c.text)),
              const SizedBox(height: Spacing.xs),
              for (final line in av.lines)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${line.sign > 0 ? '+ ' : '− '}${line.label}',
                              style: Type.body.copyWith(color: c.text),
                            ),
                            if (line.note != null)
                              Text(
                                line.note!,
                                style: Type.caption.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Money(
                        line.sign * line.cents,
                        color: line.sign < 0 ? c.negative : c.positive,
                        hidden: hidden,
                      ),
                    ],
                  ),
                ),
              Divider(height: Spacing.md, color: c.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.equalsCanSpend,
                    style: Type.title.copyWith(color: c.text),
                  ),
                  Money(
                    av.availableCents,
                    role: MoneyRole.title,
                    signed: true,
                    hidden: hidden,
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
              Text(l.adjustments, style: Type.title.copyWith(color: c.text)),
              const SizedBox(height: Spacing.sm),
              ToggleRow(
                label: l.includePlannedIncome,
                value: prefs.includePlannedIncomeInAvailability,
                help: l.includePlannedIncomeHelp,
                onChanged: (v) => ctl.setPrefs(
                  (p) => p.copyWith(includePlannedIncomeInAvailability: v),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Field(
                label: l.horizon,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SChip(
                      label: l.untilMonthEnd,
                      selected: prefs.availabilityHorizon == 'month_end',
                      onTap: () => ctl.setPrefs(
                        (p) => p.copyWith(availabilityHorizon: 'month_end'),
                      ),
                    ),
                    SChip(
                      label: l.next30days,
                      selected: prefs.availabilityHorizon == 'days_30',
                      onTap: () => ctl.setPrefs(
                        (p) => p.copyWith(availabilityHorizon: 'days_30'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              Field(
                label: l.safetyCushion,
                help: l.cushionHelp,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in const [0, 10000, 20000, 50000, 100000])
                      SChip(
                        label: v == 0 ? l.none : 'R\$ ${v ~/ 100}',
                        selected: prefs.safetyCushionCents == v,
                        onTap: () => ctl.setPrefs(
                          (p) => p.copyWith(safetyCushionCents: v),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.rules, style: Type.title.copyWith(color: c.text)),
              const SizedBox(height: 6),
              Text(
                l.availabilityRules,
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
