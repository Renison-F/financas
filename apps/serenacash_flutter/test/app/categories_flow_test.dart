/// Categories and subcategories: hierarchy rules, creation while an entry is being filled in, icon and
/// color, archiving, and deletion with reclassification. Everything runs on an in-memory database.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serenacash/app/app.dart';
import 'package:serenacash/app/di.dart';
import 'package:serenacash/app/state/app_controller.dart';
import 'package:serenacash/app/state/app_state.dart';
import 'package:serenacash/domain/categories/categories.dart';
import 'package:serenacash/domain/entities/entities.dart';
import 'package:serenacash/domain/budgets/budgets.dart';
import 'package:serenacash/domain/ports/ports.dart';
import 'package:serenacash/domain/reports/reports.dart';
import 'package:serenacash/features/categories/categories_screen.dart';
import 'package:serenacash/features/categories/category_form_screen.dart';
import 'package:serenacash/features/transactions/transaction_form_screen.dart';

import 'package:serenacash/ui/components/components.dart';

import 'harness.dart';
import 'kv_factory.dart';

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SerenaCashApp)));

Future<TestApp> _boot(WidgetTester tester) async {
  final app = TestApp();
  addTearDown(app.dispose);
  await app.db.into(app.db.kv).insert(KvCompanionFactory.onboarded());
  await pumpApp(tester, app);
  return app;
}

Category _cat(Ledger l, String name) =>
    l.categories.firstWhere((c) => c.name == name);

Future<T> _run<T>(WidgetTester tester, Future<T> Function() op) async {
  final r = await tester.runAsync(op);
  await tester.pumpAndSettle();
  return r as T;
}

/// Scrolls the category form until [finder] is built and on screen.
Future<void> _revealInForm(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(
          of: find.byType(CategoryFormScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<CategoryError?> _errorOf(Future<Object?> Function() op) async {
  try {
    await op();
    return null;
  } on CategoryException catch (e) {
    return e.error;
  }
}

void main() {
  setUpAll(loadTestFonts);

  testWidgets(
    'hierarchy rules: two levels, same kind, no cycles, no duplicates',
    (tester) async {
      await setPhone(tester);
      await _boot(tester);
      final c = _container(tester);
      final ctl = c.read(appControllerProvider.notifier);
      Ledger ledger() => c.read(ledgerProvider);
      final moradia = _cat(ledger(), 'Moradia');
      final salario = _cat(ledger(), 'Salário');

      final aluguel = await _run(
        tester,
        () => ctl.saveCategory(
          name: 'Aluguel',
          kind: 'expense',
          parentId: moradia.id,
        ),
      );
      expect(aluguel.parentId, moradia.id);
      // A subcategory starts with the look of its category.
      expect(aluguel.icon, moradia.icon);
      expect(aluguel.color, moradia.color);
      expect(categoryPath(ledger(), aluguel.id), 'Moradia › Aluguel');
      expect(rootCategoryOf(ledger(), aluguel.id)?.id, moradia.id);

      // A third level is refused.
      expect(
        await tester.runAsync(
          () => _errorOf(
            () => ctl.saveCategory(
              name: 'Caução',
              kind: 'expense',
              parentId: aluguel.id,
            ),
          ),
        ),
        CategoryError.parentIsSubcategory,
      );
      // So is a parent of the other kind.
      expect(
        await tester.runAsync(
          () => _errorOf(
            () => ctl.saveCategory(
              name: 'Bônus',
              kind: 'income',
              parentId: moradia.id,
            ),
          ),
        ),
        CategoryError.parentKindMismatch,
      );
      // A category that has subcategories cannot become one (that would be a cycle or a third level).
      expect(
        await tester.runAsync(
          () => _errorOf(
            () => ctl.saveCategory(
              id: moradia.id,
              name: 'Moradia',
              kind: 'expense',
              parentId: _cat(ledger(), 'Lazer').id,
              setParent: true,
            ),
          ),
        ),
        CategoryError.hasSubcategories,
      );
      // Nor its own parent.
      expect(
        validateCategory(
          ledger(),
          id: salario.id,
          name: 'Salário',
          kind: 'income',
          parentId: salario.id,
        ),
        CategoryError.parentIsSelf,
      );
      // Same name at the same level, ignoring case; the same name under another category is fine.
      expect(
        await tester.runAsync(
          () => _errorOf(
            () => ctl.saveCategory(
              name: 'aluguel',
              kind: 'expense',
              parentId: moradia.id,
            ),
          ),
        ),
        CategoryError.duplicateName,
      );
      expect(
        validateCategory(
          ledger(),
          name: 'Aluguel',
          kind: 'expense',
          parentId: _cat(ledger(), 'Lazer').id,
        ),
        isNull,
      );
      expect(
        validateCategory(ledger(), name: '  ', kind: 'expense'),
        CategoryError.emptyName,
      );

      // Renaming or archiving keeps the parent; setParent with null makes it a main category again.
      await _run(tester, () => ctl.archiveCategory(aluguel.id));
      expect(_cat(ledger(), 'Aluguel').parentId, moradia.id);
      expect(_cat(ledger(), 'Aluguel').archived, isTrue);
      await _run(
        tester,
        () => ctl.saveCategory(
          id: aluguel.id,
          name: 'Aluguel',
          kind: 'expense',
          setParent: true,
          archived: false,
        ),
      );
      expect(_cat(ledger(), 'Aluguel').parentId, isNull);
    },
  );

  testWidgets(
    'deleting a category moves its entries first, also the deleted ones, and never leaves a broken reference',
    (tester) async {
      await setPhone(tester);
      final app = await _boot(tester);
      final c = _container(tester);
      final ctl = c.read(appControllerProvider.notifier);
      Ledger ledger() => c.read(ledgerProvider);
      final today = c.read(todayProvider);
      final account = await _run(
        tester,
        () => ctl.saveAccount(
          name: 'Conta',
          type: 'checking',
          openingBalanceCents: 100000,
          openingDate: today,
        ),
      );
      final moradia = _cat(ledger(), 'Moradia');
      final lazer = _cat(ledger(), 'Lazer');
      final aluguel = await _run(
        tester,
        () => ctl.saveCategory(
          name: 'Aluguel',
          kind: 'expense',
          parentId: moradia.id,
        ),
      );
      Future<Transaction> expense(String d, String? cat) async =>
          (await ctl.saveTransaction(
            TransactionInput(
              kind: TransactionKind.expense,
              amountCents: 1000,
              date: today,
              description: d,
              accountId: account.id,
              categoryId: cat,
            ),
          )).first;
      await _run(tester, () => expense('No pai', moradia.id));
      await _run(tester, () => expense('Na sub', aluguel.id));
      final gone = await _run(tester, () => expense('Apagado', aluguel.id));
      await _run(
        tester,
        () => ctl.deleteTransaction(gone.id, undoLabel: (_) => 'Excluído'),
      );
      await _run(
        tester,
        () => ctl.saveBudget(categoryId: moradia.id, limitCents: 50000),
      );
      expect(categoryUsage(ledger(), moradia.id), (
        transactions: 2,
        budgets: 1,
        subcategories: 1,
      ));

      // The destination cannot be something that is deleted along, nor of another kind.
      expect(
        await tester.runAsync(
          () => _errorOf(
            () => ctl.deleteCategory(moradia.id, moveToId: aluguel.id),
          ),
        ),
        CategoryError.targetInFamily,
      );
      expect(
        await tester.runAsync(
          () => _errorOf(
            () => ctl.deleteCategory(
              moradia.id,
              moveToId: _cat(ledger(), 'Salário').id,
            ),
          ),
        ),
        CategoryError.targetKindMismatch,
      );
      expect(ledger().categories.any((x) => x.id == moradia.id), isTrue);

      final r = await _run(
        tester,
        () => ctl.deleteCategory(moradia.id, moveToId: lazer.id),
      );
      expect(r.moved, 2);
      expect(r.budgets, 1);
      final ids = ledger().categories.map((x) => x.id).toSet();
      expect(ids.contains(moradia.id), isFalse);
      expect(ids.contains(aluguel.id), isFalse);
      expect(
        ledger().transactions.every((t) => t.categoryId == lazer.id),
        isTrue,
      );
      expect(
        ledger().budgets.where((b) => b.categoryId == moradia.id),
        isEmpty,
      );

      // The soft-deleted entry was moved too: restoring it does not bring the old category back.
      final repo = await c.read(ledgerRepositoryProvider.future);
      await _run(tester, () async {
        await repo.restore(EntityTypes.transaction, gone.id);
        await ctl.reload();
      });
      final back = ledger().transactionById(gone.id);
      expect(back, isNotNull);
      expect(back!.categoryId, lazer.id);
      for (final t in ledger().transactions) {
        expect(
          t.categoryId == null || ids.contains(t.categoryId),
          isTrue,
          reason: 'entry ${t.description} points at a missing category',
        );
      }

      // "Leave without a category" clears the reference instead.
      final r2 = await _run(tester, () => ctl.deleteCategory(lazer.id));
      expect(r2.moved, 3);
      expect(ledger().transactions.every((t) => t.categoryId == null), isTrue);
      expect(app.clock, isNotNull);
    },
  );

  testWidgets(
    'side menu → categories: create with icon and color, add a subcategory, edit, archive',
    (tester) async {
      await setPhone(tester);
      await _boot(tester);
      final c = _container(tester);
      Ledger ledger() => c.read(ledgerProvider);

      await openMenu(tester, 'Categorias e subcategorias');
      expect(find.byType(CategoriesScreen), findsOneWidget);
      expect(find.text('Moradia'), findsOneWidget);
      await screenshot(tester, 'categories_light');

      // New category: name, color and an icon found by searching.
      await tester.tap(find.text('Nova categoria'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryFormScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Pets');
      await tester.pumpAndSettle();
      await _revealInForm(tester, find.bySemanticsLabel('Verde'));
      await tester.tap(find.bySemanticsLabel('Verde'));
      await tester.pumpAndSettle();
      final search = find.widgetWithText(
        TextField,
        'Buscar ícone (ex.: mercado, saúde)',
      );
      await _revealInForm(tester, search);
      await tester.enterText(search, 'veterinario');
      await tester.pumpAndSettle();
      // Accents are folded: "veterinario" finds the pet icon, and only it.
      final paw = find.byWidgetPredicate(
        (w) => w is SIcon && w.name == SIconName.paw,
      );
      await _revealInForm(tester, paw);
      expect(paw, findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is SIcon && w.name == SIconName.cart),
        findsNothing,
      );
      await tester.tap(paw);
      await tester.pumpAndSettle();
      await screenshot(tester, 'category_form_light');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesScreen), findsOneWidget);
      final pets = _cat(ledger(), 'Pets');
      expect(pets.icon, 'paw');
      expect(pets.color, '#176B4E');
      expect(pets.parentId, isNull);

      // A subcategory from the "+" of the category.
      final addSub = find.byTooltip('Adicionar subcategoria em Pets');
      await tester.ensureVisible(addSub);
      await tester.pumpAndSettle();
      await tester.tap(addSub);
      await tester.pumpAndSettle();
      expect(find.text('Nova subcategoria'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Ração');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(_cat(ledger(), 'Ração').parentId, pets.id);
      expect(find.text('Ração'), findsOneWidget);

      // Edit: rename the subcategory.
      await tester.tap(find.text('Ração'));
      await tester.pumpAndSettle();
      expect(find.text('Editar subcategoria'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Ração e petiscos');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(_cat(ledger(), 'Ração e petiscos').parentId, pets.id);

      // Archive the category: it moves to "Arquivadas" and leaves the pickers.
      await tester.tap(find.text('Pets'));
      await tester.pumpAndSettle();
      await _revealInForm(tester, find.text('Arquivar'));
      await tester.tap(find.text('Arquivar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arquivar').last);
      await tester.pumpAndSettle();
      expect(_cat(ledger(), 'Pets').archived, isTrue);
      expect(
        rootCategories(ledger(), 'expense').any((x) => x.name == 'Pets'),
        isFalse,
      );
      await tester.scrollUntilVisible(
        find.text('Arquivadas'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Arquivadas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'while filling an entry: create a category and a subcategory, keep what was typed, select the new item',
    (tester) async {
      await setPhone(tester);
      await _boot(tester);
      final c = _container(tester);
      final ctl = c.read(appControllerProvider.notifier);
      Ledger ledger() => c.read(ledgerProvider);
      await _run(
        tester,
        () => ctl.saveAccount(
          name: 'Conta',
          type: 'checking',
          openingBalanceCents: 100000,
          openingDate: c.read(todayProvider),
        ),
      );

      await addEntry(tester);
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), '12345');
      await tester.enterText(
        find.byType(TextField).at(1),
        'Passagem para Recife',
      );
      await tester.pumpAndSettle();

      // Picker: search a name that does not exist and create it from there.
      await tester.ensureVisible(find.text('Escolher categoria'));
      await tester.tap(find.text('Escolher categoria'));
      await tester.pumpAndSettle();
      expect(find.text('Moradia'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar categoria'),
        'Viagens',
      );
      await tester.pumpAndSettle();
      expect(find.text('Moradia'), findsNothing);
      await screenshot(tester, 'category_picker_light');
      await tester.tap(find.text('Criar “Viagens”'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryFormScreen), findsOneWidget);
      // The name typed in the search is already there.
      expect(find.widgetWithText(TextField, 'Viagens'), findsOneWidget);
      await tester.tap(find.text('Salvar').last);
      await tester.pumpAndSettle();

      // Back on the entry: the new category is selected and nothing typed was lost.
      expect(find.byType(CategoryFormScreen), findsNothing);
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      final viagens = _cat(ledger(), 'Viagens');
      expect(viagens.kind, 'expense');
      expect(find.text('Viagens'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Passagem para Recife'),
        findsOneWidget,
      );
      expect(find.textContaining('123,45'), findsOneWidget);

      // Subcategory created from the entry, selected on return.
      await tester.ensureVisible(find.text('Nova subcategoria'));
      await tester.tap(find.text('Nova subcategoria'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryFormScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Passagens');
      await tester.tap(find.text('Salvar').last);
      await tester.pumpAndSettle();
      final passagens = _cat(ledger(), 'Passagens');
      expect(passagens.parentId, viagens.id);
      expect(
        find.widgetWithText(TextField, 'Passagem para Recife'),
        findsOneWidget,
      );
      await screenshot(tester, 'transaction_form_category_light');

      // Changing the main category clears the subcategory that no longer belongs.
      await tester.tap(find.text('Viagens'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lazer'));
      await tester.pumpAndSettle();
      expect(find.text('Passagens'), findsNothing);
      // Choosing a subcategory in the picker selects its main category as well.
      await tester.tap(find.text('Lazer'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar categoria'),
        'passag',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Passagens'));
      await tester.pumpAndSettle();
      expect(find.text('Viagens'), findsOneWidget);

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      final saved = ledger().transactions.single;
      expect(saved.categoryId, passagens.id);
      expect(saved.amountCents, 12345);
      expect(saved.description, 'Passagem para Recife');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'deleting through the form asks where the entries go; archiving keeps them as they are',
    (tester) async {
      await setPhone(tester);
      await _boot(tester);
      final c = _container(tester);
      final ctl = c.read(appControllerProvider.notifier);
      Ledger ledger() => c.read(ledgerProvider);
      final today = c.read(todayProvider);
      final account = await _run(
        tester,
        () => ctl.saveAccount(
          name: 'Conta',
          type: 'checking',
          openingBalanceCents: 100000,
          openingDate: today,
        ),
      );
      final lazer = _cat(ledger(), 'Lazer');
      await _run(
        tester,
        () => ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.expense,
            amountCents: 4000,
            date: today,
            description: 'Cinema',
            accountId: account.id,
            categoryId: lazer.id,
          ),
        ),
      );

      // Archive: the entry keeps its category, the picker no longer offers it.
      await _run(tester, () => ctl.archiveCategory(lazer.id));
      expect(ledger().transactions.single.categoryId, lazer.id);
      expect(
        rootCategories(ledger(), 'expense').any((x) => x.id == lazer.id),
        isFalse,
      );
      await _run(tester, () => ctl.archiveCategory(lazer.id, archived: false));

      await openMenu(tester, 'Categorias e subcategorias');
      await tester.scrollUntilVisible(
        find.text('Lazer'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Lazer'));
      await tester.pumpAndSettle();
      await _revealInForm(tester, find.text('Excluir'));
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      expect(find.text('Excluir “Lazer”?'), findsOneWidget);
      expect(
        find.textContaining('1 lançamento usa esta categoria'),
        findsOneWidget,
      );
      // No destination chosen yet: the button does nothing.
      await tester.tap(find.text('Excluir categoria'));
      await tester.pumpAndSettle();
      expect(ledger().categories.any((x) => x.id == lazer.id), isTrue);
      await screenshot(tester, 'category_delete_light');

      await tester.tap(find.text('Mover para outra categoria'));
      await tester.pumpAndSettle();
      // The category being deleted is not offered as its own destination.
      expect(
        find.descendant(
          of: find.byType(BottomSheet).last,
          matching: find.text('Lazer'),
        ),
        findsNothing,
      );
      await tester.tap(find.text('Educação'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir categoria'));
      await tester.pumpAndSettle();

      expect(ledger().categories.any((x) => x.id == lazer.id), isFalse);
      expect(
        ledger().transactions.single.categoryId,
        _cat(ledger(), 'Educação').id,
      );
      expect(
        find.textContaining('1 lançamento reclassificado'),
        findsOneWidget,
      );
      expect(find.byType(CategoriesScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'totals count each entry once; the list filter of a category brings its subcategories',
    (tester) async {
      await setPhone(tester);
      await _boot(tester);
      final c = _container(tester);
      final ctl = c.read(appControllerProvider.notifier);
      Ledger ledger() => c.read(ledgerProvider);
      final today = c.read(todayProvider);
      final month = today.substring(0, 7);
      final account = await _run(
        tester,
        () => ctl.saveAccount(
          name: 'Conta',
          type: 'checking',
          openingBalanceCents: 500000,
          openingDate: today,
        ),
      );
      final moradia = _cat(ledger(), 'Moradia');
      final aluguel = await _run(
        tester,
        () => ctl.saveCategory(
          name: 'Aluguel',
          kind: 'expense',
          parentId: moradia.id,
        ),
      );
      Future<void> spend(String d, int cents, String cat) => _run(
        tester,
        () => ctl.saveTransaction(
          TransactionInput(
            kind: TransactionKind.expense,
            amountCents: cents,
            date: today,
            description: d,
            accountId: account.id,
            categoryId: cat,
          ),
        ),
      );
      await spend('Aluguel de novembro', 120000, aluguel.id);
      await spend('Conserto da pia', 15000, moradia.id);
      await spend('Mercado', 30000, _cat(ledger(), 'Supermercado').id);

      // Grouped: Moradia = its own entry + the subcategory's. Flat: each one apart. Same grand total.
      final grouped = expensesByCategory(ledger(), month, rollUp: true);
      final flat = expensesByCategory(ledger(), month);
      int sum(List<CategoryTotal> l) => l.fold(0, (a, x) => a + x.cents);
      expect(sum(grouped), 165000);
      expect(sum(flat), 165000);
      expect(
        grouped.firstWhere((x) => x.categoryId == moradia.id).cents,
        135000,
      );
      expect(grouped.any((x) => x.categoryId == aluguel.id), isFalse);
      expect(flat.firstWhere((x) => x.categoryId == moradia.id).cents, 15000);
      expect(flat.firstWhere((x) => x.categoryId == aluguel.id).cents, 120000);

      // A budget for the main category sees the subcategory's spending once.
      await _run(
        tester,
        () => ctl.saveBudget(categoryId: moradia.id, limitCents: 200000),
      );
      final progress = budgetsForMonth(
        ledger(),
        month,
        today,
      ).firstWhere((b) => b.budget.categoryId == moradia.id);
      expect(progress.spentCents, 135000);

      // On the entries tab, filtering by Moradia lists both entries and leaves the groceries out.
      await tester.tap(find.text('Lançamentos'));
      await tester.pumpAndSettle();
      expect(find.text('Mercado'), findsOneWidget);
      await screenshot(tester, 'transactions_light');
      await tester.tap(find.text('Categoria'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Moradia'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Aluguel de novembro'), findsOneWidget);
      expect(find.text('Conserto da pia'), findsOneWidget);
      expect(find.text('Mercado'), findsNothing);
      // The row says where the entry is filed.
      expect(find.textContaining('Moradia › Aluguel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
