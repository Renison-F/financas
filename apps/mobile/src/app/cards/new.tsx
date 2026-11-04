import React, { useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { withinLimit } from '@financas/core';
import { Screen, Button, MoneyInput, Input, Text, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Field, ChipSelect } from '../../features/shared/FormBits';

export default function CardEdit() {
  const { id } = useLocalSearchParams<{ id?: string }>();
  const router = useRouter();
  const { ledger, saveCard, access } = useAppStore();
  const existing = id ? ledger.cards.find((c) => c.id === id) : undefined;
  const [name, setName] = useState(existing?.name ?? '');
  const [limit, setLimit] = useState<number | null>(existing?.limitCents ?? null);
  const [closing, setClosing] = useState(String(existing?.closingDay ?? 20));
  const [due, setDue] = useState(String(existing?.dueDay ?? 27));
  const [accountId, setAccountId] = useState<string | undefined>(existing?.defaultPaymentAccountId);
  const [error, setError] = useState<string | undefined>();
  const used = ledger.transactions.some((t) => t.cardId === existing?.id);
  const lim = withinLimit(access, 'cards', ledger.cards.filter((c) => !c.archived && !c.deletedAt).length);
  const save = async () => {
    const cd = Number(closing), dd = Number(due);
    if (!name.trim()) return setError('Dê um nome ao cartão.');
    if (!Number.isInteger(cd) || cd < 1 || cd > 31 || !Number.isInteger(dd) || dd < 1 || dd > 31) return setError('Dias de fechamento e vencimento devem estar entre 1 e 31.');
    if (existing && used && cd !== existing.closingDay) return setError('Não dá para mudar o fechamento de um cartão com compras: as faturas mudariam de mês. Crie outro cartão.');
    if (!existing && !lim.ok) return router.push('/paywall?feature=unlimited_cards');
    await saveCard({ id: existing?.id, name: name.trim(), limitCents: limit ?? 0, closingDay: cd, dueDay: dd, defaultPaymentAccountId: accountId });
    router.back();
  };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={existing ? 'Editar cartão' : 'Novo cartão'} right={<Button title="Salvar" variant="ghost" onPress={() => void save()} />} />
      <Screen>
        <View style={{ gap: spacing.md }}>
          <Input label="Nome" value={name} onChangeText={setName} placeholder="Ex.: Cartão roxo" autoFocus={!existing} />
          <MoneyInput label="Limite" valueCents={limit} onChangeCents={setLimit} />
          <View style={{ flexDirection: 'row', gap: spacing.sm }}>
            <View style={{ flex: 1 }}><Input label="Dia do fechamento" value={closing} onChangeText={setClosing} keyboardType="number-pad" maxLength={2} help="Compras depois desse dia vão para a próxima fatura." /></View>
            <View style={{ flex: 1 }}><Input label="Dia do vencimento" value={due} onChangeText={setDue} keyboardType="number-pad" maxLength={2} /></View>
          </View>
          {ledger.accounts.length ? <Field label="Conta usada para pagar a fatura"><ChipSelect options={ledger.accounts.filter((a) => !a.archived).map((a) => ({ value: a.id, label: a.name }))} value={accountId} onChange={setAccountId} allowNone /></Field> : null}
          {error ? <Text role="bodySmall" color="negative">{error}</Text> : null}
          {!lim.ok && !existing ? <Text role="bodySmall" color="warning">Plano gratuito: {lim.limit} cartão. Cartões ilimitados no SerenaCash Plus.</Text> : null}
        </View>
      </Screen>
    </View>
  );
}
