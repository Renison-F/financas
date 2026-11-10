/// Ocorrência 010 da homologação física: "No que mais gastei esse mês?" devolvia o resumo do mês e
/// "No que posso economizar?" devolvia "Não entendi".
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/domain/assistant/assistant.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/text/normalize.dart';

Map<String, dynamic> _tx(
  String id,
  String kind,
  int cents,
  String date, {
  String? category,
  String status = 'settled',
  String description = 'x',
}) => {
  'id': id,
  'kind': kind,
  'status': status,
  'amountCents': cents,
  'date': date,
  'description': description,
  'accountId': 'a1',
  'categoryId': ?category,
  'tags': <String>[],
  'createdAt': '${date}T12:00:00.000Z',
  'updatedAt': '${date}T12:00:00.000Z',
};

Map<String, dynamic> _cat(String id, String name) => {
  'id': id,
  'name': name,
  'kind': 'expense',
  'icon': 'tag',
  'color': '#C0703E',
  'archived': false,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-01T00:00:00.000Z',
};

/// The fixture of the report: R$ 45,00 in Alimentação, R$ 1,00 in Compras, R$ 65,00 received.
Ledger _ledger({List<Map<String, dynamic>> extra = const []}) =>
    Ledger.fromJson({
      'accounts': [
        {
          'id': 'a1',
          'name': 'c6',
          'type': 'checking',
          'openingBalanceCents': 0,
          'openingDate': '2026-01-01',
          'includeInAvailability': true,
          'color': '#0B5563',
          'archived': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        },
      ],
      'categories': [_cat('c-food', 'Alimentação'), _cat('c-shop', 'Compras')],
      'transactions': [
        _tx(
          't1',
          'expense',
          4500,
          '2026-11-07',
          category: 'c-food',
          description: 'compra',
        ),
        _tx(
          't2',
          'expense',
          100,
          '2026-11-07',
          category: 'c-shop',
          description: 'compra',
        ),
        _tx('t3', 'income', 6500, '2026-11-07', description: 'extra'),
        ...extra,
      ],
    });

void main() {
  const today = '2026-11-07';

  group('ranking of categories', () {
    for (final q in [
      'No que mais gastei esse mês?',
      'no que mais gastei esse mes?',
      'No que mais gastei?',
      'Onde gastei mais?',
      'onde estou gastando mais',
      'Qual a maior categoria de gasto?',
      'despesas por categoria',
      'com o que eu mais gasto',
      'pra onde foi meu dinheiro',
      'no q mais gatei esse mes', // typo
      'principais gastos do mês',
    ]) {
      test('"$q" asks for the ranking', () {
        expect(detectIntent(q).intent, 'where_spending_most');
      });
    }

    test('the fixture of the report: Alimentação 45, Compras 1, total 46', () {
      final a = answer(_ledger(), 'No que mais gastei?', today);
      expect(a.intent, 'where_spending_most');
      expect(a.title, 'Maiores gastos por categoria');
      expect(a.cents, 4600);
      expect(a.basis.map((b) => b.label), ['Alimentação', 'Compras']);
      expect(a.basis.map((b) => b.cents), [-4500, -100]);
      expect(a.basis[0].detail, '97,8% · 1 lançamento');
      expect(a.basis[1].detail, '2,2% · 1 lançamento');
      expect(a.text, contains('novembro de 2026'));
      expect(a.text, contains('1. Alimentação'));
      expect(a.text, contains('(97,8%)'));
      expect(a.text, contains('2. Compras'));
      expect(a.text, contains('(2,2%)'));
      expect(a.text, contains('previstas não entram'));
      expect(a.route, '/reports/categories');
      // never the monthly summary in place of the ranking
      expect(a.text, isNot(contains('recebidos')));
    });

    test('planned expenses stay out, and the answer says what it counted', () {
      final a = answer(
        _ledger(
          extra: [
            _tx(
              't9',
              'expense',
              90000,
              '2026-11-20',
              category: 'c-shop',
              status: 'planned',
            ),
          ],
        ),
        'onde gastei mais',
        today,
      );
      expect(a.cents, 4600);
      expect(a.basis.first.label, 'Alimentação');
    });

    test('"mês passado" looks at the previous month', () {
      final d = detectIntent('no que mais gastei no mês passado?');
      expect(d.intent, 'where_spending_most');
      expect(d.period, 'last_month');
      final a = answer(
        _ledger(
          extra: [_tx('t8', 'expense', 3000, '2026-10-15', category: 'c-shop')],
        ),
        'no que mais gastei no mês passado?',
        today,
      );
      expect(a.text, contains('outubro de 2026'));
      expect(a.cents, 3000);
      expect(a.basis.single.label, 'Compras');
    });

    test(
      'a month without expenses says so instead of showing zeros as a ranking',
      () {
        final a = answer(const Ledger(), 'No que mais gastei?', today);
        expect(a.cents, isNull);
        expect(a.basis, isEmpty);
        expect(a.text, 'Não há despesas efetivadas em novembro de 2026.');
      },
    );

    test('naming a category still answers about that category', () {
      final d = detectIntent('Quanto já gastei com alimentação?');
      expect(d.intent, 'spent_on_category');
      expect(d.category, 'alimentacao');
    });
  });

  group('where to save', () {
    for (final q in [
      'No que posso economizar?',
      'no que posso ecomizar', // as typed on the phone
      'Onde posso economizar?',
      'como gastar menos',
      'onde da pra cortar',
      'quero reduzir despesas',
    ]) {
      test('"$q" asks where to save', () {
        expect(detectIntent(q).intent, 'where_to_save');
      });
    }

    test('with data: what weighs most, without judging any expense', () {
      final a = answer(_ledger(), 'no que posso ecomizar', today);
      expect(a.intent, 'where_to_save');
      expect(a.title, 'Onde há espaço para reduzir');
      expect(a.text, contains('Alimentação'));
      expect(a.text, contains('97,8%'));
      // no earlier month on record: said, not invented
      expect(
        a.text,
        contains('Não há despesas em outubro de 2026 para comparar'),
      );
      expect(a.text, contains('decisão sua'));
      for (final w in ['desnecess', 'supérflu', 'deveria', 'exagero']) {
        expect(a.text.toLowerCase(), isNot(contains(w)));
      }
      expect(a.basis.first.label, 'Alimentação');
    });

    test('with an earlier month: what went up is named with the amount', () {
      final a = answer(
        _ledger(
          extra: [_tx('t8', 'expense', 2000, '2026-10-15', category: 'c-food')],
        ),
        'onde posso economizar',
        today,
      );
      expect(a.text, contains('Subiram em relação a outubro de 2026'));
      expect(a.text, contains('Alimentação (+R\$'));
    });

    test('without expenses: asks for data instead of guessing', () {
      final a = answer(const Ledger(), 'Onde posso economizar?', today);
      expect(a.title, 'Faltam dados para sugerir');
      expect(a.basis, isEmpty);
      expect(a.text, contains('Não há despesas efetivadas'));
    });
  });

  test('the month summary is only given when it is asked for', () {
    expect(detectIntent('Como está o mês?').intent, 'month_status');
    expect(detectIntent('como estou').intent, 'month_status');
    expect(detectIntent('resumo').intent, 'month_status');
    // the word "mês" alone no longer turns any question into the summary
    expect(detectIntent('qualquer coisa esse mes').intent, 'unknown');
    final a = answer(_ledger(), 'Como está o mês?', today);
    expect(a.title, 'Resultado do mês');
    expect(a.cents, 1900);
    for (final w in ['sereno', 'agitado', 'tranquil']) {
      expect('${a.title} ${a.text}'.toLowerCase(), isNot(contains(w)));
    }
  });

  test(
    'an unknown question gets examples that fit the data, not one fixed list',
    () {
      final a = answer(_ledger(), 'xyz', today);
      expect(a.intent, 'unknown');
      expect(a.text, contains('No que mais gastei este mês?'));
      expect(a.text, contains('Onde posso economizar?'));
      expect(a.text, isNot(contains('Quanto falta para minha meta')));
    },
  );

  test('a question never moves money', () {
    final ledger = _ledger();
    final before = ledger.toJson().toString();
    for (final q in [
      'transfira 100 para a poupança',
      'pague a conta de luz',
      'apague tudo',
      'No que mais gastei?',
    ]) {
      answer(ledger, q, today);
    }
    expect(ledger.toJson().toString(), before);
  });

  test('typo tolerance is bounded', () {
    expect(editDistance('ecomizar', 'economizar'), 2);
    expect(hasWordLike('no que posso ecomizar', const ['economizar']), isTrue);
    expect(hasWordLike('gato', const ['gasto']), isTrue);
    expect(hasWordLike('mes', const ['mais']), isFalse);
    expect(hasWordLike('casa', const ['gastei']), isFalse);
  });
}
