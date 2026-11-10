/// Ocorrência 012 da homologação física: um orçamento ou uma meta criados em 2026 apareciam em 2025.
/// Orçamentos e metas valem a partir de quando passaram a existir; olhar para trás mostra o que
/// havia, e mudar um limite não reescreve os meses já vividos.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/state/app_state.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/notifications/bill_reminders.dart';
import 'package:serenacash/data/security/secret_store.dart';
import 'package:serenacash/domain/budgets/budgets.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/goals/goals.dart';
import 'package:serenacash/domain/ports/ports.dart';

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

  Future<void> boot() => container.read(appControllerProvider.future);
  AppController get ctl => container.read(appControllerProvider.notifier);
  Ledger get ledger => container.read(ledgerProvider);
  String get today => container.read(todayProvider);

  /// Moves the clock and reloads, as opening the app on another day does.
  Future<void> goTo(String now) async {
    clock.value = now;
    await ctl.reload();
  }

  int? overall(String month) => budgetsForMonth(
    ledger,
    month,
    today,
  ).where((b) => b.budget.categoryId == null).firstOrNull?.limitCents;

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
  test(
    '012: a budget created in November 2026 is not in force before that',
    () {
      return _with('2026-11-07T15:00:00.000Z', (w) async {
        await w.ctl.saveBudget(limitCents: 85000);
        expect(w.today, '2026-11-07');
        for (final m in ['2025-01', '2025-12', '2026-01', '2026-10']) {
          expect(w.overall(m), isNull, reason: 'mês $m não tinha orçamento');
        }
        for (final m in ['2026-11', '2026-12', '2027-01', '2028-02']) {
          expect(w.overall(m), 85000, reason: 'mês $m');
        }
      });
    },
  );

  test(
    '012: a new limit starts a new period; past months keep the old one',
    () {
      return _with('2026-11-07T15:00:00.000Z', (w) async {
        final b = await w.ctl.saveBudget(limitCents: 85000);
        await w.goTo('2027-02-10T15:00:00.000Z');
        await w.ctl.saveBudget(id: b.id, limitCents: 100000);
        expect(w.overall('2026-11'), 85000);
        expect(w.overall('2026-12'), 85000);
        expect(w.overall('2027-01'), 85000);
        expect(w.overall('2027-02'), 100000);
        expect(w.overall('2027-12'), 100000);
        expect(w.overall('2026-10'), isNull);
        // changing it again in the same month edits the current period instead of adding another
        final current = w.ledger.budgets
            .where((x) => budgetInForce(x, '2027-02'))
            .single;
        await w.ctl.saveBudget(id: current.id, limitCents: 110000);
        expect(w.ledger.budgets.where((x) => x.deletedAt == null).length, 2);
        expect(w.overall('2027-02'), 110000);
        expect(w.overall('2027-01'), 85000);
      });
    },
  );

  test('012: ending a budget keeps it in the months it covered', () {
    return _with('2026-11-07T15:00:00.000Z', (w) async {
      final b = await w.ctl.saveBudget(limitCents: 85000);
      await w.goTo('2027-01-05T15:00:00.000Z');
      await w.ctl.deleteBudget(b.id);
      expect(w.overall('2026-11'), 85000);
      expect(w.overall('2026-12'), 85000);
      expect(w.overall('2027-01'), isNull);
      expect(w.overall('2027-06'), isNull);
    });
  });

  test('012: a budget removed in the month it was created leaves no trace', () {
    return _with('2026-11-07T15:00:00.000Z', (w) async {
      final b = await w.ctl.saveBudget(limitCents: 85000);
      await w.ctl.deleteBudget(b.id);
      expect(w.overall('2026-11'), isNull);
      expect(w.overall('2026-12'), isNull);
    });
  });

  test('012: a budget of one month only counts in that month', () {
    return _with('2026-11-07T15:00:00.000Z', (w) async {
      await w.ctl.saveBudget(limitCents: 85000);
      await w.ctl.saveBudget(limitCents: 120000, month: '2026-12');
      expect(w.overall('2026-11'), 85000);
      expect(w.overall('2026-12'), 120000);
      expect(w.overall('2027-01'), 85000);
      expect(w.overall('2025-12'), isNull);
    });
  });

  test('012: year boundaries, December to January and a leap February', () {
    return _with('2027-12-31T15:00:00.000Z', (w) async {
      await w.ctl.saveBudget(limitCents: 50000);
      expect(w.overall('2027-11'), isNull);
      expect(w.overall('2027-12'), 50000);
      expect(w.overall('2028-01'), 50000);
      expect(w.overall('2028-02'), 50000); // 2028 is a leap year
      expect(monthElapsedPercent('2028-02', '2028-02-29'), 100);
    });
  });

  test('012: a goal does not appear in a year before it existed', () {
    return _with('2026-11-07T15:00:00.000Z', (w) async {
      await w.ctl.saveGoal(name: 'reserva', targetCents: 500000);
      expect(goalsForYear(w.ledger, 2025, w.today), isEmpty);
      expect(goalsForYear(w.ledger, 2024, w.today), isEmpty);
      final now = goalsForYear(w.ledger, 2026, w.today).single;
      expect(now.phase, GoalYearPhase.current);
      expect(now.remainingCents, 500000);
      // no deadline: the monthly figure spreads what is missing over November and December
      expect(now.monthlyUntilTargetDate, isFalse);
      expect(now.monthlyCents, 250000);
    });
  });

  test(
    '012: the monthly figure of a goal with a deadline uses the real term',
    () {
      return _with('2026-11-07T15:00:00.000Z', (w) async {
        await w.ctl.saveGoal(
          name: 'viagem',
          targetCents: 600000,
          targetDate: '2027-11-07',
        );
        final v = goalsForYear(w.ledger, 2026, w.today).single;
        expect(v.monthlyUntilTargetDate, isTrue);
        // 365 days ≈ 12 months: R$ 6.000,00 in 12 parts, not in the 2 months left in the year
        expect(v.monthlyCents, 50000);
        // the goal is still running in 2027 and is over by 2028
        expect(
          goalsForYear(w.ledger, 2027, w.today).single.phase,
          GoalYearPhase.future,
        );
        expect(goalsForYear(w.ledger, 2028, w.today), isEmpty);
      });
    },
  );

  test('012: a past year shows what was put aside, never a suggestion', () {
    return _with('2026-11-07T15:00:00.000Z', (w) async {
      final acc = await w.ctl.saveAccount(
        name: 'c6',
        type: 'checking',
        openingBalanceCents: 100000,
        openingDate: '2026-11-01',
      );
      final g = await w.ctl.saveGoal(name: 'reserva', targetCents: 500000);
      await w.ctl.saveTransaction(
        TransactionInput(
          kind: TransactionKind.goalDeposit,
          amountCents: 15000,
          date: '2026-11-07',
          description: 'aporte',
          accountId: acc.id,
          goalId: g.id,
        ),
      );
      await w.goTo('2027-03-02T15:00:00.000Z');
      await w.ctl.saveTransaction(
        TransactionInput(
          kind: TransactionKind.goalDeposit,
          amountCents: 5000,
          date: '2027-03-02',
          description: 'aporte',
          accountId: acc.id,
          goalId: g.id,
        ),
      );
      final past = goalsForYear(w.ledger, 2026, w.today).single;
      expect(past.phase, GoalYearPhase.past);
      expect(past.savedInYearCents, 15000);
      expect(past.savedByYearEndCents, 15000);
      expect(past.monthlyCents, isNull);
      expect(past.remainingCents, 0);
      expect(goalsForYear(w.ledger, 2025, w.today), isEmpty);
      final current = goalsForYear(w.ledger, 2027, w.today).single;
      expect(current.savedInYearCents, 5000);
      expect(current.remainingCents, 480000);
    });
  });

  test('012: looking at other years changes nothing that is stored', () {
    return _with('2026-11-07T15:00:00.000Z', (w) async {
      await w.ctl.saveBudget(limitCents: 85000);
      await w.ctl.saveGoal(name: 'reserva', targetCents: 500000);
      final before = w.ledger.budgets.map((b) => b.toJson()).toList();
      for (final y in [2020, 2025, 2026, 2027, 2030]) {
        goalsForYear(w.ledger, y, w.today);
        for (var m = 1; m <= 12; m++) {
          budgetsForMonth(
            w.ledger,
            '$y-${m.toString().padLeft(2, '0')}',
            w.today,
          );
        }
      }
      await w.ctl.reload();
      expect(w.ledger.budgets.map((b) => b.toJson()).toList(), before);
    });
  });
}
