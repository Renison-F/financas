import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { goalProgress, formatBRL } from '@financas/core';
import { Screen, Card, Text, Money, Button, RhythmBar, EmptyState, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

const KIND: Record<string, string> = { savings: 'Economia', emergency_fund: 'Reserva de emergência', purchase: 'Compra', debt_payoff: 'Quitar dívida', other: 'Outro' };

export default function GoalsScreen() {
  const { ledger, today } = useAppStore();
  const router = useRouter();
  const goals = ledger.goals.filter((g) => !g.deletedAt && !g.archived).map((g) => goalProgress(ledger, g, today()));
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Metas e reservas" right={<Button title="Nova" variant="ghost" icon="plus" compact onPress={() => router.push('/goals/new')} />} />
      <Screen>
        <View style={{ gap: spacing.sm }}>
          {goals.length ? goals.map((p) => (
            <Card key={p.goal.id}>
              <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}><View style={{ flex: 1 }}><Text role="title">{p.goal.name}</Text><Text role="bodySmall" color="textMuted">{KIND[p.goal.kind]}{p.goal.reserved ? ' · protegida' : ''}{p.goal.targetDate ? ` · até ${p.goal.targetDate.slice(8, 10)}/${p.goal.targetDate.slice(5, 7)}/${p.goal.targetDate.slice(0, 4)}` : ''}</Text></View><Money cents={p.savedCents} role="title" /></View>
              <View style={{ marginTop: 10 }}><RhythmBar percent={p.percent} expectedPercent={p.expectedPercent} /></View>
              <Text role="bodySmall" color="textMuted" style={{ marginTop: 6 }}>{p.percent}% de {formatBRL(p.goal.targetCents)} · faltam {formatBRL(p.remainingCents)}{p.suggestedMonthlyCents ? ` · guarde ${formatBRL(p.suggestedMonthlyCents)}/mês (${p.monthsLeft} meses)` : ''}</Text>
              <View style={{ flexDirection: 'row', gap: 8, marginTop: 8 }}><Button title="Guardar" variant="secondary" compact onPress={() => router.push(`/goals/${p.goal.id}?action=deposit`)} /><Button title="Resgatar" variant="ghost" compact onPress={() => router.push(`/goals/${p.goal.id}?action=withdraw`)} /><Button title="Editar" variant="ghost" compact onPress={() => router.push(`/goals/new?id=${p.goal.id}`)} /></View>
            </Card>
          )) : <Card><EmptyState icon="target" title="Nenhuma meta" text="Uma reserva de emergência com 3 meses de despesas é um ótimo primeiro objetivo." actionTitle="Criar meta" onAction={() => router.push('/goals/new')} /></Card>}
        </View>
      </Screen>
    </View>
  );
}
