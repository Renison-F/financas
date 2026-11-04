import React, { useMemo, useState } from 'react';
import { View, KeyboardAvoidingView, Platform } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { formatBRL, FREQUENCY_LABELS_PT, type RecurrenceFrequency, withinLimit } from '@financas/core';
import { Text, Button, MoneyInput, Input, useColors, spacing } from '../design';
import { useAppStore, type TransactionInput } from '../state/appStore';
import { Field, Segmented, DateField, Toggle, Collapsible, ConfirmSheet, SheetScroll, ChipSelect } from '../features/shared/FormBits';

type Kind = 'expense' | 'income' | 'transfer' | 'card_purchase';
const KIND_OPTIONS: { value: Kind; label: string }[] = [{ value: 'expense', label: 'Despesa' }, { value: 'income', label: 'Receita' }, { value: 'transfer', label: 'Transferir' }, { value: 'card_purchase', label: 'Cartão' }];

/** New/edit transaction in 3 taps: amount (keyboard open), category chips, account/card; advanced options collapsed. */
export default function TransactionScreen() {
  const params = useLocalSearchParams<{ id?: string; kind?: string; planned?: string; cardId?: string; date?: string }>();
  const router = useRouter();
  const c = useColors();
  const insets = useSafeAreaInsets();
  const ledger = useAppStore((s) => s.ledger);
  const access = useAppStore((s) => s.access);
  const save = useAppStore((s) => s.saveTransaction);
  const settle = useAppStore((s) => s.settleTransaction);
  const remove = useAppStore((s) => s.deleteTransaction);
  const today = useAppStore((s) => s.today)();
  const existing = useMemo(() => (params.id ? ledger.transactions.find((t) => t.id === params.id) : undefined), [params.id, ledger.transactions]);
  const editable = !existing || (['expense', 'income', 'transfer', 'card_purchase'] as string[]).includes(existing.kind);

  const [kind, setKind] = useState<Kind>((existing?.kind as Kind) ?? ((params.kind as Kind) || 'expense'));
  const [amount, setAmount] = useState<number | null>(existing?.amountCents ?? null);
  const [description, setDescription] = useState(existing?.description ?? '');
  const [categoryId, setCategoryId] = useState<string | undefined>(existing?.categoryId);
  const [accountId, setAccountId] = useState<string | undefined>(existing?.accountId ?? ledger.accounts.find((a) => !a.archived)?.id);
  const [toAccountId, setToAccountId] = useState<string | undefined>(existing?.toAccountId);
  const [cardId, setCardId] = useState<string | undefined>(existing?.cardId ?? params.cardId ?? ledger.cards.find((x) => !x.archived)?.id);
  const [date, setDate] = useState(existing?.date ?? params.date ?? today);
  const [planned, setPlanned] = useState(existing ? existing.status !== 'settled' : params.planned === '1');
  const [installments, setInstallments] = useState<number>(1);
  const [recurrence, setRecurrence] = useState<RecurrenceFrequency | undefined>();
  const [tags, setTags] = useState<string[]>(existing?.tags ?? []);
  const [notes, setNotes] = useState(existing?.notes ?? '');
  const [merchant, setMerchant] = useState(existing?.merchant ?? '');
  const [error, setError] = useState<string | undefined>();
  const [saving, setSaving] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [partial, setPartial] = useState<number | null>(null);

  const categories = ledger.categories.filter((x) => !x.archived && x.kind === (kind === 'income' ? 'income' : 'expense'));
  const accounts = ledger.accounts.filter((a) => !a.archived);
  const cards = ledger.cards.filter((x) => !x.archived);

  const onSave = async () => {
    setError(undefined);
    if (!amount || amount <= 0) return setError('Informe um valor maior que zero.');
    if (kind === 'card_purchase' && !cardId) return setError('Cadastre um cartão antes de registrar uma compra no cartão.');
    if (kind !== 'card_purchase' && !accountId) return setError('Cadastre uma conta antes de registrar.');
    if (kind === 'transfer' && (!toAccountId || toAccountId === accountId)) return setError('Escolha duas contas diferentes.');
    if (!existing && kind === 'card_purchase' && installments > 1 && !withinLimit(access, 'cards', 0).ok && access.tier === 'free' && cards.length > 1) { /* installments are free; nothing to gate */ }
    setSaving(true);
    try {
      const input: TransactionInput = {
        id: existing?.id, kind, amountCents: amount, date, description: description.trim().slice(0, 140), categoryId: kind === 'transfer' ? undefined : categoryId,
        accountId: kind === 'card_purchase' ? undefined : accountId, toAccountId: kind === 'transfer' ? toAccountId : undefined, cardId: kind === 'card_purchase' ? cardId : undefined,
        status: kind === 'card_purchase' ? 'settled' : planned ? 'planned' : existing?.status === 'partially_paid' ? 'partially_paid' : 'settled', dueDate: planned ? date : undefined, tags, notes: notes.trim() || undefined, merchant: merchant.trim() || undefined,
      };
      await save({ ...input, installments: kind === 'card_purchase' && !existing ? installments : undefined, recurrence: recurrence && !existing ? { frequency: recurrence } : undefined });
      router.back();
    } catch (e) { setError(e instanceof Error ? e.message : 'Não foi possível salvar.'); }
    finally { setSaving(false); }
  };

  const title = existing ? (editable ? 'Editar lançamento' : existing.description || 'Lançamento') : 'Novo lançamento';
  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1, backgroundColor: c.bg, paddingTop: Platform.OS === 'ios' ? spacing.sm : insets.top }}>
      <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: spacing.md, paddingVertical: spacing.xs }}>
        <Button title="Cancelar" variant="ghost" onPress={() => router.back()} />
        <Text role="title" numberOfLines={1} style={{ flex: 1, textAlign: 'center', fontSize: 17 }}>{title}</Text>
        {editable ? <Button title="Salvar" variant="ghost" onPress={() => void onSave()} loading={saving} testID="save-transaction" /> : <View style={{ width: 90 }} />}
      </View>
      <SheetScroll>
        {!existing ? <Segmented options={KIND_OPTIONS} value={kind} onChange={(k) => { setKind(k); setCategoryId(undefined); }} /> : null}
        <MoneyInput label="Valor" valueCents={amount} onChangeCents={setAmount} autoFocus={!existing} error={error && !amount ? error : undefined} testID="amount" />
        <Input label="Descrição" value={description} onChangeText={setDescription} placeholder={kind === 'income' ? 'Ex.: Salário' : kind === 'transfer' ? 'Ex.: Para a poupança' : 'Ex.: Mercado'} maxLength={140} />
        {kind !== 'transfer' ? <Field label="Categoria"><ChipSelect options={categories.map((x) => ({ value: x.id, label: x.name }))} value={categoryId} onChange={setCategoryId} allowNone /></Field> : null}
        {kind === 'card_purchase' ? <Field label="Cartão">{cards.length ? <ChipSelect options={cards.map((x) => ({ value: x.id, label: x.name }))} value={cardId} onChange={setCardId} /> : <Button title="Cadastrar cartão" variant="secondary" onPress={() => router.push('/cards/new')} />}</Field>
          : <Field label={kind === 'transfer' ? 'De' : 'Conta'}>{accounts.length ? <ChipSelect options={accounts.map((x) => ({ value: x.id, label: x.name }))} value={accountId} onChange={setAccountId} /> : <Button title="Cadastrar conta" variant="secondary" onPress={() => router.push('/accounts/new')} />}</Field>}
        {kind === 'transfer' ? <Field label="Para"><ChipSelect options={accounts.filter((a) => a.id !== accountId).map((x) => ({ value: x.id, label: x.name }))} value={toAccountId} onChange={setToAccountId} /></Field> : null}
        <DateField label={planned ? 'Vencimento' : 'Data'} value={date} onChange={setDate} />
        {kind !== 'card_purchase' && kind !== 'transfer' ? <Toggle label={kind === 'income' ? 'Ainda não recebi (previsto)' : 'Ainda não paguei (previsto)'} value={planned} onChange={setPlanned} help="Lançamentos previstos entram em 'contas a pagar' e no cálculo de 'pode gastar'." /> : null}
        {kind === 'card_purchase' && !existing ? <Field label="Parcelas"><ChipSelect options={[1, 2, 3, 4, 5, 6, 10, 12, 18, 24].map((n) => ({ value: String(n), label: n === 1 ? 'À vista' : `${n}x` }))} value={String(installments)} onChange={(v) => setInstallments(Number(v ?? 1))} />{installments > 1 && amount ? <Text role="caption" color="textMuted">{installments}x de {formatBRL(Math.round(amount / installments))} (centavos ajustados nas primeiras parcelas), uma por fatura.</Text> : null}</Field> : null}
        <Collapsible title="Mais opções">
          {!existing ? <Field label="Repetir"><ChipSelect options={(['monthly', 'weekly', 'biweekly', 'yearly'] as RecurrenceFrequency[]).map((f) => ({ value: f, label: FREQUENCY_LABELS_PT[f] }))} value={recurrence} onChange={setRecurrence} allowNone /><Text role="caption" color="textMuted">Cria uma série; os próximos 3 meses ficam como previstos e novos são gerados automaticamente.</Text></Field> : null}
          {ledger.tags.length ? <Field label="Tags"><View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>{ledger.tags.map((t) => <Button key={t.id} title={t.name} variant={tags.includes(t.id) ? 'secondary' : 'ghost'} compact onPress={() => setTags(tags.includes(t.id) ? tags.filter((x) => x !== t.id) : [...tags, t.id])} />)}</View></Field> : null}
          <Input label="Estabelecimento" value={merchant} onChangeText={setMerchant} placeholder="Opcional" />
          <Input label="Observações" value={notes} onChangeText={setNotes} placeholder="Opcional" multiline style={{ height: 80, paddingTop: 12 }} maxLength={500} />
          {access.tier === 'free' ? <Text role="caption" color="textMuted">Anexos e comprovantes fazem parte do SerenaCash Plus.</Text> : <Text role="caption" color="textMuted">Anexos: adicione pelo detalhe do lançamento após salvar.</Text>}
        </Collapsible>
        {error ? <Text role="bodySmall" color="negative">{error}</Text> : null}
        {existing && existing.status !== 'settled' && existing.status !== 'cancelled' ? (
          <View style={{ gap: spacing.sm, marginTop: spacing.sm }}>
            <Text role="label" color="textMuted">Pagamento</Text>
            <Button title={existing.kind === 'income' ? 'Marcar como recebido' : 'Marcar como pago'} icon="check" onPress={async () => { await settle(existing.id); router.back(); }} fullWidth />
            <MoneyInput label={`Pagar parte (restam ${formatBRL(existing.amountCents - (existing.paidCents ?? 0))})`} valueCents={partial} onChangeCents={setPartial} />
            <Button title="Registrar pagamento parcial" variant="secondary" disabled={!partial} onPress={async () => { if (partial) { await settle(existing.id, { paidCents: partial }); router.back(); } }} fullWidth />
          </View>
        ) : null}
        {existing ? <Button title={existing.seriesId || existing.installment ? 'Excluir este e os próximos' : 'Excluir lançamento'} variant="destructive" icon="trash" onPress={() => setConfirmDelete(true)} fullWidth style={{ marginTop: spacing.md }} /> : null}
      </SheetScroll>
      <ConfirmSheet visible={confirmDelete} title="Excluir lançamento?" text={existing?.seriesId ? 'Os lançamentos desta série a partir desta data serão excluídos. Você pode desfazer em seguida.' : 'Você pode desfazer em seguida.'} confirmLabel="Excluir" onConfirm={async () => { setConfirmDelete(false); if (existing) { await remove(existing.id, existing.seriesId ? 'series' : 'one'); router.back(); } }} onCancel={() => setConfirmDelete(false)} />
    </KeyboardAvoidingView>
  );
}
