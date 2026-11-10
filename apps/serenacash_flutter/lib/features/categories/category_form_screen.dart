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

String categoryErrorText(AppLocalizations l, CategoryError e) => switch (e) {
  CategoryError.emptyName => l.catErrEmpty,
  CategoryError.duplicateName => l.catErrDuplicate,
  CategoryError.hasSubcategories => l.catErrHasSubs,
  CategoryError.targetMissing ||
  CategoryError.targetInFamily ||
  CategoryError.targetKindMismatch => l.catErrTarget,
  _ => l.catErrParent,
};

/// Creates or edits a category or a subcategory: name, kind, main category, color and icon, with a
/// preview. Pops with the saved [Category], so whoever opened it can select the new item.
class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({
    super.key,
    this.id,
    this.kind = 'expense',
    this.parentId,
    this.initialName,
    this.lockKind = false,
  });
  final String? id;
  final String kind;
  final String? parentId;
  final String? initialName;

  /// The caller needs a category of [kind] (an expense being filled in, for example).
  final bool lockKind;
  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  late final Category? existing = widget.id == null
      ? null
      : ref.read(ledgerProvider).categoryById(widget.id);
  late final Category? _givenParent = ref
      .read(ledgerProvider)
      .categoryById(widget.parentId);
  late final _name = TextEditingController(
    text: existing?.name ?? widget.initialName ?? '',
  );
  late String _kind = existing?.kind ?? _givenParent?.kind ?? widget.kind;
  late String? _parentId = existing?.parentId ?? widget.parentId;
  late String _color =
      existing?.color ?? _givenParent?.color ?? categoryPalette.first;
  late SIconName _icon = iconByKey(
    existing?.icon ?? _givenParent?.icon ?? 'tag',
  );
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l = context.l10n;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await ref
          .read(appControllerProvider.notifier)
          .saveCategory(
            id: existing?.id,
            name: _name.text,
            kind: _kind,
            parentId: _parentId,
            setParent: true,
            color: _color,
            icon: iconKey(_icon),
          );
      if (mounted) Navigator.of(context).pop(saved);
    } on CategoryException catch (e) {
      if (mounted) {
        setState(() {
          _error = categoryErrorText(l, e.error);
          _saving = false;
        });
      }
    }
  }

  Future<void> _pickParent() async {
    final l = context.l10n;
    final choice = await showCategoryPicker(
      context,
      kind: _kind,
      selectedId: _parentId,
      title: l.catParent,
      rootsOnly: true,
      allowNone: true,
      noneLabel: l.catParentNone,
      exclude: {?existing?.id},
      allowCreate: false,
    );
    if (choice != null && mounted) setState(() => _parentId = choice.id);
  }

  Future<void> _toggleArchive() async {
    final e = existing!;
    final l = context.l10n;
    if (!e.archived) {
      final ok = await confirmSheet(
        context,
        title: '${l.catArchive} “${e.name}”?',
        text: l.catArchiveText,
        confirmLabel: l.catArchive,
        cancelLabel: l.cancel,
        destructive: false,
      );
      if (!ok) return;
    }
    await ref
        .read(appControllerProvider.notifier)
        .archiveCategory(e.id, archived: !e.archived);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final e = existing!;
    final l = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final decision = await showSSheet<_DeleteDecision>(
      context,
      builder: (_) => _DeleteSheet(category: e),
    );
    if (decision == null) return;
    try {
      final r = await ref
          .read(appControllerProvider.notifier)
          .deleteCategory(e.id, moveToId: decision.moveToId);
      messenger?.showSnackBar(SnackBar(content: Text(l.catDeleted(r.moved))));
      if (mounted) Navigator.of(context).pop();
    } on CategoryException catch (err) {
      if (mounted) setState(() => _error = categoryErrorText(l, err.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final parent = ledger.categoryById(_parentId);
    final hasSubs =
        existing != null &&
        subcategoriesOf(ledger, existing!.id, includeArchived: true).isNotEmpty;
    final isSub = _parentId != null;
    final title = existing != null
        ? (isSub ? l.catEditSub : l.catEdit)
        : (isSub ? l.catNewSub : l.newCategory);
    final name = _name.text.trim();
    // The kind can be chosen only for a new main category that nobody is waiting for.
    final canPickKind =
        existing == null && !widget.lockKind && widget.parentId == null;

    return StackScreen(
      title: title,
      actions: [
        SButton(
          label: l.save,
          variant: SButtonVariant.ghost,
          loading: _saving,
          onPressed: _save,
        ),
      ],
      children: [
        SCard(
          child: Row(
            children: [
              CategoryMark(icon: iconKey(_icon), color: _color, size: 44),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.catPreview,
                      style: Type.label.copyWith(color: c.textMuted),
                    ),
                    Text(
                      name.isEmpty ? l.catPreviewName : name,
                      style: Type.title.copyWith(
                        color: name.isEmpty ? c.textMuted : c.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [
                        _kind == 'income' ? l.income : l.expenses,
                        if (parent != null) parent.name,
                      ].join(' › '),
                      style: Type.rowMeta.copyWith(color: c.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        STextField(
          label: l.name,
          controller: _name,
          placeholder: l.categoryNameHint,
          error: _error,
          autofocus: existing == null,
          maxLength: 40,
          onChanged: (_) => setState(() => _error = null),
        ),
        if (canPickKind)
          Field(
            label: l.type,
            child: Segmented<String>(
              options: [('expense', l.expenses), ('income', l.income)],
              value: _kind,
              onChanged: (v) => setState(() {
                _kind = v;
                // A main category of the other kind cannot be the parent.
                _parentId = null;
              }),
            ),
          ),
        Field(
          label: l.catParent,
          help: hasSubs ? l.catParentLocked : l.catParentHelp,
          child: SCard(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            onTap: hasSubs ? null : _pickParent,
            child: ListRow(
              leading: parent == null
                  ? IconTile(
                      icon: SIconName.layers,
                      color: c.textMuted,
                      background: c.surfaceInset,
                    )
                  : CategoryMark.of(parent),
              title: parent?.name ?? l.catParentNone,
              titleMaxLines: 2,
              chevron: !hasSubs,
            ),
          ),
        ),
        Field(
          label: l.color,
          child: CategoryColorPicker(
            value: _color,
            onChanged: (v) => setState(() => _color = v),
          ),
        ),
        Field(
          label: l.catIcon,
          child: CategoryIconPicker(
            value: _icon,
            color: _color,
            onChanged: (v) => setState(() => _icon = v),
          ),
        ),
        if (existing != null) ...[
          if (existing!.archived)
            Text(
              l.catArchivedHelp,
              style: Type.bodySmall.copyWith(color: c.textMuted),
            ),
          Row(
            children: [
              Expanded(
                child: SButton(
                  label: existing!.archived ? l.catReactivate : l.catArchive,
                  icon: SIconName.archive,
                  variant: SButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: _toggleArchive,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: SButton(
                  label: l.catDelete,
                  icon: SIconName.trash,
                  variant: SButtonVariant.destructive,
                  fullWidth: true,
                  onPressed: _delete,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DeleteDecision {
  const _DeleteDecision(this.moveToId);
  final String? moveToId;
}

/// Says what deleting the category touches and, when entries use it, asks where they go. Nothing is
/// deleted until the destination is explicit.
class _DeleteSheet extends ConsumerStatefulWidget {
  const _DeleteSheet({required this.category});
  final Category category;
  @override
  ConsumerState<_DeleteSheet> createState() => _DeleteSheetState();
}

class _DeleteSheetState extends ConsumerState<_DeleteSheet> {
  /// 'move' | 'none' — unset until the user chooses.
  String? _mode;
  String? _targetId;

  Future<void> _pickTarget() async {
    final ledger = ref.read(ledgerProvider);
    final choice = await showCategoryPicker(
      context,
      kind: widget.category.kind,
      selectedId: _targetId,
      title: context.l10n.catMoveToPick,
      exclude: categoryFamily(ledger, widget.category.id),
      allowCreate: false,
    );
    if (choice?.id != null && mounted) {
      setState(() {
        _mode = 'move';
        _targetId = choice!.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final usage = categoryUsage(ledger, widget.category.id);
    final used = usage.transactions > 0;
    final target = ledger.categoryById(_targetId);
    final ready =
        !used || _mode == 'none' || (_mode == 'move' && target != null);
    Widget note(String s) => Padding(
      padding: const EdgeInsets.only(top: Spacing.xxs),
      child: Text(s, style: Type.bodySmall.copyWith(color: c.textMuted)),
    );
    Widget option(String mode, String label, {Widget? below}) => InkWell(
      onTap: mode == 'move' && target == null
          ? _pickTarget
          : () => setState(() => _mode = mode),
      borderRadius: BorderRadius.circular(Radii.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Touch.target),
        child: Row(
          children: [
            Semantics(
              checked: _mode == mode,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _mode == mode ? c.primary : c.borderStrong,
                    width: _mode == mode ? 6 : 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: Type.rowTitle.copyWith(color: c.text)),
                  ?below,
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.catDeleteTitle(widget.category.name),
            style: Type.headline.copyWith(color: c.text, fontSize: 18),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            used ? l.catDeleteUsed(usage.transactions) : l.catDeleteUnused,
            style: Type.body.copyWith(color: c.textMuted),
          ),
          if (used) ...[
            const SizedBox(height: Spacing.xs),
            option(
              'move',
              l.catMoveTo,
              below: target == null
                  ? null
                  : Text(
                      categoryPath(ledger, target.id) ?? target.name,
                      style: Type.rowMeta.copyWith(color: c.primary),
                    ),
            ),
            if (_mode == 'move' && target != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SButton(
                  label: l.catMoveToPick,
                  variant: SButtonVariant.ghost,
                  compact: true,
                  onPressed: _pickTarget,
                ),
              ),
            option('none', l.catLeaveNone),
          ],
          if (usage.subcategories > 0)
            note(l.catDeleteSubs(usage.subcategories)),
          if (usage.budgets > 0) note(l.catDeleteBudgets(usage.budgets)),
          const SizedBox(height: Spacing.md),
          SButton(
            label: l.catDeleteConfirm,
            variant: SButtonVariant.destructive,
            fullWidth: true,
            onPressed: ready
                ? () => Navigator.of(context)
                      .pop(_DeleteDecision(_mode == 'move' ? _targetId : null))
                : null,
          ),
          const SizedBox(height: Spacing.xs),
          SButton(
            label: l.cancel,
            variant: SButtonVariant.ghost,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
