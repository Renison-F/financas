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
import '../categories/category_widgets.dart';
import '../home/home_parts.dart' show DueBadge, dueLabel;
import '../shared/format.dart';
import '../shared/stack_screen.dart';

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key, this.filter});
  final String? filter;
  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  String _horizon = 'month';

  /// false: what is still to be paid; true: what is still to be received.
  bool _receivable = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final t = s.today;
    final until = _horizon == 'month'
        ? endOfMonth(monthKeyOf(t))
        : addDays(t, _horizon == '30' ? 30 : 90);
    String brl(int v) => formatBRL(v, hidden: hidden);
    String due(Transaction x) => x.dueDate ?? x.date;

    final List<Transaction> late, soon;
    if (_receivable) {
      // Income registered as expected and not received (or received in part) yet.
      final pending =
          s.ledger.transactions
              .where(
                (x) =>
                    x.deletedAt == null &&
                    x.kind == TransactionKind.income &&
                    (x.status == TransactionStatus.planned ||
                        x.status == TransactionStatus.partiallyPaid),
              )
              .toList()
            ..sort((a, b) => due(a).compareTo(due(b)));
      late = pending.where((x) => due(x).compareTo(t) < 0).toList();
      soon = pending
          .where(
            (x) => due(x).compareTo(t) >= 0 && due(x).compareTo(until) <= 0,
          )
          .toList();
    } else {
      late = overdue(s.ledger, t);
      soon = upcoming(s.ledger, t, until);
    }
    int total(List<Transaction> list) =>
        list.fold(0, (a, x) => a + pendingCents(x));
    final newRoute = _receivable
        ? '/transaction?kind=income&planned=1'
        : '/transaction?kind=expense&planned=1';

    Widget row(Transaction x, {required bool isLate}) {
      final category = s.ledger.categoryById(x.categoryId);
      final label = dueLabel(l, due(x), t);
      final part = x.status == TransactionStatus.partiallyPaid
          ? l.alreadyPaid(brl(x.paidCents ?? 0))
          : '';
      return ListRow(
        leading: category == null ? null : CategoryMark.of(category),
        icon: category != null
            ? null
            : isLate
            ? SIconName.alert
            : x.kind == TransactionKind.loanPayment
            ? SIconName.bank
            : _receivable
            ? SIconName.arrowDown
            : SIconName.receipt,
        iconColor: isLate && !_receivable ? c.negative : null,
        tileColor: isLate && !_receivable ? c.negativeContainer : null,
        title: x.description.isEmpty ? l.bill : x.description,
        descriptionWidget: _receivable
            ? Text(
                '${isLate ? l.expectedSince(dayMonth(due(x))) : l.expectedOn(dayMonth(due(x)))}$part',
                style: Type.rowMeta.copyWith(color: c.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : part.isEmpty
            ? DueBadge(text: label.text, tone: label.tone)
            : Text(
                '${label.text}$part',
                style: Type.rowMeta.copyWith(
                  color: isLate ? c.negative : c.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Money(
              pendingCents(x),
              role: MoneyRole.dense,
              color: _receivable
                  ? c.positive
                  : isLate
                  ? c.negative
                  : null,
              hidden: hidden,
            ),
            const SizedBox(width: Spacing.xs),
            SButton(
              label: _receivable ? l.receive : l.pay,
              variant: SButtonVariant.secondary,
              compact: true,
              onPressed: () => ctl.settleTransaction(x.id),
            ),
          ],
        ),
        onTap: () => context.push('/transaction?id=${x.id}'),
      );
    }

    return StackScreen(
      title: l.billsBoth,
      actions: [
        SButton(
          label: l.newF,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.plus,
          onPressed: () => context.push(newRoute),
        ),
      ],
      children: [
        Segmented<bool>(
          options: [(false, l.segPayable), (true, l.segReceivable)],
          value: _receivable,
          onChanged: (v) => setState(() => _receivable = v),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (key, label) in [
                ('month', l.thisMonth),
                ('30', l.days30),
                ('90', l.days90),
              ]) ...[
                SChip(
                  label: label,
                  selected: _horizon == key,
                  onTap: () => setState(() => _horizon = key),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        if (late.isNotEmpty || (widget.filter == 'overdue' && !_receivable))
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(
                  title: _receivable
                      ? l.receivableLate(brl(total(late)))
                      : l.overdueTotal(brl(total(late))),
                ),
                if (late.isEmpty)
                  Text(
                    l.noOverdue,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  )
                else
                  ...dividedRows([for (final x in late) row(x, isLate: true)]),
              ],
            ),
          ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: _receivable
                    ? l.receivableUntil(dayMonth(until), brl(total(soon)))
                    : l.dueUntil(dayMonth(until), brl(total(soon))),
              ),
              if (soon.isEmpty)
                EmptyState(
                  icon: SIconName.check,
                  title: _receivable ? l.nothingToReceive : l.nothingDuePeriod,
                  actionLabel: _receivable ? l.newReceivable : l.newBillToPay,
                  onAction: () => context.push(newRoute),
                )
              else
                ...dividedRows([for (final x in soon) row(x, isLate: false)]),
            ],
          ),
        ),
        Text(
          _receivable ? l.receivablesHelp : l.billsHelp,
          style: Type.caption.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}
