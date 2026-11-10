/// Daily control: spending and income day by day, the balance as it moved, the daily spending
/// limits (general, by category, on chosen weekdays) and the daily saving target.
///
/// What happened and what is only planned are never mixed in one number: past days show the real
/// balance, future days show a projection of what is already recorded, marked as such. Every
/// comparison is between periods of the same length, and a simulation is shown as arithmetic on
/// what was recorded, never as a forecast.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/daily/daily.dart';
import '../../domain/dates/dates.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../categories/category_widgets.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

String weekdayShort(AppLocalizations l, int weekday) => switch (weekday) {
  1 => l.weekday1,
  2 => l.weekday2,
  3 => l.weekday3,
  4 => l.weekday4,
  5 => l.weekday5,
  6 => l.weekday6,
  _ => l.weekday7,
};

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

  /// Filters of what is shown (nothing is saved): one expense category, one account, and how many
  /// months away from the current one the day-by-day list is looking.
  String? _category, _account;
  int _monthOffset = 0;

  /// The limit being set: for one category or for all spending, on some weekdays or every day.
  String? _limitCategory;
  final Set<int> _limitDays = {};

  /// The goal the saving target being set is tied to; null = any goal.
  String? _savingGoal;

  /// A short list to choose one thing from, with the "all" option on top.
  Future<({String? id})?> _choose({
    required String title,
    required String allLabel,
    required List<({String id, String name})> options,
    String? selected,
  }) => showSSheet<({String? id})>(
    context,
    useRootNavigator: true,
    builder: (sheet) {
      final c = sheet.colors;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheet).height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            0,
            Spacing.md,
            Spacing.sm,
          ),
          children: [
            Semantics(
              header: true,
              child: Text(title, style: Type.title.copyWith(color: c.text)),
            ),
            const SizedBox(height: Spacing.xs),
            ListRow(
              title: allLabel,
              trailing: selected == null
                  ? SIcon(SIconName.check, size: 18, color: c.primary)
                  : null,
              onTap: () => Navigator.of(sheet).pop((id: null)),
            ),
            for (final o in options)
              ListRow(
                title: o.name,
                trailing: selected == o.id
                    ? SIcon(SIconName.check, size: 18, color: c.primary)
                    : null,
                onTap: () => Navigator.of(sheet).pop((id: o.id)),
              ),
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final ctl = ref.read(appControllerProvider.notifier);
    final hidden = ref.watch(privacyHiddenProvider);
    final locale = Localizations.localeOf(context).toString();
    final ledger = s.ledger;
    final today = s.today;
    final thisMonth = monthKeyOf(today);
    final month = addMonthsToKey(thisMonth, _monthOffset);
    final past = _monthOffset < 0, future = _monthOffset > 0;
    final sum = dailySummary(ledger, today, categoryId: _category);
    final trend = dailyTrend(ledger, today, categoryId: _category);
    final flow = dailyFlow(ledger, month, today, accountId: _account);
    final targets = ctl.dailyTargets;
    final limitDays = spendLimitHistory(ledger, targets, today);
    final savingDays = savingHistory(ledger, targets, today);
    final limitNow = targetSetOn(targets, DailyTarget.spendLimit, today);
    final savingNow = targetSetOn(targets, DailyTarget.saving, today);
    String brl(int v) => formatBRL(v, hidden: hidden);
    String categoryName(String? id) =>
        id == null ? l.dailyFilterAll : (ledger.categoryById(id)?.name ?? '—');
    String accountName(String? id) =>
        id == null ? l.dailyFilterAll : (ledger.accountById(id)?.name ?? '—');
    String goalName(String? id) => id == null
        ? l.dailySavingAnyGoal
        : (ledger.goals.where((g) => g.id == id).firstOrNull?.name ?? '—');
    String days(List<int> weekdays) =>
        weekdays.map((w) => weekdayShort(l, w)).join(', ');

    Widget fact(String label, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Type.rowText.copyWith(color: c.text)),
          ),
          const SizedBox(width: 8),
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
    Widget note(String text) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text, style: Type.caption.copyWith(color: c.textMuted)),
    );
    Widget filter(String label, VoidCallback onTap) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: SChip(label: label, icon: SIconName.filter, onTap: onTap),
    );

    final shownDays = [
      for (final d in flow)
        if (switch (_view) {
          'both' => true,
          'planned' => compareISO(d.date, today) > 0,
          _ => compareISO(d.date, today) <= 0,
        })
          d,
    ];
    // What happened is read from the most recent day back; what is planned, from tomorrow on.
    final ordered = _view == 'planned'
        ? shownDays
        : shownDays.reversed.toList();
    final visibleDays = _showAllDays ? ordered : ordered.take(10).toList();
    final opening = future
        ? projectedBalance(
            ledger,
            addDays(startOfMonth(month), -1),
            today,
            accountId: _account,
          )
        : (_account == null
              ? openingBalance(ledger, month)
              : accountBalance(
                  ledger,
                  _account!,
                  addDays(startOfMonth(month), -1),
                ));
    final closing = flow.last.balanceCents ?? flow.last.projectedBalanceCents!;
    final balanceToday = _account == null
        ? consolidatedBalance(ledger, asOf: today)
        : accountBalance(ledger, _account!, today);

    final simulation = (_limit ?? 0) > 0
        ? simulateLimit(
            ledger,
            _limit!,
            today,
            categoryId: _limitCategory,
            weekdays: _limitDays.toList(),
          )
        : null;
    final daysInMonth =
        diffDays(startOfMonth(thisMonth), endOfMonth(thisMonth)) + 1;

    return StackScreen(
      title: l.dailyTitle,
      children: [
        // ---------------------------------------------------------------- spending of the day
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.dailySpending),
              filter(l.dailyFilterCategory(categoryName(_category)), () async {
                final r = await showCategoryPicker(
                  context,
                  kind: 'expense',
                  selectedId: _category,
                  allowNone: true,
                  noneLabel: l.dailyAllCategories,
                  allowCreate: false,
                );
                if (r != null && mounted) setState(() => _category = r.id);
              }),
              const SizedBox(height: 4),
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
              note(
                sum.previousMonthSameDaysCents == null
                    ? l.dailyNoPreviousMonth
                    : l.dailyPreviousMonth(
                        sum.daysElapsed,
                        brl(sum.previousMonthSameDaysCents!),
                      ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l.dailyTrendTitle,
                style: Type.label.copyWith(color: c.textMuted),
              ),
              fact(l.dailyLast7, brl(trend.last7Cents)),
              fact(
                l.dailyPrevious7,
                trend.previous7Cents == null
                    ? l.dailyNoData
                    : brl(trend.previous7Cents!),
              ),
              fact(
                l.dailySameWeekday,
                trend.sameWeekdayLastWeekCents == null
                    ? l.dailyNoData
                    : brl(trend.sameWeekdayLastWeekCents!),
              ),
              if (sum.spentMonthCents > 0 && trend.daysRemaining > 0)
                note(
                  l.dailyPace(
                    brl(trend.monthAtCurrentPaceCents),
                    trend.daysRemaining,
                  ),
                ),
              if (_category != null) note(l.dailyFilteredNote),
            ],
          ),
        ),
        // ---------------------------------------------------------------- cash flow day by day
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardHeader(title: l.dailyCashflow),
              filter(l.dailyFilterAccount(accountName(_account)), () async {
                final r = await _choose(
                  title: l.dailyCashflow,
                  allLabel: l.dailyAllAccounts,
                  selected: _account,
                  options: [
                    for (final a in ledger.accounts.where((a) => a.isActive))
                      (id: a.id, name: a.name),
                  ],
                );
                if (r != null && mounted) setState(() => _account = r.id);
              }),
              Row(
                children: [
                  SIconButton(
                    icon: SIconName.chevronLeft,
                    label: l.homePrevMonth,
                    color: c.primary,
                    size: 20,
                    onPressed: () => setState(() {
                      _monthOffset--;
                      _showAllDays = false;
                    }),
                  ),
                  Expanded(
                    child: Text(
                      l.dailyMonthOf(
                        locale.startsWith('pt')
                            ? monthLabelLong(month, locale).toLowerCase()
                            : monthLabelLong(month, locale),
                      ),
                      textAlign: TextAlign.center,
                      style: Type.rowTitle.copyWith(color: c.text),
                    ),
                  ),
                  SIconButton(
                    icon: SIconName.chevronRight,
                    label: l.homeNextMonth,
                    color: c.primary,
                    size: 20,
                    onPressed: () => setState(() {
                      _monthOffset++;
                      _showAllDays = false;
                    }),
                  ),
                ],
              ),
              fact(
                future ? l.dailyOpeningProjected : l.dailyOpening,
                brl(opening),
              ),
              fact(
                l.dailyReceivedMonth,
                brl(sumCents(flow.map((d) => d.incomeCents))),
                color: c.positive,
              ),
              fact(
                l.dailySpentMonth,
                brl(sumCents(flow.map((d) => d.expenseCents))),
              ),
              if (past)
                fact(l.dailyClosing, brl(closing))
              else ...[
                if (!future) fact(l.dailyBalanceToday, brl(balanceToday)),
                fact(l.dailyClosingProjected, brl(closing)),
              ],
              note(l.dailyBalanceNote),
              if (_account != null) note(l.dailyAccountNote),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (id, label) in [
                    ('done', l.dailyViewDone),
                    ('planned', l.dailyViewPlanned),
                    ('both', l.dailyViewBoth),
                  ])
                    SChip(
                      label: label,
                      selected: _view == id,
                      onTap: () => setState(() {
                        _view = id;
                        _showAllDays = false;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              if (visibleDays.isEmpty) note(l.dailyNoDays),
              for (final d in visibleDays)
                Builder(
                  builder: (context) {
                    final ahead = compareISO(d.date, today) > 0;
                    final moved =
                        d.incomeCents != 0 ||
                        d.expenseCents != 0 ||
                        d.plannedIncomeCents != 0 ||
                        d.plannedExpenseCents != 0;
                    final parts = [
                      if (d.incomeCents != 0) l.dailyDayIn(brl(d.incomeCents)),
                      if (d.expenseCents != 0)
                        l.dailyDayOut(brl(d.expenseCents)),
                      if (ahead && d.plannedIncomeCents != 0)
                        l.dailyDayPlannedIn(brl(d.plannedIncomeCents)),
                      if (ahead && d.plannedExpenseCents != 0)
                        l.dailyDayPlannedOut(brl(d.plannedExpenseCents)),
                      if (!moved) l.dailyDayNothing,
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Opacity(
                        opacity: ahead ? 0.75 : 1,
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
                              ahead
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
              if (ordered.length > visibleDays.length)
                SButton(
                  label: l.dailyShowAllDays(ordered.length),
                  variant: SButtonVariant.ghost,
                  compact: true,
                  onPressed: () => setState(() => _showAllDays = true),
                ),
            ],
          ),
        ),
        // ---------------------------------------------------------------- spending limits
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
              else
                _LimitStatus(
                  target: limitNow,
                  history: limitDays,
                  today: today,
                  brl: brl,
                  fact: fact,
                  note: note,
                  weekdays: days(limitNow.weekdays),
                ),
              if (limitedCategories(targets).any(
                (id) =>
                    targetSetOn(
                      targets,
                      DailyTarget.spendLimit,
                      today,
                      categoryId: id,
                    ) !=
                    null,
              )) ...[
                const SizedBox(height: Spacing.sm),
                Text(
                  l.dailyLimitByCategory,
                  style: Type.label.copyWith(color: c.textMuted),
                ),
                for (final id in limitedCategories(targets))
                  if (targetSetOn(
                        targets,
                        DailyTarget.spendLimit,
                        today,
                        categoryId: id,
                      )
                      case final t?) ...[
                    const SizedBox(height: 4),
                    Text(
                      categoryName(id),
                      style: Type.rowTitle.copyWith(color: c.text),
                    ),
                    _LimitStatus(
                      target: t,
                      history: spendLimitHistory(
                        ledger,
                        targets,
                        today,
                        categoryId: id,
                      ),
                      today: today,
                      brl: brl,
                      fact: fact,
                      note: note,
                      weekdays: days(t.weekdays),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SButton(
                        label: l.dailyLimitEndFor(categoryName(id)),
                        variant: SButtonVariant.ghost,
                        compact: true,
                        onPressed: () => ctl.endDailyTarget(
                          DailyTarget.spendLimit,
                          categoryId: id,
                        ),
                      ),
                    ),
                  ],
              ],
              const SizedBox(height: Spacing.sm),
              MoneyField(
                label: limitNow == null ? l.dailyLimitNew : l.dailyLimitChange,
                cents: _limit,
                onChanged: (v) => setState(() => _limit = v),
                help: l.dailyLimitHelp,
              ),
              const SizedBox(height: Spacing.xs),
              filter(
                l.dailyLimitScope(
                  _limitCategory == null
                      ? l.dailyLimitAllSpending
                      : categoryName(_limitCategory),
                ),
                () async {
                  final r = await showCategoryPicker(
                    context,
                    kind: 'expense',
                    selectedId: _limitCategory,
                    allowNone: true,
                    noneLabel: l.dailyLimitAllSpending,
                    allowCreate: false,
                  );
                  if (r != null && mounted) {
                    setState(() => _limitCategory = r.id);
                  }
                },
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l.dailyLimitWeekdays,
                style: Type.caption.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var w = 1; w <= 7; w++)
                    SChip(
                      label: weekdayShort(l, w),
                      selected: _limitDays.contains(w),
                      onTap: () => setState(
                        () => _limitDays.contains(w)
                            ? _limitDays.remove(w)
                            : _limitDays.add(w),
                      ),
                    ),
                ],
              ),
              ToggleRow(
                label: l.dailyCarry,
                value: _carry,
                help: l.dailyCarryHelp,
                onChanged: (v) => setState(() => _carry = v),
              ),
              if (simulation != null)
                note(
                  l.dailySimLimit(
                    brl(_limit!),
                    brl(simulation.monthTotalCents),
                    simulation.daysInMonth,
                    simulation.daysChecked,
                    simulation.daysWithin,
                  ),
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
                          categoryId: _limitCategory,
                          weekdays: _limitDays.toList(),
                        );
                        if (mounted) {
                          setState(() {
                            _limit = null;
                            _limitCategory = null;
                            _limitDays.clear();
                          });
                        }
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
              ToggleRow(
                label: l.dailyAlertsToggle,
                value: ledger.prefs.dailyAlerts,
                onChanged: (v) =>
                    ctl.setPrefs((p) => p.copyWith(dailyAlerts: v)),
              ),
            ],
          ),
        ),
        // ---------------------------------------------------------------- saving target
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
                        if (savingNow.goalId != null)
                          note(l.dailySavingScope(goalName(savingNow.goalId))),
                        if (day != null && day.date == today) ...[
                          fact(
                            l.dailySavingConfirmed,
                            brl(day.confirmedCents),
                            color: day.confirmedCents > 0 ? c.positive : null,
                          ),
                          fact(l.dailySavingPending, brl(day.pendingCents)),
                        ],
                        note(
                          l.dailySavingHistory(
                            brl(confirmed),
                            brl(target),
                            savingDays.length,
                          ),
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
              filter(l.dailySavingScope(goalName(_savingGoal)), () async {
                final r = await _choose(
                  title: l.dailySavingTitle,
                  allLabel: l.dailyAnyGoal,
                  selected: _savingGoal,
                  options: [
                    for (final g in ledger.goals.where(
                      (g) => !g.archived && g.deletedAt == null,
                    ))
                      (id: g.id, name: g.name),
                  ],
                );
                if (r != null && mounted) setState(() => _savingGoal = r.id);
              }),
              if ((_saving ?? 0) > 0)
                note(
                  l.dailySimSaving(
                    brl(_saving!),
                    brl(
                      mulCents(
                        _saving!,
                        daysInMonth.toDouble(),
                        RoundingMode.halfUp,
                      ),
                    ),
                    brl(mulCents(_saving!, 365, RoundingMode.halfUp)),
                  ),
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
                          goalId: _savingGoal,
                        );
                        if (mounted) {
                          setState(() {
                            _saving = null;
                            _savingGoal = null;
                          });
                        }
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

/// One spending limit: its value, the weekdays it applies on, where today stands against it and
/// on how many days of the month it was kept.
class _LimitStatus extends StatelessWidget {
  const _LimitStatus({
    required this.target,
    required this.history,
    required this.today,
    required this.brl,
    required this.fact,
    required this.note,
    required this.weekdays,
  });
  final DailyTarget target;
  final List<SpendLimitDay> history;
  final ISODate today;
  final String Function(int) brl;
  final Widget Function(String, String, {Color? color}) fact;
  final Widget Function(String) note;
  final String weekdays;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final day = history.where((d) => d.date == today).firstOrNull;
    final within = history.where((d) => d.within).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fact(
          l.dailyLimitCurrent(fmtDateBR(target.validFrom)),
          brl(target.amountCents),
        ),
        if (weekdays.isNotEmpty) note(l.dailyLimitOnDays(weekdays)),
        if (day != null) ...[
          if (target.carryOver)
            fact(l.dailyLimitCarried, brl(day.carriedCents)),
          fact(l.dailySpentToday, brl(day.spentCents)),
          fact(
            day.within ? l.dailyLimitLeft : l.dailyLimitExceeded,
            brl(day.remainingCents.abs()),
            color: day.within ? null : c.negative,
          ),
        ] else
          note(l.dailyLimitNotToday),
        note(l.dailyLimitHistory(within, history.length)),
      ],
    );
  }
}
