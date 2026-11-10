/// Ocorrências 029, 030 e 031: gastos e receitas por dia, saldo acumulado e metas diárias.
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/state/app_state.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/notifications/bill_reminders.dart';
import 'package:serenacash/data/security/secret_store.dart';
import 'package:serenacash/domain/daily/daily.dart';
import 'package:serenacash/domain/dates/dates.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ledger/ledger.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/features/home/analytic_widgets.dart';

class _World {
  _World(String now) : db = AppDatabase.inMemory(), clock = FixedClock(now) {
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
  late Account account;
  late CreditCard card;
  Future<void> boot() async {
    await container.read(appControllerProvider.future);
    account = await ctl.saveAccount(
      name: 'c6',
      type: 'checking',
      openingBalanceCents: 100000,
      openingDate: '2026-10-01',
    );
    card = await ctl.saveCard(
      name: 'carol',
      limitCents: 300000,
      closingDay: 20,
      dueDay: 27,
    );
  }

  AppController get ctl => container.read(appControllerProvider.notifier);
  Ledger get ledger => container.read(ledgerProvider);
  String get today => container.read(todayProvider);
  Future<void> goTo(String now) async {
    clock.value = now;
    await ctl.reload();
  }

  Future<void> add(
    TransactionKind kind,
    int cents,
    String date, {
    TransactionStatus status = TransactionStatus.settled,
    String? goalId,
    String? toAccount,
  }) => ctl.saveTransaction(
    TransactionInput(
      kind: kind,
      amountCents: cents,
      date: date,
      description: 'x',
      accountId: kind == TransactionKind.cardPurchase ? null : account.id,
      cardId: kind == TransactionKind.cardPurchase ? card.id : null,
      toAccountId: toAccount,
      goalId: goalId,
      status: status,
      dueDate: status == TransactionStatus.planned ? date : null,
    ),
  );

  Future<void> dispose() async {
    container.dispose();
    await db.close();
  }
}

Future<void> _with(String now, Future<void> Function(_World w) body) async {
  final w = _World(now);
  await w.boot();
  try {
    await body(w);
  } finally {
    await w.dispose();
  }
}

void main() {
  test('029/030: the days of a month add up to the month, to the cent', () {
    return _with('2026-11-20T15:00:00.000Z', (w) async {
      final rng = Random(29);
      for (var i = 0; i < 60; i++) {
        final day = (1 + rng.nextInt(30)).toString().padLeft(2, '0');
        final kind = [
          TransactionKind.expense,
          TransactionKind.income,
          TransactionKind.cardPurchase,
        ][rng.nextInt(3)];
        final planned =
            kind != TransactionKind.cardPurchase && rng.nextInt(4) == 0;
        await w.add(
          kind,
          1 + rng.nextInt(99999),
          '2026-11-$day',
          status: planned
              ? TransactionStatus.planned
              : TransactionStatus.settled,
        );
      }
      final flow = dailyFlow(w.ledger, '2026-11', w.today);
      final totals = monthTotals(w.ledger, '2026-11');
      expect(flow.length, 30);
      expect(flow.fold(0, (a, d) => a + d.incomeCents), totals.incomeSettled);
      expect(flow.fold(0, (a, d) => a + d.expenseCents), totals.expenseSettled);
      expect(
        flow.fold(0, (a, d) => a + d.plannedIncomeCents),
        totals.incomePlanned,
      );
      expect(
        flow.fold(0, (a, d) => a + d.plannedExpenseCents),
        totals.expensePlanned,
      );
    });
  });

  test('030: the balance starts from the real opening balance and is a fact only up to today', () {
    return _with('2026-11-10T15:00:00.000Z', (w) async {
      await w.add(TransactionKind.income, 6500, '2026-11-07');
      await w.add(TransactionKind.expense, 4500, '2026-11-07');
      await w.add(TransactionKind.expense, 1000, '2026-11-09');
      await w.add(
        TransactionKind.expense,
        20000,
        '2026-11-15',
        status: TransactionStatus.planned,
      );
      await w.add(
        TransactionKind.income,
        50000,
        '2026-11-20',
        status: TransactionStatus.planned,
      );
      final flow = dailyFlow(w.ledger, '2026-11', w.today);
      expect(openingBalance(w.ledger, '2026-11'), 100000);
      DayFlow on(String d) => flow.firstWhere((x) => x.date == d);
      expect(on('2026-11-06').balanceCents, 100000);
      expect(on('2026-11-07').balanceCents, 102000);
      expect(on('2026-11-07').resultCents, 2000);
      expect(on('2026-11-09').balanceCents, 101000);
      expect(on('2026-11-10').balanceCents, 101000);
      // after today nothing is stated as fact: only the projection of what is recorded
      expect(on('2026-11-11').balanceCents, isNull);
      expect(on('2026-11-14').projectedBalanceCents, 101000);
      expect(on('2026-11-15').projectedBalanceCents, 81000);
      expect(on('2026-11-20').projectedBalanceCents, 131000);
      expect(on('2026-11-30').projectedBalanceCents, 131000);
      expect(on('2026-11-10').projectedBalanceCents, isNull);
    });
  });

  test('029: card purchases count on the day of the purchase; paying the invoice is not spending again', () {
    return _with('2026-11-10T15:00:00.000Z', (w) async {
      await w.add(TransactionKind.cardPurchase, 3000, '2026-11-08');
      final before = accountBalance(w.ledger, w.account.id);
      expect(spentOn(w.ledger, '2026-11-08'), 3000);
      expect(
        accountBalance(w.ledger, w.account.id),
        before,
        reason: 'a conta não baixa na compra',
      );
      // a transfer and a goal deposit move money and are not spending either
      final other = await w.ctl.saveAccount(
        name: 'poupança',
        type: 'savings',
        openingBalanceCents: 0,
      );
      await w.add(
        TransactionKind.transfer,
        5000,
        '2026-11-08',
        toAccount: other.id,
      );
      final goal = await w.ctl.saveGoal(name: 'reserva', targetCents: 100000);
      await w.add(
        TransactionKind.goalDeposit,
        2000,
        '2026-11-08',
        goalId: goal.id,
      );
      expect(spentOn(w.ledger, '2026-11-08'), 3000);
      final s = dailySummary(w.ledger, '2026-11-08');
      expect(s.spentTodayCents, 3000);
      expect(s.receivedTodayCents, 0);
    });
  });

  test(
    '029: today, yesterday and the two averages, each named for what it is',
    () {
      return _with('2026-11-10T15:00:00.000Z', (w) async {
        await w.add(TransactionKind.expense, 3500, '2026-11-10');
        await w.add(TransactionKind.expense, 2500, '2026-11-09');
        await w.add(TransactionKind.expense, 4000, '2026-11-02');
        await w.add(TransactionKind.income, 9000, '2026-11-10');
        final s = dailySummary(w.ledger, w.today);
        expect(s.spentTodayCents, 3500);
        expect(s.spentYesterdayCents, 2500);
        expect(s.receivedTodayCents, 9000);
        expect(s.resultTodayCents, 5500);
        expect(s.spentMonthCents, 10000);
        expect(s.daysElapsed, 10);
        expect(s.daysWithSpending, 3);
        expect(s.averagePerCalendarDayCents, 1000);
        expect(s.averagePerSpendingDayCents, 3333);
        // no entry at all last month: no comparison is offered, instead of comparing with zero
        expect(s.previousMonthSameDaysCents, isNull);
        await w.add(TransactionKind.expense, 700, '2026-10-05');
        await w.add(TransactionKind.expense, 900, '2026-10-25');
        expect(dailySummary(w.ledger, w.today).previousMonthSameDaysCents, 700);
      });
    },
  );

  test('029: on the first day of a month, yesterday is the last day of the previous one', () {
    return _with('2026-12-01T15:00:00.000Z', (w) async {
      await w.add(TransactionKind.expense, 1234, '2026-11-30');
      final s = dailySummary(w.ledger, w.today);
      expect(s.spentYesterdayCents, 1234);
      expect(s.daysElapsed, 1);
      expect(s.spentMonthCents, 0);
    });
  });

  test('031: the example of the briefing, limit 100, spent 35, saving 20, set aside 15', () {
    return _with('2026-11-10T15:00:00.000Z', (w) async {
      await w.ctl.setDailyTarget(
        kind: DailyTarget.spendLimit,
        amountCents: 10000,
      );
      await w.ctl.setDailyTarget(kind: DailyTarget.saving, amountCents: 2000);
      final goal = await w.ctl.saveGoal(name: 'reserva', targetCents: 100000);
      await w.add(TransactionKind.expense, 3500, '2026-11-10');
      await w.add(
        TransactionKind.goalDeposit,
        1500,
        '2026-11-10',
        goalId: goal.id,
      );
      final limit = spendLimitHistory(
        w.ledger,
        w.ctl.dailyTargets,
        w.today,
      ).single;
      expect(limit.limitCents, 10000);
      expect(limit.spentCents, 3500);
      expect(limit.remainingCents, 6500);
      expect(limit.within, isTrue);
      final saving = savingHistory(
        w.ledger,
        w.ctl.dailyTargets,
        w.today,
      ).single;
      expect(saving.targetCents, 2000);
      expect(saving.confirmedCents, 1500);
      expect(saving.pendingCents, 500);
      expect(saving.met, isFalse);
    });
  });

  test('031: spending less than the limit is never counted as money saved', () {
    return _with('2026-11-10T15:00:00.000Z', (w) async {
      await w.ctl.setDailyTarget(
        kind: DailyTarget.spendLimit,
        amountCents: 10000,
      );
      await w.ctl.setDailyTarget(kind: DailyTarget.saving, amountCents: 2000);
      await w.add(TransactionKind.expense, 100, '2026-11-10');
      final saving = savingHistory(
        w.ledger,
        w.ctl.dailyTargets,
        w.today,
      ).single;
      expect(saving.confirmedCents, 0);
      expect(saving.pendingCents, 2000);
    });
  });

  test('031: a new limit starts today; the days already lived keep the limit they had', () {
    return _with('2026-11-10T15:00:00.000Z', (w) async {
      await w.ctl.setDailyTarget(
        kind: DailyTarget.spendLimit,
        amountCents: 10000,
      );
      await w.add(TransactionKind.expense, 12000, '2026-11-10');
      await w.goTo('2026-11-12T15:00:00.000Z');
      await w.add(TransactionKind.expense, 12000, '2026-11-12');
      await w.ctl.setDailyTarget(
        kind: DailyTarget.spendLimit,
        amountCents: 15000,
      );
      final days = spendLimitHistory(w.ledger, w.ctl.dailyTargets, w.today);
      expect(days.map((d) => d.date), [
        '2026-11-10',
        '2026-11-11',
        '2026-11-12',
      ]);
      expect(days.map((d) => d.limitCents), [10000, 10000, 15000]);
      expect(days.map((d) => d.within), [false, true, true]);
      // before the first limit existed there is no day to judge
      expect(days.any((d) => d.date.compareTo('2026-11-10') < 0), isFalse);
      // changing it twice on the same day leaves one period for that day, not two
      await w.ctl.setDailyTarget(
        kind: DailyTarget.spendLimit,
        amountCents: 9000,
      );
      final again = spendLimitHistory(w.ledger, w.ctl.dailyTargets, w.today);
      expect(again.map((d) => d.limitCents), [10000, 10000, 9000]);
      expect(
        w.ctl.dailyTargets
            .where((t) => t.kind == DailyTarget.spendLimit)
            .length,
        2,
      );
    });
  });

  test(
    '031: carry-over is off unless asked for, and stays inside the month',
    () {
      return _with('2026-11-03T15:00:00.000Z', (w) async {
        await w.ctl.setDailyTarget(
          kind: DailyTarget.spendLimit,
          amountCents: 10000,
        );
        await w.goTo('2026-11-04T15:00:00.000Z');
        final plain = spendLimitHistory(w.ledger, w.ctl.dailyTargets, w.today);
        expect(plain.last.carriedCents, 0);
        expect(plain.last.availableCents, 10000);

        final t = w.ctl.dailyTargets.single;
        final carrying = [
          DailyTarget(
            id: t.id,
            kind: t.kind,
            amountCents: t.amountCents,
            validFrom: '2026-10-30',
            carryOver: true,
          ),
        ];
        await w.add(TransactionKind.expense, 4000, '2026-11-01');
        await w.add(TransactionKind.expense, 13000, '2026-11-02');
        final days = spendLimitHistory(w.ledger, carrying, w.today);
        // day 1: 100 − 40 = 60 left; day 2: 100 + 60 − 130 = 30 left; day 3: 130; day 4: 230
        expect(days.map((d) => d.remainingCents), [6000, 3000, 13000, 23000]);
        // October's leftover does not cross into November
        expect(days.first.carriedCents, 0);
      });
    },
  );

  test('031: weekdays, ending a target and the persistence of both', () {
    return _with('2026-11-09T15:00:00.000Z', (w) async {
      // 2026-11-09 is a Monday
      await w.ctl.setDailyTarget(
        kind: DailyTarget.spendLimit,
        amountCents: 5000,
        weekdays: const [6, 7],
      );
      expect(
        targetOn(w.ctl.dailyTargets, DailyTarget.spendLimit, '2026-11-09'),
        isNull,
      );
      expect(
        targetOn(w.ctl.dailyTargets, DailyTarget.spendLimit, '2026-11-14'),
        isNotNull,
      );
      expect(
        targetOn(w.ctl.dailyTargets, DailyTarget.spendLimit, '2026-11-15'),
        isNotNull,
      );
      await w.goTo('2026-11-16T15:00:00.000Z');
      await w.ctl.endDailyTarget(DailyTarget.spendLimit);
      expect(
        targetOn(w.ctl.dailyTargets, DailyTarget.spendLimit, '2026-11-21'),
        isNull,
      );
      expect(
        targetOn(w.ctl.dailyTargets, DailyTarget.spendLimit, '2026-11-14'),
        isNotNull,
      );
      // reloading from the database brings the same targets back
      await w.ctl.reload();
      expect(w.ctl.dailyTargets.single.validUntil, '2026-11-16');
      expect(w.ctl.dailyTargets.single.weekdays, [6, 7]);
    });
  });

  test('027: the month breakdown puts each entry in one state and adds up', () {
    return _with('2026-11-10T15:00:00.000Z', (w) async {
      await w.add(TransactionKind.expense, 4500, '2026-11-07');
      await w.add(TransactionKind.cardPurchase, 100, '2026-11-07');
      await w.add(
        TransactionKind.expense,
        9000,
        '2026-11-05',
        status: TransactionStatus.planned,
      );
      await w.add(
        TransactionKind.expense,
        7000,
        '2026-11-25',
        status: TransactionStatus.planned,
      );
      await w.add(TransactionKind.income, 6500, '2026-11-07');
      await w.add(
        TransactionKind.income,
        3000,
        '2026-11-08',
        status: TransactionStatus.planned,
      );
      await w.add(
        TransactionKind.income,
        2000,
        '2026-11-28',
        status: TransactionStatus.planned,
      );
      final b = monthBreakdown(w.ledger, '2026-11', w.today);
      expect(b.paid, 4600);
      expect(b.overdue, 9000);
      expect(b.upcoming, 7000);
      expect(b.received, 6500);
      expect(b.lateIncome, 3000);
      expect(b.toReceive, 2000);
      final t = monthTotals(w.ledger, '2026-11');
      expect(b.paid, t.expenseSettled);
      expect(b.overdue + b.upcoming, t.expensePlanned);
      expect(b.lateIncome + b.toReceive, t.incomePlanned);
    });
  });

  test(
    '027: recurrence comes from what the entry is, never from its description',
    () {
      return _with('2026-11-10T15:00:00.000Z', (w) async {
        await w.ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.expense,
            amountCents: 9000,
            date: '2026-11-05',
            description: 'internet',
            accountId: w.account.id,
            recurrenceFrequency: 'monthly',
          ),
        );
        await w.ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.cardPurchase,
            amountCents: 30000,
            date: '2026-11-06',
            description: 'geladeira',
            cardId: w.card.id,
            installments: 3,
          ),
        );
        // same description as the recurring one, and it is still a one-off
        await w.ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.expense,
            amountCents: 500,
            date: '2026-11-07',
            description: 'internet',
            accountId: w.account.id,
          ),
        );
        final r = expensesByRecurrence(w.ledger, '2026-11');
        expect(r.recurring, 9000);
        expect(r.installments, 10000);
        expect(r.single, 500);
        expect(
          r.recurring + r.installments + r.single,
          monthTotals(w.ledger, '2026-11').expenseSettled,
        );
      });
    },
  );

  test('time arithmetic used by the limits holds across a leap day', () {
    expect(addDays('2028-02-28', 1), '2028-02-29');
    expect(addDays('2028-02-29', 1), '2028-03-01');
    expect(dailyFlow(const Ledger(), '2028-02', '2028-02-10').length, 29);
    expect(dailyFlow(const Ledger(), '2027-02', '2027-02-10').length, 28);
  });
}
