import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { Screen, Card, Button, ListRow, Money, EmptyState, RhythmBar, Text, spacing } from '../../design';
import { useDashboardData } from '../../features/dashboard/useDashboardData';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { formatBRL } from '@financas/core';

export default function CardsScreen() {
  const data = useDashboardData();
  const router = useRouter();
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Cartões de crédito" right={<Button title="Novo" variant="ghost" icon="plus" compact onPress={() => router.push('/cards/new')} />} />
      <Screen>
        <View style={{ gap: spacing.sm }}>
          {data.cards.length ? data.cards.map(({ card, invoice, commitment }) => (
            <Card key={card.id}>
              <ListRow icon="card" title={card.name} description={`fecha dia ${card.closingDay} · vence dia ${card.dueDay}`} right={<Money cents={invoice.remainingCents} role="title" />} onPress={() => router.push(`/cards/${card.id}`)} chevron />
              <Text role="caption" color="textMuted">Fatura {invoice.month.slice(5, 7)}/{invoice.month.slice(0, 4)} ({invoice.state === 'open' ? 'aberta' : invoice.state === 'paid' ? 'paga' : invoice.state === 'overdue' ? 'atrasada' : invoice.state}) · limite livre {formatBRL(commitment.availableLimitCents)} de {formatBRL(card.limitCents)}</Text>
              <View style={{ marginTop: 8 }}><RhythmBar percent={card.limitCents ? (commitment.outstandingCents / card.limitCents) * 100 : 0} label={`${Math.round(card.limitCents ? (commitment.outstandingCents / card.limitCents) * 100 : 0)}% do limite comprometido`} /></View>
            </Card>
          )) : <Card><EmptyState icon="card" title="Nenhum cartão" text="Com fechamento e vencimento o app mostra a fatura certa." actionTitle="Adicionar cartão" onAction={() => router.push('/cards/new')} /></Card>}
          {data.cards.length ? <Button title="Compras parceladas" variant="secondary" onPress={() => router.push('/cards/installments')} fullWidth /> : null}
        </View>
      </Screen>
    </View>
  );
}
