import { Platform } from 'react-native';
import * as Notifications from 'expo-notifications';
import { upcoming, addDays, type Ledger, formatBRL, pendingCents } from '@financas/core';

/**
 * Local reminders for bills due in the next 7 days (one notification per bill, 9:00 local time, the day before and on the day).
 * No server, no push tokens: everything is scheduled on the device. Re-run on every app start; idempotent via cancel-all.
 */
export async function ensureNotificationPermission(): Promise<boolean> {
  if (Platform.OS === 'web') return false;
  const cur = await Notifications.getPermissionsAsync();
  if (cur.granted) return true;
  if (!cur.canAskAgain) return false;
  const req = await Notifications.requestPermissionsAsync();
  return req.granted;
}

export async function scheduleBillReminders(ledger: Ledger, today: string): Promise<number> {
  if (Platform.OS === 'web') return 0;
  const perm = await Notifications.getPermissionsAsync();
  if (!perm.granted) return 0;
  await Notifications.cancelAllScheduledNotificationsAsync();
  Notifications.setNotificationHandler({ handleNotification: async () => ({ shouldShowBanner: true, shouldShowList: true, shouldPlaySound: false, shouldSetBadge: false }) });
  const bills = upcoming(ledger, today, addDays(today, 7)).slice(0, 20);
  let n = 0;
  for (const b of bills) {
    const due = b.dueDate ?? b.date;
    for (const [offset, label] of [[-1, 'vence amanhã'], [0, 'vence hoje']] as const) {
      const d = addDays(due, offset);
      if (d < today) continue;
      const at = new Date(Number(d.slice(0, 4)), Number(d.slice(5, 7)) - 1, Number(d.slice(8, 10)), 9, 0, 0);
      if (at.getTime() <= Date.now()) continue;
      await Notifications.scheduleNotificationAsync({ content: { title: `${b.description || 'Conta'} ${label}`, body: `${formatBRL(pendingCents(b))}. Toque para marcar como paga.`, data: { route: `/transaction?id=${b.id}` } }, trigger: { type: Notifications.SchedulableTriggerInputTypes.DATE, date: at } });
      n++;
    }
  }
  return n;
}
