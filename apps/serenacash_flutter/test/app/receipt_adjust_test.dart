/// Ocorrência 020 (complemento): atualizar a despesa da compra pelo cupom fiscal. Só acontece
/// quando o usuário pede e confirma; o valor anterior fica anotado; lançamentos parcelados,
/// recorrentes ou pagos em parte não são tocados.
library;

import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:serenacash/domain/money/money.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/shopping/shopping.dart';
import 'package:serenacash/features/shopping/receipt_screen.dart';
import 'package:serenacash/features/shopping/session_screen.dart';
import 'package:serenacash/l10n/app_localizations.dart';

import 'harness.dart';
import 'kv_factory.dart';

final _l = lookupAppLocalizations(const Locale('pt'));

void main() {
  setUpAll(loadTestFonts);

  group('020: adjusting an expense from the receipt (controller)', () {
    late AppDatabase db;
    late ProviderContainer c;
    late AppController ctl;
    late Account account;

    setUp(() async {
      db = AppDatabase.inMemory();
      c = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) async => db),
          secretStoreProvider.overrideWithValue(InMemorySecretStore()),
          clockProvider.overrideWithValue(
            FixedClock('2026-11-10T15:00:00.000Z'),
          ),
          idGeneratorProvider.overrideWithValue(SequentialIdGenerator('t')),
          billRemindersProvider.overrideWithValue(const NoopBillReminders()),
        ],
      );
      await c.read(appControllerProvider.future);
      ctl = c.read(appControllerProvider.notifier);
      account = await ctl.saveAccount(
        name: 'Conta',
        type: 'checking',
        openingBalanceCents: 100000,
        openingDate: '2026-10-01',
      );
    });
    tearDown(() async {
      c.dispose();
      await db.close();
    });

    Ledger ledger() => c.read(ledgerProvider);
    Future<Transaction> expense(
      int cents, {
      TransactionStatus status = TransactionStatus.settled,
      String? notes,
    }) async => (await ctl.saveTransaction(
      TransactionInput(
        kind: TransactionKind.expense,
        amountCents: cents,
        date: '2026-11-10',
        accountId: account.id,
        description: 'Compra no mercado',
        status: status,
        dueDate: status == TransactionStatus.planned ? '2026-11-10' : null,
        notes: notes,
      ),
    )).single;

    test('the amount, what was paid and the balance follow the receipt; the old amount stays in the notes', () async {
      final t = await expense(2000, notes: 'feira');
      expect(accountBalance(ledger(), account.id), 98000);
      final ok = await ctl.adjustAmountFromReceipt(
        t.id,
        2413,
        note: 'Valor ajustado pelo cupom. Antes: R\$ 20,00.',
      );
      expect(ok, isTrue);
      final after = ledger().transactionById(t.id)!;
      expect(after.amountCents, 2413);
      expect(effectiveCents(after), 2413);
      expect(after.status, TransactionStatus.settled);
      expect(accountBalance(ledger(), account.id), 97587);
      expect(
        after.notes,
        'feira\nValor ajustado pelo cupom. Antes: R\$ 20,00.',
      );
      // everything else is as it was
      expect(after.description, t.description);
      expect(after.date, t.date);
      expect(after.accountId, t.accountId);
      expect(after.createdAt, t.createdAt);
      // one entry, not two
      expect(ledger().transactions.where(isActive).length, 1);
    });

    test(
      'asking again with the same amount changes nothing and adds no note',
      () async {
        final t = await expense(2413);
        expect(
          await ctl.adjustAmountFromReceipt(t.id, 2413, note: 'x'),
          isTrue,
        );
        expect(ledger().transactionById(t.id)!.notes ?? '', isEmpty);
        expect(ledger().transactionById(t.id)!.updatedAt, t.updatedAt);
      },
    );

    test(
      'what cannot be adjusted is refused and left exactly as it was',
      () async {
        // half paid
        final bill = await expense(5000, status: TransactionStatus.planned);
        await ctl.settleTransaction(bill.id, paidCents: 2000);
        expect(
          await ctl.adjustAmountFromReceipt(bill.id, 6000, note: 'x'),
          isFalse,
        );
        expect(ledger().transactionById(bill.id)!.amountCents, 5000);
        expect(ledger().transactionById(bill.id)!.paidCents, 2000);

        // an instalment of a card purchase
        final card = await ctl.saveCard(
          name: 'azul',
          limitCents: 300000,
          closingDay: 20,
          dueDay: 27,
        );
        final parts = await ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.cardPurchase,
            amountCents: 9000,
            date: '2026-11-10',
            cardId: card.id,
            description: 'parcelado',
            installments: 3,
          ),
        );
        expect(
          await ctl.adjustAmountFromReceipt(parts.first.id, 1, note: 'x'),
          isFalse,
        );
        expect(ledger().transactionById(parts.first.id)!.amountCents, 3000);

        // not an expense, an amount that is not positive, an entry that does not exist
        final income = (await ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.income,
            amountCents: 1000,
            date: '2026-11-10',
            accountId: account.id,
          ),
        )).single;
        expect(
          await ctl.adjustAmountFromReceipt(income.id, 2000, note: 'x'),
          isFalse,
        );
        final t = await expense(2000);
        expect(await ctl.adjustAmountFromReceipt(t.id, 0, note: 'x'), isFalse);
        expect(await ctl.adjustAmountFromReceipt(t.id, -5, note: 'x'), isFalse);
        expect(
          await ctl.adjustAmountFromReceipt('nope', 2000, note: 'x'),
          isFalse,
        );
        expect(ledger().transactionById(t.id)!.amountCents, 2000);

        // a planned bill (nothing paid yet) can follow the receipt, and stays planned
        final planned = await expense(4000, status: TransactionStatus.planned);
        expect(
          await ctl.adjustAmountFromReceipt(planned.id, 4500, note: 'x'),
          isTrue,
        );
        final p = ledger().transactionById(planned.id)!;
        expect(p.amountCents, 4500);
        expect(p.status, TransactionStatus.planned);
        expect(p.paidCents, isNull);
      },
    );
  });

  testWidgets(
    '020: in the app the receipt never changes the expense on its own; the user confirms the amount',
    (tester) async {
      await setPhone(tester);
      final app = TestApp();
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await pumpApp(tester, app);
      await tester.tap(find.text('Compras'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar compra'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'teste');
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(SessionScreen)),
      );
      final ctl = c.read(appControllerProvider.notifier);
      final account = await ctl.saveAccount(
        name: 'Conta',
        type: 'checking',
        openingBalanceCents: 100000,
        openingDate: '2026-10-01',
      );
      // The purchase as it would be after finishing and registering: an expense of R$ 20,88 tied
      // to it, and a receipt whose items add up to R$ 24,13.
      final session = c
          .read(appControllerProvider)
          .requireValue
          .sessions
          .single;
      final tx = (await ctl.saveTransaction(
        TransactionInput(
          kind: TransactionKind.expense,
          amountCents: 2088,
          date: '2026-11-04',
          accountId: account.id,
          description: 'Compra',
          externalRef: 'shopping:${session.id}',
        ),
      )).single;
      final finished = finishSession(
        addToSession(
          session,
          const CartLine(
            id: 'l1',
            name: 'Vela',
            unit: 'un',
            quantity: 1,
            unitPriceCents: 1199,
            priceSource: 'manual',
            checked: true,
          ),
          ctl.nowISO(),
        ),
        ctl.nowISO(),
        ctl.newId,
      ).session;
      await ctl.saveSession(markRegistered(finished, tx.id, ctl.nowISO()));
      final reading = parseReceipt([
        '001 VELA FIAT LUX N7 C/8 1 UN x 14,99 14,99',
        '002 ABACAXI UNIAO 1 UN x 8,99 8,99',
        '003 SACOLA PLASTICA 1 UN x 0,15 0,15',
        'TOTAL 24,13',
      ], newId: ctl.newId);
      await ctl.saveReceiptLines(
        finished.id,
        reconcile(finished.lines, reading.lines).lines,
      );
      await tester.pumpAndSettle();

      // Not awaited: the future of a push only completes when the screen is closed.
      unawaited(
        Navigator.of(
          tester.element(find.byType(SessionScreen)),
          rootNavigator: true,
        ).push(
          MaterialPageRoute<void>(
            builder: (_) => ReceiptScreen(sessionId: finished.id),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReceiptScreen), findsOneWidget);

      // both amounts side by side, and the expense untouched by merely opening the comparison
      expect(find.text(_l.receiptExpenseTitle), findsOneWidget);
      expect(find.text(formatBRL(2413)), findsWidgets);
      expect(find.text(formatBRL(2088)), findsOneWidget);
      expect(c.read(ledgerProvider).transactionById(tx.id)!.amountCents, 2088);

      await tester.tap(find.text(_l.receiptAdjust));
      await tester.pumpAndSettle();
      // cancelling changes nothing
      await tester.tap(find.text(_l.cancel).last);
      await tester.pumpAndSettle();
      expect(c.read(ledgerProvider).transactionById(tx.id)!.amountCents, 2088);

      await tester.tap(find.text(_l.receiptAdjust));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_l.receiptAdjustConfirm));
      await tester.pumpAndSettle();
      final after = c.read(ledgerProvider).transactionById(tx.id)!;
      expect(after.amountCents, 2413);
      expect(after.notes, contains(formatBRL(2088)));
      expect(find.text(_l.receiptExpenseSame), findsOneWidget);
      expect(find.text(_l.receiptAdjust), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
