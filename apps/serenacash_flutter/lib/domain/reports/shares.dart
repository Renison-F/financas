/// Shares of a total for charts: percentages that add up to exactly 100,0% on screen, and small
/// categories grouped into one slice that still says what is inside it.
library;

import '../money/money.dart';
import 'reports.dart';

/// Shares in tenths of a percent (per mille) that sum to exactly 1000 whenever the total is
/// positive. Each value is rounded down and the units left over go to the largest remainders, so
/// "97,8% + 2,2%" never shows up as 99,9% or 100,1%.
List<int> sharesPerMille(List<int> values) {
  final total = values.fold<int>(0, (a, v) => a + (v > 0 ? v : 0));
  if (total <= 0) return List.filled(values.length, 0);
  final floors = <int>[], remainders = <(int, int)>[];
  var used = 0;
  for (var i = 0; i < values.length; i++) {
    final v = values[i] > 0 ? values[i] : 0;
    final f = v * 1000 ~/ total;
    floors.add(f);
    used += f;
    remainders.add((i, v * 1000 % total));
  }
  remainders.sort((a, b) {
    final d = b.$2.compareTo(a.$2);
    return d != 0 ? d : a.$1.compareTo(b.$1);
  });
  for (var k = 0; k < 1000 - used; k++) {
    floors[remainders[k % remainders.length].$1]++;
  }
  return floors;
}

/// "97,8" for 978.
String perMilleLabel(int perMille) => '${perMille ~/ 10},${perMille % 10}';

/// One slice of a chart of categories.
class CategorySlice {
  const CategorySlice({
    this.categoryId,
    required this.name,
    required this.color,
    required this.cents,
    required this.perMille,
    required this.count,
    this.members = const [],
  });
  final String? categoryId;
  final String name;
  final String color;
  final Cents cents;
  final int perMille;
  final int count;

  /// For the slice that groups the small categories: the categories inside it.
  final List<CategoryTotal> members;
  bool get isOther => members.isNotEmpty;
}

/// Slices for a chart: the largest [maxSlices] − 1 categories and, when there are more, one slice
/// with the rest (named [otherLabel]). Categories with nothing spent, or with a negative net because
/// of refunds, are left out: a slice cannot be negative. An empty list means there is nothing to
/// draw, and the screen says so instead of drawing a made-up ring.
List<CategorySlice> categorySlices(
  List<CategoryTotal> totals, {
  int maxSlices = 6,
  String otherLabel = 'Outras',
  String otherColor = '#8A949B',
}) {
  final positive = totals.where((t) => t.cents > 0).toList()
    ..sort((a, b) => b.cents.compareTo(a.cents));
  if (positive.isEmpty) return const [];
  final head = positive.length > maxSlices
      ? positive.sublist(0, maxSlices - 1)
      : positive;
  final rest = positive.length > maxSlices
      ? positive.sublist(maxSlices - 1)
      : const <CategoryTotal>[];
  final values = [
    ...head.map((t) => t.cents),
    if (rest.isNotEmpty) sumCents(rest.map((t) => t.cents)),
  ];
  final shares = sharesPerMille(values);
  return [
    for (var i = 0; i < head.length; i++)
      CategorySlice(
        categoryId: head[i].categoryId,
        name: head[i].name,
        color: head[i].color,
        cents: head[i].cents,
        perMille: shares[i],
        count: head[i].count,
      ),
    if (rest.isNotEmpty)
      CategorySlice(
        name: otherLabel,
        color: otherColor,
        cents: values.last,
        perMille: shares.last,
        count: rest.fold(0, (a, t) => a + t.count),
        members: rest,
      ),
  ];
}
