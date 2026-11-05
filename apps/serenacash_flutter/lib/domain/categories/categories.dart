/// Category tree: a category may have subcategories, and that is the whole hierarchy (two levels).
/// A subcategory has the kind of its category; nothing here can produce a cycle because a category that
/// has a parent can never be a parent itself.
library;

import '../entities/entities.dart';

enum CategoryError {
  emptyName,
  duplicateName,
  parentMissing,
  parentIsSelf,
  parentKindMismatch,
  parentIsSubcategory,
  hasSubcategories,
  kindChange,
  targetMissing,
  targetInFamily,
  targetKindMismatch,
}

/// Thrown by the app layer when a category change breaks one of the rules above.
class CategoryException implements Exception {
  const CategoryException(this.error);
  final CategoryError error;
  @override
  String toString() => 'CategoryException(${error.name})';
}

bool _live(Category c) => c.deletedAt == null;

int _bySort(Category a, Category b) {
  final s = a.sortOrder.compareTo(b.sortOrder);
  return s != 0 ? s : a.name.toLowerCase().compareTo(b.name.toLowerCase());
}

/// Main categories of [kind] ("expense" | "income"), in the user's order.
List<Category> rootCategories(
  Ledger ledger,
  String kind, {
  bool includeArchived = false,
}) =>
    ledger.categories
        .where(
          (c) =>
              _live(c) &&
              c.kind == kind &&
              c.parentId == null &&
              (includeArchived || !c.archived),
        )
        .toList()
      ..sort(_bySort);

/// Subcategories of [parentId], in the user's order.
List<Category> subcategoriesOf(
  Ledger ledger,
  String parentId, {
  bool includeArchived = false,
}) =>
    ledger.categories
        .where(
          (c) =>
              _live(c) &&
              c.parentId == parentId &&
              (includeArchived || !c.archived),
        )
        .toList()
      ..sort(_bySort);

/// The main category of [id]: itself when it is one, its parent when it is a subcategory.
Category? rootCategoryOf(Ledger ledger, String? id) {
  final c = ledger.categoryById(id);
  if (c == null) return null;
  if (c.parentId == null) return c;
  return ledger.categoryById(c.parentId) ?? c;
}

/// "Moradia › Aluguel" for a subcategory, "Moradia" for a main category, null when unknown.
String? categoryPath(Ledger ledger, String? id, {String separator = ' › '}) {
  final c = ledger.categoryById(id);
  if (c == null) return null;
  final parent = c.parentId == null ? null : ledger.categoryById(c.parentId);
  return parent == null ? c.name : '${parent.name}$separator${c.name}';
}

/// [id] and its subcategories: what "this category" means for filters, totals and deletion.
Set<String> categoryFamily(Ledger ledger, String id) => {
  id,
  for (final c in ledger.categories)
    if (_live(c) && c.parentId == id) c.id,
};

/// Whether an entry filed under [categoryId] belongs to [filterId] (the category or one of its subcategories).
bool inCategory(Ledger ledger, String? categoryId, String filterId) {
  if (categoryId == null) return false;
  if (categoryId == filterId) return true;
  return ledger.categoryById(categoryId)?.parentId == filterId;
}

/// A category is out of the pickers when it is archived or sits under an archived category.
bool isCategoryArchived(Ledger ledger, Category c) {
  if (c.archived) return true;
  final parent = c.parentId == null ? null : ledger.categoryById(c.parentId);
  return parent?.archived ?? false;
}

/// Checks a create ([id] null) or an edit before it is stored.
CategoryError? validateCategory(
  Ledger ledger, {
  String? id,
  required String name,
  required String kind,
  String? parentId,
}) {
  final clean = name.trim();
  if (clean.isEmpty) return CategoryError.emptyName;
  final existing = id == null ? null : ledger.categoryById(id);
  if (existing != null && existing.kind != kind) {
    return CategoryError.kindChange;
  }
  if (parentId != null) {
    if (parentId == id) return CategoryError.parentIsSelf;
    final parent = ledger.categoryById(parentId);
    if (parent == null || !_live(parent)) return CategoryError.parentMissing;
    if (parent.kind != kind) return CategoryError.parentKindMismatch;
    if (parent.parentId != null) return CategoryError.parentIsSubcategory;
    if (id != null &&
        subcategoriesOf(ledger, id, includeArchived: true).isNotEmpty) {
      return CategoryError.hasSubcategories;
    }
  }
  final lower = clean.toLowerCase();
  final clash = ledger.categories.any(
    (c) =>
        _live(c) &&
        c.id != id &&
        c.kind == kind &&
        c.parentId == parentId &&
        c.name.trim().toLowerCase() == lower,
  );
  return clash ? CategoryError.duplicateName : null;
}

/// What still points at [id] or at one of its subcategories.
({int transactions, int budgets, int subcategories}) categoryUsage(
  Ledger ledger,
  String id,
) {
  final family = categoryFamily(ledger, id);
  return (
    transactions: ledger.transactions
        .where((t) => t.deletedAt == null && family.contains(t.categoryId))
        .length,
    budgets: ledger.budgets
        .where((b) => b.deletedAt == null && family.contains(b.categoryId))
        .length,
    subcategories: family.length - 1,
  );
}

/// Where the entries of a category being deleted may go: another live category of the same kind that is
/// not being deleted with it. A null [targetId] means "leave them without a category".
CategoryError? validateReclassifyTarget(
  Ledger ledger,
  String id,
  String? targetId,
) {
  if (targetId == null) return null;
  final source = ledger.categoryById(id);
  final target = ledger.categoryById(targetId);
  if (source == null || target == null || !_live(target)) {
    return CategoryError.targetMissing;
  }
  if (categoryFamily(ledger, id).contains(targetId)) {
    return CategoryError.targetInFamily;
  }
  if (target.kind != source.kind) return CategoryError.targetKindMismatch;
  return null;
}
