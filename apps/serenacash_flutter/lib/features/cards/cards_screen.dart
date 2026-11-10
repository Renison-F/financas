import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/state/dashboard_data.dart';
import '../../app/theme/tokens.dart';
import '../../domain/billing/billing.dart';
import '../../domain/cards/cards.dart';
import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/money/money.dart';
import '../../ui/components/components.dart';
import '../home/widgets.dart';
import '../shared/format.dart';
import '../shared/stack_screen.dart';

String monthShortKey(String m) => '${m.substring(5, 7)}/${m.substring(0, 4)}';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final d = ref.watch(dashboardDataProvider);
    final hidden = ref.watch(privacyHiddenProvider);
    if (d == null) return const SizedBox();
    String brl(int v) => formatBRL(v, hidden: hidden);
    return StackScreen(
      title: l.creditCards,
      actions: [
        SButton(
          label: l.new_,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.plus,
          onPressed: () => context.push('/cards/new'),
        ),
      ],
      children: [
        if (d.cards.isEmpty)
          SCard(
            child: EmptyState(
              icon: SIconName.card,
              title: l.noCard,
              text: l.noCardListText,
              actionLabel: l.addCard,
              onAction: () => context.push('/cards/new'),
            ),
          )
        else ...[
          for (final v in d.cards)
            SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListRow(
                    icon: SIconName.card,
                    title: v.card.name,
                    description: l.closesDueDays(
                      v.card.closingDay,
                      v.card.dueDay,
                    ),
                    trailing: Money(
                      v.invoice.remainingCents,
                      role: MoneyRole.title,
                      hidden: hidden,
                    ),
                    chevron: true,
                    onTap: () => context.push('/cards/${v.card.id}'),
                  ),
                  Text(
                    l.cardSummary(
                      monthShortKey(v.invoice.month),
                      invoiceStateLabel(l, v.invoice.state),
                      brl(v.commitment.availableLimitCents),
                      brl(v.card.limitCents),
                    ),
                    style: Type.caption.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(height: 8),
                  RhythmBar(
                    percent: v.card.limitCents > 0
                        ? v.commitment.outstandingCents /
                              v.card.limitCents *
                              100
                        : 0,
                    label: l.limitCommitted(
                      v.card.limitCents > 0
                          ? (v.commitment.outstandingCents /
                                    v.card.limitCents *
                                    100)
                                .round()
                          : 0,
                    ),
                  ),
                ],
              ),
            ),
          SButton(
            label: l.installmentPurchases,
            variant: SButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => context.push('/cards/installments'),
          ),
        ],
      ],
    );
  }
}

class CardDetailScreen extends ConsumerStatefulWidget {
  const CardDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends ConsumerState<CardDetailScreen> {
  String? _month;
  int? _payAmount;
  String? _payAccount;
  late String _payDate = ref.read(todayProvider);
  bool _paying = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final ledger = s.ledger;
    final hidden = ref.watch(privacyHiddenProvider);
    final card = ledger.cardById(widget.id);
    if (card == null) {
      return StackScreen(
        title: l.card,
        children: [EmptyState(icon: SIconName.alert, title: l.cardNotFound)],
      );
    }
    final month = _month ??= currentInvoiceMonth(card, s.today);
    _payAccount ??=
        card.defaultPaymentAccountId ??
        ledger.accounts.where((a) => a.isActive).firstOrNull?.id;
    final inv = invoice(ledger, card, month, s.today);
    final cm = cardCommitment(ledger, card, s.today);
    final months = invoiceMonths(ledger, card);
    String brl(int v) => formatBRL(v, hidden: hidden);
    final purchases = [...inv.purchases]
      ..sort((a, b) => a.date.compareTo(b.date));
    return StackScreen(
      title: card.name,
      actions: [
        SButton(
          label: l.edit,
          variant: SButtonVariant.ghost,
          compact: true,
          icon: SIconName.edit,
          onPressed: () => context.push('/cards/new?id=${card.id}'),
        ),
      ],
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SIconButton(
              icon: SIconName.chevronLeft,
              label: l.previousInvoice,
              color: c.primary,
              onPressed: () =>
                  setState(() => _month = addMonthsToKey(month, -1)),
            ),
            Text(
              l.invoiceOf(monthShortKey(month)),
              style: Type.title.copyWith(color: c.text),
            ),
            SIconButton(
              icon: SIconName.chevronRight,
              label: l.nextInvoice,
              color: c.primary,
              onPressed: () =>
                  setState(() => _month = addMonthsToKey(month, 1)),
            ),
          ],
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.invoiceState(invoiceStateLabel(l, inv.state)),
                        style: Type.label.copyWith(color: c.textMuted),
                      ),
                      Money(
                        inv.remainingCents,
                        role: MoneyRole.headline,
                        hidden: hidden,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l.closesOn(dayMonth(inv.closingDate)),
                        style: Type.caption.copyWith(color: c.textMuted),
                      ),
                      Text(
                        l.dueOn(dayMonth(inv.dueDate)),
                        style: Type.caption.copyWith(color: c.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l.totalPaid(brl(inv.totalCents), brl(inv.paidCents)),
                style: Type.bodySmall.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: 10),
              RhythmBar(
                percent: card.limitCents > 0
                    ? cm.outstandingCents / card.limitCents * 100
                    : 0,
                label: l.limitCommittedLabel,
              ),
              const SizedBox(height: 4),
              Text(
                l.limitBreakdown(
                  brl(cm.availableLimitCents),
                  brl(card.limitCents),
                  brl(cm.currentInvoiceCents),
                  brl(cm.closedUnpaidCents),
                  brl(cm.futureCents),
                ),
                style: Type.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: l.purchasesThisInvoice,
                action: SButton(
                  label: l.newPurchase,
                  variant: SButtonVariant.ghost,
                  compact: true,
                  icon: SIconName.plus,
                  onPressed: () => context.push(
                    '/transaction?kind=card_purchase&cardId=${card.id}',
                  ),
                ),
              ),
              if (purchases.isEmpty)
                Text(
                  l.noPurchasesInvoice,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final t in purchases)
                  ListRow(
                    icon: SIconName.card,
                    title: t.description.isEmpty ? l.purchase : t.description,
                    description:
                        '${dayMonth(t.date)}${t.installment != null ? l.installmentOf(t.installment!.number, t.installment!.of) : ''}',
                    trailing: Money(t.amountCents, hidden: hidden),
                    onTap: () => context.push('/transaction?id=${t.id}'),
                  ),
              if (inv.refunds.isNotEmpty)
                for (final t in inv.refunds)
                  ListRow(
                    icon: SIconName.arrowDown,
                    iconColor: c.positive,
                    title: t.description.isEmpty
                        ? l.kindCardRefund
                        : t.description,
                    description: dayMonth(t.date),
                    trailing: Money(
                      t.amountCents,
                      color: c.positive,
                      hidden: hidden,
                    ),
                    onTap: () => context.push('/transaction?id=${t.id}'),
                  ),
              if (inv.payments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: Text(
                    l.payments,
                    style: Type.label.copyWith(color: c.textMuted),
                  ),
                ),
                for (final t in inv.payments)
                  ListRow(
                    icon: SIconName.check,
                    title: l.kindCardPayment,
                    description: dayMonth(t.date),
                    trailing: Money(
                      t.amountCents,
                      color: c.positive,
                      hidden: hidden,
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (inv.remainingCents > 0 && inv.state != InvoiceState.future)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.payInvoice),
                Text(
                  l.payInvoiceHelp,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SButton(
                      label: l.totalOf(brl(inv.remainingCents)),
                      variant: SButtonVariant.secondary,
                      compact: true,
                      onPressed: () =>
                          setState(() => _payAmount = inv.remainingCents),
                    ),
                    SButton(
                      label: l.minimum15,
                      variant: SButtonVariant.ghost,
                      compact: true,
                      onPressed: () => setState(
                        () => _payAmount = (inv.remainingCents * 0.15).round(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                MoneyField(
                  label: l.amount,
                  cents: _payAmount,
                  onChanged: (v) => setState(() => _payAmount = v),
                ),
                const SizedBox(height: Spacing.sm),
                Field(
                  label: l.account,
                  child: ChipSelect<String>(
                    options: [
                      for (final a in ledger.accounts.where((a) => a.isActive))
                        (a.id, a.name),
                    ],
                    value: _payAccount,
                    onChanged: (v) => setState(() => _payAccount = v),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                DateField(
                  label: l.paymentDate,
                  value: _payDate,
                  onChanged: (d) => setState(() => _payDate = d),
                  today: s.today,
                  todayLabel: l.today,
                  yesterdayLabel: l.yesterday,
                  tomorrowLabel: l.tomorrow,
                  invalidLabel: l.invalidDate,
                  calendarLabel: l.openCalendar,
                ),
                const SizedBox(height: Spacing.sm),
                SButton(
                  label: l.registerPayment,
                  fullWidth: true,
                  loading: _paying,
                  onPressed: (_payAmount ?? 0) <= 0 || _payAccount == null
                      ? null
                      : () async {
                          setState(() => _paying = true);
                          try {
                            await ref
                                .read(appControllerProvider.notifier)
                                .payInvoice(
                                  cardId: card.id,
                                  invoiceMonth: month,
                                  amountCents: _payAmount!,
                                  accountId: _payAccount!,
                                  date: _payDate,
                                  description: l.invoicePaymentDesc(
                                    monthShortKey(month),
                                  ),
                                );
                            setState(() => _payAmount = null);
                          } finally {
                            if (mounted) setState(() => _paying = false);
                          }
                        },
                ),
              ],
            ),
          ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.invoiceHistory),
              if (months.isEmpty)
                Text(
                  l.noInvoicesYet,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final m in months.reversed)
                  Builder(
                    builder: (_) {
                      final i = invoice(ledger, card, m, s.today);
                      return ListRow(
                        icon: SIconName.receipt,
                        title: monthShortKey(m),
                        description:
                            '${invoiceStateLabel(l, i.state)} · ${l.dueOn(dayMonth(i.dueDate))}',
                        trailing: Money(i.totalCents, hidden: hidden),
                        onTap: () => setState(() => _month = m),
                      );
                    },
                  ),
            ],
          ),
        ),
        Text(
          l.invoiceRule(card.closingDay),
          style: Type.caption.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

class CardFormScreen extends ConsumerStatefulWidget {
  const CardFormScreen({super.key, this.id});
  final String? id;
  @override
  ConsumerState<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends ConsumerState<CardFormScreen> {
  late final existing = widget.id == null
      ? null
      : ref.read(ledgerProvider).cardById(widget.id);
  late final _name = TextEditingController(text: existing?.name ?? '');
  late int? _limit = existing?.limitCents;
  late final _closing = TextEditingController(
    text: '${existing?.closingDay ?? 20}',
  );
  late final _due = TextEditingController(text: '${existing?.dueDay ?? 27}');
  late String? _accountId = existing?.defaultPaymentAccountId;
  String? _error;

  Future<void> _save() async {
    final l = context.l10n;
    final s = ref.read(appControllerProvider).requireValue;
    final cd = int.tryParse(_closing.text), dd = int.tryParse(_due.text);
    if (_name.text.trim().isEmpty) {
      return setState(() => _error = l.nameCardErr);
    }
    if (cd == null || dd == null || cd < 1 || cd > 31 || dd < 1 || dd > 31) {
      return setState(() => _error = l.daysRangeErr);
    }
    final used = s.ledger.transactions.any((t) => t.cardId == existing?.id);
    if (existing != null && used && cd != existing!.closingDay) {
      return setState(() => _error = l.closingChangeErr);
    }
    final lim = withinLimit(
      s.access,
      'cards',
      s.ledger.cards.where((x) => x.isActive).length,
    );
    if (existing == null && !lim.ok) {
      unawaited(context.push('/paywall?feature=unlimited_cards'));
      return;
    }
    final saved = await ref
        .read(appControllerProvider.notifier)
        .saveCard(
          id: existing?.id,
          name: _name.text.trim(),
          limitCents: _limit ?? 0,
          closingDay: cd,
          dueDay: dd,
          defaultPaymentAccountId: _accountId,
        );
    if (mounted) context.pop(saved.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final lim = withinLimit(
      s.access,
      'cards',
      s.ledger.cards.where((x) => x.isActive).length,
    );
    return StackScreen(
      title: existing != null ? l.editCard : l.newCard,
      actions: [
        SButton(label: l.save, variant: SButtonVariant.ghost, onPressed: _save),
      ],
      children: [
        STextField(
          label: l.name,
          controller: _name,
          placeholder: l.cardNameHint,
          autofocus: existing == null,
        ),
        MoneyField(
          label: l.limit,
          cents: _limit,
          onChanged: (v) => setState(() => _limit = v),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Field(
                label: l.closingDay,
                help: l.closingHelp,
                child: STextField(
                  controller: _closing,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  semanticLabel: l.closingDay,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: STextField(
                label: l.dueDay,
                controller: _due,
                keyboardType: TextInputType.number,
                maxLength: 2,
              ),
            ),
          ],
        ),
        if (s.ledger.accounts.isNotEmpty)
          Field(
            label: l.paymentAccount,
            child: ChipSelect<String>(
              options: [
                for (final a in s.ledger.accounts.where((a) => a.isActive))
                  (a.id, a.name),
              ],
              value: _accountId,
              allowNone: true,
              onChanged: (v) => setState(() => _accountId = v),
            ),
          ),
        if (_error != null)
          Text(_error!, style: Type.bodySmall.copyWith(color: c.negative)),
        if (!lim.ok && existing == null)
          Text(
            l.freeLimitCards(lim.limit ?? 0),
            style: Type.bodySmall.copyWith(color: c.warning),
          ),
      ],
    );
  }
}

/// Projection of installment commitments per future invoice, across all cards.
class InstallmentsScreen extends ConsumerWidget {
  const InstallmentsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final s = ref.watch(appControllerProvider).requireValue;
    final hidden = ref.watch(privacyHiddenProvider);
    final ledger = s.ledger;
    final cards = ledger.cards.where((x) => x.isActive).toList();
    final byMonth = <String, ({int cents, int count})>{};
    for (final card in cards) {
      final cur = currentInvoiceMonth(card, s.today);
      for (final m in invoiceMonths(ledger, card)) {
        if (m.compareTo(cur) < 0) continue;
        final rows = invoice(
          ledger,
          card,
          m,
          s.today,
        ).purchases.where((p) => p.installment != null).toList();
        if (rows.isEmpty) continue;
        final e = byMonth[m] ?? (cents: 0, count: 0);
        byMonth[m] = (
          cents: e.cents + rows.fold(0, (a, r) => a + r.amountCents),
          count: e.count + rows.length,
        );
      }
    }
    final months = byMonth.keys.toList()..sort();
    final groups =
        <String, ({String description, int paid, int of, int remaining})>{};
    for (final t in ledger.transactions) {
      if (t.installment == null ||
          t.kind != TransactionKind.cardPurchase ||
          t.deletedAt != null) {
        continue;
      }
      final g =
          groups[t.installment!.groupId] ??
          (
            description: t.description.replaceAll(RegExp(r' \(\d+/\d+\)$'), ''),
            paid: 0,
            of: t.installment!.of,
            remaining: 0,
          );
      final card = ledger.cardById(t.cardId);
      final cur = currentInvoiceMonth(
        card ??
            const CreditCard(
              id: '',
              name: '',
              limitCents: 0,
              closingDay: 1,
              dueDay: 1,
              color: '',
              archived: false,
              currency: 'BRL',
              createdAt: '',
              updatedAt: '',
            ),
        s.today,
      );
      final past = t.invoiceMonth != null && t.invoiceMonth!.compareTo(cur) < 0;
      groups[t.installment!.groupId] = (
        description: g.description,
        paid: g.paid + (past ? 1 : 0),
        of: g.of,
        remaining: g.remaining + (past ? 0 : t.amountCents),
      );
    }
    return StackScreen(
      title: l.installmentPurchases,
      children: [
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.committedPerInvoice),
              if (months.isEmpty)
                EmptyState(icon: SIconName.card, title: l.noFutureInstallments)
              else
                for (final m in months)
                  ListRow(
                    icon: SIconName.calendar,
                    title: monthShortKey(m),
                    description: l.installmentsCount(byMonth[m]!.count),
                    trailing: Money(byMonth[m]!.cents, hidden: hidden),
                  ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.perPurchase),
              if (groups.isEmpty)
                Text(
                  l.noInstallmentPurchase,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                for (final g in groups.values)
                  ListRow(
                    icon: SIconName.card,
                    title: g.description.isEmpty
                        ? l.installmentPurchase
                        : g.description,
                    description: l.pastInvoicesRemaining(
                      g.paid,
                      g.of,
                      formatBRL(g.remaining, hidden: hidden),
                    ),
                    trailing: Money(g.remaining, hidden: hidden),
                  ),
            ],
          ),
        ),
        SButton(
          label: l.cards,
          variant: SButtonVariant.ghost,
          onPressed: () => context.push('/cards'),
        ),
      ],
    );
  }
}
