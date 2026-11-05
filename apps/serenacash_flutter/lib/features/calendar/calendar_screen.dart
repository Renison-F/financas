import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

/// Kinds listed on a day that are not part of its result (see `resultCents`).
bool _onlyMovesMoney(Transaction t) =>
    t.kind != TransactionKind.income &&
    t.kind != TransactionKind.expense &&
    t.kind != TransactionKind.cardPurchase &&
    t.kind != TransactionKind.cardRefund;

/// Month calendar with per-day totals of bills and incomes; tap a day to see its items.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late String _month = monthKeyOf(ref.read(todayProvider));
  late String? _selected = ref.read(todayProvider);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final locale = Localizations.localeOf(context).toString();
    final t = s.today;
    final y = int.parse(_month.substring(0, 4)),
        m = int.parse(_month.substring(5, 7));
    final days = daysInMonth(y, m);
    final first = weekdayOf('$_month-01');
    final byDay = <String, List<Transaction>>{};
    for (final x in s.ledger.transactions) {
      if (!isActive(x)) continue;
      final d = x.dueDate ?? x.date;
      if (monthKeyOf(d) != _month) continue;
      (byDay[d] ??= []).add(x);
    }
    final sel = _selected == null
        ? const <Transaction>[]
        : (byDay[_selected] ?? const <Transaction>[]);
    final wd = locale.startsWith('en')
        ? const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        : const ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    int cents(Transaction x) =>
        x.status == TransactionStatus.settled ? x.amountCents : pendingCents(x);
    return StackScreen(
      title: l.calendar,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SIconButton(
              icon: SIconName.chevronLeft,
              label: l.previousMonth,
              color: c.primary,
              onPressed: () =>
                  setState(() => _month = addMonthsToKey(_month, -1)),
            ),
            Text(
              monthLabelLong(_month, locale),
              style: Type.title.copyWith(color: c.text),
            ),
            SIconButton(
              icon: SIconName.chevronRight,
              label: l.nextMonth,
              color: c.primary,
              onPressed: () =>
                  setState(() => _month = addMonthsToKey(_month, 1)),
            ),
          ],
        ),
        SCard(
          child: Column(
            children: [
              Row(
                children: [
                  for (final w in wd)
                    Expanded(
                      child: Text(
                        w,
                        textAlign: TextAlign.center,
                        style: Type.caption.copyWith(color: c.textMuted),
                      ),
                    ),
                ],
              ),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                children: [
                  for (var i = 0; i < first; i++) const SizedBox(),
                  for (var d = 1; d <= days; d++)
                    Builder(
                      builder: (_) {
                        final iso = '$_month-${d.toString().padLeft(2, '0')}';
                        final items = byDay[iso] ?? const <Transaction>[];
                        final out = items
                            .where((x) => x.kind != TransactionKind.income)
                            .fold(0, (a, x) => a + cents(x));
                        final inc = items
                            .where((x) => x.kind == TransactionKind.income)
                            .fold(0, (a, x) => a + cents(x));
                        final late = items.any(
                          (x) =>
                              x.status != TransactionStatus.settled &&
                              compareISO(x.dueDate ?? x.date, t) < 0 &&
                              x.kind != TransactionKind.income,
                        );
                        final isSel = iso == _selected, isToday = iso == t;
                        return Semantics(
                          button: true,
                          label: l.dayItems(
                            d.toString().padLeft(2, '0'),
                            items.length,
                          ),
                          child: InkWell(
                            onTap: () => setState(() => _selected = iso),
                            borderRadius: BorderRadius.circular(Radii.sm),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSel
                                    ? c.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(Radii.sm),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$d',
                                    style: Type.bodySmall.copyWith(
                                      color: isToday ? c.primary : c.text,
                                      fontWeight: isToday
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (out > 0)
                                          Container(
                                            width: 6,
                                            height: 6,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: late
                                                  ? c.negative
                                                  : c.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        if (inc > 0)
                                          Container(
                                            width: 6,
                                            height: 6,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: c.positive,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_selected != null)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayMonth(_selected!),
                  style: Type.title.copyWith(color: c.text),
                ),
                const SizedBox(height: 6),
                if (sel.isEmpty)
                  Text(
                    l.nothingThisDay,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  )
                else
                  for (final x in sel)
                    ListRow(
                      icon: x.kind == TransactionKind.income
                          ? SIconName.arrowDown
                          : SIconName.receipt,
                      title: x.description.isEmpty
                          ? kindLabel(l, x.kind)
                          : x.description,
                      description:
                          '${kindLabel(l, x.kind)}${x.status != TransactionStatus.settled ? ' · ${l.planned}' : ''}',
                      trailing: Money(
                        x.kind == TransactionKind.income
                            ? x.amountCents
                            : -x.amountCents,
                        signed: x.kind == TransactionKind.income,
                        hidden: hidden,
                      ),
                      onTap: () => context.push('/transaction?id=${x.id}'),
                    ),
                const SizedBox(height: 6),
                Text(
                  l.dayTotal(formatBRL(resultCents(sel), hidden: hidden)),
                  style: Type.caption.copyWith(color: c.textMuted),
                ),
                if (sel.any(_onlyMovesMoney))
                  Text(
                    l.dayTotalHint,
                    style: Type.caption.copyWith(color: c.textMuted),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
