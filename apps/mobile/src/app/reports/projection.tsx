import React, { useState } from 'react';
import { View } from 'react-native';
import { projectBalance, addDays, endOfMonth, monthKeyOf, formatBRL } from '@financas/core';
import { Screen, Card, Text, Money, Chip, ListRow, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

export default function ProjectionReport() {
  const { ledger, today } = useAppStore();
  const t = today();
  const [h, setH] = useState<'month' | '30' | '60' | '90'>('month');
  const until = h === 'month' ? endOfMonth(monthKeyOf(t)) : addDays(t, Number(h));
  const p = projectBalance(ledger, t, until);
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Projeção de saldo" />
      <Screen>
        <View style={{ flexDirection: 'row', gap: 8, marginBottom: spacing.sm, flexWrap: 'wrap' }}>{(['month', '30', '60', '90'] as const).map((x) => <Chip key={x} label={x === 'month' ? 'Fim do mês' : `${x} dias`} selected={h === x} onPress={() => setH(x)} />)}</View>
        <Card style={{ marginBottom: spacing.sm }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><View><Text role="label" color="textMuted">Hoje</Text><Money cents={p.startCents} role="title" signed /></View><View style={{ alignItems: 'flex-end' }}><Text role="label" color="textMuted">Em {until.slice(8, 10)}/{until.slice(5, 7)}</Text><Money cents={p.endCents} role="title" signed /></View></View>
          <Text role="bodySmall" color={p.minCents < 0 ? 'negative' : 'textMuted'} style={{ marginTop: 8 }}>{p.minCents < 0 ? `Atenção: o saldo fica negativo (${formatBRL(p.minCents)}) em ${p.minDate.slice(8, 10)}/${p.minDate.slice(5, 7)}.` : `Menor saldo no período: ${formatBRL(p.minCents)} em ${p.minDate.slice(8, 10)}/${p.minDate.slice(5, 7)}.`}</Text>
        </Card>
        <Card>{p.points.length ? p.points.map((x, i) => <ListRow key={i} icon={x.kind === 'income' ? 'arrow-down' : x.kind === 'card' ? 'card' : x.kind === 'loan' ? 'bank' : 'receipt'} title={x.label} description={`${x.date.slice(8, 10)}/${x.date.slice(5, 7)} · saldo após ${formatBRL(x.balanceAfterCents)}`} right={<Money cents={x.cents} signed />} />) : <Text role="bodySmall" color="textMuted">Nada previsto no período. Cadastre contas e receitas previstas para projetar.</Text>}</Card>
        <Text role="caption" color="textMuted" style={{ marginTop: spacing.sm }}>Considera lançamentos previstos, parcelas de empréstimo e faturas de cartão até o vencimento. Faturas atrasadas entram hoje.</Text>
      </Screen>
    </View>
  );
}
