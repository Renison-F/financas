/// Local reminders for bills due in the next 7 days: one notification per bill at 09:00 local time,
/// the day before and on the day. No server, no push tokens. Idempotent (cancel-all then reschedule).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';

abstract interface class BillReminders {
  /// Asks the system for permission (shows the system dialog when needed).
  Future<bool> requestPermission();

  /// Whether notifications are already allowed. Never prompts.
  Future<bool> hasPermission();
  Future<int> schedule(Ledger ledger, String today);

  /// Route of the reminder that launched the app from a terminated state; returned once.
  Future<String?> takeLaunchRoute();

  /// Routes of reminders tapped while the app is running or in the background.
  Stream<String> get openedRoutes;
}

final billRemindersProvider = Provider<BillReminders>(
  (_) =>
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS
      ? LocalBillReminders()
      : const NoopBillReminders(),
);

class NoopBillReminders implements BillReminders {
  const NoopBillReminders();
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<bool> hasPermission() async => false;
  @override
  Future<int> schedule(Ledger ledger, String today) async => 0;
  @override
  Future<String?> takeLaunchRoute() async => null;
  @override
  Stream<String> get openedRoutes => const Stream.empty();
}

class LocalBillReminders implements BillReminders {
  LocalBillReminders({
    FlutterLocalNotificationsPlugin? plugin,
    this.labelTomorrow = 'vence amanhã',
    this.labelToday = 'vence hoje',
    this.tapHint = 'Toque para marcar como paga.',
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  final String labelTomorrow, labelToday, tapHint;
  bool _initialized = false;
  bool _launchRouteTaken = false;
  final _opened = StreamController<String>.broadcast();

  @override
  Stream<String> get openedRoutes => _opened.stream;

  Future<void> _init() async {
    if (_initialized) return;
    await _plugin.initialize(
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) _opened.add(route);
      },
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: false,
            sound: false,
          ) ??
          false;
    }
    return false;
  }

  @override
  Future<bool> hasPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return (await ios.checkPermissions())?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<String?> takeLaunchRoute() async {
    if (_launchRouteTaken) return null;
    _launchRouteTaken = true;
    await _init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final route = details.notificationResponse?.payload;
    return route == null || route.isEmpty ? null : route;
  }

  @override
  Future<int> schedule(Ledger ledger, String today) async {
    await _init();
    await _plugin.cancelAll();
    final bills = upcoming(ledger, today, addDays(today, 7)).take(20).toList();
    var n = 0;
    var id = 1;
    for (final b in bills) {
      final due = b.dueDate ?? b.date;
      for (final (offset, label) in [(-1, labelTomorrow), (0, labelToday)]) {
        final d = addDays(due, offset);
        if (compareISO(d, today) < 0) continue;
        final at = DateTime(
          int.parse(d.substring(0, 4)),
          int.parse(d.substring(5, 7)),
          int.parse(d.substring(8, 10)),
          9,
        );
        if (!at.isAfter(DateTime.now())) continue;
        await _plugin.zonedSchedule(
          id: id++,
          title: '${b.description.isEmpty ? 'Conta' : b.description} $label',
          body: '${formatBRL(pendingCents(b))}. $tapHint',
          scheduledDate: _tz(at),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'bills',
              'Vencimentos',
              channelDescription: 'Lembretes de contas a pagar',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: '/transaction?id=${b.id}',
        );
        n++;
      }
    }
    return n;
  }
}

/// flutter_local_notifications needs a TZDateTime; the instant is preserved, so UTC needs no tz database.
tz.TZDateTime _tz(DateTime local) => tz.TZDateTime.from(local, tz.UTC);
