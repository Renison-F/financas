/// Shared pieces of the category screens: the colored mark, the color and icon pickers and the bottom
/// sheet that selects a category (with search and creation on the spot).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../domain/categories/categories.dart';
import '../../domain/entities/entities.dart';
import '../../ui/components/components.dart';
import '../accounts/account_form_screen.dart' show colorFromHex, colorName;
import 'category_form_screen.dart';

/// The color of a category as it should be drawn on the current theme (lighter on dark surfaces).
Color categoryTone(BuildContext context, String hex) {
  final base = colorFromHex(hex, context.colors.primary);
  return Theme.of(context).brightness == Brightness.dark
      ? Color.lerp(base, Colors.white, 0.45)!
      : base;
}

/// Icon of a category on a tile tinted with its color.
class CategoryMark extends StatelessWidget {
  const CategoryMark({
    super.key,
    required this.icon,
    required this.color,
    this.size = Layout.tile,
    this.muted = false,
  });

  /// The mark of [c] in its own color. Entries keep that color even after the category is archived;
  /// only the screens that manage categories pass [muted] for archived ones.
  CategoryMark.of(
    Category c, {
    super.key,
    this.size = Layout.tile,
    this.muted = false,
  }) : icon = c.icon,
       color = c.color;

  /// Icon key as stored ("cart", "arrow-up").
  final String icon;
  final String color;
  final double size;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = muted ? c.textMuted : categoryTone(context, color);
    return IconTile(
      icon: iconByKey(icon),
      color: tone,
      background: muted ? c.surfaceInset : tone.withValues(alpha: 0.14),
      size: size,
    );
  }
}

/// Swatches of [categoryPalette]; the selected one carries a ring and a check.
class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      children: [
        for (final h in categoryPalette)
          Semantics(
            container: true,
            selected: h.toUpperCase() == value.toUpperCase(),
            button: true,
            label: colorName(context.l10n, h),
            excludeSemantics: true,
            child: InkWell(
              onTap: () => onChanged(h),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: Touch.target,
                height: Touch.target,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorFromHex(h, c.primary),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: h.toUpperCase() == value.toUpperCase()
                            ? c.text
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: h.toUpperCase() == value.toUpperCase()
                        ? const Center(
                            child: SIcon(
                              SIconName.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Searchable grid of the icon library.
class CategoryIconPicker extends StatefulWidget {
  const CategoryIconPicker({
    super.key,
    required this.value,
    required this.color,
    required this.onChanged,
  });
  final SIconName value;
  final String color;
  final ValueChanged<SIconName> onChanged;
  @override
  State<CategoryIconPicker> createState() => _CategoryIconPickerState();
}

class _CategoryIconPickerState extends State<CategoryIconPicker> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final found = searchCategoryIcons(_query);
    final tone = categoryTone(context, widget.color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        STextField(
          placeholder: l.catSearchIcon,
          semanticLabel: l.catSearchIcon,
          onChanged: (v) => setState(() => _query = v),
          textInputAction: TextInputAction.search,
        ),
        const SizedBox(height: Spacing.xs),
        if (found.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Text(
              l.catNoIcon(_query.trim()),
              style: Type.bodySmall.copyWith(color: c.textMuted),
            ),
          )
        else
          Wrap(
            children: [
              for (final i in found)
                Semantics(
                  key: ValueKey(i.icon),
                  // Its own node, always: when the search leaves a single icon, a non-container
                  // annotation is absorbed by the surrounding node and the button is never announced.
                  container: true,
                  selected: i.icon == widget.value,
                  button: true,
                  label: i.keywords.split(' ').first,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => widget.onChanged(i.icon),
                    borderRadius: BorderRadius.circular(Radii.sm),
                    child: SizedBox(
                      width: Touch.target,
                      height: Touch.target,
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: i.icon == widget.value
                                ? tone.withValues(alpha: 0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(Radii.sm),
                            border: Border.all(
                              color: i.icon == widget.value
                                  ? tone
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: SIcon(
                              i.icon,
                              size: 22,
                              color: i.icon == widget.value
                                  ? tone
                                  : c.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// What a category picker returns: the chosen category, or none when [id] is null.
class CategoryChoice {
  const CategoryChoice(this.id);
  final String? id;
}

/// Opens the category picker as a bottom sheet. Returns null when dismissed.
///
/// [rootsOnly] lists main categories only (choosing a parent, a budget or a destination);
/// [exclude] hides categories (and what sits under them); [allowCreate] adds the creation actions.
Future<CategoryChoice?> showCategoryPicker(
  BuildContext context, {
  required String kind,
  String? selectedId,
  String? title,
  bool rootsOnly = false,
  bool allowNone = false,
  String? noneLabel,
  Set<String> exclude = const {},
  bool allowCreate = true,
}) => showSSheet<CategoryChoice>(
  context,
  useRootNavigator: true,
  builder: (_) => _CategoryPickerSheet(
    kind: kind,
    selectedId: selectedId,
    title: title,
    rootsOnly: rootsOnly,
    allowNone: allowNone,
    noneLabel: noneLabel,
    exclude: exclude,
    allowCreate: allowCreate,
  ),
);

/// Opens the category form on top of whatever is on screen and returns what was saved.
Future<Category?> openCategoryForm(
  BuildContext context, {
  String? id,
  String kind = 'expense',
  String? parentId,
  String? initialName,
  bool lockKind = false,
}) => Navigator.of(context, rootNavigator: true).push<Category>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => CategoryFormScreen(
      id: id,
      kind: kind,
      parentId: parentId,
      initialName: initialName,
      lockKind: lockKind,
    ),
  ),
);

class _CategoryPickerSheet extends ConsumerStatefulWidget {
  const _CategoryPickerSheet({
    required this.kind,
    required this.selectedId,
    required this.title,
    required this.rootsOnly,
    required this.allowNone,
    required this.noneLabel,
    required this.exclude,
    required this.allowCreate,
  });
  final String kind;
  final String? selectedId;
  final String? title;
  final bool rootsOnly;
  final bool allowNone;
  final String? noneLabel;
  final Set<String> exclude;
  final bool allowCreate;
  @override
  ConsumerState<_CategoryPickerSheet> createState() =>
      _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<_CategoryPickerSheet> {
  String _query = '';

  void _pick(String? id) => Navigator.of(context).pop(CategoryChoice(id));

  Future<void> _create({String? parentId, String? name}) async {
    final created = await openCategoryForm(
      context,
      kind: widget.kind,
      parentId: parentId,
      initialName: name,
      lockKind: true,
    );
    if (created != null && mounted) _pick(created.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final ledger = ref.watch(ledgerProvider);
    final q = foldForSearch(_query.trim());
    bool matches(Category x) => q.isEmpty || foldForSearch(x.name).contains(q);

    final rows = <Widget>[];
    var exact = false;
    for (final root in rootCategories(ledger, widget.kind)) {
      if (widget.exclude.contains(root.id)) continue;
      final subs = widget.rootsOnly
          ? const <Category>[]
          : subcategoriesOf(
              ledger,
              root.id,
            ).where((s) => !widget.exclude.contains(s.id)).toList();
      final rootHit = matches(root);
      final shownSubs = rootHit ? subs : subs.where(matches).toList();
      if (!rootHit && shownSubs.isEmpty) continue;
      if (foldForSearch(root.name) == q) exact = true;
      rows.add(
        ListRow(
          leading: CategoryMark.of(root),
          title: root.name,
          description: subs.isEmpty ? null : l.catSubCount(subs.length),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.selectedId == root.id)
                SIcon(SIconName.check, size: 20, color: c.primary),
              if (widget.allowCreate && !widget.rootsOnly)
                SIconButton(
                  icon: SIconName.plus,
                  label: l.catAddSubTo(root.name),
                  size: 20,
                  color: c.primary,
                  onPressed: () => _create(parentId: root.id),
                ),
            ],
          ),
          onTap: () => _pick(root.id),
        ),
      );
      for (final s in shownSubs) {
        if (foldForSearch(s.name) == q) exact = true;
        rows.add(
          Padding(
            padding: const EdgeInsets.only(left: Spacing.lg),
            child: ListRow(
              leading: CategoryMark.of(s, size: 26),
              title: s.name,
              trailing: widget.selectedId == s.id
                  ? SIcon(SIconName.check, size: 20, color: c.primary)
                  : null,
              onTap: () => _pick(s.id),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            0,
            Spacing.md,
            Spacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title ?? l.catChoose,
                style: Type.headline.copyWith(color: c.text, fontSize: 18),
              ),
              const SizedBox(height: Spacing.sm),
              STextField(
                placeholder: l.catSearch,
                semanticLabel: l.catSearch,
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
              ),
              const SizedBox(height: Spacing.xs),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    if (widget.allowNone && q.isEmpty)
                      ListRow(
                        icon: SIconName.close,
                        iconColor: c.textMuted,
                        tileColor: c.surfaceInset,
                        title: widget.noneLabel ?? l.catNone,
                        trailing: widget.selectedId == null
                            ? SIcon(SIconName.check, size: 20, color: c.primary)
                            : null,
                        onTap: () => _pick(null),
                      ),
                    ...rows,
                    if (rows.isEmpty && q.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.sm,
                        ),
                        child: Text(
                          l.catNotFound(_query.trim()),
                          style: Type.bodySmall.copyWith(color: c.textMuted),
                        ),
                      ),
                    if (rows.isEmpty && q.isEmpty && !widget.allowNone)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.sm,
                        ),
                        child: Text(
                          l.catEmptyKind,
                          style: Type.bodySmall.copyWith(color: c.textMuted),
                        ),
                      ),
                    // Typed a name that does not exist: one tap creates it and selects it.
                    if (widget.allowCreate && q.isNotEmpty && !exact)
                      ListRow(
                        icon: SIconName.plus,
                        title: l.catCreateNamed(_query.trim()),
                        onTap: () => _create(name: _query.trim()),
                      ),
                  ],
                ),
              ),
              if (widget.allowCreate) ...[
                const SizedBox(height: Spacing.xs),
                SButton(
                  label: l.newCategory,
                  icon: SIconName.plus,
                  variant: SButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: _create,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
