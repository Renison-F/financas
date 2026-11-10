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
import '../../domain/budgets/budgets.dart';
import '../../domain/cards/cards.dart';
import '../../domain/dates/dates.dart';
import '../../domain/dashboard/widgets.dart' as dash;
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../domain/reports/shares.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';
import 'analytic_widgets.dart';
import 'home_parts.dart';

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
    if (analyticWidgetIds.contains(id)) {
      return AnalyticWidget(id: id, data: data);
    }
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
      MoneyRole role = MoneyRole.dense,
      bool signed = false,
      Color? color,
    }) =>
        Money(cents, role: role, signed: signed, color: color, hidden: hidden);
    String brl(int v) => formatBRL(v, hidden: hidden);
    Widget muted(String s) =>
        Text(s, style: Type.rowMeta.copyWith(color: c.textMuted));
    final cats = {
      for (final k in ref.watch(ledgerProvider).categories) k.id: k,
    };
    // The icon the user's category carries; entries without a category use [fallback].
    SIconName catIcon(Transaction t, SIconName fallback) {
      final k = cats[t.categoryId];
      return k == null ? fallback : iconByKey(k.icon, fallback: fallback);
    }

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

    // A section with nothing to show is one quiet line, not a tall card: several of them together
    // (first use) must not push the content that exists off the screen.
    Widget emptyRow(
      SIconName icon,
      String title, [
      String? actionLabel,
      String? route,
    ]) => HomeCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: EmptyRow(
        icon: icon,
        title: title,
        actionLabel: actionLabel,
        onAction: route == null ? null : () => go(route),
      ),
    );
    final noAccount = data.accounts.isEmpty;
    switch (id) {
      case 'bills_to_pay' when data.bills.isEmpty && data.overdue.isEmpty:
        return emptyRow(
          SIconName.calendar,
          l.noBillPlanned,
          l.add,
          '/transaction?kind=expense&planned=1',
        );
      case 'cards_invoices' when data.cards.isEmpty:
        return emptyRow(SIconName.card, l.firstCard, l.add, '/cards/new');
      case 'recent_transactions' when data.recent.isEmpty:
        return emptyRow(
          SIconName.list,
          l.noTransactionYet,
          l.add,
          Routes.transaction,
        );
      case 'monthly_budget' when data.budgets.isEmpty:
        return emptyRow(
          SIconName.plan,
          l.noBudgetYet,
          l.create,
          '/budgets/new',
        );
      case 'spending_by_category' when data.categories.isEmpty:
        return emptyRow(SIconName.tag, l.noSpendingYet);
      case 'goals' when data.goals.isEmpty:
        return emptyRow(SIconName.target, l.noGoalYet, l.create, '/goals/new');
      case 'loans' when data.loans.isEmpty:
        return emptyRow(SIconName.bank, l.noLoan, l.add, '/loans/new');
      case 'consolidated_balance' || 'account_balances' when noAccount:
        return emptyRow(SIconName.wallet, l.noAccount, l.add, '/accounts/new');
    }
    switch (id) {
      case 'available':
        return SummaryPanel(
          availability: data.availability,
          hidden: hidden,
          monthHorizon:
              ref.watch(prefsProvider).availabilityHorizon == 'month_end',
          onExplain: () => go(Routes.available),
          onAddAccount: () => go('/accounts/new'),
        );
      case 'consolidated_balance':
        return HomeCard(
          onTap: () => go('/accounts'),
          semanticHint: l.accounts,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.totalBalance, link: l.accounts),
              if (data.accounts.isNotEmpty)
                money(data.consolidated, role: MoneyRole.section, signed: true)
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
        return HomeCard(
          onTap: () => go('/accounts'),
          semanticHint: l.all,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.balancesByAccount, link: l.all),
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
        return HomeCard(
          onTap: () => go('/transactions?kind=income'),
          semanticHint: l.see,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.income, link: l.see),
              money(
                data.totals.incomeSettled,
                role: MoneyRole.section,
                color: c.positive,
              ),
              muted(l.plannedLabel(brl(data.totals.incomePlanned))),
            ],
          ),
        );
      case 'expenses':
        return HomeCard(
          onTap: () => go('/transactions?kind=expense'),
          semanticHint: l.see,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.expenses, link: l.see),
              money(data.totals.expenseSettled, role: MoneyRole.section),
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
        // Overdue first, then what is still to come in the period; the total is what remains to pay.
        final pending = [...data.overdue, ...data.bills];
        final total = pending.fold<int>(0, (a, t) => a + pendingCents(t));
        const maxRows = 4;
        return HomeCard(
          onTap: () => go('/bills'),
          semanticHint: l.seeAllFem,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.billsToPay, link: l.seeAllFem),
              money(total, role: MoneyRole.section),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: l.billsPendingUntil(dayMonth(data.horizonEnd)),
                    ),
                    if (data.overdue.isNotEmpty)
                      TextSpan(
                        text: ' · ${l.billsOverdueCount(data.overdue.length)}',
                        style: TextStyle(
                          color: c.negative,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                style: Type.rowMeta.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Spacing.xxs),
              ...dividedRows([
                for (final t in pending.take(maxRows))
                  () {
                    final due = dueLabel(l, t.dueDate ?? t.date, data.today);
                    final late = due.tone == DueTone.overdue;
                    return ListRow(
                      icon: late
                          ? SIconName.alert
                          : catIcon(t, SIconName.receipt),
                      iconColor: late ? c.negative : null,
                      tileColor: late ? c.negativeContainer : null,
                      title: t.description.isEmpty ? l.bill : t.description,
                      descriptionWidget: DueBadge(
                        text: due.text,
                        tone: due.tone,
                      ),
                      trailing: money(
                        pendingCents(t),
                        color: late ? c.negative : null,
                      ),
                      onTap: () => go('/transaction?id=${t.id}'),
                    );
                  }(),
              ]),
              if (pending.length > maxRows)
                action(l.moreBills(pending.length - maxRows), '/bills'),
            ],
          ),
        );
      case 'overdue_bills':
        return HomeCard(
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
        return HomeCard(
          onTap: () => go('/calendar'),
          semanticHint: l.calendar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.next7days, link: l.calendar),
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
        const maxCards = 2;
        final shown = data.cards.take(maxCards).toList();
        return HomeCard(
          onTap: () => go('/cards'),
          semanticHint: l.seeCards,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.cardsAndInvoices, link: l.seeCards),
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: Spacing.xs),
                    child: RowDivider(),
                  ),
                _CardInvoice(
                  view: shown[i],
                  hidden: hidden,
                  locale: locale,
                  onTap: () => go('/cards/${shown[i].card.id}'),
                ),
              ],
              // The remaining cards stay one tap away and are announced, never silently dropped.
              if (data.cards.length > maxCards)
                action(l.moreCards(data.cards.length - maxCards), '/cards'),
            ],
          ),
        );
      case 'installments':
        return HomeCard(
          onTap: () => go('/cards/installments'),
          semanticHint: l.details,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.installmentPurchases, link: l.details),
              money(data.installmentsFuture, role: MoneyRole.section),
              muted(l.committedFuture),
            ],
          ),
        );
      case 'monthly_budget':
        final g = data.globalBudget;
        return HomeCard(
          onTap: () => go('/budgets'),
          semanticHint: l.budgets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.monthlyBudget, link: l.budgets),
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
                              style: Type.rowText.copyWith(color: c.text),
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
        return HomeCard(
          onTap: () => go('/reports/categories'),
          semanticHint: l.report,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.spendingByCategory, link: l.report),
              if (data.categories.isEmpty)
                EmptyState(
                  icon: SIconName.tag,
                  title: l.noExpensesMonth,
                  actionLabel: l.registerExpense,
                  onAction: () => go('/transaction?kind=expense'),
                )
              else
                Builder(
                  builder: (context) {
                    // Same query and same slices as the category report: the two cannot disagree.
                    final slices = categorySlices(
                      data.categories,
                      maxSlices: 5,
                      otherLabel: l.chartOthers,
                    );
                    if (slices.isEmpty) {
                      return Text(
                        l.noExpensesMonth,
                        style: Type.bodySmall.copyWith(color: c.textMuted),
                      );
                    }
                    return DonutChart(
                      compact: true,
                      diameter: 116,
                      centerLabel: l.chartTotal,
                      centerValue: brl(total),
                      slices: [
                        for (final x in slices)
                          DonutSlice(
                            label: x.name,
                            value: brl(x.cents),
                            share: '${perMilleLabel(x.perMille)}%',
                            color: _hex(x.color, c.primary),
                          ),
                      ],
                    );
                  },
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
        // The bars keep their height; the month label under them grows with the text size, so the
        // chart never clips it. "Compact charts" makes the bars shorter.
        final barHeight = context.look.compactCharts ? 60.0 : 96.0;
        final labelHeight =
            MediaQuery.textScalerOf(context).scale(12) * 1.5 + 2;
        return HomeCard(
          onTap: () => go('/reports/cashflow'),
          semanticHint: l.cashflow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.evolution, link: l.cashflow),
              if (!data.hasTransactions)
                EmptyState(
                  icon: SIconName.arrowUp,
                  title: l.noHistory,
                  text: l.noHistoryText,
                )
              else
                SizedBox(
                  height: barHeight + labelHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final p in data.cashflow)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: barHeight,
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
                                            (p.totals.incomeSettled /
                                                    max *
                                                    barHeight)
                                                .clamp(2, barHeight)
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
                                            (p.totals.expenseSettled /
                                                    max *
                                                    barHeight)
                                                .clamp(2, barHeight)
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
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  monthLabelShort(p.totals.month, locale),
                                  maxLines: 1,
                                  style: Type.caption.copyWith(
                                    color: c.textMuted,
                                  ),
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
        return HomeCard(
          onTap: () => go('/goals'),
          semanticHint: l.see,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.goals, link: l.see),
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
                              Flexible(
                                child: Text(
                                  g.goal.name,
                                  style: Type.rowText.copyWith(color: c.text),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: Spacing.xs),
                              Flexible(
                                child: Text(
                                  '${brl(g.savedCents)} ${l.ofLimit(brl(g.goal.targetCents))}',
                                  style: Type.rowText.copyWith(
                                    color: c.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
        return HomeCard(
          onTap: () => go('/goals'),
          semanticHint: l.see,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.reserves, link: l.see),
              money(reserved, role: MoneyRole.section),
              muted(l.reservesText),
            ],
          ),
        );
      case 'monthly_savings':
        final inc = data.totals.incomeSettled;
        final rate = inc > 0
            ? ((inc - data.totals.expenseSettled) / inc * 100).round()
            : null;
        return HomeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.monthlySavings),
              money(data.totals.net, role: MoneyRole.section, signed: true),
              muted(
                rate == null
                    ? l.registerIncomeForRate
                    : l.percentOfIncome(rate),
              ),
            ],
          ),
        );
      case 'subscriptions':
        return HomeCard(
          onTap: () => go('/reports/recurring'),
          semanticHint: l.see,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.subscriptions, link: l.see),
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
        return HomeCard(
          onTap: () => go('/loans'),
          semanticHint: l.see,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.loans, link: l.see),
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
        return HomeCard(
          onTap: () => go('/calendar'),
          semanticHint: l.open,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.calendar, link: l.open),
              muted(
                '${l.calendarSummary(data.bills.length, dayMonth(data.horizonEnd))}${data.overdue.isNotEmpty ? l.overdueCount(data.overdue.length) : ''}',
              ),
            ],
          ),
        );
      case 'recent_transactions':
        String day(String iso) => iso == data.today
            ? l.today
            : iso == addDays(data.today, -1)
            ? l.yesterday
            : dayMonth(iso);
        return HomeCard(
          onTap: () => go('/transactions'),
          semanticHint: l.seeAllMasc,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.recentTransactions, link: l.seeAllMasc),
              ...dividedRows([
                for (final t in data.recent)
                  ListRow(
                    icon: catIcon(
                      t,
                      t.kind == TransactionKind.income
                          ? SIconName.arrowDown
                          : t.kind == TransactionKind.transfer
                          ? SIconName.swap
                          : t.kind == TransactionKind.cardPurchase
                          ? SIconName.card
                          : SIconName.arrowUp,
                    ),
                    title: t.description.isEmpty
                        ? kindLabel(l, t.kind)
                        : t.description,
                    description:
                        '${day(t.date)} · ${cats[t.categoryId]?.name ?? kindLabel(l, t.kind)}${t.status == TransactionStatus.planned ? ' · ${l.planned}' : ''}',
                    // Regra do Sinal: green marks money coming in; routine spending stays in the text color.
                    trailing: Money(
                      signedAmount(t),
                      role: MoneyRole.dense,
                      color: t.kind == TransactionKind.income
                          ? c.positive
                          : c.text,
                      showPlus: t.kind == TransactionKind.income,
                      spacedSign: true,
                      hidden: hidden,
                    ),
                    onTap: () => go('/transaction?id=${t.id}'),
                  ),
              ]),
            ],
          ),
        );
      case 'recommendations':
        return HomeCard(
          onTap: () => go('/assistant'),
          semanticHint: l.assistant,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.suggestions, link: l.assistant),
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
        return HomeCard(
          onTap: () => go('/shopping'),
          semanticHint: l.see,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.shoppingLists, link: l.see),
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
        return HomeCard(
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
        return HomeCard(
          onTap: () => go('/reports/indicators'),
          semanticHint: l.methodology,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.advancedIndicators, link: l.methodology),
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
        return HomeCard(
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

/// One card inside "Cartões e faturas": which card, what is owed and when it is due.
class _CardInvoice extends StatelessWidget {
  const _CardInvoice({
    required this.view,
    required this.hidden,
    required this.locale,
    required this.onTap,
  });
  final CardView view;
  final bool hidden;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final inv = view.invoice;
    final late = inv.state == InvoiceState.overdue;
    final brand = view.card.brand?.trim() ?? '';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Touch.target),
            child: Row(
              children: [
                const CardGlyph(),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        view.card.name,
                        style: Type.rowTitle.copyWith(color: c.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (brand.isNotEmpty)
                        Text(
                          brand,
                          style: Type.rowMeta.copyWith(color: c.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                SIcon(SIconName.chevronRight, size: 18, color: c.primary),
              ],
            ),
          ),
          const SizedBox(height: 2),
          HomeFigures(
            dividerColor: c.surfaceInset,
            left: HomeFigure(
              // "Fatura atual" while it is open; closed, overdue or paid say so.
              label: inv.state == InvoiceState.open
                  ? l.invoiceCurrent
                  : l.invoiceOf(invoiceStateLabel(l, inv.state)),
              labelColor: late ? c.negative : c.textMuted,
              labelWeight: late ? FontWeight.w600 : null,
              value: Money(
                inv.remainingCents,
                role: MoneyRole.section,
                size: 17,
                color: late ? c.negative : null,
                hidden: hidden,
              ),
            ),
            right: HomeFigure(
              label: l.invoiceDueLabel,
              labelColor: c.textMuted,
              value: Text(
                dayMonthShort(inv.dueDate, locale),
                style: Type.sectionValue.copyWith(fontSize: 17, color: c.text),
              ),
            ),
          ),
          if (inv.state == InvoiceState.open) ...[
            const Padding(
              padding: EdgeInsets.only(top: Spacing.xs, bottom: 6),
              child: RowDivider(),
            ),
            Text(
              l.invoiceCloses(dayMonthShort(inv.closingDate, locale)),
              style: Type.rowMeta.copyWith(color: c.textMuted),
            ),
          ],
          const SizedBox(height: Spacing.xxs),
        ],
      ),
    );
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
      return HomeCard(
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
