import React, { useState } from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { budgetsForMonth, formatBRL, monthKeyOf, addMonthsToKey } from '@financas/core';
import { Screen, Card, Text, Money, Button, RhythmBar, EmptyState, Chip, spacing, RHYTHM_LABEL } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

export default function BudgetsScreen() {
  const { ledger, today } = useAppStore();
  const router = useRouter();
  const [month, setMonth] = useState(monthKeyOf(today()));
  const statuses = budgetsForMonth(ledger, month, today());
  const label = (m: string) => `${m.slice(5, 7)}/${m.slice(0, 4)}`;
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Orçamentos" right={<Button title="Novo" variant="ghost" icon="plus" compact onPress={() => router.push('/budgets/new')} />} />
      <Screen>
        <View style={{ flexDirection: 'row', gap: 8, marginBottom: spacing.sm }}><Chip label={`‹ ${label(addMonthsToKey(month, -1))}`} onPress={() => setMonth(addMonthsToKey(month, -1))} /><Chip label={label(month)} selected /><Chip label={`${label(addMonthsToKey(month, 1))} ›`} onPress={() => setMonth(addMonthsToKey(month, 1))} /></View>
        <View style={{ gap: spacing.sm }}>
          {statuses.length ? statuses.map((b) => (
            <Card key={b.budget.id}>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                <View style={{ flex: 1 }}><Text role="title">{b.category?.name ?? 'Orçamento do mês'}</Text><Text role="bodySmall" color="textMuted">{formatBRL(b.spentCents)} de {formatBRL(b.limitCents)}{b.plannedCents ? ` · ${formatBRL(b.plannedCents)} previstos` : ''}</Text></View>
                <Money cents={b.remainingCents} signed />
              </View>
              <View style={{ marginTop: 10 }}><RhythmBar percent={b.percentUsed} expectedPercent={b.expectedPercent} state={b.pace} /></View>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginTop: 6 }}>
                <Text role="label" color={b.pace === 'sereno' ? 'positive' : b.pace === 'atencao' ? 'warning' : 'negative'}>{RHYTHM_LABEL[b.pace]} · {b.percentUsed}% usado, {b.expectedPercent}% do mês</Text>
                <Button title="Editar" variant="ghost" compact onPress={() => router.push(`/budgets/new?id=${b.budget.id}`)} />
              </View>
            </Card>
          )) : <Card><EmptyState icon="plan" title="Nenhum orçamento" text="Defina um limite para uma categoria ou para o mês inteiro. A marca de hoje mostra se o ritmo está sereno." actionTitle="Criar orçamento" onAction={() => router.push('/budgets/new')} /></Card>}
        </View>
        <Text role="caption" color="textMuted" style={{ marginTop: spacing.md }}>Sereno: gasto até a marca de hoje. Atenção: até 10 pontos acima. Agitado: além disso ou acima do limite. Subcategorias somam no orçamento da categoria-mãe.</Text>
      </Screen>
    </View>
  );
}
