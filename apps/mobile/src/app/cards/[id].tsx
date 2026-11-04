import React, { useState } from 'react';
import { View, Pressable } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { invoice, invoiceMonths, currentInvoiceMonth, cardCommitment, addMonthsToKey, formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, ListRow, EmptyState, Icon, MoneyInput, useColors, spacing, touch, RhythmBar } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Field, ChipSelect, DateField } from '../../features/shared/FormBits';

const STATE_PT = { open: 'aberta', closed: 'fechada', paid: 'paga', overdue: 'atrasada', future: 'futura' } as const;

export default function CardDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const c = useColors();
  const { ledger, payInvoice, today } = useAppStore();
  const card = ledger.cards.find((x) => x.id === id);
  const [month, setMonth] = useState(card ? currentInvoiceMonth(card, today()) : '');
  const [payAmount, setPayAmount] = useState<number | null>(null);
  const [payAccount, setPayAccount] = useState<string | undefined>(card?.defaultPaymentAccountId ?? ledger.accounts[0]?.id);
  const [payDate, setPayDate] = useState(today());
  const [paying, setPaying] = useState(false);
  if (!card) return <View><StackHeader title="Cartão" /><EmptyState icon="alert" title="Cartão não encontrado" /></View>;
  const inv = invoice(ledger, card, month, today());
  const cm = cardCommitment(ledger, card, today());
  const months = invoiceMonths(ledger, card);
  const label = `${month.slice(5, 7)}/${month.slice(0, 4)}`;
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={card.name} right={<Button title="Editar" variant="ghost" compact icon="edit" onPress={() => router.push(`/cards/new?id=${card.id}`)} />} />
      <Screen>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: spacing.sm }}>
          <Pressable accessibilityRole="button" accessibilityLabel="Fatura anterior" onPress={() => setMonth(addMonthsToKey(month, -1))} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="chevron-left" color={c.primary} /></Pressable>
          <Text role="title">Fatura {label}</Text>
          <Pressable accessibilityRole="button" accessibilityLabel="Próxima fatura" onPress={() => setMonth(addMonthsToKey(month, 1))} style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="chevron-right" color={c.primary} /></Pressable>
        </View>
        <Card style={{ marginBottom: spacing.sm }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-end' }}><View><Text role="label" color="textMuted">Fatura {STATE_PT[inv.state]}</Text><Money cents={inv.remainingCents} role="headline" /></View><View style={{ alignItems: 'flex-end' }}><Text role="caption" color="textMuted">fecha {inv.closingDate.slice(8, 10)}/{inv.closingDate.slice(5, 7)}</Text><Text role="caption" color="textMuted">vence {inv.dueDate.slice(8, 10)}/{inv.dueDate.slice(5, 7)}</Text></View></View>
          <Text role="bodySmall" color="textMuted" style={{ marginTop: 6 }}>Total {formatBRL(inv.totalCents)} · pago {formatBRL(inv.paidCents)}</Text>
          <View style={{ marginTop: 10 }}><RhythmBar percent={card.limitCents ? (cm.outstandingCents / card.limitCents) * 100 : 0} label="Limite comprometido" /></View>
          <Text role="caption" color="textMuted" style={{ marginTop: 4 }}>Limite livre {formatBRL(cm.availableLimitCents)} de {formatBRL(card.limitCents)} (fatura atual {formatBRL(cm.currentInvoiceCents)} + fechadas {formatBRL(cm.closedUnpaidCents)} + futuras {formatBRL(cm.futureCents)})</Text>
        </Card>
        <Card style={{ marginBottom: spacing.sm }}>
          <CardHeader title="Compras desta fatura" action={<Button title="Nova compra" variant="ghost" compact icon="plus" onPress={() => router.push(`/transaction?kind=card_purchase&cardId=${card.id}`)} />} />
          {inv.purchases.length ? inv.purchases.sort((a, b) => a.date.localeCompare(b.date)).map((t) => <ListRow key={t.id} icon="card" title={t.description || 'Compra'} description={`${t.date.slice(8, 10)}/${t.date.slice(5, 7)}${t.installment ? ` · parcela ${t.installment.number}/${t.installment.of}` : ''}`} right={<Money cents={t.amountCents} />} onPress={() => router.push(`/transaction?id=${t.id}`)} />) : <Text role="bodySmall" color="textMuted">Nenhuma compra nesta fatura.</Text>}
          {inv.payments.length ? <><Text role="label" color="textMuted" style={{ marginTop: spacing.sm }}>Pagamentos</Text>{inv.payments.map((t) => <ListRow key={t.id} icon="check" title="Pagamento" description={`${t.date.slice(8, 10)}/${t.date.slice(5, 7)}`} right={<Money cents={t.amountCents} color="positive" />} />)}</> : null}
        </Card>
        {inv.remainingCents > 0 && inv.state !== 'future' ? <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Pagar fatura" />
          <Text role="bodySmall" color="textMuted">O pagamento sai da conta e abate a fatura. Não vira despesa de novo: as compras já contaram quando aconteceram.</Text>
          <View style={{ flexDirection: 'row', gap: 8 }}><Button title={`Total ${formatBRL(inv.remainingCents)}`} variant="secondary" compact onPress={() => setPayAmount(inv.remainingCents)} /><Button title="Mínimo (15%)" variant="ghost" compact onPress={() => setPayAmount(Math.round(inv.remainingCents * 0.15))} /></View>
          <MoneyInput label="Valor" valueCents={payAmount} onChangeCents={setPayAmount} />
          <Field label="Conta"><ChipSelect options={ledger.accounts.filter((a) => !a.archived).map((a) => ({ value: a.id, label: a.name }))} value={payAccount} onChange={setPayAccount} /></Field>
          <DateField label="Data do pagamento" value={payDate} onChange={setPayDate} />
          <Button title="Registrar pagamento" disabled={!payAmount || !payAccount} loading={paying} onPress={async () => { if (!payAmount || !payAccount) return; setPaying(true); try { await payInvoice(card.id, month, payAmount, payAccount, payDate); setPayAmount(null); } finally { setPaying(false); } }} fullWidth />
        </Card> : null}
        <Card>
          <CardHeader title="Histórico de faturas" />
          {months.length ? months.slice().reverse().map((m) => { const i = invoice(ledger, card, m, today()); return <ListRow key={m} icon="receipt" title={`${m.slice(5, 7)}/${m.slice(0, 4)}`} description={`${STATE_PT[i.state]} · vence ${i.dueDate.slice(8, 10)}/${i.dueDate.slice(5, 7)}`} right={<Money cents={i.totalCents} />} onPress={() => setMonth(m)} />; }) : <Text role="bodySmall" color="textMuted">Ainda sem faturas.</Text>}
        </Card>
        <Text role="caption" color="textMuted" style={{ marginTop: spacing.sm }}>Regra: compras até o dia {card.closingDay} entram na fatura do mês; depois disso, na seguinte. Parcelas caem uma por fatura.</Text>
      </Screen>
    </View>
  );
}
