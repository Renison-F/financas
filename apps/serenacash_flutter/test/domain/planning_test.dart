import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/availability/availability.dart';
import 'package:serenacash/domain/budgets/budgets.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/goals/goals.dart';
import 'package:serenacash/domain/loans/loans.dart';
import '../fixtures/fixture_loader.dart';

Ledger _ledger(Map<String, dynamic> i) => Ledger.fromJson(i['ledger'] as Map<String, dynamic>);

void main() {
  group('availability fixtures', () {
    for (final c in loadFixtures('availability')) {
      test(c.name, () {
        final i = c.inputMap;
        final actual = availability(_ledger(i), today: i['today'] as String, horizonEnd: i['horizonEnd'] as String?, includePlannedIncome: i['includePlannedIncome'] as bool?, safetyCushionCents: i['safetyCushionCents'] as int?).toJson();
        expect(jsonEquals(actual, c.expected), isTrue, reason: 'expected ${c.expected}\n got $actual');
      });
    }
  });
  group('budgets fixtures', () {
    for (final c in loadFixtures('budgets')) {
      test(c.name, () {
        final i = c.inputMap;
        dynamic actual;
        if (c.name.startsWith('spentInMonth')) {
          final s = spentInMonth(_ledger(i), i['month'] as String, i['categoryId'] as String?);
          actual = {'spentCents': s.spentCents, 'plannedCents': s.plannedCents};
        } else if (c.name.startsWith('budgetsForMonth')) {
          actual = budgetsForMonth(_ledger(i), i['month'] as String, i['today'] as String).map((s) => s.toJson()).toList();
        } else if (c.name.startsWith('pace')) {
          actual = pace((i['used'] as num).toDouble(), (i['expected'] as num).toDouble()).name;
        } else if (c.name.startsWith('monthElapsed')) {
          actual = monthElapsedPercent(i['month'] as String, i['today'] as String);
        } else {
          fail('unmapped ${c.name}');
        }
        expect(jsonEquals(actual, c.expected), isTrue, reason: 'expected ${c.expected}\n got $actual');
      });
    }
  });
  group('goals fixtures', () {
    for (final c in loadFixtures('goals')) {
      test(c.name, () {
        final i = c.inputMap;
        final L = _ledger(i);
        final actual = goalProgress(L, L.goalById(i['goalId'] as String)!, i['today'] as String).toJson();
        expect(jsonEquals(actual, c.expected), isTrue, reason: 'expected ${c.expected}\n got $actual');
      });
    }
  });
  group('loans fixtures', () {
    for (final c in loadFixtures('loans')) {
      test(c.name, () {
        final i = c.inputMap;
        dynamic actual;
        if (c.name.startsWith('price ')) {
          actual = priceInstallment(i['principalCents'] as int, (i['monthlyRatePercent'] as num).toDouble(), i['n'] as int);
        } else if (c.name.startsWith('schedule')) {
          actual = buildSchedule(Loan.fromJson(i['loan'] as Map<String, dynamic>)).map((r) => r.toJson()).toList();
        } else if (c.name == 'position') {
          final L = _ledger(i);
          final p = loanPosition(L, L.loanById(i['loanId'] as String)!, i['today'] as String);
          actual = {'loan': p.loan.id, 'paidInstallments': p.paidInstallments, 'paidCents': p.paidCents, 'extraAmortizationCents': p.extraAmortizationCents, 'outstandingCents': p.outstandingCents, 'nextDue': p.nextDue?.number, 'overdueInstallments': p.overdueInstallments.map((r) => r.number).toList(), 'payoffTodayCents': p.payoffTodayCents};
        } else if (c.name.startsWith('payoffValue')) {
          final loan = Loan(id: 'l', name: 'l', principalCents: 1000000, monthlyRatePercent: 2, termMonths: 12, system: 'price', firstDueDate: '2026-01-10', monthlyFeeCents: 0, upfrontFeesCents: 0, archived: false, createdAt: '', updatedAt: '');
          actual = payoffValue(buildSchedule(loan).sublist(i['from'] as int), (i['rate'] as num).toDouble(), i['today'] as String);
        } else if (c.name.startsWith('extra')) {
          final loan = Loan(id: 'l', name: 'l', principalCents: 1000000, monthlyRatePercent: 2, termMonths: 12, system: 'price', firstDueDate: '2026-01-10', monthlyFeeCents: 0, upfrontFeesCents: 0, archived: false, createdAt: '', updatedAt: '');
          actual = simulateExtraPayment(loan, i['outstanding'] as int, i['extra'] as int, i['remaining'] as int, i['mode'] as String).toJson();
        } else {
          fail('unmapped ${c.name}');
        }
        expect(jsonEquals(actual, c.expected), isTrue, reason: 'expected ${c.expected}\n got $actual');
      });
    }
  });
}
