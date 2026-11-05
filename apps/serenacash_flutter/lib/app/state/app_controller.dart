/// Application controller: loads the snapshot from the repositories and exposes every mutation of the
/// RN `appStore` with the same rules (installments, series, settlement, invoices, undo, erase).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/billing/billing.dart';
import '../../domain/cards/cards.dart';
import '../../domain/categories/categories.dart';
import '../../domain/dashboard/widgets.dart';
import '../../domain/dates/dates.dart' hide Clock;
import '../../domain/entities/entities.dart';
import '../../domain/ledger/ledger.dart';
import '../../domain/loans/loans.dart';
import '../../domain/ports/ports.dart' hide Clock;
import '../../domain/ports/clock.dart' show Clock;
import '../../domain/recurrence/recurrence.dart';
import '../../domain/shopping/shopping.dart' hide defaultCategories;
import '../di.dart';
import 'app_state.dart';
import 'seed.dart';

final appControllerProvider = AsyncNotifierProvider<AppController, AppState>(
  AppController.new,
);

/// Convenience selectors.
final ledgerProvider = Provider<Ledger>(
  (ref) => ref.watch(appControllerProvider).value?.ledger ?? const Ledger(),
);
final prefsProvider = Provider<UserPrefs>(
  (ref) => ref.watch(ledgerProvider).prefs,
);
final privacyHiddenProvider = Provider<bool>(
  (ref) => ref.watch(prefsProvider).privacyMode,
);
final todayProvider = Provider<String>(
  (ref) => ref.watch(appControllerProvider).value?.today ?? todayISO(),
);

class AppController extends AsyncNotifier<AppState> {
  late LedgerRepository _ledger;
  late ShoppingRepository _shopping;
  late PreferencesStore _prefs;
  late IdGenerator _ids;
  late Clock _clock;

  String newId() => _ids.newId();
  String nowISO() => _clock.nowISO();
  String today() => todayISO();

  @override
  Future<AppState> build() async {
    _ledger = await ref.watch(ledgerRepositoryProvider.future);
    _shopping = await ref.watch(shoppingRepositoryProvider.future);
    _prefs = await ref.watch(preferencesStoreProvider.future);
    _ids = ref.watch(idGeneratorProvider);
    _clock = ref.watch(clockProvider);
    final ledger = await _ledger.loadLedger();
    if (ledger.categories.isEmpty) {
      for (final c in defaultCategories(newId, nowISO())) {
        await _ledger.upsertCategory(c);
      }
    }
    final s = await _load();
    final n = await _materializeRecurrences(s);
    return n > 0 ? await _load() : s;
  }

  Future<AppState> _load() async {
    final ledger = await _ledger.loadLedger();
    final layoutRaw = await _prefs.get(PrefKeys.dashboardLayout);
    final onboarded = await _prefs.get(PrefKeys.onboarded) == true;
    final entRaw = await _prefs.get(PrefKeys.entitlementCache);
    final entitlements = entRaw is List
        ? entRaw
              .map((e) => Entitlement.fromJson(e as Map<String, dynamic>))
              .toList()
        : <Entitlement>[];
    final now = DateTime.now();
    return AppState(
      ledger: ledger,
      layout: layoutRaw == null
          ? homeDefaultLayout
          : normalizeLayout(layoutRaw),
      onboarded: onboarded,
      shoppingLists: await _shopping.lists(includeArchived: true),
      sessions: await _shopping.sessions(),
      products: await _shopping.products(),
      observations: await _shopping.observations(),
      entitlements: entitlements,
      access: resolveAccess(entitlements, now),
      undo: state.value?.undo,
      today: todayISO(),
    );
  }

  Future<void> reload() async => state = AsyncData(await _load());

  AppState get _s => state.requireValue;

  Future<T> _mutate<T>(Future<T> Function() op) async {
    final r = await op();
    await reload();
    return r;
  }

  // ---------- prefs / layout / onboarding ----------

  Future<void> setPrefs(UserPrefs Function(UserPrefs) patch) async {
    final next = patch(_s.ledger.prefs);
    await _ledger.savePrefs(next);
    state = AsyncData(_s.copyWith(ledger: _s.ledger.copyWith(prefs: next)));
  }

  Future<void> setLayout(DashboardLayout layout) async {
    await _prefs.set(PrefKeys.dashboardLayout, layout.toJson());
    state = AsyncData(_s.copyWith(layout: layout));
  }

  Future<void> completeOnboarding() async {
    await _prefs.set(PrefKeys.onboarded, true);
    state = AsyncData(_s.copyWith(onboarded: true));
  }

  void setUndo(UndoAction? u) => state = AsyncData(
    u == null ? _s.copyWith(clearUndo: true) : _s.copyWith(undo: u),
  );

  // ---------- accounts, categories, tags, cards, budgets, goals, loans ----------

  Future<Account> saveAccount({
    String? id,
    required String name,
    String? type,
    int? openingBalanceCents,
    String? openingDate,
    String? color,
    bool? archived,
    bool? includeInAvailability,
    int? sortOrder,
  }) => _mutate(() async {
    final now = nowISO();
    final ex = id == null ? null : _s.ledger.accountById(id);
    final a = Account(
      id: ex?.id ?? newId(),
      name: name,
      type: type ?? ex?.type ?? 'checking',
      currency: ex?.currency ?? _s.ledger.prefs.currency,
      openingBalanceCents: openingBalanceCents ?? ex?.openingBalanceCents ?? 0,
      openingDate: openingDate ?? ex?.openingDate ?? today(),
      color: color ?? ex?.color ?? '#0B5563',
      archived: archived ?? ex?.archived ?? false,
      includeInAvailability:
          includeInAvailability ?? ex?.includeInAvailability ?? true,
      sortOrder: sortOrder ?? ex?.sortOrder ?? _s.ledger.accounts.length,
      createdAt: ex?.createdAt ?? now,
      updatedAt: now,
    );
    await _ledger.upsertAccount(a);
    return a;
  });

  Future<void> archiveAccount(String id, {bool archived = true}) async {
    final a = _s.ledger.accountById(id);
    if (a != null) await saveAccount(id: id, name: a.name, archived: archived);
  }

  Future<({bool ok, String? reason})> deleteAccount(
    String id,
    String usedReason,
  ) async {
    final used = _s.ledger.transactions.any(
      (t) => t.accountId == id || t.toAccountId == id,
    );
    if (used) return (ok: false, reason: usedReason);
    await _mutate(() => _ledger.softDelete(EntityTypes.account, id));
    return (ok: true, reason: null);
  }

  Future<void> adjustBalance(
    String accountId,
    int newBalanceCents,
    String date,
    String description,
  ) async {
    final diff = newBalanceCents - accountBalance(_s.ledger, accountId);
    if (diff == 0) return;
    await saveTransaction(
      TransactionInput(
        kind: TransactionKind.balanceAdjustment,
        amountCents: diff.abs(),
        date: date,
        description: description,
        status: TransactionStatus.settled,
        toAccountId: diff > 0 ? accountId : null,
        accountId: diff < 0 ? accountId : null,
      ),
    );
  }

  /// Creates or edits a category. [parentId] is only applied when [setParent] is true (so callers that
  /// just rename or archive do not have to repeat it); passing null with [setParent] makes it a main
  /// category again. Throws [CategoryException] when the change breaks the hierarchy rules.
  Future<Category> saveCategory({
    String? id,
    required String name,
    required String kind,
    String? icon,
    String? color,
    String? parentId,
    bool? setParent,
    bool? archived,
  }) => _mutate(() async {
    final now = nowISO();
    final ex = id == null ? null : _s.ledger.categoryById(id);
    // A new category takes the parent it is given; an edit keeps its own unless told otherwise.
    final parent = (setParent ?? ex == null) ? parentId : ex?.parentId;
    final error = validateCategory(
      _s.ledger,
      id: ex?.id,
      name: name,
      kind: kind,
      parentId: parent,
    );
    if (error != null) throw CategoryException(error);
    final parentCat = _s.ledger.categoryById(parent);
    final c = Category(
      id: ex?.id ?? newId(),
      name: name.trim(),
      kind: kind,
      icon: icon ?? ex?.icon ?? parentCat?.icon ?? 'tag',
      color: color ?? ex?.color ?? parentCat?.color ?? '#4F5E61',
      parentId: parent,
      archived: archived ?? ex?.archived ?? false,
      sortOrder: ex?.sortOrder ?? _s.ledger.categories.length,
      createdAt: ex?.createdAt ?? now,
      updatedAt: now,
    );
    await _ledger.upsertCategory(c);
    return c;
  });

  /// Archiving keeps the category on every entry that already uses it; it only leaves the pickers.
  Future<void> archiveCategory(String id, {bool archived = true}) async {
    final c = _s.ledger.categoryById(id);
    if (c == null) return;
    await saveCategory(id: id, name: c.name, kind: c.kind, archived: archived);
  }

  /// Deletes a category together with its subcategories. Every entry filed under any of them (including
  /// recurrence templates) goes to [moveToId], or stays without a category when it is null, before the
  /// categories are removed, so nothing is left pointing at a deleted category. Budgets of the deleted
  /// categories are removed with them. Throws [CategoryException] for an invalid target.
  Future<({int moved, int budgets})> deleteCategory(
    String id, {
    String? moveToId,
  }) => _mutate(() async {
    final ledger = _s.ledger;
    final error = validateReclassifyTarget(ledger, id, moveToId);
    if (error != null) throw CategoryException(error);
    final family = categoryFamily(ledger, id);
    final now = nowISO();
    final moved = [
      for (final t in ledger.transactions)
        if (family.contains(t.categoryId))
          Transaction.fromJson({
            ...t.toJson()..remove('categoryId'),
            'categoryId': ?moveToId,
            'updatedAt': now,
          }),
    ];
    if (moved.isNotEmpty) await _ledger.upsertTransactions(moved);
    await _ledger.reassignCategoryOnDeleted(family, moveToId);
    final budgets = ledger.budgets
        .where((b) => b.deletedAt == null && family.contains(b.categoryId))
        .toList();
    for (final b in budgets) {
      await _ledger.softDelete(EntityTypes.budget, b.id);
    }
    // Subcategories first, then the category itself.
    for (final cid in family.where((x) => x != id)) {
      await _ledger.softDelete(EntityTypes.category, cid);
    }
    await _ledger.softDelete(EntityTypes.category, id);
    return (moved: moved.length, budgets: budgets.length);
  });

  Future<Tag> saveTag({String? id, required String name, String? color}) =>
      _mutate(() async {
        final now = nowISO();
        final ex = id == null
            ? null
            : _s.ledger.tags.where((t) => t.id == id).firstOrNull;
        final t = Tag(
          id: ex?.id ?? newId(),
          name: name,
          color: color ?? ex?.color ?? '#4F5E61',
          createdAt: ex?.createdAt ?? now,
          updatedAt: now,
        );
        await _ledger.upsertTag(t);
        return t;
      });

  Future<CreditCard> saveCard({
    String? id,
    required String name,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    String? brand,
    String? defaultPaymentAccountId,
    String? color,
    bool? archived,
  }) => _mutate(() async {
    final now = nowISO();
    final ex = id == null ? null : _s.ledger.cardById(id);
    final c = CreditCard(
      id: ex?.id ?? newId(),
      name: name,
      brand: brand ?? ex?.brand,
      limitCents: limitCents,
      closingDay: closingDay,
      dueDay: dueDay,
      defaultPaymentAccountId:
          defaultPaymentAccountId ?? ex?.defaultPaymentAccountId,
      color: color ?? ex?.color ?? '#0B5563',
      archived: archived ?? ex?.archived ?? false,
      currency: ex?.currency ?? _s.ledger.prefs.currency,
      createdAt: ex?.createdAt ?? now,
      updatedAt: now,
    );
    await _ledger.upsertCard(c);
    return c;
  });

  Future<Budget> saveBudget({
    String? id,
    String? categoryId,
    required int limitCents,
    String? month,
    bool? rollover,
  }) => _mutate(() async {
    final now = nowISO();
    final ex = id == null
        ? null
        : _s.ledger.budgets.where((b) => b.id == id).firstOrNull;
    final b = Budget(
      id: ex?.id ?? newId(),
      categoryId: categoryId ?? ex?.categoryId,
      limitCents: limitCents,
      month: month ?? ex?.month,
      rollover: rollover ?? ex?.rollover ?? false,
      createdAt: ex?.createdAt ?? now,
      updatedAt: now,
    );
    await _ledger.upsertBudget(b);
    return b;
  });

  Future<void> deleteBudget(String id) =>
      _mutate(() => _ledger.softDelete(EntityTypes.budget, id));

  Future<Goal> saveGoal({
    String? id,
    required String name,
    required int targetCents,
    String? kind,
    String? targetDate,
    String? accountId,
    bool? reserved,
    String? color,
    bool? archived,
  }) => _mutate(() async {
    final now = nowISO();
    final ex = id == null
        ? null
        : _s.ledger.goals.where((g) => g.id == id).firstOrNull;
    final g = Goal(
      id: ex?.id ?? newId(),
      name: name,
      kind: kind ?? ex?.kind ?? 'savings',
      targetCents: targetCents,
      targetDate: targetDate ?? ex?.targetDate,
      accountId: accountId ?? ex?.accountId,
      reserved: reserved ?? ex?.reserved ?? true,
      color: color ?? ex?.color ?? '#0B5563',
      archived: archived ?? ex?.archived ?? false,
      createdAt: ex?.createdAt ?? now,
      updatedAt: now,
    );
    await _ledger.upsertGoal(g);
    return g;
  });

  Future<Loan> saveLoan({
    String? id,
    required String name,
    required int principalCents,
    required double monthlyRatePercent,
    required int termMonths,
    required String firstDueDate,
    String? lender,
    String? system,
    int? monthlyFeeCents,
    int? upfrontFeesCents,
    String? accountId,
    bool? archived,
    bool registerDisbursement = false,
    bool createInstallments = false,
    required String disbursementLabel,
  }) => _mutate(() async {
    final now = nowISO();
    final ex = id == null
        ? null
        : _s.ledger.loans.where((l) => l.id == id).firstOrNull;
    final loan = Loan(
      id: ex?.id ?? newId(),
      name: name,
      lender: lender ?? ex?.lender,
      principalCents: principalCents,
      monthlyRatePercent: monthlyRatePercent,
      termMonths: termMonths,
      system: system ?? ex?.system ?? 'price',
      firstDueDate: firstDueDate,
      monthlyFeeCents: monthlyFeeCents ?? ex?.monthlyFeeCents ?? 0,
      upfrontFeesCents: upfrontFeesCents ?? ex?.upfrontFeesCents ?? 0,
      accountId: accountId ?? ex?.accountId,
      archived: archived ?? ex?.archived ?? false,
      createdAt: ex?.createdAt ?? now,
      updatedAt: now,
    );
    await _ledger.upsertLoan(loan);
    final txs = <Transaction>[];
    if (registerDisbursement && loan.accountId != null) {
      txs.add(
        Transaction(
          id: newId(),
          kind: TransactionKind.loanDisbursement,
          amountCents: loan.principalCents,
          currency: _s.ledger.prefs.currency,
          date: today(),
          description: '$disbursementLabel: ${loan.name}',
          accountId: loan.accountId,
          loanId: loan.id,
          status: TransactionStatus.settled,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    if (createInstallments) {
      final groupId = newId();
      for (final row in buildSchedule(loan)) {
        txs.add(
          Transaction(
            id: newId(),
            kind: TransactionKind.loanPayment,
            amountCents: row.installmentCents,
            currency: _s.ledger.prefs.currency,
            date: row.dueDate,
            dueDate: row.dueDate,
            description: '${loan.name} ${row.number}/${loan.termMonths}',
            accountId: loan.accountId,
            loanId: loan.id,
            status: TransactionStatus.planned,
            installment: Installment(
              number: row.number,
              of: loan.termMonths,
              groupId: groupId,
            ),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
    if (txs.isNotEmpty) await _ledger.upsertTransactions(txs);
    return loan;
  });

  // ---------- transactions ----------

  Future<List<Transaction>> saveTransaction(
    TransactionInput input, {
    String? errAmount,
    String? errTransfer,
    String? errCard,
    String? errAccount,
  }) => _mutate(() async {
    final now = nowISO();
    final ex = input.id == null ? null : _s.ledger.transactionById(input.id!);
    final ledger = _s.ledger;
    var base = Transaction(
      id: ex?.id ?? newId(),
      kind: input.kind,
      amountCents: input.amountCents,
      currency: ex?.currency ?? ledger.prefs.currency,
      date: input.date,
      description: input.description,
      categoryId: input.categoryId,
      accountId: input.accountId,
      toAccountId: input.toAccountId,
      cardId: input.cardId,
      goalId: input.goalId ?? ex?.goalId,
      loanId: input.loanId ?? ex?.loanId,
      status: input.status ?? ex?.status ?? TransactionStatus.settled,
      paidCents: ex?.paidCents,
      settledDate: ex?.settledDate,
      dueDate: input.dueDate,
      installment: ex?.installment,
      seriesId: ex?.seriesId,
      transferGroupId: ex?.transferGroupId,
      invoiceMonth: input.invoiceMonth ?? ex?.invoiceMonth,
      tags: input.tags,
      notes: input.notes,
      attachments: ex?.attachments ?? const [],
      merchant: input.merchant,
      externalRef: input.externalRef ?? ex?.externalRef,
      refundOfId: input.refundOfId ?? ex?.refundOfId,
      createdAt: ex?.createdAt ?? now,
      updatedAt: now,
    );
    if (base.amountCents <= 0) {
      throw AppError(errAmount ?? 'Informe um valor maior que zero.');
    }
    if (base.kind == TransactionKind.transfer &&
        (base.accountId == null ||
            base.toAccountId == null ||
            base.accountId == base.toAccountId)) {
      throw AppError(errTransfer ?? 'Escolha duas contas diferentes.');
    }
    if ((base.kind == TransactionKind.cardPurchase ||
            base.kind == TransactionKind.cardRefund) &&
        base.cardId == null) {
      throw AppError(errCard ?? 'Escolha o cartão.');
    }
    if (const {
          TransactionKind.income,
          TransactionKind.expense,
          TransactionKind.goalDeposit,
          TransactionKind.loanPayment,
        }.contains(base.kind) &&
        base.accountId == null) {
      throw AppError(errAccount ?? 'Escolha a conta.');
    }
    if (base.kind == TransactionKind.cardRefund) {
      final purchase = base.refundOfId == null
          ? null
          : ledger.transactionById(base.refundOfId);
      if (purchase == null) {
        throw AppError(errCard ?? 'Escolha a compra estornada.');
      }
      final v = validateCardRefund(ledger, purchase, base.amountCents);
      if (!v.ok) throw AppError(v.reason ?? 'Estorno inválido.');
      base = base.copyWith(
        cardId: purchase.cardId,
        invoiceMonth:
            base.invoiceMonth ??
            invoiceMonthFor(
              ledger.cardById(purchase.cardId)!.closingDay,
              base.date,
            ),
      );
    }
    final created = <Transaction>[];
    if (base.kind == TransactionKind.cardPurchase &&
        (input.installments ?? 1) > 1 &&
        ex == null) {
      final card = ledger.cardById(base.cardId!)!;
      final groupId = newId();
      for (final p in planInstallments(
        totalCents: base.amountCents,
        count: input.installments!,
        purchaseDate: base.date,
        closingDay: card.closingDay,
      )) {
        created.add(
          base
              .copyWith(
                amountCents: p.amountCents,
                date: p.date,
                invoiceMonth: p.invoiceMonth,
                installment: Installment(
                  number: p.number,
                  of: p.of,
                  groupId: groupId,
                ),
                description: '${base.description} (${p.number}/${p.of})',
              )
              .withId(newId()),
        );
      }
      await _ledger.upsertTransactions(created);
    } else if (input.recurrenceFrequency != null && ex == null) {
      final seriesId = newId();
      final rule = RecurrenceRule(
        id: seriesId,
        frequency: input.recurrenceFrequency!,
        startDate: base.date,
      );
      final until = addMonthsClamped(today(), 3);
      final dates = occurrencesBetween(rule, base.date, until);
      for (var i = 0; i < dates.length; i++) {
        var t = base.copyWith(
          date: dates[i],
          dueDate: base.dueDate != null ? dates[i] : null,
          seriesId: seriesId,
          status: i == 0 ? base.status : TransactionStatus.planned,
        );
        if (i > 0) t = t.withId(newId());
        if (t.kind == TransactionKind.cardPurchase && t.cardId != null) {
          t = t.copyWith(
            invoiceMonth: invoiceMonthFor(
              ledger.cardById(t.cardId!)!.closingDay,
              dates[i],
            ),
          );
        }
        created.add(t);
      }
      await _ledger.upsertTransactions(created);
      await _ledger.upsertRecurrenceRule(
        StoredRecurrence(
          rule: rule,
          templateTransactionId: base.id,
          lastGenerated: dates.isEmpty ? null : dates.last,
        ),
      );
    } else {
      if ((base.kind == TransactionKind.cardPurchase ||
              base.kind == TransactionKind.cardRefund) &&
          base.cardId != null &&
          base.invoiceMonth == null) {
        base = base.copyWith(
          invoiceMonth: invoiceMonthFor(
            ledger.cardById(base.cardId!)!.closingDay,
            base.date,
          ),
        );
      }
      await _ledger.upsertTransaction(base);
      created.add(base);
    }
    return created;
  });

  Future<void> settleTransaction(
    String id, {
    int? paidCents,
    String? date,
  }) async {
    final t = _s.ledger.transactionById(id);
    if (t == null) return;
    final paid = paidCents ?? t.amountCents;
    final total =
        (t.status == TransactionStatus.partiallyPaid ? (t.paidCents ?? 0) : 0) +
        paid;
    final next = total >= t.amountCents
        ? t.copyWith(
            status: TransactionStatus.settled,
            paidCents: t.amountCents,
            settledDate: date ?? today(),
            updatedAt: nowISO(),
          )
        : t.copyWith(
            status: TransactionStatus.partiallyPaid,
            paidCents: total,
            updatedAt: nowISO(),
          );
    await _mutate(() => _ledger.upsertTransaction(next));
  }

  Future<void> deleteTransaction(
    String id, {
    bool series = false,
    required String Function(int count) undoLabel,
  }) async {
    final t = _s.ledger.transactionById(id);
    if (t == null) return;
    final all = _s.ledger.transactions;
    final targets = series && t.seriesId != null
        ? all
              .where(
                (x) =>
                    x.seriesId == t.seriesId && compareISO(x.date, t.date) >= 0,
              )
              .toList()
        : t.installment != null
        ? all
              .where((x) => x.installment?.groupId == t.installment!.groupId)
              .toList()
        : [t];
    await _mutate(() async {
      for (final x in targets) {
        await _ledger.softDelete(EntityTypes.transaction, x.id);
      }
    });
    setUndo(
      UndoAction(
        label: undoLabel(targets.length),
        run: () async {
          for (final x in targets) {
            await _ledger.restore(EntityTypes.transaction, x.id);
          }
          await reload();
          setUndo(null);
        },
      ),
    );
  }

  Future<void> payInvoice({
    required String cardId,
    required String invoiceMonth,
    required int amountCents,
    required String accountId,
    required String date,
    required String description,
  }) => saveTransaction(
    TransactionInput(
      kind: TransactionKind.cardPayment,
      amountCents: amountCents,
      date: date,
      accountId: accountId,
      cardId: cardId,
      invoiceMonth: invoiceMonth,
      description: description,
      status: TransactionStatus.settled,
    ),
  );

  Future<int> importTransactions(List<Transaction> list) async {
    final out = await _mutate(() => _ledger.upsertTransactions(list));
    return out.where((o) => o != WriteOutcome.alreadyApplied).length;
  }

  Future<int> _materializeRecurrences(AppState s, [String? until]) async {
    final horizon = until ?? addMonthsClamped(today(), 3);
    final rules = await _ledger.recurrenceRules();
    var n = 0;
    final txs = s.ledger.transactions;
    for (final r in rules) {
      final template =
          s.ledger.transactionById(r.templateTransactionId) ??
          txs.where((t) => t.seriesId == r.rule.id).firstOrNull;
      if (template == null) continue;
      final from = r.lastGenerated ?? r.rule.startDate;
      final dates = occurrencesBetween(r.rule, from, horizon)
          .where(
            (d) =>
                r.lastGenerated == null || compareISO(d, r.lastGenerated!) > 0,
          )
          .toList();
      if (dates.isEmpty) continue;
      final now = nowISO();
      final created = <Transaction>[];
      for (final d in dates) {
        if (txs.any((t) => t.seriesId == r.rule.id && t.date == d)) continue;
        var t = Transaction(
          id: newId(),
          kind: template.kind,
          amountCents: template.amountCents,
          currency: template.currency,
          date: d,
          description: template.description,
          categoryId: template.categoryId,
          accountId: template.accountId,
          toAccountId: template.toAccountId,
          cardId: template.cardId,
          goalId: template.goalId,
          loanId: template.loanId,
          status: TransactionStatus.planned,
          dueDate: d,
          seriesId: r.rule.id,
          tags: template.tags,
          notes: template.notes,
          merchant: template.merchant,
          createdAt: now,
          updatedAt: now,
        );
        if (t.kind == TransactionKind.cardPurchase && t.cardId != null) {
          final card = s.ledger.cardById(t.cardId!);
          if (card != null) {
            t = t.copyWith(invoiceMonth: invoiceMonthFor(card.closingDay, d));
          }
        }
        created.add(t);
        n++;
      }
      if (created.isNotEmpty) await _ledger.upsertTransactions(created);
      await _ledger.upsertRecurrenceRule(
        StoredRecurrence(
          rule: r.rule,
          templateTransactionId: r.templateTransactionId,
          lastGenerated: dates.last,
        ),
      );
    }
    return n;
  }

  Future<int> materializeRecurrences() async {
    final n = await _materializeRecurrences(_s);
    if (n > 0) await reload();
    return n;
  }

  // ---------- attachments ----------

  Future<void> addAttachment(
    String transactionId,
    Attachment meta,
    List<int> bytes,
  ) => _mutate(() => _ledger.putAttachment(transactionId, meta, bytes));
  Future<List<int>?> attachmentBytes(String id) => _ledger.attachmentBytes(id);
  Future<void> removeAttachment(String id) =>
      _mutate(() => _ledger.removeAttachment(id));

  // ---------- shopping ----------

  Future<void> saveShoppingList(ShoppingList l) =>
      _mutate(() => _shopping.upsertList(l));
  Future<void> deleteShoppingList(String id) =>
      _mutate(() => _shopping.deleteList(id));
  Future<void> saveSession(ShoppingSession s) =>
      _mutate(() => _shopping.upsertSession(s));
  Future<void> saveProduct(Product p) =>
      _mutate(() => _shopping.upsertProduct(p));
  Future<void> addPriceObservations(List<PriceObservation> obs) async {
    if (obs.isNotEmpty) await _mutate(() => _shopping.addObservations(obs));
  }

  // ---------- billing / data ----------

  Future<void> setEntitlements(List<Entitlement> e) async {
    await _prefs.set(
      PrefKeys.entitlementCache,
      e.map((x) => x.toJson()).toList(),
    );
    state = AsyncData(
      _s.copyWith(entitlements: e, access: resolveAccess(e, DateTime.now())),
    );
  }

  Future<void> eraseEverything() async {
    await _ledger.purgeAll();
    await _shopping.purgeAll();
    ref.invalidateSelf();
    await future;
  }
}

extension on Transaction {
  Transaction withId(String id) => Transaction(
    id: id,
    kind: kind,
    amountCents: amountCents,
    currency: currency,
    date: date,
    description: description,
    categoryId: categoryId,
    accountId: accountId,
    toAccountId: toAccountId,
    cardId: cardId,
    goalId: goalId,
    loanId: loanId,
    status: status,
    paidCents: paidCents,
    settledDate: settledDate,
    dueDate: dueDate,
    installment: installment,
    seriesId: seriesId,
    transferGroupId: transferGroupId,
    invoiceMonth: invoiceMonth,
    tags: tags,
    notes: notes,
    attachments: attachments,
    merchant: merchant,
    externalRef: externalRef,
    refundOfId: refundOfId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

/// Home screen of someone who never customized it, in the order of the reference design: the latest
/// entries come right after the cards. The domain's own default keeps the order of the original core
/// (it is what a saved layout without an order falls back to).
final homeDefaultLayout = defaultLayout.copyWith(
  order: [
    for (final id in defaultLayout.order)
      if (id != 'recent_transactions') ...[
        id,
        if (id == 'cards_invoices') 'recent_transactions',
      ],
  ],
);
