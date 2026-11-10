/// Balance of the period with a timeline the user can touch: opening, current and expected balance,
/// the month day by day in two views (balance, or what came in and went out), and the facts of the
/// day that is touched. Past, present and future months use the same card; what is a fact and what
/// is only planned are always drawn and named differently.
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
import '../../ui/components/components.dart';
import '../shared/format.dart';
import 'home_parts.dart';

class PeriodBalanceCard extends StatefulWidget {
  const PeriodBalanceCard({
    super.key,
    required this.ledger,
    required this.data,
    required this.hidden,
  });
  final Ledger ledger;
  final DashboardData data;
  final bool hidden;
  @override
  State<PeriodBalanceCard> createState() => _PeriodBalanceCardState();
}

class _PeriodBalanceCardState extends State<PeriodBalanceCard> {
  int? _day;
  bool _flowView = false;

  @override
  void didUpdateWidget(PeriodBalanceCard old) {
    super.didUpdateWidget(old);
    // Another month has other days: the day that was selected means nothing there.
    if (old.data.month != widget.data.month) _day = null;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = widget.ledger, data = widget.data, hidden = widget.hidden;
    if (ledger.accounts.where((a) => a.isActive).isEmpty) {
      return HomeCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: EmptyRow(
          icon: SIconName.wallet,
          title: l.homeNoAccountForBalance,
          actionLabel: l.add,
          onAction: () => context.push('/accounts/new'),
        ),
      );
    }
    final month = data.month, today = data.today;
    final thisMonth = monthKeyOf(today);
    final past = month.compareTo(thisMonth) < 0;
    final future = month.compareTo(thisMonth) > 0;
    final flow = dailyFlow(ledger, month, today);
    final opening = future
        ? projectedBalance(ledger, addDays(startOfMonth(month), -1), today)
        : openingBalance(ledger, month);
    final closing = flow.last.balanceCents ?? flow.last.projectedBalanceCents!;
    final current = consolidatedBalance(ledger, asOf: today);
    final todayIndex = flow.indexWhere((d) => d.date == today);
    // Index of the last day that is a fact: everything after it is planned.
    final lastFact = past
        ? flow.length - 1
        : future
        ? -1
        : todayIndex;
    final selected = _day != null && _day! < flow.length ? _day : null;
    String brl(int v) => formatBRL(v, hidden: hidden);
    final compact = context.look.compactCharts;
    final locale = Localizations.localeOf(context).toString();

    void select(int? i) => setState(() => _day = i);
    int indexAt(double dx, double width) =>
        (dx / width * (flow.length - 1)).round().clamp(0, flow.length - 1);

    String describe(DayFlow d) {
      final fact = d.balanceCents != null;
      return [
        dayTitle(d.date, locale),
        fact
            ? l.timelineBalance(brl(d.balanceCents!))
            : l.timelineProjected(brl(d.projectedBalanceCents!)),
        if (d.incomeCents != 0) l.timelineReceived(brl(d.incomeCents)),
        if (d.expenseCents != 0) l.timelineSpent(brl(d.expenseCents)),
        if (d.plannedIncomeCents != 0)
          l.timelineToReceive(brl(d.plannedIncomeCents)),
        if (d.plannedExpenseCents != 0)
          l.timelineToPay(brl(d.plannedExpenseCents)),
      ].join(' · ');
    }

    // For a screen reader the chart is a slider over the days: the first step lands on today (or
    // on the first day of a month that is not the current one), the next ones move a day at a time.
    final start = lastFact < 0 || past ? 0 : lastFact;
    final next = selected == null
        ? start
        : (selected + 1).clamp(0, flow.length - 1);
    final previous = selected == null
        ? start
        : (selected - 1).clamp(0, flow.length - 1);
    final chart = LayoutBuilder(
      builder: (context, box) => Semantics(
        container: true,
        slider: true,
        label: _flowView ? l.timelineFlowLabel : l.homeTimelineLabel,
        value: selected == null ? l.timelineNoDay : describe(flow[selected]),
        increasedValue: describe(flow[next]),
        decreasedValue: describe(flow[previous]),
        onIncrease: () => select(next),
        onDecrease: () => select(previous),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => select(indexAt(d.localPosition.dx, box.maxWidth)),
          onHorizontalDragUpdate: (d) =>
              select(indexAt(d.localPosition.dx, box.maxWidth)),
          child: SizedBox(
            key: const ValueKey('timeline-chart'),
            height: compact ? 52 : 88,
            width: double.infinity,
            child: CustomPaint(
              painter: _flowView
                  ? _FlowPainter(
                      days: flow,
                      selected: selected,
                      income: c.positive,
                      expense: c.text,
                      planned: c.textMuted,
                      axis: c.border,
                      marker: c.primary,
                    )
                  : _BalancePainter(
                      values: [
                        for (final d in flow)
                          d.balanceCents ?? d.projectedBalanceCents ?? 0,
                      ],
                      lastFact: lastFact,
                      selected: selected,
                      color: c.primary,
                      muted: c.textMuted,
                      zero: c.border,
                    ),
            ),
          ),
        ),
      ),
    );

    Widget figure(
      String label,
      int cents, {
      Color? color,
      bool signed = false,
    }) => Expanded(
      child: _Stacked(
        label: label,
        cents: cents,
        hidden: hidden,
        color: color,
        signed: signed,
      ),
    );
    final change = closing - opening;
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: l.homePeriodBalance,
            action: SButton(
              label: l.homeDayByDay,
              variant: SButtonVariant.ghost,
              compact: true,
              onPressed: () => context.push('/daily'),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              figure(future ? l.homeOpeningProjected : l.homeOpening, opening),
              const SizedBox(width: 8),
              if (past)
                figure(l.homeClosing, closing)
              else if (future)
                figure(
                  l.homeClosingProjected,
                  closing,
                  color: closing < 0 ? c.negative : null,
                )
              else
                figure(l.homeBalanceToday, current),
              const SizedBox(width: 8),
              if (past || future)
                figure(
                  future ? l.homeChangeProjected : l.homeChange,
                  change,
                  signed: true,
                  color: change < 0 ? c.negative : null,
                )
              else
                figure(
                  l.homeProjected,
                  closing,
                  color: closing < 0 ? c.negative : null,
                ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Segmented<bool>(
            options: [
              (false, l.timelineViewBalance),
              (true, l.timelineViewFlow),
            ],
            value: _flowView,
            onChanged: (v) => setState(() => _flowView = v),
          ),
          const SizedBox(height: Spacing.xs),
          chart,
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayMonth(flow.first.date),
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
                if (todayIndex >= 0)
                  Text(
                    l.timelineToday(dayMonth(today)),
                    style: Type.caption.copyWith(color: c.primary),
                  ),
                Text(
                  dayMonth(flow.last.date),
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          if (_flowView)
            Text(
              l.timelineFlowLegend,
              style: Type.caption.copyWith(color: c.textMuted),
            ),
          const SizedBox(height: 6),
          if (selected == null)
            Text(
              l.timelineHint,
              style: Type.caption.copyWith(color: c.textMuted),
            )
          else
            _DayLine(
              text: describe(flow[selected]),
              openLabel: l.timelineOpenDay,
              onOpen: () => showDaySheet(context, flow[selected].date),
              onClear: () => select(null),
              clearLabel: l.timelineClear,
            ),
          if (!past) ...[
            const SizedBox(height: 4),
            Text(
              l.homeProjectedNote,
              style: Type.caption.copyWith(color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stacked extends StatelessWidget {
  const _Stacked({
    required this.label,
    required this.cents,
    required this.hidden,
    this.color,
    this.signed = false,
  });
  final String label;
  final int cents;
  final bool hidden, signed;
  final Color? color;
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
      ],
    );
  }
}

/// The day that was touched, in words, with the way into its entries.
class _DayLine extends StatelessWidget {
  const _DayLine({
    required this.text,
    required this.openLabel,
    required this.onOpen,
    required this.onClear,
    required this.clearLabel,
  });
  final String text, openLabel, clearLabel;
  final VoidCallback onOpen, onClear;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 4),
      decoration: BoxDecoration(
        color: c.surfaceInset,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(text, style: Type.rowMeta.copyWith(color: c.text)),
          ),
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              SButton(
                label: clearLabel,
                variant: SButtonVariant.ghost,
                compact: true,
                onPressed: onClear,
              ),
              SButton(
                label: openLabel,
                variant: SButtonVariant.ghost,
                compact: true,
                onPressed: onOpen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Entries of one day, with the way to open each one and to add another on that date.
Future<void> showDaySheet(
  BuildContext context,
  ISODate date,
) => showSSheet<void>(
  context,
  useRootNavigator: true,
  builder: (sheet) => Consumer(
    builder: (context, ref, _) {
      final l = context.l10n;
      final c = context.colors;
      final ledger = ref.watch(ledgerProvider);
      final hidden = ref.watch(privacyHiddenProvider);
      final entries = entriesOn(ledger, date);
      final locale = Localizations.localeOf(context).toString();
      void go(String route) {
        Navigator.of(sheet).pop();
        context.push(route);
      }

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            0,
            Spacing.md,
            Spacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  dayTitle(date, locale),
                  style: Type.title.copyWith(color: c.text),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                  child: Text(
                    l.timelineDayEmpty,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final t in entries)
                        ListRow(
                          icon: isIncomeLike(t)
                              ? SIconName.arrowDown
                              : SIconName.receipt,
                          title: t.description.isEmpty
                              ? kindLabel(l, t.kind)
                              : t.description,
                          description: isPlanned(t)
                              ? '${kindLabel(l, t.kind)} · ${l.timelinePlanned}'
                              : kindLabel(l, t.kind),
                          trailing: Money(
                            signedAmount(t),
                            role: MoneyRole.dense,
                            signed: !isNeutralKind(t.kind),
                            hidden: hidden,
                          ),
                          onTap: () => go('/transaction?id=${t.id}'),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: Spacing.xs),
              SButton(
                label: l.timelineAddOnDay,
                icon: SIconName.plus,
                variant: SButtonVariant.secondary,
                onPressed: () => go('/transaction?date=$date'),
              ),
            ],
          ),
        ),
      );
    },
  ),
);

/// Balance day by day. A fact is a solid line; what is only planned is dashed.
class _BalancePainter extends CustomPainter {
  _BalancePainter({
    required this.values,
    required this.lastFact,
    required this.selected,
    required this.color,
    required this.muted,
    required this.zero,
  });
  final List<int> values;
  final int lastFact;
  final int? selected;
  final Color color, muted, zero;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final span = (hi - lo) == 0 ? 1 : (hi - lo);
    final n = values.length;
    Offset at(int i) => Offset(
      n == 1 ? size.width / 2 : size.width * i / (n - 1),
      (hi - lo) == 0
          ? size.height / 2
          : size.height - 5 - (size.height - 10) * (values[i] - lo) / span,
    );
    if (lo < 0 && hi > 0) {
      final y = size.height - 5 - (size.height - 10) * (0 - lo) / span;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = zero
          ..strokeWidth = 1,
      );
    }
    if (lastFact > 0) {
      final path = Path()..moveTo(at(0).dx, at(0).dy);
      for (var i = 1; i <= lastFact && i < n; i++) {
        path.lineTo(at(i).dx, at(i).dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    final dashed = Paint()
      ..color = muted
      ..strokeWidth = 1.5;
    for (var i = lastFact < 0 ? 0 : lastFact; i < n - 1; i++) {
      final a = at(i), b = at(i + 1);
      canvas.drawLine(a, Offset.lerp(a, b, 0.55)!, dashed);
    }
    if (lastFact >= 0 && lastFact < n) {
      canvas.drawCircle(at(lastFact), 3.5, Paint()..color = color);
    }
    final s = selected;
    if (s != null && s < n) {
      final p = at(s);
      canvas.drawLine(
        Offset(p.dx, 0),
        Offset(p.dx, size.height),
        Paint()
          ..color = muted
          ..strokeWidth = 1,
      );
      canvas.drawCircle(p, 5, Paint()..color = color);
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = zero
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_BalancePainter old) =>
      old.values != values ||
      old.lastFact != lastFact ||
      old.selected != selected ||
      old.color != color;
}

/// What came in (above the line) and went out (below it) each day. Filled bars are facts; outlined
/// bars are what is still planned for the day.
class _FlowPainter extends CustomPainter {
  _FlowPainter({
    required this.days,
    required this.selected,
    required this.income,
    required this.expense,
    required this.planned,
    required this.axis,
    required this.marker,
  });
  final List<DayFlow> days;
  final int? selected;
  final Color income, expense, planned, axis, marker;
  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    var top = 0, bottom = 0;
    for (final d in days) {
      final up = d.incomeCents + d.plannedIncomeCents;
      final down = d.expenseCents + d.plannedExpenseCents;
      if (up > top) top = up;
      if (down > bottom) bottom = down;
    }
    final total = top + bottom;
    // The line between income and expenses sits where the two scales meet; with nothing on one
    // side it goes to that edge.
    final mid = total == 0
        ? size.height / 2
        : 2 + (size.height - 4) * top / total;
    canvas.drawLine(
      Offset(0, mid),
      Offset(size.width, mid),
      Paint()
        ..color = axis
        ..strokeWidth = 1,
    );
    if (total == 0) return;
    final slot = size.width / days.length;
    final w = (slot * 0.6).clamp(2.0, 10.0);
    final unit = (size.height - 4) / total;
    final outline = Paint()
      ..color = planned
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < days.length; i++) {
      final d = days[i];
      final x = slot * i + (slot - w) / 2;
      if (i == selected) {
        canvas.drawRect(
          Rect.fromLTWH(slot * i, 0, slot, size.height),
          Paint()..color = marker.withValues(alpha: 0.14),
        );
      }
      final up = d.incomeCents * unit, upPlan = d.plannedIncomeCents * unit;
      final down = d.expenseCents * unit,
          downPlan = d.plannedExpenseCents * unit;
      if (up > 0) {
        canvas.drawRect(
          Rect.fromLTWH(x, mid - up, w, up),
          Paint()..color = income,
        );
      }
      if (upPlan > 0) {
        canvas.drawRect(
          Rect.fromLTWH(x, mid - up - upPlan, w, upPlan),
          outline,
        );
      }
      if (down > 0) {
        canvas.drawRect(
          Rect.fromLTWH(x, mid, w, down),
          Paint()..color = expense,
        );
      }
      if (downPlan > 0) {
        canvas.drawRect(Rect.fromLTWH(x, mid + down, w, downPlan), outline);
      }
    }
  }

  @override
  bool shouldRepaint(_FlowPainter old) =>
      old.days != days || old.selected != selected || old.income != income;
}
