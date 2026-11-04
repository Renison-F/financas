/// Ledger math: effective/pending amounts, account effects, balances, month totals, overdue/upcoming.
/// Mirrors `packages/core/src/domain/ledger.ts` (verified by fixtures `ledger.json`).
library;

import '../dates/dates.dart';
import '../entities/entities.dart';
import '../money/money.dart';

bool isActive(Transaction t) => t.deletedAt == null && t.status != TransactionStatus.cancelled;
bool isSettled(Transaction t) => isActive(t) && t.status == TransactionStatus.settled;
bool isPlanned(Transaction t) => isActive(t) && (t.status == TransactionStatus.planned || t.status == TransactionStatus.partiallyPaid);

/// Amount that has effectively moved money (settled, or the paid part of a partial).
Cents effectiveCents(Transaction t) {
  if (!isActive(t)) return 0;
  if (t.status == TransactionStatus.settled) return t.amountCents;
  if (t.status == TransactionStatus.partiallyPaid) return (t.paidCents ?? 0).clamp(0, t.amountCents);
  return 0;
}

/// Amount still pending (planned, or the remaining part of a partial).
Cents pendingCents(Transaction t) {
  if (!isActive(t)) return 0;
  if (t.status == TransactionStatus.planned) return t.amountCents;
  if (t.status == TransactionStatus.partiallyPaid) return (t.amountCents - (t.paidCents ?? 0)).clamp(0, maxSafeCents);
  return 0;
}

/// Signed effect of a transaction on a given account (effective money only).
Cents accountEffect(Transaction t, Id accountId, [Cents? amount]) {
  final c = amount ?? effectiveCents(t);
  if (c == 0) return 0;
  switch (t.kind) {
    case TransactionKind.income:
    case TransactionKind.loanDisbursement:
      return t.accountId == accountId ? c : 0;
    case TransactionKind.expense:
    case TransactionKind.cardPayment:
    case TransactionKind.loanPayment:
      return t.accountId == accountId ? negate(c) : 0;
    case TransactionKind.transfer:
    case TransactionKind.goalDeposit: // accountId = source, toAccountId = account where the goal money sits (optional)
    case TransactionKind.goalWithdrawal: // accountId = goal account (optional), toAccountId = destination
      return (t.accountId == accountId ? negate(c) : 0) + (t.toAccountId == accountId ? c : 0);
    case TransactionKind.balanceAdjustment:
      if (t.toAccountId == accountId) return c;
      if (t.accountId == accountId) return negate(c);
      return 0;
    case TransactionKind.cardPurchase:
    case TransactionKind.cardRefund:
      return 0; // never touch accounts; invoices do
  }
}

/// Balance of an account as of `asOf` (inclusive), settled money only.
Cents accountBalance(Ledger ledger, Id accountId, [ISODate? asOf]) {
  final account = ledger.accountById(accountId);
  if (account == null) return 0;
  var balance = account.openingBalanceCents;
  for (final t in ledger.transactions) {
    if (!isActive(t)) continue;
    final effDate = t.settledDate ?? t.date;
    if (asOf != null && compareISO(effDate, asOf) > 0) continue;
    balance = addCents(balance, accountEffect(t, accountId));
  }
  return balance;
}

List<Account> activeAccounts(Ledger ledger) => ledger.accounts.where((a) => a.isActive).toList();

Cents consolidatedBalance(Ledger ledger, {List<Id>? accountIds, ISODate? asOf, bool includeArchived = false}) {
  final accounts = (includeArchived ? ledger.accounts.where((a) => a.deletedAt == null) : activeAccounts(ledger)).where((a) => accountIds == null || accountIds.contains(a.id));
  return sumCents(accounts.map((a) => accountBalance(ledger, a.id, asOf)));
}

bool isExpenseLike(Transaction t) => t.kind == TransactionKind.expense || t.kind == TransactionKind.cardPurchase || t.kind == TransactionKind.cardRefund;
bool isIncomeLike(Transaction t) => t.kind == TransactionKind.income;

List<Transaction> transactionsInMonth(Ledger ledger, MonthKey month) => ledger.transactions.where((t) => isActive(t) && monthKeyOf(t.date) == month).toList();

class MonthTotals {
  const MonthTotals({required this.month, required this.incomeSettled, required this.incomePlanned, required this.expenseSettled, required this.expensePlanned, required this.net, required this.cardPurchases});
  final MonthKey month;
  final Cents incomeSettled;
  final Cents incomePlanned;
  final Cents expenseSettled;
  final Cents expensePlanned;
  final Cents net;
  final Cents cardPurchases;
  Map<String, dynamic> toJson() => {'month': month, 'incomeSettled': incomeSettled, 'incomePlanned': incomePlanned, 'expenseSettled': expenseSettled, 'expensePlanned': expensePlanned, 'net': net, 'cardPurchases': cardPurchases};
}

/// Month totals by competence. Card purchases count as expenses in the month of purchase; card payments are
/// NOT expenses (they only move money); card refunds reduce expenses on their date.
MonthTotals monthTotals(Ledger ledger, MonthKey month) {
  var incomeSettled = 0, incomePlanned = 0, expenseSettled = 0, expensePlanned = 0, cardPurchases = 0;
  for (final t in transactionsInMonth(ledger, month)) {
    if (isIncomeLike(t)) {
      incomeSettled = addCents(incomeSettled, effectiveCents(t));
      incomePlanned = addCents(incomePlanned, pendingCents(t));
    }
    if (t.kind == TransactionKind.cardPurchase) {
      expenseSettled = addCents(expenseSettled, t.amountCents);
      cardPurchases = addCents(cardPurchases, t.amountCents);
    } else if (t.kind == TransactionKind.cardRefund) {
      expenseSettled = subCents(expenseSettled, t.amountCents);
      cardPurchases = subCents(cardPurchases, t.amountCents);
    } else if (t.kind == TransactionKind.expense) {
      expenseSettled = addCents(expenseSettled, effectiveCents(t));
      expensePlanned = addCents(expensePlanned, pendingCents(t));
    }
  }
  return MonthTotals(month: month, incomeSettled: incomeSettled, incomePlanned: incomePlanned, expenseSettled: expenseSettled, expensePlanned: expensePlanned, net: incomeSettled - expenseSettled, cardPurchases: cardPurchases);
}

const _billKinds = {TransactionKind.expense, TransactionKind.income, TransactionKind.loanPayment, TransactionKind.cardPayment};
const _payableKinds = {TransactionKind.expense, TransactionKind.loanPayment, TransactionKind.cardPayment};

/// Planned bills whose due date is before `today`.
List<Transaction> overdue(Ledger ledger, ISODate today) => ledger.transactions.where((t) => isPlanned(t) && _billKinds.contains(t.kind) && compareISO(t.effectiveDate, today) < 0).toList();

/// Planned payables within [today, until], sorted by due date.
List<Transaction> upcoming(Ledger ledger, ISODate today, ISODate until) {
  final list = ledger.transactions.where((t) => isPlanned(t) && _payableKinds.contains(t.kind) && compareISO(t.effectiveDate, today) >= 0 && compareISO(t.effectiveDate, until) <= 0).toList();
  list.sort((a, b) => compareISO(a.effectiveDate, b.effectiveDate));
  return list;
}
