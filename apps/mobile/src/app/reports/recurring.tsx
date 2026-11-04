import React from 'react';
import { View } from 'react-native';
import { recurringExpenses, monthKeyOf, formatBRL } from '@financas/core';
import { Screen, Card, Text, Money, ListRow, EmptyState, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

export default function RecurringReport() {
  const { ledger, today } = useAppStore();
  const rows = recurringExpenses(ledger, monthKeyOf(today()));
  const total = rows.reduce((a, r) => a + r.amountCents, 0);
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Gastos recorrentes" />
      <Screen>
        <Card style={{ marginBottom: spacing.sm }}><Text role="label" color="textMuted">Por mês</Text><Money cents={total} role="headline" /><Text role="caption" color="textMuted">Séries cadastradas e gastos repetidos (mesma descrição e valor em 3+ meses dos últimos 6).</Text></Card>
        <Card>{rows.length ? rows.map((r) => <ListRow key={r.key} icon="receipt" title={r.description || 'Recorrente'} description={`${r.months.length} meses · ${r.seriesId ? 'série' : 'detectado'}`} right={<Money cents={r.amountCents} />} />) : <EmptyState icon="receipt" title="Nada recorrente detectado" text="Com 3 meses de histórico o app encontra assinaturas e contas repetidas." />}</Card>
        {rows.length ? <Text role="caption" color="textMuted" style={{ marginTop: spacing.sm }}>Dica: revise assinaturas que você não usa; cada {formatBRL(rows[rows.length - 1]?.amountCents ?? 0)}/mês são {formatBRL((rows[rows.length - 1]?.amountCents ?? 0) * 12)}/ano.</Text> : null}
      </Screen>
    </View>
  );
}
