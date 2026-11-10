/// Ocorrências 006 e 007 da homologação física: outros sistemas de empréstimo e a dívida sem prazo
/// nem parcelas, paga quando possível. Matemática em centavos, com as convenções escritas no
/// domínio (mês comercial de 30 dias, pro rata por dia; nada de multa sem estar no contrato).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/state/app_state.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/notifications/bill_reminders.dart';
import 'package:serenacash/data/security/secret_store.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ledger/ledger.dart';
import 'package:serenacash/domain/loans/loans.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/reports/reports.dart';

Loan _loan({
  String system = 'free',
  int principal = 4000000,
  double rate = 0,
  int term = 0,
  String interest = 'none',
  String origin = '2026-11-01',
  String direction = 'borrowed',
  int fee = 0,
}) => Loan(
  id: 'l1',
  name: 'casa',
  principalCents: principal,
  monthlyRatePercent: rate,
  termMonths: term,
  system: system,
  firstDueDate: origin,
  monthlyFeeCents: fee,
  upfrontFeesCents: 0,
  archived: false,
  direction: direction,
  interestMode: interest,
  createdAt: '2026-11-01T12:00:00.000Z',
  updatedAt: '2026-11-01T12:00:00.000Z',
);

Transaction _pay(String id, int cents, String date) => Transaction(
  id: id,
  kind: TransactionKind.loanPayment,
  amountCents: cents,
  currency: 'BRL',
  date: date,
  description: 'pagamento',
  accountId: 'a1',
  loanId: 'l1',
  status: TransactionStatus.settled,
  createdAt: '${date}T12:00:00.000Z',
  updatedAt: '${date}T12:00:00.000Z',
);

class _World {
  _World()
    : db = AppDatabase.inMemory(),
      clock = FixedClock('2026-11-07T15:00:00.000Z') {
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWith((ref) async => db),
        secretStoreProvider.overrideWithValue(InMemorySecretStore()),
        clockProvider.overrideWithValue(clock),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator('t')),
        billRemindersProvider.overrideWithValue(const NoopBillReminders()),
      ],
    );
  }
  final AppDatabase db;
  final FixedClock clock;
  late final ProviderContainer container;
  Future<void> boot() => container.read(appControllerProvider.future);
  AppController get ctl => container.read(appControllerProvider.notifier);
  Ledger get ledger => container.read(ledgerProvider);
  String get today => container.read(todayProvider);
  Future<void> dispose() async {
    container.dispose();
    await db.close();
  }

  Future<Transaction> pay(Loan loan, int cents, {String? date}) =>
      ctl.registerLoanPayment(
        loanId: loan.id,
        amountCents: cents,
        date: date ?? today,
        description: 'pagamento',
        tooMuchMessage: (owed) => 'maior que o saldo ($owed)',
        invalidAmountMessage: 'valor inválido',
      );
}

Future<void> _with(Future<void> Function(_World w) body) async {
  final w = _World();
  await w.boot();
  try {
    await body(w);
  } finally {
    await w.dispose();
  }
}

void main() {
  group('007: debt without schedule', () {
    test('acceptance: R\$ 40.000 without interest, R\$ 500 then R\$ 2.000', () {
      final loan = _loan();
      expect(buildSchedule(loan), isEmpty, reason: 'no invented due dates');
      var st = freeDebtStatement(loan, [
        _pay('p1', 50000, '2026-11-10'),
      ], '2026-11-10');
      expect(st.outstandingCents, 3950000);
      st = freeDebtStatement(loan, [
        _pay('p1', 50000, '2026-11-10'),
        _pay('p2', 200000, '2027-03-02'),
      ], '2027-12-31');
      expect(st.outstandingCents, 3750000);
      expect(
        st.accruedInterestCents,
        0,
        reason: 'time alone adds nothing without interest',
      );
      expect(st.events.map((e) => e.principalCents), [50000, 200000]);
      expect(st.events.map((e) => e.interestCents), [0, 0]);
      expect(st.events.map((e) => e.balanceAfterCents), [3950000, 3750000]);
      expect(st.paidCents, 250000);
    });

    test('payments in any order of entry give the same statement; a later one is ignored "as of" before it', () {
      final loan = _loan();
      final a = _pay('p1', 50000, '2026-11-10'),
          b = _pay('p2', 200000, '2027-03-02');
      expect(
        freeDebtStatement(loan, [b, a], '2027-12-31').outstandingCents,
        freeDebtStatement(loan, [a, b], '2027-12-31').outstandingCents,
      );
      expect(
        freeDebtStatement(loan, [a, b], '2026-12-31').outstandingCents,
        3950000,
      );
    });

    test('reversing a payment restores the balance exactly', () {
      final loan = _loan(rate: 1, interest: 'simple', principal: 1000000);
      final p1 = _pay('p1', 60000, '2026-12-01'),
          p2 = _pay('p2', 30000, '2027-01-15');
      final withBoth = freeDebtStatement(loan, [p1, p2], '2027-02-01');
      final withoutSecond = freeDebtStatement(loan, [p1], '2027-02-01');
      final again = freeDebtStatement(loan, [p1, p2], '2027-02-01');
      expect(withBoth.outstandingCents, again.outstandingCents);
      expect(
        withoutSecond.outstandingCents,
        greaterThan(withBoth.outstandingCents),
      );
      expect(withoutSecond.events.length, 1);
    });

    test('simple interest: 1% a month on the principal, pro rata by day, interest paid first', () {
      final loan = _loan(principal: 1000000, rate: 1, interest: 'simple');
      // 30 days: R$ 100,00 of interest
      expect(
        freeDebtStatement(loan, const [], '2026-12-01').accruedInterestCents,
        10000,
      );
      // 15 days: R$ 50,00
      expect(
        freeDebtStatement(loan, const [], '2026-11-16').accruedInterestCents,
        5000,
      );
      final st = freeDebtStatement(loan, [
        _pay('p1', 60000, '2026-12-01'),
      ], '2026-12-01');
      expect(st.events.single.interestCents, 10000);
      expect(st.events.single.principalCents, 50000);
      expect(st.principalOutstandingCents, 950000);
      expect(st.outstandingCents, 950000);
      // 60 more days on R$ 9.500,00: R$ 190,00
      final later = freeDebtStatement(loan, [
        _pay('p1', 60000, '2026-12-01'),
      ], '2027-01-30');
      expect(later.accruedInterestCents, 19000);
      expect(later.outstandingCents, 969000);
    });

    test('compound interest: unpaid interest is charged too', () {
      final loan = _loan(principal: 1000000, rate: 2, interest: 'compound');
      // two months of 30 days: 10.000 × 1,02² = 10.404,00
      final st = freeDebtStatement(loan, const [], '2026-12-31');
      expect(st.outstandingCents, 1040400);
      // paying exactly the interest leaves the principal whole
      final paid = freeDebtStatement(loan, [
        _pay('p1', 40400, '2026-12-31'),
      ], '2026-12-31');
      expect(paid.events.single.interestCents, 40400);
      expect(paid.events.single.principalCents, 0);
      expect(paid.outstandingCents, 1000000);
      // a payment smaller than the interest reduces only interest; the principal is untouched
      final small = freeDebtStatement(loan, [
        _pay('p1', 10000, '2026-12-31'),
      ], '2026-12-31');
      expect(small.principalOutstandingCents, 1000000);
      expect(small.accruedInterestCents, 30400);
    });

    test(
      'the stated mode is what counts: zero rate or "none" never accrues',
      () {
        expect(
          freeDebtStatement(
            _loan(rate: 0, interest: 'compound'),
            const [],
            '2030-01-01',
          ).accruedInterestCents,
          0,
        );
        expect(
          freeDebtStatement(
            _loan(rate: 3, interest: 'none'),
            const [],
            '2030-01-01',
          ).accruedInterestCents,
          0,
        );
      },
    );

    test(
      'the balance never goes below zero, and what exceeds it stays visible',
      () {
        final loan = _loan(principal: 100000);
        final st = freeDebtStatement(loan, [
          _pay('p1', 150000, '2026-11-10'),
        ], '2026-11-10');
        expect(st.outstandingCents, 0);
        expect(st.settled, isTrue);
        expect(st.events.single.principalCents, 100000);
        expect(st.events.single.excessCents, 50000);
        // a settled debt stops accruing
        final interest = _loan(
          principal: 100000,
          rate: 5,
          interest: 'compound',
        );
        expect(
          freeDebtStatement(interest, [
            _pay('p1', 100000, '2026-11-01'),
          ], '2030-01-01').outstandingCents,
          0,
        );
      },
    );

    test('late payment adds no fine: only what the debt states', () {
      final loan = _loan(principal: 100000);
      final st = freeDebtStatement(loan, [
        _pay('p1', 10000, '2029-05-05'),
      ], '2029-05-05');
      expect(st.outstandingCents, 90000);
    });
  });

  group('006: other systems and the stated rate', () {
    test('rate per year: nominal is divided by 12, effective is converted by compounding', () {
      expect(monthlyRateFrom(1.99, period: 'month', kind: 'effective'), 1.99);
      expect(monthlyRateFrom(12, period: 'year', kind: 'nominal'), 1);
      final eff = monthlyRateFrom(12.682503, period: 'year', kind: 'effective');
      expect(eff, closeTo(1, 0.00001));
      // the two are not the same thing: 12% a year effective is less than 1% a month
      expect(
        monthlyRateFrom(12, period: 'year', kind: 'effective'),
        lessThan(1),
      );
    });

    test(
      'american: interest every period, principal with the last installment',
      () {
        final rows = buildSchedule(
          _loan(
            system: 'american',
            principal: 1000000,
            rate: 1,
            term: 3,
            origin: '2026-12-10',
          ),
        );
        expect(rows.map((r) => r.installmentCents), [10000, 10000, 1010000]);
        expect(rows.map((r) => r.amortizationCents), [0, 0, 1000000]);
        expect(rows.map((r) => r.balanceAfterCents), [1000000, 1000000, 0]);
        expect(rows.map((r) => r.dueDate), [
          '2026-12-10',
          '2027-01-10',
          '2027-02-10',
        ]);
        expect(totalInterest(rows), 30000);
        expect(sumAmortization(rows), 1000000);
      },
    );

    test('bullet: one payment at the end with compounded interest', () {
      final rows = buildSchedule(
        _loan(
          system: 'bullet',
          principal: 1000000,
          rate: 2,
          term: 2,
          origin: '2026-12-10',
        ),
      );
      expect(rows.length, 1);
      expect(rows.single.installmentCents, 1040400);
      expect(rows.single.interestCents, 40400);
      expect(rows.single.amortizationCents, 1000000);
      expect(rows.single.dueDate, '2027-01-10');
      expect(rows.single.balanceAfterCents, 0);
    });

    test('price and SAC still close to the cent', () {
      for (final system in ['price', 'sac']) {
        final rows = buildSchedule(
          _loan(
            system: system,
            principal: 4000000,
            rate: 1.99,
            term: 48,
            origin: '2027-08-20',
          ),
        );
        expect(rows.length, 48);
        expect(sumAmortization(rows), 4000000, reason: system);
        expect(rows.last.balanceAfterCents, 0);
      }
    });

    test('a system that needs a term has no schedule without one', () {
      expect(buildSchedule(_loan(system: 'american', term: 0)), isEmpty);
    });
  });

  group('through the controller', () {
    test('007: free debt creates no planned bills, and payments move the account once', () {
      return _with((w) async {
        final acc = await w.ctl.saveAccount(
          name: 'c6',
          type: 'checking',
          openingBalanceCents: 500000,
          openingDate: '2026-11-01',
        );
        final loan = await w.ctl.saveLoan(
          name: 'casa',
          principalCents: 4000000,
          monthlyRatePercent: 0,
          termMonths: 0,
          firstDueDate: '2026-11-01',
          system: 'free',
          accountId: acc.id,
          createInstallments: true,
          disbursementLabel: 'Entrada',
        );
        expect(w.ledger.transactions, isEmpty);
        await w.pay(loan, 50000);
        expect(loanPosition(w.ledger, loan, w.today).outstandingCents, 3950000);
        await w.pay(loan, 200000);
        expect(loanPosition(w.ledger, loan, w.today).outstandingCents, 3750000);
        expect(accountBalance(w.ledger, acc.id), 250000);
        expect(w.ledger.transactions.length, 2);
        // a loan payment is not an expense of the month: it moves money, it is not spending
        expect(monthTotals(w.ledger, '2026-11').expenseSettled, 0);

        // more than what is owed is refused, with the amount that settles the debt
        await expectLater(
          w.pay(loan, 3750001),
          throwsA(
            isA<AppError>().having(
              (e) => e.message,
              'message',
              contains('37.500,00'),
            ),
          ),
        );
        await expectLater(w.pay(loan, 0), throwsA(isA<AppError>()));
        expect(w.ledger.transactions.length, 2);

        // undoing a payment gives the balance back, on the debt and on the account
        final last = w.ledger.transactions.last;
        await w.ctl.deleteTransaction(last.id, undoLabel: (_) => 'x');
        expect(loanPosition(w.ledger, loan, w.today).outstandingCents, 3950000);
        expect(accountBalance(w.ledger, acc.id), 450000);

        // settling: the exact balance is accepted and nothing is left
        await w.pay(loan, 3950000);
        expect(loanPosition(w.ledger, loan, w.today).outstandingCents, 0);
      });
    });

    test(
      '006: money the user lent goes out, comes back in and counts as an asset',
      () {
        return _with((w) async {
          final acc = await w.ctl.saveAccount(
            name: 'c6',
            type: 'checking',
            openingBalanceCents: 500000,
            openingDate: '2026-11-01',
          );
          final loan = await w.ctl.saveLoan(
            name: 'empréstimo ao irmão',
            principalCents: 100000,
            monthlyRatePercent: 0,
            termMonths: 0,
            firstDueDate: w.today,
            system: 'free',
            direction: 'lent',
            accountId: acc.id,
            registerDisbursement: true,
            disbursementLabel: 'Saída',
          );
          expect(
            accountBalance(w.ledger, acc.id),
            400000,
            reason: 'o dinheiro saiu',
          );
          await w.pay(loan, 30000);
          expect(
            accountBalance(w.ledger, acc.id),
            430000,
            reason: 'parte voltou',
          );
          expect(loanPosition(w.ledger, loan, w.today).outstandingCents, 70000);
          final nw = netWorth(w.ledger, '2026-11', 1, w.today).last;
          expect(nw.debtsCents, 0, reason: 'não é dívida do usuário');
          expect(nw.assetsCents, 430000 + 70000);
        });
      },
    );

    test('006: an american loan creates its installments as planned bills', () {
      return _with((w) async {
        final loan = await w.ctl.saveLoan(
          name: 'capital de giro',
          principalCents: 1000000,
          monthlyRatePercent: 1,
          termMonths: 3,
          firstDueDate: '2026-12-10',
          system: 'american',
          createInstallments: true,
          disbursementLabel: 'Entrada',
        );
        final planned = w.ledger.transactions
            .where((t) => t.loanId == loan.id)
            .toList();
        expect(planned.map((t) => t.amountCents), [10000, 10000, 1010000]);
        expect(
          planned.every((t) => t.status == TransactionStatus.planned),
          isTrue,
        );
        expect(planned.map((t) => t.description), [
          'capital de giro 1/3',
          'capital de giro 2/3',
          'capital de giro 3/3',
        ]);
      });
    });
  });
}
