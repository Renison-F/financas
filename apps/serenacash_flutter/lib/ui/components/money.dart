import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../domain/money/money.dart';

/// Screen-reader label: "mil duzentos e trinta e quatro reais e cinquenta e seis centavos" style.
String moneyAccessibilityLabel(int cents, {String currency = 'BRL'}) {
  final abs = cents.abs();
  final reais = abs ~/ 100, cent = abs % 100;
  final unit = currency == 'BRL' ? (reais == 1 ? 'real' : 'reais') : currency;
  final parts = [
    '$reais $unit',
    if (cent != 0) '$cent ${cent == 1 ? 'centavo' : 'centavos'}',
  ];
  return '${cents < 0 ? 'menos ' : ''}${parts.join(' e ')}';
}

enum MoneyRole { hero, headline, title, row, body, bodySmall }

/// Renders integer cents with tabular figures, explicit sign, color by the "Regra do Sinal",
/// privacy mode (R$ ••••) and a spoken accessibility label. Hero role shows cents at 60% size.
class Money extends StatelessWidget {
  const Money(
    this.cents, {
    super.key,
    this.role = MoneyRole.row,
    this.signed = false,
    this.color,
    this.showPlus = false,
    this.currency = 'BRL',
    required this.hidden,
    this.align = TextAlign.start,
  });
  final int cents;
  final MoneyRole role;
  final bool signed;
  final Color? color;
  final bool showPlus;
  final String currency;
  final bool hidden;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone =
        color ??
        (signed
            ? (cents < 0
                  ? c.negative
                  : cents > 0
                  ? c.positive
                  : c.text)
            : c.text);
    final text = formatBRL(cents, hidden: hidden, currency: currency);
    final label = hidden
        ? 'valor oculto'
        : moneyAccessibilityLabel(cents, currency: currency);
    final plus = showPlus && cents > 0 ? '+' : '';
    final style = switch (role) {
      MoneyRole.hero => Type.moneyHero,
      MoneyRole.headline => Type.headline.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      MoneyRole.title => Type.title.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      MoneyRole.row => Type.moneyRow,
      MoneyRole.body => Type.body.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      MoneyRole.bodySmall => Type.bodySmall.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    }.copyWith(color: tone);
    if (role == MoneyRole.hero && !hidden) {
      final idx = text.lastIndexOf(',');
      final main = idx >= 0 ? text.substring(0, idx) : text;
      final cent = idx >= 0 ? text.substring(idx) : '';
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$plus$main', style: style),
              TextSpan(
                text: cent,
                style: style.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Text(
        '$plus$text',
        style: style,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
