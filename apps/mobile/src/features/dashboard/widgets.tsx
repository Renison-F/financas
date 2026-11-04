import React from 'react';
import { View, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { formatBRL, widgetById, type WidgetId, FREQUENCY_LABELS_PT } from '@financas/core';
import { Card, CardHeader, Text, Money, Button, RhythmBar, ListRow, EmptyState, Icon, useColors, spacing, radius } from '../../design';
import type { DashboardData } from './useDashboardData';
import { useAppStore } from '../../state/appStore';

const monthLabel = (key: string) => { const [y, m] = key.split('-'); return new Date(Number(y), Number(m) - 1, 1).toLocaleDateString('pt-BR', { month: 'short' }).replace('.', ''); };
const dayMonth = (d: string) => `${d.slice(8, 10)}/${d.slice(5, 7)}`;

function Action({ label, route }: { label: string; route: string }) {
  const router = useRouter();
  return <Button title={label} variant="ghost" compact onPress={() => router.push(route as never)} />;
}

/** Each widget: real data, empty state with an action, tap navigation. Errors are caught by the ErrorBoundary in the list. */
export function Widget({ id, data }: { id: WidgetId; data: DashboardData }) {
  const router = useRouter();
  const c = useColors();
  const def = widgetById(id);
  const go = (route: string) => () => router.push(route as never);
  switch (id) {
    case 'available': {
      const av = data.availability;
      if (!av.hasAccounts) return <Card><CardHeader title="Pode gastar" /><EmptyState icon="wallet" title="Comece pela sua conta" text="Com o saldo de uma conta o app já mostra quanto cabe gastar." actionTitle="Adicionar conta" onAction={go('/accounts/new')} /></Card>;
      const tone = av.status === 'negative' ? 'negative' : av.status === 'tight' ? 'warning' : 'positive';
      return (
        <Pressable accessibilityRole="button" accessibilityHint="Abre a explicação do cálculo" onPress={go('/available')}>
          <Card style={{ backgroundColor: av.status === 'negative' ? c.negativeContainer : c.primaryContainer }}>
            <Text role="label" color={av.status === 'negative' ? 'negative' : 'onPrimaryContainer'}>Pode gastar até {dayMonth(av.horizonEnd)}</Text>
            <View style={{ marginTop: 6 }}><Money cents={av.availableCents} role="moneyHero" color={av.status === 'negative' ? 'negative' : 'onPrimaryContainer'} /></View>
            <Text role="bodySmall" color={av.status === 'negative' ? 'negative' : 'onPrimaryContainer'} style={{ marginTop: 8 }}>
              {av.status === 'negative' ? 'As contas registradas passam do dinheiro disponível.' : av.status === 'tight' ? 'Está apertado: o que sobra cobre pouco mais que as contas.' : 'Estimativa com o que está registrado, não um saldo garantido.'}
            </Text>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 }}>
              <Text role="label" color={tone}>{av.mode === 'otimista' ? 'Modo otimista' : 'Modo prudente'}</Text>
              <Text role="label" color="onPrimaryContainer">Como calculamos ›</Text>
            </View>
          </Card>
        </Pressable>
      );
    }
    case 'consolidated_balance':
      return <Card><CardHeader title="Saldo total" action={<Action label="Contas" route="/accounts" />} />{data.accounts.length ? <Money cents={data.consolidated} role="headline" signed /> : <EmptyState icon="wallet" title="Nenhuma conta" actionTitle="Adicionar" onAction={go('/accounts/new')} />}</Card>;
    case 'account_balances':
      return <Card><CardHeader title="Saldos por conta" action={<Action label="Ver todas" route="/accounts" />} />{data.accounts.length ? data.accounts.map((a) => <ListRow key={a.account.id} icon={a.account.type === 'cash' ? 'wallet' : 'bank'} title={a.account.name} right={<Money cents={a.balance} signed />} onPress={go(`/accounts/${a.account.id}`)} />) : <EmptyState icon="wallet" title="Nenhuma conta" actionTitle="Adicionar" onAction={go('/accounts/new')} />}</Card>;
    case 'income':
      return <Card><CardHeader title="Receitas" action={<Action label="Ver" route="/transactions?kind=income" />} /><Money cents={data.totals.incomeSettled} role="headline" color="positive" /><Text role="bodySmall" color="textMuted">Previstas: {formatBRL(data.totals.incomePlanned)}</Text></Card>;
    case 'expenses':
      return <Card><CardHeader title="Despesas" action={<Action label="Ver" route="/transactions?kind=expense" />} /><Money cents={data.totals.expenseSettled} role="headline" /><Text role="bodySmall" color="textMuted">Previstas: {formatBRL(data.totals.expensePlanned)} · no cartão: {formatBRL(data.totals.cardPurchases)}</Text></Card>;
    case 'bills_to_pay':
      return <Card><CardHeader title="Contas a pagar" action={<Action label="Todas" route="/bills" />} />{data.bills.length ? data.bills.slice(0, 5).map((t) => <ListRow key={t.id} icon="receipt" title={t.description || 'Conta'} description={`vence ${dayMonth(t.dueDate ?? t.date)}`} right={<Money cents={t.amountCents - (t.paidCents ?? 0)} />} onPress={go(`/transaction?id=${t.id}`)} />) : <EmptyState icon="check" title="Nada a pagar até o fim do período" text="Cadastre contas previstas para o 'pode gastar' ficar honesto." actionTitle="Nova conta a pagar" onAction={go('/transaction?kind=expense&planned=1')} />}</Card>;
    case 'overdue_bills':
      return <Card><CardHeader title="Contas atrasadas" />{data.overdue.length ? data.overdue.slice(0, 5).map((t) => <ListRow key={t.id} icon="alert" iconColor={c.negative} title={t.description || 'Conta'} description={`venceu ${dayMonth(t.dueDate ?? t.date)}`} right={<Money cents={t.amountCents - (t.paidCents ?? 0)} color="negative" />} onPress={go(`/transaction?id=${t.id}`)} />) : <Text role="bodySmall" color="textMuted">Nenhuma conta atrasada.</Text>}</Card>;
    case 'upcoming_due':
      return <Card><CardHeader title="Próximos 7 dias" action={<Action label="Calendário" route="/calendar" />} />{data.next7.length ? data.next7.slice(0, 5).map((t) => <ListRow key={t.id} icon="calendar" title={t.description || 'Conta'} description={dayMonth(t.dueDate ?? t.date)} right={<Money cents={t.amountCents - (t.paidCents ?? 0)} />} onPress={go(`/transaction?id=${t.id}`)} />) : <Text role="bodySmall" color="textMuted">Nenhum vencimento nos próximos 7 dias.</Text>}</Card>;
    case 'cards_invoices':
      return <Card><CardHeader title="Cartões e faturas" action={<Action label="Ver" route="/cards" />} />{data.cards.length ? data.cards.map(({ card, invoice: inv, commitment }) => (
        <Pressable key={card.id} accessibilityRole="button" onPress={go(`/cards/${card.id}`)} style={{ paddingVertical: 8 }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="body">{card.name}</Text><Money cents={inv.remainingCents} /></View>
          <Text role="bodySmall" color="textMuted">Fatura {inv.state === 'open' ? 'aberta' : inv.state} · vence {dayMonth(inv.dueDate)} · limite livre {formatBRL(commitment.availableLimitCents)}</Text>
          <View style={{ marginTop: 6 }}><RhythmBar percent={card.limitCents ? (commitment.outstandingCents / card.limitCents) * 100 : 0} label={`${Math.round(card.limitCents ? (commitment.outstandingCents / card.limitCents) * 100 : 0)}% do limite comprometido`} /></View>
        </Pressable>
      )) : <EmptyState icon="card" title="Nenhum cartão" text="Cadastre fechamento e vencimento para acompanhar a fatura." actionTitle="Adicionar cartão" onAction={go('/cards/new')} />}</Card>;
    case 'installments':
      return <Card><CardHeader title="Compras parceladas" action={<Action label="Detalhes" route="/cards/installments" />} /><Money cents={data.installmentsFuture} role="headline" /><Text role="bodySmall" color="textMuted">comprometidos em faturas futuras</Text></Card>;
    case 'monthly_budget': {
      const g = data.globalBudget;
      return <Card><CardHeader title="Orçamento do mês" action={<Action label="Orçamentos" route="/budgets" />} />{g ? <><View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Money cents={g.spentCents} role="title" /><Text role="bodySmall" color="textMuted">de {formatBRL(g.limitCents)}</Text></View><View style={{ marginTop: 8 }}><RhythmBar percent={g.percentUsed} expectedPercent={g.expectedPercent} state={g.pace} /></View><Text role="label" color={g.pace === 'sereno' ? 'positive' : g.pace === 'atencao' ? 'warning' : 'negative'} style={{ marginTop: 6 }}>Mês {g.pace === 'atencao' ? 'em atenção' : g.pace}</Text></> : data.budgets.length ? data.budgets.slice(0, 3).map((b) => <View key={b.budget.id} style={{ marginBottom: 10 }}><View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="bodySmall">{b.category?.name ?? 'Geral'}</Text><Text role="bodySmall" color="textMuted">{formatBRL(b.spentCents)} de {formatBRL(b.limitCents)}</Text></View><RhythmBar percent={b.percentUsed} expectedPercent={b.expectedPercent} state={b.pace} /></View>) : <EmptyState icon="plan" title="Sem orçamento ainda" text="Defina um limite para o mês e acompanhe o ritmo com a marca de hoje." actionTitle="Criar orçamento" onAction={go('/budgets/new')} />}</Card>;
    }
    case 'spending_by_category': {
      const total = data.categories.reduce((a, x) => a + x.cents, 0);
      return <Card><CardHeader title="Gastos por categoria" action={<Action label="Relatório" route="/reports/categories" />} />{data.categories.length ? data.categories.map((x) => <View key={x.categoryId ?? 'none'} style={{ marginBottom: 8 }}><View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="bodySmall">{x.name}</Text><Text role="bodySmall" tabular>{formatBRL(x.cents)} · {x.percent}%</Text></View><View style={{ height: 8, borderRadius: 4, backgroundColor: c.surfaceInset, marginTop: 4 }}><View style={{ height: 8, borderRadius: 4, width: `${total ? (x.cents / total) * 100 : 0}%`, backgroundColor: x.color }} /></View></View>) : <EmptyState icon="tag" title="Sem despesas neste mês" actionTitle="Registrar despesa" onAction={go('/transaction?kind=expense')} />}</Card>;
    }
    case 'evolution': {
      const max = Math.max(1, ...data.cashflow.map((p) => Math.max(p.incomeSettled, p.expenseSettled)));
      return <Card><CardHeader title="Evolução" action={<Action label="Fluxo" route="/reports/cashflow" />} />{data.hasTransactions ? <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 8, height: 120 }}>{data.cashflow.map((p) => <View key={p.month} style={{ flex: 1, alignItems: 'center', gap: 4 }}><View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 2, height: 96 }}><View accessibilityLabel={`Receitas ${monthLabel(p.month)}: ${formatBRL(p.incomeSettled)}`} style={{ width: 10, height: Math.max(2, (p.incomeSettled / max) * 96), backgroundColor: c.positive, borderRadius: 3 }} /><View accessibilityLabel={`Despesas ${monthLabel(p.month)}: ${formatBRL(p.expenseSettled)}`} style={{ width: 10, height: Math.max(2, (p.expenseSettled / max) * 96), backgroundColor: c.primary, borderRadius: 3 }} /></View><Text role="caption" color="textMuted">{monthLabel(p.month)}</Text></View>)}</View> : <EmptyState icon="arrow-up" title="Ainda sem histórico" text="Registre receitas e despesas para ver a evolução." />}</Card>;
    }
    case 'goals':
      return <Card><CardHeader title="Metas" action={<Action label="Ver" route="/goals" />} />{data.goals.length ? data.goals.slice(0, 3).map((g) => <Pressable key={g.goal.id} accessibilityRole="button" onPress={go(`/goals/${g.goal.id}`)} style={{ marginBottom: 10 }}><View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="bodySmall">{g.goal.name}</Text><Text role="bodySmall" color="textMuted">{formatBRL(g.savedCents)} de {formatBRL(g.goal.targetCents)}</Text></View><RhythmBar percent={g.percent} expectedPercent={g.expectedPercent} /></Pressable>) : <EmptyState icon="target" title="Nenhuma meta" text="Uma reserva de emergência é um bom começo." actionTitle="Criar meta" onAction={go('/goals/new')} />}</Card>;
    case 'reserves': {
      const reserved = data.goals.filter((g) => g.goal.reserved).reduce((a, g) => a + g.savedCents, 0);
      return <Card><CardHeader title="Reservas" action={<Action label="Ver" route="/goals" />} /><Money cents={reserved} role="headline" /><Text role="bodySmall" color="textMuted">separado e fora do "pode gastar"</Text></Card>;
    }
    case 'monthly_savings': {
      const rate = data.totals.incomeSettled ? Math.round(((data.totals.incomeSettled - data.totals.expenseSettled) / data.totals.incomeSettled) * 100) : null;
      return <Card><CardHeader title="Economia do mês" /><Money cents={data.totals.net} role="headline" signed /><Text role="bodySmall" color="textMuted">{rate === null ? 'Registre receitas para ver a taxa de economia.' : `${rate}% das receitas`}</Text></Card>;
    }
    case 'subscriptions':
      return <Card><CardHeader title="Assinaturas e recorrentes" action={<Action label="Ver" route="/reports/recurring" />} />{data.recurring.length ? data.recurring.slice(0, 5).map((r) => <ListRow key={r.key} icon="receipt" title={r.description} description={`${r.months.length} meses seguidos`} right={<Money cents={r.amountCents} />} />) : <Text role="bodySmall" color="textMuted">Nenhum gasto recorrente detectado ainda.</Text>}</Card>;
    case 'loans':
      return <Card><CardHeader title="Empréstimos" action={<Action label="Ver" route="/loans" />} />{data.loans.length ? data.loans.map((p) => <ListRow key={p.loan.id} icon="bank" title={p.loan.name} description={p.nextDue ? `próxima ${dayMonth(p.nextDue.dueDate)} · ${formatBRL(p.nextDue.installmentCents)}` : 'quitado'} right={<Money cents={p.outstandingCents} />} onPress={go(`/loans/${p.loan.id}`)} />) : <EmptyState icon="bank" title="Nenhum empréstimo" actionTitle="Cadastrar" onAction={go('/loans/new')} />}</Card>;
    case 'calendar':
      return <Card><CardHeader title="Calendário" action={<Action label="Abrir" route="/calendar" />} /><Text role="bodySmall" color="textMuted">{data.bills.length} vencimento(s) até {dayMonth(data.horizonEnd)}{data.overdue.length ? ` · ${data.overdue.length} atrasado(s)` : ''}</Text></Card>;
    case 'recent_transactions':
      return <Card><CardHeader title="Últimos lançamentos" action={<Action label="Todos" route="/transactions" />} />{data.recent.length ? data.recent.map((t) => <ListRow key={t.id} icon={t.kind === 'income' ? 'arrow-down' : t.kind === 'transfer' ? 'swap' : t.kind === 'card_purchase' ? 'card' : 'arrow-up'} title={t.description || kindLabel(t.kind)} description={`${dayMonth(t.date)}${t.status === 'planned' ? ' · previsto' : ''}`} right={<Money cents={t.kind === 'income' ? t.amountCents : -t.amountCents} signed={t.kind === 'income'} />} onPress={go(`/transaction?id=${t.id}`)} />) : <EmptyState icon="list" title="Nenhum lançamento" actionTitle="Registrar" onAction={go('/transaction')} />}</Card>;
    case 'recommendations':
      return <Card><CardHeader title="Sugestões" action={<Action label="Assistente" route="/assistant" />} />{data.recommendations.length ? data.recommendations.map((r) => <ListRow key={r.id} icon={r.severity === 'urgent' ? 'alert' : r.severity === 'attention' ? 'info' : 'sparkle'} iconColor={r.severity === 'urgent' ? c.negative : r.severity === 'attention' ? c.warning : c.primary} title={r.title} description={r.text} onPress={r.route ? go(r.route) : undefined} />) : <Text role="bodySmall" color="textMuted">Tudo sereno por aqui.</Text>}</Card>;
    case 'shopping_lists':
      return <Card><CardHeader title="Listas de compras" action={<Action label="Ver" route="/shopping" />} /><Text role="bodySmall" color="textMuted">{data.listCount ? `${data.listCount} lista(s)` : 'Nenhuma lista ainda.'}</Text>{!data.listCount ? <Button title="Criar lista" variant="secondary" compact onPress={go('/shopping/list/new')} style={{ marginTop: 8 }} /> : null}</Card>;
    case 'shopping_assistant':
      return <Card><CardHeader title="Assistente de supermercado" /><Text role="bodySmall" color="textMuted">{data.finishedSessions ? `${data.finishedSessions} compra(s) registrada(s)` : 'Leia etiquetas e códigos e veja o total antes do caixa.'}</Text><Button title="Iniciar compra" icon="cart" onPress={go('/shopping/session')} style={{ marginTop: 10 }} /></Card>;
    case 'advanced_indicators': {
      const inc = data.totals.incomeSettled;
      const savingRate = inc ? Math.round(((inc - data.totals.expenseSettled) / inc) * 100) : null;
      const commitment = inc ? Math.round(((data.cards.reduce((a, x) => a + x.commitment.outstandingCents, 0) + data.loans.reduce((a, l) => a + (l.nextDue?.installmentCents ?? 0), 0)) / inc) * 100) : null;
      return <Card><CardHeader title="Indicadores avançados" action={<Action label="Metodologia" route="/reports/indicators" />} /><View style={{ gap: 6 }}><Row k="Taxa de poupança (mês)" v={savingRate === null ? '—' : `${savingRate}%`} /><Row k="Renda comprometida (cartões + parcela)" v={commitment === null ? '—' : `${commitment}%`} /><Row k="Patrimônio líquido" v={data.netWorth ? formatBRL(data.netWorth.netCents) : '—'} /></View><Text role="caption" color="textMuted" style={{ marginTop: 6 }}>Cálculos sobre os dados registrados; não são diagnóstico financeiro.</Text></Card>;
    }
    default:
      return <Card><CardHeader title={def.title} /><Text role="bodySmall" color="textMuted">{def.description}</Text></Card>;
  }
}

function Row({ k, v }: { k: string; v: string }) { return <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}><Text role="bodySmall" color="textMuted">{k}</Text><Text role="bodySmall" tabular>{v}</Text></View>; }

export function kindLabel(kind: string): string {
  return ({ income: 'Receita', expense: 'Despesa', transfer: 'Transferência', card_purchase: 'Compra no cartão', card_payment: 'Pagamento de fatura', goal_deposit: 'Depósito em reserva', goal_withdrawal: 'Resgate de reserva', loan_disbursement: 'Entrada de empréstimo', loan_payment: 'Parcela de empréstimo', balance_adjustment: 'Ajuste de saldo' } as Record<string, string>)[kind] ?? kind;
}

export class WidgetErrorBoundary extends React.Component<{ children: React.ReactNode; title: string }, { error: Error | null }> {
  override state = { error: null as Error | null };
  static getDerivedStateFromError(error: Error) { return { error }; }
  override render() {
    if (this.state.error) return <Card><CardHeader title={this.props.title} /><EmptyState icon="alert" title="Não foi possível carregar" text="Toque para tentar de novo." actionTitle="Tentar de novo" onAction={() => this.setState({ error: null })} /></Card>;
    return this.props.children;
  }
}

export { Icon, spacing, radius, FREQUENCY_LABELS_PT };
