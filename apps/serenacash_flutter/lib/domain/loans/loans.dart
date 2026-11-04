/// Loan math (Price / SAC, fees, position, payoff, extra payment). Mirrors `loans.ts`; assumptions in docs/07.
library;

import 'dart:math' as math;

import '../dates/dates.dart';
import '../entities/entities.dart';
import '../ledger/ledger.dart';
import '../money/money.dart';

class ScheduleRow {
  const ScheduleRow({
    required this.number,
    required this.dueDate,
    required this.installmentCents,
    required this.interestCents,
    required this.amortizationCents,
    required this.feeCents,
    required this.balanceAfterCents,
  });
  final int number;
  final ISODate dueDate;
  final Cents installmentCents;
  final Cents interestCents;
  final Cents amortizationCents;
  final Cents feeCents;
  final Cents balanceAfterCents;
  Map<String, dynamic> toJson() => {
    'number': number,
    'dueDate': dueDate,
    'installmentCents': installmentCents,
    'interestCents': interestCents,
    'amortizationCents': amortizationCents,
    'feeCents': feeCents,
    'balanceAfterCents': balanceAfterCents,
  };
}

int _jsRound(double v) => (v + 0.5).floorToDouble().toInt();

Cents priceInstallment(Cents principalCents, double monthlyRatePercent, int n) {
  if (n < 1) throw MoneyError('Prazo inválido');
  final i = monthlyRatePercent / 100;
  if (i == 0) return _jsRound(principalCents / n);
  final factor = i / (1 - math.pow(1 + i, -n));
  return mulCents(principalCents, factor, RoundingMode.halfUp);
}

List<ScheduleRow> buildSchedule(Loan loan) {
  final principal = loan.principalCents + loan.upfrontFeesCents;
  final n = loan.termMonths;
  final i = loan.monthlyRatePercent / 100;
  final rows = <ScheduleRow>[];
  var balance = principal;
  final anchor = parts(loan.firstDueDate).day;
  final pmt = loan.system == 'price'
      ? priceInstallment(principal, loan.monthlyRatePercent, n)
      : 0;
  final sacAmorts = loan.system == 'sac'
      ? allocate(principal, n)
      : const <int>[];
  for (var k = 1; k <= n; k++) {
    final interest = mulCents(balance, i, RoundingMode.halfUp);
    int amort;
    if (loan.system == 'price') {
      amort = k == n ? balance : math.min(balance, pmt - interest);
    } else {
      amort = sacAmorts[k - 1];
    }
    if (k == n) amort = balance;
    final installment = addCents(amort, interest) + loan.monthlyFeeCents;
    balance = balance - amort;
    rows.add(
      ScheduleRow(
        number: k,
        dueDate: addMonthsClamped(loan.firstDueDate, k - 1, anchor),
        installmentCents: installment,
        interestCents: interest,
        amortizationCents: amort,
        feeCents: loan.monthlyFeeCents,
        balanceAfterCents: balance,
      ),
    );
  }
  return rows;
}

Cents totalInterest(List<ScheduleRow> s) =>
    sumCents(s.map((r) => r.interestCents));
Cents totalCost(List<ScheduleRow> s) =>
    sumCents(s.map((r) => r.installmentCents));

int _monthsBetween(ISODate from, ISODate to) {
  final a = parts(from), b = parts(to);
  final m = (b.year - a.year) * 12 + (b.month - a.month);
  return b.day < a.day ? m - 1 : m;
}

/// Present value of the remaining installments at the contractual monthly rate (fees not discounted).
Cents payoffValue(
  List<ScheduleRow> remaining,
  double monthlyRatePercent,
  ISODate today,
) {
  final i = monthlyRatePercent / 100;
  var total = 0;
  for (final row in remaining) {
    final monthsAhead = math.max(0, _monthsBetween(today, row.dueDate));
    final base = row.amortizationCents + row.interestCents;
    final pv = i == 0
        ? base
        : mulCents(
            base,
            math.pow(1 + i, -monthsAhead).toDouble(),
            RoundingMode.halfUp,
          );
    total = addCents(total, pv);
  }
  return total;
}

class LoanPosition {
  const LoanPosition({
    required this.loan,
    required this.schedule,
    required this.paidInstallments,
    required this.paidCents,
    required this.extraAmortizationCents,
    required this.outstandingCents,
    this.nextDue,
    required this.overdueInstallments,
    required this.payoffTodayCents,
  });
  final Loan loan;
  final List<ScheduleRow> schedule;
  final int paidInstallments;
  final Cents paidCents;
  final Cents extraAmortizationCents;
  final Cents outstandingCents;
  final ScheduleRow? nextDue;
  final List<ScheduleRow> overdueInstallments;
  final Cents payoffTodayCents;
}

LoanPosition loanPosition(Ledger ledger, Loan loan, ISODate today) {
  final schedule = buildSchedule(loan);
  final payments = ledger.transactions.where(
    (t) =>
        isActive(t) &&
        t.kind == TransactionKind.loanPayment &&
        t.loanId == loan.id,
  );
  final paidCents = sumCents(payments.map(effectiveCents));
  var remainingPaid = paidCents;
  var paid = 0;
  for (final row in schedule) {
    if (remainingPaid >= row.installmentCents) {
      remainingPaid -= row.installmentCents;
      paid++;
    } else {
      break;
    }
  }
  final extra = remainingPaid;
  final remaining = schedule.sublist(paid);
  final base = paid > 0
      ? schedule[paid - 1].balanceAfterCents
      : loan.principalCents + loan.upfrontFeesCents;
  final outstanding = (base - extra).clamp(0, maxSafeCents);
  final overdueRows = remaining
      .where((r) => compareISO(r.dueDate, today) < 0)
      .toList();
  return LoanPosition(
    loan: loan,
    schedule: schedule,
    paidInstallments: paid,
    paidCents: paidCents,
    extraAmortizationCents: extra,
    outstandingCents: outstanding,
    nextDue: remaining.firstOrNull,
    overdueInstallments: overdueRows,
    payoffTodayCents:
        (payoffValue(remaining, loan.monthlyRatePercent, today) - extra).clamp(
          0,
          maxSafeCents,
        ),
  );
}

class ExtraPaymentResult {
  const ExtraPaymentResult({
    required this.newBalanceCents,
    required this.newTermMonths,
    required this.newInstallmentCents,
  });
  final Cents newBalanceCents;
  final int newTermMonths;
  final Cents newInstallmentCents;
  Map<String, dynamic> toJson() => {
    'newBalanceCents': newBalanceCents,
    'newTermMonths': newTermMonths,
    'newInstallmentCents': newInstallmentCents,
  };
}

/// `reduce_term` keeps the installment and shortens the term; `reduce_installment` keeps the term.
ExtraPaymentResult simulateExtraPayment(
  Loan loan,
  Cents outstandingCents,
  Cents extraCents,
  int remainingMonths,
  String mode,
) {
  final newBalance = (outstandingCents - extraCents).clamp(0, maxSafeCents);
  if (newBalance == 0) {
    return const ExtraPaymentResult(
      newBalanceCents: 0,
      newTermMonths: 0,
      newInstallmentCents: 0,
    );
  }
  if (mode == 'reduce_installment') {
    return ExtraPaymentResult(
      newBalanceCents: newBalance,
      newTermMonths: remainingMonths,
      newInstallmentCents:
          priceInstallment(
            newBalance,
            loan.monthlyRatePercent,
            remainingMonths,
          ) +
          loan.monthlyFeeCents,
    );
  }
  final pmt = priceInstallment(
    outstandingCents,
    loan.monthlyRatePercent,
    remainingMonths,
  );
  final i = loan.monthlyRatePercent / 100;
  final months = i == 0
      ? (newBalance / pmt).ceil()
      : (-math.log(1 - (newBalance * i) / pmt) / math.log(1 + i)).ceil();
  return ExtraPaymentResult(
    newBalanceCents: newBalance,
    newTermMonths: math.max(1, months),
    newInstallmentCents: pmt + loan.monthlyFeeCents,
  );
}
