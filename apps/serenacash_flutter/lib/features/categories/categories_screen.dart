import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/categories/categories.dart';
import '../../domain/entities/entities.dart';
import '../../ui/components/components.dart';
import '../shared/stack_screen.dart';
import 'category_widgets.dart';

/// Categories and their subcategories, by kind. Tapping one opens it for editing; the "+" on a category
/// adds a subcategory to it. Archived ones are listed apart. Tags live at the bottom.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});
  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _kind = 'expense';
  final _tag = TextEditingController();

  @override
  void dispose() {
    _tag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final uses = <String, int>{};
    for (final t in ledger.transactions) {
      final id = t.categoryId;
      if (id != null && t.deletedAt == null) uses[id] = (uses[id] ?? 0) + 1;
    }
    final all = rootCategories(ledger, _kind, includeArchived: true);
    final active = all.where((x) => !x.archived).toList();
    final archivedRoots = all.where((x) => x.archived).toList();
    // Archived subcategories of categories that are still in use.
    final archivedSubs = [
      for (final r in active)
        ...subcategoriesOf(
          ledger,
          r.id,
          includeArchived: true,
        ).where((s) => s.archived),
    ];

    Widget row(Category x, {bool sub = false, String? under}) {
      final subs = sub ? 0 : subcategoriesOf(ledger, x.id).length;
      final used = sub
          ? (uses[x.id] ?? 0)
          : categoryFamily(
              ledger,
              x.id,
            ).fold<int>(0, (a, id) => a + (uses[id] ?? 0));
      // Only what there is to say: an unused category without subcategories shows just its name.
      final facts = [
        ?under,
        if (subs > 0) l.catSubCount(subs),
        if (used > 0) l.catUsage(used),
      ];
      return ListRow(
        leading: CategoryMark.of(
          x,
          size: sub ? 26 : Layout.tile,
          muted: x.archived,
        ),
        title: x.name,
        description: facts.isEmpty ? null : facts.join(' · '),
        trailing: sub || x.archived
            ? null
            : SIconButton(
                icon: SIconName.plus,
                label: l.catAddSubTo(x.name),
                size: 20,
                color: c.primary,
                onPressed: () =>
                    openCategoryForm(context, kind: x.kind, parentId: x.id),
              ),
        chevron: sub || x.archived,
        onTap: () => openCategoryForm(context, id: x.id),
      );
    }

    return StackScreen(
      title: l.catTitle,
      actions: [
        SButton(
          label: l.newCategory,
          icon: SIconName.plus,
          variant: SButtonVariant.ghost,
          compact: true,
          onPressed: () => openCategoryForm(context, kind: _kind),
        ),
      ],
      children: [
        Segmented<String>(
          options: [('expense', l.expenses), ('income', l.income)],
          value: _kind,
          onChanged: (v) => setState(() => _kind = v),
        ),
        if (active.isEmpty)
          SCard(
            child: EmptyState(
              icon: SIconName.tag,
              title: l.catEmptyKind,
              actionLabel: l.newCategory,
              onAction: () => openCategoryForm(context, kind: _kind),
            ),
          )
        else
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(
                  title: _kind == 'expense'
                      ? l.expenseCategories
                      : l.incomeCategories,
                ),
                ...dividedRows([
                  for (final x in active)
                    Column(
                      children: [
                        row(x),
                        for (final s in subcategoriesOf(ledger, x.id))
                          Padding(
                            padding: const EdgeInsets.only(left: Spacing.lg),
                            child: row(s, sub: true),
                          ),
                      ],
                    ),
                ]),
              ],
            ),
          ),
        if (archivedRoots.isNotEmpty || archivedSubs.isNotEmpty)
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: l.catArchivedSection),
                Text(
                  l.catArchivedHelp,
                  style: Type.rowMeta.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Spacing.xxs),
                ...dividedRows([
                  for (final x in archivedRoots) row(x),
                  for (final s in archivedSubs)
                    row(
                      s,
                      sub: true,
                      under: ledger.categoryById(s.parentId)?.name,
                    ),
                ]),
              ],
            ),
          ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.tags),
              if (ledger.tags.isEmpty)
                Text(
                  l.tagsHelp,
                  style: Type.bodySmall.copyWith(color: c.textMuted),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final t in ledger.tags) SChip(label: t.name)],
                ),
              const SizedBox(height: Spacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: STextField(
                      label: l.newTag,
                      controller: _tag,
                      placeholder: l.tagHint,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SButton(
                    label: l.add,
                    onPressed: _tag.text.trim().isEmpty
                        ? null
                        : () async {
                            await ctl.saveTag(name: _tag.text.trim());
                            setState(_tag.clear);
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
