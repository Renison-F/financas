/// Annual planning: month-by-month result, the budget in force each month and what the goals need until year end.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/budgets/budgets.dart';
import '../../domain/dates/dates.dart';
import '../../domain/goals/goals.dart';
import '../../domain/money/money.dart';
import '../../domain/reports/reports.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

class AnnualScreen extends ConsumerStatefulWidget {
  const AnnualScreen({super.key});
  @override
  ConsumerState<AnnualScreen> createState() => _AnnualScreenState();
}

class _AnnualScreenState extends ConsumerState<AnnualScreen> {
  late int _year = int.parse(ref.read(todayProvider).substring(0, 4));
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final locale = Localizations.localeOf(context).toString();
    final currentMonth = monthKeyOf(s.today);
    final year = yearSummary(s.ledger, _year, rankUpTo: currentMonth);
    String brl(int v) => formatBRL(v, hidden: hidden);
    final tab = Type.bodySmall.copyWith(
      color: c.text,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final thisYear = int.parse(currentMonth.substring(0, 4));
    // Goals as that year saw them: a past year shows what was put aside, never a suggestion for a
    // goal that did not exist yet.
    final goals = goalsForYear(s.ledger, _year, s.today);
    final yearMonths = [for (final m in year.months) m.month];
    final hasBudget = yearMonths.any(
      (m) => s.ledger.budgets.any(
        (b) => b.categoryId == null && budgetInForce(b, m),
      ),
    );
    final hasEntries = year.months.any(
      (m) =>
          m.incomeSettled != 0 ||
          m.expenseSettled != 0 ||
          m.incomePlanned != 0 ||
          m.expensePlanned != 0,
    );
    // An empty year is said to be empty, instead of twelve rows of zeros that look like history.
    final empty = !hasEntries && !hasBudget && _year != thisYear;
    return StackScreen(
      title: l.annualPlanning,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SIconButton(
              icon: SIconName.chevronLeft,
              label: l.previousYear,
              color: c.primary,
              onPressed: () => setState(() => _year--),
            ),
            Text('$_year', style: Type.title.copyWith(color: c.text)),
            SIconButton(
              icon: SIconName.chevronRight,
              label: l.nextYear,
              color: c.primary,
              onPressed: () => setState(() => _year++),
            ),
          ],
        ),
        if (empty)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.annualNoData('$_year'),
                  style: Type.body.copyWith(color: c.text),
                ),
                const SizedBox(height: 4),
                Text(
                  l.annualNoDataHint,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
              ],
            ),
          )
        else ...[
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.yearResult,
                  style: Type.label.copyWith(color: c.textMuted),
                ),
                Money(
                  year.netCents,
                  role: MoneyRole.headline,
                  signed: true,
                  hidden: hidden,
                ),
                Text(
                  '${l.income} ${brl(year.incomeCents)} · ${l.expenses} ${brl(year.expenseCents)}',
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        l.monthCol,
                        style: Type.caption.copyWith(color: c.textMuted),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l.income,
                        style: Type.caption.copyWith(color: c.textMuted),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l.expenses,
                        style: Type.caption.copyWith(color: c.textMuted),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l.budgetCol,
                        style: Type.caption.copyWith(color: c.textMuted),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l.result,
                        style: Type.caption.copyWith(color: c.textMuted),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                for (final m in year.months)
                  Builder(
                    builder: (_) {
                      final key = m.month;
                      final b = budgetsForMonth(
                        s.ledger,
                        key,
                        s.today,
                      ).where((x) => x.budget.categoryId == null).firstOrNull;
                      final future = key.compareTo(currentMonth) > 0;
                      final exp = future ? m.expensePlanned : m.expenseSettled;
                      final inc = future ? m.incomePlanned : m.incomeSettled;
                      return Opacity(
                        opacity: future ? 0.7 : 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(
                                  monthLabelShort(key, locale),
                                  style: Type.bodySmall.copyWith(
                                    color: key == currentMonth
                                        ? c.primary
                                        : c.text,
                                    fontWeight: key == currentMonth
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  brl(inc),
                                  style: tab.copyWith(color: c.positive),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  brl(exp),
                                  style: tab,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  b == null ? '—' : brl(b.limitCents),
                                  style: tab.copyWith(
                                    color: b != null && exp > b.limitCents
                                        ? c.negative
                                        : c.textMuted,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  brl(inc - exp),
                                  style: tab.copyWith(
                                    color: inc - exp < 0 ? c.negative : c.text,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 6),
                Text(
                  l.annualBudgetNote,
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        ],
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: _year == thisYear
                    ? l.annualGoals
                    : l.annualGoalsOfYear('$_year'),
              ),
              if (goals.isEmpty)
                Text(
                  _year < thisYear ? l.annualNoGoalsInYear('$_year') : l.noGoal,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final g in goals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(switch (g.phase) {
                          GoalYearPhase.past => l.annualGoalPast(
                            g.goal.name,
                            brl(g.savedInYearCents),
                            brl(g.savedByYearEndCents),
                          ),
                          GoalYearPhase.current =>
                            g.monthlyUntilTargetDate
                                ? l.annualGoalByDate(
                                    g.goal.name,
                                    brl(g.remainingCents),
                                    brl(g.monthlyCents ?? 0),
                                    fmtDateBR(g.goal.targetDate!),
                                  )
                                : l.annualGoalByYearEnd(
                                    g.goal.name,
                                    brl(g.remainingCents),
                                    brl(g.monthlyCents ?? 0),
                                  ),
                          GoalYearPhase.future =>
                            g.goal.targetDate != null
                                ? l.annualGoalFutureDate(
                                    g.goal.name,
                                    brl(g.remainingCents),
                                    fmtDateBR(g.goal.targetDate!),
                                  )
                                : l.annualGoalFutureOpen(
                                    g.goal.name,
                                    brl(g.remainingCents),
                                  ),
                        }, style: Type.bodySmall.copyWith(color: c.text)),
                        const SizedBox(height: 4),
                        RhythmBar(
                          percent: g.percent,
                          expectedPercent: g.expectedPercent,
                        ),
                      ],
                    ),
                  ),
              if (_year > thisYear)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l.annualFutureNote,
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
