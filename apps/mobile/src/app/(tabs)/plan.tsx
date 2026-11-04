import React from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { formatBRL } from '@financas/core';
import { Screen, Card, CardHeader, Text, Money, Button, RhythmBar, ListRow, EmptyState, spacing } from '../../design';
import { useDashboardData } from '../../features/dashboard/useDashboardData';

/** "Está sereno?" — budgets, goals, cards and loans at a glance, each with its own screen. */
export default function PlanScreen() {
  const data = useDashboardData();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const go = (r: string) => () => router.push(r as never);
  const dm = (d: string) => `${d.slice(8, 10)}/${d.slice(5, 7)}`;
  return (
    <Screen title="Planejar" subtitle="Orçamentos, metas, cartões e empréstimos" style={{ paddingTop: insets.top }}>
      <View style={{ gap: spacing.sm }}>
        <Card>
          <CardHeader title="Orçamentos" action={<Button title="Novo" variant="ghost" compact icon="plus" onPress={go('/budgets/new')} />} />
          {data.budgets.length ? data.budgets.map((b) => <View key={b.budget.id} style={{ marginBottom: 12 }}><View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="body">{b.category?.name ?? 'Orçamento do mês'}</Text><Text role="bodySmall" color="textMuted" tabular>{formatBRL(b.spentCents)} de {formatBRL(b.limitCents)}</Text></View><View style={{ marginTop: 6 }}><RhythmBar percent={b.percentUsed} expectedPercent={b.expectedPercent} state={b.pace} /></View></View>) : <EmptyState icon="plan" title="Nenhum orçamento" text="Defina limites por categoria ou para o mês inteiro." actionTitle="Criar orçamento" onAction={go('/budgets/new')} />}
          {data.budgets.length ? <Button title="Ver todos" variant="ghost" onPress={go('/budgets')} /> : null}
        </Card>
        <Card>
          <CardHeader title="Metas e reservas" action={<Button title="Nova" variant="ghost" compact icon="plus" onPress={go('/goals/new')} />} />
          {data.goals.length ? data.goals.map((g) => <ListRow key={g.goal.id} icon="target" title={g.goal.name} description={`${g.percent}% · faltam ${formatBRL(g.remainingCents)}${g.suggestedMonthlyCents ? ` · ${formatBRL(g.suggestedMonthlyCents)}/mês` : ''}`} right={<Money cents={g.savedCents} />} onPress={go(`/goals/${g.goal.id}`)} chevron />) : <EmptyState icon="target" title="Nenhuma meta" text="Comece por uma reserva de emergência." actionTitle="Criar meta" onAction={go('/goals/new')} />}
        </Card>
        <Card>
          <CardHeader title="Cartões" action={<Button title="Novo" variant="ghost" compact icon="plus" onPress={go('/cards/new')} />} />
          {data.cards.length ? data.cards.map(({ card, invoice, commitment }) => <ListRow key={card.id} icon="card" title={card.name} description={`fatura ${invoice.state === 'open' ? 'aberta' : invoice.state === 'paid' ? 'paga' : invoice.state === 'overdue' ? 'atrasada' : invoice.state === 'closed' ? 'fechada' : 'futura'} · vence ${dm(invoice.dueDate)} · livre ${formatBRL(commitment.availableLimitCents)}`} right={<Money cents={invoice.remainingCents} />} onPress={go(`/cards/${card.id}`)} chevron />) : <EmptyState icon="card" title="Nenhum cartão" actionTitle="Adicionar cartão" onAction={go('/cards/new')} />}
        </Card>
        <Card>
          <CardHeader title="Empréstimos e dívidas" action={<Button title="Novo" variant="ghost" compact icon="plus" onPress={go('/loans/new')} />} />
          {data.loans.length ? data.loans.map((p) => <ListRow key={p.loan.id} icon="bank" title={p.loan.name} description={p.nextDue ? `próxima ${dm(p.nextDue.dueDate)} · ${formatBRL(p.nextDue.installmentCents)} · ${p.paidInstallments}/${p.loan.termMonths} pagas` : 'quitado'} right={<Money cents={p.outstandingCents} />} onPress={go(`/loans/${p.loan.id}`)} chevron />) : <Text role="bodySmall" color="textMuted">Nenhum empréstimo cadastrado.</Text>}
        </Card>
        <Card>
          <CardHeader title="Projeção de saldo" action={<Button title="Ver" variant="ghost" compact onPress={go('/reports/projection')} />} />
          <Text role="bodySmall" color="textMuted">Veja como o saldo evolui com as contas e receitas previstas até o fim do mês.</Text>
        </Card>
      </View>
    </Screen>
  );
}
