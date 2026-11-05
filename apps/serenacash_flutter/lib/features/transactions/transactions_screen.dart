import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';
import '../../domain/reports/reports.dart';
import '../../ui/components/components.dart';
import '../shared/add_sheet.dart';
import '../shared/format.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key, this.kind});
  final String? kind;
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late String _month = monthKeyOf(ref.read(todayProvider));
  late String _filter = widget.kind ?? 'all';
  String _query = '';

  @override
  void didUpdateWidget(TransactionsScreen old) {
    super.didUpdateWidget(old);
    if (widget.kind != old.kind && widget.kind != null) _filter = widget.kind!;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final hidden = ref.watch(privacyHiddenProvider);
    final locale = Localizations.localeOf(context).toString();
    final kinds = _filter == 'all' || _filter == 'planned'
        ? null
        : [kindFromWire(_filter)];
    final items = searchTransactions(
      ledger,
      _query,
      SearchFilters(
        kinds: kinds,
        from: '$_month-01',
        to: endOfMonth(_month),
        status: _filter == 'planned'
            ? const [TransactionStatus.planned, TransactionStatus.partiallyPaid]
            : null,
      ),
    );
    final byDay = <String, List<Transaction>>{};
    for (final t in items) {
      (byDay[t.date] ??= []).add(t);
    }
    final totals = monthTotals(ledger, _month);
    final filters = [
      ('all', l.filterAll),
      ('expense', l.expenses),
      ('income', l.income),
      ('card_purchase', l.filterCard),
      ('transfer', l.filterTransfers),
      ('planned', l.filterPlanned),
    ];
    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: AddFab(
        label: l.addTitle,
        onPressed: () => showAddSheet(context),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.md,
                      Spacing.xs,
                      Spacing.md,
                      Spacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SIconButton(
                              icon: SIconName.chevronLeft,
                              label: l.previousMonth,
                              color: c.primary,
                              onPressed: () => setState(
                                () => _month = addMonthsToKey(_month, -1),
                              ),
                            ),
                            Text(
                              monthLabelLong(_month, locale),
                              style: Type.title.copyWith(color: c.text),
                            ),
                            SIconButton(
                              icon: SIconName.chevronRight,
                              label: l.nextMonth,
                              color: c.primary,
                              onPressed: () => setState(
                                () => _month = addMonthsToKey(_month, 1),
                              ),
                            ),
                          ],
                        ),
                        SCard(
                          inset: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _Total(
                                l.inflow,
                                Money(
                                  totals.incomeSettled,
                                  color: c.positive,
                                  hidden: hidden,
                                ),
                              ),
                              _Total(
                                l.outflow,
                                Money(totals.expenseSettled, hidden: hidden),
                              ),
                              _Total(
                                l.result,
                                Money(totals.net, signed: true, hidden: hidden),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        STextField(
                          placeholder: l.searchTransactions,
                          semanticLabel: l.searchTransactions,
                          onChanged: (v) => setState(() => _query = v),
                          textInputAction: TextInputAction.search,
                        ),
                        const SizedBox(height: Spacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final f in filters)
                              SChip(
                                label: f.$2,
                                selected: _filter == f.$1,
                                onTap: () => setState(() => _filter = f.$1),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: EmptyState(
                        icon: SIconName.list,
                        title: _query.isNotEmpty
                            ? l.nothingFound
                            : l.noTransactionMonth,
                        text: _query.isNotEmpty
                            ? l.tryAnotherWord
                            : l.registerWithPlus,
                        actionLabel: _query.isNotEmpty ? null : l.register,
                        onAction: () => context.push(Routes.transaction),
                        compact: false,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.md,
                      0,
                      Spacing.md,
                      120,
                    ),
                    sliver: SliverList.list(
                      children: [
                        for (final e in byDay.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: Spacing.md,
                              bottom: 4,
                            ),
                            child: Text(
                              dayTitle(e.key, locale),
                              style: Type.label.copyWith(color: c.textMuted),
                            ),
                          ),
                          for (final t in e.value) _TxRow(t: t, hidden: hidden),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value);
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: Type.caption.copyWith(color: context.colors.textMuted),
      ),
      value,
    ],
  );
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.t, required this.hidden});
  final Transaction t;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final icon = switch (t.kind) {
      TransactionKind.income => SIconName.arrowDown,
      TransactionKind.transfer => SIconName.swap,
      TransactionKind.cardPurchase => SIconName.card,
      TransactionKind.cardPayment => SIconName.receipt,
      _ => SIconName.arrowUp,
    };
    final iconColor = t.status == TransactionStatus.planned
        ? c.warning
        : t.kind == TransactionKind.income
        ? c.positive
        : c.primary;
    final status = t.status == TransactionStatus.planned
        ? ' · ${l.planned}'
        : t.status == TransactionStatus.partiallyPaid
        ? ' · ${l.paidPart(formatBRL(t.paidCents ?? 0, hidden: hidden))}'
        : '';
    final inst = t.installment != null
        ? ' · ${t.installment!.number}/${t.installment!.of}'
        : '';
    return ListRow(
      icon: icon,
      iconColor: iconColor,
      title: t.description.isEmpty ? kindLabel(l, t.kind) : t.description,
      description: '${kindLabel(l, t.kind)}$status$inst',
      trailing: Money(
        signedAmount(t),
        signed: !isNeutralKind(t.kind),
        hidden: hidden,
      ),
      onTap: () => context.push('/transaction?id=${t.id}'),
    );
  }
}
