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

/// The effective monthly rate (in percent) for a rate stated per month or per year. A nominal
/// yearly rate is divided by 12; an effective yearly rate is the monthly rate that compounds to it.
double monthlyRateFrom(
  double percent, {
  required String period,
  required String kind,
}) {
  if (period != 'year') return percent;
  if (kind == 'nominal') return percent / 12;
  return (math.pow(1 + percent / 100, 1 / 12) - 1) * 100;
}

/// The kind of entry that pays a loan down. For money the user lent, being paid back is money
/// coming in; for money the user borrowed, paying is money going out.
TransactionKind repaymentKind(Loan loan) => loan.direction == 'lent'
    ? TransactionKind.loanDisbursement
    : TransactionKind.loanPayment;

/// The kind of entry for the moment the principal changes hands.
TransactionKind handoverKind(Loan loan) => loan.direction == 'lent'
    ? TransactionKind.loanPayment
    : TransactionKind.loanDisbursement;

/// The installments of a loan with a schedule. A `free` debt has none: nothing here invents due
/// dates for a debt that has no term.
List<ScheduleRow> buildSchedule(Loan loan) {
  if (loan.system == 'free') return const [];
  final principal = loan.principalCents + loan.upfrontFeesCents;
  final n = loan.termMonths;
  final i = loan.monthlyRatePercent / 100;
  final rows = <ScheduleRow>[];
  var balance = principal;
  final anchor = parts(loan.firstDueDate).day;
  if (n < 1) return const [];
  if (loan.system == 'bullet') {
    // One payment at the end of the term: the principal plus interest compounded month by month.
    final interest = mulCents(
      principal,
      math.pow(1 + i, n).toDouble() - 1,
      RoundingMode.halfUp,
    );
    final fees = loan.monthlyFeeCents * n;
    return [
      ScheduleRow(
        number: 1,
        dueDate: addMonthsClamped(loan.firstDueDate, n - 1, anchor),
        installmentCents: addCents(principal, interest) + fees,
        interestCents: interest,
        amortizationCents: principal,
        feeCents: fees,
        balanceAfterCents: 0,
      ),
    ];
  }
  if (loan.system == 'american') {
    // Interest on the whole principal each period; the principal itself with the last one.
    final interest = mulCents(principal, i, RoundingMode.halfUp);
    return [
      for (var k = 1; k <= n; k++)
        ScheduleRow(
          number: k,
          dueDate: addMonthsClamped(loan.firstDueDate, k - 1, anchor),
          installmentCents:
              interest + (k == n ? principal : 0) + loan.monthlyFeeCents,
          interestCents: interest,
          amortizationCents: k == n ? principal : 0,
          feeCents: loan.monthlyFeeCents,
          balanceAfterCents: k == n ? 0 : principal,
        ),
    ];
  }
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

/// One payment of a debt without a schedule, with what it covered.
class DebtEvent {
  const DebtEvent({
    required this.transactionId,
    required this.date,
    required this.paidCents,
    required this.interestCents,
    required this.principalCents,
    required this.excessCents,
    required this.balanceAfterCents,
  });
  final Id transactionId;
  final ISODate date;
  final Cents paidCents;

  /// Part of the payment that covered interest accrued until its date.
  final Cents interestCents;

  /// Part that reduced the principal.
  final Cents principalCents;

  /// Part beyond everything owed on that date (should be zero; kept visible when it is not).
  final Cents excessCents;
  final Cents balanceAfterCents;
}

class FreeDebtStatement {
  const FreeDebtStatement({
    required this.events,
    required this.principalOutstandingCents,
    required this.accruedInterestCents,
    required this.paidCents,
    required this.interestPaidCents,
  });
  final List<DebtEvent> events;
  final Cents principalOutstandingCents;

  /// Interest accrued and not yet paid, as of the date the statement was asked for.
  final Cents accruedInterestCents;
  final Cents paidCents;
  final Cents interestPaidCents;
  Cents get outstandingCents =>
      addCents(principalOutstandingCents, accruedInterestCents);
  bool get settled => outstandingCents == 0;
}

/// Statement of a debt paid when possible: no due dates, payments of any amount on any date.
///
/// Interest only exists when the debt says so ([Loan.interestMode]) and follows one stated
/// convention: a commercial month of 30 days, pro rata by day, from the date of origin
/// ([Loan.firstDueDate]). `simple` charges the outstanding principal; `compound` charges the whole
/// balance, unpaid interest included. A payment covers accrued interest first and the principal
/// with what is left. No fine or late fee is ever added: nothing in the debt states one.
FreeDebtStatement freeDebtStatement(
  Loan loan,
  Iterable<Transaction> repayments,
  ISODate today,
) {
  final i = loan.monthlyRatePercent / 100;
  final mode = i == 0 ? 'none' : loan.interestMode;
  var principal = loan.principalCents + loan.upfrontFeesCents;
  var accrued = 0;
  var last = loan.firstDueDate;
  var paid = 0, interestPaid = 0;

  void accrueUntil(ISODate date) {
    final days = diffDays(last, date);
    if (days <= 0) return;
    last = date;
    if (mode == 'simple') {
      accrued = addCents(
        accrued,
        mulCents(principal, i * days / 30, RoundingMode.halfUp),
      );
    } else if (mode == 'compound') {
      accrued = addCents(
        accrued,
        mulCents(
          principal + accrued,
          math.pow(1 + i, days / 30).toDouble() - 1,
          RoundingMode.halfUp,
        ),
      );
    }
  }

  // Only what happened up to the date asked for: a statement "as of" a day ignores later payments.
  final sorted =
      repayments
          .where(
            (t) =>
                effectiveCents(t) > 0 &&
                compareISO(t.settledDate ?? t.date, today) <= 0,
          )
          .toList()
        ..sort((a, b) {
          final d = compareISO(
            a.settledDate ?? a.date,
            b.settledDate ?? b.date,
          );
          return d != 0 ? d : a.createdAt.compareTo(b.createdAt);
        });
  final events = <DebtEvent>[];
  for (final t in sorted) {
    accrueUntil(t.settledDate ?? t.date);
    final amount = effectiveCents(t);
    final toInterest = math.min(amount, accrued);
    final toPrincipal = math.min(amount - toInterest, principal);
    accrued -= toInterest;
    principal -= toPrincipal;
    paid = addCents(paid, amount);
    interestPaid = addCents(interestPaid, toInterest);
    events.add(
      DebtEvent(
        transactionId: t.id,
        date: t.settledDate ?? t.date,
        paidCents: amount,
        interestCents: toInterest,
        principalCents: toPrincipal,
        excessCents: amount - toInterest - toPrincipal,
        balanceAfterCents: principal + accrued,
      ),
    );
  }
  // A debt that is fully paid stops accruing.
  if (principal + accrued > 0) accrueUntil(today);
  return FreeDebtStatement(
    events: events,
    principalOutstandingCents: principal,
    accruedInterestCents: accrued,
    paidCents: paid,
    interestPaidCents: interestPaid,
  );
}

/// The entries that pay a loan down, whichever way the money flows.
Iterable<Transaction> loanRepayments(Ledger ledger, Loan loan) {
  final kind = repaymentKind(loan);
  return ledger.transactions.where(
    (t) => isActive(t) && t.kind == kind && t.loanId == loan.id,
  );
}

LoanPosition loanPosition(Ledger ledger, Loan loan, ISODate today) {
  final schedule = buildSchedule(loan);
  final payments = loanRepayments(ledger, loan);
  final paidCents = sumCents(payments.map(effectiveCents));
  if (loan.system == 'free') {
    final st = freeDebtStatement(loan, payments, today);
    return LoanPosition(
      loan: loan,
      schedule: const [],
      paidInstallments: 0,
      paidCents: st.paidCents,
      extraAmortizationCents: 0,
      outstandingCents: st.outstandingCents,
      overdueInstallments: const [],
      payoffTodayCents: st.outstandingCents,
    );
  }
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

/// Sum of what the installments pay off of the principal: it has to equal the amount financed.
Cents sumAmortization(List<ScheduleRow> s) =>
    sumCents(s.map((r) => r.amortizationCents));
