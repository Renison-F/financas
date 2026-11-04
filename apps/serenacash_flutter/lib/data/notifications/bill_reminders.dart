/// Local reminders for bills due in the next 7 days: one notification per bill at 09:00 local time,
/// the day before and on the day. No server, no push tokens. Idempotent (cancel-all then reschedule).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/dates/dates.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/money/money.dart';

abstract interface class BillReminders {
  Future<bool> requestPermission();
  Future<int> schedule(Ledger ledger, String today);
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
  Future<int> schedule(Ledger ledger, String today) async => 0;
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

  Future<void> _init() async {
    if (_initialized) return;
    await _plugin.initialize(
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
