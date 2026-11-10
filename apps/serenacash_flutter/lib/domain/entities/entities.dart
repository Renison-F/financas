/// Domain entities. Plain immutable Dart classes with JSON mapping identical to the TypeScript model so
/// backups (`serenacash` v1), fixtures and the future sync payloads are interchangeable byte-for-byte in meaning.
/// (freezed is reserved for feature-level DTOs; domain entities stay dependency-free.)
library;

import 'package:meta/meta.dart';

import '../money/money.dart';

typedef Id = String;

@immutable
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.openingBalanceCents,
    required this.openingDate,
    required this.color,
    required this.archived,
    required this.includeInAvailability,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final Id id;
  final String name;
  final String
  type; // cash | checking | savings | digital_wallet | investment | other
  final String currency;
  final Cents openingBalanceCents;
  final String openingDate;
  final String color;
  final bool archived;
  final bool includeInAvailability;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  bool get isActive => !archived && deletedAt == null;

  factory Account.fromJson(Map<String, dynamic> j) => Account(
    id: j['id'] as String,
    name: j['name'] as String,
    type: j['type'] as String? ?? 'other',
    currency: j['currency'] as String? ?? 'BRL',
    openingBalanceCents: (j['openingBalanceCents'] as num?)?.toInt() ?? 0,
    openingDate: j['openingDate'] as String? ?? '1970-01-01',
    color: j['color'] as String? ?? '#0B5563',
    archived: j['archived'] as bool? ?? false,
    includeInAvailability: j['includeInAvailability'] as bool? ?? true,
    sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
    deletedAt: j['deletedAt'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'currency': currency,
    'openingBalanceCents': openingBalanceCents,
    'openingDate': openingDate,
    'color': color,
    'archived': archived,
    'includeInAvailability': includeInAvailability,
    'sortOrder': sortOrder,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (deletedAt != null) 'deletedAt': deletedAt,
  };
  Account copyWith({
    String? name,
    String? type,
    Cents? openingBalanceCents,
    String? openingDate,
    String? color,
    bool? archived,
    bool? includeInAvailability,
    int? sortOrder,
    String? updatedAt,
    String? deletedAt,
  }) => Account(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency,
    openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
    openingDate: openingDate ?? this.openingDate,
    color: color ?? this.color,
    archived: archived ?? this.archived,
    includeInAvailability: includeInAvailability ?? this.includeInAvailability,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}

@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.kind,
    required this.icon,
    required this.color,
    this.parentId,
    required this.archived,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final Id id;
  final String name;
  final String kind; // income | expense
  final String icon;
  final String color;
  final Id? parentId;
  final bool archived;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['id'] as String,
    name: j['name'] as String,
    kind: j['kind'] as String,
    icon: j['icon'] as String? ?? 'tag',
    color: j['color'] as String? ?? '#4F5E61',
    parentId: j['parentId'] as String?,
    archived: j['archived'] as bool? ?? false,
    sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
    deletedAt: j['deletedAt'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind,
    'icon': icon,
    'color': color,
    if (parentId != null) 'parentId': parentId,
    'archived': archived,
    'sortOrder': sortOrder,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (deletedAt != null) 'deletedAt': deletedAt,
  };
}

@immutable
class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final Id id;
  final String name;
  final String color;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  factory Tag.fromJson(Map<String, dynamic> j) => Tag(
    id: j['id'] as String,
    name: j['name'] as String,
    color: j['color'] as String? ?? '#4F5E61',
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
    deletedAt: j['deletedAt'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (deletedAt != null) 'deletedAt': deletedAt,
  };
}

@immutable
class CreditCard {
  const CreditCard({
    required this.id,
    required this.name,
    this.brand,
    required this.limitCents,
    required this.closingDay,
    required this.dueDay,
    this.defaultPaymentAccountId,
    required this.color,
    required this.archived,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final Id id;
  final String name;
  final String? brand;
  final Cents limitCents;
  final int closingDay;
  final int dueDay;
  final Id? defaultPaymentAccountId;
  final String color;
  final bool archived;
  final String currency;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  bool get isActive => !archived && deletedAt == null;
  factory CreditCard.fromJson(Map<String, dynamic> j) => CreditCard(
    id: j['id'] as String,
    name: j['name'] as String,
    brand: j['brand'] as String?,
    limitCents: (j['limitCents'] as num?)?.toInt() ?? 0,
    closingDay: (j['closingDay'] as num?)?.toInt() ?? 20,
    dueDay: (j['dueDay'] as num?)?.toInt() ?? 10,
    defaultPaymentAccountId: j['defaultPaymentAccountId'] as String?,
    color: j['color'] as String? ?? '#0B5563',
    archived: j['archived'] as bool? ?? false,
    currency: j['currency'] as String? ?? 'BRL',
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
    deletedAt: j['deletedAt'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (brand != null) 'brand': brand,
    'limitCents': limitCents,
    'closingDay': closingDay,
    'dueDay': dueDay,
    if (defaultPaymentAccountId != null)
      'defaultPaymentAccountId': defaultPaymentAccountId,
    'color': color,
    'archived': archived,
    'currency': currency,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (deletedAt != null) 'deletedAt': deletedAt,
  };
}

enum TransactionKind {
  income,
  expense,
  transfer,
  cardPurchase,
  cardPayment,
  goalDeposit,
  goalWithdrawal,
  loanDisbursement,
  loanPayment,
  balanceAdjustment,
  cardRefund,
}

const _kindWire = {
  TransactionKind.income: 'income',
  TransactionKind.expense: 'expense',
  TransactionKind.transfer: 'transfer',
  TransactionKind.cardPurchase: 'card_purchase',
  TransactionKind.cardPayment: 'card_payment',
  TransactionKind.goalDeposit: 'goal_deposit',
  TransactionKind.goalWithdrawal: 'goal_withdrawal',
  TransactionKind.loanDisbursement: 'loan_disbursement',
  TransactionKind.loanPayment: 'loan_payment',
  TransactionKind.balanceAdjustment: 'balance_adjustment',
  TransactionKind.cardRefund: 'card_refund',
};
TransactionKind kindFromWire(String s) => _kindWire.entries
    .firstWhere(
      (e) => e.value == s,
      orElse: () => throw ArgumentError('Tipo de lançamento desconhecido: $s'),
    )
    .key;
String kindToWire(TransactionKind k) => _kindWire[k]!;

enum TransactionStatus { planned, settled, partiallyPaid, cancelled }

const _statusWire = {
  TransactionStatus.planned: 'planned',
  TransactionStatus.settled: 'settled',
  TransactionStatus.partiallyPaid: 'partially_paid',
  TransactionStatus.cancelled: 'cancelled',
};
TransactionStatus statusFromWire(String s) => _statusWire.entries
    .firstWhere(
      (e) => e.value == s,
      orElse: () => throw ArgumentError('Status desconhecido: $s'),
    )
    .key;
String statusToWire(TransactionStatus s) => _statusWire[s]!;

@immutable
class Installment {
  const Installment({
    required this.number,
    required this.of,
    required this.groupId,
  });
  final int number;
  final int of;
  final Id groupId;
  factory Installment.fromJson(Map<String, dynamic> j) => Installment(
    number: (j['number'] as num).toInt(),
    of: (j['of'] as num).toInt(),
    groupId: j['groupId'] as String,
  );
  Map<String, dynamic> toJson() => {
    'number': number,
    'of': of,
    'groupId': groupId,
  };
}

@immutable
class Attachment {
  const Attachment({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
  });
  final Id id;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  factory Attachment.fromJson(Map<String, dynamic> j) => Attachment(
    id: j['id'] as String,
    fileName: j['fileName'] as String,
    mimeType: j['mimeType'] as String,
    sizeBytes: (j['sizeBytes'] as num).toInt(),
    sha256: j['sha256'] as String,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'mimeType': mimeType,
    'sizeBytes': sizeBytes,
    'sha256': sha256,
  };
}

@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.kind,
    required this.amountCents,
    required this.currency,
    required this.date,
    required this.description,
    this.categoryId,
    this.accountId,
    this.toAccountId,
    this.cardId,
    this.goalId,
    this.loanId,
    required this.status,
    this.paidCents,
    this.settledDate,
    this.dueDate,
    this.installment,
    this.seriesId,
    this.transferGroupId,
    this.invoiceMonth,
    this.tags = const [],
    this.notes,
    this.attachments = const [],
    this.merchant,
    this.externalRef,
    this.refundOfId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final Id id;
  final TransactionKind kind;
  final Cents amountCents; // always positive; direction given by kind
  final String currency;
  final String date; // competence date
  final String description;
  final Id? categoryId;
  final Id? accountId;
  final Id? toAccountId;
  final Id? cardId;
  final Id? goalId;
  final Id? loanId;
  final TransactionStatus status;
  final Cents? paidCents;
  final String? settledDate;
  final String? dueDate;
  final Installment? installment;
  final Id? seriesId;
  final Id? transferGroupId;
  final String? invoiceMonth;
  final List<Id> tags;
  final String? notes;
  final List<Attachment> attachments;
  final String? merchant;
  final String? externalRef;

  /// For `cardRefund`: the purchase being (partially) reversed. New in Flutter (pendência do projeto original).
  final Id? refundOfId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  String get effectiveDate => dueDate ?? date;

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
    id: j['id'] as String,
    kind: kindFromWire(j['kind'] as String),
    amountCents: (j['amountCents'] as num).toInt(),
    currency: j['currency'] as String? ?? 'BRL',
    date: j['date'] as String,
    description: j['description'] as String? ?? '',
    categoryId: j['categoryId'] as String?,
    accountId: j['accountId'] as String?,
    toAccountId: j['toAccountId'] as String?,
    cardId: j['cardId'] as String?,
    goalId: j['goalId'] as String?,
    loanId: j['loanId'] as String?,
    status: statusFromWire(j['status'] as String? ?? 'settled'),
    paidCents: (j['paidCents'] as num?)?.toInt(),
    settledDate: j['settledDate'] as String?,
    dueDate: j['dueDate'] as String?,
    installment: j['installment'] == null
        ? null
        : Installment.fromJson(j['installment'] as Map<String, dynamic>),
    seriesId: j['seriesId'] as String?,
    transferGroupId: j['transferGroupId'] as String?,
    invoiceMonth: j['invoiceMonth'] as String?,
    tags: (j['tags'] as List<dynamic>? ?? const []).cast<String>(),
    notes: j['notes'] as String?,
    attachments: (j['attachments'] as List<dynamic>? ?? const [])
        .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
        .toList(),
    merchant: j['merchant'] as String?,
    externalRef: j['externalRef'] as String?,
    refundOfId: j['refundOfId'] as String?,
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
    deletedAt: j['deletedAt'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kindToWire(kind),
    'amountCents': amountCents,
    'currency': currency,
    'date': date,
    'description': description,
    if (categoryId != null) 'categoryId': categoryId,
    if (accountId != null) 'accountId': accountId,
    if (toAccountId != null) 'toAccountId': toAccountId,
    if (cardId != null) 'cardId': cardId,
    if (goalId != null) 'goalId': goalId,
    if (loanId != null) 'loanId': loanId,
    'status': statusToWire(status),
    if (paidCents != null) 'paidCents': paidCents,
    if (settledDate != null) 'settledDate': settledDate,
    if (dueDate != null) 'dueDate': dueDate,
    if (installment != null) 'installment': installment!.toJson(),
    if (seriesId != null) 'seriesId': seriesId,
    if (transferGroupId != null) 'transferGroupId': transferGroupId,
    if (invoiceMonth != null) 'invoiceMonth': invoiceMonth,
    'tags': tags,
    if (notes != null) 'notes': notes,
    'attachments': attachments.map((a) => a.toJson()).toList(),
    if (merchant != null) 'merchant': merchant,
    if (externalRef != null) 'externalRef': externalRef,
    if (refundOfId != null) 'refundOfId': refundOfId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (deletedAt != null) 'deletedAt': deletedAt,
  };
  Transaction copyWith({
    Cents? amountCents,
    String? date,
    String? description,
    Id? categoryId,
    Id? accountId,
    Id? toAccountId,
    Id? cardId,
    TransactionStatus? status,
    Cents? paidCents,
    String? settledDate,
    String? dueDate,
    Installment? installment,
    Id? seriesId,
    String? invoiceMonth,
    List<Id>? tags,
    String? notes,
    List<Attachment>? attachments,
    String? merchant,
    String? externalRef,
    Id? refundOfId,
    String? updatedAt,
    String? deletedAt,
    bool clearPaid = false,
  }) => Transaction(
    id: id,
    kind: kind,
    amountCents: amountCents ?? this.amountCents,
    currency: currency,
    date: date ?? this.date,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    accountId: accountId ?? this.accountId,
    toAccountId: toAccountId ?? this.toAccountId,
    cardId: cardId ?? this.cardId,
    goalId: goalId,
    loanId: loanId,
    status: status ?? this.status,
    paidCents: clearPaid ? null : (paidCents ?? this.paidCents),
    settledDate: clearPaid ? null : (settledDate ?? this.settledDate),
    dueDate: dueDate ?? this.dueDate,
    installment: installment ?? this.installment,
    seriesId: seriesId ?? this.seriesId,
    transferGroupId: transferGroupId,
    invoiceMonth: invoiceMonth ?? this.invoiceMonth,
    tags: tags ?? this.tags,
    notes: notes ?? this.notes,
    attachments: attachments ?? this.attachments,
    merchant: merchant ?? this.merchant,
    externalRef: externalRef ?? this.externalRef,
    refundOfId: refundOfId ?? this.refundOfId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}

@immutable
class Budget {
  const Budget({
    required this.id,
    this.categoryId,
    required this.limitCents,
    this.month,
    required this.rollover,
    this.validFrom,
    this.validUntil,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final Id id;
  final Id? categoryId;
  final Cents limitCents;

  /// Set for a budget of one specific month; null for a recurring one.
  final String? month;
  final bool rollover;

  /// First month (`YYYY-MM`) a recurring budget is in force. A budget never applies to months
  /// before it existed: a limit set this year says nothing about last year.
  final String? validFrom;

  /// First month the recurring budget is no longer in force (it was replaced or ended). The months
  /// before it keep the limit they had.
  final String? validUntil;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  factory Budget.fromJson(Map<String, dynamic> j) => Budget(
    id: j['id'] as String,
    categoryId: j['categoryId'] as String?,
    limitCents: (j['limitCents'] as num).toInt(),
    month: j['month'] as String?,
    rollover: j['rollover'] as bool? ?? false,
    validFrom: j['validFrom'] as String?,
    validUntil: j['validUntil'] as String?,
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
    deletedAt: j['deletedAt'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    if (categoryId != null) 'categoryId': categoryId,
    'limitCents': limitCents,
    if (month != null) 'month': month,
    'rollover': rollover,
    if (validFrom != null) 'validFrom': validFrom,
    if (validUntil != null) 'validUntil': validUntil,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (deletedAt != null) 'deletedAt': deletedAt,
  };
}

@immutable
class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.kind,
    required this.targetCents,
    this.targetDate,
    this.accountId,
    required this.reserved,
    required this.color,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final Id id;
  final String name;
  final String
  kind; // savings | emergency_fund | purchase | debt_payoff | other
  final Cents targetCents;
  final String? targetDate;
  final Id? accountId;
  final bool reserved;
  final String color;
  final bool archived;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  bool get isActive => !archived && deletedAt == null;
  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
    id: j['id'] as String,
    name: j['name'] as String,
    kind: j['kind'] as String? ?? 'savings',
    targetCents: (j['targetCents'] as num).toInt(),
    targetDate: j['targetDate'] as String?,
    accountId: j['accountId'] as String?,
    reserved: j['reserved'] as bool? ?? true,
    color: j['color'] as String? ?? '#0B5563',
    archived: j['archived'] as bool? ?? false,
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
    deletedAt: j['deletedAt'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind,
    'targetCents': targetCents,
    if (targetDate != null) 'targetDate': targetDate,
    if (accountId != null) 'accountId': accountId,
    'reserved': reserved,
    'color': color,
    'archived': archived,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (deletedAt != null) 'deletedAt': deletedAt,
  };
}

@immutable
class Loan {
  const Loan({
    required this.id,
    required this.name,
    this.lender,
    required this.principalCents,
    required this.monthlyRatePercent,
    required this.termMonths,
    required this.system,
    required this.firstDueDate,
    required this.monthlyFeeCents,
    required this.upfrontFeesCents,
    this.accountId,
    required this.archived,
    this.direction = 'borrowed',
    this.interestMode = 'none',
    this.ratePeriod = 'month',
    this.rateKind = 'effective',
    this.rateInputPercent,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final Id id;
  final String name;

  /// The other party: who lent the money, or who it was lent to.
  final String? lender;
  final Cents principalCents;

  /// The effective monthly rate every calculation uses. When the contract states the rate another
  /// way, [rateInputPercent], [ratePeriod] and [rateKind] keep what was typed.
  final double monthlyRatePercent;

  /// Number of installments; 0 for a debt without a schedule (`free`).
  final int termMonths;

  /// `price` | `sac` | `american` (interest each period, principal at the end) | `bullet` (one
  /// payment at the end) | `free` (no schedule: paid when possible).
  final String system;

  /// `borrowed` (the user owes) or `lent` (the user is owed).
  final String direction;

  /// For a `free` debt: `none`, `simple` or `compound` interest at [monthlyRatePercent].
  final String interestMode;

  /// How the rate was stated: per `month` or per `year`; `effective` or `nominal` (a nominal yearly
  /// rate is divided by 12, an effective one is converted by compounding).
  final String ratePeriod;
  final String rateKind;
  final double? rateInputPercent;
  final String firstDueDate;
  final Cents monthlyFeeCents;
  final Cents upfrontFeesCents;
  final Id? accountId;
  final bool archived;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  bool get isActive => !archived && deletedAt == null;
  factory Loan.fromJson(Map<String, dynamic> j) => Loan(
    id: j['id'] as String,
    name: j['name'] as String,
    lender: j['lender'] as String?,
    principalCents: (j['principalCents'] as num).toInt(),
    monthlyRatePercent: (j['monthlyRatePercent'] as num).toDouble(),
    termMonths: (j['termMonths'] as num).toInt(),
    system: j['system'] as String? ?? 'price',
    firstDueDate: j['firstDueDate'] as String,
    monthlyFeeCents: (j['monthlyFeeCents'] as num?)?.toInt() ?? 0,
    upfrontFeesCents: (j['upfrontFeesCents'] as num?)?.toInt() ?? 0,
    accountId: j['accountId'] as String?,
    archived: j['archived'] as bool? ?? false,
    direction: j['direction'] as String? ?? 'borrowed',
    interestMode: j['interestMode'] as String? ?? 'none',
    ratePeriod: j['ratePeriod'] as String? ?? 'month',
    rateKind: j['rateKind'] as String? ?? 'effective',
    rateInputPercent: (j['rateInputPercent'] as num?)?.toDouble(),
    createdAt: j['createdAt'] as String? ?? '',
    updatedAt: j['updatedAt'] as String? ?? '',
    deletedAt: j['deletedAt'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (lender != null) 'lender': lender,
    'principalCents': principalCents,
    'monthlyRatePercent': monthlyRatePercent,
    'termMonths': termMonths,
    'system': system,
    'firstDueDate': firstDueDate,
    'monthlyFeeCents': monthlyFeeCents,
    'upfrontFeesCents': upfrontFeesCents,
    if (accountId != null) 'accountId': accountId,
    'archived': archived,
    if (direction != 'borrowed') 'direction': direction,
    if (interestMode != 'none') 'interestMode': interestMode,
    if (ratePeriod != 'month') 'ratePeriod': ratePeriod,
    if (rateKind != 'effective') 'rateKind': rateKind,
    if (rateInputPercent != null) 'rateInputPercent': rateInputPercent,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (deletedAt != null) 'deletedAt': deletedAt,
  };
}

@immutable
class RecurrenceRule {
  const RecurrenceRule({
    required this.id,
    required this.frequency,
    this.anchorDay,
    required this.startDate,
    this.endDate,
    this.count,
  });
  final Id id;
  final String frequency; // daily | weekly | biweekly | monthly | bimonthly | quarterly | semiannual | yearly
  final int? anchorDay;
  final String startDate;
  final String? endDate;
  final int? count;
  factory RecurrenceRule.fromJson(Map<String, dynamic> j) => RecurrenceRule(
    id: j['id'] as String,
    frequency: j['frequency'] as String,
    anchorDay: (j['anchorDay'] as num?)?.toInt(),
    startDate: j['startDate'] as String,
    endDate: j['endDate'] as String?,
    count: (j['count'] as num?)?.toInt(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'frequency': frequency,
    if (anchorDay != null) 'anchorDay': anchorDay,
    'startDate': startDate,
    if (endDate != null) 'endDate': endDate,
    if (count != null) 'count': count,
  };
}

@immutable
class UserPrefs {
  const UserPrefs({
    this.locale = 'pt-BR',
    this.currency = 'BRL',
    this.theme = 'system',
    this.privacyMode = false,
    this.safetyCushionCents = 0,
    this.includePlannedIncomeInAvailability = false,
    this.availabilityHorizon = 'month_end',
    this.firstDayOfMonth = 1,
    this.hapticsEnabled = true,
    this.biometricLock = false,
    this.lockOnBackground = true,
    this.pinEnabled = false,
    this.displayName = '',
    this.dailyTargets = const [],
    this.palette = 'teal',
    this.density = 'comfortable',
    this.customPrimary,
    this.customAccent,
    this.cardStyle = 'flat',
    this.chartStyle = 'detailed',
    this.motion = 'system',
    this.textSize = 'standard',
    this.productLookup = false,
    this.dailyAlerts = true,
    this.silencedReminders = const [],
  });
  final String locale;
  final String currency;
  final String theme;
  final bool privacyMode;
  final Cents safetyCushionCents;
  final bool includePlannedIncomeInAvailability;
  final String availabilityHorizon; // month_end | days_30 | next_payday
  final int firstDayOfMonth;
  final bool hapticsEnabled;
  final bool biometricLock;
  final bool lockOnBackground;
  final bool pinEnabled;

  /// How the user wants to be greeted; empty when not informed.
  final String displayName;

  /// Daily spending limits and saving targets, each with the period it was in force
  /// (`DailyTarget.toJson`). Kept as plain maps here so the entities do not depend on that module.
  final List<Map<String, dynamic>> dailyTargets;

  /// Colour palette of the interface (`teal`, `blue`, `green`, `terracotta`, `graphite`, `wine`).
  /// It changes the accent of the app, never the meaning of income, expense and warning colours.
  final String palette;

  /// `comfortable` or `compact` spacing of lists and cards.
  final String density;

  /// The two colours of the palette the user made (`palette == 'custom'`), as 0xAARRGGBB. Every
  /// other tone is derived from them, with the contrast checked.
  final int? customPrimary, customAccent;

  /// `flat` (default), `outlined`, `elevated` or `tinted` cards.
  final String cardStyle;

  /// `detailed` (default) or `compact` charts.
  final String chartStyle;

  /// `system` follows the accessibility setting of the device; `reduced` turns transitions off.
  final String motion;

  /// `standard`, `large` or `larger`: multiplies the text size of the device, never replaces it.
  final String textSize;

  /// Consent to look a barcode up in an open product catalogue on the internet. Off by default:
  /// without it nothing about a purchase leaves the device.
  final bool productLookup;

  /// Notices when a daily spending limit is passed or a saving target is still open.
  final bool dailyAlerts;

  /// Kinds of reminder the user turned off (`bill`, `receivable`, `invoice`, `goal`).
  final List<String> silencedReminders;
  factory UserPrefs.fromJson(Map<String, dynamic> j) => UserPrefs(
    locale: j['locale'] as String? ?? 'pt-BR',
    currency: j['currency'] as String? ?? 'BRL',
    theme: j['theme'] as String? ?? 'system',
    privacyMode: j['privacyMode'] as bool? ?? false,
    safetyCushionCents: (j['safetyCushionCents'] as num?)?.toInt() ?? 0,
    includePlannedIncomeInAvailability:
        j['includePlannedIncomeInAvailability'] as bool? ?? false,
    availabilityHorizon: j['availabilityHorizon'] as String? ?? 'month_end',
    firstDayOfMonth: (j['firstDayOfMonth'] as num?)?.toInt() ?? 1,
    hapticsEnabled: j['hapticsEnabled'] as bool? ?? true,
    biometricLock: j['biometricLock'] as bool? ?? false,
    lockOnBackground: j['lockOnBackground'] as bool? ?? true,
    pinEnabled: j['pinEnabled'] as bool? ?? false,
    displayName: j['displayName'] as String? ?? '',
    dailyTargets: [
      for (final t in j['dailyTargets'] as List? ?? const [])
        Map<String, dynamic>.from(t as Map),
    ],
    palette: j['palette'] as String? ?? 'teal',
    density: j['density'] as String? ?? 'comfortable',
    customPrimary: (j['customPrimary'] as num?)?.toInt(),
    customAccent: (j['customAccent'] as num?)?.toInt(),
    cardStyle: j['cardStyle'] as String? ?? 'flat',
    chartStyle: j['chartStyle'] as String? ?? 'detailed',
    motion: j['motion'] as String? ?? 'system',
    textSize: j['textSize'] as String? ?? 'standard',
    productLookup: j['productLookup'] as bool? ?? false,
    dailyAlerts: j['dailyAlerts'] as bool? ?? true,
    silencedReminders: [
      for (final k in j['silencedReminders'] as List? ?? const [])
        if (k is String) k,
    ],
  );
  Map<String, dynamic> toJson() => {
    'locale': locale,
    'currency': currency,
    'theme': theme,
    'privacyMode': privacyMode,
    'safetyCushionCents': safetyCushionCents,
    'includePlannedIncomeInAvailability': includePlannedIncomeInAvailability,
    'availabilityHorizon': availabilityHorizon,
    'firstDayOfMonth': firstDayOfMonth,
    'hapticsEnabled': hapticsEnabled,
    'biometricLock': biometricLock,
    'lockOnBackground': lockOnBackground,
    'pinEnabled': pinEnabled,
    // Written only when set, so documents from before this field stay byte-identical.
    if (displayName.isNotEmpty) 'displayName': displayName,
    if (dailyTargets.isNotEmpty) 'dailyTargets': dailyTargets,
    if (palette != 'teal') 'palette': palette,
    if (density != 'comfortable') 'density': density,
    'customPrimary': ?customPrimary,
    'customAccent': ?customAccent,
    if (cardStyle != 'flat') 'cardStyle': cardStyle,
    if (chartStyle != 'detailed') 'chartStyle': chartStyle,
    if (motion != 'system') 'motion': motion,
    if (textSize != 'standard') 'textSize': textSize,
    if (productLookup) 'productLookup': true,
    if (!dailyAlerts) 'dailyAlerts': false,
    if (silencedReminders.isNotEmpty) 'silencedReminders': silencedReminders,
  };
  UserPrefs copyWith({
    String? locale,
    String? currency,
    String? theme,
    bool? privacyMode,
    Cents? safetyCushionCents,
    bool? includePlannedIncomeInAvailability,
    String? availabilityHorizon,
    int? firstDayOfMonth,
    bool? hapticsEnabled,
    bool? biometricLock,
    bool? lockOnBackground,
    bool? pinEnabled,
    String? displayName,
    List<Map<String, dynamic>>? dailyTargets,
    String? palette,
    String? density,
    int? customPrimary,
    int? customAccent,
    String? cardStyle,
    String? chartStyle,
    String? motion,
    String? textSize,
    bool? productLookup,
    bool? dailyAlerts,
    List<String>? silencedReminders,
  }) => UserPrefs(
    locale: locale ?? this.locale,
    currency: currency ?? this.currency,
    theme: theme ?? this.theme,
    privacyMode: privacyMode ?? this.privacyMode,
    safetyCushionCents: safetyCushionCents ?? this.safetyCushionCents,
    includePlannedIncomeInAvailability:
        includePlannedIncomeInAvailability ??
        this.includePlannedIncomeInAvailability,
    availabilityHorizon: availabilityHorizon ?? this.availabilityHorizon,
    firstDayOfMonth: firstDayOfMonth ?? this.firstDayOfMonth,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    biometricLock: biometricLock ?? this.biometricLock,
    lockOnBackground: lockOnBackground ?? this.lockOnBackground,
    pinEnabled: pinEnabled ?? this.pinEnabled,
    displayName: displayName ?? this.displayName,
    dailyTargets: dailyTargets ?? this.dailyTargets,
    palette: palette ?? this.palette,
    density: density ?? this.density,
    customPrimary: customPrimary ?? this.customPrimary,
    customAccent: customAccent ?? this.customAccent,
    cardStyle: cardStyle ?? this.cardStyle,
    chartStyle: chartStyle ?? this.chartStyle,
    motion: motion ?? this.motion,
    textSize: textSize ?? this.textSize,
    productLookup: productLookup ?? this.productLookup,
    dailyAlerts: dailyAlerts ?? this.dailyAlerts,
    silencedReminders: silencedReminders ?? this.silencedReminders,
  );
}

/// Everything the pure domain functions need, loaded from storage (an in-memory snapshot).
@immutable
class Ledger {
  const Ledger({
    this.accounts = const [],
    this.categories = const [],
    this.tags = const [],
    this.cards = const [],
    this.transactions = const [],
    this.budgets = const [],
    this.goals = const [],
    this.loans = const [],
    this.prefs = const UserPrefs(),
  });
  final List<Account> accounts;
  final List<Category> categories;
  final List<Tag> tags;
  final List<CreditCard> cards;
  final List<Transaction> transactions;
  final List<Budget> budgets;
  final List<Goal> goals;
  final List<Loan> loans;
  final UserPrefs prefs;

  factory Ledger.fromJson(Map<String, dynamic> j) {
    List<T> list<T>(String k, T Function(Map<String, dynamic>) f) =>
        (j[k] as List<dynamic>? ?? const [])
            .map((e) => f(e as Map<String, dynamic>))
            .toList();
    return Ledger(
      accounts: list('accounts', Account.fromJson),
      categories: list('categories', Category.fromJson),
      tags: list('tags', Tag.fromJson),
      cards: list('cards', CreditCard.fromJson),
      transactions: list('transactions', Transaction.fromJson),
      budgets: list('budgets', Budget.fromJson),
      goals: list('goals', Goal.fromJson),
      loans: list('loans', Loan.fromJson),
      prefs: j['prefs'] == null
          ? const UserPrefs()
          : UserPrefs.fromJson(j['prefs'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() => {
    'accounts': accounts.map((a) => a.toJson()).toList(),
    'categories': categories.map((a) => a.toJson()).toList(),
    'tags': tags.map((a) => a.toJson()).toList(),
    'cards': cards.map((a) => a.toJson()).toList(),
    'transactions': transactions.map((a) => a.toJson()).toList(),
    'budgets': budgets.map((a) => a.toJson()).toList(),
    'goals': goals.map((a) => a.toJson()).toList(),
    'loans': loans.map((a) => a.toJson()).toList(),
    'prefs': prefs.toJson(),
  };

  Account? accountById(Id id) => accounts.where((a) => a.id == id).firstOrNull;
  Category? categoryById(Id? id) =>
      id == null ? null : categories.where((c) => c.id == id).firstOrNull;
  CreditCard? cardById(Id? id) =>
      id == null ? null : cards.where((c) => c.id == id).firstOrNull;
  Goal? goalById(Id? id) =>
      id == null ? null : goals.where((g) => g.id == id).firstOrNull;
  Loan? loanById(Id? id) =>
      id == null ? null : loans.where((l) => l.id == id).firstOrNull;
  Transaction? transactionById(Id? id) =>
      id == null ? null : transactions.where((t) => t.id == id).firstOrNull;
  Ledger copyWith({
    List<Account>? accounts,
    List<Category>? categories,
    List<Tag>? tags,
    List<CreditCard>? cards,
    List<Transaction>? transactions,
    List<Budget>? budgets,
    List<Goal>? goals,
    List<Loan>? loans,
    UserPrefs? prefs,
  }) => Ledger(
    accounts: accounts ?? this.accounts,
    categories: categories ?? this.categories,
    tags: tags ?? this.tags,
    cards: cards ?? this.cards,
    transactions: transactions ?? this.transactions,
    budgets: budgets ?? this.budgets,
    goals: goals ?? this.goals,
    loans: loans ?? this.loans,
    prefs: prefs ?? this.prefs,
  );
}
