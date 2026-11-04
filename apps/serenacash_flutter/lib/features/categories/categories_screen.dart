import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/state/app_controller.dart';
import '../../app/theme/tokens.dart';
import '../../ui/components/components.dart';
import '../accounts/account_form_screen.dart';
import '../shared/stack_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});
  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _kind = 'expense';
  final _name = TextEditingController();
  final _tag = TextEditingController();
  String? _parentId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final ledger = ref.watch(ledgerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final cats = ledger.categories
        .where((x) => x.kind == _kind && x.deletedAt == null)
        .toList();
    final roots = cats.where((x) => x.parentId == null).toList();
    Widget archiveBtn(String id, String name, String kind, bool archived) =>
        SButton(
          label: archived ? l.reactivate : l.archive,
          variant: SButtonVariant.ghost,
          compact: true,
          onPressed: () => ctl.saveCategory(
            id: id,
            name: name,
            kind: kind,
            archived: !archived,
          ),
        );
    return StackScreen(
      title: l.categoriesTags,
      children: [
        Segmented<String>(
          options: [('expense', l.expenses), ('income', l.income)],
          value: _kind,
          onChanged: (v) => setState(() {
            _kind = v;
            _parentId = null;
          }),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: l.newCategory),
              STextField(
                label: l.name,
                controller: _name,
                placeholder: l.categoryNameHint,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: Spacing.sm),
              Field(
                label: l.subcategoryOf,
                child: ChipSelect<String>(
                  options: [for (final x in roots) (x.id, x.name)],
                  value: _parentId,
                  allowNone: true,
                  onChanged: (v) => setState(() => _parentId = v),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              SButton(
                label: l.add,
                onPressed: _name.text.trim().isEmpty
                    ? null
                    : () async {
                        await ctl.saveCategory(
                          name: _name.text.trim(),
                          kind: _kind,
                          parentId: _parentId,
                        );
                        setState(() {
                          _name.clear();
                          _parentId = null;
                        });
                      },
              ),
            ],
          ),
        ),
        SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: _kind == 'expense'
                    ? l.expenseCategories
                    : l.incomeCategories,
              ),
              for (final x in roots) ...[
                ListRow(
                  icon: SIconName.tag,
                  iconColor: colorFromHex(x.color, c.textMuted),
                  title: x.name,
                  description: x.archived ? l.archivedLower : null,
                  trailing: archiveBtn(x.id, x.name, x.kind, x.archived),
                ),
                for (final sub in cats.where((s) => s.parentId == x.id))
                  ListRow(
                    title: '↳ ${sub.name}',
                    description: sub.archived ? l.archivedLower : null,
                    trailing: archiveBtn(
                      sub.id,
                      sub.name,
                      sub.kind,
                      sub.archived,
                    ),
                  ),
              ],
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
