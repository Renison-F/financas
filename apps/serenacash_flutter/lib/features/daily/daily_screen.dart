/// Daily control: spending and income day by day, the balance as it moved, the daily spending limit
/// and the daily saving target.
///
/// What happened and what is only planned are never mixed in one number: past days show the real
/// balance, future days show a projection of what is already recorded, marked as such.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/daily/daily.dart';
import '../../domain/dates/dates.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});
  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  String _view = 'done';
  int? _limit, _saving;
  bool _carry = false;
  bool _showAllDays = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final ctl = ref.read(appControllerProvider.notifier);
    final hidden = ref.watch(privacyHiddenProvider);
    final locale = Localizations.localeOf(context).toString();
    final today = s.today;
    final month = monthKeyOf(today);
    final sum = dailySummary(s.ledger, today);
    final flow = dailyFlow(s.ledger, month, today);
    final targets = ctl.dailyTargets;
    final limitDays = spendLimitHistory(s.ledger, targets, today);
    final savingDays = savingHistory(s.ledger, targets, today);
    final limitNow = targetOn(targets, DailyTarget.spendLimit, today);
    final savingNow = targetOn(targets, DailyTarget.saving, today);
    String brl(int v) => formatBRL(v, hidden: hidden);
    Widget fact(String label, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Type.rowText.copyWith(color: c.text)),
          ),
          Text(
            value,
            style: Type.rowText.copyWith(
              color: color ?? c.text,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    final shownDays = [
      for (final d in flow)
        if (_view == 'both' || compareISO(d.date, today) <= 0) d,
    ].reversed.toList();
    final visibleDays = _showAllDays ? shownDays : shownDays.take(10).toList();

    return StackScreen(
      title: l.dailyTitle,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.dailySpending),
              fact(l.dailySpentToday, brl(sum.spentTodayCents)),
              fact(l.dailySpentYesterday, brl(sum.spentYesterdayCents)),
              fact(l.dailySpentMonth, brl(sum.spentMonthCents)),
              fact(
                l.dailyAverageCalendar(sum.daysElapsed),
                brl(sum.averagePerCalendarDayCents),
              ),
              fact(
                l.dailyAverageSpending(sum.daysWithSpending),
                sum.averagePerSpendingDayCents == null
                    ? '—'
                    : brl(sum.averagePerSpendingDayCents!),
              ),
              const SizedBox(height: 4),
              Text(
                sum.previousMonthSameDaysCents == null
                    ? l.dailyNoPreviousMonth
                    : l.dailyPreviousMonth(
                        sum.daysElapsed,
                        brl(sum.previousMonthSameDaysCents!),
                      ),
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.dailyCashflow),
              fact(l.dailyOpening, brl(sum.openingBalanceCents)),
              fact(
                l.dailyReceivedMonth,
                brl(sum.receivedMonthCents),
                color: c.positive,
              ),
              fact(l.dailySpentMonth, brl(sum.spentMonthCents)),
              fact(l.dailyBalanceToday, brl(sum.balanceTodayCents)),
              const SizedBox(height: 4),
              Text(
                l.dailyBalanceNote,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: Spacing.sm),
              Segmented<String>(
                options: [('done', l.dailyViewDone), ('both', l.dailyViewBoth)],
                value: _view,
                onChanged: (v) => setState(() => _view = v),
              ),
              const SizedBox(height: Spacing.xs),
              for (final d in visibleDays)
                Builder(
                  builder: (context) {
                    final future = compareISO(d.date, today) > 0;
                    final moved =
                        d.incomeCents != 0 ||
                        d.expenseCents != 0 ||
                        d.plannedIncomeCents != 0 ||
                        d.plannedExpenseCents != 0;
                    final parts = [
                      if (d.incomeCents != 0) l.dailyDayIn(brl(d.incomeCents)),
                      if (d.expenseCents != 0)
                        l.dailyDayOut(brl(d.expenseCents)),
                      if (future && d.plannedIncomeCents != 0)
                        l.dailyDayPlannedIn(brl(d.plannedIncomeCents)),
                      if (future && d.plannedExpenseCents != 0)
                        l.dailyDayPlannedOut(brl(d.plannedExpenseCents)),
                      if (!moved) l.dailyDayNothing,
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Opacity(
                        opacity: future ? 0.75 : 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 58,
                              child: Text(
                                d.date == today
                                    ? l.today
                                    : dayMonthShort(d.date, locale),
                                style: Type.rowText.copyWith(
                                  color: d.date == today ? c.primary : c.text,
                                  fontWeight: d.date == today
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                parts.join(' · '),
                                style: Type.rowMeta.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ),
                            Text(
                              future
                                  ? l.dailyDayProjected(
                                      brl(d.projectedBalanceCents ?? 0),
                                    )
                                  : brl(d.balanceCents ?? 0),
                              style: Type.rowText.copyWith(
                                color: c.text,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (shownDays.length > visibleDays.length)
                SButton(
                  label: l.dailyShowAllDays(shownDays.length),
                  variant: SButtonVariant.ghost,
                  compact: true,
                  onPressed: () => setState(() => _showAllDays = true),
                ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.dailyLimitTitle),
              if (limitNow == null)
                Text(
                  l.dailyLimitNone,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else ...[
                Builder(
                  builder: (context) {
                    final day = limitDays.lastOrNull;
                    final within = limitDays.where((d) => d.within).length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        fact(
                          l.dailyLimitCurrent(fmtDateBR(limitNow.validFrom)),
                          brl(limitNow.amountCents),
                        ),
                        if (day != null && day.date == today) ...[
                          if (limitNow.carryOver)
                            fact(l.dailyLimitCarried, brl(day.carriedCents)),
                          fact(l.dailySpentToday, brl(day.spentCents)),
                          fact(
                            day.within
                                ? l.dailyLimitLeft
                                : l.dailyLimitExceeded,
                            brl(day.remainingCents.abs()),
                            color: day.within ? null : c.negative,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          l.dailyLimitHistory(within, limitDays.length),
                          style: Type.caption.copyWith(color: c.textMuted),
                        ),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: Spacing.sm),
              MoneyField(
                label: limitNow == null ? l.dailyLimitNew : l.dailyLimitChange,
                cents: _limit,
                onChanged: (v) => setState(() => _limit = v),
                help: l.dailyLimitHelp,
              ),
              ToggleRow(
                label: l.dailyCarry,
                value: _carry,
                help: l.dailyCarryHelp,
                onChanged: (v) => setState(() => _carry = v),
              ),
              const SizedBox(height: Spacing.xs),
              SButton(
                label: l.dailyLimitSave,
                fullWidth: true,
                onPressed: (_limit ?? 0) <= 0
                    ? null
                    : () async {
                        await ctl.setDailyTarget(
                          kind: DailyTarget.spendLimit,
                          amountCents: _limit!,
                          carryOver: _carry,
                        );
                        if (mounted) setState(() => _limit = null);
                      },
              ),
              if (limitNow != null)
                SButton(
                  label: l.dailyLimitEnd,
                  variant: SButtonVariant.ghost,
                  fullWidth: true,
                  compact: true,
                  onPressed: () => ctl.endDailyTarget(DailyTarget.spendLimit),
                ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.dailySavingTitle),
              Text(
                l.dailySavingRule,
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              if (savingNow != null)
                Builder(
                  builder: (context) {
                    final day = savingDays.lastOrNull;
                    final target = sumCents(
                      savingDays.map((d) => d.targetCents),
                    );
                    final confirmed = sumCents(
                      savingDays.map((d) => d.confirmedCents),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        fact(
                          l.dailySavingCurrent(fmtDateBR(savingNow.validFrom)),
                          brl(savingNow.amountCents),
                        ),
                        if (day != null && day.date == today) ...[
                          fact(
                            l.dailySavingConfirmed,
                            brl(day.confirmedCents),
                            color: day.confirmedCents > 0 ? c.positive : null,
                          ),
                          fact(l.dailySavingPending, brl(day.pendingCents)),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          l.dailySavingHistory(
                            brl(confirmed),
                            brl(target),
                            savingDays.length,
                          ),
                          style: Type.caption.copyWith(color: c.textMuted),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: Spacing.sm),
              MoneyField(
                label: savingNow == null
                    ? l.dailySavingNew
                    : l.dailySavingChange,
                cents: _saving,
                onChanged: (v) => setState(() => _saving = v),
              ),
              const SizedBox(height: Spacing.xs),
              SButton(
                label: l.dailySavingSave,
                fullWidth: true,
                onPressed: (_saving ?? 0) <= 0
                    ? null
                    : () async {
                        await ctl.setDailyTarget(
                          kind: DailyTarget.saving,
                          amountCents: _saving!,
                        );
                        if (mounted) setState(() => _saving = null);
                      },
              ),
              SButton(
                label: l.dailySavingDeposit,
                variant: SButtonVariant.secondary,
                fullWidth: true,
                compact: true,
                onPressed: () => context.push('/goals'),
              ),
              if (savingNow != null)
                SButton(
                  label: l.dailySavingEnd,
                  variant: SButtonVariant.ghost,
                  fullWidth: true,
                  compact: true,
                  onPressed: () => ctl.endDailyTarget(DailyTarget.saving),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
