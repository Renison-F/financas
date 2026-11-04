/// Performance measurements in this environment (Linux host, debug VM). Numbers are printed and bounded
/// generously; the bounds exist to catch order-of-magnitude regressions, not device frame budgets.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/state/dashboard_data.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/database/drift_ledger_repository.dart';
import 'package:serenacash/domain/dashboard/widgets.dart' as dash;
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/reports/reports.dart';

Ledger bigLedger(int n) {
  const now = '2026-11-04T12:00:00.000Z';
  final accounts = [
    for (var i = 0; i < 3; i++)
      Account(
        id: 'a$i',
        name: 'Conta $i',
        type: 'checking',
        currency: 'BRL',
        openingBalanceCents: 100000 * (i + 1),
        openingDate: '2024-01-01',
        color: '#0B5563',
        archived: false,
        includeInAvailability: true,
        sortOrder: i,
        createdAt: now,
        updatedAt: now,
      ),
  ];
  final cats = [
    for (var i = 0; i < 12; i++)
      Category(
        id: 'c$i',
        name: 'Cat $i',
        kind: i < 10 ? 'expense' : 'income',
        icon: 'tag',
        color: '#4F5E61',
        archived: false,
        sortOrder: i,
        createdAt: now,
        updatedAt: now,
      ),
  ];
  final card = const CreditCard(
    id: 'card',
    name: 'Cartão',
    limitCents: 800000,
    closingDay: 20,
    dueDay: 27,
    color: '#0B5563',
    archived: false,
    currency: 'BRL',
    createdAt: now,
    updatedAt: now,
  );
  final txs = <Transaction>[];
  for (var i = 0; i < n; i++) {
    final day = (i % 28) + 1;
    final monthIdx = (i ~/ 28) % 24;
    final y = 2025 + monthIdx ~/ 12, m = monthIdx % 12 + 1;
    final date =
        '$y-${m.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    final kind = i % 7 == 0
        ? TransactionKind.income
        : i % 5 == 0
        ? TransactionKind.cardPurchase
        : TransactionKind.expense;
    txs.add(
      Transaction(
        id: 't$i',
        kind: kind,
        amountCents: 1000 + (i * 37) % 90000,
        currency: 'BRL',
        date: date,
        description: 'Lançamento $i',
        categoryId: kind == TransactionKind.income ? 'c10' : 'c${i % 10}',
        accountId: kind == TransactionKind.cardPurchase ? null : 'a${i % 3}',
        cardId: kind == TransactionKind.cardPurchase ? 'card' : null,
        invoiceMonth: kind == TransactionKind.cardPurchase
            ? '$y-${m.toString().padLeft(2, '0')}'
            : null,
        status: i % 11 == 0
            ? TransactionStatus.planned
            : TransactionStatus.settled,
        dueDate: i % 11 == 0 ? date : null,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
  return Ledger(
    accounts: accounts,
    categories: cats,
    cards: [card],
    transactions: txs,
    budgets: [
      const Budget(
        id: 'b',
        limitCents: 500000,
        rollover: false,
        createdAt: now,
        updatedAt: now,
      ),
    ],
    goals: [
      const Goal(
        id: 'g',
        name: 'Reserva',
        kind: 'emergency_fund',
        targetCents: 1000000,
        reserved: true,
        color: '#0B5563',
        archived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );
}

void main() {
  test('dashboard computation for 5,000 transactions stays well under one frame budget on device class hardware', () {
    final ledger = bigLedger(5000);
    final layout = dash.applyPreset(dash.defaultLayout, 'complete');
    computeDashboard(ledger, layout, '2026-11-04', 2, 3); // warm-up
    final sw = Stopwatch()..start();
    for (var i = 0; i < 10; i++) {
      computeDashboard(ledger, layout, '2026-11-04', 2, 3);
    }
    sw.stop();
    final perRun = sw.elapsedMicroseconds / 10 / 1000;
    // ignore: avoid_print
    print(
      'PERF dashboard(5000 tx, 24 widgets): ${perRun.toStringAsFixed(1)} ms per computation',
    );
    expect(perRun, lessThan(1500));
  });

  test('search over 5,000 transactions', () {
    final ledger = bigLedger(5000);
    final sw = Stopwatch()..start();
    final r = searchTransactions(
      ledger,
      'Lançamento 12',
      const SearchFilters(from: '2025-01-01', to: '2026-12-31'),
    );
    sw.stop();
    // ignore: avoid_print
    print(
      'PERF search(5000 tx): ${sw.elapsedMicroseconds / 1000} ms, ${r.length} results',
    );
    expect(sw.elapsedMilliseconds, lessThan(500));
  });

  test('database: replaceAll + loadLedger with 5,000 transactions', () async {
    final db = AppDatabase.inMemory();
    final repo = DriftLedgerRepository(
      db,
      clock: FixedClock('2026-11-04T12:00:00.000Z'),
    );
    final ledger = bigLedger(5000);
    final sw = Stopwatch()..start();
    await repo.replaceAll(ledger);
    final write = sw.elapsedMilliseconds;
    sw.reset();
    final back = await repo.loadLedger();
    final read = sw.elapsedMilliseconds;
    sw.reset();
    final month = await repo.transactionsBetween('2026-11-01', '2026-11-30');
    final range = sw.elapsedMilliseconds;
    // ignore: avoid_print
    print(
      'PERF db: replaceAll $write ms · loadLedger $read ms (${back.transactions.length} tx) · month range $range ms (${month.length} tx)',
    );
    expect(back.transactions.length, 5000);
    expect(write, lessThan(20000));
    expect(read, lessThan(5000));
    expect(range, lessThan(1000));
    await db.close();
  });
}
