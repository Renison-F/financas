/// Ocorrências 029 a 031 (complemento) e lembretes: filtros por categoria e por conta, comparações
/// entre períodos iguais, simulação de limite, limite por categoria e por dia da semana, meta de
/// economia ligada a uma reserva, aviso de limite ultrapassado e lembretes sem duplicidade.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/app/router.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/state/app_state.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/notifications/bill_reminders.dart';
import 'package:serenacash/data/security/secret_store.dart';
import 'package:serenacash/domain/daily/daily.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/money/money.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/reminders/reminders.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/l10n/app_localizations.dart';

import 'harness.dart';
import 'kv_factory.dart';

final _l = lookupAppLocalizations(const Locale('pt'));

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
  late Account account, second;
  late CreditCard card;
  late Category food, transport;
  late Goal trip, reserve;

  AppController get ctl => container.read(appControllerProvider.notifier);
  Ledger get ledger => container.read(ledgerProvider);
  String get today => container.read(todayProvider);

  Future<void> boot() async {
    await container.read(appControllerProvider.future);
    account = await ctl.saveAccount(
      name: 'corrente',
      type: 'checking',
      openingBalanceCents: 100000,
      openingDate: '2026-09-01',
    );
    second = await ctl.saveAccount(
      name: 'carteira',
      type: 'cash',
      openingBalanceCents: 20000,
      openingDate: '2026-09-01',
    );
    card = await ctl.saveCard(
      name: 'azul',
      limitCents: 300000,
      closingDay: 20,
      dueDay: 27,
    );
    food = await ctl.saveCategory(name: 'Comida teste', kind: 'expense');
    transport = await ctl.saveCategory(
      name: 'Transporte teste',
      kind: 'expense',
    );
    trip = await ctl.saveGoal(name: 'Viagem', targetCents: 500000);
    reserve = await ctl.saveGoal(name: 'Reserva', targetCents: 900000);
  }

  Future<void> add(
    TransactionKind kind,
    int cents,
    String date, {
    TransactionStatus status = TransactionStatus.settled,
    String? categoryId,
    String? accountId,
    String? goalId,
    String description = 'x',
  }) => ctl.saveTransaction(
    TransactionInput(
      kind: kind,
      amountCents: cents,
      date: date,
      description: description,
      categoryId: categoryId,
      accountId: kind == TransactionKind.cardPurchase
          ? null
          : (accountId ?? account.id),
      cardId: kind == TransactionKind.cardPurchase ? card.id : null,
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
  setUpAll(loadTestFonts);

  group('029: filters and comparisons', () {
    test('spending by category counts the category and its subcategories, to the cent', () {
      return _with('2026-11-10T15:00:00.000Z', (w) async {
        final lunch = await w.ctl.saveCategory(
          name: 'Almoço teste',
          kind: 'expense',
          parentId: w.food.id,
        );
        await w.add(
          TransactionKind.expense,
          3000,
          '2026-11-10',
          categoryId: w.food.id,
        );
        await w.add(
          TransactionKind.expense,
          1250,
          '2026-11-10',
          categoryId: lunch.id,
        );
        await w.add(
          TransactionKind.cardPurchase,
          999,
          '2026-11-09',
          categoryId: w.food.id,
        );
        await w.add(
          TransactionKind.expense,
          4000,
          '2026-11-10',
          categoryId: w.transport.id,
        );
        await w.add(TransactionKind.income, 50000, '2026-11-10');

        final all = dailySummary(w.ledger, w.today);
        final food = dailySummary(w.ledger, w.today, categoryId: w.food.id);
        final transport = dailySummary(
          w.ledger,
          w.today,
          categoryId: w.transport.id,
        );
        expect(all.spentTodayCents, 8250);
        expect(food.spentTodayCents, 4250, reason: 'categoria + subcategoria');
        expect(
          food.spentYesterdayCents,
          999,
          reason: 'compra no cartão conta no dia',
        );
        expect(food.spentMonthCents, 5249);
        expect(transport.spentMonthCents, 4000);
        expect(
          food.spentMonthCents + transport.spentMonthCents,
          all.spentMonthCents,
          reason: 'as partes somam o todo',
        );
        // income and balances do not belong to a category: they stay whole
        expect(food.receivedTodayCents, all.receivedTodayCents);
        expect(food.balanceTodayCents, all.balanceTodayCents);
        expect(food.daysWithSpending, 2);
      });
    });

    test('the flow of one account is that account: its balance, and no card purchase', () {
      return _with('2026-11-10T15:00:00.000Z', (w) async {
        await w.add(TransactionKind.expense, 5000, '2026-11-05');
        await w.add(
          TransactionKind.expense,
          700,
          '2026-11-05',
          accountId: w.second.id,
        );
        await w.add(TransactionKind.cardPurchase, 9000, '2026-11-05');
        await w.add(
          TransactionKind.expense,
          1000,
          '2026-11-20',
          accountId: w.second.id,
          status: TransactionStatus.planned,
        );
        final wallet = dailyFlow(
          w.ledger,
          '2026-11',
          w.today,
          accountId: w.second.id,
        );
        DayFlow on(List<DayFlow> f, String d) =>
            f.firstWhere((x) => x.date == d);
        expect(on(wallet, '2026-11-05').expenseCents, 700);
        expect(on(wallet, '2026-11-05').balanceCents, 19300);
        expect(on(wallet, '2026-11-10').balanceCents, 19300);
        expect(on(wallet, '2026-11-20').projectedBalanceCents, 18300);
        final everything = dailyFlow(w.ledger, '2026-11', w.today);
        expect(on(everything, '2026-11-05').expenseCents, 14700);
        expect(on(everything, '2026-11-05').balanceCents, 114300);
      });
    });

    test('comparisons use periods of the same length and say when there is no record', () {
      return _with('2026-11-20T15:00:00.000Z', (w) async {
        // nothing recorded: a week ago there is no data, which is not the same as zero
        var t = dailyTrend(w.ledger, w.today);
        expect(t.last7Cents, 0);
        expect(t.previous7Cents, isNull);
        expect(t.sameWeekdayLastWeekCents, isNull);

        await w.add(TransactionKind.expense, 1000, '2026-11-01');
        await w.add(TransactionKind.expense, 2000, '2026-11-08');
        await w.add(TransactionKind.expense, 3000, '2026-11-13');
        await w.add(TransactionKind.expense, 4000, '2026-11-14');
        await w.add(TransactionKind.expense, 5000, '2026-11-20');
        t = dailyTrend(w.ledger, w.today);
        expect(t.last7Cents, 9000, reason: '14 a 20/11');
        expect(t.previous7Cents, 5000, reason: '07 a 13/11');
        expect(t.sameWeekdayLastWeekCents, 3000, reason: '13/11');
        expect(t.daysRemaining, 10);
        // 15.000 in 20 days = 750 a day; 10 days more = 7.500
        expect(t.monthAtCurrentPaceCents, 22500);
      });
    });
  });

  group('031: limits by category and weekday, simulation and alerts', () {
    test('a limit of a category looks only at that category; the general one at everything', () {
      return _with('2026-11-10T15:00:00.000Z', (w) async {
        await w.ctl.setDailyTarget(
          kind: DailyTarget.spendLimit,
          amountCents: 10000,
        );
        await w.ctl.setDailyTarget(
          kind: DailyTarget.spendLimit,
          amountCents: 3000,
          categoryId: w.food.id,
        );
        await w.add(
          TransactionKind.expense,
          3500,
          '2026-11-10',
          categoryId: w.food.id,
        );
        await w.add(
          TransactionKind.expense,
          2000,
          '2026-11-10',
          categoryId: w.transport.id,
        );
        final targets = w.ctl.dailyTargets;
        final general = spendLimitHistory(w.ledger, targets, w.today).single;
        final food = spendLimitHistory(
          w.ledger,
          targets,
          w.today,
          categoryId: w.food.id,
        ).single;
        expect(general.spentCents, 5500);
        expect(general.within, isTrue);
        expect(food.spentCents, 3500);
        expect(food.within, isFalse);
        expect(limitedCategories(targets), [w.food.id]);

        final alerts = limitAlerts(w.ledger, targets, w.today);
        expect(alerts.length, 1, reason: 'só o limite ultrapassado avisa');
        expect(alerts.single.target.categoryId, w.food.id);
        expect(alerts.single.overCents, 500);

        // ending the category limit keeps the general one and silences the alert
        await w.ctl.endDailyTarget(
          DailyTarget.spendLimit,
          categoryId: w.food.id,
        );
        expect(limitAlerts(w.ledger, w.ctl.dailyTargets, w.today), isEmpty);
        expect(
          targetSetOn(w.ctl.dailyTargets, DailyTarget.spendLimit, w.today),
          isNotNull,
        );
      });
    });

    test('a limit for chosen weekdays applies only on them', () {
      // 10/11/2026 is a Tuesday
      return _with('2026-11-10T15:00:00.000Z', (w) async {
        await w.ctl.setDailyTarget(
          kind: DailyTarget.spendLimit,
          amountCents: 5000,
          weekdays: [6, 7],
        );
        await w.add(TransactionKind.expense, 9000, '2026-11-10');
        final targets = w.ctl.dailyTargets;
        expect(targets.single.weekdays, [6, 7]);
        expect(
          targetOn(targets, DailyTarget.spendLimit, w.today),
          isNull,
          reason: 'terça-feira: não se aplica',
        );
        expect(
          targetSetOn(targets, DailyTarget.spendLimit, w.today),
          isNotNull,
          reason: 'mas o limite existe',
        );
        expect(limitAlerts(w.ledger, targets, w.today), isEmpty);
        expect(spendLimitHistory(w.ledger, targets, w.today), isEmpty);
        expect(targetAppliesOn(targets.single, '2026-11-14'), isTrue);
        expect(targetAppliesOn(targets.single, '2026-11-15'), isTrue);
        expect(targetAppliesOn(targets.single, '2026-11-16'), isFalse);
      });
    });

    test('simulation: a value tried against the days already lived, without changing anything', () {
      return _with('2026-11-10T15:00:00.000Z', (w) async {
        await w.add(TransactionKind.expense, 12000, '2026-11-03');
        await w.add(TransactionKind.expense, 4000, '2026-11-07');
        await w.add(TransactionKind.expense, 10000, '2026-11-10');
        final before = w.ctl.dailyTargets.length;
        final sim = simulateLimit(w.ledger, 10000, w.today);
        expect(sim.daysInMonth, 30);
        expect(sim.monthTotalCents, 300000);
        expect(sim.daysChecked, 10);
        expect(
          sim.daysWithin,
          9,
          reason: 'só 03/11 passou; o limite exato conta como dentro',
        );
        // weekends only: November 2026 has 5 Saturdays and 5 Sundays; up to the 10th, 01, 07 and 08
        final weekend = simulateLimit(
          w.ledger,
          3000,
          w.today,
          weekdays: [6, 7],
        );
        expect(weekend.daysInMonth, 9);
        expect(weekend.daysChecked, 3);
        expect(weekend.daysWithin, 2, reason: '07/11 gastou 40,00');
        expect(w.ctl.dailyTargets.length, before);
      });
    });

    test(
      'a saving target tied to a goal counts only what went into that goal',
      () {
        return _with('2026-11-10T15:00:00.000Z', (w) async {
          await w.ctl.setDailyTarget(
            kind: DailyTarget.saving,
            amountCents: 2000,
            goalId: w.trip.id,
          );
          await w.add(
            TransactionKind.goalDeposit,
            1500,
            '2026-11-10',
            goalId: w.reserve.id,
          );
          var day = savingHistory(w.ledger, w.ctl.dailyTargets, w.today).single;
          expect(day.confirmedCents, 0, reason: 'foi para outra meta');
          expect(day.pendingCents, 2000);
          await w.add(
            TransactionKind.goalDeposit,
            1500,
            '2026-11-10',
            goalId: w.trip.id,
          );
          day = savingHistory(w.ledger, w.ctl.dailyTargets, w.today).single;
          expect(day.confirmedCents, 1500);
          expect(day.pendingCents, 500);
          // spending nothing all day still saves nothing
          expect(savedOn(w.ledger, '2026-11-09', goalId: w.trip.id), 0);
          // the tie survives being stored
          final back = DailyTarget.fromJson(w.ctl.dailyTargets.single.toJson());
          expect(back.goalId, w.trip.id);
        });
      },
    );
  });

  group('reminders: one notice per commitment', () {
    test('the plan, kind by kind', () {
      return _with('2026-11-10T15:00:00.000Z', (w) async {
        await w.add(
          TransactionKind.expense,
          8000,
          '2026-11-12',
          status: TransactionStatus.planned,
          description: 'Luz',
        );
        await w.add(
          TransactionKind.income,
          250000,
          '2026-11-11',
          status: TransactionStatus.planned,
          description: 'Salário',
        );
        await w.add(
          TransactionKind.expense,
          5000,
          '2026-12-20',
          status: TransactionStatus.planned,
          description: 'Longe',
        );
        await w.ctl.saveGoal(
          name: 'Curso',
          targetCents: 100000,
          targetDate: '2026-11-15',
        );
        final plan = reminderPlan(w.ledger, w.today);
        List<Reminder> of(String kind) =>
            plan.where((r) => r.kind == kind).toList();

        expect(of(ReminderKind.bill).map((r) => r.notifyOn), [
          '2026-11-11',
          '2026-11-12',
        ]);
        expect(of(ReminderKind.bill).every((r) => r.subject == 'Luz'), isTrue);
        // due tomorrow: the notice of the eve is today's, the other is tomorrow's
        expect(of(ReminderKind.receivable).map((r) => r.notifyOn), [
          '2026-11-10',
          '2026-11-11',
        ]);
        expect(of(ReminderKind.goal).map((r) => r.notifyOn), [
          '2026-11-14',
          '2026-11-15',
        ]);
        expect(of(ReminderKind.goal).first.cents, 100000);
        expect(plan.any((r) => r.subject == 'Longe'), isFalse);

        // no notice is planned twice, and they come in the order they will be shown
        final ids = plan.map((r) => '${r.key}@${r.notifyOn}').toList();
        expect(ids.toSet().length, ids.length);
        expect([
          for (final r in plan) r.notifyOn,
        ], [for (final r in plan) r.notifyOn]..sort());
        // every route is one the app agrees to open
        expect(plan.every((r) => isReminderRoute(r.route)), isTrue);
        expect(isReminderRoute('/settings'), isFalse);
        expect(isReminderRoute('https://example.com'), isFalse);

        // a kind that is silenced disappears, the others stay
        final quiet = reminderPlan(
          w.ledger,
          w.today,
          silenced: {ReminderKind.receivable, ReminderKind.goal},
        );
        expect(quiet.map((r) => r.kind).toSet(), {ReminderKind.bill});

        // paying the bill removes its notices
        final bill = w.ledger.transactions.firstWhere(
          (t) => t.description == 'Luz',
        );
        await w.ctl.settleTransaction(bill.id);
        expect(
          reminderPlan(w.ledger, w.today).any((r) => r.subject == 'Luz'),
          isFalse,
        );
      });
    });

    test(
      'a card invoice with a balance is reminded once, by what is still open',
      () {
        // closing day 20, due day 27: a purchase on 05/11 is in the invoice due on 27/11
        return _with('2026-11-24T15:00:00.000Z', (w) async {
          await w.add(TransactionKind.cardPurchase, 12000, '2026-11-05');
          final plan = reminderPlan(
            w.ledger,
            w.today,
          ).where((r) => r.kind == ReminderKind.invoice).toList();
          expect(plan.map((r) => r.notifyOn), ['2026-11-26', '2026-11-27']);
          expect(plan.every((r) => r.subject == 'azul'), isTrue);
          expect(plan.every((r) => r.cents == 12000), isTrue);
          expect(plan.every((r) => r.route == '/cards'), isTrue);
          final text = reminderText(plan.last);
          expect(text.title, 'Fatura azul vence hoje');
          expect(text.body, contains(formatBRL(12000)));
          expect(reminderText(plan.first).title, 'Fatura azul vence amanhã');
        });
      },
    );

    test('the text of each kind says what it is, without the balance of any account', () {
      Reminder r(
        String kind, {
        bool today = true,
        String subject = 'Aluguel',
      }) => Reminder(
        key: 'k',
        kind: kind,
        notifyOn: today ? '2026-11-12' : '2026-11-11',
        dueDate: '2026-11-12',
        subject: subject,
        cents: 150000,
        route: '/transaction?id=1',
      );
      expect(reminderText(r(ReminderKind.bill)).title, 'Aluguel vence hoje');
      expect(
        reminderText(r(ReminderKind.bill, today: false, subject: '')).title,
        'Conta vence amanhã',
      );
      expect(
        reminderText(r(ReminderKind.receivable, subject: '')).title,
        'Recebimento previsto para hoje',
      );
      expect(
        reminderText(r(ReminderKind.goal, subject: 'Curso')).title,
        'Meta Curso: a data é hoje',
      );
      for (final kind in ReminderKind.all) {
        expect(reminderText(r(kind)).body, contains(formatBRL(150000)));
      }
    });
  });

  group('in the app', () {
    Future<ProviderContainer> boot(WidgetTester tester) async {
      await setPhone(tester);
      final app = TestApp(now: '2026-11-10T15:00:00.000Z');
      addTearDown(app.dispose);
      await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
      await pumpApp(tester, app);
      return ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen, skipOffstage: false)),
      );
    }

    testWidgets(
      '031: a limit passed today shows on the home screen, and the notice can be turned off',
      (tester) async {
        final c = await boot(tester);
        final ctl = c.read(appControllerProvider.notifier);
        final a = await ctl.saveAccount(
          name: 'Conta',
          type: 'checking',
          openingBalanceCents: 100000,
          openingDate: '2026-10-01',
        );
        await ctl.setDailyTarget(
          kind: DailyTarget.spendLimit,
          amountCents: 5000,
        );
        await tester.pumpAndSettle();
        expect(
          find.text(_l.dailyAlertOpen),
          findsNothing,
          reason: 'nada gasto',
        );
        await ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.expense,
            amountCents: 6500,
            date: '2026-11-10',
            accountId: a.id,
            description: 'x',
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(_l.dailyAlertGeneral(formatBRL(1500))),
          findsOneWidget,
        );
        await ctl.setPrefs((p) => p.copyWith(dailyAlerts: false));
        await tester.pumpAndSettle();
        expect(find.text(_l.dailyAlertGeneral(formatBRL(1500))), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '029–031: the daily screen with every filter and form, on a small screen with large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final app = TestApp(now: '2026-11-10T15:00:00.000Z');
        addTearDown(app.dispose);
        await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
        await pumpApp(tester, app);
        final c = ProviderScope.containerOf(
          tester.element(find.byType(HomeScreen, skipOffstage: false)),
        );
        final ctl = c.read(appControllerProvider.notifier);
        final a = await ctl.saveAccount(
          name: 'Conta',
          type: 'checking',
          openingBalanceCents: 100000,
          openingDate: '2026-10-01',
        );
        final food = await ctl.saveCategory(
          name: 'Comida teste',
          kind: 'expense',
        );
        final goal = await ctl.saveGoal(name: 'Viagem', targetCents: 500000);
        await ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.expense,
            amountCents: 6500,
            date: '2026-11-10',
            accountId: a.id,
            categoryId: food.id,
            description: 'x',
          ),
        );
        await ctl.setDailyTarget(
          kind: DailyTarget.spendLimit,
          amountCents: 5000,
        );
        await ctl.setDailyTarget(
          kind: DailyTarget.spendLimit,
          amountCents: 2000,
          categoryId: food.id,
          weekdays: [1, 2, 3, 4, 5],
          carryOver: true,
        );
        await ctl.setDailyTarget(
          kind: DailyTarget.saving,
          amountCents: 2000,
          goalId: goal.id,
        );
        await ctl.setPrefs((p) => p.copyWith(textSize: 'larger'));
        unawaited(c.read(routerProvider).push('/daily'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // The screen is a lazy list: what is seen on the way down is noted as it passes.
        var sawCategoryLimits = false, sawWeekdays = false;
        for (var i = 0; i < 14; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -420),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'passo $i');
          sawCategoryLimits |= find
              .text(_l.dailyLimitByCategory)
              .evaluate()
              .isNotEmpty;
          sawWeekdays |= find
              .text(_l.dailyLimitOnDays('Seg, Ter, Qua, Qui, Sex'))
              .evaluate()
              .isNotEmpty;
        }
        expect(sawCategoryLimits, isTrue);
        expect(sawWeekdays, isTrue);
      },
    );
  });
}
