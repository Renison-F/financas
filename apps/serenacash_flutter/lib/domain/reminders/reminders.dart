/// What the app reminds the user of, decided from the ledger alone: bills to pay (loan instalments
/// among them), amounts to receive, card invoices and goals with a date. Each commitment yields at
/// most one notice the day before and one on the day, never two for the same thing.
library;

import '../cards/cards.dart';
import '../dates/dates.dart';
import '../entities/entities.dart';
import '../goals/goals.dart';
import '../ledger/ledger.dart';
import '../money/money.dart';

/// The kinds of reminder. Their names are what the preferences store for the ones turned off.
abstract final class ReminderKind {
  static const bill = 'bill',
      receivable = 'receivable',
      invoice = 'invoice',
      goal = 'goal';
  static const all = [bill, receivable, invoice, goal];
}

class Reminder {
  const Reminder({
    required this.key,
    required this.kind,
    required this.notifyOn,
    required this.dueDate,
    required this.subject,
    required this.cents,
    required this.route,
  });

  /// The same for every notice of one commitment; with [notifyOn] it identifies one notice.
  final String key;
  final String kind;

  /// The day the notice is shown: the due date or the day before it.
  final ISODate notifyOn;
  final ISODate dueDate;

  /// What it is about: the description of the bill, the name of the card or of the goal.
  final String subject;

  /// What is still to pay, to receive or to set aside.
  final Cents cents;

  /// Where a touch on the notice leads.
  final String route;

  bool get onTheDay => notifyOn == dueDate;
}

/// How many days ahead reminders are planned. Rescheduling happens every time the ledger changes
/// or the app opens, so a week is enough and keeps the number of pending notices small.
const reminderHorizonDays = 7;

/// The notices to schedule from [today] on, in the order they will be shown. Kinds in [silenced]
/// are left out. No more than [max] notices are returned (systems limit the pending ones).
List<Reminder> reminderPlan(
  Ledger ledger,
  ISODate today, {
  Set<String> silenced = const {},
  int max = 60,
}) {
  final until = addDays(today, reminderHorizonDays);
  bool soon(ISODate d) =>
      compareISO(d, today) >= 0 && compareISO(d, until) <= 0;
  final due =
      <
        ({
          String key,
          String kind,
          ISODate date,
          String subject,
          int cents,
          String route,
        })
      >[];

  if (!silenced.contains(ReminderKind.bill)) {
    for (final t in upcoming(ledger, today, until)) {
      due.add((
        key: 'tx:${t.id}',
        kind: ReminderKind.bill,
        date: t.effectiveDate,
        subject: t.description,
        cents: pendingCents(t),
        route: '/transaction?id=${t.id}',
      ));
    }
  }
  if (!silenced.contains(ReminderKind.receivable)) {
    for (final t in ledger.transactions) {
      if (!isPlanned(t) || !isIncomeLike(t) || !soon(t.effectiveDate)) continue;
      due.add((
        key: 'tx:${t.id}',
        kind: ReminderKind.receivable,
        date: t.effectiveDate,
        subject: t.description,
        cents: pendingCents(t),
        route: '/transaction?id=${t.id}',
      ));
    }
  }
  if (!silenced.contains(ReminderKind.invoice)) {
    for (final card in ledger.cards.where((c) => c.isActive)) {
      final current = currentInvoiceMonth(card, today);
      // The invoice that is open and the one before it, which may be closed and not yet paid.
      for (final month in [addMonthsToKey(current, -1), current]) {
        final inv = invoice(ledger, card, month, today);
        final left = inv.totalCents - inv.paidCents;
        if (left <= 0 || !soon(inv.dueDate)) continue;
        due.add((
          key: 'invoice:${card.id}:$month',
          kind: ReminderKind.invoice,
          date: inv.dueDate,
          subject: card.name,
          cents: left,
          route: '/cards',
        ));
      }
    }
  }
  if (!silenced.contains(ReminderKind.goal)) {
    for (final g in ledger.goals) {
      final date = g.targetDate;
      if (g.archived || g.deletedAt != null || date == null || !soon(date)) {
        continue;
      }
      final p = goalProgress(ledger, g, today);
      final left = g.targetCents - p.savedCents;
      if (left <= 0) continue;
      due.add((
        key: 'goal:${g.id}',
        kind: ReminderKind.goal,
        date: date,
        subject: g.name,
        cents: left,
        route: '/goals',
      ));
    }
  }

  final out = <Reminder>[];
  final seen = <String>{};
  for (final d in due) {
    for (final offset in const [-1, 0]) {
      final on = addDays(d.date, offset);
      if (compareISO(on, today) < 0) continue;
      // One commitment, one notice per day, whatever the path that found it.
      if (!seen.add('${d.key}@$on')) continue;
      out.add(
        Reminder(
          key: d.key,
          kind: d.kind,
          notifyOn: on,
          dueDate: d.date,
          subject: d.subject,
          cents: d.cents,
          route: d.route,
        ),
      );
    }
  }
  out.sort((a, b) {
    final byDay = compareISO(a.notifyOn, b.notifyOn);
    return byDay != 0 ? byDay : a.key.compareTo(b.key);
  });
  return out.length > max ? out.sublist(0, max) : out;
}

/// The routes a notice may open. Anything else found in a notice is ignored.
bool isReminderRoute(String route) =>
    route == '/cards' ||
    route == '/goals' ||
    route.startsWith('/transaction?id=');
