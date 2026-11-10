/// Analytic cards of the home screen: balance of the period, overview, daily control, breakdown by
/// state, expenses by recurrence and financial health. Each one is computed from the ledger with
/// the same functions the reports use, shows a true empty state instead of a made-up figure, and
/// can be hidden or moved like any other card.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/dashboard_data.dart';
import '../../app/theme/tokens.dart';
import '../../domain/daily/daily.dart';
import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../domain/reports/shares.dart';
import '../../ui/components/components.dart';
import 'home_parts.dart';
import 'period_timeline.dart';

const analyticWidgetIds = {
  'period_balance',
  'overview',
  'daily_control',
  'breakdown',
  'recurrence',
  'financial_health',
};

class AnalyticWidget extends ConsumerWidget {
  const AnalyticWidget({super.key, required this.id, required this.data});
  final String id;
  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(ledgerProvider);
    final hidden = ref.watch(privacyHiddenProvider);
    final targets = ref.watch(appControllerProvider.notifier).dailyTargets;
    return switch (id) {
      'period_balance' => PeriodBalanceCard(
        ledger: ledger,
        data: data,
        hidden: hidden,
      ),
      'overview' => _Overview(data: data, hidden: hidden),
      'daily_control' => _DailyControl(
        ledger: ledger,
        data: data,
        hidden: hidden,
        targets: targets,
      ),
      'breakdown' => _Breakdown(ledger: ledger, data: data, hidden: hidden),
      'recurrence' => _Recurrence(ledger: ledger, data: data, hidden: hidden),
      _ => _Health(ledger: ledger, data: data, hidden: hidden),
    };
  }
}

/// A labelled amount, stacked. The label says what the number is; colour only reinforces it.
class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.cents,
    required this.hidden,
    this.color,
    this.note,
    this.signed = false,
  });
  final String label;
  final int cents;
  final bool hidden, signed;
  final Color? color;
  final String? note;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Type.rowMeta.copyWith(color: c.textMuted)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Money(
            cents,
            role: MoneyRole.section,
            hidden: hidden,
            signed: signed,
            color: color,
          ),
        ),
        if (note != null)
          Text(
            note!,
            style: Type.caption.copyWith(color: c.textMuted),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.data, required this.hidden});
  final DashboardData data;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final t = data.totals;
    String brl(int v) => formatBRL(v, hidden: hidden);
    // Nothing recorded in the month: said in one line, never as a row of zeros.
    if (t.incomeSettled == 0 &&
        t.expenseSettled == 0 &&
        t.incomePlanned == 0 &&
        t.expensePlanned == 0 &&
        data.cards.isEmpty) {
      return HomeCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: EmptyRow(icon: SIconName.chart, title: l.homeNoEntriesMonth),
      );
    }
    final invoices = data.cards.fold<int>(
      0,
      (a, x) =>
          a + x.commitment.currentInvoiceCents + x.commitment.closedUnpaidCents,
    );
    // Each indicator carries a mark in its own colour. The label says what it is; the colour and
    // the icon only make the four easier to tell apart at a glance.
    Widget tile(
      Widget child,
      String route, {
      required SIconName icon,
      required Color color,
      required Color background,
    }) => Expanded(
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.surfaceInset,
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: IconTile(
                  icon: icon,
                  color: color,
                  background: background,
                  size: 30,
                ),
              ),
              const SizedBox(height: 6),
              child,
            ],
          ),
        ),
      ),
    );
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: l.homeOverview),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tile(
                  _Figure(
                    label: l.homeIncomeReceived,
                    cents: t.incomeSettled,
                    hidden: hidden,
                    color: c.positive,
                    note: t.incomePlanned > 0
                        ? l.homePlannedMore(brl(t.incomePlanned))
                        : null,
                  ),
                  '/transactions',
                  icon: SIconName.arrowDown,
                  color: c.positive,
                  background: c.positiveContainer,
                ),
                const SizedBox(width: 8),
                tile(
                  _Figure(
                    label: l.homeExpensePaid,
                    cents: t.expenseSettled,
                    hidden: hidden,
                    note: t.expensePlanned > 0
                        ? l.homePlannedMore(brl(t.expensePlanned))
                        : null,
                  ),
                  '/reports/categories',
                  icon: SIconName.arrowUp,
                  color: c.negative,
                  background: c.negativeContainer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tile(
                  _Figure(
                    label: l.homeResult,
                    cents: t.net,
                    hidden: hidden,
                    signed: true,
                    color: t.net < 0 ? c.negative : null,
                    note: l.homeResultNote,
                  ),
                  '/reports/cashflow',
                  icon: SIconName.swap,
                  color: c.onPrimaryContainer,
                  background: c.primaryContainer,
                ),
                const SizedBox(width: 8),
                tile(
                  _Figure(
                    label: l.homeCardInvoices,
                    cents: invoices,
                    hidden: hidden,
                    note: data.cards.isEmpty
                        ? l.homeNoCards
                        : l.homeCardInvoicesNote,
                  ),
                  '/cards',
                  icon: SIconName.card,
                  color: c.warning,
                  background: c.warningContainer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyControl extends StatelessWidget {
  const _DailyControl({
    required this.ledger,
    required this.data,
    required this.hidden,
    required this.targets,
  });
  final Ledger ledger;
  final DashboardData data;
  final bool hidden;
  final List<DailyTarget> targets;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = dailySummary(ledger, data.today);
    String brl(int v) => formatBRL(v, hidden: hidden);
    final limit = spendLimitHistory(
      ledger,
      targets,
      data.today,
    ).where((d) => d.date == data.today).firstOrNull;
    final saving = savingHistory(
      ledger,
      targets,
      data.today,
    ).where((d) => d.date == data.today).firstOrNull;
    // No movement in the month and no target: one line that leads to setting one.
    if (limit == null &&
        saving == null &&
        s.spentMonthCents == 0 &&
        s.receivedMonthCents == 0) {
      return HomeCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: EmptyRow(
          icon: SIconName.calendar,
          title: l.dailyEmpty,
          actionLabel: l.dailySetLimit,
          onAction: () => context.push('/daily'),
        ),
      );
    }
    return HomeCard(
      onTap: () => context.push('/daily'),
      semanticHint: l.dailyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: l.dailyTitle, link: l.homeDayByDay),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Figure(
                  label: l.dailyReceivedToday,
                  cents: s.receivedTodayCents,
                  hidden: hidden,
                  color: s.receivedTodayCents > 0 ? c.positive : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Figure(
                  label: l.dailySpentToday,
                  cents: s.spentTodayCents,
                  hidden: hidden,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Figure(
                  label: l.dailyResultToday,
                  cents: s.resultTodayCents,
                  hidden: hidden,
                  signed: true,
                  color: s.resultTodayCents < 0 ? c.negative : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.dailyYesterdayAndAverage(
              brl(s.spentYesterdayCents),
              brl(s.averagePerCalendarDayCents),
            ),
            style: Type.rowMeta.copyWith(color: c.textMuted),
          ),
          if (limit != null) ...[
            const SizedBox(height: 8),
            Text(
              limit.within
                  ? l.dailyLimitLine(
                      brl(limit.availableCents),
                      brl(limit.remainingCents),
                    )
                  : l.dailyLimitOver(
                      brl(limit.availableCents),
                      brl(-limit.remainingCents),
                    ),
              style: Type.rowText.copyWith(
                color: limit.within ? c.text : c.negative,
              ),
            ),
            const SizedBox(height: 4),
            RhythmBar(
              percent: limit.availableCents > 0
                  ? limit.spentCents / limit.availableCents * 100
                  : (limit.spentCents > 0 ? 101 : 0),
              label: l.dailyLimitBar,
            ),
          ],
          if (saving != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                saving.met
                    ? l.dailySavingMet(
                        brl(saving.targetCents),
                        brl(saving.confirmedCents),
                      )
                    : l.dailySavingLine(
                        brl(saving.targetCents),
                        brl(saving.confirmedCents),
                        brl(saving.pendingCents),
                      ),
                style: Type.rowText.copyWith(color: c.text),
              ),
            ),
          if (limit == null && saving == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.dailyNoTargets,
                style: Type.link.copyWith(color: c.primary),
              ),
            ),
        ],
      ),
    );
  }
}

/// Amounts of the month by state. Each entry is in exactly one state, so the parts add up to the
/// month and nothing is counted twice.
({
  int paid,
  int upcoming,
  int overdue,
  int received,
  int toReceive,
  int lateIncome,
})
monthBreakdown(Ledger ledger, MonthKey month, ISODate today) {
  var paid = 0,
      upcoming = 0,
      overdue = 0,
      received = 0,
      toReceive = 0,
      lateIncome = 0;
  for (final t in ledger.transactions) {
    if (!isActive(t) || monthKeyOf(t.date) != month) continue;
    final pending = pendingCents(t);
    final late = compareISO(t.dueDate ?? t.date, today) < 0;
    if (isIncomeLike(t)) {
      received += effectiveCents(t);
      if (late) {
        lateIncome += pending;
      } else {
        toReceive += pending;
      }
    } else if (t.kind == TransactionKind.cardPurchase) {
      paid += t.amountCents;
    } else if (t.kind == TransactionKind.cardRefund) {
      paid -= t.amountCents;
    } else if (t.kind == TransactionKind.expense) {
      paid += effectiveCents(t);
      if (late) {
        overdue += pending;
      } else {
        upcoming += pending;
      }
    }
  }
  return (
    paid: paid,
    upcoming: upcoming,
    overdue: overdue,
    received: received,
    toReceive: toReceive,
    lateIncome: lateIncome,
  );
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({
    required this.ledger,
    required this.data,
    required this.hidden,
  });
  final Ledger ledger;
  final DashboardData data;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final b = monthBreakdown(ledger, monthKeyOf(data.today), data.today);
    final empty =
        b.paid == 0 &&
        b.upcoming == 0 &&
        b.overdue == 0 &&
        b.received == 0 &&
        b.toReceive == 0 &&
        b.lateIncome == 0;
    if (empty) {
      return HomeCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: EmptyRow(icon: SIconName.list, title: l.homeNoEntriesMonth),
      );
    }
    Widget line(String label, int cents, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Type.rowText.copyWith(color: c.text)),
          ),
          const SizedBox(width: 8),
          // A very large amount on a narrow screen with large text shrinks instead of overflowing.
          Flexible(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Money(
                cents,
                role: MoneyRole.dense,
                hidden: hidden,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
    return HomeCard(
      onTap: () => context.push('/bills'),
      semanticHint: l.billsBoth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: l.homeBreakdown, link: l.billsBoth),
          Text(
            l.homeBreakdownExpenses,
            style: Type.rowMeta.copyWith(color: c.textMuted),
          ),
          line(l.homePaid, b.paid),
          line(l.homeUpcoming, b.upcoming),
          line(
            l.homeOverdue,
            b.overdue,
            color: b.overdue > 0 ? c.negative : null,
          ),
          Divider(height: Spacing.md, color: c.border),
          Text(
            l.homeBreakdownIncome,
            style: Type.rowMeta.copyWith(color: c.textMuted),
          ),
          line(l.homeReceived, b.received, color: c.positive),
          line(l.homeToReceive, b.toReceive),
          line(
            l.homeLateIncome,
            b.lateIncome,
            color: b.lateIncome > 0 ? c.warning : null,
          ),
        ],
      ),
    );
  }
}

/// Expenses of the month by what the entry itself says it is: part of a recurring series, an
/// installment, or a one-off. Never guessed from the description.
({int recurring, int installments, int single}) expensesByRecurrence(
  Ledger ledger,
  MonthKey month,
) {
  var recurring = 0, installments = 0, single = 0;
  for (final t in ledger.transactions) {
    if (!isActive(t) || monthKeyOf(t.date) != month) continue;
    final cents = switch (t.kind) {
      TransactionKind.cardPurchase => t.amountCents,
      TransactionKind.cardRefund => -t.amountCents,
      TransactionKind.expense => effectiveCents(t),
      _ => 0,
    };
    if (cents == 0) continue;
    if (t.seriesId != null) {
      recurring += cents;
    } else if (t.installment != null) {
      installments += cents;
    } else {
      single += cents;
    }
  }
  return (recurring: recurring, installments: installments, single: single);
}

class _Recurrence extends StatelessWidget {
  const _Recurrence({
    required this.ledger,
    required this.data,
    required this.hidden,
  });
  final Ledger ledger;
  final DashboardData data;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final r = expensesByRecurrence(ledger, monthKeyOf(data.today));
    final parts = [
      (l.homeRecurring, r.recurring, c.primary),
      (l.homeInstallments, r.installments, c.accent),
      (l.homeSingle, r.single, c.textMuted),
    ].where((p) => p.$2 > 0).toList();
    if (parts.isEmpty) {
      return HomeCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: EmptyRow(icon: SIconName.tag, title: l.noSpendingYet),
      );
    }
    final shares = sharesPerMille([for (final p in parts) p.$2]);
    final total = parts.fold<int>(0, (a, p) => a + p.$2);
    return HomeCard(
      onTap: () => context.push('/reports/recurring'),
      semanticHint: l.homeRecurrenceTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: l.homeRecurrenceTitle, link: l.report),
          DonutChart(
            compact: true,
            diameter: 108,
            centerLabel: l.chartTotal,
            centerValue: formatBRL(total, hidden: hidden),
            slices: [
              for (var i = 0; i < parts.length; i++)
                DonutSlice(
                  label: parts[i].$1,
                  value: formatBRL(parts[i].$2, hidden: hidden),
                  share: '${perMilleLabel(shares[i])}%',
                  color: parts[i].$3,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Health extends StatelessWidget {
  const _Health({
    required this.ledger,
    required this.data,
    required this.hidden,
  });
  final Ledger ledger;
  final DashboardData data;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final t = data.totals;
    String brl(int v) => formatBRL(v, hidden: hidden);
    // Without income and expenses in the month there is nothing to assess: said, not scored.
    if (t.incomeSettled == 0 && t.expenseSettled == 0) {
      return HomeCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(title: l.homeHealth),
            Text(
              l.homeHealthNoData,
              style: Type.bodySmall.copyWith(color: c.textMuted),
            ),
          ],
        ),
      );
    }
    final rows = <(String, String, bool?)>[];
    rows.add((
      l.healthResult,
      t.net >= 0
          ? l.healthResultOk(brl(t.net))
          : l.healthResultBad(brl(-t.net)),
      t.net >= 0,
    ));
    final overdueTotal = sumCents(data.overdue.map(pendingCents));
    rows.add((
      l.healthOverdue,
      data.overdue.isEmpty
          ? l.healthOverdueOk
          : l.healthOverdueBad(data.overdue.length, brl(overdueTotal)),
      data.overdue.isEmpty,
    ));
    final limit = data.cards.fold<int>(0, (a, x) => a + x.card.limitCents);
    final used = data.cards.fold<int>(
      0,
      (a, x) => a + x.commitment.outstandingCents,
    );
    rows.add((
      l.healthCards,
      limit <= 0
          ? l.healthNoBasis
          : l.healthCardsUse((used / limit * 100).round()),
      limit <= 0 ? null : used / limit <= 0.5,
    ));
    final g = data.globalBudget;
    rows.add((
      l.healthBudget,
      g == null
          ? l.healthNoBudget
          : l.healthBudgetUse(brl(g.spentCents), brl(g.limitCents)),
      g == null ? null : g.spentCents <= g.limitCents,
    ));
    return HomeCard(
      onTap: () => context.push('/reports/indicators'),
      semanticHint: l.homeHealth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: l.homeHealth),
          for (final (label, text, ok) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SIcon(
                    ok == null
                        ? SIconName.info
                        : ok
                        ? SIconName.check
                        : SIconName.alert,
                    size: 16,
                    color: ok == null
                        ? c.textMuted
                        : ok
                        ? c.positive
                        : c.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$label: ',
                            style: Type.rowText.copyWith(
                              color: c.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: text,
                            style: Type.rowText.copyWith(color: c.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 2),
          Text(
            l.homeHealthNote,
            style: Type.caption.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
