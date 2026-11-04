import '../../domain/billing/billing.dart';
import '../../domain/dashboard/widgets.dart';
import '../../domain/entities/entities.dart';
import '../../domain/shopping/shopping.dart';

class UndoAction {
  const UndoAction({required this.label, required this.run});
  final String label;
  final Future<void> Function() run;
}

/// Immutable snapshot the UI renders. Derived values (dashboard data) are computed from it.
class AppState {
  const AppState({
    required this.ledger,
    required this.layout,
    required this.onboarded,
    required this.shoppingLists,
    required this.sessions,
    required this.products,
    required this.observations,
    required this.entitlements,
    required this.access,
    this.undo,
    required this.today,
  });
  final Ledger ledger;
  final DashboardLayout layout;
  final bool onboarded;
  final List<ShoppingList> shoppingLists;
  final List<ShoppingSession> sessions;
  final List<Product> products;
  final List<PriceObservation> observations;
  final List<Entitlement> entitlements;
  final Access access;
  final UndoAction? undo;
  final String today;

  AppState copyWith({
    Ledger? ledger,
    DashboardLayout? layout,
    bool? onboarded,
    List<ShoppingList>? shoppingLists,
    List<ShoppingSession>? sessions,
    List<Product>? products,
    List<PriceObservation>? observations,
    List<Entitlement>? entitlements,
    Access? access,
    UndoAction? undo,
    bool clearUndo = false,
    String? today,
  }) => AppState(
    ledger: ledger ?? this.ledger,
    layout: layout ?? this.layout,
    onboarded: onboarded ?? this.onboarded,
    shoppingLists: shoppingLists ?? this.shoppingLists,
    sessions: sessions ?? this.sessions,
    products: products ?? this.products,
    observations: observations ?? this.observations,
    entitlements: entitlements ?? this.entitlements,
    access: access ?? this.access,
    undo: clearUndo ? null : (undo ?? this.undo),
    today: today ?? this.today,
  );
}

/// Input of the transaction form (mirrors the RN `TransactionInput`).
class TransactionInput {
  const TransactionInput({
    this.id,
    required this.kind,
    required this.amountCents,
    required this.date,
    this.description = '',
    this.categoryId,
    this.accountId,
    this.toAccountId,
    this.cardId,
    this.goalId,
    this.loanId,
    this.status,
    this.dueDate,
    this.tags = const [],
    this.notes,
    this.merchant,
    this.invoiceMonth,
    this.installments,
    this.recurrenceFrequency,
    this.refundOfId,
    this.externalRef,
  });
  final String? id;
  final TransactionKind kind;
  final int amountCents;
  final String date;
  final String description;
  final String? categoryId, accountId, toAccountId, cardId, goalId, loanId;
  final TransactionStatus? status;
  final String? dueDate;
  final List<String> tags;
  final String? notes, merchant, invoiceMonth;

  /// split into N card installments (card_purchase only)
  final int? installments;

  /// create a recurring series
  final String? recurrenceFrequency;
  final String? refundOfId;
  final String? externalRef;
}

class AppError implements Exception {
  AppError(this.message);
  final String message;
  @override
  String toString() => message;
}
