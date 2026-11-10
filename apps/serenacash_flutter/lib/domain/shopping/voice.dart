/// Understanding of a spoken cart item: "5 quilos de arroz, 29 reais".
///
/// It works on the text the speech engine returned and never adds anything to a cart: the result
/// fills the review form, which the user confirms. One ambiguity is treated as such instead of
/// guessed: with a quantity other than one, "29 reais" may be the total or the price of each unit.
library;

import '../money/money.dart';
import '../text/normalize.dart';

/// What the amount that was said refers to.
enum SpokenPrice {
  /// Nothing about price was said.
  none,

  /// The price of one unit (said "cada", "o quilo", "a unidade", or the quantity is one).
  perUnit,

  /// The price of the whole quantity (said "no total", "tudo por", "ao todo").
  total,

  /// Could be either: the user has to say which.
  ambiguous,
}

class SpokenItem {
  const SpokenItem({
    required this.transcript,
    required this.name,
    required this.quantity,
    required this.unit,
    this.amountCents,
    required this.meaning,
    this.cancel = false,
  });
  final String transcript;
  final String name;
  final double quantity;
  final String unit;

  /// The amount that was said, whatever it refers to.
  final Cents? amountCents;
  final SpokenPrice meaning;

  /// The user said to give up ("cancelar").
  final bool cancel;

  /// The price of one unit under a reading of the amount. Null when no amount was said.
  Cents? unitPriceCents({required bool amountIsTotal}) {
    final a = amountCents;
    if (a == null) return null;
    if (!amountIsTotal || quantity <= 0) return a;
    return divCents(a, quantity, RoundingMode.halfUp);
  }
}

const _numberWords = {
  'um': 1.0,
  'uma': 1.0,
  'dois': 2.0,
  'duas': 2.0,
  'tres': 3.0,
  'quatro': 4.0,
  'cinco': 5.0,
  'seis': 6.0,
  'sete': 7.0,
  'oito': 8.0,
  'nove': 9.0,
  'dez': 10.0,
  'onze': 11.0,
  'doze': 12.0,
  'meio': 0.5,
  'meia': 0.5,
};

const _unitWords = {
  'kg': 'kg',
  'quilo': 'kg',
  'quilos': 'kg',
  'kilo': 'kg',
  'kilos': 'kg',
  'g': 'g',
  'grama': 'g',
  'gramas': 'g',
  'l': 'l',
  'litro': 'l',
  'litros': 'l',
  'ml': 'ml',
  'mililitro': 'ml',
  'mililitros': 'ml',
  'un': 'un',
  'unidade': 'un',
  'unidades': 'un',
  'pacote': 'un',
  'pacotes': 'un',
  'caixa': 'un',
  'caixas': 'un',
  'lata': 'un',
  'latas': 'un',
  'garrafa': 'un',
  'garrafas': 'un',
  'duzia': 'dz',
  'duzias': 'dz',
};

final _money = RegExp(
  r'(?:r\$\s*)?(\d{1,6})(?:[,.](\d{1,2}))?\s*(?:reais|real)?(?:\s+e\s+(\d{1,2})(?:\s+centavos)?)?',
);
final _moneyMarked = RegExp(
  r'r\$\s*\d|\d\s*(reais|real)\b|\d+[,.]\d{2}\b|\b(por|a|custa|custando|custou)\s+\d',
);
final _totalWords = RegExp(
  r'\b(no total|ao todo|tudo por|total de|pelo total|no conjunto)\b',
);
final _eachWords = RegExp(
  r'\b(cada|a unidade|por unidade|o quilo|por quilo|o kilo|por kilo|o litro|por litro|o kg|por kg|a duzia|unitario)\b',
);
final _cancel = RegExp(r'^\s*(cancelar|cancela|esquece|deixa pra la)\b');

SpokenItem parseSpokenItem(String transcript) {
  final t = normalizeText(transcript).replaceAll(RegExp(r'\s+'), ' ').trim();
  if (_cancel.hasMatch(t)) {
    return SpokenItem(
      transcript: transcript,
      name: '',
      quantity: 1,
      unit: 'un',
      meaning: SpokenPrice.none,
      cancel: true,
    );
  }
  // 1. The amount: the last thing that reads as money. A bare number is only taken as money when
  // the sentence marks it ("reais", "R$", a decimal part, "por 29", "a 29").
  Cents? amount;
  String rest = t;
  final marked = _moneyMarked.hasMatch(t);
  if (marked) {
    RegExpMatch? best;
    for (final m in _money.allMatches(t)) {
      final text = m[0]!;
      final isMoney =
          text.contains('r\$') ||
          text.contains('rea') ||
          m[2] != null ||
          m[3] != null ||
          RegExp(r'\b(por|a|custa|custando|custou)\s+$')
              .hasMatch(t.substring(0, m.start));
      if (isMoney) best = m;
    }
    if (best != null) {
      final whole = int.parse(best[1]!);
      final cents = best[2] != null
          ? int.parse(best[2]!.padRight(2, '0'))
          : (best[3] != null ? int.parse(best[3]!.padRight(2, '0')) : 0);
      amount = whole * 100 + cents;
      rest = '${t.substring(0, best.start)} ${t.substring(best.end)}';
    }
  }
  final saysTotal = _totalWords.hasMatch(t);
  final saysEach = _eachWords.hasMatch(t);
  rest = rest
      .replaceAll(_totalWords, ' ')
      .replaceAll(_eachWords, ' ')
      .replaceAll(
        RegExp(r'\b(por|custa|custando|custou|centavos|reais|real)\b'),
        ' ',
      )
      .replaceAll(RegExp(r'[,;.]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // 2. Quantity and unit at the start: "5 kg de", "dois litros de", "meia duzia de", "500g".
  var quantity = 1.0;
  var unit = 'un';
  var words = rest.split(' ').where((w) => w.isNotEmpty).toList();
  if (words.isNotEmpty) {
    final glued = RegExp(r'^(\d+(?:[,.]\d+)?)(kg|g|ml|l)$')
        .firstMatch(words[0]);
    double? q;
    var consumed = 0;
    if (glued != null) {
      q = double.tryParse(glued[1]!.replaceAll(',', '.'));
      unit = glued[2]!;
      consumed = 1;
    } else {
      q =
          double.tryParse(words[0].replaceAll(',', '.')) ??
          _numberWords[words[0]];
      if (q != null) {
        consumed = 1;
        if (words.length > 1 && _unitWords.containsKey(words[1])) {
          unit = _unitWords[words[1]]!;
          consumed = 2;
        }
      } else if (_unitWords.containsKey(words[0]) && words.length > 1) {
        // "quilo de arroz": one of that unit.
        q = 1;
        unit = _unitWords[words[0]]!;
        consumed = 1;
      }
    }
    if (q != null && q > 0) {
      quantity = q;
      words = words.sublist(consumed);
      if (unit == 'dz') {
        quantity = q * 12;
        unit = 'un';
      }
    }
  }
  while (words.isNotEmpty &&
      const {'de', 'do', 'da', 'a', 'o'}.contains(words.first)) {
    words = words.sublist(1);
  }
  while (words.isNotEmpty && const {'a', 'o', 'e', 'de'}.contains(words.last)) {
    words = words.sublist(0, words.length - 1);
  }
  final name = words.join(' ');

  final meaning = amount == null
      ? SpokenPrice.none
      : saysTotal && !saysEach
      ? SpokenPrice.total
      : saysEach || quantity == 1
      ? SpokenPrice.perUnit
      : SpokenPrice.ambiguous;
  return SpokenItem(
    transcript: transcript,
    name: name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1),
    quantity: quantity,
    unit: unit,
    amountCents: amount,
    meaning: meaning,
  );
}
