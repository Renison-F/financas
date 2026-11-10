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
  const BasisLine(this.label, this.cents, {this.detail});
  final String label;
  final Cents cents;

  /// What the line weighs in the answer (share of the total, number of entries).
  final String? detail;
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
  const DetectedIntent(
    this.intent, {
    this.category,
    this.amountCents,
    this.period,
  });
  final String intent;
  final String? category;
  final Cents? amountCents;

  /// `last_month` when the question names the previous month; null for the current one.
  final String? period;
  Map<String, dynamic> toJson() => {
    'intent': intent,
    if (category != null) 'category': category,
    if (amountCents != null) 'amountCents': amountCents,
    if (period != null) 'period': period,
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
// "Where does the money go": a ranking of categories, however the question is worded.
final _where = RegExp(
  r'onde (eu |estou |foi que |e que |mais )*(gast|vai|foi)|(no|em|com|do) que (eu |mais |estou )*gast|'
  r'gast\w* mais|mais gast|maior(es)? (gasto|despesa|categoria)|pra onde|para onde|'
  r'principais (gastos|despesas)|ranking|(despesas|gastos) por categoria|categoria que mais',
);
const _spendWords = [
  'gastei',
  'gastar',
  'gasto',
  'gastos',
  'gastando',
  'despesa',
  'despesas',
];
final _rankWords = RegExp(r'\b(mais|maior|maiores|onde|ranking|principais)\b');
// "Where can I save": verbs of spending less, typos included.
const _saveWords = [
  'economizar',
  'economizo',
  'poupar',
  'cortar',
  'reduzir',
  'diminuir',
  'enxugar',
];
final _saveRe = RegExp(r'gastar menos|gasto menos|sobrar mais');
final _lastMonth = RegExp(r'mes passado|ultimo mes|mes anterior');
final _cat = RegExp(
  r'(?:gastei|gasto|gastando) (?:com|em|no|na) ([a-z ]+?)(?:\?|$| este| esse| neste| no mes)',
);
final _organize = RegExp(r'organizar|comecar|por onde|dica|ajuda');
final _goal = RegExp(r'meta|objetivo|reserva|falta para');
final _inst = RegExp(r'parcela|comprometid|parcelad');
final _month = RegExp(
  r'como estou|como (esta|vai|anda|foi) (o |meu |este |esse )?mes|situacao|resumo|'
  r'resultado do mes|balanco|como (estao|andam) (as |minhas )*(contas|financas)',
);

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
  final period = _lastMonth.hasMatch(q) ? 'last_month' : null;
  if (_saveRe.hasMatch(q) || hasWordLike(q, _saveWords)) {
    return DetectedIntent('where_to_save', period: period);
  }
  final c = _cat.firstMatch(q);
  // "gastei com mercado" names a category; "no que mais gastei" asks for the ranking.
  final ranking =
      _where.hasMatch(q) ||
      (c == null && hasWordLike(q, _spendWords) && _rankWords.hasMatch(q));
  if (ranking) return DetectedIntent('where_spending_most', period: period);
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

const _monthNames = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];
String _monthName(MonthKey m) =>
    '${_monthNames[int.parse(m.substring(5, 7)) - 1]} de ${m.substring(0, 4)}';

Answer answer(Ledger ledger, String question, ISODate today) {
  final d = detectIntent(question);
  final thisMonth = monthKeyOf(today);
  final month = d.period == 'last_month'
      ? addMonthsToKey(thisMonth, -1)
      : thisMonth;
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
      // The same query the category report runs: settled expenses of the month, subcategories
      // added to their category. Planned expenses are left out, and the answer says so.
      final cats = expensesByCategory(ledger, month, rollUp: true);
      final total = sumCents(cats.map((c) => c.cents));
      final shown = cats.take(5).toList();
      final rest = cats.skip(5).toList();
      final ranking = [
        for (var i = 0; i < shown.length; i++)
          '${i + 1}. ${shown[i].name}: ${formatBRL(shown[i].cents)} (${_fmtPct(shown[i].percent)}%)',
      ].join('; ');
      return Answer(
        intent: d.intent,
        title: 'Maiores gastos por categoria',
        cents: cats.isEmpty ? null : total,
        text: cats.isEmpty
            ? 'Não há despesas efetivadas em ${_monthName(month)}.'
            : 'Em ${_monthName(month)}, as despesas efetivadas somam ${formatBRL(total)} em ${cats.length} ${cats.length == 1 ? 'categoria' : 'categorias'}. $ranking. Despesas previstas não entram nesta conta.',
        basis: [
          for (final c in shown)
            BasisLine(
              c.name,
              -c.cents,
              detail:
                  '${_fmtPct(c.percent)}% · ${c.count} ${c.count == 1 ? 'lançamento' : 'lançamentos'}',
            ),
          if (rest.isNotEmpty)
            BasisLine(
              'Outras ${rest.length}',
              -sumCents(rest.map((c) => c.cents)),
            ),
        ],
        route: '/reports/categories',
      );
    case 'where_to_save':
      final cats = expensesByCategory(ledger, month, rollUp: true);
      final total = sumCents(cats.map((c) => c.cents));
      if (cats.isEmpty || total <= 0) {
        return Answer(
          intent: d.intent,
          title: 'Faltam dados para sugerir',
          text:
              'Não há despesas efetivadas em ${_monthName(month)}, então não há o que comparar. Registre os gastos do mês${d.period == null ? ' ou pergunte "Onde posso economizar no mês passado?"' : ''}.',
          basis: const [],
          route: '/transactions',
        );
      }
      final parts = <String>[];
      final top = cats.take(3).toList();
      parts.add(
        'Em ${_monthName(month)}, o que mais pesa: ${top.map((c) => '${c.name} (${formatBRL(c.cents)}, ${_fmtPct(c.percent)}%)').join(', ')}.',
      );
      final over = budgetsForMonth(
        ledger,
        month,
        today,
      ).where((s) => s.pace != PaceStatus.sereno).toList();
      if (over.isNotEmpty) {
        parts.add(
          'Acima do previsto no orçamento: ${over.map((s) => '${s.category?.name ?? 'orçamento do mês'} (${formatBRL(s.spentCents)} de ${formatBRL(s.limitCents)})').join(', ')}.',
        );
      }
      final previousMonth = addMonthsToKey(month, -1);
      final previous = {
        for (final c in expensesByCategory(ledger, previousMonth, rollUp: true))
          c.categoryId: c.cents,
      };
      if (previous.isEmpty) {
        parts.add(
          'Não há despesas em ${_monthName(previousMonth)} para comparar a evolução.',
        );
      } else {
        final rises = [
          for (final c in cats)
            if (previous[c.categoryId] != null &&
                c.cents > previous[c.categoryId]!)
              (c.name, c.cents - previous[c.categoryId]!),
        ]..sort((a, b) => b.$2.compareTo(a.$2));
        if (rises.isNotEmpty) {
          parts.add(
            'Subiram em relação a ${_monthName(previousMonth)}: ${rises.take(2).map((r) => '${r.$1} (+${formatBRL(r.$2)})').join(', ')}.',
          );
        }
      }
      final rec = recurringExpenses(ledger, month);
      if (rec.isNotEmpty) {
        parts.add(
          '${rec.length} ${rec.length == 1 ? 'gasto se repete' : 'gastos se repetem'} todo mês e ${rec.length == 1 ? 'soma' : 'somam'} ${formatBRL(sumCents(rec.map((r) => r.amountCents)))}; vale conferir se ainda fazem sentido.',
        );
      }
      parts.add(
        'O app mostra onde o dinheiro se concentra; o que reduzir é uma decisão sua.',
      );
      return Answer(
        intent: d.intent,
        title: 'Onde há espaço para reduzir',
        text: parts.join(' '),
        basis: [
          for (final c in top)
            BasisLine(c.name, -c.cents, detail: '${_fmtPct(c.percent)}%'),
        ],
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
            : 'Não encontrei despesas de uma categoria parecida com "$cat" neste mês. A lista de categorias está no menu.',
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
      // Money the user lent is owed to them: it is not a commitment of theirs.
      for (final l in ledger.loans.where(
        (l) => !l.archived && l.direction != 'lent',
      )) {
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
      int n(PaceStatus p) => statuses.where((s) => s.pace == p).length;
      return Answer(
        intent: d.intent,
        title: 'Resultado do mês',
        cents: t.net,
        text:
            'Em ${_monthName(month)}: ${formatBRL(t.incomeSettled)} recebidos e ${formatBRL(t.expenseSettled)} gastos, resultado de ${formatBRL(t.net)}. ${statuses.isNotEmpty ? 'Orçamentos: ${n(PaceStatus.sereno)} dentro do previsto, ${n(PaceStatus.atencao)} pouco acima e ${n(PaceStatus.agitado)} acima do previsto.' : 'Sem orçamento definido para comparar.'}',
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
      // Examples drawn from what this user actually has, instead of one fixed list.
      final examples = [
        '"No que mais gastei este mês?"',
        '"Onde posso economizar?"',
        if (ledger.transactions.any(
          (t) => isActive(t) && t.status == TransactionStatus.planned,
        ))
          '"Quais contas vencem esta semana?"',
        if (ledger.cards.any((c) => !c.archived))
          '"Quanto tenho comprometido em parcelas?"',
        if (ledger.goals.any((g) => g.isActive))
          '"Quanto falta para minha meta?"',
        '"Posso comprar algo de 300,00?"',
      ];
      return Answer(
        intent: 'unknown',
        title: 'Não entendi',
        text:
            'Não reconheci essa pergunta. Experimente, por exemplo: ${examples.take(4).join(', ')}. Para ver tudo, abra os relatórios no menu.',
        basis: const [],
      );
  }
}

/// Percent with a decimal comma, as money is written here.
String _fmtPct(double v) => v == v.roundToDouble()
    ? v.toInt().toString()
    : v.toString().replaceAll('.', ',');

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
