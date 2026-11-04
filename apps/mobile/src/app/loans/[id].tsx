import React, { useState } from 'react';
import { View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { loanPosition, simulateExtraPayment, formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, MoneyInput, EmptyState, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';
import { Segmented } from '../../features/shared/FormBits';

export default function LoanDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { ledger, today, saveTransaction } = useAppStore();
  const loan = ledger.loans.find((l) => l.id === id);
  const [extra, setExtra] = useState<number | null>(null);
  const [mode, setMode] = useState<'reduce_term' | 'reduce_installment'>('reduce_term');
  if (!loan) return <View><StackHeader title="Empréstimo" /><EmptyState icon="alert" title="Não encontrado" /></View>;
  const p = loanPosition(ledger, loan, today());
  const remaining = p.schedule.length - p.paidInstallments;
  const sim = extra ? simulateExtraPayment(loan, p.outstandingCents, extra, Math.max(1, remaining), mode) : null;
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title={loan.name} right={<Button title="Editar" variant="ghost" compact icon="edit" onPress={() => router.push(`/loans/new?id=${loan.id}`)} />} />
      <Screen>
        <Card style={{ marginBottom: spacing.sm }}>
          <Text role="label" color="textMuted">Saldo devedor</Text><Money cents={p.outstandingCents} role="headline" />
          <Text role="bodySmall" color="textMuted" style={{ marginTop: 4 }}>{p.paidInstallments} de {loan.termMonths} parcelas pagas · {formatBRL(p.paidCents)} pagos{p.extraAmortizationCents ? ` (${formatBRL(p.extraAmortizationCents)} além das parcelas)` : ''}</Text>
          <Text role="bodySmall" color="textMuted">Quitar hoje ≈ <Text role="bodySmall">{formatBRL(p.payoffTodayCents)}</Text> (valor presente das parcelas restantes à taxa do contrato, sem tarifas)</Text>
          {p.overdueInstallments.length ? <Text role="bodySmall" color="negative" style={{ marginTop: 4 }}>{p.overdueInstallments.length} parcela(s) atrasada(s).</Text> : null}
        </Card>
        <Card style={{ marginBottom: spacing.sm, gap: spacing.sm }}>
          <CardHeader title="Simular pagamento extra" />
          <MoneyInput label="Valor extra" valueCents={extra} onChangeCents={setExtra} />
          <Segmented options={[{ value: 'reduce_term', label: 'Reduzir prazo' }, { value: 'reduce_installment', label: 'Reduzir parcela' }]} value={mode} onChange={setMode} />
          {sim ? <Text role="body">{sim.newBalanceCents === 0 ? 'Quita o empréstimo.' : mode === 'reduce_term' ? `Novo prazo: ${sim.newTermMonths} parcelas de ${formatBRL(sim.newInstallmentCents)} (antes ${remaining}).` : `Nova parcela: ${formatBRL(sim.newInstallmentCents)} por ${sim.newTermMonths} meses.`}</Text> : null}
          <Button title="Registrar pagamento extra" variant="secondary" disabled={!extra} onPress={async () => { if (extra) { await saveTransaction({ kind: 'loan_payment', amountCents: extra, date: today(), description: `Amortização: ${loan.name}`, accountId: loan.accountId, loanId: loan.id, status: 'settled' }); setExtra(null); } }} fullWidth />
        </Card>
        <Card>
          <CardHeader title="Tabela" />
          {p.schedule.map((r) => (
            <View key={r.number} style={{ flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 6, opacity: r.number <= p.paidInstallments ? 0.5 : 1 }}>
              <Text role="bodySmall" style={{ width: 36 }}>{r.number}</Text>
              <Text role="bodySmall" color="textMuted" style={{ width: 60 }}>{r.dueDate.slice(8, 10)}/{r.dueDate.slice(5, 7)}/{r.dueDate.slice(2, 4)}</Text>
              <Text role="bodySmall" tabular style={{ flex: 1, textAlign: 'right' }}>{formatBRL(r.installmentCents)}</Text>
              <Text role="caption" color="textMuted" tabular style={{ flex: 1, textAlign: 'right' }}>j {formatBRL(r.interestCents)}</Text>
              <Text role="caption" color="textMuted" tabular style={{ flex: 1, textAlign: 'right' }}>{formatBRL(r.balanceAfterCents)}</Text>
            </View>
          ))}
        </Card>
      </Screen>
    </View>
  );
}
