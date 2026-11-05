/// How the main computations scale with the size of the ledger: 100, 1.000, 5.000, 10.000 and 50.000
/// entries. The numbers come from the Dart VM on the development machine: they show the shape of the
/// growth (and catch an accidental quadratic), not what a phone does. Device numbers are measured with a
/// release build and recorded in docs/flutter-migration/10-PERFORMANCE.md.
///
/// With SERENA_PERF_OUT set to a folder it also writes one plain backup per size, to be imported in a test
/// install on a device.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/state/dashboard_data.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/database/drift_ledger_repository.dart';
import 'package:serenacash/domain/availability/availability.dart';
import 'package:serenacash/domain/dashboard/widgets.dart' as dash;
import 'package:serenacash/domain/io/backup.dart';
import 'package:serenacash/domain/ledger/ledger.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/reports/reports.dart';

import 'perf_test.dart' show bigLedger;

double _ms(void Function() f, {int runs = 3}) {
  f(); // warm-up
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    f();
  }
  return sw.elapsedMicroseconds / runs / 1000;
}

void main() {
  const sizes = [100, 1000, 5000, 10000, 50000];
  const today = '2026-11-04';
  final rows = <int, Map<String, double>>{};

  for (final n in sizes) {
    test('volume: $n entries', () async {
      final ledger = bigLedger(n);
      final essential = dash.defaultLayout;
      final complete = dash.applyPreset(dash.defaultLayout, 'complete');
      final r = <String, double>{};
      r['dashboard essential'] = _ms(
        () => computeDashboard(ledger, essential, today, 2, 3),
      );
      r['dashboard 24 widgets'] = _ms(
        () => computeDashboard(ledger, complete, today, 2, 3),
      );
      r['search'] = _ms(
        () => searchTransactions(
          ledger,
          'Lançamento 12',
          const SearchFilters(from: '2025-01-01', to: '2026-12-31'),
        ),
      );
      r['month totals'] = _ms(() => monthTotals(ledger, '2026-11'));
      r['by category'] = _ms(
        () => expensesByCategory(ledger, '2026-11', rollUp: true),
      );
      r['pode gastar'] = _ms(() => availability(ledger, today: today));

      final db = AppDatabase.inMemory();
      final repo = DriftLedgerRepository(
        db,
        clock: FixedClock('2026-11-04T12:00:00.000Z'),
      );
      final sw = Stopwatch()..start();
      await repo.replaceAll(ledger);
      r['db write all'] = sw.elapsedMicroseconds / 1000;
      sw.reset();
      final back = await repo.loadLedger();
      r['db load all'] = sw.elapsedMicroseconds / 1000;
      sw.reset();
      await repo.transactionsBetween('2026-11-01', '2026-11-30');
      r['db month range'] = sw.elapsedMicroseconds / 1000;
      expect(back.transactions.length, n);
      expect(await db.integrityCheck(), isEmpty);
      await db.close();
      rows[n] = r;

      final out = Platform.environment['SERENA_PERF_OUT'];
      if (out != null && out.isNotEmpty) {
        final file = File('$out/serenacash-perf-$n.json');
        await file.writeAsString(
          jsonEncode(
            createBackup(
              ledger,
              exportedAt: '2026-11-04T12:00:00.000Z',
            ).toJson(),
          ),
        );
      }

      // Bounds are generous on purpose: they exist to catch a change of order of magnitude.
      final perEntry = r['dashboard 24 widgets']! / n;
      expect(
        perEntry,
        lessThan(1.0),
        reason: 'dashboard grew faster than linear',
      );
      expect(r['search']!, lessThan(n * 0.05 + 50));
    });
  }

  tearDownAll(() {
    if (rows.isEmpty) return;
    final metrics = rows.values.first.keys.toList();
    final b = StringBuffer('PERF-VOLUME (ms)\n');
    b.writeln('| medida | ${sizes.where(rows.containsKey).join(' | ')} |');
    for (final m in metrics) {
      b.writeln(
        '| $m | ${sizes.where(rows.containsKey).map((n) => rows[n]![m]!.toStringAsFixed(1)).join(' | ')} |',
      );
    }
    // ignore: avoid_print
    print(b);
  });
}
