/// Financial invariants, exercised through the real controller and repositories on an in-memory
/// database with seeded random data: whatever the sequence of operations, the money has to add up.
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
import 'package:serenacash/domain/availability/availability.dart';
import 'package:serenacash/domain/cards/cards.dart';
import 'package:serenacash/domain/dates/dates.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/ledger/ledger.dart';
import 'package:serenacash/domain/money/money.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/shopping/shopping.dart';

class _World {
  _World({String now = '2026-11-05T12:00:00.000Z'})
    : db = AppDatabase.inMemory(),
      clock = FixedClock(now) {
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

  Future<Account> account(String name, int opening) => ctl.saveAccount(
    name: name,
    type: 'checking',
    openingBalanceCents: opening,
    openingDate: addDays(today, -60),
  );

  Future<Transaction> entry(
    TransactionKind kind,
    int cents, {
    String? account,
    String? toAccount,
    String? card,
    String? date,
    TransactionStatus? status,
    int? installments,
    String? refundOf,
    String? recurrence,
    String? externalRef,
    String description = 'x',
  }) async => (await ctl.saveTransaction(
    TransactionInput(
      kind: kind,
      amountCents: cents,
      date: date ?? today,
      description: description,
      accountId: account,
      toAccountId: toAccount,
      cardId: card,
      status: status,
      dueDate: status == TransactionStatus.planned ? (date ?? today) : null,
      installments: installments,
      refundOfId: refundOf,
      recurrenceFrequency: recurrence,
      externalRef: externalRef,
    ),
  )).first;

  Future<void> dispose() async {
    container.dispose();
    await db.close();
  }
}

Future<void> _withWorld(Future<void> Function(_World w) body) async {
  final w = _World();
  await w.boot();
  try {
    await body(w);
  } finally {
    await w.dispose();
  }
}

void main() {
  test(
    '1. money keeps exact precision: sums, allocations and BRL text round-trip',
    () {
      final rng = Random(20261105);
      for (var i = 0; i < 2000; i++) {
        final total = rng.nextInt(2000000000) - 1000000000;
        final parts = 1 + rng.nextInt(36);
        final shares = allocate(total.abs(), parts);
        expect(
          sumCents(shares),
          total.abs(),
          reason: 'allocate($total, $parts)',
        );
        // No share differs from another by more than one cent.
        expect(shares.reduce(max) - shares.reduce(min), lessThanOrEqualTo(1));
        expect(parseMoneyBR(formatBRL(total)), total, reason: formatBRL(total));
      }
      // 0,1 + 0,2 is the classic float trap: in cents it is exactly 30.
      expect(addCents(cents(0.1), cents(0.2)), 30);
      expect(() => assertCents(10.5), throwsA(isA<MoneyError>()));
      expect(() => assertCents(double.nan), throwsA(isA<MoneyError>()));
      expect(() => assertCents(double.infinity), throwsA(isA<MoneyError>()));
      // Large amounts stay exact (R$ 90 trilhões in cents is still a safe integer).
      expect(addCents(9000000000000000, 1), 9000000000000001);
    },
  );

  test('2. transfers move money between accounts and create neither income nor expense', () async {
    await _withWorld((w) async {
      final a = await w.account('A', 500000);
      final b = await w.account('B', 100000);
      final rng = Random(2);
      final month = monthKeyOf(w.today);
      final before = consolidatedBalance(w.ledger);
      final totalsBefore = monthTotals(w.ledger, month);
      var expectA = 500000, expectB = 100000;
      for (var i = 0; i < 40; i++) {
        final cents = 1 + rng.nextInt(50000);
        final forward = rng.nextBool();
        await w.entry(
          TransactionKind.transfer,
          cents,
          account: forward ? a.id : b.id,
          toAccount: forward ? b.id : a.id,
        );
        expectA += forward ? -cents : cents;
        expectB += forward ? cents : -cents;
      }
      expect(accountBalance(w.ledger, a.id), expectA);
      expect(accountBalance(w.ledger, b.id), expectB);
      expect(consolidatedBalance(w.ledger), before);
      final totals = monthTotals(w.ledger, month);
      expect(totals.incomeSettled, totalsBefore.incomeSettled);
      expect(totals.expenseSettled, totalsBefore.expenseSettled);
      expect(totals.net, totalsBefore.net);
    });
  });

  test('3. paying an invoice takes the money out once and never counts the purchases again', () async {
    await _withWorld((w) async {
      final a = await w.account('A', 1000000);
      final card = await w.ctl.saveCard(
        name: 'Cartão',
        limitCents: 800000,
        closingDay: 20,
        dueDay: 27,
      );
      final month = monthKeyOf(w.today);
      await w.entry(TransactionKind.cardPurchase, 35000, card: card.id);
      await w.entry(TransactionKind.cardPurchase, 15000, card: card.id);
      // The purchase is the expense; the account is untouched until the invoice is paid.
      expect(accountBalance(w.ledger, a.id), 1000000);
      expect(monthTotals(w.ledger, month).cardPurchases, 50000);
      // Spending is counted when the purchase is made (that is what the month totals show).
      final spentBeforePaying = monthTotals(w.ledger, month).expenseSettled;
      expect(spentBeforePaying, 50000);
      final invMonth = currentInvoiceMonth(card, w.today);
      expect(invoice(w.ledger, card, invMonth, w.today).totalCents, 50000);

      await w.ctl.payInvoice(
        cardId: card.id,
        invoiceMonth: invMonth,
        amountCents: 50000,
        accountId: a.id,
        date: w.today,
        description: 'Fatura',
      );
      expect(accountBalance(w.ledger, a.id), 950000);
      final t = monthTotals(w.ledger, month);
      expect(t.cardPurchases, 50000);
      // The payment is not a second expense: the month's spending is what it was.
      expect(t.expenseSettled, spentBeforePaying);
      expect(t.net, -50000);
      final inv = invoice(w.ledger, card, invMonth, w.today);
      expect(inv.totalCents, 50000);
      expect(inv.paidCents, 50000);
      expect(inv.remainingCents, 0);
    });
  });

  test('4. installments always add up to the purchase, cent by cent', () async {
    await _withWorld((w) async {
      await w.account('A', 0);
      final card = await w.ctl.saveCard(
        name: 'Cartão',
        limitCents: 5000000,
        closingDay: 20,
        dueDay: 27,
      );
      final rng = Random(4);
      for (var i = 0; i < 25; i++) {
        final n = 2 + rng.nextInt(23);
        final total = 1 + rng.nextInt(999999);
        final first = await w.entry(
          TransactionKind.cardPurchase,
          total,
          card: card.id,
          installments: n,
          description: 'compra $i',
        );
        final series = w.ledger.transactions
            .where((t) => t.installment?.groupId == first.installment?.groupId)
            .toList();
        if (total < n) {
          // Fewer cents than installments cannot be split; whatever was stored still adds up.
          expect(sumCents(series.map((t) => t.amountCents)), total);
          continue;
        }
        expect(series, hasLength(n), reason: '$total em $n');
        expect(sumCents(series.map((t) => t.amountCents)), total);
        final amounts = series.map((t) => t.amountCents);
        expect(amounts.reduce(max) - amounts.reduce(min), lessThanOrEqualTo(1));
        expect(series.map((t) => t.installment!.number).toSet(), {
          for (var k = 1; k <= n; k++) k,
        });
      }
    });
  });

  test(
    '5. a refund lowers the invoice by its amount and nothing else',
    () async {
      await _withWorld((w) async {
        final a = await w.account('A', 300000);
        final card = await w.ctl.saveCard(
          name: 'Cartão',
          limitCents: 800000,
          closingDay: 20,
          dueDay: 27,
        );
        final buy = await w.entry(
          TransactionKind.cardPurchase,
          42990,
          card: card.id,
        );
        final invMonth = currentInvoiceMonth(card, w.today);
        await w.entry(
          TransactionKind.cardRefund,
          12990,
          card: card.id,
          refundOf: buy.id,
        );
        expect(invoice(w.ledger, card, invMonth, w.today).totalCents, 30000);
        expect(accountBalance(w.ledger, a.id), 300000);
        // A refund larger than what is left of the purchase is refused.
        await expectLater(
          w.entry(
            TransactionKind.cardRefund,
            30001,
            card: card.id,
            refundOf: buy.id,
          ),
          throwsA(anything),
        );
        expect(invoice(w.ledger, card, invMonth, w.today).totalCents, 30000);
      });
    },
  );

  test('6. expected income changes no balance until it is received', () async {
    await _withWorld((w) async {
      final a = await w.account('A', 100000);
      final salary = await w.entry(
        TransactionKind.income,
        820000,
        account: a.id,
        status: TransactionStatus.planned,
        date: addDays(w.today, 3),
      );
      expect(accountBalance(w.ledger, a.id), 100000);
      expect(consolidatedBalance(w.ledger), 100000);
      expect(monthTotals(w.ledger, monthKeyOf(w.today)).incomeSettled, 0);
      // By default expected income does not enter "pode gastar" either.
      final av = availability(w.ledger, today: w.today);
      expect(av.availableCents, 100000);

      await w.ctl.settleTransaction(salary.id);
      expect(accountBalance(w.ledger, a.id), 920000);
    });
  });

  test(
    '7. partial payments keep the pending amount exact, whatever the order',
    () async {
      await _withWorld((w) async {
        final a = await w.account('A', 1000000);
        final rng = Random(7);
        for (var i = 0; i < 15; i++) {
          final total = 1000 + rng.nextInt(200000);
          final bill = await w.entry(
            TransactionKind.expense,
            total,
            account: a.id,
            status: TransactionStatus.planned,
            description: 'conta $i',
          );
          final before = accountBalance(w.ledger, a.id);
          var paid = 0;
          while (paid < total) {
            final part = min(total - paid, 1 + rng.nextInt(total));
            await w.ctl.settleTransaction(bill.id, paidCents: part);
            paid += part;
            final now = w.ledger.transactionById(bill.id)!;
            expect(pendingCents(now), total - paid);
            expect(accountBalance(w.ledger, a.id), before - paid);
          }
          final done = w.ledger.transactionById(bill.id)!;
          expect(done.status, TransactionStatus.settled);
          expect(pendingCents(done), 0);
          // Paying again a bill already settled must not take more money.
          await w.ctl.settleTransaction(bill.id, paidCents: 500);
          expect(accountBalance(w.ledger, a.id), before - total);
        }
      });
    },
  );

  test(
    '8. saving the same entry again updates it instead of duplicating',
    () async {
      await _withWorld((w) async {
        final a = await w.account('A', 100000);
        final t = await w.entry(TransactionKind.expense, 4590, account: a.id);
        for (var i = 0; i < 5; i++) {
          await w.ctl.saveTransaction(
            TransactionInput(
              id: t.id,
              kind: TransactionKind.expense,
              amountCents: 4590,
              date: w.today,
              description: 'x',
              accountId: a.id,
            ),
          );
        }
        expect(w.ledger.transactions, hasLength(1));
        expect(accountBalance(w.ledger, a.id), 100000 - 4590);
        // The same external reference (a finished shopping session, an import) is applied once.
        await w.entry(
          TransactionKind.expense,
          10000,
          account: a.id,
          externalRef: 'shopping:s1',
        );
        await w.entry(
          TransactionKind.expense,
          10000,
          account: a.id,
          externalRef: 'shopping:s1',
        );
        expect(
          w.ledger.transactions.where((x) => x.externalRef == 'shopping:s1'),
          hasLength(1),
        );
        expect(accountBalance(w.ledger, a.id), 100000 - 4590 - 10000);
      });
    },
  );

  test('9. a batch that fails in the middle leaves nothing written', () async {
    await _withWorld((w) async {
      final a = await w.account('A', 100000);
      final repo = await w.container.read(ledgerRepositoryProvider.future);
      final good = await w.entry(TransactionKind.expense, 1000, account: a.id);
      final countBefore = w.ledger.transactions.length;
      Transaction clone(String id, {String? account}) => Transaction.fromJson({
        ...good.toJson(),
        'id': id,
        'accountId': account ?? a.id,
      });
      // The third row points at an account that does not exist: the foreign key rejects it.
      await expectLater(
        repo.upsertTransactions([
          clone('batch-1'),
          clone('batch-2'),
          clone('batch-3', account: 'conta-inexistente'),
        ]),
        throwsA(anything),
      );
      await w.ctl.reload();
      expect(w.ledger.transactions, hasLength(countBefore));
      expect(w.ledger.transactionById('batch-1'), isNull);
      expect(accountBalance(w.ledger, a.id), 99000);
      expect(await w.db.integrityCheck(), isEmpty);
    });
  });

  test(
    '10. exporting and restoring a backup changes no balance and no total',
    () async {
      await _withWorld((w) async {
        final a = await w.account('A', 548050);
        final b = await w.account('B', 20000);
        final card = await w.ctl.saveCard(
          name: 'Cartão',
          limitCents: 500000,
          closingDay: 20,
          dueDay: 27,
        );
        final rng = Random(10);
        for (var i = 0; i < 60; i++) {
          final cents = 1 + rng.nextInt(90000);
          switch (rng.nextInt(5)) {
            case 0:
              await w.entry(TransactionKind.income, cents, account: a.id);
            case 1:
              await w.entry(TransactionKind.expense, cents, account: a.id);
            case 2:
              await w.entry(
                TransactionKind.transfer,
                cents,
                account: a.id,
                toAccount: b.id,
              );
            case 3:
              await w.entry(
                TransactionKind.cardPurchase,
                cents,
                card: card.id,
                installments: 1 + rng.nextInt(6),
              );
            default:
              await w.entry(
                TransactionKind.expense,
                cents,
                account: b.id,
                status: TransactionStatus.planned,
                date: addDays(w.today, rng.nextInt(20)),
              );
          }
        }
        final month = monthKeyOf(w.today);
        Map<String, Object> picture() => {
          'a': accountBalance(w.ledger, a.id),
          'b': accountBalance(w.ledger, b.id),
          'total': consolidatedBalance(w.ledger),
          'month': monthTotals(w.ledger, month).toJson().toString(),
          'available': availability(w.ledger, today: w.today).availableCents,
          'count': w.ledger.transactions.length,
          'invoice': invoice(
            w.ledger,
            card,
            currentInvoiceMonth(card, w.today),
            w.today,
          ).totalCents,
        };
        final before = picture();
        final backup = await w.container.read(backupServiceProvider.future);
        final text = await backup.exportEncrypted('frase de teste longa');
        // Something changes after the backup, then the backup is restored over it.
        await w.entry(TransactionKind.expense, 12345, account: a.id);
        expect(picture(), isNot(before));
        final report = await backup.importFromText(
          text,
          passphrase: 'frase de teste longa',
        );
        expect(report.ok, isTrue);
        await w.ctl.reload();
        expect(picture(), before);
        expect(await w.db.integrityCheck(), isEmpty);
      });
    },
  );

  test(
    '11. deleting and undoing puts every amount and link back where it was',
    () async {
      await _withWorld((w) async {
        final a = await w.account('A', 400000);
        final b = await w.account('B', 0);
        final bill = await w.entry(
          TransactionKind.expense,
          120000,
          account: a.id,
          status: TransactionStatus.planned,
          recurrence: 'monthly',
          description: 'Aluguel',
        );
        final transfer = await w.entry(
          TransactionKind.transfer,
          50000,
          account: a.id,
          toAccount: b.id,
        );
        String snapshot() =>
            (w.ledger.transactions.map((t) => t.toJson().toString()).toList()
                  ..sort())
                .join('|');
        final before = snapshot();
        final balances = (
          accountBalance(w.ledger, a.id),
          accountBalance(w.ledger, b.id),
        );

        await w.ctl.deleteTransaction(
          bill.id,
          series: true,
          undoLabel: (n) => '$n',
        );
        expect(
          w.ledger.transactions.where((t) => t.description == 'Aluguel'),
          isEmpty,
        );
        await w.container.read(appControllerProvider).requireValue.undo!.run();
        await w.ctl.reload();
        await w.ctl.deleteTransaction(transfer.id, undoLabel: (n) => '$n');
        expect(accountBalance(w.ledger, b.id), 0);
        expect(accountBalance(w.ledger, a.id), 400000);
        await w.container.read(appControllerProvider).requireValue.undo!.run();
        await w.ctl.reload();

        expect((
          accountBalance(w.ledger, a.id),
          accountBalance(w.ledger, b.id),
        ), balances);
        // Same entries, same fields except the update stamps the repository rewrites.
        String strip(String s) =>
            s.replaceAll(RegExp(r'updatedAt: [^,}]+'), 'updatedAt: _');
        expect(strip(snapshot()), strip(before));
        expect(await w.db.integrityCheck(), isEmpty);
      });
    },
  );

  test(
    '12. goods sold by weight round to the cent, half up, and the cart adds up',
    () {
      final rng = Random(12);
      for (var i = 0; i < 1000; i++) {
        final pricePerKg = 1 + rng.nextInt(20000);
        final grams = 1 + rng.nextInt(5000);
        final line = CartLine(
          id: 'l$i',
          name: 'item',
          quantity: grams / 1000,
          unit: 'kg',
          unitPriceCents: pricePerKg,
          priceSource: 'manual',
          checked: true,
        );
        final exact = pricePerKg * grams / 1000;
        final expected = (exact + 0.5).floor();
        expect(
          lineTotal(line).netCents,
          expected,
          reason: '$pricePerKg c/kg × $grams g',
        );
      }
      final lines = [
        for (var i = 0; i < 40; i++)
          CartLine(
            id: 'c$i',
            name: 'item',
            quantity: (1 + rng.nextInt(3000)) / 1000,
            unit: 'kg',
            unitPriceCents: 1 + rng.nextInt(9000),
            priceSource: 'manual',
            checked: true,
          ),
      ];
      expect(
        cartTotals(lines, null).totalCents,
        sumCents(lines.map((l) => lineTotal(l).netCents)),
      );
    },
  );

  test(
    '13. "pode gastar" is the sum of the lines it shows, every time',
    () async {
      await _withWorld((w) async {
        final a = await w.account('A', 548050);
        final card = await w.ctl.saveCard(
          name: 'Cartão',
          limitCents: 500000,
          closingDay: 20,
          dueDay: 27,
        );
        final rng = Random(13);
        for (var i = 0; i < 50; i++) {
          final cents = 1 + rng.nextInt(60000);
          switch (rng.nextInt(4)) {
            case 0:
              await w.entry(
                TransactionKind.expense,
                cents,
                account: a.id,
                status: TransactionStatus.planned,
                date: addDays(w.today, rng.nextInt(40) - 10),
              );
            case 1:
              await w.entry(TransactionKind.cardPurchase, cents, card: card.id);
            case 2:
              await w.entry(TransactionKind.expense, cents, account: a.id);
            default:
              await w.entry(
                TransactionKind.income,
                cents,
                account: a.id,
                status: TransactionStatus.planned,
                date: addDays(w.today, rng.nextInt(20)),
              );
          }
          final av = availability(w.ledger, today: w.today);
          final fromLines = av.lines.fold<int>(
            0,
            (s, l) => s + l.sign * l.cents,
          );
          expect(av.availableCents, fromLines, reason: 'after step $i');
          // Reproducible: the same ledger and day give the same answer.
          expect(
            availability(w.ledger, today: w.today).availableCents,
            av.availableCents,
          );
        }
      });
    },
  );

  test('14. every card purchase lands in exactly one invoice, across month ends and leap days', () {
    final rng = Random(14);
    for (final closing in [1, 5, 15, 28, 29, 30, 31]) {
      for (final due in [1, 10, 27, 31]) {
        final card = CreditCard(
          id: 'c',
          name: 'Cartão',
          limitCents: 100000000,
          closingDay: closing,
          dueDay: due,
          color: '#0B5563',
          archived: false,
          currency: 'BRL',
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
        );
        final purchases = <Transaction>[];
        var day = '2027-12-25';
        // Two years of days, through February 2028 (leap) and every month length.
        for (var i = 0; i < 760; i++) {
          day = addDays(day, 1);
          if (rng.nextInt(3) != 0) continue;
          purchases.add(
            Transaction(
              id: 'p$i',
              kind: TransactionKind.cardPurchase,
              status: TransactionStatus.settled,
              amountCents: 1 + rng.nextInt(50000),
              currency: 'BRL',
              date: day,
              description: 'p',
              cardId: 'c',
              tags: const [],
              attachments: const [],
              createdAt: '2026-01-01T00:00:00Z',
              updatedAt: '2026-01-01T00:00:00Z',
            ),
          );
        }
        final ledger = Ledger(cards: [card], transactions: purchases);
        final months = invoiceMonths(ledger, card);
        final total = sumCents(
          months.map((m) => invoice(ledger, card, m, '2030-01-01').totalCents),
        );
        expect(
          total,
          sumCents(purchases.map((t) => t.amountCents)),
          reason: 'fechamento $closing, vencimento $due',
        );
        for (final m in months) {
          final inv = invoice(ledger, card, m, '2030-01-01');
          // The due date never comes before the closing date of the same invoice.
          expect(
            compareISO(inv.dueDate, inv.closingDate) >= 0,
            isTrue,
            reason: 'fatura $m: fecha ${inv.closingDate}, vence ${inv.dueDate}',
          );
        }
        for (final t in purchases) {
          final m = purchaseInvoiceMonth(card, t);
          // Never in an invoice that closed before the purchase was made.
          expect(
            compareISO(invoiceClosingDate(closing, m), t.date) >= 0,
            isTrue,
            reason: 'compra ${t.date} na fatura $m (fecha dia $closing)',
          );
        }
      }
    }
  });

  test('15. a finished shopping session becomes one expense, however many times it is confirmed', () async {
    await _withWorld((w) async {
      final a = await w.account('A', 100000);
      var session = startSession(
        's1',
        '2026-11-05T12:00:00.000Z',
        budgetCents: 30000,
      );
      session = addToSession(
        session,
        const CartLine(
          id: 'l1',
          name: 'Arroz',
          quantity: 2,
          unit: 'un',
          unitPriceCents: 2590,
          priceSource: 'manual',
          checked: true,
        ),
        '2026-11-05T12:01:00.000Z',
      );
      session = addToSession(
        session,
        const CartLine(
          id: 'l2',
          name: 'Tomate',
          quantity: 0.735,
          unit: 'kg',
          unitPriceCents: 899,
          priceSource: 'manual',
          checked: true,
        ),
        '2026-11-05T12:02:00.000Z',
      );
      var n = 0;
      final r = finishSession(
        session,
        '2026-11-05T12:10:00.000Z',
        () => 'o${n++}',
      );
      final st = r.suggestedTransaction!;
      expect(st.amountCents, sessionTotals(session).totalCents);
      expect(st.amountCents, 2 * 2590 + 661);
      for (var i = 0; i < 4; i++) {
        await w.entry(
          TransactionKind.expense,
          st.amountCents,
          account: a.id,
          description: st.description,
          externalRef: st.externalRef,
        );
      }
      expect(
        w.ledger.transactions.where((t) => t.externalRef == st.externalRef),
        hasLength(1),
      );
      expect(accountBalance(w.ledger, a.id), 100000 - st.amountCents);
      // Finishing the same session again describes the same expense, with the same reference.
      final again = finishSession(
        r.session,
        '2026-11-05T12:11:00.000Z',
        () => 'x${n++}',
      );
      expect(
        again.suggestedTransaction?.externalRef ?? st.externalRef,
        st.externalRef,
      );
    });
  });

  test('invalid input is refused before it reaches the database', () async {
    await _withWorld((w) async {
      final a = await w.account('A', 100000);
      Future<void> refused(Future<Object?> Function() op, String why) async {
        await expectLater(op(), throwsA(anything), reason: why);
      }

      await refused(
        () => w.entry(TransactionKind.expense, 0, account: a.id),
        'valor zero',
      );
      await refused(
        () => w.entry(TransactionKind.expense, -500, account: a.id),
        'valor negativo',
      );
      await refused(
        () => w.entry(
          TransactionKind.transfer,
          1000,
          account: a.id,
          toAccount: a.id,
        ),
        'transferência para a mesma conta',
      );
      await refused(
        () => w.entry(TransactionKind.cardPurchase, 1000),
        'compra no cartão sem cartão',
      );
      await refused(
        () => w.entry(TransactionKind.expense, 1000),
        'despesa sem conta',
      );
      await refused(
        () => w.entry(
          TransactionKind.expense,
          1000,
          account: a.id,
          date: '2026-02-30',
        ),
        'data que não existe',
      );
      expect(w.ledger.transactions, isEmpty);
      expect(accountBalance(w.ledger, a.id), 100000);
      // A very large amount is stored and summed exactly.
      await w.entry(TransactionKind.income, 99999999999, account: a.id);
      expect(accountBalance(w.ledger, a.id), 100000 + 99999999999);
    });
  });
}
