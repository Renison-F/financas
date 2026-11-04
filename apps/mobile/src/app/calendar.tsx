import React, { useMemo, useState } from 'react';
import { View, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { monthKeyOf, addMonthsToKey, daysInMonth, weekdayOf, formatBRL, isActive, pendingCents, type Transaction } from '@financas/core';
import { Screen, Card, Text, Money, ListRow, Icon, useColors, spacing, touch, radius } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';
import { kindLabel } from '../features/dashboard/widgets';

const WD = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

/** Month calendar with per-day totals of bills and incomes; tap a day to see its items. */
export default function CalendarScreen() {
  const { ledger, today } = useAppStore();
  const router = useRouter();
  const c = useColors();
  const t = today();
  const [month, setMonth] = useState(monthKeyOf(t));
  const [selected, setSelected] = useState<string | null>(t);
  const y = Number(month.slice(0, 4)), m = Number(month.slice(5, 7));
  const days = daysInMonth(y, m);
  const first = weekdayOf(`${month}-01`);
  const byDay = useMemo(() => { const map = new Map<string, Transaction[]>(); for (const x of ledger.transactions) { if (!isActive(x)) continue; const d = x.dueDate ?? x.date; if (monthKeyOf(d) !== month) continue; map.set(d, [...(map.get(d) ?? []), x]); } return map; }, [ledger.transactions, month]);
  const cells = [...Array(first).fill(null), ...Array.from({ length: days }, (_, i) => `${month}-${String(i + 1).padStart(2, '0')}`)];
  const label = new Date(y, m - 1, 1).toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
  const sel = selected ? byDay.get(selected) ?? [] : [];
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Calendário" />
      <Screen>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: spacing.sm }}>
          <Pressable accessibilityRole="button" accessibilityLabel="Mês anterior" onPress={() => setMonth(addMonthsToKey(month, -1))} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="chevron-left" color={c.primary} /></Pressable>
          <Text role="title" style={{ textTransform: 'capitalize' }}>{label}</Text>
          <Pressable accessibilityRole="button" accessibilityLabel="Próximo mês" onPress={() => setMonth(addMonthsToKey(month, 1))} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="chevron-right" color={c.primary} /></Pressable>
        </View>
        <Card>
          <View style={{ flexDirection: 'row' }}>{WD.map((w, i) => <Text key={i} role="caption" color="textMuted" align="center" style={{ flex: 1 }}>{w}</Text>)}</View>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
            {cells.map((d, i) => {
              if (!d) return <View key={`e${i}`} style={{ width: `${100 / 7}%`, height: 52 }} />;
              const items = byDay.get(d) ?? [];
              const out = items.filter((x) => x.kind !== 'income').reduce((a, x) => a + (x.status === 'settled' ? x.amountCents : pendingCents(x)), 0);
              const inc = items.filter((x) => x.kind === 'income').reduce((a, x) => a + (x.status === 'settled' ? x.amountCents : pendingCents(x)), 0);
              const isSel = d === selected, isToday = d === t;
              return (
                <Pressable key={d} accessibilityRole="button" accessibilityLabel={`${d.slice(8, 10)}: ${items.length} lançamento(s)`} onPress={() => setSelected(d)} style={{ width: `${100 / 7}%`, height: 52, alignItems: 'center', justifyContent: 'center', borderRadius: radius.sm, backgroundColor: isSel ? c.primaryContainer : 'transparent' }}>
                  <Text role="bodySmall" color={isToday ? 'primary' : 'text'} style={{ fontWeight: isToday ? '700' : '400' }}>{Number(d.slice(8, 10))}</Text>
                  <View style={{ flexDirection: 'row', gap: 2, height: 6 }}>{out ? <View style={{ width: 6, height: 6, borderRadius: 3, backgroundColor: items.some((x) => x.status !== 'settled' && (x.dueDate ?? x.date) < t && x.kind !== 'income') ? c.negative : c.primary }} /> : null}{inc ? <View style={{ width: 6, height: 6, borderRadius: 3, backgroundColor: c.positive }} /> : null}</View>
                </Pressable>
              );
            })}
          </View>
        </Card>
        {selected ? <Card style={{ marginTop: spacing.sm }}>
          <Text role="title" style={{ marginBottom: 6 }}>{selected.slice(8, 10)}/{selected.slice(5, 7)}</Text>
          {sel.length ? sel.map((x) => <ListRow key={x.id} icon={x.kind === 'income' ? 'arrow-down' : 'receipt'} title={x.description || kindLabel(x.kind)} description={`${kindLabel(x.kind)}${x.status !== 'settled' ? ' · previsto' : ''}`} right={<Money cents={x.kind === 'income' ? x.amountCents : -x.amountCents} signed={x.kind === 'income'} />} onPress={() => router.push(`/transaction?id=${x.id}`)} />) : <Text role="bodySmall" color="textMuted">Nada neste dia.</Text>}
          <Text role="caption" color="textMuted" style={{ marginTop: 6 }}>Total do dia: {formatBRL(sel.reduce((a, x) => a + (x.kind === 'income' ? x.amountCents : -x.amountCents), 0))}</Text>
        </Card> : null}
      </Screen>
    </View>
  );
}
