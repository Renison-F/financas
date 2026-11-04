import { formatBRL, type Cents } from '../money/money';
import { addDays, compareISO, monthKeyOf, type ISODate } from '../dates/dates';
import type { Ledger } from './types';
import { availability } from './availability';
import { upcoming, overdue, monthTotals, pendingCents } from './ledger';
import { budgetsForMonth } from './budgets';
import { expensesByCategory, recurringExpenses } from './reports';
import { goalProgress } from './goals';
import { cardCommitment } from './cards';
import { loanPosition } from './loans';

/**
 * Deterministic financial assistant. Every answer is computed from the user's own data with the
 * same functions the screens use; no external model is required. Each answer carries `basis`
 * (which numbers it used) so the UI can show "como calculamos".
 */
export type Intent =
  | 'can_spend' | 'bills_this_week' | 'where_spending_most' | 'spent_on_category' | 'can_afford' | 'how_to_organize'
  | 'goal_remaining' | 'installments_committed' | 'month_status' | 'unknown';

export interface Answer { intent: Intent; title: string; text: string; cents?: Cents | undefined; basis: { label: string; cents: Cents }[]; route?: string | undefined; }

const norm = (s: string) => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');

export function detectIntent(question: string): { intent: Intent; category?: string | undefined; amountCents?: Cents | undefined } {
  const q = norm(question);
  const money = q.match(/(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d{1,2}))?/);
  const amountCents = money ? Number(money[1]!.replace(/\./g, '')) * 100 + Number((money[2] ?? '0').padEnd(2, '0')) : undefined;
  if (/(posso|da pra|consigo|tenho como).*(comprar|pagar)|cabe|suficiente/.test(q) && amountCents) return { intent: 'can_afford', amountCents };
  if (/quanto (posso|da pra|dá pra) gastar|pode gastar|sobra/.test(q)) return { intent: 'can_spend' };
  if (/(vence|vencem|pagar|contas).*(semana|dias|hoje|amanha)/.test(q) || /quais contas/.test(q)) return { intent: 'bills_this_week' };
  if (/onde (estou )?gast|maior gasto|gastando mais|pra onde/.test(q)) return { intent: 'where_spending_most' };
  const cat = q.match(/(?:gastei|gasto|gastando) (?:com|em|no|na) ([a-z ]+?)(?:\?|$| este| esse| neste| no mes)/);
  if (cat) return { intent: 'spent_on_category', category: cat[1]!.trim() };
  if (/organizar|comecar|por onde|dica|ajuda/.test(q)) return { intent: 'how_to_organize' };
  if (/meta|objetivo|reserva|falta para/.test(q)) return { intent: 'goal_remaining' };
  if (/parcela|comprometid|parcelad/.test(q)) return { intent: 'installments_committed' };
  if (/como estou|situacao|mes|sereno/.test(q)) return { intent: 'month_status' };
  return { intent: 'unknown' };
}

export function answer(ledger: Ledger, question: string, today: ISODate): Answer {
  const { intent, category, amountCents } = detectIntent(question);
  const month = monthKeyOf(today);
  switch (intent) {
    case 'can_spend': {
      const av = availability(ledger, { today });
      return { intent, title: 'Pode gastar', cents: av.availableCents, text: `Até ${av.horizonEnd.slice(8, 10)}/${av.horizonEnd.slice(5, 7)}, dá para gastar ${formatBRL(av.availableCents)} sem comprometer o que já está registrado. É uma estimativa com o que você cadastrou, não um saldo garantido.`, basis: av.lines.map((l) => ({ label: l.label, cents: l.sign * l.cents })), route: '/available' };
    }
    case 'can_afford': {
      const av = availability(ledger, { today });
      const remaining = av.availableCents - (amountCents ?? 0);
      return { intent, title: remaining >= 0 ? 'Cabe' : 'Não cabe agora', cents: remaining, text: remaining >= 0 ? `Sim. Depois de ${formatBRL(amountCents ?? 0)} ainda sobram ${formatBRL(remaining)} até ${av.horizonEnd.slice(8, 10)}/${av.horizonEnd.slice(5, 7)}.` : `Hoje não: faltariam ${formatBRL(-remaining)} para cobrir as contas até ${av.horizonEnd.slice(8, 10)}/${av.horizonEnd.slice(5, 7)}. Se for no cartão, a fatura entra na conta do próximo período.`, basis: [{ label: 'Pode gastar', cents: av.availableCents }, { label: 'Compra', cents: -(amountCents ?? 0) }], route: '/available' };
    }
    case 'bills_this_week': {
      const list = upcoming(ledger, today, addDays(today, 7));
      const late = overdue(ledger, today);
      const total = list.reduce((a, t) => a + pendingCents(t), 0);
      const text = list.length ? `${list.length} conta(s) vencem até ${addDays(today, 7).slice(8, 10)}/${addDays(today, 7).slice(5, 7)}, somando ${formatBRL(total)}.` : 'Nenhuma conta vence nos próximos 7 dias.';
      return { intent, title: 'Vencendo esta semana', cents: total, text: late.length ? `${text} Atenção: ${late.length} conta(s) já passaram do vencimento.` : text, basis: list.map((t) => ({ label: `${t.description || 'Conta'} (${(t.dueDate ?? t.date).slice(8, 10)}/${(t.dueDate ?? t.date).slice(5, 7)})`, cents: -pendingCents(t) })), route: '/bills' };
    }
    case 'where_spending_most': {
      const cats = expensesByCategory(ledger, month, { rollUp: true });
      const top = cats[0];
      return { intent, title: 'Onde o dinheiro está indo', cents: top?.cents, text: top ? `Neste mês, ${top.name} é a maior categoria: ${formatBRL(top.cents)} (${top.percent}% das despesas).` : 'Ainda não há despesas registradas neste mês.', basis: cats.slice(0, 5).map((c) => ({ label: c.name, cents: -c.cents })), route: '/reports/categories' };
    }
    case 'spent_on_category': {
      const cats = expensesByCategory(ledger, month, { rollUp: false });
      const hit = cats.find((c) => norm(c.name).includes(category ?? '')) ?? cats.find((c) => (category ?? '').includes(norm(c.name)));
      return { intent, title: hit ? `Gasto com ${hit.name}` : 'Categoria não encontrada', cents: hit?.cents ?? 0, text: hit ? `Você gastou ${formatBRL(hit.cents)} com ${hit.name} neste mês (${hit.count} lançamento(s)).` : `Não encontrei uma categoria parecida com "${category}". Veja a lista de categorias em Mais.`, basis: hit ? [{ label: hit.name, cents: -hit.cents }] : [], route: '/reports/categories' };
    }
    case 'goal_remaining': {
      const goals = ledger.goals.filter((g) => !g.archived && !g.deletedAt).map((g) => goalProgress(ledger, g, today));
      const text = goals.length ? goals.map((p) => `${p.goal.name}: faltam ${formatBRL(p.remainingCents)} (${p.percent}% guardado${p.suggestedMonthlyCents ? `; guardando ${formatBRL(p.suggestedMonthlyCents)} por mês você chega no prazo` : ''}).`).join(' ') : 'Você ainda não criou metas. Crie uma em Planejar.';
      return { intent, title: 'Suas metas', text, basis: goals.map((p) => ({ label: p.goal.name, cents: p.remainingCents })), route: '/goals' };
    }
    case 'installments_committed': {
      let future = 0; const basis: { label: string; cents: Cents }[] = [];
      for (const c of ledger.cards.filter((c) => !c.archived)) { const cm = cardCommitment(ledger, c, today); future += cm.futureCents + cm.currentInvoiceCents + cm.closedUnpaidCents; basis.push({ label: c.name, cents: -(cm.futureCents + cm.currentInvoiceCents + cm.closedUnpaidCents) }); }
      for (const l of ledger.loans.filter((l) => !l.archived)) { const p = loanPosition(ledger, l, today); future += p.outstandingCents; basis.push({ label: l.name, cents: -p.outstandingCents }); }
      return { intent, title: 'Comprometido em parcelas e faturas', cents: future, text: future ? `Entre faturas de cartão e empréstimos, você tem ${formatBRL(future)} comprometidos para os próximos meses.` : 'Nenhuma parcela ou fatura em aberto.', basis, route: '/cards/installments' };
    }
    case 'month_status': {
      const t = monthTotals(ledger, month);
      const statuses = budgetsForMonth(ledger, month, today);
      const worst = statuses.find((s) => s.pace === 'agitado') ? 'agitado' : statuses.find((s) => s.pace === 'atencao') ? 'atenção' : 'sereno';
      return { intent, title: `Mês ${worst}`, cents: t.net, text: `Até agora: ${formatBRL(t.incomeSettled)} recebidos e ${formatBRL(t.expenseSettled)} gastos (saldo do mês ${formatBRL(t.net)}). ${statuses.length ? `Orçamentos: ${statuses.filter((s) => s.pace === 'sereno').length} serenos, ${statuses.filter((s) => s.pace === 'atencao').length} em atenção, ${statuses.filter((s) => s.pace === 'agitado').length} agitados.` : 'Crie orçamentos para acompanhar o ritmo.'}`, basis: [{ label: 'Receitas', cents: t.incomeSettled }, { label: 'Despesas', cents: -t.expenseSettled }], route: '/budgets' };
    }
    case 'how_to_organize':
      return { intent, title: 'Por onde começar', text: 'Três passos: (1) cadastre todas as contas fixas do mês como previstas, para o "pode gastar" ficar honesto; (2) crie um orçamento para a categoria onde você mais gasta; (3) separe uma reserva pequena e automática todo mês, mesmo que seja R$ 50. O app mostra o ritmo de cada orçamento com a marca de hoje.', basis: [], route: '/budgets' };
    default:
      return { intent: 'unknown', title: 'Não entendi', text: 'Posso responder sobre: quanto pode gastar, contas da semana, onde você mais gasta, quanto gastou em uma categoria, se uma compra cabe, metas, parcelas e como está o mês.', basis: [] };
  }
}

export interface Recommendation { id: string; severity: 'info' | 'attention' | 'urgent'; title: string; text: string; route?: string | undefined; }

/** Rule-based recommendations, transparent and deterministic. */
export function recommendations(ledger: Ledger, today: ISODate): Recommendation[] {
  const out: Recommendation[] = [];
  const month = monthKeyOf(today);
  const late = overdue(ledger, today);
  if (late.length) out.push({ id: 'overdue', severity: 'urgent', title: `${late.length} conta(s) atrasada(s)`, text: `Somam ${formatBRL(late.reduce((a, t) => a + pendingCents(t), 0))}. Pagar ou reagendar evita juros e mantém o "pode gastar" correto.`, route: '/bills?filter=overdue' });
  for (const s of budgetsForMonth(ledger, month, today)) {
    if (s.pace === 'agitado') out.push({ id: `budget_${s.budget.id}`, severity: 'attention', title: `${s.category?.name ?? 'Orçamento do mês'} acima do ritmo`, text: `Já foram ${formatBRL(s.spentCents)} de ${formatBRL(s.limitCents)} (${s.percentUsed}%) com ${s.expectedPercent}% do mês decorrido.`, route: '/budgets' });
  }
  for (const c of ledger.cards.filter((c) => !c.archived)) {
    const cm = cardCommitment(ledger, c, today);
    if (c.limitCents > 0 && cm.outstandingCents / c.limitCents > 0.8) out.push({ id: `card_${c.id}`, severity: 'attention', title: `${c.name}: ${Math.round((cm.outstandingCents / c.limitCents) * 100)}% do limite comprometido`, text: `Faturas e parcelas somam ${formatBRL(cm.outstandingCents)} de ${formatBRL(c.limitCents)}.`, route: '/cards' });
  }
  const t = monthTotals(ledger, month);
  if (t.incomeSettled > 0) {
    const rate = (t.incomeSettled - t.expenseSettled) / t.incomeSettled;
    if (rate < 0) out.push({ id: 'negative_month', severity: 'attention', title: 'Gastos acima das receitas', text: `Neste mês as despesas superam as receitas em ${formatBRL(t.expenseSettled - t.incomeSettled)}.`, route: '/reports/cashflow' });
    else if (rate >= 0.2 && !ledger.goals.length) out.push({ id: 'start_goal', severity: 'info', title: 'Sobrou mais de 20% da renda', text: 'Bom momento para criar uma reserva de emergência e guardar parte disso.', route: '/goals' });
  }
  const rec = recurringExpenses(ledger, month);
  if (rec.length >= 3) out.push({ id: 'recurring', severity: 'info', title: `${rec.length} gastos recorrentes`, text: `Somam ${formatBRL(rec.reduce((a, r) => a + r.amountCents, 0))} por mês. Vale revisar assinaturas que você não usa.`, route: '/reports/recurring' });
  if (!ledger.accounts.length) out.push({ id: 'no_accounts', severity: 'info', title: 'Cadastre sua primeira conta', text: 'Com o saldo de uma conta o app já mostra quanto você pode gastar.', route: '/accounts/new' });
  return out.sort((a, b) => ['urgent', 'attention', 'info'].indexOf(a.severity) - ['urgent', 'attention', 'info'].indexOf(b.severity));
}
