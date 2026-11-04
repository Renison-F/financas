import React, { useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { goalProgress, formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, MoneyInput, ListRow, EmptyState, RhythmBar, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Field, ChipSelect, DateField, Segmented } from '../../features/shared/FormBits';

/** Goal detail: deposits/withdrawals move real money between an account and the goal. */
export default function GoalDetail() {
  const { id, action } = useLocalSearchParams<{ id: string; action?: string }>();
  const router = useRouter();
  const { ledger, saveTransaction, today } = useAppStore();
  const goal = ledger.goals.find((g) => g.id === id);
  const [mode, setMode] = useState<'deposit' | 'withdraw'>(action === 'withdraw' ? 'withdraw' : 'deposit');
  const [amount, setAmount] = useState<number | null>(null);
  const [accountId, setAccountId] = useState<string | undefined>(goal?.accountId ?? ledger.accounts[0]?.id);
  const [date, setDate] = useState(today());
  const [busy, setBusy] = useState(false);
  if (!goal) return <View><StackHeader title="Meta" /><EmptyState icon="alert" title="Meta não encontrada" /></View>;
  const p = goalProgress(ledger, goal, today());
  const moves = ledger.transactions.filter((t) => t.goalId === goal.id && !t.deletedAt).sort((a, b) => b.date.localeCompare(a.date));
  const submit = async () => {
    if (!amount) return;
    setBusy(true);
    try {
      if (mode === 'deposit') await saveTransaction({ kind: 'goal_deposit', amountCents: amount, date, description: `Guardado: ${goal.name}`, accountId, toAccountId: goal.accountId, goalId: goal.id, status: 'settled' });
      else await saveTransaction({ kind: 'goal_withdrawal', amountCents: amount, date, description: `Resgate: ${goal.name}`, accountId: goal.accountId, toAccountId: accountId, goalId: goal.id, status: 'settled' });
      setAmount(null);
    } finally { setBusy(false); }
  };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={goal.name} right={<Button title="Editar" variant="ghost" compact icon="edit" onPress={() => router.push(`/goals/new?id=${goal.id}`)} />} />
      <Screen>
        <Card style={{ marginBottom: spacing.sm }}>
          <Text role="label" color="textMuted">Guardado</Text><Money cents={p.savedCents} role="headline" />
          <View style={{ marginTop: 10 }}><RhythmBar percent={p.percent} expectedPercent={p.expectedPercent} /></View>
          <Text role="bodySmall" color="textMuted" style={{ marginTop: 6 }}>{p.percent}% de {formatBRL(goal.targetCents)} · faltam {formatBRL(p.remainingCents)}{p.suggestedMonthlyCents ? ` · sugestão ${formatBRL(p.suggestedMonthlyCents)}/mês` : ''}</Text>
        </Card>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <Segmented options={[{ value: 'deposit', label: 'Guardar' }, { value: 'withdraw', label: 'Resgatar' }]} value={mode} onChange={setMode} />
          <MoneyInput label="Valor" valueCents={amount} onChangeCents={setAmount} />
          <Field label={mode === 'deposit' ? 'Sai da conta' : 'Vai para a conta'}><ChipSelect options={ledger.accounts.filter((a) => !a.archived).map((a) => ({ value: a.id, label: a.name }))} value={accountId} onChange={setAccountId} /></Field>
          <DateField label="Data" value={date} onChange={setDate} />
          <Button title={mode === 'deposit' ? 'Guardar' : 'Resgatar'} onPress={() => void submit()} disabled={!amount || (!accountId && !goal.accountId)} loading={busy} fullWidth />
        </Card>
        <Card><CardHeader title="Movimentações" />{moves.length ? moves.map((t) => <ListRow key={t.id} icon={t.kind === 'goal_deposit' ? 'arrow-up' : 'arrow-down'} title={t.description} description={`${t.date.slice(8, 10)}/${t.date.slice(5, 7)}/${t.date.slice(0, 4)}`} right={<Money cents={t.kind === 'goal_deposit' ? t.amountCents : -t.amountCents} signed />} onPress={() => router.push(`/transaction?id=${t.id}`)} />) : <Text role="bodySmall" color="textMuted">Nenhuma movimentação ainda.</Text>}</Card>
      </Screen>
    </View>
  );
}
