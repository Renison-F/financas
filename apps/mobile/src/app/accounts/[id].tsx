import React, { useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { accountBalance, searchTransactions, formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, ListRow, EmptyState, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { ConfirmSheet } from '../../features/shared/FormBits';
import { kindLabel } from '../../features/dashboard/widgets';

export default function AccountDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { ledger, archiveAccount, deleteAccount } = useAppStore();
  const [confirm, setConfirm] = useState<'archive' | 'delete' | null>(null);
  const [err, setErr] = useState<string | undefined>();
  const account = ledger.accounts.find((a) => a.id === id);
  if (!account) return <View><StackHeader title="Conta" /><EmptyState icon="alert" title="Conta não encontrada" /></View>;
  const history = searchTransactions(ledger, '', { accountIds: [account.id] }).slice(0, 50);
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={account.name} right={<Button title="Editar" variant="ghost" compact icon="edit" onPress={() => router.push(`/accounts/edit?id=${account.id}`)} />} />
      <Screen>
        <Card style={{ marginBottom: spacing.sm }}><Text role="label" color="textMuted">Saldo atual</Text><Money cents={accountBalance(ledger, account.id)} role="headline" signed /><Text role="caption" color="textMuted">Saldo inicial {formatBRL(account.openingBalanceCents)} em {account.openingDate.slice(8, 10)}/{account.openingDate.slice(5, 7)}/{account.openingDate.slice(0, 4)}{account.archived ? ' · arquivada' : ''}</Text></Card>
        <Card>
          <CardHeader title="Histórico" action={<Button title="Novo" variant="ghost" compact icon="plus" onPress={() => router.push('/transaction')} />} />
          {history.length ? history.map((t) => <ListRow key={t.id} icon={t.kind === 'income' ? 'arrow-down' : t.kind === 'transfer' ? 'swap' : 'arrow-up'} title={t.description || kindLabel(t.kind)} description={`${t.date.slice(8, 10)}/${t.date.slice(5, 7)} · ${kindLabel(t.kind)}${t.status !== 'settled' ? ' · previsto' : ''}`} right={<Money cents={(t.kind === 'income' || t.kind === 'loan_disbursement' || t.kind === 'goal_withdrawal' || (t.kind === 'transfer' && t.toAccountId === account.id) || (t.kind === 'balance_adjustment' && t.toAccountId === account.id)) ? t.amountCents : -t.amountCents} signed />} onPress={() => router.push(`/transaction?id=${t.id}`)} />) : <EmptyState icon="list" title="Sem movimentações" />}
        </Card>
        <View style={{ gap: spacing.xs, marginTop: spacing.md }}>
          <Button title={account.archived ? 'Reativar conta' : 'Arquivar conta'} variant="secondary" onPress={() => (account.archived ? void archiveAccount(account.id, false).then(() => router.back()) : setConfirm('archive'))} fullWidth />
          <Button title="Excluir conta" variant="destructive" icon="trash" onPress={() => setConfirm('delete')} fullWidth />
          {err ? <Text role="bodySmall" color="negative">{err}</Text> : null}
        </View>
      </Screen>
      <ConfirmSheet visible={confirm === 'archive'} title="Arquivar conta?" text="Ela some das listas e do 'pode gastar', mas o histórico continua. Você pode reativar depois." confirmLabel="Arquivar" destructive={false} onConfirm={async () => { setConfirm(null); await archiveAccount(account.id); router.back(); }} onCancel={() => setConfirm(null)} />
      <ConfirmSheet visible={confirm === 'delete'} title="Excluir conta?" text="Só é possível excluir contas sem lançamentos. Se houver movimentações, arquive." confirmLabel="Excluir" onConfirm={async () => { setConfirm(null); const r = await deleteAccount(account.id); if (r.ok) router.back(); else setErr(r.reason); }} onCancel={() => setConfirm(null)} />
    </View>
  );
}
