import React, { useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { accountBalance, withinLimit, type AccountType } from '@financas/core';
import { Screen, Button, MoneyInput, Input, Text, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Field, Segmented, Toggle, DateField, ChipSelect } from '../../features/shared/FormBits';

const COLORS = ['#0B5563', '#176B4E', '#C0703E', '#8A5200', '#A93A29', '#4F5E61'];

export default function AccountEdit() {
  const { id } = useLocalSearchParams<{ id?: string }>();
  const router = useRouter();
  const { ledger, saveAccount, adjustBalance, access, today } = useAppStore();
  const existing = id ? ledger.accounts.find((a) => a.id === id) : undefined;
  const [name, setName] = useState(existing?.name ?? '');
  const [type, setType] = useState<AccountType>(existing?.type ?? 'checking');
  const [opening, setOpening] = useState<number | null>(existing?.openingBalanceCents ?? null);
  const [openingDate, setOpeningDate] = useState(existing?.openingDate ?? today());
  const [include, setInclude] = useState(existing?.includeInAvailability ?? true);
  const [color, setColor] = useState(existing?.color ?? COLORS[0]!);
  const [adjust, setAdjust] = useState<number | null>(null);
  const [error, setError] = useState<string | undefined>();
  const limit = withinLimit(access, 'accounts', ledger.accounts.filter((a) => !a.archived && !a.deletedAt).length);
  const save = async () => {
    if (!name.trim()) return setError('Dê um nome à conta.');
    if (!existing && !limit.ok) return router.push('/paywall?feature=unlimited_accounts');
    await saveAccount({ id: existing?.id, name: name.trim(), type, openingBalanceCents: opening ?? 0, openingDate, includeInAvailability: include, color });
    router.back();
  };
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={existing ? 'Editar conta' : 'Nova conta'} right={<Button title="Salvar" variant="ghost" onPress={() => void save()} />} />
      <Screen>
        <View style={{ gap: spacing.md }}>
          <Input label="Nome" value={name} onChangeText={setName} placeholder="Ex.: Nubank, Carteira" error={error} autoFocus={!existing} />
          <Field label="Tipo"><Segmented options={[{ value: 'checking', label: 'Banco' }, { value: 'digital_wallet', label: 'Digital' }, { value: 'cash', label: 'Dinheiro' }, { value: 'savings', label: 'Poupança' }]} value={type as 'checking'} onChange={(v) => setType(v)} /></Field>
          <MoneyInput label={existing ? 'Saldo inicial (na data abaixo)' : 'Saldo atual'} valueCents={opening} onChangeCents={setOpening} help={existing ? 'Para corrigir o saldo de hoje, use o ajuste abaixo.' : 'O saldo de hoje vira o saldo inicial da conta.'} />
          <DateField label="Data do saldo inicial" value={openingDate} onChange={setOpeningDate} />
          <Toggle label='Considerar no "pode gastar"' value={include} onChange={setInclude} help="Desligue para reservas, investimentos ou contas que você não usa no dia a dia." />
          <Field label="Cor"><ChipSelect options={COLORS.map((c) => ({ value: c, label: ' ' }))} value={color} onChange={(v) => setColor(v ?? COLORS[0]!)} /></Field>
          {existing ? <View style={{ gap: spacing.sm, marginTop: spacing.md }}>
            <Text role="title">Ajustar saldo</Text>
            <Text role="bodySmall" color="textMuted">Saldo calculado hoje: {new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(accountBalance(ledger, existing.id) / 100)}. Informe o saldo real e o app cria um ajuste com a diferença (conciliação).</Text>
            <MoneyInput label="Saldo real hoje" valueCents={adjust} onChangeCents={setAdjust} />
            <Button title="Registrar ajuste" variant="secondary" disabled={adjust === null} onPress={async () => { if (adjust !== null) { await adjustBalance(existing.id, adjust, today()); router.back(); } }} />
          </View> : null}
          {!limit.ok && !existing ? <Text role="bodySmall" color="warning">Plano gratuito: até {limit.limit} contas. Contas ilimitadas no SerenaCash Plus.</Text> : null}
        </View>
      </Screen>
    </View>
  );
}
