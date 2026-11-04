import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { accountBalance, consolidatedBalance } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, ListRow, EmptyState, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

const TYPE_LABEL: Record<string, string> = { cash: 'Dinheiro', checking: 'Conta bancária', savings: 'Poupança', digital_wallet: 'Carteira digital', investment: 'Investimento', other: 'Outra' };

export default function AccountsScreen() {
  const ledger = useAppStore((s) => s.ledger);
  const router = useRouter();
  const active = ledger.accounts.filter((a) => !a.archived && !a.deletedAt);
  const archived = ledger.accounts.filter((a) => a.archived && !a.deletedAt);
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Contas e carteiras" right={<Button title="Nova" variant="ghost" icon="plus" compact onPress={() => router.push('/accounts/new')} />} />
      <Screen>
        <Card style={{ marginBottom: spacing.sm }}><Text role="label" color="textMuted">Saldo consolidado</Text><Money cents={consolidatedBalance(ledger)} role="headline" signed /><Text role="caption" color="textMuted">Transferências entre contas não alteram o total.</Text></Card>
        <Card>
          <CardHeader title="Ativas" />
          {active.length ? active.map((a) => <ListRow key={a.id} icon={a.type === 'cash' ? 'wallet' : 'bank'} title={a.name} description={`${TYPE_LABEL[a.type] ?? a.type}${a.includeInAvailability ? '' : ' · fora do pode gastar'}`} right={<Money cents={accountBalance(ledger, a.id)} signed />} onPress={() => router.push(`/accounts/${a.id}`)} chevron />) : <EmptyState icon="wallet" title="Nenhuma conta" actionTitle="Adicionar conta" onAction={() => router.push('/accounts/new')} />}
        </Card>
        {archived.length ? <Card style={{ marginTop: spacing.sm }}><CardHeader title="Arquivadas" />{archived.map((a) => <ListRow key={a.id} icon="wallet" title={a.name} right={<Money cents={accountBalance(ledger, a.id)} />} onPress={() => router.push(`/accounts/${a.id}`)} chevron />)}</Card> : null}
      </Screen>
    </View>
  );
}
