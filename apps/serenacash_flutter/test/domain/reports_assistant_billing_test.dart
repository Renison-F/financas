import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/assistant/assistant.dart';
import 'package:serenacash/domain/billing/billing.dart';
import 'package:serenacash/domain/dashboard/widgets.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/reports/reports.dart';
import 'package:serenacash/domain/sync/sync_model.dart';

import '../fixtures/fixture_loader.dart';

Ledger _ledger(Map<String, dynamic> i) =>
    Ledger.fromJson(i['ledger'] as Map<String, dynamic>);

void main() {
  group('reports fixtures', () {
    for (final c in loadFixtures('reports')) {
      test(c.name, () {
        final i = c.inputMap;
        final L = _ledger(i);
        dynamic actual;
        if (c.name.startsWith('expensesByCategory')) {
          actual = expensesByCategory(
            L,
            i['month'] as String,
            rollUp: i['rollUp'] == true,
            includePlanned: i['includePlanned'] == true,
          ).map((x) => x.toJson()).toList();
        } else if (c.name.startsWith('cashflow')) {
          actual = cashflow(
            L,
            i['end'] as String,
            i['months'] as int,
          ).map((p) => p.toJson()).toList();
        } else if (c.name.startsWith('compareMonths')) {
          actual = compareMonths(L, i['month'] as String).toJson();
        } else if (c.name.startsWith('yearSummary')) {
          actual = yearSummary(L, i['year'] as int).toJson();
        } else if (c.name.startsWith('recurring')) {
          actual = recurringExpenses(
            L,
            i['end'] as String,
          ).map((r) => r.toJson()).toList();
        } else if (c.name.startsWith('projectBalance')) {
          actual = projectBalance(
            L,
            i['today'] as String,
            i['until'] as String,
          ).toJson();
        } else if (c.name.startsWith('netWorth')) {
          actual = netWorth(
            L,
            i['end'] as String,
            i['months'] as int,
            i['today'] as String,
          ).map((p) => p.toJson()).toList();
        } else if (c.name == 'search salario') {
          actual = searchTransactions(
            L,
            i['query'] as String,
          ).map((t) => t.id).toList();
        } else if (c.name == 'search food planned') {
          actual = searchTransactions(
            L,
            '',
            const SearchFilters(
              categoryIds: ['food'],
              status: [TransactionStatus.planned],
            ),
          ).map((t) => t.id).toList();
        } else if (c.name == 'search min') {
          actual = searchTransactions(
            L,
            '',
            const SearchFilters(minCents: 200000),
          ).map((t) => t.id).toList();
        } else {
          fail('unmapped ${c.name}');
        }
        expect(
          jsonEquals(actual, c.expected),
          isTrue,
          reason: 'expected ${c.expected}\n got $actual',
        );
      });
    }
  });
  group('assistant fixtures', () {
    for (final c in loadFixtures('assistant')) {
      test(c.name, () {
        final i = c.inputMap;
        dynamic actual;
        if (c.name.startsWith('intent')) {
          actual = detectIntent(i['question'] as String).toJson();
        } else if (c.name.startsWith('answer')) {
          actual = answer(
            _ledger(i),
            i['question'] as String,
            i['today'] as String,
          ).toJson();
        } else {
          actual = recommendations(
            _ledger(i),
            i['today'] as String,
          ).map((r) => {'id': r.id, 'severity': r.severity}).toList();
        }
        expect(
          jsonEquals(actual, c.expected),
          isTrue,
          reason: 'expected ${c.expected}\n got $actual',
        );
      });
    }
  });
  group('billing fixtures', () {
    for (final c in loadFixtures('billing')) {
      test(c.name, () {
        final i = c.inputMap;
        List<Entitlement> ents(Object? l) => (l as List<dynamic>)
            .map((e) => Entitlement.fromJson(e as Map<String, dynamic>))
            .toList();
        dynamic actual;
        if (c.name.startsWith('access')) {
          actual = resolveAccess(
            ents(i['entitlements']),
            DateTime.parse(i['now'] as String),
          ).toJson();
        } else if (c.name.startsWith('withinLimit')) {
          final r = withinLimit(
            resolveAccess(const [], DateTime.parse('2026-11-04T12:00:00.000Z')),
            i['key'] as String,
            i['count'] as int,
          );
          actual = {'ok': r.ok, 'limit': r.limit, 'remaining': r.remaining};
        } else {
          actual = mergeEntitlements(
            ents(i['existing']),
            ents(i['incoming']),
          ).map((e) => e.toJson()).toList();
        }
        expect(
          jsonEquals(actual, c.expected),
          isTrue,
          reason: 'expected ${c.expected}\n got $actual',
        );
      });
    }
    test('catalog ids are distinct between lifetime and subscriptions', () {
      final lt = planById(PlanId.lifetime);
      for (final p in plans.where((p) => p.id != PlanId.lifetime)) {
        expect(p.iosProduct, isNot(lt.iosProduct));
        expect(p.androidProduct, isNot(lt.androidProduct));
      }
      expect(widgets.length, 24);
    });
  });
  group('dashboard fixtures', () {
    for (final c in loadFixtures('dashboard')) {
      test(c.name, () {
        dynamic actual;
        if (c.name == 'widget ids') {
          actual = widgetIds;
        } else if (c.name == 'default layout') {
          actual = defaultLayout.toJson();
        } else if (c.name == 'ops sequence') {
          var l = applyPreset(defaultLayout, 'focus');
          l = showWidget(l, 'goals', 1);
          l = moveWidgetBy(l, 'goals', -1);
          l = moveWidgetBy(l, 'goals', -1);
          l = hideWidget(l, 'bills_to_pay');
          actual = l.toJson();
        } else {
          actual = normalizeLayout(c.inputMap['raw']).toJson();
        }
        expect(
          jsonEquals(actual, c.expected),
          isTrue,
          reason: 'expected ${c.expected}\n got $actual',
        );
      });
    }
  });
  group('sync fixtures', () {
    for (final c in loadFixtures('sync')) {
      test(c.name, () {
        final i = c.inputMap;
        final r = mergeEntity(
          i['base'] as Map<String, dynamic>?,
          i['local'] as Map<String, dynamic>,
          i['remote'] as Map<String, dynamic>,
          'transaction',
          't',
          'now',
        );
        final actual = {
          'merged': r.merged,
          if (r.conflict != null) 'conflict': r.conflict!.toJson(),
        };
        expect(
          jsonEquals(actual, c.expected),
          isTrue,
          reason: 'expected ${c.expected}\n got $actual',
        );
      });
    }
  });
}
