import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { invoice, invoiceMonths, currentInvoiceMonth, formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, ListRow, EmptyState, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

/** Projection of installment commitments per future invoice, across all cards. */
export default function InstallmentsScreen() {
  const { ledger, today } = useAppStore();
  const router = useRouter();
  const cards = ledger.cards.filter((c) => !c.archived);
  const byMonth = new Map<string, { month: string; cents: number; count: number }>();
  for (const card of cards) { const cur = currentInvoiceMonth(card, today()); for (const m of invoiceMonths(ledger, card)) { if (m < cur) continue; const inv = invoice(ledger, card, m, today()); const rows = inv.purchases.filter((p) => p.installment); if (!rows.length) continue; const e = byMonth.get(m) ?? { month: m, cents: 0, count: 0 }; e.cents += rows.reduce((a, r) => a + r.amountCents, 0); e.count += rows.length; byMonth.set(m, e); } }
  const months = [...byMonth.values()].sort((a, b) => a.month.localeCompare(b.month));
  const groups = new Map<string, { description: string; paid: number; of: number; remaining: number }>();
  for (const t of ledger.transactions) if (t.installment && t.kind === 'card_purchase' && !t.deletedAt) { const g = groups.get(t.installment.groupId) ?? { description: t.description.replace(/ \(\d+\/\d+\)$/, ''), paid: 0, of: t.installment.of, remaining: 0 }; if (t.invoiceMonth && t.invoiceMonth < currentInvoiceMonth(cards.find((c) => c.id === t.cardId) ?? { closingDay: 1 }, today())) g.paid++; else g.remaining += t.amountCents; groups.set(t.installment.groupId, g); }
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Compras parceladas" />
      <Screen>
        <Card style={{ marginBottom: spacing.sm }}><CardHeader title="Comprometido por fatura" />{months.length ? months.map((m) => <ListRow key={m.month} icon="calendar" title={`${m.month.slice(5, 7)}/${m.month.slice(0, 4)}`} description={`${m.count} parcela(s)`} right={<Money cents={m.cents} />} />) : <EmptyState icon="card" title="Nenhuma parcela futura" />}</Card>
        <Card><CardHeader title="Por compra" />{groups.size ? [...groups.values()].map((g, i) => <ListRow key={i} icon="card" title={g.description || 'Compra parcelada'} description={`${g.paid}/${g.of} faturas passadas · restam ${formatBRL(g.remaining)}`} right={<Money cents={g.remaining} />} />) : <Text role="bodySmall" color="textMuted">Nenhuma compra parcelada.</Text>}</Card>
        <Text role="caption" color="textMuted" style={{ marginTop: spacing.sm }} onPress={() => router.push('/cards')}>Ver cartões</Text>
      </Screen>
    </View>
  );
}
