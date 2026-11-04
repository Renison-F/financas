import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/cards/cards.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ledger/ledger.dart';
import 'package:serenacash/domain/recurrence/recurrence.dart';
import '../fixtures/fixture_loader.dart';

Ledger _ledger(Map<String, dynamic> i) => Ledger.fromJson(i['ledger'] as Map<String, dynamic>);

void main() {
  group('ledger fixtures', () {
    for (final c in loadFixtures('ledger')) {
      test(c.name, () {
        final L = _ledger(c.inputMap);
        final actual = {
          'balanceA': accountBalance(L, 'a'), 'balanceB': accountBalance(L, 'b'), 'balanceA_asOf_1105': accountBalance(L, 'a', '2026-11-05'), 'consolidated': consolidatedBalance(L),
          'monthTotals': monthTotals(L, '2026-11').toJson(), 'overdueIds': overdue(L, '2026-11-04').map((t) => t.id).toList(), 'upcomingIds': upcoming(L, '2026-11-04', '2026-11-30').map((t) => t.id).toList(),
        };
        expect(jsonEquals(actual, c.expected), isTrue, reason: 'expected ${c.expected}\n got $actual');
      });
    }
  });
  group('cards fixtures', () {
    Map<String, dynamic> inv(Invoice v) => {'cardId': v.cardId, 'month': v.month, 'closingDate': v.closingDate, 'dueDate': v.dueDate, 'purchases': v.purchases.map((t) => t.id).toList(), 'payments': v.payments.map((t) => t.id).toList(), 'totalCents': v.totalCents, 'paidCents': v.paidCents, 'remainingCents': v.remainingCents, 'state': v.state.name};
    for (final c in loadFixtures('cards')) {
      test(c.name, () {
        final i = c.inputMap;
        dynamic actual;
        if (c.name.startsWith('invoiceMonthFor')) {
          actual = invoiceMonthFor(i['closingDay'] as int, i['date'] as String);
        } else if (c.name.startsWith('invoiceDueDate')) {
          actual = invoiceDueDate(i['closingDay'] as int, i['dueDay'] as int, i['month'] as String);
        } else if (c.name.startsWith('invoice ')) {
          final L = _ledger(i);
          actual = inv(invoice(L, L.cardById(i['cardId'] as String)!, i['month'] as String, i['today'] as String));
        } else if (c.name.startsWith('cardCommitment')) {
          final L = _ledger(i);
          actual = cardCommitment(L, L.cardById(i['cardId'] as String)!, i['today'] as String).toJson();
        } else if (c.name.startsWith('planInstallments')) {
          actual = planInstallments(totalCents: i['totalCents'] as int, count: i['count'] as int, purchaseDate: i['purchaseDate'] as String, closingDay: i['closingDay'] as int, firstInvoiceOffsetMonths: i['firstInvoiceOffsetMonths'] as int).map((p) => p.toJson()).toList();
        } else {
          fail('unmapped ${c.name}');
        }
        expect(jsonEquals(actual, c.expected), isTrue, reason: 'expected ${c.expected}\n got $actual');
      });
    }
    test('card refund (new): reduces the invoice and month expenses, never exceeds the purchase', () {
      const now = '2026-11-04T00:00:00.000Z';
      const card = CreditCard(id: 'k', name: 'K', limitCents: 100000, closingDay: 20, dueDay: 27, color: '#000', archived: false, currency: 'BRL', createdAt: now, updatedAt: now);
      const purchase = Transaction(id: 'p', kind: TransactionKind.cardPurchase, amountCents: 10000, currency: 'BRL', date: '2026-11-03', description: 'TV', cardId: 'k', status: TransactionStatus.settled, createdAt: now, updatedAt: now);
      const refund = Transaction(id: 'r', kind: TransactionKind.cardRefund, amountCents: 4000, currency: 'BRL', date: '2026-11-05', description: 'Estorno TV', cardId: 'k', refundOfId: 'p', status: TransactionStatus.settled, createdAt: now, updatedAt: now);
      const L = Ledger(cards: [card], transactions: [purchase, refund]);
      expect(invoice(L, card, '2026-11', '2026-11-06').totalCents, 6000);
      expect(monthTotals(L, '2026-11').expenseSettled, 6000);
      expect(cardCommitment(L, card, '2026-11-06').availableLimitCents, 94000);
      expect(validateCardRefund(L, purchase, 6000).ok, isTrue);
      expect(validateCardRefund(L, purchase, 6001).ok, isFalse);
      expect(validateCardRefund(L, purchase, 6001).maxRefundableCents, 6000);
      expect(validateCardRefund(L, refund, 1).ok, isFalse);
    });
  });
  group('recurrence fixtures', () {
    for (final c in loadFixtures('recurrence')) {
      test(c.name, () {
        final i = c.inputMap;
        final rule = RecurrenceRule.fromJson(i['rule'] as Map<String, dynamic>);
        final actual = c.name.startsWith('next') ? nextOccurrence(rule, i['after'] as String) : occurrencesBetween(rule, i['from'] as String, i['to'] as String);
        expect(jsonEquals(actual, c.expected), isTrue, reason: 'expected ${c.expected} got $actual');
      });
    }
  });
}
