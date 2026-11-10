/// Navigation: 5 persistent tabs (StatefulShellRoute) + stacked and modal routes, with onboarding redirect.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/accounts/account_form_screen.dart';
import '../features/annual/annual_screen.dart';
import '../features/history/history_screen.dart';
import '../features/shopping/list_screens.dart';
import '../features/daily/daily_screen.dart';
import '../features/shopping/price_history_screen.dart';
import '../features/shopping/scan_screen.dart';
import '../features/shopping/session_screen.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/assistant/assistant_screen.dart';
import '../features/billing/paywall_screen.dart';
import '../features/bills/bills_screen.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/cards/cards_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/data/export_screen.dart';
import '../features/data/import_screen.dart';
import '../features/data/privacy_help_screens.dart';
import '../features/goals/goals_screen.dart';
import '../features/home/available_screen.dart';
import '../features/home/customize_screen.dart';
import '../features/home/home_screen.dart';
import '../features/loans/loans_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/plan/plan_screen.dart';
import '../features/reports/reports_screens.dart';
import '../features/settings/settings_screen.dart';
import '../features/shopping/shopping_tab.dart';
import '../features/transactions/transaction_form_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../ui/icons.dart';
import 'app.dart';
import 'app_drawer.dart';
import 'state/app_controller.dart';
import 'theme/tokens.dart';

final _rootKey = GlobalKey<NavigatorState>();

abstract final class Routes {
  static const home = '/';
  static const transactions = '/transactions';
  static const shopping = '/shopping';
  static const plan = '/plan';
  static const onboarding = '/onboarding';
  static const transaction = '/transaction';
  static const customize = '/customize';
  static const available = '/available';
  static const settings = '/settings';
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    // Only the onboarding flag affects redirects; notifying on every reload would
    // re-evaluate routes in the middle of a navigation.
    ref.listen(
      appControllerProvider.select((s) => s.value?.onboarded),
      (_, _) => notifyListeners(),
    );
  }
  final Ref ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final app = ref.read(appControllerProvider);
      if (app.isLoading && !app.hasValue) return null;
      final onboarded = app.value?.onboarded ?? true;
      final inOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarded && !inOnboarding) return Routes.onboarding;
      if (onboarded && inOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        pageBuilder: (c, s) => CustomTransitionPage(
          key: s.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (_, a, _, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabsShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (c, s) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.transactions,
                builder: (c, s) =>
                    TransactionsScreen(kind: s.uri.queryParameters['kind']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.shopping,
                builder: (c, s) => const ShoppingTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.plan, builder: (c, s) => const PlanScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.transaction,
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => _modal(
          s,
          TransactionFormScreen(
            id: s.uri.queryParameters['id'],
            kind: s.uri.queryParameters['kind'],
            planned: s.uri.queryParameters['planned'] == '1',
            cardId: s.uri.queryParameters['cardId'],
            date: s.uri.queryParameters['date'],
          ),
        ),
      ),
      GoRoute(
        path: Routes.customize,
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => _modal(s, const CustomizeScreen()),
      ),
      GoRoute(
        path: Routes.available,
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => _modal(s, const AvailableScreen()),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/accounts',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/accounts/new',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const AccountFormScreen(),
      ),
      GoRoute(
        path: '/accounts/edit',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => AccountFormScreen(id: s.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/accounts/:id',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => AccountDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/categories',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/cards',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const CardsScreen(),
      ),
      GoRoute(
        path: '/cards/new',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => CardFormScreen(id: s.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/cards/installments',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const InstallmentsScreen(),
      ),
      GoRoute(
        path: '/cards/:id',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => CardDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/budgets',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const BudgetsScreen(),
      ),
      GoRoute(
        path: '/budgets/new',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => BudgetFormScreen(id: s.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/goals',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/goals/new',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => GoalFormScreen(id: s.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/goals/:id',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => GoalDetailScreen(
          id: s.pathParameters['id']!,
          action: s.uri.queryParameters['action'],
        ),
      ),
      GoRoute(
        path: '/loans',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const LoansScreen(),
      ),
      GoRoute(
        path: '/loans/new',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => LoanFormScreen(id: s.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/loans/:id',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => LoanDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/calendar',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/bills',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => BillsScreen(filter: s.uri.queryParameters['filter']),
      ),
      GoRoute(
        path: '/reports',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const ReportsIndexScreen(),
      ),
      GoRoute(
        path: '/reports/cashflow',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const CashflowReportScreen(),
      ),
      GoRoute(
        path: '/reports/categories',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const CategoriesReportScreen(),
      ),
      GoRoute(
        path: '/reports/indicators',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const IndicatorsReportScreen(),
      ),
      GoRoute(
        path: '/reports/projection',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const ProjectionReportScreen(),
      ),
      GoRoute(
        path: '/reports/recurring',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const RecurringReportScreen(),
      ),
      GoRoute(
        path: '/assistant',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const AssistantScreen(),
      ),
      GoRoute(
        path: '/import',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const ImportScreen(),
      ),
      GoRoute(
        path: '/export',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const ExportScreen(),
      ),
      GoRoute(
        path: '/privacy',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/help',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const HelpScreen(),
      ),
      GoRoute(
        path: '/history',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/plan/annual',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const AnnualScreen(),
      ),
      GoRoute(
        path: '/shopping/prices',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const PriceHistoryScreen(),
      ),
      GoRoute(
        path: '/daily',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const DailyScreen(),
      ),
      GoRoute(
        path: '/shopping/list/new',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => const ListFormScreen(),
      ),
      GoRoute(
        path: '/shopping/list/:id',
        parentNavigatorKey: _rootKey,
        builder: (c, s) => ListDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/shopping/session',
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => _modal(
          s,
          SessionScreen(
            id: s.uri.queryParameters['id'],
            listId: s.uri.queryParameters['listId'],
          ),
        ),
      ),
      GoRoute(
        path: '/shopping/scan',
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => _modal(
          s,
          ScanScreen(mode: s.uri.queryParameters['mode'] ?? 'label'),
        ),
      ),
      GoRoute(
        path: '/paywall',
        parentNavigatorKey: _rootKey,
        builder: (c, s) =>
            PaywallScreen(feature: s.uri.queryParameters['feature']),
      ),
    ],
  );
});

Page<void> _modal(GoRouterState s, Widget child) =>
    MaterialPage(key: s.pageKey, fullscreenDialog: true, child: child);

class _TabsShell extends ConsumerStatefulWidget {
  const _TabsShell({required this.shell});
  final StatefulNavigationShell shell;
  @override
  ConsumerState<_TabsShell> createState() => _TabsShellState();
}

class _TabsShellState extends ConsumerState<_TabsShell> {
  final _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    final app = ref.watch(appControllerProvider);
    if (!app.hasValue) return BootScreen(error: app.error);
    final l = AppLocalizations.of(context);
    final c = context.colors;
    // The four frequent destinations, then the entry to the side menu (never a selected tab).
    final tabs = [
      (SIconName.home, l.tabHome),
      (SIconName.plus, l.tabTransactions),
      (SIconName.cart, l.tabShopping),
      (SIconName.chart, l.tabPlan),
      (SIconName.menu, l.navMenu),
    ];
    const menuIndex = 4;
    void goTab(int i) =>
        shell.goBranch(i, initialLocation: i == shell.currentIndex);
    // One undo listener for the whole shell: the tabs stay alive together, so a listener per tab
    // would queue the same SnackBar once per tab.
    return UndoHost(
      child: Scaffold(
        key: _scaffold,
        drawer: AppDrawer(currentTab: shell.currentIndex, onSelectTab: goTab),
        body: shell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.border)),
          ),
          // Five labels share the width: they follow the system font only as far as "Lançamentos"
          // still fits its fifth of the bar without wrapping.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: MediaQuery.sizeOf(context).width >= 400
                ? 1.15
                : 1.0,
            child: NavigationBarTheme(
              data: NavigationBarTheme.of(context).copyWith(
                // On the narrowest phones the longest label needs a slightly smaller size.
                labelTextStyle: MediaQuery.sizeOf(context).width < 360
                    ? WidgetStateProperty.resolveWith(
                        (s) => Type.label.copyWith(
                          fontSize: 10,
                          letterSpacing: 0,
                          fontWeight: s.contains(WidgetState.selected)
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: s.contains(WidgetState.selected)
                              ? c.primary
                              : c.textMuted,
                        ),
                      )
                    : null,
              ),
              child: NavigationBar(
                selectedIndex: shell.currentIndex,
                onDestinationSelected: (i) => i == menuIndex
                    ? _scaffold.currentState?.openDrawer()
                    : goTab(i),
                destinations: [
                  for (var i = 0; i < tabs.length; i++)
                    NavigationDestination(
                      icon: SIcon(tabs[i].$1, size: 22, color: c.textMuted),
                      selectedIcon: SIcon(
                        tabs[i].$1,
                        size: 22,
                        color: c.primary,
                      ),
                      label: tabs[i].$2,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Undo toast listener: shows a SnackBar with "Desfazer" whenever the controller sets an undo action.
class UndoHost extends ConsumerWidget {
  const UndoHost({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appControllerProvider.select((s) => s.value?.undo), (
      prev,
      next,
    ) {
      if (next == null || identical(prev, next)) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(next.label),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: context.l10n.undo,
            onPressed: () => next.run(),
          ),
        ),
      );
    });
    return child;
  }
}
