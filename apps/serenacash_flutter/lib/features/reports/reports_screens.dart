import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/cards/cards.dart';
import '../../domain/dates/dates.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/loans/loans.dart';
import '../../domain/money/money.dart';
import '../../domain/reports/reports.dart';
import '../../ui/components/components.dart';
import '../accounts/account_form_screen.dart';
import '../budgets/budgets_screen.dart';
import '../cards/cards_screen.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

class ReportsIndexScreen extends ConsumerWidget {
  const ReportsIndexScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final access = ref.watch(appControllerProvider).requireValue.access;
    final items = [
      (
        '/reports/cashflow',
        SIconName.arrowUp,
        l.cashflowReport,
        l.cashflowDesc,
      ),
      (
        '/reports/categories',
        SIconName.tag,
        l.spendingByCategory,
        l.categoriesDesc,
      ),
      (
        '/reports/recurring',
        SIconName.receipt,
        l.recurringReport,
        l.recurringDesc,
      ),
      (
        '/reports/projection',
        SIconName.calendar,
        l.balanceProjection,
        l.projectionDesc,
      ),
      (
        '/reports/indicators',
        SIconName.sparkle,
        l.indicatorsReport,
        access.tier == 'free' ? l.plusTitle : l.indicatorsDesc,
      ),
    ];
    return StackScreen(
      title: l.reports,
      children: [
        SCard(
          child: Column(
            children: [
              for (final it in items)
                ListRow(
                  icon: it.$2,
                  title: it.$3,
                  description: it.$4,
                  chevron: true,
                  onTap: () => context.push(it.$1),
                ),
            ],
          ),
        ),
        Text(l.exportHint, style: Type.caption.copyWith(color: c.textMuted)),
      ],
    );
  }
}

class CashflowReportScreen extends ConsumerStatefulWidget {
  const CashflowReportScreen({super.key});
  @override
  ConsumerState<CashflowReportScreen> createState() =>
      _CashflowReportScreenState();
}

class _CashflowReportScreenState extends ConsumerState<CashflowReportScreen> {
  int _range = 6;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final locale = Localizations.localeOf(context).toString();
    final month = monthKeyOf(s.today);
    final points = cashflow(s.ledger, month, _range);
    final max = [
      1,
      ...points.map(
        (p) => p.totals.incomeSettled > p.totals.expenseSettled
            ? p.totals.incomeSettled
            : p.totals.expenseSettled,
      ),
    ].reduce((a, b) => a > b ? a : b);
    final cmp = compareMonths(s.ledger, month);
    final year = yearSummary(
      s.ledger,
      int.parse(month.substring(0, 4)),
      rankUpTo: monthKeyOf(s.today),
    );
    String brl(int v) => formatBRL(v, hidden: hidden);
    String ml(String k) => monthLabelShort(k, locale);
    final tab = Type.bodySmall.copyWith(
      color: c.text,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return StackScreen(
      title: l.cashflowReport,
      children: [
        Wrap(
          spacing: 8,
          children: [
            SChip(
              label: l.months6,
              selected: _range == 6,
              onTap: () => setState(() => _range = 6),
            ),
            SChip(
              label: l.months12,
              selected: _range == 12,
              onTap: () => setState(() => _range = 12),
            ),
          ],
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.incomeVsExpenses),
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final p in points)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Semantics(
                                    label: l.incomeOf(
                                      ml(p.totals.month),
                                      brl(p.totals.incomeSettled),
                                    ),
                                    child: Container(
                                      width: _range == 6 ? 12 : 7,
                                      height:
                                          (p.totals.incomeSettled / max * 120)
                                              .clamp(2, 120)
                                              .toDouble(),
                                      decoration: BoxDecoration(
                                        color: c.positive,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Semantics(
                                    label: l.expensesOf(
                                      ml(p.totals.month),
                                      brl(p.totals.expenseSettled),
                                    ),
                                    child: Container(
                                      width: _range == 6 ? 12 : 7,
                                      height:
                                          (p.totals.expenseSettled / max * 120)
                                              .clamp(2, 120)
                                              .toDouble(),
                                      decoration: BoxDecoration(
                                        color: c.primary,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ml(p.totals.month),
                              style: Type.caption.copyWith(color: c.textMuted),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Legend(c.positive, l.income),
                  const SizedBox(width: 12),
                  _Legend(c.primary, l.expenses),
                ],
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.monthByMonth),
              for (final p in points.reversed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          ml(p.totals.month),
                          style: Type.bodySmall.copyWith(color: c.text),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          brl(p.totals.incomeSettled),
                          style: tab.copyWith(color: c.positive),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          brl(p.totals.expenseSettled),
                          style: tab,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          brl(p.totals.net),
                          style: tab.copyWith(
                            color: p.totals.net < 0 ? c.negative : c.text,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          l.balanceShort(brl(p.balanceEnd)),
                          style: Type.caption.copyWith(
                            color: c.textMuted,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          textAlign: TextAlign.end,
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
              CardHeader(title: l.compareWithPrevious),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.income,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  ),
                  Money(
                    cmp.incomeDeltaCents,
                    signed: true,
                    showPlus: true,
                    hidden: hidden,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.expenses,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  ),
                  Text(
                    '${cmp.expenseDeltaCents > 0 ? '+' : ''}${brl(cmp.expenseDeltaCents)}${cmp.expenseDeltaPercent != null ? ' (${cmp.expenseDeltaPercent! > 0 ? '+' : ''}${cmp.expenseDeltaPercent!.round()}%)' : ''}',
                    style: tab.copyWith(
                      color: cmp.expenseDeltaCents > 0
                          ? c.negative
                          : c.positive,
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
              CardHeader(title: l.yearLabel(year.year)),
              KeyValueRow(l.income, brl(year.incomeCents)),
              const SizedBox(height: 6),
              KeyValueRow(l.expenses, brl(year.expenseCents)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.result,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  ),
                  Money(year.netCents, signed: true, hidden: hidden),
                ],
              ),
              if (year.bestMonth != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l.bestWorst(
                      ml(year.bestMonth!),
                      year.worstMonth != null ? ml(year.worstMonth!) : '—',
                    ),
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

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: Type.caption.copyWith(color: context.colors.textMuted),
      ),
    ],
  );
}

class CategoriesReportScreen extends ConsumerStatefulWidget {
  const CategoriesReportScreen({super.key});
  @override
  ConsumerState<CategoriesReportScreen> createState() =>
      _CategoriesReportScreenState();
}

class _CategoriesReportScreenState
    extends ConsumerState<CategoriesReportScreen> {
  late String _month = monthKeyOf(ref.read(todayProvider));
  bool _rollUp = true;
  bool _planned = false;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final rows = expensesByCategory(
      s.ledger,
      _month,
      rollUp: _rollUp,
      includePlanned: _planned,
    );
    final total = rows.fold(0, (a, r) => a + r.cents);
    String brl(int v) => formatBRL(v, hidden: hidden);
    // Grouped view: each category also shows how its amount splits among its subcategories. The parts
    // are a breakdown of the category total, never added to it again.
    final parts = <String?, List<CategoryTotal>>{};
    if (_rollUp) {
      for (final f in expensesByCategory(
        s.ledger,
        _month,
        includePlanned: _planned,
      )) {
        final cat = s.ledger.categoryById(f.categoryId);
        if (cat == null) continue;
        (parts[cat.parentId ?? cat.id] ??= []).add(f);
      }
      // A category with entries only in itself has nothing to break down.
      parts.removeWhere(
        (root, list) => list.every((f) => f.categoryId == root),
      );
    }
    return StackScreen(
      title: l.spendingByCategory,
      children: [
        MonthChips(month: _month, onChanged: (m) => setState(() => _month = m)),
        SCard(
          child: Column(
            children: [
              ToggleRow(
                label: l.groupSubcategories,
                value: _rollUp,
                onChanged: (v) => setState(() => _rollUp = v),
              ),
              ToggleRow(
                label: l.includePlanned,
                value: _planned,
                onChanged: (v) => setState(() => _planned = v),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.totalLabel(brl(total)),
                style: Type.title.copyWith(color: c.text),
              ),
              const SizedBox(height: Spacing.sm),
              if (rows.isEmpty)
                Text(
                  l.noExpensesMonth,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                r.name,
                                style: Type.body.copyWith(color: c.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Money(r.cents, hidden: hidden),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l.transactionsCount(r.count),
                              style: Type.caption.copyWith(color: c.textMuted),
                            ),
                            Text(
                              '${r.percent.round()}%',
                              style: Type.caption.copyWith(color: c.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: SizedBox(
                            height: 10,
                            child: Stack(
                              children: [
                                Container(color: c.surfaceInset),
                                FractionallySizedBox(
                                  widthFactor: total > 0
                                      ? (r.cents / total).clamp(0, 1).toDouble()
                                      : 0,
                                  child: Container(
                                    color: colorFromHex(r.color, c.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        for (final f
                            in parts[r.categoryId] ?? const <CategoryTotal>[])
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4,
                              left: Spacing.sm,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    f.categoryId == r.categoryId
                                        ? l.repDirectInCategory
                                        : f.name,
                                    style: Type.rowMeta.copyWith(
                                      color: c.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  brl(f.cents),
                                  style: Type.rowMeta.copyWith(
                                    color: c.textMuted,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              if (parts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: Text(
                    l.repSubsIncluded,
                    style: Type.rowMeta.copyWith(color: c.textMuted),
                  ),
                ),
              SButton(
                label: l.seeMonthTransactions,
                variant: SButtonVariant.ghost,
                onPressed: () => context.go('/transactions?kind=expense'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IndicatorsReportScreen extends ConsumerWidget {
  const IndicatorsReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    if (!s.access.features.contains('advanced_reports')) {
      return StackScreen(
        title: l.indicatorsReport,
        children: [
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.plusFeature, style: Type.title.copyWith(color: c.text)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l.indicatorsPlusText,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  ),
                ),
                SButton(
                  label: l.knowPlus,
                  onPressed: () =>
                      context.push('/paywall?feature=advanced_reports'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    final t = s.today, month = monthKeyOf(t);
    final nw = netWorth(s.ledger, month, 12, t);
    final tot = monthTotals(s.ledger, month);
    final inc = tot.incomeSettled;
    final cardDebt = s.ledger.cards
        .where((x) => x.isActive)
        .fold(0, (a, x) => a + cardCommitment(s.ledger, x, t).outstandingCents);
    final loanInst = s.ledger.loans
        .where((x) => x.isActive)
        .fold(
          0,
          (a, x) =>
              a + (loanPosition(s.ledger, x, t).nextDue?.installmentCents ?? 0),
        );
    final savingRate = inc > 0 ? (inc - tot.expenseSettled) / inc * 100 : null;
    final commitment = inc > 0 ? (cardDebt + loanInst) / inc * 100 : null;
    String brl(int v) => formatBRL(v, hidden: hidden);
    Widget ind(String k, String v, String how) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(k, style: Type.body.copyWith(color: c.text)),
              Text(v, style: Type.moneyRow.copyWith(color: c.text)),
            ],
          ),
          Text(how, style: Type.caption.copyWith(color: c.textMuted)),
        ],
      ),
    );
    return StackScreen(
      title: l.indicatorsReport,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.thisMonthTitle),
              ind(
                l.savingRate,
                savingRate == null ? '—' : '${savingRate.toStringAsFixed(1)}%',
                l.savingRateHow,
              ),
              ind(
                l.committedIncome,
                commitment == null ? '—' : '${commitment.toStringAsFixed(1)}%',
                l.commitmentHow,
              ),
              ind(
                l.netWorth,
                nw.isEmpty ? '—' : brl(nw.last.netCents),
                l.netWorthHow,
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.netWorth12),
              for (final p in nw)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        monthShortKey(p.month),
                        style: Type.bodySmall.copyWith(color: c.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.assetsDebts(brl(p.assetsCents), brl(p.debtsCents)),
                          style: Type.caption.copyWith(color: c.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Money(p.netCents, signed: true, hidden: hidden),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Text(
          l.indicatorsMethod,
          style: Type.caption.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

class ProjectionReportScreen extends ConsumerStatefulWidget {
  const ProjectionReportScreen({super.key});
  @override
  ConsumerState<ProjectionReportScreen> createState() =>
      _ProjectionReportScreenState();
}

class _ProjectionReportScreenState
    extends ConsumerState<ProjectionReportScreen> {
  String _h = 'month';
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final t = s.today;
    final until = _h == 'month'
        ? endOfMonth(monthKeyOf(t))
        : addDays(t, int.parse(_h));
    final p = projectBalance(s.ledger, t, until);
    String brl(int v) => formatBRL(v, hidden: hidden);
    return StackScreen(
      title: l.balanceProjection,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final x in const ['month', '30', '60', '90'])
              SChip(
                label: x == 'month'
                    ? l.monthEnd
                    : x == '30'
                    ? l.days30
                    : x == '60'
                    ? l.days60
                    : l.days90,
                selected: _h == x,
                onTap: () => setState(() => _h = x),
              ),
          ],
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.today,
                        style: Type.label.copyWith(color: c.textMuted),
                      ),
                      Money(
                        p.startCents,
                        role: MoneyRole.title,
                        signed: true,
                        hidden: hidden,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l.onDate(dayMonth(until)),
                        style: Type.label.copyWith(color: c.textMuted),
                      ),
                      Money(
                        p.endCents,
                        role: MoneyRole.title,
                        signed: true,
                        hidden: hidden,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                p.minCents < 0
                    ? l.negativeWarning(brl(p.minCents), dayMonth(p.minDate))
                    : l.minBalance(brl(p.minCents), dayMonth(p.minDate)),
                style: Type.bodySmall.copyWith(
                  color: p.minCents < 0 ? c.negative : c.textMuted,
                ),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.points.isEmpty)
                Text(
                  l.nothingPlanned,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final x in p.points)
                  ListRow(
                    icon: x.kind == 'income'
                        ? SIconName.arrowDown
                        : x.kind == 'card'
                        ? SIconName.card
                        : x.kind == 'loan'
                        ? SIconName.bank
                        : SIconName.receipt,
                    title: x.label,
                    description: l.balanceAfter(
                      dayMonth(x.date),
                      brl(x.balanceAfterCents),
                    ),
                    trailing: Money(x.cents, signed: true, hidden: hidden),
                  ),
            ],
          ),
        ),
        Text(
          l.projectionRules,
          style: Type.caption.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

class RecurringReportScreen extends ConsumerWidget {
  const RecurringReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final rows = recurringExpenses(s.ledger, monthKeyOf(s.today));
    final total = rows.fold(0, (a, r) => a + r.amountCents);
    String brl(int v) => formatBRL(v, hidden: hidden);
    return StackScreen(
      title: l.recurringReport,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.perMonthLabel,
                style: Type.label.copyWith(color: c.textMuted),
              ),
              Money(total, role: MoneyRole.headline, hidden: hidden),
              Text(
                l.recurringHelp,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rows.isEmpty)
                EmptyState(
                  icon: SIconName.receipt,
                  title: l.nothingRecurring,
                  text: l.nothingRecurringText,
                )
              else
                for (final r in rows)
                  ListRow(
                    icon: SIconName.receipt,
                    title: r.description.isEmpty ? l.recurring : r.description,
                    description: l.recurringLine(
                      r.months.length,
                      r.seriesId != null ? l.series : l.detected,
                    ),
                    trailing: Money(r.amountCents, hidden: hidden),
                  ),
            ],
          ),
        ),
        if (rows.isNotEmpty)
          Text(
            l.recurringTip(
              brl(rows.last.amountCents),
              brl(rows.last.amountCents * 12),
            ),
            style: Type.caption.copyWith(color: c.textMuted),
          ),
      ],
    );
  }
}
