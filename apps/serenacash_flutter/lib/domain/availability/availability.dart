/// "Pode gastar": an explainable estimate, never a guaranteed balance. Mirrors `availability.ts`.
library;

import '../cards/cards.dart';
import '../dates/dates.dart';
import '../entities/entities.dart';
import '../goals/goals.dart';
import '../ledger/ledger.dart';
import '../money/money.dart';

class AvailabilityLine {
  const AvailabilityLine({required this.key, required this.label, required this.cents, required this.sign, this.note});
  final String key;
  final String label;
  final Cents cents;
  final int sign; // +1 | -1
  final String? note;
  Map<String, dynamic> toJson() => {'key': key, 'label': label, 'cents': cents, 'sign': sign, if (note != null) 'note': note};
}

enum AvailabilityStatus { positive, tight, negative }

class Availability {
  const Availability({required this.availableCents, required this.horizonEnd, required this.lines, required this.mode, required this.hasAccounts, required this.status});
  final Cents availableCents;
  final ISODate horizonEnd;
  final List<AvailabilityLine> lines;
  final String mode; // prudente | otimista
  final bool hasAccounts;
  final AvailabilityStatus status;
  Map<String, dynamic> toJson() => {'availableCents': availableCents, 'horizonEnd': horizonEnd, 'lines': lines.map((l) => l.toJson()).toList(), 'mode': mode, 'hasAccounts': hasAccounts, 'status': status.name};
}

/// + balances of considered accounts (settled) − overdue bills − bills until horizon − card invoices (closed unpaid
/// + current open) − reserved goals kept inside considered accounts − safety cushion (+ planned income in "otimista").
Availability availability(Ledger ledger, {required ISODate today, List<Id>? accountIds, ISODate? horizonEnd, bool? includePlannedIncome, Cents? safetyCushionCents}) {
  final horizon = horizonEnd ?? (ledger.prefs.availabilityHorizon == 'days_30' ? addDays(today, 30) : endOfMonth(monthKeyOf(today)));
  final accounts = activeAccounts(ledger).where((a) => a.includeInAvailability).where((a) => accountIds == null || accountIds.contains(a.id)).toList();
  final balances = sumCents(accounts.map((a) => accountBalance(ledger, a.id)));
  final lines = <AvailabilityLine>[AvailabilityLine(key: 'balances', label: 'Dinheiro nas contas', cents: balances, sign: 1)];

  const billKinds = {TransactionKind.expense, TransactionKind.loanPayment};
  bool accountConsidered(Transaction t) => t.accountId == null || accounts.any((a) => a.id == t.accountId) || !ledger.accounts.any((a) => a.id == t.accountId);
  final bills = ledger.transactions.where((t) => isPlanned(t) && billKinds.contains(t.kind) && compareISO(t.effectiveDate, horizon) <= 0 && accountConsidered(t)).toList();
  final overdueBills = bills.where((t) => compareISO(t.effectiveDate, today) < 0).toList();
  final upcomingBills = bills.where((t) => compareISO(t.effectiveDate, today) >= 0).toList();
  final overdueCents = sumCents(overdueBills.map(pendingCents));
  final upcomingCents = sumCents(upcomingBills.map(pendingCents));
  if (overdueCents != 0) lines.add(AvailabilityLine(key: 'overdue', label: 'Contas atrasadas', cents: overdueCents, sign: -1, note: '${overdueBills.length} conta(s)'));
  lines.add(AvailabilityLine(key: 'bills', label: 'Contas até ${horizon.substring(8, 10)}/${horizon.substring(5, 7)}', cents: upcomingCents, sign: -1, note: '${upcomingBills.length} conta(s)'));

  var cardsCents = 0;
  var cardNotes = 0;
  for (final card in ledger.cards.where((c) => c.isActive)) {
    final cm = cardCommitment(ledger, card, today);
    final due = cm.closedUnpaidCents + cm.currentInvoiceCents;
    cardsCents = addCents(cardsCents, due);
    if (due > 0) cardNotes++;
  }
  lines.add(AvailabilityLine(key: 'cards', label: 'Faturas de cartão', cents: cardsCents, sign: -1, note: cardNotes > 0 ? '$cardNotes cartão(ões)' : null));

  final reserved = sumCents(ledger.goals.where((g) => g.reserved && g.isActive && g.accountId != null && accounts.any((a) => a.id == g.accountId)).map((g) => goalSavedCents(ledger, g.id)));
  if (reserved != 0) lines.add(AvailabilityLine(key: 'reserved', label: 'Reservas guardadas', cents: reserved, sign: -1, note: 'dinheiro separado dentro das contas'));

  final cushion = safetyCushionCents ?? ledger.prefs.safetyCushionCents;
  if (cushion != 0) lines.add(AvailabilityLine(key: 'cushion', label: 'Colchão de segurança', cents: cushion, sign: -1));

  final includeIncome = includePlannedIncome ?? ledger.prefs.includePlannedIncomeInAvailability;
  if (includeIncome) {
    final incomes = ledger.transactions.where((t) => isActive(t) && isPlanned(t) && t.kind == TransactionKind.income && compareISO(t.effectiveDate, horizon) <= 0 && compareISO(t.effectiveDate, today) >= 0);
    lines.add(AvailabilityLine(key: 'planned_income', label: 'Receitas previstas', cents: sumCents(incomes.map(pendingCents)), sign: 1, note: 'ainda não recebidas'));
  }

  final available = lines.fold<int>(0, (acc, l) => acc + l.sign * l.cents);
  final tightThreshold = [5000, (balances * 0.1).round()].reduce((a, b) => a > b ? a : b);
  final status = available < 0 ? AvailabilityStatus.negative : available < tightThreshold ? AvailabilityStatus.tight : AvailabilityStatus.positive;
  return Availability(availableCents: available, horizonEnd: horizon, lines: lines, mode: includeIncome ? 'otimista' : 'prudente', hasAccounts: accounts.isNotEmpty, status: status);
}

({Cents remainingCents, bool fits}) simulatePurchase(Availability av, Cents amountCents) {
  final remaining = av.availableCents - amountCents;
  return (remainingCents: remaining, fits: remaining >= 0);
}
