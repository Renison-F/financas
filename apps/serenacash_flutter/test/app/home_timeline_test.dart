/// Ocorrências 027, 028 e 009 (complemento): navegação por mês no cabeçalho, linha do tempo que
/// responde ao toque, cartões em tamanho reduzido e visão geral com marcas de cor. Os números são
/// sempre os do domínio; nada é inventado para preencher um gráfico.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/state/app_state.dart';
import 'package:serenacash/app/state/dashboard_data.dart';
import 'package:serenacash/data/database/app_database.dart';
import 'package:serenacash/data/notifications/bill_reminders.dart';
import 'package:serenacash/data/security/secret_store.dart';
import 'package:serenacash/domain/daily/daily.dart';
import 'package:serenacash/domain/dashboard/widgets.dart' as dash;
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/money/money.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/features/home/compact_widget.dart';
import 'package:serenacash/features/home/home_screen.dart';
import 'package:serenacash/l10n/app_localizations.dart';

import 'harness.dart';
import 'kv_factory.dart';

final _l = lookupAppLocalizations(const Locale('pt'));

BuildContext _home(WidgetTester tester) =>
    tester.element(find.byType(HomeScreen, skipOffstage: false));

/// The app on 10/11/2026 with one account of R$ 1.000,00 opened in October and a few entries.
Future<ProviderContainer> _boot(
  WidgetTester tester, {
  bool phone = true,
}) async {
  if (phone) await setPhone(tester);
  final app = TestApp(now: '2026-11-10T15:00:00.000Z');
  addTearDown(app.dispose);
  await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
  await pumpApp(tester, app);
  final c = ProviderScope.containerOf(_home(tester));
  final ctl = c.read(appControllerProvider.notifier);
  final account = await ctl.saveAccount(
    name: 'Conta',
    type: 'checking',
    openingBalanceCents: 100000,
    openingDate: '2026-10-01',
  );
  Future<void> add(
    TransactionKind kind,
    int cents,
    String date, {
    TransactionStatus status = TransactionStatus.settled,
  }) => ctl.saveTransaction(
    TransactionInput(
      kind: kind,
      amountCents: cents,
      date: date,
      accountId: account.id,
      description: 'x',
      status: status,
      dueDate: status == TransactionStatus.planned ? date : null,
    ),
  );
  await add(TransactionKind.expense, 30000, '2026-10-20');
  await add(TransactionKind.income, 6500, '2026-11-07');
  await add(TransactionKind.expense, 4500, '2026-11-07');
  await add(
    TransactionKind.expense,
    20000,
    '2026-11-25',
    status: TransactionStatus.planned,
  );
  await add(
    TransactionKind.income,
    50000,
    '2026-12-05',
    status: TransactionStatus.planned,
  );
  await add(
    TransactionKind.expense,
    10000,
    '2026-12-10',
    status: TransactionStatus.planned,
  );
  await tester.pumpAndSettle();
  return c;
}

Future<void> _see(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadTestFonts);

  group('027: projection across months (domain)', () {
    test(
      'a month that has not begun starts from what is expected on its eve',
      () async {
        final db = AppDatabase.inMemory();
        addTearDown(db.close);
        final c = ProviderContainer(
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
        addTearDown(c.dispose);
        await c.read(appControllerProvider.future);
        final ctl = c.read(appControllerProvider.notifier);
        final a = await ctl.saveAccount(
          name: 'Conta',
          type: 'checking',
          openingBalanceCents: 100000,
          openingDate: '2026-10-01',
        );
        Future<void> planned(TransactionKind k, int v, String d) =>
            ctl.saveTransaction(
              TransactionInput(
                kind: k,
                amountCents: v,
                date: d,
                accountId: a.id,
                description: 'x',
                status: TransactionStatus.planned,
                dueDate: d,
              ),
            );
        await planned(TransactionKind.expense, 20000, '2026-11-25');
        await planned(TransactionKind.income, 50000, '2026-12-05');
        await planned(TransactionKind.expense, 10000, '2026-12-10');
        final ledger = c.read(ledgerProvider);
        const today = '2026-11-10';
        // facts up to today, the sum of what is recorded afterwards
        expect(projectedBalance(ledger, '2026-11-10', today), 100000);
        expect(projectedBalance(ledger, '2026-11-24', today), 100000);
        expect(projectedBalance(ledger, '2026-11-30', today), 80000);
        expect(projectedBalance(ledger, '2026-12-31', today), 120000);

        final december = dailyFlow(ledger, '2026-12', today);
        expect(december.first.balanceCents, isNull, reason: 'nada é fato');
        expect(
          december.first.projectedBalanceCents,
          80000,
          reason: 'parte do previsto para 30/11, não do saldo de hoje',
        );
        expect(december[4].projectedBalanceCents, 130000);
        expect(december.last.projectedBalanceCents, 120000);

        // a past month is made only of facts
        final october = dailyFlow(ledger, '2026-10', today);
        expect(october.every((d) => d.balanceCents != null), isTrue);
        expect(october.every((d) => d.projectedBalanceCents == null), isTrue);
        expect(entriesOn(ledger, '2026-11-25').length, 1);
        expect(entriesOn(ledger, '2026-11-26'), isEmpty);
      },
    );
  });

  group('027: layout sizes (domain)', () {
    test('reduced size is saved with the layout, only when used, and survives a round trip', () {
      final base = dash.defaultLayout;
      expect(base.toJson().containsKey('compact'), isFalse);
      final l = dash.setWidgetCompact(base, 'overview', true);
      expect(l.compact, {'overview'});
      final back = dash.normalizeLayout(l.toJson());
      expect(back.compact, {'overview'});
      expect(dash.setWidgetCompact(back, 'overview', false).compact, isEmpty);
      // ids that do not exist are dropped instead of failing
      expect(
        dash.normalizeLayout({
          'order': ['available'],
          'compact': ['nope', 'available', 3],
        }).compact,
        {'available'},
      );
    });
  });

  testWidgets(
    '027: the arrows of the header look at another month and come back',
    (tester) async {
      final c = await _boot(tester);
      expect(find.text('Novembro de 2026'), findsOneWidget);
      expect(c.read(dashboardDataProvider)!.totals.expenseSettled, 4500);

      await tester.tap(find.bySemanticsLabel(_l.homePrevMonth));
      await tester.pumpAndSettle();
      expect(find.text('Outubro de 2026'), findsOneWidget);
      final october = c.read(dashboardDataProvider)!;
      expect(october.month, '2026-10');
      expect(
        october.totals.expenseSettled,
        30000,
        reason: 'os números são os de outubro',
      );
      expect(
        find.text(_l.homeOtherMonthNote('Outubro de 2026')),
        findsOneWidget,
      );
      // the saved layout is untouched: this is a look, not a setting
      expect(
        c.read(appControllerProvider).value!.layout.period,
        'current_month',
      );

      await tester.tap(find.bySemanticsLabel(_l.homeNextMonth));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(_l.homeNextMonth));
      await tester.pumpAndSettle();
      expect(find.text('Dezembro de 2026'), findsOneWidget);
      expect(c.read(dashboardDataProvider)!.month, '2026-12');

      await tester.tap(find.text(_l.homeBackToToday('Novembro de 2026')));
      await tester.pumpAndSettle();
      expect(find.text('Novembro de 2026'), findsOneWidget);
      expect(c.read(homeMonthProvider), isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '027: the balance card names past, present and future differently',
    (tester) async {
      final c = await _boot(tester);
      await c
          .read(appControllerProvider.notifier)
          .setLayout(const dash.DashboardLayout(order: ['period_balance']));
      await tester.pumpAndSettle();
      String brl(int v) => formatBRL(v);

      // present: opening 700,00 (1.000 − 300 of October), today 720,00, expected 520,00
      expect(find.text(_l.homeOpening), findsOneWidget);
      expect(find.text(_l.homeBalanceToday), findsOneWidget);
      expect(find.text(_l.homeProjected), findsOneWidget);
      expect(find.text(brl(70000)), findsOneWidget);
      expect(find.text(brl(72000)), findsOneWidget);
      expect(find.text(brl(52000)), findsOneWidget);

      // past: only facts, and no projection note
      await tester.tap(find.bySemanticsLabel(_l.homePrevMonth));
      await tester.pumpAndSettle();
      expect(find.text(_l.homeClosing), findsOneWidget);
      expect(find.text(_l.homeChange), findsOneWidget);
      expect(find.text(_l.homeProjected), findsNothing);
      expect(find.text(_l.homeProjectedNote), findsNothing);
      expect(find.text(brl(100000)), findsOneWidget);
      expect(find.text(brl(70000)), findsOneWidget);

      // future: everything is said to be expected
      await tester.tap(find.bySemanticsLabel(_l.homeNextMonth));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(_l.homeNextMonth));
      await tester.pumpAndSettle();
      expect(find.text(_l.homeOpeningProjected), findsOneWidget);
      expect(find.text(_l.homeClosingProjected), findsOneWidget);
      expect(find.text(_l.homeChangeProjected), findsOneWidget);
      expect(find.text(brl(52000)), findsOneWidget);
      expect(find.text(brl(92000)), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '027: touching a day of the timeline shows its facts and opens its entries',
    (tester) async {
      final c = await _boot(tester);
      await c
          .read(appControllerProvider.notifier)
          .setLayout(const dash.DashboardLayout(order: ['period_balance']));
      await tester.pumpAndSettle();
      expect(find.text(_l.timelineHint), findsOneWidget);

      final chart = find.byKey(const ValueKey('timeline-chart'));
      final box = tester.getRect(chart.first);
      // November has 30 days: day 7 is index 6 of 29 steps
      await tester.tapAt(Offset(box.left + box.width * 6 / 29, box.center.dy));
      await tester.pumpAndSettle();
      expect(find.text(_l.timelineHint), findsNothing);
      expect(find.textContaining('saldo ${formatBRL(72000)}'), findsOneWidget);
      expect(
        find.textContaining('recebido ${formatBRL(6500)}'),
        findsOneWidget,
      );
      expect(find.textContaining('gasto ${formatBRL(4500)}'), findsOneWidget);

      // a future day is said to be expected, with what is still to pay
      await tester.tapAt(Offset(box.left + box.width * 24 / 29, box.center.dy));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('saldo previsto ${formatBRL(52000)}'),
        findsOneWidget,
      );
      expect(
        find.textContaining('a pagar ${formatBRL(20000)}'),
        findsOneWidget,
      );

      // the other view keeps the selection and draws without error
      await tester.tap(find.text(_l.timelineViewFlow));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('a pagar ${formatBRL(20000)}'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(_l.timelineOpenDay));
      await tester.pumpAndSettle();
      expect(find.text(_l.timelineAddOnDay), findsOneWidget);
      expect(find.textContaining('· ${_l.timelinePlanned}'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_l.timelineClear));
      await tester.pumpAndSettle();
      expect(find.text(_l.timelineHint), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '027: a card in reduced size is one line with the same figure, and can be enlarged again',
    (tester) async {
      final c = await _boot(tester);
      final ctl = c.read(appControllerProvider.notifier);
      await ctl.setLayout(
        const dash.DashboardLayout(
          order: ['overview', 'recurrence'],
          compact: {'overview', 'recurrence'},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CompactWidget), findsNWidgets(2));
      final data = c.read(dashboardDataProvider)!;
      expect(widgetHeadlineCents('overview', data), 2000);
      expect(
        widgetHeadlineCents('recurrence', data),
        isNull,
        reason: 'sem número único',
      );
      expect(
        find.text(_l.homeResultNote),
        findsNothing,
        reason: 'conteúdo completo fora da tela',
      );

      // the choice is on disk
      await ctl.reload();
      await tester.pumpAndSettle();
      expect(c.read(appControllerProvider).value!.layout.compact, {
        'overview',
        'recurrence',
      });

      // and it is changed in "Personalizar tela inicial"
      await _see(tester, find.text(_l.customizeHome));
      await tester.tap(find.text(_l.customizeHome));
      await tester.pumpAndSettle();
      final title = dash.widgetById('overview').title;
      await tester.tap(find.bySemanticsLabel(_l.widgetExpand(title)));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(_l.widgetCompact(title)), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '027/028: the new home survives a small screen with large text, in every card style',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await _boot(tester, phone: false);
      final ctl = c.read(appControllerProvider.notifier);
      await ctl.setLayout(
        dash.DashboardLayout(
          order: dash.allWidgetIds,
          compact: const {'income', 'expenses', 'loans'},
        ),
      );
      for (final style in ['outlined', 'elevated', 'tinted']) {
        await ctl.setPrefs(
          (p) => p.copyWith(
            cardStyle: style,
            chartStyle: 'compact',
            textSize: 'larger',
            theme: style == 'tinted' ? 'dark' : 'light',
          ),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 12; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -500),
          );
          await tester.pump(const Duration(milliseconds: 50));
          expect(tester.takeException(), isNull, reason: '$style, passo $i');
        }
        await tester.pumpAndSettle();
        for (var i = 0; i < 12; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, 500),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: style);
      }
    },
  );
}
