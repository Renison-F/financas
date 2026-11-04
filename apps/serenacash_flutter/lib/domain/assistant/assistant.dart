/// Deterministic financial assistant: answers computed from the user's own data with the same functions the
/// screens use; no external model required. Mirrors `assistant.ts`.
library;

import '../availability/availability.dart';
import '../budgets/budgets.dart';
import '../cards/cards.dart';
import '../dates/dates.dart';
import '../entities/entities.dart';
import '../goals/goals.dart';
import '../ledger/ledger.dart';
import '../loans/loans.dart';
import '../money/money.dart';
import '../reports/reports.dart';
import '../text/normalize.dart';

class BasisLine {
  const BasisLine(this.label, this.cents);
  final String label;
  final Cents cents;
  Map<String, dynamic> toJson() => {'label': label, 'cents': cents};
}

class Answer {
  const Answer({
    required this.intent,
    required this.title,
    required this.text,
    this.cents,
    required this.basis,
    this.route,
  });
  final String intent;
  final String title;
  final String text;
  final Cents? cents;
  final List<BasisLine> basis;
  final String? route;
  Map<String, dynamic> toJson() => {
    'intent': intent,
    'title': title,
    if (cents != null) 'cents': cents,
    'basis': basis.map((b) => b.toJson()).toList(),
    if (route != null) 'route': route,
  };
}

class DetectedIntent {
  const DetectedIntent(this.intent, {this.category, this.amountCents});
  final String intent;
  final String? category;
  final Cents? amountCents;
  Map<String, dynamic> toJson() => {
    'intent': intent,
    if (category != null) 'category': category,
    if (amountCents != null) 'amountCents': amountCents,
  };
}

final _money = RegExp(r'(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d{1,2}))?');
final _afford = RegExp(
  r'(posso|da pra|consigo|tenho como).*(comprar|pagar)|cabe|suficiente',
);
final _canSpend = RegExp(
  r'quanto (posso|da pra|dá pra) gastar|pode gastar|sobra',
);
final _bills = RegExp(
  r'(vence|vencem|pagar|contas).*(semana|dias|hoje|amanha)',
);
final _bills2 = RegExp(r'quais contas');
final _where = RegExp(r'onde (estou )?gast|maior gasto|gastando mais|pra onde');
final _cat = RegExp(
  r'(?:gastei|gasto|gastando) (?:com|em|no|na) ([a-z ]+?)(?:\?|$| este| esse| neste| no mes)',
);
final _organize = RegExp(r'organizar|comecar|por onde|dica|ajuda');
final _goal = RegExp(r'meta|objetivo|reserva|falta para');
final _inst = RegExp(r'parcela|comprometid|parcelad');
final _month = RegExp(r'como estou|situacao|mes|sereno');

DetectedIntent detectIntent(String question) {
  final q = normalizeText(question);
  final m = _money.firstMatch(q);
  Cents? amount;
  if (m != null) {
    amount =
        int.parse(m.group(1)!.replaceAll('.', '')) * 100 +
        int.parse((m.group(2) ?? '0').padRight(2, '0'));
  }
  if (_afford.hasMatch(q) && amount != null) {
    return DetectedIntent('can_afford', amountCents: amount);
  }
  if (_canSpend.hasMatch(q)) return const DetectedIntent('can_spend');
  if (_bills.hasMatch(q) || _bills2.hasMatch(q)) {
    return const DetectedIntent('bills_this_week');
  }
  if (_where.hasMatch(q)) return const DetectedIntent('where_spending_most');
  final c = _cat.firstMatch(q);
  if (c != null) {
    return DetectedIntent('spent_on_category', category: c.group(1)!.trim());
  }
  if (_organize.hasMatch(q)) return const DetectedIntent('how_to_organize');
  if (_goal.hasMatch(q)) return const DetectedIntent('goal_remaining');
  if (_inst.hasMatch(q)) return const DetectedIntent('installments_committed');
  if (_month.hasMatch(q)) return const DetectedIntent('month_status');
  return const DetectedIntent('unknown');
}

String _dm(ISODate d) => '${d.substring(8, 10)}/${d.substring(5, 7)}';

Answer answer(Ledger ledger, String question, ISODate today) {
  final d = detectIntent(question);
  final month = monthKeyOf(today);
  switch (d.intent) {
    case 'can_spend':
      final av = availability(ledger, today: today);
      return Answer(
        intent: d.intent,
        title: 'Pode gastar',
        cents: av.availableCents,
        text:
            'Até ${_dm(av.horizonEnd)}, dá para gastar ${formatBRL(av.availableCents)} sem comprometer o que já está registrado. É uma estimativa com o que você cadastrou, não um saldo garantido.',
        basis: av.lines
            .map((l) => BasisLine(l.label, l.sign * l.cents))
            .toList(),
        route: '/available',
      );
    case 'can_afford':
      final av = availability(ledger, today: today);
      final remaining = av.availableCents - (d.amountCents ?? 0);
      return Answer(
        intent: d.intent,
        title: remaining >= 0 ? 'Cabe' : 'Não cabe agora',
        cents: remaining,
        text: remaining >= 0
            ? 'Sim. Depois de ${formatBRL(d.amountCents ?? 0)} ainda sobram ${formatBRL(remaining)} até ${_dm(av.horizonEnd)}.'
            : 'Hoje não: faltariam ${formatBRL(-remaining)} para cobrir as contas até ${_dm(av.horizonEnd)}. Se for no cartão, a fatura entra na conta do próximo período.',
        basis: [
          BasisLine('Pode gastar', av.availableCents),
          BasisLine('Compra', -(d.amountCents ?? 0)),
        ],
        route: '/available',
      );
    case 'bills_this_week':
      final list = upcoming(ledger, today, addDays(today, 7));
      final late = overdue(ledger, today);
      final total = sumCents(list.map(pendingCents));
      final text = list.isNotEmpty
          ? '${list.length} conta(s) vencem até ${_dm(addDays(today, 7))}, somando ${formatBRL(total)}.'
          : 'Nenhuma conta vence nos próximos 7 dias.';
      return Answer(
        intent: d.intent,
        title: 'Vencendo esta semana',
        cents: total,
        text: late.isNotEmpty
            ? '$text Atenção: ${late.length} conta(s) já passaram do vencimento.'
            : text,
        basis: list
            .map(
              (t) => BasisLine(
                '${t.description.isEmpty ? 'Conta' : t.description} (${_dm(t.effectiveDate)})',
                -pendingCents(t),
              ),
            )
            .toList(),
        route: '/bills',
      );
    case 'where_spending_most':
      final cats = expensesByCategory(ledger, month, rollUp: true);
      final top = cats.firstOrNull;
      return Answer(
        intent: d.intent,
        title: 'Onde o dinheiro está indo',
        cents: top?.cents,
        text: top != null
            ? 'Neste mês, ${top.name} é a maior categoria: ${formatBRL(top.cents)} (${_fmtPct(top.percent)}% das despesas).'
            : 'Ainda não há despesas registradas neste mês.',
        basis: cats.take(5).map((c) => BasisLine(c.name, -c.cents)).toList(),
        route: '/reports/categories',
      );
    case 'spent_on_category':
      final cats = expensesByCategory(ledger, month);
      final cat = d.category ?? '';
      final hit =
          cats.where((c) => normalizeText(c.name).contains(cat)).firstOrNull ??
          cats.where((c) => cat.contains(normalizeText(c.name))).firstOrNull;
      return Answer(
        intent: d.intent,
        title: hit != null
            ? 'Gasto com ${hit.name}'
            : 'Categoria não encontrada',
        cents: hit?.cents ?? 0,
        text: hit != null
            ? 'Você gastou ${formatBRL(hit.cents)} com ${hit.name} neste mês (${hit.count} lançamento(s)).'
            : 'Não encontrei uma categoria parecida com "$cat". Veja a lista de categorias em Mais.',
        basis: hit != null ? [BasisLine(hit.name, -hit.cents)] : const [],
        route: '/reports/categories',
      );
    case 'goal_remaining':
      final goals = ledger.goals
          .where((g) => g.isActive)
          .map((g) => goalProgress(ledger, g, today))
          .toList();
      final text = goals.isNotEmpty
          ? goals
                .map(
                  (p) =>
                      '${p.goal.name}: faltam ${formatBRL(p.remainingCents)} (${_fmtPct(p.percent)}% guardado${p.suggestedMonthlyCents != null && p.suggestedMonthlyCents != 0 ? '; guardando ${formatBRL(p.suggestedMonthlyCents!)} por mês você chega no prazo' : ''}).',
                )
                .join(' ')
          : 'Você ainda não criou metas. Crie uma em Planejar.';
      return Answer(
        intent: d.intent,
        title: 'Suas metas',
        text: text,
        basis: goals
            .map((p) => BasisLine(p.goal.name, p.remainingCents))
            .toList(),
        route: '/goals',
      );
    case 'installments_committed':
      var future = 0;
      final basis = <BasisLine>[];
      for (final c in ledger.cards.where((c) => !c.archived)) {
        final cm = cardCommitment(ledger, c, today);
        final all =
            cm.futureCents + cm.currentInvoiceCents + cm.closedUnpaidCents;
        future += all;
        basis.add(BasisLine(c.name, -all));
      }
      for (final l in ledger.loans.where((l) => !l.archived)) {
        final p = loanPosition(ledger, l, today);
        future += p.outstandingCents;
        basis.add(BasisLine(l.name, -p.outstandingCents));
      }
      return Answer(
        intent: d.intent,
        title: 'Comprometido em parcelas e faturas',
        cents: future,
        text: future != 0
            ? 'Entre faturas de cartão e empréstimos, você tem ${formatBRL(future)} comprometidos para os próximos meses.'
            : 'Nenhuma parcela ou fatura em aberto.',
        basis: basis,
        route: '/cards/installments',
      );
    case 'month_status':
      final t = monthTotals(ledger, month);
      final statuses = budgetsForMonth(ledger, month, today);
      final worst = statuses.any((s) => s.pace == PaceStatus.agitado)
          ? 'agitado'
          : statuses.any((s) => s.pace == PaceStatus.atencao)
          ? 'atenção'
          : 'sereno';
      int n(PaceStatus p) => statuses.where((s) => s.pace == p).length;
      return Answer(
        intent: d.intent,
        title: 'Mês $worst',
        cents: t.net,
        text:
            'Até agora: ${formatBRL(t.incomeSettled)} recebidos e ${formatBRL(t.expenseSettled)} gastos (saldo do mês ${formatBRL(t.net)}). ${statuses.isNotEmpty ? 'Orçamentos: ${n(PaceStatus.sereno)} serenos, ${n(PaceStatus.atencao)} em atenção, ${n(PaceStatus.agitado)} agitados.' : 'Crie orçamentos para acompanhar o ritmo.'}',
        basis: [
          BasisLine('Receitas', t.incomeSettled),
          BasisLine('Despesas', -t.expenseSettled),
        ],
        route: '/budgets',
      );
    case 'how_to_organize':
      return Answer(
        intent: d.intent,
        title: 'Por onde começar',
        text: 'Três passos: (1) cadastre todas as contas fixas do mês como previstas, para o "pode gastar" ficar honesto; (2) crie um orçamento para a categoria onde você mais gasta; (3) separe uma reserva pequena e automática todo mês, mesmo que seja R\$ 50. O app mostra o ritmo de cada orçamento com a marca de hoje.',
        basis: const [],
        route: '/budgets',
      );
    default:
      return const Answer(
        intent: 'unknown',
        title: 'Não entendi',
        text: 'Posso responder sobre: quanto pode gastar, contas da semana, onde você mais gasta, quanto gastou em uma categoria, se uma compra cabe, metas, parcelas e como está o mês.',
        basis: [],
      );
  }
}

String _fmtPct(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

class Recommendation {
  const Recommendation({
    required this.id,
    required this.severity,
    required this.title,
    required this.text,
    this.route,
  });
  final String id;
  final String severity; // info | attention | urgent
  final String title;
  final String text;
  final String? route;
}

List<Recommendation> recommendations(Ledger ledger, ISODate today) {
  final out = <Recommendation>[];
  final month = monthKeyOf(today);
  final late = overdue(ledger, today);
  if (late.isNotEmpty) {
    out.add(
      Recommendation(
        id: 'overdue',
        severity: 'urgent',
        title: '${late.length} conta(s) atrasada(s)',
        text:
            'Somam ${formatBRL(sumCents(late.map(pendingCents)))}. Pagar ou reagendar evita juros e mantém o "pode gastar" correto.',
        route: '/bills?filter=overdue',
      ),
    );
  }
  for (final s in budgetsForMonth(ledger, month, today)) {
    if (s.pace == PaceStatus.agitado) {
      out.add(
        Recommendation(
          id: 'budget_${s.budget.id}',
          severity: 'attention',
          title: '${s.category?.name ?? 'Orçamento do mês'} acima do ritmo',
          text:
              'Já foram ${formatBRL(s.spentCents)} de ${formatBRL(s.limitCents)} (${_fmtPct(s.percentUsed)}%) com ${_fmtPct(s.expectedPercent)}% do mês decorrido.',
          route: '/budgets',
        ),
      );
    }
  }
  for (final c in ledger.cards.where((c) => !c.archived)) {
    final cm = cardCommitment(ledger, c, today);
    if (c.limitCents > 0 && cm.outstandingCents / c.limitCents > 0.8) {
      out.add(
        Recommendation(
          id: 'card_${c.id}',
          severity: 'attention',
          title:
              '${c.name}: ${(cm.outstandingCents / c.limitCents * 100).round()}% do limite comprometido',
          text:
              'Faturas e parcelas somam ${formatBRL(cm.outstandingCents)} de ${formatBRL(c.limitCents)}.',
          route: '/cards',
        ),
      );
    }
  }
  final t = monthTotals(ledger, month);
  if (t.incomeSettled > 0) {
    final rate = (t.incomeSettled - t.expenseSettled) / t.incomeSettled;
    if (rate < 0) {
      out.add(
        Recommendation(
          id: 'negative_month',
          severity: 'attention',
          title: 'Gastos acima das receitas',
          text:
              'Neste mês as despesas superam as receitas em ${formatBRL(t.expenseSettled - t.incomeSettled)}.',
          route: '/reports/cashflow',
        ),
      );
    } else if (rate >= 0.2 && ledger.goals.isEmpty) {
      out.add(
        const Recommendation(
          id: 'start_goal',
          severity: 'info',
          title: 'Sobrou mais de 20% da renda',
          text: 'Bom momento para criar uma reserva de emergência e guardar parte disso.',
          route: '/goals',
        ),
      );
    }
  }
  final rec = recurringExpenses(ledger, month);
  if (rec.length >= 3) {
    out.add(
      Recommendation(
        id: 'recurring',
        severity: 'info',
        title: '${rec.length} gastos recorrentes',
        text:
            'Somam ${formatBRL(sumCents(rec.map((r) => r.amountCents)))} por mês. Vale revisar assinaturas que você não usa.',
        route: '/reports/recurring',
      ),
    );
  }
  if (ledger.accounts.isEmpty) {
    out.add(
      const Recommendation(
        id: 'no_accounts',
        severity: 'info',
        title: 'Cadastre sua primeira conta',
        text:
            'Com o saldo de uma conta o app já mostra quanto você pode gastar.',
        route: '/accounts/new',
      ),
    );
  }
  const order = ['urgent', 'attention', 'info'];
  final idx = out.asMap().entries.toList()
    ..sort((a, b) {
      final d =
          order.indexOf(a.value.severity) - order.indexOf(b.value.severity);
      return d != 0 ? d : a.key.compareTo(b.key);
    });
  return idx.map((e) => e.value).toList();
}
