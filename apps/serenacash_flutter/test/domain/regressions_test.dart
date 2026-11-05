/// Rules added while fixing the homologation findings (calendar day result, year ranking, greeting).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ledger/ledger.dart';
import 'package:serenacash/domain/reports/reports.dart';
import 'package:serenacash/features/shared/format.dart';
import 'package:serenacash/l10n/app_localizations_pt.dart';

Transaction _tx(
  String id,
  TransactionKind kind,
  int cents, {
  String date = '2026-11-05',
  TransactionStatus status = TransactionStatus.settled,
  int? paidCents,
}) => Transaction(
  id: id,
  kind: kind,
  status: status,
  amountCents: cents,
  currency: 'BRL',
  paidCents: paidCents,
  date: date,
  description: id,
  accountId: 'a',
  createdAt: '2026-11-05T00:00:00.000Z',
  updatedAt: '2026-11-05T00:00:00.000Z',
);

void main() {
  group('resultCents (calendar day result)', () {
    test('counts income, expenses and card purchases; leaves out what only moves money', () {
      final day = [
        _tx('salario', TransactionKind.income, 500000),
        _tx(
          'internet',
          TransactionKind.expense,
          9990,
          status: TransactionStatus.partiallyPaid,
          paidCents: 4000,
        ),
        _tx('padaria', TransactionKind.expense, 4590),
        _tx('loja', TransactionKind.cardPurchase, 30000),
        _tx('fatura', TransactionKind.cardPayment, 4500),
        _tx('reserva', TransactionKind.goalDeposit, 10000),
        _tx('transferencia', TransactionKind.transfer, 2000),
        _tx('estorno', TransactionKind.cardRefund, 1000),
      ];
      // 5000,00 − 99,90 − 45,90 − 300,00 + 10,00
      expect(resultCents(day), 500000 - 9990 - 4590 - 30000 + 1000);
    });

    test('the homologation day: -445,80, not -590,80', () {
      final day = [
        _tx(
          'internet',
          TransactionKind.expense,
          9990,
          status: TransactionStatus.partiallyPaid,
          paidCents: 4000,
        ),
        _tx('padaria', TransactionKind.expense, 4590),
        _tx('loja', TransactionKind.cardPurchase, 30000),
        _tx('fatura', TransactionKind.cardPayment, 4500),
        _tx('reserva', TransactionKind.goalDeposit, 10000),
      ];
      expect(resultCents(day), -44580);
    });

    test('cancelled entries do not count', () {
      expect(
        resultCents([
          _tx(
            'x',
            TransactionKind.expense,
            1000,
            status: TransactionStatus.cancelled,
          ),
        ]),
        0,
      );
    });
  });

  group('yearSummary ranking', () {
    Ledger ledger() => Ledger(
      accounts: const [],
      categories: const [],
      tags: const [],
      cards: const [],
      transactions: [
        _tx('nov-despesa', TransactionKind.expense, 38590),
        _tx(
          'dez-parcela',
          TransactionKind.cardPurchase,
          30000,
          date: '2026-12-05',
        ),
      ],
      budgets: const [],
      goals: const [],
      loans: const [],
      prefs: const UserPrefs(),
    );

    test('without a limit a future month can rank (original rule)', () {
      final y = yearSummary(ledger(), 2026);
      expect(y.bestMonth, '2026-12');
      expect(y.worstMonth, '2026-11');
    });

    test(
      'with rankUpTo only months up to it are ranked; totals stay whole',
      () {
        final y = yearSummary(ledger(), 2026, rankUpTo: '2026-11');
        expect(y.bestMonth, '2026-11');
        expect(y.worstMonth, '2026-11');
        expect(y.expenseCents, 68590);
      },
    );
  });

  group('greetingFor', () {
    final l = AppLocalizationsPt();
    test('small hours are evening, not morning', () {
      expect(greetingFor(l, 1), 'Boa noite');
      expect(greetingFor(l, 4), 'Boa noite');
    });
    test('morning, afternoon and evening boundaries', () {
      expect(greetingFor(l, 5), 'Bom dia');
      expect(greetingFor(l, 11), 'Bom dia');
      expect(greetingFor(l, 12), 'Boa tarde');
      expect(greetingFor(l, 17), 'Boa tarde');
      expect(greetingFor(l, 18), 'Boa noite');
      expect(greetingFor(l, 23), 'Boa noite');
    });
  });

  group('texts', () {
    final l = AppLocalizationsPt();
    test('singular and plural', () {
      expect(l.itemsCount(1), '1 item');
      expect(l.itemsCount(2), '2 itens');
      expect(l.recurringLine(1, 'série'), '1 mês · série');
      expect(l.recurringLine(3, 'série'), '3 meses · série');
    });
    test('import report counts are in Portuguese', () {
      expect(importCountLabel(l, 'accounts', 2), '2 contas');
      expect(importCountLabel(l, 'recurrenceRules', 1), '1 série');
      expect(importCountLabel(l, 'shoppingLists', 1), '1 lista de compras');
    });
  });
}
