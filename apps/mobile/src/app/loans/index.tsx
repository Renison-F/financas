import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { loanPosition, formatBRL } from '@financas/core';
import { Screen, Card, Text, Money, Button, ListRow, EmptyState, RhythmBar, spacing } from '../../design';
import { useAppStore } from '../../state/appStore';
import { StackHeader } from '../../features/shared/ScreenHeader';

export default function LoansScreen() {
  const { ledger, today } = useAppStore();
  const router = useRouter();
  const loans = ledger.loans.filter((l) => !l.deletedAt && !l.archived).map((l) => loanPosition(ledger, l, today()));
  return (
    <View style={{ flex: 1 }}>
      <StackHeader title="Empréstimos e dívidas" right={<Button title="Novo" variant="ghost" icon="plus" compact onPress={() => router.push('/loans/new')} />} />
      <Screen>
        <View style={{ gap: spacing.sm }}>
          {loans.length ? loans.map((p) => (
            <Card key={p.loan.id}>
              <ListRow icon="bank" title={p.loan.name} description={`${p.loan.system === 'price' ? 'Price' : 'SAC'} · ${p.loan.monthlyRatePercent}% a.m. · ${p.paidInstallments}/${p.loan.termMonths} pagas${p.overdueInstallments.length ? ` · ${p.overdueInstallments.length} atrasada(s)` : ''}`} right={<Money cents={p.outstandingCents} role="title" />} onPress={() => router.push(`/loans/${p.loan.id}`)} chevron />
              <RhythmBar percent={p.loan.termMonths ? (p.paidInstallments / p.loan.termMonths) * 100 : 0} label="Parcelas pagas" />
              <Text role="caption" color="textMuted" style={{ marginTop: 6 }}>{p.nextDue ? `Próxima: ${formatBRL(p.nextDue.installmentCents)} em ${p.nextDue.dueDate.slice(8, 10)}/${p.nextDue.dueDate.slice(5, 7)} · quitar hoje ≈ ${formatBRL(p.payoffTodayCents)}` : 'Quitado'}</Text>
            </Card>
          )) : <Card><EmptyState icon="bank" title="Nenhum empréstimo" text="Cadastre financiamentos, crediário ou dívidas para ver saldo devedor, juros e simulação de quitação." actionTitle="Cadastrar" onAction={() => router.push('/loans/new')} /></Card>}
        </View>
      </Screen>
    </View>
  );
}
