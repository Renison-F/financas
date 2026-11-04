/// "Está sereno?": budgets, goals, cards and loans at a glance, each with its own screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/dashboard_data.dart';
import '../../app/theme/tokens.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../home/widgets.dart';
import '../shared/format.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final d = ref.watch(dashboardDataProvider);
    final hidden = ref.watch(privacyHiddenProvider);
    if (d == null) return const SizedBox();
    String brl(int v) => formatBRL(v, hidden: hidden);
    Widget newBtn(String route, String label) => SButton(
      label: label,
      variant: SButtonVariant.ghost,
      compact: true,
      icon: SIconName.plus,
      onPressed: () => context.push(route),
    );
    return SScreen(
      title: l.planTitle,
      subtitle: l.planSubtitle,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.budgets,
                action: newBtn('/budgets/new', l.new_),
              ),
              if (d.budgets.isEmpty)
                EmptyState(
                  icon: SIconName.plan,
                  title: l.noBudget,
                  text: l.noBudgetPlanText,
                  actionLabel: l.createBudget,
                  onAction: () => context.push('/budgets/new'),
                )
              else ...[
                for (final b in d.budgets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b.category?.name ?? l.monthlyBudget,
                              style: Type.body.copyWith(color: c.text),
                            ),
                            Text(
                              '${brl(b.spentCents)} ${l.ofLimit(brl(b.limitCents))}',
                              style: Type.bodySmall.copyWith(
                                color: c.textMuted,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RhythmBar(
                          percent: b.percentUsed,
                          expectedPercent: b.expectedPercent,
                          state: b.pace,
                        ),
                      ],
                    ),
                  ),
                SButton(
                  label: l.seeAll,
                  variant: SButtonVariant.ghost,
                  onPressed: () => context.push('/budgets'),
                ),
              ],
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.goalsAndReserves,
                action: newBtn('/goals/new', l.newF),
              ),
              if (d.goals.isEmpty)
                EmptyState(
                  icon: SIconName.target,
                  title: l.noGoal,
                  text: l.noGoalPlanText,
                  actionLabel: l.createGoal,
                  onAction: () => context.push('/goals/new'),
                )
              else
                for (final g in d.goals)
                  ListRow(
                    icon: SIconName.target,
                    title: g.goal.name,
                    description:
                        '${l.goalLine(g.percent.round(), brl(g.remainingCents))}${g.suggestedMonthlyCents != null ? l.perMonth(brl(g.suggestedMonthlyCents!)) : ''}',
                    trailing: Money(g.savedCents, hidden: hidden),
                    chevron: true,
                    onTap: () => context.push('/goals/${g.goal.id}'),
                  ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.cards, action: newBtn('/cards/new', l.new_)),
              if (d.cards.isEmpty)
                EmptyState(
                  icon: SIconName.card,
                  title: l.noCard,
                  actionLabel: l.addCard,
                  onAction: () => context.push('/cards/new'),
                )
              else
                for (final v in d.cards)
                  ListRow(
                    icon: SIconName.card,
                    title: v.card.name,
                    description: l.cardLine(
                      invoiceStateLabel(l, v.invoice.state),
                      dayMonth(v.invoice.dueDate),
                      brl(v.commitment.availableLimitCents),
                    ),
                    trailing: Money(v.invoice.remainingCents, hidden: hidden),
                    chevron: true,
                    onTap: () => context.push('/cards/${v.card.id}'),
                  ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.loansAndDebts,
                action: newBtn('/loans/new', l.new_),
              ),
              if (d.loans.isEmpty)
                Text(
                  l.noLoanRegistered,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final p in d.loans)
                  ListRow(
                    icon: SIconName.bank,
                    title: p.loan.name,
                    description: p.nextDue != null
                        ? l.loanLine(
                            dayMonth(p.nextDue!.dueDate),
                            brl(p.nextDue!.installmentCents),
                            p.paidInstallments,
                            p.loan.termMonths,
                          )
                        : l.paidOff,
                    trailing: Money(p.outstandingCents, hidden: hidden),
                    chevron: true,
                    onTap: () => context.push('/loans/${p.loan.id}'),
                  ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.balanceProjection,
                action: SButton(
                  label: l.see,
                  variant: SButtonVariant.ghost,
                  compact: true,
                  onPressed: () => context.push('/reports/projection'),
                ),
              ),
              Text(
                l.projectionText,
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
