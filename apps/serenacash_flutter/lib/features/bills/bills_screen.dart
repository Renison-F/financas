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

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key, this.filter});
  final String? filter;
  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  String _horizon = 'month';
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
    final late = overdue(s.ledger, t);
    final soon = upcoming(s.ledger, t, until);
    String brl(int v) => formatBRL(v, hidden: hidden);
    Widget payCol(
      Transaction x, {
      bool neg = false,
      bool secondary = false,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Money(pendingCents(x), color: neg ? c.negative : null, hidden: hidden),
        SButton(
          label: l.pay,
          variant: secondary ? SButtonVariant.secondary : SButtonVariant.ghost,
          compact: true,
          onPressed: () => ctl.settleTransaction(x.id),
        ),
      ],
    );
    return StackScreen(
      title: l.billsToPay,
      actions: [
        SButton(
          label: l.newF,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.plus,
          onPressed: () => context.push('/transaction?kind=expense&planned=1'),
        ),
      ],
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SChip(
              label: l.thisMonth,
              selected: _horizon == 'month',
              onTap: () => setState(() => _horizon = 'month'),
            ),
            SChip(
              label: l.days30,
              selected: _horizon == '30',
              onTap: () => setState(() => _horizon = '30'),
            ),
            SChip(
              label: l.days90,
              selected: _horizon == '90',
              onTap: () => setState(() => _horizon = '90'),
            ),
          ],
        ),
        if (late.isNotEmpty || widget.filter == 'overdue')
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(
                  title: l.overdueTotal(
                    brl(late.fold(0, (a, x) => a + pendingCents(x))),
                  ),
                ),
                if (late.isEmpty)
                  Text(
                    l.noOverdue,
                    style: Type.bodySmall.copyWith(color: c.textMuted),
                  )
                else
                  for (final x in late)
                    ListRow(
                      icon: SIconName.alert,
                      iconColor: c.negative,
                      title: x.description.isEmpty ? l.bill : x.description,
                      description: l.duePast(dayMonth(x.dueDate ?? x.date)),
                      trailing: payCol(x, neg: true, secondary: true),
                      onTap: () => context.push('/transaction?id=${x.id}'),
                    ),
              ],
            ),
          ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.dueUntil(
                  dayMonth(until),
                  brl(soon.fold(0, (a, x) => a + pendingCents(x))),
                ),
              ),
              if (soon.isEmpty)
                EmptyState(
                  icon: SIconName.check,
                  title: l.nothingDuePeriod,
                  actionLabel: l.newBillToPay,
                  onAction: () =>
                      context.push('/transaction?kind=expense&planned=1'),
                )
              else
                for (final x in soon)
                  ListRow(
                    icon: x.kind == TransactionKind.loanPayment
                        ? SIconName.bank
                        : SIconName.receipt,
                    title: x.description.isEmpty ? l.bill : x.description,
                    description:
                        '${l.dueOn(dayMonth(x.dueDate ?? x.date))}${x.status == TransactionStatus.partiallyPaid ? l.alreadyPaid(brl(x.paidCents ?? 0)) : ''}',
                    trailing: payCol(x),
                    onTap: () => context.push('/transaction?id=${x.id}'),
                  ),
            ],
          ),
        ),
        Text(l.billsHelp, style: Type.caption.copyWith(color: c.textMuted)),
      ],
    );
  }
}
