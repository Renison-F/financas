/// Navigation: 5 persistent tabs (StatefulShellRoute) + stacked and modal routes, with onboarding redirect.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/available_screen.dart';
import '../features/home/customize_screen.dart';
import '../features/home/home_screen.dart';
import '../features/more/more_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/plan/plan_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shopping/shopping_tab.dart';
import '../features/transactions/transaction_form_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../ui/icons.dart';
import 'app.dart';
import 'state/app_controller.dart';
import 'theme/tokens.dart';

final _rootKey = GlobalKey<NavigatorState>();

abstract final class Routes {
  static const home = '/';
  static const transactions = '/transactions';
  static const shopping = '/shopping';
  static const plan = '/plan';
  static const more = '/more';
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
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.more, builder: (c, s) => const MoreScreen()),
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
    ],
  );
});

Page<void> _modal(GoRouterState s, Widget child) =>
    MaterialPage(key: s.pageKey, fullscreenDialog: true, child: child);

class _TabsShell extends ConsumerWidget {
  const _TabsShell({required this.shell});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appControllerProvider);
    if (!app.hasValue) return BootScreen(error: app.error);
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final tabs = [
      (SIconName.home, l.tabHome),
      (SIconName.list, l.tabTransactions),
      (SIconName.cart, l.tabShopping),
      (SIconName.plan, l.tabPlan),
      (SIconName.more, l.tabMore),
    ];
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            for (var i = 0; i < tabs.length; i++)
              NavigationDestination(
                icon: SIcon(tabs[i].$1, color: c.textMuted),
                selectedIcon: SIcon(
                  tabs[i].$1,
                  color: c.primary,
                  filled: i == 0,
                ),
                label: tabs[i].$2,
              ),
          ],
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
