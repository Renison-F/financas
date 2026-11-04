/// Credit card invoices, commitments, installments and refunds. Mirrors `packages/core/src/domain/cards.ts`.
library;

import '../dates/dates.dart';
import '../entities/entities.dart';
import '../ledger/ledger.dart';
import '../money/money.dart';

/// Invoice month for a purchase: on or before the closing day → that month's invoice; after → next month.
MonthKey invoiceMonthFor(int closingDay, ISODate purchaseDate) {
  final p = parts(purchaseDate);
  final key = monthKeyOf(purchaseDate);
  return p.day <= closingDay ? key : addMonthsToKey(key, 1);
}

ISODate invoiceClosingDate(int closingDay, MonthKey invoiceMonth) =>
    monthKeyToDate(invoiceMonth, closingDay);

ISODate invoiceDueDate(int closingDay, int dueDay, MonthKey invoiceMonth) {
  final key = dueDay > closingDay
      ? invoiceMonth
      : addMonthsToKey(invoiceMonth, 1);
  return monthKeyToDate(key, dueDay);
}

MonthKey purchaseInvoiceMonth(CreditCard card, Transaction t) =>
    t.invoiceMonth ?? invoiceMonthFor(card.closingDay, t.date);

enum InvoiceState { open, closed, paid, overdue, future }

String invoiceStateWire(InvoiceState s) => s.name;

class Invoice {
  const Invoice({
    required this.cardId,
    required this.month,
    required this.closingDate,
    required this.dueDate,
    required this.purchases,
    required this.refunds,
    required this.payments,
    required this.totalCents,
    required this.paidCents,
    required this.remainingCents,
    required this.state,
  });
  final Id cardId;
  final MonthKey month;
  final ISODate closingDate;
  final ISODate dueDate;
  final List<Transaction> purchases;
  final List<Transaction> refunds;
  final List<Transaction> payments;
  final Cents totalCents;
  final Cents paidCents;
  final Cents remainingCents;
  final InvoiceState state;
}

List<Transaction> cardPurchases(Ledger ledger, Id cardId) => ledger.transactions
    .where(
      (t) =>
          isActive(t) &&
          t.kind == TransactionKind.cardPurchase &&
          t.cardId == cardId,
    )
    .toList();
List<Transaction> cardRefunds(Ledger ledger, Id cardId) => ledger.transactions
    .where(
      (t) =>
          isActive(t) &&
          t.kind == TransactionKind.cardRefund &&
          t.cardId == cardId,
    )
    .toList();
List<Transaction> cardPayments(Ledger ledger, Id cardId) => ledger.transactions
    .where(
      (t) =>
          isActive(t) &&
          t.kind == TransactionKind.cardPayment &&
          t.cardId == cardId,
    )
    .toList();

Invoice invoice(Ledger ledger, CreditCard card, MonthKey month, ISODate today) {
  final purchases = cardPurchases(
    ledger,
    card.id,
  ).where((t) => purchaseInvoiceMonth(card, t) == month).toList();
  // A refund (estorno) credits the invoice it is assigned to (normally the invoice of the date it was issued).
  final refunds = cardRefunds(
    ledger,
    card.id,
  ).where((t) => purchaseInvoiceMonth(card, t) == month).toList();
  final payments = cardPayments(ledger, card.id)
      .where(
        (t) =>
            t.invoiceMonth == month &&
            (isSettled(t) || t.status == TransactionStatus.partiallyPaid),
      )
      .toList();
  final totalCents =
      sumCents(purchases.map((t) => t.amountCents)) -
      sumCents(refunds.map((t) => t.amountCents));
  final paidCents = sumCents(payments.map(effectiveCents));
  final remainingCents = (totalCents - paidCents).clamp(0, maxSafeCents);
  final closingDate = invoiceClosingDate(card.closingDay, month);
  final dueDate = invoiceDueDate(card.closingDay, card.dueDay, month);
  InvoiceState state;
  if (totalCents > 0 && remainingCents == 0) {
    state = InvoiceState.paid;
  } else if (compareISO(today, closingDate) <= 0) {
    state = month.compareTo(monthKeyOf(today)) > 0
        ? InvoiceState.future
        : InvoiceState.open;
  } else if (compareISO(today, dueDate) > 0 && remainingCents > 0) {
    state = InvoiceState.overdue;
  } else {
    state = InvoiceState.closed;
  }
  return Invoice(
    cardId: card.id,
    month: month,
    closingDate: closingDate,
    dueDate: dueDate,
    purchases: purchases,
    refunds: refunds,
    payments: payments,
    totalCents: totalCents,
    paidCents: paidCents,
    remainingCents: remainingCents,
    state: state,
  );
}

/// The invoice currently accumulating purchases.
MonthKey currentInvoiceMonth(CreditCard card, ISODate today) =>
    invoiceMonthFor(card.closingDay, today);

/// All invoice months that have any purchase, refund or payment, ascending.
List<MonthKey> invoiceMonths(Ledger ledger, CreditCard card) {
  final set = <MonthKey>{};
  for (final t in cardPurchases(ledger, card.id)) {
    set.add(purchaseInvoiceMonth(card, t));
  }
  for (final t in cardRefunds(ledger, card.id)) {
    set.add(purchaseInvoiceMonth(card, t));
  }
  for (final t in cardPayments(ledger, card.id)) {
    if (t.invoiceMonth != null) set.add(t.invoiceMonth!);
  }
  return set.toList()..sort();
}

class CardCommitment {
  const CardCommitment({
    required this.currentInvoiceCents,
    required this.closedUnpaidCents,
    required this.futureCents,
    required this.outstandingCents,
    required this.availableLimitCents,
  });
  final Cents currentInvoiceCents;
  final Cents closedUnpaidCents;
  final Cents futureCents;
  final Cents outstandingCents;
  final Cents availableLimitCents;
  Map<String, dynamic> toJson() => {
    'currentInvoiceCents': currentInvoiceCents,
    'closedUnpaidCents': closedUnpaidCents,
    'futureCents': futureCents,
    'outstandingCents': outstandingCents,
    'availableLimitCents': availableLimitCents,
  };
}

CardCommitment cardCommitment(Ledger ledger, CreditCard card, ISODate today) {
  final current = currentInvoiceMonth(card, today);
  var currentInvoiceCents = 0, closedUnpaidCents = 0, futureCents = 0;
  for (final m in invoiceMonths(ledger, card)) {
    final inv = invoice(ledger, card, m, today);
    if (m == current) {
      currentInvoiceCents = addCents(currentInvoiceCents, inv.remainingCents);
    } else if (m.compareTo(current) < 0) {
      closedUnpaidCents = addCents(closedUnpaidCents, inv.remainingCents);
    } else {
      futureCents = addCents(futureCents, inv.remainingCents);
    }
  }
  final outstanding = currentInvoiceCents + closedUnpaidCents + futureCents;
  return CardCommitment(
    currentInvoiceCents: currentInvoiceCents,
    closedUnpaidCents: closedUnpaidCents,
    futureCents: futureCents,
    outstandingCents: outstanding,
    availableLimitCents: card.limitCents - outstanding,
  );
}

class PlannedInstallment {
  const PlannedInstallment({
    required this.number,
    required this.of,
    required this.amountCents,
    required this.date,
    required this.invoiceMonth,
  });
  final int number;
  final int of;
  final Cents amountCents;
  final ISODate date;
  final MonthKey invoiceMonth;
  Map<String, dynamic> toJson() => {
    'number': number,
    'of': of,
    'amountCents': amountCents,
    'date': date,
    'invoiceMonth': invoiceMonth,
  };
}

/// Splits a card purchase into N installments, one per consecutive invoice, summing exactly to the total.
List<PlannedInstallment> planInstallments({
  required Cents totalCents,
  required int count,
  required ISODate purchaseDate,
  required int closingDay,
  int firstInvoiceOffsetMonths = 0,
}) {
  if (count < 1 || count > 120) {
    throw MoneyError('Número de parcelas inválido (1 a 120).');
  }
  final amounts = allocate(totalCents, count);
  final firstMonth = addMonthsToKey(
    invoiceMonthFor(closingDay, purchaseDate),
    firstInvoiceOffsetMonths,
  );
  final anchorDay = parts(purchaseDate).day;
  return [
    for (var i = 0; i < count; i++)
      PlannedInstallment(
        number: i + 1,
        of: count,
        amountCents: amounts[i],
        date: i == 0
            ? purchaseDate
            : addMonthsClamped(purchaseDate, i, anchorDay),
        invoiceMonth: addMonthsToKey(firstMonth, i),
      ),
  ];
}

/// Estorno de compra no cartão: validates that the refund never exceeds the purchase (minus earlier refunds).
/// Returns the refund transaction to persist; the caller assigns id/timestamps.
class RefundValidation {
  const RefundValidation({
    required this.ok,
    this.reason,
    required this.maxRefundableCents,
  });
  final bool ok;
  final String? reason;
  final Cents maxRefundableCents;
}

RefundValidation validateCardRefund(
  Ledger ledger,
  Transaction purchase,
  Cents amountCents,
) {
  if (purchase.kind != TransactionKind.cardPurchase) {
    return const RefundValidation(
      ok: false,
      reason: 'Só compras no cartão podem ser estornadas.',
      maxRefundableCents: 0,
    );
  }
  final already = sumCents(
    ledger.transactions
        .where(
          (t) =>
              isActive(t) &&
              t.kind == TransactionKind.cardRefund &&
              t.refundOfId == purchase.id,
        )
        .map((t) => t.amountCents),
  );
  final max = purchase.amountCents - already;
  if (amountCents <= 0) {
    return RefundValidation(
      ok: false,
      reason: 'Informe um valor maior que zero.',
      maxRefundableCents: max,
    );
  }
  if (amountCents > max) {
    return RefundValidation(
      ok: false,
      reason:
          'O estorno não pode passar de ${formatBRL(max)} (valor da compra menos estornos anteriores).',
      maxRefundableCents: max,
    );
  }
  return RefundValidation(ok: true, maxRefundableCents: max);
}
