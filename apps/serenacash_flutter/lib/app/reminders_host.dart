/// Keeps bill reminders in step with the ledger and opens the bill when a reminder is tapped.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications/bill_reminders.dart';
import '../domain/entities/entities.dart';
import '../domain/reminders/reminders.dart';
import 'router.dart';
import 'state/app_controller.dart';

/// Sits above the lock gate so a tapped reminder is remembered while the app is locked and the bill
/// shows as soon as it unlocks.
class RemindersHost extends ConsumerStatefulWidget {
  const RemindersHost({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<RemindersHost> createState() => _RemindersHostState();
}

class _RemindersHostState extends ConsumerState<RemindersHost> {
  static const _billRoute = '/transaction?id=';

  StreamSubscription<String>? _taps;
  Timer? _debounce;
  bool _launchChecked = false;

  @override
  void initState() {
    super.initState();
    _taps = ref.read(billRemindersProvider).openedRoutes.listen(_open);
    // fireImmediately covers a state that is already loaded when this widget mounts.
    ref.listenManual<(Ledger?, bool)>(
      appControllerProvider.select(
        (s) => (s.value?.ledger, s.value?.onboarded ?? false),
      ),
      (_, next) => _onLedger(next),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _taps?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  /// Only the routes a reminder can carry are honoured, and an entry only while it still exists.
  void _open(String route) {
    if (!mounted || !isReminderRoute(route)) return;
    final app = ref.read(appControllerProvider).value;
    if (app == null || !app.onboarded) return;
    if (route.startsWith(_billRoute)) {
      final id = Uri.tryParse(route)?.queryParameters['id'];
      if (id == null || app.ledger.transactionById(id) == null) return;
    }
    ref.read(routerProvider).push(route);
  }

  Future<void> _checkLaunch() async {
    final route = await ref.read(billRemindersProvider).takeLaunchRoute();
    if (route != null) _open(route);
  }

  /// Same rule as the original app: reschedule whenever the ledger changes, but never prompt here.
  void _resync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      final app = ref.read(appControllerProvider).value;
      if (app == null || !app.onboarded) return;
      final reminders = ref.read(billRemindersProvider);
      try {
        if (!await reminders.hasPermission()) return;
        await reminders.schedule(app.ledger, app.today);
      } catch (_) {
        // Reminders are best effort; a platform failure must not disturb the app.
      }
    });
  }

  void _onLedger((Ledger?, bool) state) {
    final (ledger, onboarded) = state;
    if (ledger == null || !onboarded) return;
    _resync();
    if (!_launchChecked) {
      _launchChecked = true;
      _checkLaunch();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
