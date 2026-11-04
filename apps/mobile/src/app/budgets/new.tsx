import React, { useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { withinLimit, monthKeyOf } from '@financas/core';
import { Screen, Button, MoneyInput, Text, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Field, ChipSelect, Toggle, ConfirmSheet } from '../../features/shared/FormBits';

export default function BudgetEdit() {
  const { id } = useLocalSearchParams<{ id?: string }>();
  const router = useRouter();
  const { ledger, saveBudget, deleteBudget, access, today } = useAppStore();
  const existing = id ? ledger.budgets.find((b) => b.id === id) : undefined;
  const [categoryId, setCategoryId] = useState<string | undefined>(existing?.categoryId);
  const [limit, setLimit] = useState<number | null>(existing?.limitCents ?? null);
  const [onlyThisMonth, setOnlyThisMonth] = useState(!!existing?.month);
  const [confirm, setConfirm] = useState(false);
  const [error, setError] = useState<string | undefined>();
  const lim = withinLimit(access, 'budgets', ledger.budgets.filter((b) => !b.deletedAt).length);
  const save = async () => {
    if (!limit) return setError('Informe o limite.');
    if (!existing && !lim.ok) return router.push('/paywall?feature=unlimited_budgets');
    await saveBudget({ id: existing?.id, categoryId, limitCents: limit, month: onlyThisMonth ? monthKeyOf(today()) : undefined });
    router.back();
  };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={existing ? 'Editar orçamento' : 'Novo orçamento'} right={<Button title="Salvar" variant="ghost" onPress={() => void save()} />} />
      <Screen>
        <View style={{ gap: spacing.md }}>
          <Field label="Para"><ChipSelect options={[{ value: '__all__', label: 'O mês inteiro' }, ...ledger.categories.filter((c) => c.kind === 'expense' && !c.archived).map((c) => ({ value: c.id, label: c.name }))]} value={categoryId ?? '__all__'} onChange={(v) => setCategoryId(v === '__all__' ? undefined : v)} /></Field>
          <MoneyInput label="Limite mensal" valueCents={limit} onChangeCents={setLimit} error={error} autoFocus={!existing} />
          <Toggle label="Só para este mês" value={onlyThisMonth} onChange={setOnlyThisMonth} help="Desligado = vale todo mês até você mudar." />
          {!lim.ok && !existing ? <Text role="bodySmall" color="warning">Plano gratuito: até {lim.limit} orçamentos. Ilimitados no SerenaCash Plus.</Text> : null}
          {existing ? <Button title="Excluir orçamento" variant="destructive" icon="trash" onPress={() => setConfirm(true)} fullWidth /> : null}
        </View>
      </Screen>
      <ConfirmSheet visible={confirm} title="Excluir orçamento?" text="Os lançamentos não são afetados." confirmLabel="Excluir" onConfirm={async () => { setConfirm(false); if (existing) { await deleteBudget(existing.id); router.back(); } }} onCancel={() => setConfirm(false)} />
    </View>
  );
}
