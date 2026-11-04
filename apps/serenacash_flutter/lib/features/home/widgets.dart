/// The 24 dashboard widgets: real data, empty state with an action, tap navigation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/dashboard_data.dart';
import '../../app/theme/tokens.dart';
import '../../domain/availability/availability.dart';
import '../../domain/budgets/budgets.dart';
import '../../domain/cards/cards.dart';
import '../../domain/dashboard/widgets.dart' as dash;
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';

String invoiceStateLabel(AppLocalizations l, InvoiceState s) => switch (s) {
  InvoiceState.open => l.invoiceOpen,
  InvoiceState.closed => l.invoiceClosed,
  InvoiceState.paid => l.invoicePaid,
  InvoiceState.overdue => l.invoiceOverdue,
  InvoiceState.future => l.invoiceFuture,
};
String paceLabel(AppLocalizations l, PaceStatus p) => switch (p) {
  PaceStatus.sereno => l.paceSereno,
  PaceStatus.atencao => l.paceAtencao,
  PaceStatus.agitado => l.paceAgitado,
};

class DashboardWidget extends ConsumerWidget {
  const DashboardWidget({super.key, required this.id, required this.data});
  final String id;
  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final hidden = ref.watch(privacyHiddenProvider);
    final locale = Localizations.localeOf(context).toString();
    void go(String r) => context.push(r);
    Widget action(String label, String route) => SButton(
      label: label,
      variant: SButtonVariant.ghost,
      compact: true,
      onPressed: () => go(route),
    );
    Widget money(
      int cents, {
      MoneyRole role = MoneyRole.row,
      bool signed = false,
      Color? color,
    }) =>
        Money(cents, role: role, signed: signed, color: color, hidden: hidden);
    String brl(int v) => formatBRL(v, hidden: hidden);
    Widget muted(String s) =>
        Text(s, style: Type.bodySmall.copyWith(color: c.textMuted));
    Widget txRow(
      Transaction t, {
      SIconName icon = SIconName.receipt,
      Color? iconColor,
      String? desc,
      Widget? right,
    }) => ListRow(
      icon: icon,
      iconColor: iconColor,
      title: t.description.isEmpty ? l.bill : t.description,
      description: desc,
      trailing: right ?? money(pendingCents(t)),
      onTap: () => go('/transaction?id=${t.id}'),
    );

    switch (id) {
      case 'available':
        final av = data.availability;
        if (!av.hasAccounts) {
          return SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.canSpendTitle),
                EmptyState(
                  icon: SIconName.wallet,
                  title: l.startWithAccount,
                  text: l.startWithAccountText,
                  actionLabel: l.addAccount,
                  onAction: () => go('/accounts/new'),
                ),
              ],
            ),
          );
        }
        final neg = av.status == AvailabilityStatus.negative;
        final fg = neg ? c.negative : c.onPrimaryContainer;
        final tone = neg
            ? c.negative
            : av.status == AvailabilityStatus.tight
            ? c.warning
            : c.positive;
        return SCard(
          color: neg ? c.negativeContainer : c.primaryContainer,
          onTap: () => go(Routes.available),
          semanticHint: l.howWeCalculate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.canSpendUntil(dayMonth(av.horizonEnd)),
                style: Type.label.copyWith(color: fg),
              ),
              const SizedBox(height: 6),
              money(av.availableCents, role: MoneyRole.hero, color: fg),
              const SizedBox(height: 8),
              Text(
                neg
                    ? l.availNegative
                    : av.status == AvailabilityStatus.tight
                    ? l.availTight
                    : l.availOk,
                style: Type.bodySmall.copyWith(color: fg),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      av.mode == 'otimista' ? l.modeOptimistic : l.modePrudent,
                      style: Type.label.copyWith(color: tone),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l.howWeCalculate,
                      style: Type.label.copyWith(color: fg),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 'consolidated_balance':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.totalBalance,
                action: action(l.accounts, '/accounts'),
              ),
              if (data.accounts.isNotEmpty)
                money(data.consolidated, role: MoneyRole.headline, signed: true)
              else
                EmptyState(
                  icon: SIconName.wallet,
                  title: l.noAccount,
                  actionLabel: l.add,
                  onAction: () => go('/accounts/new'),
                ),
            ],
          ),
        );
      case 'account_balances':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.balancesByAccount,
                action: action(l.all, '/accounts'),
              ),
              if (data.accounts.isEmpty)
                EmptyState(
                  icon: SIconName.wallet,
                  title: l.noAccount,
                  actionLabel: l.add,
                  onAction: () => go('/accounts/new'),
                )
              else
                for (final a in data.accounts)
                  ListRow(
                    icon: a.account.type == 'cash'
                        ? SIconName.wallet
                        : SIconName.bank,
                    title: a.account.name,
                    trailing: money(a.balance, signed: true),
                    onTap: () => go('/accounts/${a.account.id}'),
                  ),
            ],
          ),
        );
      case 'income':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.income,
                action: action(l.see, '/transactions?kind=income'),
              ),
              money(
                data.totals.incomeSettled,
                role: MoneyRole.headline,
                color: c.positive,
              ),
              muted(l.plannedLabel(brl(data.totals.incomePlanned))),
            ],
          ),
        );
      case 'expenses':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.expenses,
                action: action(l.see, '/transactions?kind=expense'),
              ),
              money(data.totals.expenseSettled, role: MoneyRole.headline),
              muted(
                l.plannedAndCard(
                  brl(data.totals.expensePlanned),
                  brl(data.totals.cardPurchases),
                ),
              ),
            ],
          ),
        );
      case 'bills_to_pay':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.billsToPay, action: action(l.all, '/bills')),
              if (data.bills.isEmpty)
                EmptyState(
                  icon: SIconName.check,
                  title: l.nothingToPay,
                  text: l.nothingToPayText,
                  actionLabel: l.newBillToPay,
                  onAction: () => go('/transaction?kind=expense&planned=1'),
                )
              else
                for (final t in data.bills.take(5))
                  txRow(t, desc: l.dueOn(dayMonth(t.dueDate ?? t.date))),
            ],
          ),
        );
      case 'overdue_bills':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.overdueBills),
              if (data.overdue.isEmpty)
                muted(l.noOverdue)
              else
                for (final t in data.overdue.take(5))
                  txRow(
                    t,
                    icon: SIconName.alert,
                    iconColor: c.negative,
                    desc: l.duePast(dayMonth(t.dueDate ?? t.date)),
                    right: money(pendingCents(t), color: c.negative),
                  ),
            ],
          ),
        );
      case 'upcoming_due':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.next7days,
                action: action(l.calendar, '/calendar'),
              ),
              if (data.next7.isEmpty)
                muted(l.noDueNext7)
              else
                for (final t in data.next7.take(5))
                  txRow(
                    t,
                    icon: SIconName.calendar,
                    desc: dayMonth(t.dueDate ?? t.date),
                  ),
            ],
          ),
        );
      case 'cards_invoices':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.cardsAndInvoices,
                action: action(l.see, '/cards'),
              ),
              if (data.cards.isEmpty)
                EmptyState(
                  icon: SIconName.card,
                  title: l.noCard,
                  text: l.noCardText,
                  actionLabel: l.addCard,
                  onAction: () => go('/cards/new'),
                )
              else
                for (final v in data.cards)
                  InkWell(
                    onTap: () => go('/cards/${v.card.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                v.card.name,
                                style: Type.body.copyWith(color: c.text),
                              ),
                              money(v.invoice.remainingCents),
                            ],
                          ),
                          muted(
                            l.invoiceLine(
                              invoiceStateLabel(l, v.invoice.state),
                              dayMonth(v.invoice.dueDate),
                              brl(v.commitment.availableLimitCents),
                            ),
                          ),
                          const SizedBox(height: 6),
                          RhythmBar(
                            percent: v.card.limitCents > 0
                                ? v.commitment.outstandingCents /
                                      v.card.limitCents *
                                      100
                                : 0,
                            label: l.limitCommitted(
                              v.card.limitCents > 0
                                  ? (v.commitment.outstandingCents /
                                            v.card.limitCents *
                                            100)
                                        .round()
                                  : 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      case 'installments':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.installmentPurchases,
                action: action(l.details, '/cards/installments'),
              ),
              money(data.installmentsFuture, role: MoneyRole.headline),
              muted(l.committedFuture),
            ],
          ),
        );
      case 'monthly_budget':
        final g = data.globalBudget;
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.monthlyBudget,
                action: action(l.budgets, '/budgets'),
              ),
              if (g != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    money(g.spentCents, role: MoneyRole.title),
                    muted(l.ofLimit(brl(g.limitCents))),
                  ],
                ),
                const SizedBox(height: 8),
                RhythmBar(
                  percent: g.percentUsed,
                  expectedPercent: g.expectedPercent,
                  state: g.pace,
                ),
                const SizedBox(height: 6),
                Text(
                  l.monthPace(paceLabel(l, g.pace)),
                  style: Type.label.copyWith(
                    color: g.pace == PaceStatus.sereno
                        ? c.positive
                        : g.pace == PaceStatus.atencao
                        ? c.warning
                        : c.negative,
                  ),
                ),
              ] else if (data.budgets.isNotEmpty)
                for (final b in data.budgets.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b.category?.name ?? l.general,
                              style: Type.bodySmall.copyWith(color: c.text),
                            ),
                            muted(
                              '${brl(b.spentCents)} ${l.ofLimit(brl(b.limitCents))}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RhythmBar(
                          percent: b.percentUsed,
                          expectedPercent: b.expectedPercent,
                          state: b.pace,
                        ),
                      ],
                    ),
                  )
              else
                EmptyState(
                  icon: SIconName.plan,
                  title: l.noBudgetYet,
                  text: l.noBudgetText,
                  actionLabel: l.createBudget,
                  onAction: () => go('/budgets/new'),
                ),
            ],
          ),
        );
      case 'spending_by_category':
        final total = data.categories.fold(0, (a, x) => a + x.cents);
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.spendingByCategory,
                action: action(l.report, '/reports/categories'),
              ),
              if (data.categories.isEmpty)
                EmptyState(
                  icon: SIconName.tag,
                  title: l.noExpensesMonth,
                  actionLabel: l.registerExpense,
                  onAction: () => go('/transaction?kind=expense'),
                )
              else
                for (final x in data.categories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                x.name,
                                style: Type.bodySmall.copyWith(color: c.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${brl(x.cents)} · ${x.percent.round()}%',
                              style: Type.bodySmall.copyWith(
                                color: c.text,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 8,
                            child: Stack(
                              children: [
                                Container(color: c.surfaceInset),
                                FractionallySizedBox(
                                  widthFactor: total > 0
                                      ? (x.cents / total).clamp(0, 1).toDouble()
                                      : 0,
                                  child: Container(
                                    color: _hex(x.color, c.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      case 'evolution':
        final max = [
          1,
          ...data.cashflow.map(
            (p) => p.totals.incomeSettled > p.totals.expenseSettled
                ? p.totals.incomeSettled
                : p.totals.expenseSettled,
          ),
        ].reduce((a, b) => a > b ? a : b);
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.evolution,
                action: action(l.cashflow, '/reports/cashflow'),
              ),
              if (!data.hasTransactions)
                EmptyState(
                  icon: SIconName.arrowUp,
                  title: l.noHistory,
                  text: l.noHistoryText,
                )
              else
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final p in data.cashflow)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 96,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Semantics(
                                      label: l.incomeOf(
                                        monthLabelShort(p.totals.month, locale),
                                        brl(p.totals.incomeSettled),
                                      ),
                                      child: Container(
                                        width: 10,
                                        height:
                                            (p.totals.incomeSettled / max * 96)
                                                .clamp(2, 96)
                                                .toDouble(),
                                        decoration: BoxDecoration(
                                          color: c.positive,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Semantics(
                                      label: l.expensesOf(
                                        monthLabelShort(p.totals.month, locale),
                                        brl(p.totals.expenseSettled),
                                      ),
                                      child: Container(
                                        width: 10,
                                        height:
                                            (p.totals.expenseSettled / max * 96)
                                                .clamp(2, 96)
                                                .toDouble(),
                                        decoration: BoxDecoration(
                                          color: c.primary,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                monthLabelShort(p.totals.month, locale),
                                style: Type.caption.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      case 'goals':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.goals, action: action(l.see, '/goals')),
              if (data.goals.isEmpty)
                EmptyState(
                  icon: SIconName.target,
                  title: l.noGoal,
                  text: l.noGoalText,
                  actionLabel: l.createGoal,
                  onAction: () => go('/goals/new'),
                )
              else
                for (final g in data.goals.take(3))
                  InkWell(
                    onTap: () => go('/goals/${g.goal.id}'),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                g.goal.name,
                                style: Type.bodySmall.copyWith(color: c.text),
                              ),
                              muted(
                                '${brl(g.savedCents)} ${l.ofLimit(brl(g.goal.targetCents))}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          RhythmBar(
                            percent: g.percent,
                            expectedPercent: g.expectedPercent,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      case 'reserves':
        final reserved = data.goals
            .where((g) => g.goal.reserved)
            .fold(0, (a, g) => a + g.savedCents);
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.reserves, action: action(l.see, '/goals')),
              money(reserved, role: MoneyRole.headline),
              muted(l.reservesText),
            ],
          ),
        );
      case 'monthly_savings':
        final inc = data.totals.incomeSettled;
        final rate = inc > 0
            ? ((inc - data.totals.expenseSettled) / inc * 100).round()
            : null;
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.monthlySavings),
              money(data.totals.net, role: MoneyRole.headline, signed: true),
              muted(
                rate == null
                    ? l.registerIncomeForRate
                    : l.percentOfIncome(rate),
              ),
            ],
          ),
        );
      case 'subscriptions':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.subscriptions,
                action: action(l.see, '/reports/recurring'),
              ),
              if (data.recurring.isEmpty)
                muted(l.noRecurring)
              else
                for (final r in data.recurring.take(5))
                  ListRow(
                    icon: SIconName.receipt,
                    title: r.description,
                    description: l.monthsInARow(r.months.length),
                    trailing: money(r.amountCents),
                  ),
            ],
          ),
        );
      case 'loans':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.loans, action: action(l.see, '/loans')),
              if (data.loans.isEmpty)
                EmptyState(
                  icon: SIconName.bank,
                  title: l.noLoan,
                  actionLabel: l.registerLoan,
                  onAction: () => go('/loans/new'),
                )
              else
                for (final p in data.loans)
                  ListRow(
                    icon: SIconName.bank,
                    title: p.loan.name,
                    description: p.nextDue != null
                        ? l.nextInstallment(
                            dayMonth(p.nextDue!.dueDate),
                            brl(p.nextDue!.installmentCents),
                          )
                        : l.paidOff,
                    trailing: money(p.outstandingCents),
                    onTap: () => go('/loans/${p.loan.id}'),
                  ),
            ],
          ),
        );
      case 'calendar':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.calendar,
                action: action(l.open, '/calendar'),
              ),
              muted(
                '${l.calendarSummary(data.bills.length, dayMonth(data.horizonEnd))}${data.overdue.isNotEmpty ? l.overdueCount(data.overdue.length) : ''}',
              ),
            ],
          ),
        );
      case 'recent_transactions':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.recentTransactions,
                action: action(l.allLabel, '/transactions'),
              ),
              if (data.recent.isEmpty)
                EmptyState(
                  icon: SIconName.list,
                  title: l.noTransaction,
                  actionLabel: l.register,
                  onAction: () => go('/transaction'),
                )
              else
                for (final t in data.recent)
                  ListRow(
                    icon: t.kind == TransactionKind.income
                        ? SIconName.arrowDown
                        : t.kind == TransactionKind.transfer
                        ? SIconName.swap
                        : t.kind == TransactionKind.cardPurchase
                        ? SIconName.card
                        : SIconName.arrowUp,
                    title: t.description.isEmpty
                        ? kindLabel(l, t.kind)
                        : t.description,
                    description:
                        '${dayMonth(t.date)}${t.status == TransactionStatus.planned ? ' · ${l.planned}' : ''}',
                    trailing: money(
                      signedAmount(t),
                      signed: !isNeutralKind(t.kind),
                    ),
                    onTap: () => go('/transaction?id=${t.id}'),
                  ),
            ],
          ),
        );
      case 'recommendations':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.suggestions,
                action: action(l.assistant, '/assistant'),
              ),
              if (data.recommendations.isEmpty)
                muted(l.allCalm)
              else
                for (final r in data.recommendations)
                  ListRow(
                    icon: r.severity == 'urgent'
                        ? SIconName.alert
                        : r.severity == 'attention'
                        ? SIconName.info
                        : SIconName.sparkle,
                    iconColor: r.severity == 'urgent'
                        ? c.negative
                        : r.severity == 'attention'
                        ? c.warning
                        : c.primary,
                    title: r.title,
                    description: r.text,
                    onTap: r.route == null ? null : () => go(r.route!),
                  ),
            ],
          ),
        );
      case 'shopping_lists':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.shoppingLists,
                action: action(l.see, '/shopping'),
              ),
              muted(
                data.listCount > 0 ? l.listCount(data.listCount) : l.noListYet,
              ),
              if (data.listCount == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SButton(
                    label: l.createList,
                    variant: SButtonVariant.secondary,
                    compact: true,
                    onPressed: () => go('/shopping/list/new'),
                  ),
                ),
            ],
          ),
        );
      case 'shopping_assistant':
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.shoppingAssistant),
              muted(
                data.finishedSessions > 0
                    ? l.sessionsCount(data.finishedSessions)
                    : l.shoppingAssistantText,
              ),
              const SizedBox(height: 10),
              SButton(
                label: l.startShopping,
                icon: SIconName.cart,
                onPressed: () => go('/shopping/session'),
              ),
            ],
          ),
        );
      case 'advanced_indicators':
        final inc = data.totals.incomeSettled;
        final savingRate = inc > 0
            ? ((inc - data.totals.expenseSettled) / inc * 100).round()
            : null;
        final committed = inc > 0
            ? ((data.cards.fold(
                            0,
                            (a, x) => a + x.commitment.outstandingCents,
                          ) +
                          data.loans.fold(
                            0,
                            (a, x) => a + (x.nextDue?.installmentCents ?? 0),
                          )) /
                      inc *
                      100)
                  .round()
            : null;
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.advancedIndicators,
                action: action(l.methodology, '/reports/indicators'),
              ),
              KeyValueRow(
                l.savingRate,
                savingRate == null ? '—' : '$savingRate%',
              ),
              const SizedBox(height: 6),
              KeyValueRow(
                l.committedIncome,
                committed == null ? '—' : '$committed%',
              ),
              const SizedBox(height: 6),
              KeyValueRow(
                l.netWorth,
                data.netWorth == null ? '—' : brl(data.netWorth!.netCents),
              ),
              const SizedBox(height: 6),
              Text(
                l.indicatorsDisclaimer,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        );
      default:
        final def = dash.widgetById(id);
        return SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: def.title),
              muted(def.description),
            ],
          ),
        );
    }
  }
}

Color _hex(String hex, Color fallback) {
  final h = hex.replaceAll('#', '');
  if (h.length != 6) return fallback;
  final v = int.tryParse(h, radix: 16);
  return v == null ? fallback : Color(0xFF000000 | v);
}

/// Error boundary per widget: a broken widget never takes the home screen down.
class WidgetBoundary extends StatefulWidget {
  const WidgetBoundary({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  State<WidgetBoundary> createState() => _WidgetBoundaryState();
}

class _WidgetBoundaryState extends State<WidgetBoundary> {
  Object? _error;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (_error != null) {
      return SCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(title: widget.title),
            EmptyState(
              icon: SIconName.alert,
              title: l.widgetLoadError,
              text: l.tapToRetry,
              actionLabel: l.retry,
              onAction: () => setState(() => _error = null),
            ),
          ],
        ),
      );
    }
    return _Catch(
      onError: (e) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _error = e);
      }),
      child: widget.child,
    );
  }
}

class _Catch extends StatelessWidget {
  const _Catch({required this.onError, required this.child});
  final void Function(Object) onError;
  final Widget child;
  @override
  Widget build(BuildContext context) => Builder(
    builder: (ctx) {
      try {
        return child;
      } catch (e) {
        onError(e);
        return const SizedBox.shrink();
      }
    },
  );
}
