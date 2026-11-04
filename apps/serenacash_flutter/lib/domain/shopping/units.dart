/// Units used in Brazilian supermarkets. Quantities are doubles normalized to the unit's decimal scale
/// (0 for countable, 3 for weight/volume, 2 for metres); money math snaps float noise before rounding.
library;

import 'package:intl/intl.dart';

class UnitDefinition {
  const UnitDefinition({
    required this.id,
    required this.label,
    required this.name,
    required this.plural,
    required this.base,
    required this.toBase,
    required this.decimals,
    required this.measured,
  });
  final String id;
  final String label;
  final String name;
  final String plural;
  final String base; // un | kg | l | m
  final double toBase;
  final int decimals;
  final bool measured;
}

const units = <String, UnitDefinition>{
  'un': UnitDefinition(
    id: 'un',
    label: 'un',
    name: 'unidade',
    plural: 'unidades',
    base: 'un',
    toBase: 1,
    decimals: 0,
    measured: false,
  ),
  'kg': UnitDefinition(
    id: 'kg',
    label: 'kg',
    name: 'quilo',
    plural: 'quilos',
    base: 'kg',
    toBase: 1,
    decimals: 3,
    measured: true,
  ),
  'g': UnitDefinition(
    id: 'g',
    label: 'g',
    name: 'grama',
    plural: 'gramas',
    base: 'kg',
    toBase: 0.001,
    decimals: 0,
    measured: true,
  ),
  'l': UnitDefinition(
    id: 'l',
    label: 'L',
    name: 'litro',
    plural: 'litros',
    base: 'l',
    toBase: 1,
    decimals: 3,
    measured: true,
  ),
  'ml': UnitDefinition(
    id: 'ml',
    label: 'mL',
    name: 'mililitro',
    plural: 'mililitros',
    base: 'l',
    toBase: 0.001,
    decimals: 0,
    measured: true,
  ),
  'pct': UnitDefinition(
    id: 'pct',
    label: 'pct',
    name: 'pacote',
    plural: 'pacotes',
    base: 'un',
    toBase: 1,
    decimals: 0,
    measured: false,
  ),
  'dz': UnitDefinition(
    id: 'dz',
    label: 'dz',
    name: 'dúzia',
    plural: 'dúzias',
    base: 'un',
    toBase: 12,
    decimals: 0,
    measured: false,
  ),
  'cx': UnitDefinition(
    id: 'cx',
    label: 'cx',
    name: 'caixa',
    plural: 'caixas',
    base: 'un',
    toBase: 1,
    decimals: 0,
    measured: false,
  ),
  'm': UnitDefinition(
    id: 'm',
    label: 'm',
    name: 'metro',
    plural: 'metros',
    base: 'm',
    toBase: 1,
    decimals: 2,
    measured: true,
  ),
};

final unitIds = units.keys.toList();

int _jsRound(double v) => (v + 0.5).floorToDouble().toInt();

double normalizeQuantity(double q, String unit) {
  if (!q.isFinite || q < 0) throw ArgumentError('Quantidade inválida');
  final d = units[unit]!.decimals;
  final f = [1, 10, 100, 1000][d];
  return _jsRound(q * f) / f;
}

String formatQuantity(double q, String unit, {String locale = 'pt_BR'}) {
  final def = units[unit]!;
  final nf = NumberFormat.decimalPattern(locale)
    ..maximumFractionDigits = def.decimals
    ..minimumFractionDigits = 0;
  return '${nf.format(q)} ${def.label}';
}

({double quantity, String base}) toBaseQuantity(double q, String unit) {
  final def = units[unit]!;
  return (quantity: q * def.toBase, base: def.base);
}

const _unitTokens = {
  'kg': 'kg',
  'kilo': 'kg',
  'quilo': 'kg',
  'g': 'g',
  'gr': 'g',
  'grama': 'g',
  'gramas': 'g',
  'l': 'l',
  'lt': 'l',
  'litro': 'l',
  'litros': 'l',
  'ml': 'ml',
  'un': 'un',
  'und': 'un',
  'unid': 'un',
  'unidade': 'un',
  'pc': 'un',
  'pç': 'un',
  'peca': 'un',
  'peça': 'un',
  'pct': 'pct',
  'pacote': 'pct',
  'dz': 'dz',
  'duzia': 'dz',
  'dúzia': 'dz',
  'cx': 'cx',
  'caixa': 'cx',
  'm': 'm',
  'metro': 'm',
};

String? parseUnit(String token) {
  var t = token.trim().toLowerCase();
  if (t.endsWith('.')) t = t.substring(0, t.length - 1);
  return _unitTokens[t];
}
