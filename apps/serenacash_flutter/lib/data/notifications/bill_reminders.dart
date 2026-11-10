/// Local reminders for what is due in the next 7 days (bills, amounts to receive, card invoices
/// and goals with a date): one notification per commitment at 09:00 local time, the day before and
/// on the day. No server, no push tokens. Idempotent (cancel-all then reschedule).
library;

import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/entities.dart';
import '../../domain/money/money.dart';
import '../../domain/reminders/reminders.dart';

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

/// Title and text of the notice of one reminder. The amount is what is still open, never the
/// balance of an account.
({String title, String body}) reminderText(Reminder r) {
  final when = r.onTheDay ? 'hoje' : 'amanhã';
  final value = formatBRL(r.cents);
  return switch (r.kind) {
    ReminderKind.receivable => (
      title:
          '${r.subject.isEmpty ? 'Recebimento' : r.subject} previsto para $when',
      body: '$value. Toque para confirmar quando receber.',
    ),
    ReminderKind.invoice => (
      title: 'Fatura ${r.subject} vence $when',
      body: '$value em aberto.',
    ),
    ReminderKind.goal => (
      title: 'Meta ${r.subject}: a data é $when',
      body: 'Faltam $value.',
    ),
    _ => (
      title: '${r.subject.isEmpty ? 'Conta' : r.subject} vence $when',
      body: '$value. Toque para marcar como paga.',
    ),
  };
}

class LocalBillReminders implements BillReminders {
  LocalBillReminders({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
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
        // White silhouette in res/drawable (kept from R8 by res/raw/keep.xml).
        android: AndroidInitializationSettings('ic_stat_serenacash'),
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
    final plan = reminderPlan(
      ledger,
      today,
      silenced: ledger.prefs.silencedReminders.toSet(),
    );
    var n = 0;
    var id = 1;
    for (final r in plan) {
      final d = r.notifyOn;
      final at = DateTime(
        int.parse(d.substring(0, 4)),
        int.parse(d.substring(5, 7)),
        int.parse(d.substring(8, 10)),
        9,
      );
      if (!at.isAfter(DateTime.now())) continue;
      final text = reminderText(r);
      await _plugin.zonedSchedule(
        id: id++,
        title: text.title,
        body: text.body,
        scheduledDate: _tz(at),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'bills',
            'Vencimentos',
            channelDescription:
                'Lembretes de contas, recebimentos, faturas e metas',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            color: Color(0xFF0B5563),
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: r.route,
      );
      n++;
    }
    return n;
  }
}

/// flutter_local_notifications needs a TZDateTime; the instant is preserved, so UTC needs no tz database.
tz.TZDateTime _tz(DateTime local) => tz.TZDateTime.from(local, tz.UTC);
