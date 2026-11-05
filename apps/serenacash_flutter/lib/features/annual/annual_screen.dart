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
    final goals = s.ledger.goals
        .where((g) => g.isActive)
        .map((g) => goalProgress(s.ledger, g, s.today))
        .where((p) => p.remainingCents > 0)
        .toList();
    final monthsLeft = _year == int.parse(currentMonth.substring(0, 4))
        ? 13 - int.parse(currentMonth.substring(5, 7))
        : 12;
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
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.annualGoals),
              if (goals.isEmpty)
                Text(
                  l.noGoal,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final p in goals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.goalNeedPerMonth(
                            p.goal.name,
                            brl(p.remainingCents),
                            brl(
                              (p.remainingCents /
                                      (monthsLeft < 1 ? 1 : monthsLeft))
                                  .ceil(),
                            ),
                          ),
                          style: Type.bodySmall.copyWith(color: c.text),
                        ),
                        const SizedBox(height: 4),
                        RhythmBar(
                          percent: p.percent,
                          expectedPercent: p.expectedPercent,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
