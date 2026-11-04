import React, { useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { withinLimit, type GoalKind } from '@financas/core';
import { Screen, Button, MoneyInput, Input, Text, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Field, ChipSelect, Toggle, DateField } from '../../features/shared/FormBits';

export default function GoalEdit() {
  const { id } = useLocalSearchParams<{ id?: string }>();
  const router = useRouter();
  const { ledger, saveGoal, access, today } = useAppStore();
  const existing = id ? ledger.goals.find((g) => g.id === id) : undefined;
  const [name, setName] = useState(existing?.name ?? '');
  const [kind, setKind] = useState<GoalKind>(existing?.kind ?? 'emergency_fund');
  const [target, setTarget] = useState<number | null>(existing?.targetCents ?? null);
  const [hasDate, setHasDate] = useState(!!existing?.targetDate);
  const [date, setDate] = useState(existing?.targetDate ?? today());
  const [accountId, setAccountId] = useState<string | undefined>(existing?.accountId);
  const [reserved, setReserved] = useState(existing?.reserved ?? true);
  const [archived, setArchived] = useState(existing?.archived ?? false);
  const [error, setError] = useState<string | undefined>();
  const lim = withinLimit(access, 'goals', ledger.goals.filter((g) => !g.deletedAt && !g.archived).length);
  const save = async () => {
    if (!name.trim()) return setError('Dê um nome à meta.');
    if (!target) return setError('Informe o valor da meta.');
    if (!existing && !lim.ok) return router.push('/paywall?feature=unlimited_goals');
    await saveGoal({ id: existing?.id, name: name.trim(), kind, targetCents: target, targetDate: hasDate ? date : undefined, accountId, reserved, archived });
    router.back();
  };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={existing ? 'Editar meta' : 'Nova meta'} right={<Button title="Salvar" variant="ghost" onPress={() => void save()} />} />
      <Screen>
        <View style={{ gap: spacing.md }}>
          <Input label="Nome" value={name} onChangeText={setName} placeholder="Ex.: Reserva de emergência" autoFocus={!existing} />
          <Field label="Tipo"><ChipSelect options={[{ value: 'emergency_fund', label: 'Reserva de emergência' }, { value: 'savings', label: 'Economia' }, { value: 'purchase', label: 'Compra' }, { value: 'debt_payoff', label: 'Quitar dívida' }, { value: 'other', label: 'Outro' }]} value={kind} onChange={(v) => setKind(v ?? 'other')} /></Field>
          <MoneyInput label="Valor da meta" valueCents={target} onChangeCents={setTarget} error={error} />
          <Toggle label="Tem prazo" value={hasDate} onChange={setHasDate} />
          {hasDate ? <DateField label="Até quando" value={date} onChange={setDate} /> : null}
          <Field label="Onde o dinheiro fica"><ChipSelect options={[{ value: '__none__', label: 'Fora das contas do app' }, ...ledger.accounts.filter((a) => !a.archived).map((a) => ({ value: a.id, label: a.name }))]} value={accountId ?? '__none__'} onChange={(v) => setAccountId(v === '__none__' ? undefined : v)} /><Text role="caption" color="textMuted">Se ficar dentro de uma conta considerada no "pode gastar", o valor guardado é descontado de lá.</Text></Field>
          <Toggle label='Proteger do "pode gastar"' value={reserved} onChange={setReserved} help="O valor guardado nunca aparece como disponível." />
          {existing ? <Toggle label="Arquivar meta" value={archived} onChange={setArchived} /> : null}
          {!lim.ok && !existing ? <Text role="bodySmall" color="warning">Plano gratuito: até {lim.limit} metas. Ilimitadas no SerenaCash Plus.</Text> : null}
        </View>
      </Screen>
    </View>
  );
}
