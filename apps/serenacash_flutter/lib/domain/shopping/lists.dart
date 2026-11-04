/// Shopping lists. Estimates only sum known prices: unknown items are counted, never guessed. Mirrors `lists.ts`.
library;

import '../money/money.dart';
import 'units.dart';

class ListItem {
  const ListItem({
    required this.id,
    required this.name,
    this.brand,
    this.category,
    required this.unit,
    required this.quantity,
    this.estimatedUnitPriceCents,
    this.estimateSource,
    this.productId,
    this.barcode,
    required this.checked,
    this.note,
    required this.sortOrder,
  });
  final String id;
  final String name;
  final String? brand;
  final String? category;
  final String unit;
  final double quantity;
  final Cents? estimatedUnitPriceCents;
  final String? estimateSource; // history | manual | last_purchase
  final String? productId;
  final String? barcode;
  final bool checked;
  final String? note;
  final int sortOrder;
  factory ListItem.fromJson(Map<String, dynamic> j) => ListItem(
    id: j['id'] as String,
    name: j['name'] as String,
    brand: j['brand'] as String?,
    category: j['category'] as String?,
    unit: j['unit'] as String,
    quantity: (j['quantity'] as num).toDouble(),
    estimatedUnitPriceCents: (j['estimatedUnitPriceCents'] as num?)?.toInt(),
    estimateSource: j['estimateSource'] as String?,
    productId: j['productId'] as String?,
    barcode: j['barcode'] as String?,
    checked: j['checked'] as bool? ?? false,
    note: j['note'] as String?,
    sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (brand != null) 'brand': brand,
    if (category != null) 'category': category,
    'unit': unit,
    'quantity': quantity,
    if (estimatedUnitPriceCents != null)
      'estimatedUnitPriceCents': estimatedUnitPriceCents,
    if (estimateSource != null) 'estimateSource': estimateSource,
    if (productId != null) 'productId': productId,
    if (barcode != null) 'barcode': barcode,
    'checked': checked,
    if (note != null) 'note': note,
    'sortOrder': sortOrder,
  };
  ListItem copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    String? unit,
    double? quantity,
    Cents? estimatedUnitPriceCents,
    String? estimateSource,
    String? productId,
    String? barcode,
    bool? checked,
    String? note,
    int? sortOrder,
  }) => ListItem(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand ?? this.brand,
    category: category ?? this.category,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    estimatedUnitPriceCents:
        estimatedUnitPriceCents ?? this.estimatedUnitPriceCents,
    estimateSource: estimateSource ?? this.estimateSource,
    productId: productId ?? this.productId,
    barcode: barcode ?? this.barcode,
    checked: checked ?? this.checked,
    note: note ?? this.note,
    sortOrder: sortOrder ?? this.sortOrder,
  );
}

class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.name,
    this.store,
    this.budgetCents,
    required this.items,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
    this.lastCompletedAt,
    this.shareToken,
  });
  final String id;
  final String name;
  final String? store;
  final Cents? budgetCents;
  final List<ListItem> items;
  final bool archived;
  final String createdAt;
  final String updatedAt;
  final String? lastCompletedAt;
  final String? shareToken;
  factory ShoppingList.fromJson(Map<String, dynamic> j) => ShoppingList(
    id: j['id'] as String,
    name: j['name'] as String,
    store: j['store'] as String?,
    budgetCents: (j['budgetCents'] as num?)?.toInt(),
    items: (j['items'] as List<dynamic>? ?? const [])
        .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    archived: j['archived'] as bool? ?? false,
    createdAt: j['createdAt'] as String,
    updatedAt: j['updatedAt'] as String,
    lastCompletedAt: j['lastCompletedAt'] as String?,
    shareToken: j['shareToken'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (store != null) 'store': store,
    if (budgetCents != null) 'budgetCents': budgetCents,
    'items': items.map((i) => i.toJson()).toList(),
    'archived': archived,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (lastCompletedAt != null) 'lastCompletedAt': lastCompletedAt,
    if (shareToken != null) 'shareToken': shareToken,
  };
  ShoppingList copyWith({
    String? id,
    String? name,
    String? store,
    Cents? budgetCents,
    List<ListItem>? items,
    bool? archived,
    String? createdAt,
    String? updatedAt,
    String? lastCompletedAt,
    String? shareToken,
    bool clearCompletion = false,
  }) => ShoppingList(
    id: id ?? this.id,
    name: name ?? this.name,
    store: store ?? this.store,
    budgetCents: budgetCents ?? this.budgetCents,
    items: items ?? this.items,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastCompletedAt: clearCompletion
        ? null
        : (lastCompletedAt ?? this.lastCompletedAt),
    shareToken: clearCompletion ? null : (shareToken ?? this.shareToken),
  );
}

const defaultCategories = <String>[
  'Hortifruti',
  'Padaria',
  'Açougue e peixaria',
  'Frios e laticínios',
  'Mercearia',
  'Bebidas',
  'Limpeza',
  'Higiene e beleza',
  'Pet',
  'Bebê',
  'Outros',
];

class ListEstimate {
  const ListEstimate({
    required this.knownCents,
    required this.knownItems,
    required this.unknownItems,
    required this.totalItems,
    required this.coveragePercent,
    this.budgetCents,
    this.remainingCents,
  });
  final Cents knownCents;
  final int knownItems;
  final int unknownItems;
  final int totalItems;
  final int coveragePercent;
  final Cents? budgetCents;
  final Cents? remainingCents;
  Map<String, dynamic> toJson() => {
    'knownCents': knownCents,
    'knownItems': knownItems,
    'unknownItems': unknownItems,
    'totalItems': totalItems,
    'coveragePercent': coveragePercent,
    if (budgetCents != null) 'budgetCents': budgetCents,
    if (remainingCents != null) 'remainingCents': remainingCents,
  };
}

int _jsRound(double v) => (v + 0.5).floorToDouble().toInt();

ListEstimate estimateList(ShoppingList list) {
  final active = list.items;
  final known = active.where((i) => i.estimatedUnitPriceCents != null).toList();
  final knownCents = sumCents(
    known.map(
      (i) => mulCents(
        i.estimatedUnitPriceCents!,
        normalizeQuantity(i.quantity, i.unit),
        RoundingMode.halfUp,
      ),
    ),
  );
  return ListEstimate(
    knownCents: knownCents,
    knownItems: known.length,
    unknownItems: active.length - known.length,
    totalItems: active.length,
    coveragePercent: active.isEmpty
        ? 0
        : _jsRound(known.length / active.length * 100),
    budgetCents: list.budgetCents,
    remainingCents: list.budgetCents == null
        ? null
        : list.budgetCents! - knownCents,
  );
}

class CategoryGroup {
  const CategoryGroup(this.category, this.items);
  final String category;
  final List<ListItem> items;
}

List<CategoryGroup> groupByCategory(List<ListItem> items) {
  final map = <String, List<ListItem>>{};
  final sorted = [...items]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  for (final it in sorted) {
    (map[it.category ?? 'Outros'] ??= []).add(it);
  }
  int rank(String k) {
    final i = defaultCategories.indexOf(k);
    return i == -1 ? 99 : i;
  }

  final entries = map.entries.toList()
    ..sort((a, b) => rank(a.key).compareTo(rank(b.key)));
  return entries.map((e) => CategoryGroup(e.key, e.value)).toList();
}

ShoppingList addItem(ShoppingList list, ListItem item, String now) {
  final key = item.name.trim().toLowerCase();
  final existing = list.items
      .where(
        (i) =>
            i.name.trim().toLowerCase() == key &&
            i.unit == item.unit &&
            !units[i.unit]!.measured,
      )
      .firstOrNull;
  if (existing != null) {
    return updateItem(
      list,
      existing.id,
      (i) => i.copyWith(quantity: i.quantity + item.quantity),
      now,
    );
  }
  return list.copyWith(
    updatedAt: now,
    items: [
      ...list.items,
      item.copyWith(checked: false, sortOrder: list.items.length),
    ],
  );
}

ShoppingList updateItem(
  ShoppingList list,
  String id,
  ListItem Function(ListItem) patch,
  String now,
) => list.copyWith(
  updatedAt: now,
  items: list.items.map((i) => i.id == id ? patch(i) : i).toList(),
);

ShoppingList removeItem(ShoppingList list, String id, String now) {
  final rest = list.items.where((i) => i.id != id).toList();
  return list.copyWith(
    updatedAt: now,
    items: [
      for (var k = 0; k < rest.length; k++) rest[k].copyWith(sortOrder: k),
    ],
  );
}

ShoppingList toggleItem(ShoppingList list, String id, String now) {
  final cur = list.items.where((i) => i.id == id).firstOrNull?.checked ?? false;
  return updateItem(list, id, (i) => i.copyWith(checked: !cur), now);
}

ShoppingList uncheckAll(ShoppingList list, String now) => list.copyWith(
  updatedAt: now,
  items: list.items.map((i) => i.copyWith(checked: false)).toList(),
);

ShoppingList duplicateList(
  ShoppingList list,
  String newId,
  String Function() itemId,
  String now, [
  String? name,
]) => list.copyWith(
  id: newId,
  name: name ?? '${list.name} (cópia)',
  archived: false,
  createdAt: now,
  updatedAt: now,
  clearCompletion: true,
  items: list.items
      .map((i) => i.copyWith(id: itemId(), checked: false))
      .toList(),
);

class ListProgress {
  const ListProgress(this.checked, this.total, this.percent);
  final int checked;
  final int total;
  final int percent;
  Map<String, dynamic> toJson() => {
    'checked': checked,
    'total': total,
    'percent': percent,
  };
}

ListProgress listProgress(ShoppingList list) {
  final total = list.items.length;
  final checked = list.items.where((i) => i.checked).length;
  return ListProgress(
    checked,
    total,
    total == 0 ? 0 : _jsRound(checked / total * 100),
  );
}
