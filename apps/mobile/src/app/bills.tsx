import React, { useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { overdue, upcoming, addDays, endOfMonth, monthKeyOf, formatBRL, pendingCents } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, ListRow, EmptyState, Chip, spacing } from '../design';
import { useAppStore } from '../state/appStore';
import { StackHeader } from '../features/shared/ScreenHeader';

export default function BillsScreen() {
  const { filter } = useLocalSearchParams<{ filter?: string }>();
  const { ledger, today, settleTransaction } = useAppStore();
  const router = useRouter();
  const [horizon, setHorizon] = useState<'month' | '30' | '90'>('month');
  const t = today();
  const until = horizon === 'month' ? endOfMonth(monthKeyOf(t)) : addDays(t, horizon === '30' ? 30 : 90);
  const late = overdue(ledger, t);
  const soon = upcoming(ledger, t, until);
  const dm = (d: string) => `${d.slice(8, 10)}/${d.slice(5, 7)}`;
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Contas a pagar" right={<Button title="Nova" variant="ghost" icon="plus" compact onPress={() => router.push('/transaction?kind=expense&planned=1')} />} />
      <Screen>
        <View style={{ flexDirection: 'row', gap: 8, marginBottom: spacing.sm }}><Chip label="Este mês" selected={horizon === 'month'} onPress={() => setHorizon('month')} /><Chip label="30 dias" selected={horizon === '30'} onPress={() => setHorizon('30')} /><Chip label="90 dias" selected={horizon === '90'} onPress={() => setHorizon('90')} /></View>
        {late.length || filter === 'overdue' ? <Card style={{ marginBottom: spacing.sm }}><CardHeader title={`Atrasadas · ${formatBRL(late.reduce((a, x) => a + pendingCents(x), 0))}`} />{late.length ? late.map((x) => <ListRow key={x.id} icon="alert" title={x.description || 'Conta'} description={`venceu ${dm(x.dueDate ?? x.date)}`} right={<View style={{ alignItems: 'flex-end', gap: 4 }}><Money cents={pendingCents(x)} color="negative" /><Button title="Pagar" variant="secondary" compact onPress={() => void settleTransaction(x.id)} /></View>} onPress={() => router.push(`/transaction?id=${x.id}`)} />) : <Text role="bodySmall" color="textMuted">Nenhuma conta atrasada.</Text>}</Card> : null}
        <Card>
          <CardHeader title={`A vencer até ${dm(until)} · ${formatBRL(soon.reduce((a, x) => a + pendingCents(x), 0))}`} />
          {soon.length ? soon.map((x) => <ListRow key={x.id} icon={x.kind === 'loan_payment' ? 'bank' : 'receipt'} title={x.description || 'Conta'} description={`vence ${dm(x.dueDate ?? x.date)}${x.status === 'partially_paid' ? ` · já pago ${formatBRL(x.paidCents ?? 0)}` : ''}`} right={<View style={{ alignItems: 'flex-end', gap: 4 }}><Money cents={pendingCents(x)} /><Button title="Pagar" variant="ghost" compact onPress={() => void settleTransaction(x.id)} /></View>} onPress={() => router.push(`/transaction?id=${x.id}`)} />) : <EmptyState icon="check" title="Nada a vencer no período" actionTitle="Nova conta a pagar" onAction={() => router.push('/transaction?kind=expense&planned=1')} />}
        </Card>
        <Text role="caption" color="textMuted" style={{ marginTop: spacing.sm }}>"Pagar" marca como pago hoje na conta do lançamento. Para pagar parte, abra o lançamento.</Text>
      </Screen>
    </View>
  );
}
