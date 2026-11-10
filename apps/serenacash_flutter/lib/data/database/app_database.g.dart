// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn([
      'cash',
      'checking',
      'savings',
      'digital_wallet',
      'investment',
      'other',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceCentsMeta =
      const VerificationMeta('openingBalanceCents');
  @override
  late final GeneratedColumn<int> openingBalanceCents = GeneratedColumn<int>(
    'opening_balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingDateMeta = const VerificationMeta(
    'openingDate',
  );
  @override
  late final GeneratedColumn<String> openingDate = GeneratedColumn<String>(
    'opening_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _includeInAvailabilityMeta =
      const VerificationMeta('includeInAvailability');
  @override
  late final GeneratedColumn<bool> includeInAvailability =
      GeneratedColumn<bool>(
        'include_in_availability',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("include_in_availability" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    type,
    currency,
    openingBalanceCents,
    openingDate,
    color,
    archived,
    includeInAvailability,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('opening_balance_cents')) {
      context.handle(
        _openingBalanceCentsMeta,
        openingBalanceCents.isAcceptableOrUnknown(
          data['opening_balance_cents']!,
          _openingBalanceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceCentsMeta);
    }
    if (data.containsKey('opening_date')) {
      context.handle(
        _openingDateMeta,
        openingDate.isAcceptableOrUnknown(
          data['opening_date']!,
          _openingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingDateMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('include_in_availability')) {
      context.handle(
        _includeInAvailabilityMeta,
        includeInAvailability.isAcceptableOrUnknown(
          data['include_in_availability']!,
          _includeInAvailabilityMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      openingBalanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_cents'],
      )!,
      openingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_date'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      includeInAvailability: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_in_availability'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String name;
  final String type;
  final String currency;
  final int openingBalanceCents;
  final String openingDate;
  final String color;
  final bool archived;
  final bool includeInAvailability;
  final int sortOrder;
  const AccountRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
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
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['currency'] = Variable<String>(currency);
    map['opening_balance_cents'] = Variable<int>(openingBalanceCents);
    map['opening_date'] = Variable<String>(openingDate);
    map['color'] = Variable<String>(color);
    map['archived'] = Variable<bool>(archived);
    map['include_in_availability'] = Variable<bool>(includeInAvailability);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      openingBalanceCents: Value(openingBalanceCents),
      openingDate: Value(openingDate),
      color: Value(color),
      archived: Value(archived),
      includeInAvailability: Value(includeInAvailability),
      sortOrder: Value(sortOrder),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      openingBalanceCents: serializer.fromJson<int>(
        json['openingBalanceCents'],
      ),
      openingDate: serializer.fromJson<String>(json['openingDate']),
      color: serializer.fromJson<String>(json['color']),
      archived: serializer.fromJson<bool>(json['archived']),
      includeInAvailability: serializer.fromJson<bool>(
        json['includeInAvailability'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'currency': serializer.toJson<String>(currency),
      'openingBalanceCents': serializer.toJson<int>(openingBalanceCents),
      'openingDate': serializer.toJson<String>(openingDate),
      'color': serializer.toJson<String>(color),
      'archived': serializer.toJson<bool>(archived),
      'includeInAvailability': serializer.toJson<bool>(includeInAvailability),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  AccountRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? name,
    String? type,
    String? currency,
    int? openingBalanceCents,
    String? openingDate,
    String? color,
    bool? archived,
    bool? includeInAvailability,
    int? sortOrder,
  }) => AccountRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
    openingDate: openingDate ?? this.openingDate,
    color: color ?? this.color,
    archived: archived ?? this.archived,
    includeInAvailability: includeInAvailability ?? this.includeInAvailability,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      openingBalanceCents: data.openingBalanceCents.present
          ? data.openingBalanceCents.value
          : this.openingBalanceCents,
      openingDate: data.openingDate.present
          ? data.openingDate.value
          : this.openingDate,
      color: data.color.present ? data.color.value : this.color,
      archived: data.archived.present ? data.archived.value : this.archived,
      includeInAvailability: data.includeInAvailability.present
          ? data.includeInAvailability.value
          : this.includeInAvailability,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('openingDate: $openingDate, ')
          ..write('color: $color, ')
          ..write('archived: $archived, ')
          ..write('includeInAvailability: $includeInAvailability, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    type,
    currency,
    openingBalanceCents,
    openingDate,
    color,
    archived,
    includeInAvailability,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.openingBalanceCents == this.openingBalanceCents &&
          other.openingDate == this.openingDate &&
          other.color == this.color &&
          other.archived == this.archived &&
          other.includeInAvailability == this.includeInAvailability &&
          other.sortOrder == this.sortOrder);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> currency;
  final Value<int> openingBalanceCents;
  final Value<String> openingDate;
  final Value<String> color;
  final Value<bool> archived;
  final Value<bool> includeInAvailability;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const AccountsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.openingDate = const Value.absent(),
    this.color = const Value.absent(),
    this.archived = const Value.absent(),
    this.includeInAvailability = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String name,
    required String type,
    required String currency,
    required int openingBalanceCents,
    required String openingDate,
    required String color,
    this.archived = const Value.absent(),
    this.includeInAvailability = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       type = Value(type),
       currency = Value(currency),
       openingBalanceCents = Value(openingBalanceCents),
       openingDate = Value(openingDate),
       color = Value(color);
  static Insertable<AccountRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<int>? openingBalanceCents,
    Expression<String>? openingDate,
    Expression<String>? color,
    Expression<bool>? archived,
    Expression<bool>? includeInAvailability,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (openingBalanceCents != null)
        'opening_balance_cents': openingBalanceCents,
      if (openingDate != null) 'opening_date': openingDate,
      if (color != null) 'color': color,
      if (archived != null) 'archived': archived,
      if (includeInAvailability != null)
        'include_in_availability': includeInAvailability,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? currency,
    Value<int>? openingBalanceCents,
    Value<String>? openingDate,
    Value<String>? color,
    Value<bool>? archived,
    Value<bool>? includeInAvailability,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
      openingDate: openingDate ?? this.openingDate,
      color: color ?? this.color,
      archived: archived ?? this.archived,
      includeInAvailability:
          includeInAvailability ?? this.includeInAvailability,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (openingBalanceCents.present) {
      map['opening_balance_cents'] = Variable<int>(openingBalanceCents.value);
    }
    if (openingDate.present) {
      map['opening_date'] = Variable<String>(openingDate.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (includeInAvailability.present) {
      map['include_in_availability'] = Variable<bool>(
        includeInAvailability.value,
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('openingDate: $openingDate, ')
          ..write('color: $color, ')
          ..write('archived: $archived, ')
          ..write('includeInAvailability: $includeInAvailability, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    check: () => kind.isIn(['income', 'expense']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    kind,
    icon,
    color,
    parentId,
    archived,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String name;
  final String kind;
  final String icon;
  final String color;
  final String? parentId;
  final bool archived;
  final int sortOrder;
  const CategoryRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    required this.name,
    required this.kind,
    required this.icon,
    required this.color,
    this.parentId,
    required this.archived,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      icon: Value(icon),
      color: Value(color),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'parentId': serializer.toJson<String?>(parentId),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? name,
    String? kind,
    String? icon,
    String? color,
    Value<String?> parentId = const Value.absent(),
    bool? archived,
    int? sortOrder,
  }) => CategoryRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    parentId: parentId.present ? parentId.value : this.parentId,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    kind,
    icon,
    color,
    parentId,
    archived,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.parentId == this.parentId &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> icon;
  final Value<String> color;
  final Value<String?> parentId;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String name,
    required String kind,
    required String icon,
    required String color,
    this.parentId = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       kind = Value(kind),
       icon = Value(icon),
       color = Value(color);
  static Insertable<CategoryRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? parentId,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (parentId != null) 'parent_id': parentId,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? icon,
    Value<String>? color,
    Value<String?>? parentId,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String name;
  final String color;
  const TagRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    required this.name,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      color: Value(color),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
    };
  }

  TagRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? name,
    String? color,
  }) => TagRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<int> rowid;
  const TagsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String name,
    required String color,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       color = Value(color);
  static Insertable<TagRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? name,
    Value<String>? color,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditCardsTable extends CreditCards
    with TableInfo<$CreditCardsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _limitCentsMeta = const VerificationMeta(
    'limitCents',
  );
  @override
  late final GeneratedColumn<int> limitCents = GeneratedColumn<int>(
    'limit_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(limitCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closingDayMeta = const VerificationMeta(
    'closingDay',
  );
  @override
  late final GeneratedColumn<int> closingDay = GeneratedColumn<int>(
    'closing_day',
    aliasedName,
    false,
    check: () => ComparableExpr(closingDay).isBetweenValues(1, 31),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    false,
    check: () => ComparableExpr(dueDay).isBetweenValues(1, 31),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultPaymentAccountIdMeta =
      const VerificationMeta('defaultPaymentAccountId');
  @override
  late final GeneratedColumn<String> defaultPaymentAccountId =
      GeneratedColumn<String>(
        'default_payment_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES accounts (id)',
        ),
      );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    brand,
    limitCents,
    closingDay,
    dueDay,
    defaultPaymentAccountId,
    color,
    archived,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('limit_cents')) {
      context.handle(
        _limitCentsMeta,
        limitCents.isAcceptableOrUnknown(data['limit_cents']!, _limitCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_limitCentsMeta);
    }
    if (data.containsKey('closing_day')) {
      context.handle(
        _closingDayMeta,
        closingDay.isAcceptableOrUnknown(data['closing_day']!, _closingDayMeta),
      );
    } else if (isInserting) {
      context.missing(_closingDayMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDayMeta);
    }
    if (data.containsKey('default_payment_account_id')) {
      context.handle(
        _defaultPaymentAccountIdMeta,
        defaultPaymentAccountId.isAcceptableOrUnknown(
          data['default_payment_account_id']!,
          _defaultPaymentAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      limitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_cents'],
      )!,
      closingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_day'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      )!,
      defaultPaymentAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_payment_account_id'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $CreditCardsTable createAlias(String alias) {
    return $CreditCardsTable(attachedDatabase, alias);
  }
}

class CardRow extends DataClass implements Insertable<CardRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String name;
  final String? brand;
  final int limitCents;
  final int closingDay;
  final int dueDay;
  final String? defaultPaymentAccountId;
  final String color;
  final bool archived;
  final String currency;
  const CardRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
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
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['limit_cents'] = Variable<int>(limitCents);
    map['closing_day'] = Variable<int>(closingDay);
    map['due_day'] = Variable<int>(dueDay);
    if (!nullToAbsent || defaultPaymentAccountId != null) {
      map['default_payment_account_id'] = Variable<String>(
        defaultPaymentAccountId,
      );
    }
    map['color'] = Variable<String>(color);
    map['archived'] = Variable<bool>(archived);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  CreditCardsCompanion toCompanion(bool nullToAbsent) {
    return CreditCardsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      limitCents: Value(limitCents),
      closingDay: Value(closingDay),
      dueDay: Value(dueDay),
      defaultPaymentAccountId: defaultPaymentAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultPaymentAccountId),
      color: Value(color),
      archived: Value(archived),
      currency: Value(currency),
    );
  }

  factory CardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      limitCents: serializer.fromJson<int>(json['limitCents']),
      closingDay: serializer.fromJson<int>(json['closingDay']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      defaultPaymentAccountId: serializer.fromJson<String?>(
        json['defaultPaymentAccountId'],
      ),
      color: serializer.fromJson<String>(json['color']),
      archived: serializer.fromJson<bool>(json['archived']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'limitCents': serializer.toJson<int>(limitCents),
      'closingDay': serializer.toJson<int>(closingDay),
      'dueDay': serializer.toJson<int>(dueDay),
      'defaultPaymentAccountId': serializer.toJson<String?>(
        defaultPaymentAccountId,
      ),
      'color': serializer.toJson<String>(color),
      'archived': serializer.toJson<bool>(archived),
      'currency': serializer.toJson<String>(currency),
    };
  }

  CardRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    int? limitCents,
    int? closingDay,
    int? dueDay,
    Value<String?> defaultPaymentAccountId = const Value.absent(),
    String? color,
    bool? archived,
    String? currency,
  }) => CardRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    limitCents: limitCents ?? this.limitCents,
    closingDay: closingDay ?? this.closingDay,
    dueDay: dueDay ?? this.dueDay,
    defaultPaymentAccountId: defaultPaymentAccountId.present
        ? defaultPaymentAccountId.value
        : this.defaultPaymentAccountId,
    color: color ?? this.color,
    archived: archived ?? this.archived,
    currency: currency ?? this.currency,
  );
  CardRow copyWithCompanion(CreditCardsCompanion data) {
    return CardRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      limitCents: data.limitCents.present
          ? data.limitCents.value
          : this.limitCents,
      closingDay: data.closingDay.present
          ? data.closingDay.value
          : this.closingDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      defaultPaymentAccountId: data.defaultPaymentAccountId.present
          ? data.defaultPaymentAccountId.value
          : this.defaultPaymentAccountId,
      color: data.color.present ? data.color.value : this.color,
      archived: data.archived.present ? data.archived.value : this.archived,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('limitCents: $limitCents, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('defaultPaymentAccountId: $defaultPaymentAccountId, ')
          ..write('color: $color, ')
          ..write('archived: $archived, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    brand,
    limitCents,
    closingDay,
    dueDay,
    defaultPaymentAccountId,
    color,
    archived,
    currency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.limitCents == this.limitCents &&
          other.closingDay == this.closingDay &&
          other.dueDay == this.dueDay &&
          other.defaultPaymentAccountId == this.defaultPaymentAccountId &&
          other.color == this.color &&
          other.archived == this.archived &&
          other.currency == this.currency);
}

class CreditCardsCompanion extends UpdateCompanion<CardRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<int> limitCents;
  final Value<int> closingDay;
  final Value<int> dueDay;
  final Value<String?> defaultPaymentAccountId;
  final Value<String> color;
  final Value<bool> archived;
  final Value<String> currency;
  final Value<int> rowid;
  const CreditCardsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.limitCents = const Value.absent(),
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.defaultPaymentAccountId = const Value.absent(),
    this.color = const Value.absent(),
    this.archived = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditCardsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String name,
    this.brand = const Value.absent(),
    required int limitCents,
    required int closingDay,
    required int dueDay,
    this.defaultPaymentAccountId = const Value.absent(),
    required String color,
    this.archived = const Value.absent(),
    required String currency,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       limitCents = Value(limitCents),
       closingDay = Value(closingDay),
       dueDay = Value(dueDay),
       color = Value(color),
       currency = Value(currency);
  static Insertable<CardRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<int>? limitCents,
    Expression<int>? closingDay,
    Expression<int>? dueDay,
    Expression<String>? defaultPaymentAccountId,
    Expression<String>? color,
    Expression<bool>? archived,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (limitCents != null) 'limit_cents': limitCents,
      if (closingDay != null) 'closing_day': closingDay,
      if (dueDay != null) 'due_day': dueDay,
      if (defaultPaymentAccountId != null)
        'default_payment_account_id': defaultPaymentAccountId,
      if (color != null) 'color': color,
      if (archived != null) 'archived': archived,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditCardsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<int>? limitCents,
    Value<int>? closingDay,
    Value<int>? dueDay,
    Value<String?>? defaultPaymentAccountId,
    Value<String>? color,
    Value<bool>? archived,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return CreditCardsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      limitCents: limitCents ?? this.limitCents,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      defaultPaymentAccountId:
          defaultPaymentAccountId ?? this.defaultPaymentAccountId,
      color: color ?? this.color,
      archived: archived ?? this.archived,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (limitCents.present) {
      map['limit_cents'] = Variable<int>(limitCents.value);
    }
    if (closingDay.present) {
      map['closing_day'] = Variable<int>(closingDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (defaultPaymentAccountId.present) {
      map['default_payment_account_id'] = Variable<String>(
        defaultPaymentAccountId.value,
      );
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('limitCents: $limitCents, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('defaultPaymentAccountId: $defaultPaymentAccountId, ')
          ..write('color: $color, ')
          ..write('archived: $archived, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCentsMeta = const VerificationMeta(
    'targetCents',
  );
  @override
  late final GeneratedColumn<int> targetCents = GeneratedColumn<int>(
    'target_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(targetCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _reservedMeta = const VerificationMeta(
    'reserved',
  );
  @override
  late final GeneratedColumn<bool> reserved = GeneratedColumn<bool>(
    'reserved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reserved" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    kind,
    targetCents,
    targetDate,
    accountId,
    reserved,
    color,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('target_cents')) {
      context.handle(
        _targetCentsMeta,
        targetCents.isAcceptableOrUnknown(
          data['target_cents']!,
          _targetCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCentsMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('reserved')) {
      context.handle(
        _reservedMeta,
        reserved.isAcceptableOrUnknown(data['reserved']!, _reservedMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      targetCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_cents'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_date'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      reserved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reserved'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String name;
  final String kind;
  final int targetCents;
  final String? targetDate;
  final String? accountId;
  final bool reserved;
  final String color;
  final bool archived;
  const GoalRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    required this.name,
    required this.kind,
    required this.targetCents,
    this.targetDate,
    this.accountId,
    required this.reserved,
    required this.color,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['target_cents'] = Variable<int>(targetCents);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(targetDate);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['reserved'] = Variable<bool>(reserved);
    map['color'] = Variable<String>(color);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      targetCents: Value(targetCents),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      reserved: Value(reserved),
      color: Value(color),
      archived: Value(archived),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      targetCents: serializer.fromJson<int>(json['targetCents']),
      targetDate: serializer.fromJson<String?>(json['targetDate']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      reserved: serializer.fromJson<bool>(json['reserved']),
      color: serializer.fromJson<String>(json['color']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'targetCents': serializer.toJson<int>(targetCents),
      'targetDate': serializer.toJson<String?>(targetDate),
      'accountId': serializer.toJson<String?>(accountId),
      'reserved': serializer.toJson<bool>(reserved),
      'color': serializer.toJson<String>(color),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  GoalRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? name,
    String? kind,
    int? targetCents,
    Value<String?> targetDate = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    bool? reserved,
    String? color,
    bool? archived,
  }) => GoalRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    targetCents: targetCents ?? this.targetCents,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    accountId: accountId.present ? accountId.value : this.accountId,
    reserved: reserved ?? this.reserved,
    color: color ?? this.color,
    archived: archived ?? this.archived,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      targetCents: data.targetCents.present
          ? data.targetCents.value
          : this.targetCents,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      reserved: data.reserved.present ? data.reserved.value : this.reserved,
      color: data.color.present ? data.color.value : this.color,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('targetCents: $targetCents, ')
          ..write('targetDate: $targetDate, ')
          ..write('accountId: $accountId, ')
          ..write('reserved: $reserved, ')
          ..write('color: $color, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    kind,
    targetCents,
    targetDate,
    accountId,
    reserved,
    color,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.targetCents == this.targetCents &&
          other.targetDate == this.targetDate &&
          other.accountId == this.accountId &&
          other.reserved == this.reserved &&
          other.color == this.color &&
          other.archived == this.archived);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<int> targetCents;
  final Value<String?> targetDate;
  final Value<String?> accountId;
  final Value<bool> reserved;
  final Value<String> color;
  final Value<bool> archived;
  final Value<int> rowid;
  const GoalsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.targetCents = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.accountId = const Value.absent(),
    this.reserved = const Value.absent(),
    this.color = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String name,
    required String kind,
    required int targetCents,
    this.targetDate = const Value.absent(),
    this.accountId = const Value.absent(),
    this.reserved = const Value.absent(),
    required String color,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       kind = Value(kind),
       targetCents = Value(targetCents),
       color = Value(color);
  static Insertable<GoalRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? targetCents,
    Expression<String>? targetDate,
    Expression<String>? accountId,
    Expression<bool>? reserved,
    Expression<String>? color,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (targetCents != null) 'target_cents': targetCents,
      if (targetDate != null) 'target_date': targetDate,
      if (accountId != null) 'account_id': accountId,
      if (reserved != null) 'reserved': reserved,
      if (color != null) 'color': color,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<int>? targetCents,
    Value<String?>? targetDate,
    Value<String?>? accountId,
    Value<bool>? reserved,
    Value<String>? color,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      targetCents: targetCents ?? this.targetCents,
      targetDate: targetDate ?? this.targetDate,
      accountId: accountId ?? this.accountId,
      reserved: reserved ?? this.reserved,
      color: color ?? this.color,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (targetCents.present) {
      map['target_cents'] = Variable<int>(targetCents.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (reserved.present) {
      map['reserved'] = Variable<bool>(reserved.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('targetCents: $targetCents, ')
          ..write('targetDate: $targetDate, ')
          ..write('accountId: $accountId, ')
          ..write('reserved: $reserved, ')
          ..write('color: $color, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, LoanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lenderMeta = const VerificationMeta('lender');
  @override
  late final GeneratedColumn<String> lender = GeneratedColumn<String>(
    'lender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _principalCentsMeta = const VerificationMeta(
    'principalCents',
  );
  @override
  late final GeneratedColumn<int> principalCents = GeneratedColumn<int>(
    'principal_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(principalCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyRatePercentMeta =
      const VerificationMeta('monthlyRatePercent');
  @override
  late final GeneratedColumn<double> monthlyRatePercent =
      GeneratedColumn<double>(
        'monthly_rate_percent',
        aliasedName,
        false,
        check: () => ComparableExpr(monthlyRatePercent).isBiggerOrEqualValue(0),
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _termMonthsMeta = const VerificationMeta(
    'termMonths',
  );
  @override
  late final GeneratedColumn<int> termMonths = GeneratedColumn<int>(
    'term_months',
    aliasedName,
    false,
    check: () => ComparableExpr(termMonths).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemMeta = const VerificationMeta('system');
  @override
  late final GeneratedColumn<String> system = GeneratedColumn<String>(
    'system',
    aliasedName,
    false,
    check: () => system.isIn(['price', 'sac', 'american', 'bullet', 'free']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstDueDateMeta = const VerificationMeta(
    'firstDueDate',
  );
  @override
  late final GeneratedColumn<String> firstDueDate = GeneratedColumn<String>(
    'first_due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyFeeCentsMeta = const VerificationMeta(
    'monthlyFeeCents',
  );
  @override
  late final GeneratedColumn<int> monthlyFeeCents = GeneratedColumn<int>(
    'monthly_fee_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _upfrontFeesCentsMeta = const VerificationMeta(
    'upfrontFeesCents',
  );
  @override
  late final GeneratedColumn<int> upfrontFeesCents = GeneratedColumn<int>(
    'upfront_fees_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    check: () => direction.isIn(['borrowed', 'lent']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('borrowed'),
  );
  static const VerificationMeta _interestModeMeta = const VerificationMeta(
    'interestMode',
  );
  @override
  late final GeneratedColumn<String> interestMode = GeneratedColumn<String>(
    'interest_mode',
    aliasedName,
    false,
    check: () => interestMode.isIn(['none', 'simple', 'compound']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _ratePeriodMeta = const VerificationMeta(
    'ratePeriod',
  );
  @override
  late final GeneratedColumn<String> ratePeriod = GeneratedColumn<String>(
    'rate_period',
    aliasedName,
    false,
    check: () => ratePeriod.isIn(['month', 'year']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('month'),
  );
  static const VerificationMeta _rateKindMeta = const VerificationMeta(
    'rateKind',
  );
  @override
  late final GeneratedColumn<String> rateKind = GeneratedColumn<String>(
    'rate_kind',
    aliasedName,
    false,
    check: () => rateKind.isIn(['effective', 'nominal']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('effective'),
  );
  static const VerificationMeta _rateInputPercentMeta = const VerificationMeta(
    'rateInputPercent',
  );
  @override
  late final GeneratedColumn<double> rateInputPercent = GeneratedColumn<double>(
    'rate_input_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    lender,
    principalCents,
    monthlyRatePercent,
    termMonths,
    system,
    firstDueDate,
    monthlyFeeCents,
    upfrontFeesCents,
    accountId,
    archived,
    direction,
    interestMode,
    ratePeriod,
    rateKind,
    rateInputPercent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('lender')) {
      context.handle(
        _lenderMeta,
        lender.isAcceptableOrUnknown(data['lender']!, _lenderMeta),
      );
    }
    if (data.containsKey('principal_cents')) {
      context.handle(
        _principalCentsMeta,
        principalCents.isAcceptableOrUnknown(
          data['principal_cents']!,
          _principalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalCentsMeta);
    }
    if (data.containsKey('monthly_rate_percent')) {
      context.handle(
        _monthlyRatePercentMeta,
        monthlyRatePercent.isAcceptableOrUnknown(
          data['monthly_rate_percent']!,
          _monthlyRatePercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyRatePercentMeta);
    }
    if (data.containsKey('term_months')) {
      context.handle(
        _termMonthsMeta,
        termMonths.isAcceptableOrUnknown(data['term_months']!, _termMonthsMeta),
      );
    } else if (isInserting) {
      context.missing(_termMonthsMeta);
    }
    if (data.containsKey('system')) {
      context.handle(
        _systemMeta,
        system.isAcceptableOrUnknown(data['system']!, _systemMeta),
      );
    } else if (isInserting) {
      context.missing(_systemMeta);
    }
    if (data.containsKey('first_due_date')) {
      context.handle(
        _firstDueDateMeta,
        firstDueDate.isAcceptableOrUnknown(
          data['first_due_date']!,
          _firstDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstDueDateMeta);
    }
    if (data.containsKey('monthly_fee_cents')) {
      context.handle(
        _monthlyFeeCentsMeta,
        monthlyFeeCents.isAcceptableOrUnknown(
          data['monthly_fee_cents']!,
          _monthlyFeeCentsMeta,
        ),
      );
    }
    if (data.containsKey('upfront_fees_cents')) {
      context.handle(
        _upfrontFeesCentsMeta,
        upfrontFeesCents.isAcceptableOrUnknown(
          data['upfront_fees_cents']!,
          _upfrontFeesCentsMeta,
        ),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('interest_mode')) {
      context.handle(
        _interestModeMeta,
        interestMode.isAcceptableOrUnknown(
          data['interest_mode']!,
          _interestModeMeta,
        ),
      );
    }
    if (data.containsKey('rate_period')) {
      context.handle(
        _ratePeriodMeta,
        ratePeriod.isAcceptableOrUnknown(data['rate_period']!, _ratePeriodMeta),
      );
    }
    if (data.containsKey('rate_kind')) {
      context.handle(
        _rateKindMeta,
        rateKind.isAcceptableOrUnknown(data['rate_kind']!, _rateKindMeta),
      );
    }
    if (data.containsKey('rate_input_percent')) {
      context.handle(
        _rateInputPercentMeta,
        rateInputPercent.isAcceptableOrUnknown(
          data['rate_input_percent']!,
          _rateInputPercentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lender'],
      ),
      principalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}principal_cents'],
      )!,
      monthlyRatePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_rate_percent'],
      )!,
      termMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}term_months'],
      )!,
      system: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system'],
      )!,
      firstDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_due_date'],
      )!,
      monthlyFeeCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_fee_cents'],
      )!,
      upfrontFeesCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}upfront_fees_cents'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      interestMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_mode'],
      )!,
      ratePeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_period'],
      )!,
      rateKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_kind'],
      )!,
      rateInputPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate_input_percent'],
      ),
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class LoanRow extends DataClass implements Insertable<LoanRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String name;
  final String? lender;
  final int principalCents;
  final double monthlyRatePercent;
  final int termMonths;
  final String system;
  final String firstDueDate;
  final int monthlyFeeCents;
  final int upfrontFeesCents;
  final String? accountId;
  final bool archived;
  final String direction;
  final String interestMode;
  final String ratePeriod;
  final String rateKind;
  final double? rateInputPercent;
  const LoanRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
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
    required this.direction,
    required this.interestMode,
    required this.ratePeriod,
    required this.rateKind,
    this.rateInputPercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || lender != null) {
      map['lender'] = Variable<String>(lender);
    }
    map['principal_cents'] = Variable<int>(principalCents);
    map['monthly_rate_percent'] = Variable<double>(monthlyRatePercent);
    map['term_months'] = Variable<int>(termMonths);
    map['system'] = Variable<String>(system);
    map['first_due_date'] = Variable<String>(firstDueDate);
    map['monthly_fee_cents'] = Variable<int>(monthlyFeeCents);
    map['upfront_fees_cents'] = Variable<int>(upfrontFeesCents);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['archived'] = Variable<bool>(archived);
    map['direction'] = Variable<String>(direction);
    map['interest_mode'] = Variable<String>(interestMode);
    map['rate_period'] = Variable<String>(ratePeriod);
    map['rate_kind'] = Variable<String>(rateKind);
    if (!nullToAbsent || rateInputPercent != null) {
      map['rate_input_percent'] = Variable<double>(rateInputPercent);
    }
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      lender: lender == null && nullToAbsent
          ? const Value.absent()
          : Value(lender),
      principalCents: Value(principalCents),
      monthlyRatePercent: Value(monthlyRatePercent),
      termMonths: Value(termMonths),
      system: Value(system),
      firstDueDate: Value(firstDueDate),
      monthlyFeeCents: Value(monthlyFeeCents),
      upfrontFeesCents: Value(upfrontFeesCents),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      archived: Value(archived),
      direction: Value(direction),
      interestMode: Value(interestMode),
      ratePeriod: Value(ratePeriod),
      rateKind: Value(rateKind),
      rateInputPercent: rateInputPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(rateInputPercent),
    );
  }

  factory LoanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lender: serializer.fromJson<String?>(json['lender']),
      principalCents: serializer.fromJson<int>(json['principalCents']),
      monthlyRatePercent: serializer.fromJson<double>(
        json['monthlyRatePercent'],
      ),
      termMonths: serializer.fromJson<int>(json['termMonths']),
      system: serializer.fromJson<String>(json['system']),
      firstDueDate: serializer.fromJson<String>(json['firstDueDate']),
      monthlyFeeCents: serializer.fromJson<int>(json['monthlyFeeCents']),
      upfrontFeesCents: serializer.fromJson<int>(json['upfrontFeesCents']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      archived: serializer.fromJson<bool>(json['archived']),
      direction: serializer.fromJson<String>(json['direction']),
      interestMode: serializer.fromJson<String>(json['interestMode']),
      ratePeriod: serializer.fromJson<String>(json['ratePeriod']),
      rateKind: serializer.fromJson<String>(json['rateKind']),
      rateInputPercent: serializer.fromJson<double?>(json['rateInputPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'lender': serializer.toJson<String?>(lender),
      'principalCents': serializer.toJson<int>(principalCents),
      'monthlyRatePercent': serializer.toJson<double>(monthlyRatePercent),
      'termMonths': serializer.toJson<int>(termMonths),
      'system': serializer.toJson<String>(system),
      'firstDueDate': serializer.toJson<String>(firstDueDate),
      'monthlyFeeCents': serializer.toJson<int>(monthlyFeeCents),
      'upfrontFeesCents': serializer.toJson<int>(upfrontFeesCents),
      'accountId': serializer.toJson<String?>(accountId),
      'archived': serializer.toJson<bool>(archived),
      'direction': serializer.toJson<String>(direction),
      'interestMode': serializer.toJson<String>(interestMode),
      'ratePeriod': serializer.toJson<String>(ratePeriod),
      'rateKind': serializer.toJson<String>(rateKind),
      'rateInputPercent': serializer.toJson<double?>(rateInputPercent),
    };
  }

  LoanRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? name,
    Value<String?> lender = const Value.absent(),
    int? principalCents,
    double? monthlyRatePercent,
    int? termMonths,
    String? system,
    String? firstDueDate,
    int? monthlyFeeCents,
    int? upfrontFeesCents,
    Value<String?> accountId = const Value.absent(),
    bool? archived,
    String? direction,
    String? interestMode,
    String? ratePeriod,
    String? rateKind,
    Value<double?> rateInputPercent = const Value.absent(),
  }) => LoanRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    lender: lender.present ? lender.value : this.lender,
    principalCents: principalCents ?? this.principalCents,
    monthlyRatePercent: monthlyRatePercent ?? this.monthlyRatePercent,
    termMonths: termMonths ?? this.termMonths,
    system: system ?? this.system,
    firstDueDate: firstDueDate ?? this.firstDueDate,
    monthlyFeeCents: monthlyFeeCents ?? this.monthlyFeeCents,
    upfrontFeesCents: upfrontFeesCents ?? this.upfrontFeesCents,
    accountId: accountId.present ? accountId.value : this.accountId,
    archived: archived ?? this.archived,
    direction: direction ?? this.direction,
    interestMode: interestMode ?? this.interestMode,
    ratePeriod: ratePeriod ?? this.ratePeriod,
    rateKind: rateKind ?? this.rateKind,
    rateInputPercent: rateInputPercent.present
        ? rateInputPercent.value
        : this.rateInputPercent,
  );
  LoanRow copyWithCompanion(LoansCompanion data) {
    return LoanRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lender: data.lender.present ? data.lender.value : this.lender,
      principalCents: data.principalCents.present
          ? data.principalCents.value
          : this.principalCents,
      monthlyRatePercent: data.monthlyRatePercent.present
          ? data.monthlyRatePercent.value
          : this.monthlyRatePercent,
      termMonths: data.termMonths.present
          ? data.termMonths.value
          : this.termMonths,
      system: data.system.present ? data.system.value : this.system,
      firstDueDate: data.firstDueDate.present
          ? data.firstDueDate.value
          : this.firstDueDate,
      monthlyFeeCents: data.monthlyFeeCents.present
          ? data.monthlyFeeCents.value
          : this.monthlyFeeCents,
      upfrontFeesCents: data.upfrontFeesCents.present
          ? data.upfrontFeesCents.value
          : this.upfrontFeesCents,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      archived: data.archived.present ? data.archived.value : this.archived,
      direction: data.direction.present ? data.direction.value : this.direction,
      interestMode: data.interestMode.present
          ? data.interestMode.value
          : this.interestMode,
      ratePeriod: data.ratePeriod.present
          ? data.ratePeriod.value
          : this.ratePeriod,
      rateKind: data.rateKind.present ? data.rateKind.value : this.rateKind,
      rateInputPercent: data.rateInputPercent.present
          ? data.rateInputPercent.value
          : this.rateInputPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lender: $lender, ')
          ..write('principalCents: $principalCents, ')
          ..write('monthlyRatePercent: $monthlyRatePercent, ')
          ..write('termMonths: $termMonths, ')
          ..write('system: $system, ')
          ..write('firstDueDate: $firstDueDate, ')
          ..write('monthlyFeeCents: $monthlyFeeCents, ')
          ..write('upfrontFeesCents: $upfrontFeesCents, ')
          ..write('accountId: $accountId, ')
          ..write('archived: $archived, ')
          ..write('direction: $direction, ')
          ..write('interestMode: $interestMode, ')
          ..write('ratePeriod: $ratePeriod, ')
          ..write('rateKind: $rateKind, ')
          ..write('rateInputPercent: $rateInputPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    lender,
    principalCents,
    monthlyRatePercent,
    termMonths,
    system,
    firstDueDate,
    monthlyFeeCents,
    upfrontFeesCents,
    accountId,
    archived,
    direction,
    interestMode,
    ratePeriod,
    rateKind,
    rateInputPercent,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.lender == this.lender &&
          other.principalCents == this.principalCents &&
          other.monthlyRatePercent == this.monthlyRatePercent &&
          other.termMonths == this.termMonths &&
          other.system == this.system &&
          other.firstDueDate == this.firstDueDate &&
          other.monthlyFeeCents == this.monthlyFeeCents &&
          other.upfrontFeesCents == this.upfrontFeesCents &&
          other.accountId == this.accountId &&
          other.archived == this.archived &&
          other.direction == this.direction &&
          other.interestMode == this.interestMode &&
          other.ratePeriod == this.ratePeriod &&
          other.rateKind == this.rateKind &&
          other.rateInputPercent == this.rateInputPercent);
}

class LoansCompanion extends UpdateCompanion<LoanRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> lender;
  final Value<int> principalCents;
  final Value<double> monthlyRatePercent;
  final Value<int> termMonths;
  final Value<String> system;
  final Value<String> firstDueDate;
  final Value<int> monthlyFeeCents;
  final Value<int> upfrontFeesCents;
  final Value<String?> accountId;
  final Value<bool> archived;
  final Value<String> direction;
  final Value<String> interestMode;
  final Value<String> ratePeriod;
  final Value<String> rateKind;
  final Value<double?> rateInputPercent;
  final Value<int> rowid;
  const LoansCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lender = const Value.absent(),
    this.principalCents = const Value.absent(),
    this.monthlyRatePercent = const Value.absent(),
    this.termMonths = const Value.absent(),
    this.system = const Value.absent(),
    this.firstDueDate = const Value.absent(),
    this.monthlyFeeCents = const Value.absent(),
    this.upfrontFeesCents = const Value.absent(),
    this.accountId = const Value.absent(),
    this.archived = const Value.absent(),
    this.direction = const Value.absent(),
    this.interestMode = const Value.absent(),
    this.ratePeriod = const Value.absent(),
    this.rateKind = const Value.absent(),
    this.rateInputPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String name,
    this.lender = const Value.absent(),
    required int principalCents,
    required double monthlyRatePercent,
    required int termMonths,
    required String system,
    required String firstDueDate,
    this.monthlyFeeCents = const Value.absent(),
    this.upfrontFeesCents = const Value.absent(),
    this.accountId = const Value.absent(),
    this.archived = const Value.absent(),
    this.direction = const Value.absent(),
    this.interestMode = const Value.absent(),
    this.ratePeriod = const Value.absent(),
    this.rateKind = const Value.absent(),
    this.rateInputPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       principalCents = Value(principalCents),
       monthlyRatePercent = Value(monthlyRatePercent),
       termMonths = Value(termMonths),
       system = Value(system),
       firstDueDate = Value(firstDueDate);
  static Insertable<LoanRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? lender,
    Expression<int>? principalCents,
    Expression<double>? monthlyRatePercent,
    Expression<int>? termMonths,
    Expression<String>? system,
    Expression<String>? firstDueDate,
    Expression<int>? monthlyFeeCents,
    Expression<int>? upfrontFeesCents,
    Expression<String>? accountId,
    Expression<bool>? archived,
    Expression<String>? direction,
    Expression<String>? interestMode,
    Expression<String>? ratePeriod,
    Expression<String>? rateKind,
    Expression<double>? rateInputPercent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lender != null) 'lender': lender,
      if (principalCents != null) 'principal_cents': principalCents,
      if (monthlyRatePercent != null)
        'monthly_rate_percent': monthlyRatePercent,
      if (termMonths != null) 'term_months': termMonths,
      if (system != null) 'system': system,
      if (firstDueDate != null) 'first_due_date': firstDueDate,
      if (monthlyFeeCents != null) 'monthly_fee_cents': monthlyFeeCents,
      if (upfrontFeesCents != null) 'upfront_fees_cents': upfrontFeesCents,
      if (accountId != null) 'account_id': accountId,
      if (archived != null) 'archived': archived,
      if (direction != null) 'direction': direction,
      if (interestMode != null) 'interest_mode': interestMode,
      if (ratePeriod != null) 'rate_period': ratePeriod,
      if (rateKind != null) 'rate_kind': rateKind,
      if (rateInputPercent != null) 'rate_input_percent': rateInputPercent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? lender,
    Value<int>? principalCents,
    Value<double>? monthlyRatePercent,
    Value<int>? termMonths,
    Value<String>? system,
    Value<String>? firstDueDate,
    Value<int>? monthlyFeeCents,
    Value<int>? upfrontFeesCents,
    Value<String?>? accountId,
    Value<bool>? archived,
    Value<String>? direction,
    Value<String>? interestMode,
    Value<String>? ratePeriod,
    Value<String>? rateKind,
    Value<double?>? rateInputPercent,
    Value<int>? rowid,
  }) {
    return LoansCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      lender: lender ?? this.lender,
      principalCents: principalCents ?? this.principalCents,
      monthlyRatePercent: monthlyRatePercent ?? this.monthlyRatePercent,
      termMonths: termMonths ?? this.termMonths,
      system: system ?? this.system,
      firstDueDate: firstDueDate ?? this.firstDueDate,
      monthlyFeeCents: monthlyFeeCents ?? this.monthlyFeeCents,
      upfrontFeesCents: upfrontFeesCents ?? this.upfrontFeesCents,
      accountId: accountId ?? this.accountId,
      archived: archived ?? this.archived,
      direction: direction ?? this.direction,
      interestMode: interestMode ?? this.interestMode,
      ratePeriod: ratePeriod ?? this.ratePeriod,
      rateKind: rateKind ?? this.rateKind,
      rateInputPercent: rateInputPercent ?? this.rateInputPercent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lender.present) {
      map['lender'] = Variable<String>(lender.value);
    }
    if (principalCents.present) {
      map['principal_cents'] = Variable<int>(principalCents.value);
    }
    if (monthlyRatePercent.present) {
      map['monthly_rate_percent'] = Variable<double>(monthlyRatePercent.value);
    }
    if (termMonths.present) {
      map['term_months'] = Variable<int>(termMonths.value);
    }
    if (system.present) {
      map['system'] = Variable<String>(system.value);
    }
    if (firstDueDate.present) {
      map['first_due_date'] = Variable<String>(firstDueDate.value);
    }
    if (monthlyFeeCents.present) {
      map['monthly_fee_cents'] = Variable<int>(monthlyFeeCents.value);
    }
    if (upfrontFeesCents.present) {
      map['upfront_fees_cents'] = Variable<int>(upfrontFeesCents.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (interestMode.present) {
      map['interest_mode'] = Variable<String>(interestMode.value);
    }
    if (ratePeriod.present) {
      map['rate_period'] = Variable<String>(ratePeriod.value);
    }
    if (rateKind.present) {
      map['rate_kind'] = Variable<String>(rateKind.value);
    }
    if (rateInputPercent.present) {
      map['rate_input_percent'] = Variable<double>(rateInputPercent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lender: $lender, ')
          ..write('principalCents: $principalCents, ')
          ..write('monthlyRatePercent: $monthlyRatePercent, ')
          ..write('termMonths: $termMonths, ')
          ..write('system: $system, ')
          ..write('firstDueDate: $firstDueDate, ')
          ..write('monthlyFeeCents: $monthlyFeeCents, ')
          ..write('upfrontFeesCents: $upfrontFeesCents, ')
          ..write('accountId: $accountId, ')
          ..write('archived: $archived, ')
          ..write('direction: $direction, ')
          ..write('interestMode: $interestMode, ')
          ..write('ratePeriod: $ratePeriod, ')
          ..write('rateKind: $rateKind, ')
          ..write('rateInputPercent: $rateInputPercent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    check: () => kind.isIn([
      'income',
      'expense',
      'transfer',
      'card_purchase',
      'card_payment',
      'goal_deposit',
      'goal_withdrawal',
      'loan_disbursement',
      'loan_payment',
      'balance_adjustment',
      'card_refund',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(amountCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES credit_cards (id)',
    ),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id)',
    ),
  );
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
    'loan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES loans (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () =>
        status.isIn(['planned', 'settled', 'partially_paid', 'cancelled']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidCentsMeta = const VerificationMeta(
    'paidCents',
  );
  @override
  late final GeneratedColumn<int> paidCents = GeneratedColumn<int>(
    'paid_cents',
    aliasedName,
    true,
    check: () =>
        paidCents.isNull() | ComparableExpr(paidCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settledDateMeta = const VerificationMeta(
    'settledDate',
  );
  @override
  late final GeneratedColumn<String> settledDate = GeneratedColumn<String>(
    'settled_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentOfMeta = const VerificationMeta(
    'installmentOf',
  );
  @override
  late final GeneratedColumn<int> installmentOf = GeneratedColumn<int>(
    'installment_of',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentGroupIdMeta =
      const VerificationMeta('installmentGroupId');
  @override
  late final GeneratedColumn<String> installmentGroupId =
      GeneratedColumn<String>(
        'installment_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferGroupIdMeta = const VerificationMeta(
    'transferGroupId',
  );
  @override
  late final GeneratedColumn<String> transferGroupId = GeneratedColumn<String>(
    'transfer_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceMonthMeta = const VerificationMeta(
    'invoiceMonth',
  );
  @override
  late final GeneratedColumn<String> invoiceMonth = GeneratedColumn<String>(
    'invoice_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalRefMeta = const VerificationMeta(
    'externalRef',
  );
  @override
  late final GeneratedColumn<String> externalRef = GeneratedColumn<String>(
    'external_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refundOfIdMeta = const VerificationMeta(
    'refundOfId',
  );
  @override
  late final GeneratedColumn<String> refundOfId = GeneratedColumn<String>(
    'refund_of_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    kind,
    amountCents,
    currency,
    date,
    description,
    categoryId,
    accountId,
    toAccountId,
    cardId,
    goalId,
    loanId,
    status,
    paidCents,
    settledDate,
    dueDate,
    installmentNumber,
    installmentOf,
    installmentGroupId,
    seriesId,
    transferGroupId,
    invoiceMonth,
    notes,
    merchant,
    externalRef,
    refundOfId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    }
    if (data.containsKey('loan_id')) {
      context.handle(
        _loanIdMeta,
        loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('paid_cents')) {
      context.handle(
        _paidCentsMeta,
        paidCents.isAcceptableOrUnknown(data['paid_cents']!, _paidCentsMeta),
      );
    }
    if (data.containsKey('settled_date')) {
      context.handle(
        _settledDateMeta,
        settledDate.isAcceptableOrUnknown(
          data['settled_date']!,
          _settledDateMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    }
    if (data.containsKey('installment_of')) {
      context.handle(
        _installmentOfMeta,
        installmentOf.isAcceptableOrUnknown(
          data['installment_of']!,
          _installmentOfMeta,
        ),
      );
    }
    if (data.containsKey('installment_group_id')) {
      context.handle(
        _installmentGroupIdMeta,
        installmentGroupId.isAcceptableOrUnknown(
          data['installment_group_id']!,
          _installmentGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('transfer_group_id')) {
      context.handle(
        _transferGroupIdMeta,
        transferGroupId.isAcceptableOrUnknown(
          data['transfer_group_id']!,
          _transferGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('invoice_month')) {
      context.handle(
        _invoiceMonthMeta,
        invoiceMonth.isAcceptableOrUnknown(
          data['invoice_month']!,
          _invoiceMonthMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('external_ref')) {
      context.handle(
        _externalRefMeta,
        externalRef.isAcceptableOrUnknown(
          data['external_ref']!,
          _externalRefMeta,
        ),
      );
    }
    if (data.containsKey('refund_of_id')) {
      context.handle(
        _refundOfIdMeta,
        refundOfId.isAcceptableOrUnknown(
          data['refund_of_id']!,
          _refundOfIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_id'],
      ),
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      ),
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      ),
      loanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      paidCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_cents'],
      ),
      settledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settled_date'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      ),
      installmentOf: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_of'],
      ),
      installmentGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installment_group_id'],
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      transferGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_group_id'],
      ),
      invoiceMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_month'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      externalRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_ref'],
      ),
      refundOfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_of_id'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String kind;
  final int amountCents;
  final String currency;
  final String date;
  final String description;
  final String? categoryId;
  final String? accountId;
  final String? toAccountId;
  final String? cardId;
  final String? goalId;
  final String? loanId;
  final String status;
  final int? paidCents;
  final String? settledDate;
  final String? dueDate;
  final int? installmentNumber;
  final int? installmentOf;
  final String? installmentGroupId;
  final String? seriesId;
  final String? transferGroupId;
  final String? invoiceMonth;
  final String? notes;
  final String? merchant;
  final String? externalRef;
  final String? refundOfId;
  const TransactionRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
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
    this.installmentNumber,
    this.installmentOf,
    this.installmentGroupId,
    this.seriesId,
    this.transferGroupId,
    this.invoiceMonth,
    this.notes,
    this.merchant,
    this.externalRef,
    this.refundOfId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['amount_cents'] = Variable<int>(amountCents);
    map['currency'] = Variable<String>(currency);
    map['date'] = Variable<String>(date);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || cardId != null) {
      map['card_id'] = Variable<String>(cardId);
    }
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<String>(goalId);
    }
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<String>(loanId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || paidCents != null) {
      map['paid_cents'] = Variable<int>(paidCents);
    }
    if (!nullToAbsent || settledDate != null) {
      map['settled_date'] = Variable<String>(settledDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || installmentNumber != null) {
      map['installment_number'] = Variable<int>(installmentNumber);
    }
    if (!nullToAbsent || installmentOf != null) {
      map['installment_of'] = Variable<int>(installmentOf);
    }
    if (!nullToAbsent || installmentGroupId != null) {
      map['installment_group_id'] = Variable<String>(installmentGroupId);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    if (!nullToAbsent || transferGroupId != null) {
      map['transfer_group_id'] = Variable<String>(transferGroupId);
    }
    if (!nullToAbsent || invoiceMonth != null) {
      map['invoice_month'] = Variable<String>(invoiceMonth);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || externalRef != null) {
      map['external_ref'] = Variable<String>(externalRef);
    }
    if (!nullToAbsent || refundOfId != null) {
      map['refund_of_id'] = Variable<String>(refundOfId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      kind: Value(kind),
      amountCents: Value(amountCents),
      currency: Value(currency),
      date: Value(date),
      description: Value(description),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      cardId: cardId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardId),
      goalId: goalId == null && nullToAbsent
          ? const Value.absent()
          : Value(goalId),
      loanId: loanId == null && nullToAbsent
          ? const Value.absent()
          : Value(loanId),
      status: Value(status),
      paidCents: paidCents == null && nullToAbsent
          ? const Value.absent()
          : Value(paidCents),
      settledDate: settledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(settledDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      installmentNumber: installmentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentNumber),
      installmentOf: installmentOf == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentOf),
      installmentGroupId: installmentGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentGroupId),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      transferGroupId: transferGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferGroupId),
      invoiceMonth: invoiceMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceMonth),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      externalRef: externalRef == null && nullToAbsent
          ? const Value.absent()
          : Value(externalRef),
      refundOfId: refundOfId == null && nullToAbsent
          ? const Value.absent()
          : Value(refundOfId),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      currency: serializer.fromJson<String>(json['currency']),
      date: serializer.fromJson<String>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      cardId: serializer.fromJson<String?>(json['cardId']),
      goalId: serializer.fromJson<String?>(json['goalId']),
      loanId: serializer.fromJson<String?>(json['loanId']),
      status: serializer.fromJson<String>(json['status']),
      paidCents: serializer.fromJson<int?>(json['paidCents']),
      settledDate: serializer.fromJson<String?>(json['settledDate']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      installmentNumber: serializer.fromJson<int?>(json['installmentNumber']),
      installmentOf: serializer.fromJson<int?>(json['installmentOf']),
      installmentGroupId: serializer.fromJson<String?>(
        json['installmentGroupId'],
      ),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      transferGroupId: serializer.fromJson<String?>(json['transferGroupId']),
      invoiceMonth: serializer.fromJson<String?>(json['invoiceMonth']),
      notes: serializer.fromJson<String?>(json['notes']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      externalRef: serializer.fromJson<String?>(json['externalRef']),
      refundOfId: serializer.fromJson<String?>(json['refundOfId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'amountCents': serializer.toJson<int>(amountCents),
      'currency': serializer.toJson<String>(currency),
      'date': serializer.toJson<String>(date),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<String?>(categoryId),
      'accountId': serializer.toJson<String?>(accountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'cardId': serializer.toJson<String?>(cardId),
      'goalId': serializer.toJson<String?>(goalId),
      'loanId': serializer.toJson<String?>(loanId),
      'status': serializer.toJson<String>(status),
      'paidCents': serializer.toJson<int?>(paidCents),
      'settledDate': serializer.toJson<String?>(settledDate),
      'dueDate': serializer.toJson<String?>(dueDate),
      'installmentNumber': serializer.toJson<int?>(installmentNumber),
      'installmentOf': serializer.toJson<int?>(installmentOf),
      'installmentGroupId': serializer.toJson<String?>(installmentGroupId),
      'seriesId': serializer.toJson<String?>(seriesId),
      'transferGroupId': serializer.toJson<String?>(transferGroupId),
      'invoiceMonth': serializer.toJson<String?>(invoiceMonth),
      'notes': serializer.toJson<String?>(notes),
      'merchant': serializer.toJson<String?>(merchant),
      'externalRef': serializer.toJson<String?>(externalRef),
      'refundOfId': serializer.toJson<String?>(refundOfId),
    };
  }

  TransactionRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? kind,
    int? amountCents,
    String? currency,
    String? date,
    String? description,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    Value<String?> toAccountId = const Value.absent(),
    Value<String?> cardId = const Value.absent(),
    Value<String?> goalId = const Value.absent(),
    Value<String?> loanId = const Value.absent(),
    String? status,
    Value<int?> paidCents = const Value.absent(),
    Value<String?> settledDate = const Value.absent(),
    Value<String?> dueDate = const Value.absent(),
    Value<int?> installmentNumber = const Value.absent(),
    Value<int?> installmentOf = const Value.absent(),
    Value<String?> installmentGroupId = const Value.absent(),
    Value<String?> seriesId = const Value.absent(),
    Value<String?> transferGroupId = const Value.absent(),
    Value<String?> invoiceMonth = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> merchant = const Value.absent(),
    Value<String?> externalRef = const Value.absent(),
    Value<String?> refundOfId = const Value.absent(),
  }) => TransactionRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    kind: kind ?? this.kind,
    amountCents: amountCents ?? this.amountCents,
    currency: currency ?? this.currency,
    date: date ?? this.date,
    description: description ?? this.description,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    cardId: cardId.present ? cardId.value : this.cardId,
    goalId: goalId.present ? goalId.value : this.goalId,
    loanId: loanId.present ? loanId.value : this.loanId,
    status: status ?? this.status,
    paidCents: paidCents.present ? paidCents.value : this.paidCents,
    settledDate: settledDate.present ? settledDate.value : this.settledDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    installmentNumber: installmentNumber.present
        ? installmentNumber.value
        : this.installmentNumber,
    installmentOf: installmentOf.present
        ? installmentOf.value
        : this.installmentOf,
    installmentGroupId: installmentGroupId.present
        ? installmentGroupId.value
        : this.installmentGroupId,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    transferGroupId: transferGroupId.present
        ? transferGroupId.value
        : this.transferGroupId,
    invoiceMonth: invoiceMonth.present ? invoiceMonth.value : this.invoiceMonth,
    notes: notes.present ? notes.value : this.notes,
    merchant: merchant.present ? merchant.value : this.merchant,
    externalRef: externalRef.present ? externalRef.value : this.externalRef,
    refundOfId: refundOfId.present ? refundOfId.value : this.refundOfId,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      status: data.status.present ? data.status.value : this.status,
      paidCents: data.paidCents.present ? data.paidCents.value : this.paidCents,
      settledDate: data.settledDate.present
          ? data.settledDate.value
          : this.settledDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      installmentOf: data.installmentOf.present
          ? data.installmentOf.value
          : this.installmentOf,
      installmentGroupId: data.installmentGroupId.present
          ? data.installmentGroupId.value
          : this.installmentGroupId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      transferGroupId: data.transferGroupId.present
          ? data.transferGroupId.value
          : this.transferGroupId,
      invoiceMonth: data.invoiceMonth.present
          ? data.invoiceMonth.value
          : this.invoiceMonth,
      notes: data.notes.present ? data.notes.value : this.notes,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      externalRef: data.externalRef.present
          ? data.externalRef.value
          : this.externalRef,
      refundOfId: data.refundOfId.present
          ? data.refundOfId.value
          : this.refundOfId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('cardId: $cardId, ')
          ..write('goalId: $goalId, ')
          ..write('loanId: $loanId, ')
          ..write('status: $status, ')
          ..write('paidCents: $paidCents, ')
          ..write('settledDate: $settledDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('installmentOf: $installmentOf, ')
          ..write('installmentGroupId: $installmentGroupId, ')
          ..write('seriesId: $seriesId, ')
          ..write('transferGroupId: $transferGroupId, ')
          ..write('invoiceMonth: $invoiceMonth, ')
          ..write('notes: $notes, ')
          ..write('merchant: $merchant, ')
          ..write('externalRef: $externalRef, ')
          ..write('refundOfId: $refundOfId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    kind,
    amountCents,
    currency,
    date,
    description,
    categoryId,
    accountId,
    toAccountId,
    cardId,
    goalId,
    loanId,
    status,
    paidCents,
    settledDate,
    dueDate,
    installmentNumber,
    installmentOf,
    installmentGroupId,
    seriesId,
    transferGroupId,
    invoiceMonth,
    notes,
    merchant,
    externalRef,
    refundOfId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.amountCents == this.amountCents &&
          other.currency == this.currency &&
          other.date == this.date &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.cardId == this.cardId &&
          other.goalId == this.goalId &&
          other.loanId == this.loanId &&
          other.status == this.status &&
          other.paidCents == this.paidCents &&
          other.settledDate == this.settledDate &&
          other.dueDate == this.dueDate &&
          other.installmentNumber == this.installmentNumber &&
          other.installmentOf == this.installmentOf &&
          other.installmentGroupId == this.installmentGroupId &&
          other.seriesId == this.seriesId &&
          other.transferGroupId == this.transferGroupId &&
          other.invoiceMonth == this.invoiceMonth &&
          other.notes == this.notes &&
          other.merchant == this.merchant &&
          other.externalRef == this.externalRef &&
          other.refundOfId == this.refundOfId);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> kind;
  final Value<int> amountCents;
  final Value<String> currency;
  final Value<String> date;
  final Value<String> description;
  final Value<String?> categoryId;
  final Value<String?> accountId;
  final Value<String?> toAccountId;
  final Value<String?> cardId;
  final Value<String?> goalId;
  final Value<String?> loanId;
  final Value<String> status;
  final Value<int?> paidCents;
  final Value<String?> settledDate;
  final Value<String?> dueDate;
  final Value<int?> installmentNumber;
  final Value<int?> installmentOf;
  final Value<String?> installmentGroupId;
  final Value<String?> seriesId;
  final Value<String?> transferGroupId;
  final Value<String?> invoiceMonth;
  final Value<String?> notes;
  final Value<String?> merchant;
  final Value<String?> externalRef;
  final Value<String?> refundOfId;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.goalId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.status = const Value.absent(),
    this.paidCents = const Value.absent(),
    this.settledDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.installmentOf = const Value.absent(),
    this.installmentGroupId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.transferGroupId = const Value.absent(),
    this.invoiceMonth = const Value.absent(),
    this.notes = const Value.absent(),
    this.merchant = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.refundOfId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String kind,
    required int amountCents,
    required String currency,
    required String date,
    required String description,
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.goalId = const Value.absent(),
    this.loanId = const Value.absent(),
    required String status,
    this.paidCents = const Value.absent(),
    this.settledDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.installmentOf = const Value.absent(),
    this.installmentGroupId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.transferGroupId = const Value.absent(),
    this.invoiceMonth = const Value.absent(),
    this.notes = const Value.absent(),
    this.merchant = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.refundOfId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       kind = Value(kind),
       amountCents = Value(amountCents),
       currency = Value(currency),
       date = Value(date),
       description = Value(description),
       status = Value(status);
  static Insertable<TransactionRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? kind,
    Expression<int>? amountCents,
    Expression<String>? currency,
    Expression<String>? date,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<String>? accountId,
    Expression<String>? toAccountId,
    Expression<String>? cardId,
    Expression<String>? goalId,
    Expression<String>? loanId,
    Expression<String>? status,
    Expression<int>? paidCents,
    Expression<String>? settledDate,
    Expression<String>? dueDate,
    Expression<int>? installmentNumber,
    Expression<int>? installmentOf,
    Expression<String>? installmentGroupId,
    Expression<String>? seriesId,
    Expression<String>? transferGroupId,
    Expression<String>? invoiceMonth,
    Expression<String>? notes,
    Expression<String>? merchant,
    Expression<String>? externalRef,
    Expression<String>? refundOfId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (amountCents != null) 'amount_cents': amountCents,
      if (currency != null) 'currency': currency,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (cardId != null) 'card_id': cardId,
      if (goalId != null) 'goal_id': goalId,
      if (loanId != null) 'loan_id': loanId,
      if (status != null) 'status': status,
      if (paidCents != null) 'paid_cents': paidCents,
      if (settledDate != null) 'settled_date': settledDate,
      if (dueDate != null) 'due_date': dueDate,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (installmentOf != null) 'installment_of': installmentOf,
      if (installmentGroupId != null)
        'installment_group_id': installmentGroupId,
      if (seriesId != null) 'series_id': seriesId,
      if (transferGroupId != null) 'transfer_group_id': transferGroupId,
      if (invoiceMonth != null) 'invoice_month': invoiceMonth,
      if (notes != null) 'notes': notes,
      if (merchant != null) 'merchant': merchant,
      if (externalRef != null) 'external_ref': externalRef,
      if (refundOfId != null) 'refund_of_id': refundOfId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? kind,
    Value<int>? amountCents,
    Value<String>? currency,
    Value<String>? date,
    Value<String>? description,
    Value<String?>? categoryId,
    Value<String?>? accountId,
    Value<String?>? toAccountId,
    Value<String?>? cardId,
    Value<String?>? goalId,
    Value<String?>? loanId,
    Value<String>? status,
    Value<int?>? paidCents,
    Value<String?>? settledDate,
    Value<String?>? dueDate,
    Value<int?>? installmentNumber,
    Value<int?>? installmentOf,
    Value<String?>? installmentGroupId,
    Value<String?>? seriesId,
    Value<String?>? transferGroupId,
    Value<String?>? invoiceMonth,
    Value<String?>? notes,
    Value<String?>? merchant,
    Value<String?>? externalRef,
    Value<String?>? refundOfId,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      kind: kind ?? this.kind,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      cardId: cardId ?? this.cardId,
      goalId: goalId ?? this.goalId,
      loanId: loanId ?? this.loanId,
      status: status ?? this.status,
      paidCents: paidCents ?? this.paidCents,
      settledDate: settledDate ?? this.settledDate,
      dueDate: dueDate ?? this.dueDate,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      installmentOf: installmentOf ?? this.installmentOf,
      installmentGroupId: installmentGroupId ?? this.installmentGroupId,
      seriesId: seriesId ?? this.seriesId,
      transferGroupId: transferGroupId ?? this.transferGroupId,
      invoiceMonth: invoiceMonth ?? this.invoiceMonth,
      notes: notes ?? this.notes,
      merchant: merchant ?? this.merchant,
      externalRef: externalRef ?? this.externalRef,
      refundOfId: refundOfId ?? this.refundOfId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paidCents.present) {
      map['paid_cents'] = Variable<int>(paidCents.value);
    }
    if (settledDate.present) {
      map['settled_date'] = Variable<String>(settledDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (installmentOf.present) {
      map['installment_of'] = Variable<int>(installmentOf.value);
    }
    if (installmentGroupId.present) {
      map['installment_group_id'] = Variable<String>(installmentGroupId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (transferGroupId.present) {
      map['transfer_group_id'] = Variable<String>(transferGroupId.value);
    }
    if (invoiceMonth.present) {
      map['invoice_month'] = Variable<String>(invoiceMonth.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (externalRef.present) {
      map['external_ref'] = Variable<String>(externalRef.value);
    }
    if (refundOfId.present) {
      map['refund_of_id'] = Variable<String>(refundOfId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('cardId: $cardId, ')
          ..write('goalId: $goalId, ')
          ..write('loanId: $loanId, ')
          ..write('status: $status, ')
          ..write('paidCents: $paidCents, ')
          ..write('settledDate: $settledDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('installmentOf: $installmentOf, ')
          ..write('installmentGroupId: $installmentGroupId, ')
          ..write('seriesId: $seriesId, ')
          ..write('transferGroupId: $transferGroupId, ')
          ..write('invoiceMonth: $invoiceMonth, ')
          ..write('notes: $notes, ')
          ..write('merchant: $merchant, ')
          ..write('externalRef: $externalRef, ')
          ..write('refundOfId: $refundOfId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionTagsTable extends TransactionTags
    with TableInfo<$TransactionTagsTable, TransactionTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [transactionId, tagId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId, tagId};
  @override
  TransactionTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTagRow(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TransactionTagsTable createAlias(String alias) {
    return $TransactionTagsTable(attachedDatabase, alias);
  }
}

class TransactionTagRow extends DataClass
    implements Insertable<TransactionTagRow> {
  final String transactionId;
  final String tagId;
  final int position;
  const TransactionTagRow({
    required this.transactionId,
    required this.tagId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    map['tag_id'] = Variable<String>(tagId);
    map['position'] = Variable<int>(position);
    return map;
  }

  TransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return TransactionTagsCompanion(
      transactionId: Value(transactionId),
      tagId: Value(tagId),
      position: Value(position),
    );
  }

  factory TransactionTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTagRow(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'tagId': serializer.toJson<String>(tagId),
      'position': serializer.toJson<int>(position),
    };
  }

  TransactionTagRow copyWith({
    String? transactionId,
    String? tagId,
    int? position,
  }) => TransactionTagRow(
    transactionId: transactionId ?? this.transactionId,
    tagId: tagId ?? this.tagId,
    position: position ?? this.position,
  );
  TransactionTagRow copyWithCompanion(TransactionTagsCompanion data) {
    return TransactionTagRow(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagRow(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(transactionId, tagId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTagRow &&
          other.transactionId == this.transactionId &&
          other.tagId == this.tagId &&
          other.position == this.position);
}

class TransactionTagsCompanion extends UpdateCompanion<TransactionTagRow> {
  final Value<String> transactionId;
  final Value<String> tagId;
  final Value<int> position;
  final Value<int> rowid;
  const TransactionTagsCompanion({
    this.transactionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTagsCompanion.insert({
    required String transactionId,
    required String tagId,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId),
       tagId = Value(tagId);
  static Insertable<TransactionTagRow> custom({
    Expression<String>? transactionId,
    Expression<String>? tagId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (tagId != null) 'tag_id': tagId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTagsCompanion copyWith({
    Value<String>? transactionId,
    Value<String>? tagId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TransactionTagsCompanion(
      transactionId: transactionId ?? this.transactionId,
      tagId: tagId ?? this.tagId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    check: () => ComparableExpr(sizeBytes).isBetweenValues(0, 10 * 1024 * 1024),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    fileName,
    mimeType,
    sizeBytes,
    sha256,
    data,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String id;
  final String transactionId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  final Uint8List data;
  final String createdAt;
  const AttachmentRow({
    required this.id,
    required this.transactionId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    required this.data,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['sha256'] = Variable<String>(sha256);
    map['data'] = Variable<Uint8List>(data);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      sha256: Value(sha256),
      data: Value(data),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      data: serializer.fromJson<Uint8List>(json['data']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sha256': serializer.toJson<String>(sha256),
      'data': serializer.toJson<Uint8List>(data),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  AttachmentRow copyWith({
    String? id,
    String? transactionId,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    String? sha256,
    Uint8List? data,
    String? createdAt,
  }) => AttachmentRow(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256 ?? this.sha256,
    data: data ?? this.data,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    fileName,
    mimeType,
    sizeBytes,
    sha256,
    $driftBlobEquality.hash(data),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          $driftBlobEquality.equals(other.data, this.data) &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String> sha256;
  final Value<Uint8List> data;
  final Value<String> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String transactionId,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    required String sha256,
    required Uint8List data,
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       sha256 = Value(sha256),
       data = Value(data),
       createdAt = Value(createdAt);
  static Insertable<AttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<Uint8List>? data,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String>? sha256,
    Value<Uint8List>? data,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _limitCentsMeta = const VerificationMeta(
    'limitCents',
  );
  @override
  late final GeneratedColumn<int> limitCents = GeneratedColumn<int>(
    'limit_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(limitCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rolloverMeta = const VerificationMeta(
    'rollover',
  );
  @override
  late final GeneratedColumn<bool> rollover = GeneratedColumn<bool>(
    'rollover',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rollover" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _validFromMeta = const VerificationMeta(
    'validFrom',
  );
  @override
  late final GeneratedColumn<String> validFrom = GeneratedColumn<String>(
    'valid_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta(
    'validUntil',
  );
  @override
  late final GeneratedColumn<String> validUntil = GeneratedColumn<String>(
    'valid_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    categoryId,
    limitCents,
    month,
    rollover,
    validFrom,
    validUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('limit_cents')) {
      context.handle(
        _limitCentsMeta,
        limitCents.isAcceptableOrUnknown(data['limit_cents']!, _limitCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_limitCentsMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    }
    if (data.containsKey('rollover')) {
      context.handle(
        _rolloverMeta,
        rollover.isAcceptableOrUnknown(data['rollover']!, _rolloverMeta),
      );
    }
    if (data.containsKey('valid_from')) {
      context.handle(
        _validFromMeta,
        validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta),
      );
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      limitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_cents'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      ),
      rollover: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rollover'],
      )!,
      validFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_from'],
      ),
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_until'],
      ),
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String? categoryId;
  final int limitCents;
  final String? month;
  final bool rollover;
  final String? validFrom;
  final String? validUntil;
  const BudgetRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    this.categoryId,
    required this.limitCents,
    this.month,
    required this.rollover,
    this.validFrom,
    this.validUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['limit_cents'] = Variable<int>(limitCents);
    if (!nullToAbsent || month != null) {
      map['month'] = Variable<String>(month);
    }
    map['rollover'] = Variable<bool>(rollover);
    if (!nullToAbsent || validFrom != null) {
      map['valid_from'] = Variable<String>(validFrom);
    }
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<String>(validUntil);
    }
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      limitCents: Value(limitCents),
      month: month == null && nullToAbsent
          ? const Value.absent()
          : Value(month),
      rollover: Value(rollover),
      validFrom: validFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(validFrom),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
    );
  }

  factory BudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      limitCents: serializer.fromJson<int>(json['limitCents']),
      month: serializer.fromJson<String?>(json['month']),
      rollover: serializer.fromJson<bool>(json['rollover']),
      validFrom: serializer.fromJson<String?>(json['validFrom']),
      validUntil: serializer.fromJson<String?>(json['validUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String?>(categoryId),
      'limitCents': serializer.toJson<int>(limitCents),
      'month': serializer.toJson<String?>(month),
      'rollover': serializer.toJson<bool>(rollover),
      'validFrom': serializer.toJson<String?>(validFrom),
      'validUntil': serializer.toJson<String?>(validUntil),
    };
  }

  BudgetRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    Value<String?> categoryId = const Value.absent(),
    int? limitCents,
    Value<String?> month = const Value.absent(),
    bool? rollover,
    Value<String?> validFrom = const Value.absent(),
    Value<String?> validUntil = const Value.absent(),
  }) => BudgetRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    limitCents: limitCents ?? this.limitCents,
    month: month.present ? month.value : this.month,
    rollover: rollover ?? this.rollover,
    validFrom: validFrom.present ? validFrom.value : this.validFrom,
    validUntil: validUntil.present ? validUntil.value : this.validUntil,
  );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      limitCents: data.limitCents.present
          ? data.limitCents.value
          : this.limitCents,
      month: data.month.present ? data.month.value : this.month,
      rollover: data.rollover.present ? data.rollover.value : this.rollover,
      validFrom: data.validFrom.present ? data.validFrom.value : this.validFrom,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitCents: $limitCents, ')
          ..write('month: $month, ')
          ..write('rollover: $rollover, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    categoryId,
    limitCents,
    month,
    rollover,
    validFrom,
    validUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.limitCents == this.limitCents &&
          other.month == this.month &&
          other.rollover == this.rollover &&
          other.validFrom == this.validFrom &&
          other.validUntil == this.validUntil);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String?> categoryId;
  final Value<int> limitCents;
  final Value<String?> month;
  final Value<bool> rollover;
  final Value<String?> validFrom;
  final Value<String?> validUntil;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.limitCents = const Value.absent(),
    this.month = const Value.absent(),
    this.rollover = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    this.categoryId = const Value.absent(),
    required int limitCents,
    this.month = const Value.absent(),
    this.rollover = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       limitCents = Value(limitCents);
  static Insertable<BudgetRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<int>? limitCents,
    Expression<String>? month,
    Expression<bool>? rollover,
    Expression<String>? validFrom,
    Expression<String>? validUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (limitCents != null) 'limit_cents': limitCents,
      if (month != null) 'month': month,
      if (rollover != null) 'rollover': rollover,
      if (validFrom != null) 'valid_from': validFrom,
      if (validUntil != null) 'valid_until': validUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String?>? categoryId,
    Value<int>? limitCents,
    Value<String?>? month,
    Value<bool>? rollover,
    Value<String?>? validFrom,
    Value<String?>? validUntil,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitCents: limitCents ?? this.limitCents,
      month: month ?? this.month,
      rollover: rollover ?? this.rollover,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (limitCents.present) {
      map['limit_cents'] = Variable<int>(limitCents.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (rollover.present) {
      map['rollover'] = Variable<bool>(rollover.value);
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<String>(validFrom.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<String>(validUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitCents: $limitCents, ')
          ..write('month: $month, ')
          ..write('rollover: $rollover, ')
          ..write('validFrom: $validFrom, ')
          ..write('validUntil: $validUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceRulesTable extends RecurrenceRules
    with TableInfo<$RecurrenceRulesTable, RecurrenceRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    check: () => frequency.isIn([
      'daily',
      'weekly',
      'biweekly',
      'monthly',
      'bimonthly',
      'quarterly',
      'semiannual',
      'yearly',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorDayMeta = const VerificationMeta(
    'anchorDay',
  );
  @override
  late final GeneratedColumn<int> anchorDay = GeneratedColumn<int>(
    'anchor_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateTransactionIdMeta =
      const VerificationMeta('templateTransactionId');
  @override
  late final GeneratedColumn<String> templateTransactionId =
      GeneratedColumn<String>(
        'template_transaction_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id)',
        ),
      );
  static const VerificationMeta _lastGeneratedMeta = const VerificationMeta(
    'lastGenerated',
  );
  @override
  late final GeneratedColumn<String> lastGenerated = GeneratedColumn<String>(
    'last_generated',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    frequency,
    anchorDay,
    startDate,
    endDate,
    count,
    templateTransactionId,
    lastGenerated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurrenceRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('anchor_day')) {
      context.handle(
        _anchorDayMeta,
        anchorDay.isAcceptableOrUnknown(data['anchor_day']!, _anchorDayMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('template_transaction_id')) {
      context.handle(
        _templateTransactionIdMeta,
        templateTransactionId.isAcceptableOrUnknown(
          data['template_transaction_id']!,
          _templateTransactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateTransactionIdMeta);
    }
    if (data.containsKey('last_generated')) {
      context.handle(
        _lastGeneratedMeta,
        lastGenerated.isAcceptableOrUnknown(
          data['last_generated']!,
          _lastGeneratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrenceRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceRuleRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      anchorDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_day'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      ),
      templateTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_transaction_id'],
      )!,
      lastGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_generated'],
      ),
    );
  }

  @override
  $RecurrenceRulesTable createAlias(String alias) {
    return $RecurrenceRulesTable(attachedDatabase, alias);
  }
}

class RecurrenceRuleRow extends DataClass
    implements Insertable<RecurrenceRuleRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String frequency;
  final int? anchorDay;
  final String startDate;
  final String? endDate;
  final int? count;

  /// Transaction used as template for each occurrence (same as the RN app's `templateTransactionId`).
  final String templateTransactionId;
  final String? lastGenerated;
  const RecurrenceRuleRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    required this.frequency,
    this.anchorDay,
    required this.startDate,
    this.endDate,
    this.count,
    required this.templateTransactionId,
    this.lastGenerated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || anchorDay != null) {
      map['anchor_day'] = Variable<int>(anchorDay);
    }
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || count != null) {
      map['count'] = Variable<int>(count);
    }
    map['template_transaction_id'] = Variable<String>(templateTransactionId);
    if (!nullToAbsent || lastGenerated != null) {
      map['last_generated'] = Variable<String>(lastGenerated);
    }
    return map;
  }

  RecurrenceRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceRulesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      frequency: Value(frequency),
      anchorDay: anchorDay == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorDay),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      count: count == null && nullToAbsent
          ? const Value.absent()
          : Value(count),
      templateTransactionId: Value(templateTransactionId),
      lastGenerated: lastGenerated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGenerated),
    );
  }

  factory RecurrenceRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceRuleRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      frequency: serializer.fromJson<String>(json['frequency']),
      anchorDay: serializer.fromJson<int?>(json['anchorDay']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      count: serializer.fromJson<int?>(json['count']),
      templateTransactionId: serializer.fromJson<String>(
        json['templateTransactionId'],
      ),
      lastGenerated: serializer.fromJson<String?>(json['lastGenerated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'frequency': serializer.toJson<String>(frequency),
      'anchorDay': serializer.toJson<int?>(anchorDay),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'count': serializer.toJson<int?>(count),
      'templateTransactionId': serializer.toJson<String>(templateTransactionId),
      'lastGenerated': serializer.toJson<String?>(lastGenerated),
    };
  }

  RecurrenceRuleRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? frequency,
    Value<int?> anchorDay = const Value.absent(),
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    Value<int?> count = const Value.absent(),
    String? templateTransactionId,
    Value<String?> lastGenerated = const Value.absent(),
  }) => RecurrenceRuleRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    frequency: frequency ?? this.frequency,
    anchorDay: anchorDay.present ? anchorDay.value : this.anchorDay,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    count: count.present ? count.value : this.count,
    templateTransactionId: templateTransactionId ?? this.templateTransactionId,
    lastGenerated: lastGenerated.present
        ? lastGenerated.value
        : this.lastGenerated,
  );
  RecurrenceRuleRow copyWithCompanion(RecurrenceRulesCompanion data) {
    return RecurrenceRuleRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      anchorDay: data.anchorDay.present ? data.anchorDay.value : this.anchorDay,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      count: data.count.present ? data.count.value : this.count,
      templateTransactionId: data.templateTransactionId.present
          ? data.templateTransactionId.value
          : this.templateTransactionId,
      lastGenerated: data.lastGenerated.present
          ? data.lastGenerated.value
          : this.lastGenerated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRuleRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('frequency: $frequency, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('count: $count, ')
          ..write('templateTransactionId: $templateTransactionId, ')
          ..write('lastGenerated: $lastGenerated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    frequency,
    anchorDay,
    startDate,
    endDate,
    count,
    templateTransactionId,
    lastGenerated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceRuleRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.frequency == this.frequency &&
          other.anchorDay == this.anchorDay &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.count == this.count &&
          other.templateTransactionId == this.templateTransactionId &&
          other.lastGenerated == this.lastGenerated);
}

class RecurrenceRulesCompanion extends UpdateCompanion<RecurrenceRuleRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> frequency;
  final Value<int?> anchorDay;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<int?> count;
  final Value<String> templateTransactionId;
  final Value<String?> lastGenerated;
  final Value<int> rowid;
  const RecurrenceRulesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.frequency = const Value.absent(),
    this.anchorDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.count = const Value.absent(),
    this.templateTransactionId = const Value.absent(),
    this.lastGenerated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurrenceRulesCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String frequency,
    this.anchorDay = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
    this.count = const Value.absent(),
    required String templateTransactionId,
    this.lastGenerated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       frequency = Value(frequency),
       startDate = Value(startDate),
       templateTransactionId = Value(templateTransactionId);
  static Insertable<RecurrenceRuleRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? frequency,
    Expression<int>? anchorDay,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? count,
    Expression<String>? templateTransactionId,
    Expression<String>? lastGenerated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (frequency != null) 'frequency': frequency,
      if (anchorDay != null) 'anchor_day': anchorDay,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (count != null) 'count': count,
      if (templateTransactionId != null)
        'template_transaction_id': templateTransactionId,
      if (lastGenerated != null) 'last_generated': lastGenerated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurrenceRulesCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? frequency,
    Value<int?>? anchorDay,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<int?>? count,
    Value<String>? templateTransactionId,
    Value<String?>? lastGenerated,
    Value<int>? rowid,
  }) {
    return RecurrenceRulesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      anchorDay: anchorDay ?? this.anchorDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      count: count ?? this.count,
      templateTransactionId:
          templateTransactionId ?? this.templateTransactionId,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (anchorDay.present) {
      map['anchor_day'] = Variable<int>(anchorDay.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (templateTransactionId.present) {
      map['template_transaction_id'] = Variable<String>(
        templateTransactionId.value,
      );
    }
    if (lastGenerated.present) {
      map['last_generated'] = Variable<String>(lastGenerated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRulesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('frequency: $frequency, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('count: $count, ')
          ..write('templateTransactionId: $templateTransactionId, ')
          ..write('lastGenerated: $lastGenerated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListsTable extends ShoppingLists
    with TableInfo<$ShoppingListsTable, ShoppingListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeMeta = const VerificationMeta('store');
  @override
  late final GeneratedColumn<String> store = GeneratedColumn<String>(
    'store',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetCentsMeta = const VerificationMeta(
    'budgetCents',
  );
  @override
  late final GeneratedColumn<int> budgetCents = GeneratedColumn<int>(
    'budget_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastCompletedAtMeta = const VerificationMeta(
    'lastCompletedAt',
  );
  @override
  late final GeneratedColumn<String> lastCompletedAt = GeneratedColumn<String>(
    'last_completed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shareTokenMeta = const VerificationMeta(
    'shareToken',
  );
  @override
  late final GeneratedColumn<String> shareToken = GeneratedColumn<String>(
    'share_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    store,
    budgetCents,
    archived,
    lastCompletedAt,
    shareToken,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingListRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('store')) {
      context.handle(
        _storeMeta,
        store.isAcceptableOrUnknown(data['store']!, _storeMeta),
      );
    }
    if (data.containsKey('budget_cents')) {
      context.handle(
        _budgetCentsMeta,
        budgetCents.isAcceptableOrUnknown(
          data['budget_cents']!,
          _budgetCentsMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('last_completed_at')) {
      context.handle(
        _lastCompletedAtMeta,
        lastCompletedAt.isAcceptableOrUnknown(
          data['last_completed_at']!,
          _lastCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('share_token')) {
      context.handle(
        _shareTokenMeta,
        shareToken.isAcceptableOrUnknown(data['share_token']!, _shareTokenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      store: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store'],
      ),
      budgetCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_cents'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      lastCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_completed_at'],
      ),
      shareToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_token'],
      ),
    );
  }

  @override
  $ShoppingListsTable createAlias(String alias) {
    return $ShoppingListsTable(attachedDatabase, alias);
  }
}

class ShoppingListRow extends DataClass implements Insertable<ShoppingListRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String name;
  final String? store;
  final int? budgetCents;
  final bool archived;
  final String? lastCompletedAt;
  final String? shareToken;
  const ShoppingListRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    required this.name,
    this.store,
    this.budgetCents,
    required this.archived,
    this.lastCompletedAt,
    this.shareToken,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || store != null) {
      map['store'] = Variable<String>(store);
    }
    if (!nullToAbsent || budgetCents != null) {
      map['budget_cents'] = Variable<int>(budgetCents);
    }
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || lastCompletedAt != null) {
      map['last_completed_at'] = Variable<String>(lastCompletedAt);
    }
    if (!nullToAbsent || shareToken != null) {
      map['share_token'] = Variable<String>(shareToken);
    }
    return map;
  }

  ShoppingListsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      store: store == null && nullToAbsent
          ? const Value.absent()
          : Value(store),
      budgetCents: budgetCents == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetCents),
      archived: Value(archived),
      lastCompletedAt: lastCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedAt),
      shareToken: shareToken == null && nullToAbsent
          ? const Value.absent()
          : Value(shareToken),
    );
  }

  factory ShoppingListRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      store: serializer.fromJson<String?>(json['store']),
      budgetCents: serializer.fromJson<int?>(json['budgetCents']),
      archived: serializer.fromJson<bool>(json['archived']),
      lastCompletedAt: serializer.fromJson<String?>(json['lastCompletedAt']),
      shareToken: serializer.fromJson<String?>(json['shareToken']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'store': serializer.toJson<String?>(store),
      'budgetCents': serializer.toJson<int?>(budgetCents),
      'archived': serializer.toJson<bool>(archived),
      'lastCompletedAt': serializer.toJson<String?>(lastCompletedAt),
      'shareToken': serializer.toJson<String?>(shareToken),
    };
  }

  ShoppingListRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? name,
    Value<String?> store = const Value.absent(),
    Value<int?> budgetCents = const Value.absent(),
    bool? archived,
    Value<String?> lastCompletedAt = const Value.absent(),
    Value<String?> shareToken = const Value.absent(),
  }) => ShoppingListRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    store: store.present ? store.value : this.store,
    budgetCents: budgetCents.present ? budgetCents.value : this.budgetCents,
    archived: archived ?? this.archived,
    lastCompletedAt: lastCompletedAt.present
        ? lastCompletedAt.value
        : this.lastCompletedAt,
    shareToken: shareToken.present ? shareToken.value : this.shareToken,
  );
  ShoppingListRow copyWithCompanion(ShoppingListsCompanion data) {
    return ShoppingListRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      store: data.store.present ? data.store.value : this.store,
      budgetCents: data.budgetCents.present
          ? data.budgetCents.value
          : this.budgetCents,
      archived: data.archived.present ? data.archived.value : this.archived,
      lastCompletedAt: data.lastCompletedAt.present
          ? data.lastCompletedAt.value
          : this.lastCompletedAt,
      shareToken: data.shareToken.present
          ? data.shareToken.value
          : this.shareToken,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('store: $store, ')
          ..write('budgetCents: $budgetCents, ')
          ..write('archived: $archived, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('shareToken: $shareToken')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    store,
    budgetCents,
    archived,
    lastCompletedAt,
    shareToken,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.store == this.store &&
          other.budgetCents == this.budgetCents &&
          other.archived == this.archived &&
          other.lastCompletedAt == this.lastCompletedAt &&
          other.shareToken == this.shareToken);
}

class ShoppingListsCompanion extends UpdateCompanion<ShoppingListRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> store;
  final Value<int?> budgetCents;
  final Value<bool> archived;
  final Value<String?> lastCompletedAt;
  final Value<String?> shareToken;
  final Value<int> rowid;
  const ShoppingListsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.store = const Value.absent(),
    this.budgetCents = const Value.absent(),
    this.archived = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.shareToken = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String name,
    this.store = const Value.absent(),
    this.budgetCents = const Value.absent(),
    this.archived = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.shareToken = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name);
  static Insertable<ShoppingListRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? store,
    Expression<int>? budgetCents,
    Expression<bool>? archived,
    Expression<String>? lastCompletedAt,
    Expression<String>? shareToken,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (store != null) 'store': store,
      if (budgetCents != null) 'budget_cents': budgetCents,
      if (archived != null) 'archived': archived,
      if (lastCompletedAt != null) 'last_completed_at': lastCompletedAt,
      if (shareToken != null) 'share_token': shareToken,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? store,
    Value<int?>? budgetCents,
    Value<bool>? archived,
    Value<String?>? lastCompletedAt,
    Value<String?>? shareToken,
    Value<int>? rowid,
  }) {
    return ShoppingListsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      store: store ?? this.store,
      budgetCents: budgetCents ?? this.budgetCents,
      archived: archived ?? this.archived,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      shareToken: shareToken ?? this.shareToken,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (store.present) {
      map['store'] = Variable<String>(store.value);
    }
    if (budgetCents.present) {
      map['budget_cents'] = Variable<int>(budgetCents.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (lastCompletedAt.present) {
      map['last_completed_at'] = Variable<String>(lastCompletedAt.value);
    }
    if (shareToken.present) {
      map['share_token'] = Variable<String>(shareToken.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('store: $store, ')
          ..write('budgetCents: $budgetCents, ')
          ..write('archived: $archived, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('shareToken: $shareToken, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListItemsTable extends ShoppingListItems
    with TableInfo<$ShoppingListItemsTable, ShoppingListItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shopping_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    check: () => ComparableExpr(quantity).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedUnitPriceCentsMeta =
      const VerificationMeta('estimatedUnitPriceCents');
  @override
  late final GeneratedColumn<int> estimatedUnitPriceCents =
      GeneratedColumn<int>(
        'estimated_unit_price_cents',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _estimateSourceMeta = const VerificationMeta(
    'estimateSource',
  );
  @override
  late final GeneratedColumn<String> estimateSource = GeneratedColumn<String>(
    'estimate_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkedMeta = const VerificationMeta(
    'checked',
  );
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
    'checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    name,
    brand,
    category,
    unit,
    quantity,
    estimatedUnitPriceCents,
    estimateSource,
    productId,
    barcode,
    checked,
    note,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingListItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('estimated_unit_price_cents')) {
      context.handle(
        _estimatedUnitPriceCentsMeta,
        estimatedUnitPriceCents.isAcceptableOrUnknown(
          data['estimated_unit_price_cents']!,
          _estimatedUnitPriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('estimate_source')) {
      context.handle(
        _estimateSourceMeta,
        estimateSource.isAcceptableOrUnknown(
          data['estimate_source']!,
          _estimateSourceMeta,
        ),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('checked')) {
      context.handle(
        _checkedMeta,
        checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      estimatedUnitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_unit_price_cents'],
      ),
      estimateSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estimate_source'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      checked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}checked'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ShoppingListItemsTable createAlias(String alias) {
    return $ShoppingListItemsTable(attachedDatabase, alias);
  }
}

class ShoppingListItemRow extends DataClass
    implements Insertable<ShoppingListItemRow> {
  final String id;
  final String listId;
  final String name;
  final String? brand;
  final String? category;
  final String unit;
  final double quantity;
  final int? estimatedUnitPriceCents;
  final String? estimateSource;
  final String? productId;
  final String? barcode;
  final bool checked;
  final String? note;
  final int sortOrder;
  const ShoppingListItemRow({
    required this.id,
    required this.listId,
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['unit'] = Variable<String>(unit);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || estimatedUnitPriceCents != null) {
      map['estimated_unit_price_cents'] = Variable<int>(
        estimatedUnitPriceCents,
      );
    }
    if (!nullToAbsent || estimateSource != null) {
      map['estimate_source'] = Variable<String>(estimateSource);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['checked'] = Variable<bool>(checked);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ShoppingListItemsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      unit: Value(unit),
      quantity: Value(quantity),
      estimatedUnitPriceCents: estimatedUnitPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedUnitPriceCents),
      estimateSource: estimateSource == null && nullToAbsent
          ? const Value.absent()
          : Value(estimateSource),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      checked: Value(checked),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      sortOrder: Value(sortOrder),
    );
  }

  factory ShoppingListItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListItemRow(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String?>(json['category']),
      unit: serializer.fromJson<String>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      estimatedUnitPriceCents: serializer.fromJson<int?>(
        json['estimatedUnitPriceCents'],
      ),
      estimateSource: serializer.fromJson<String?>(json['estimateSource']),
      productId: serializer.fromJson<String?>(json['productId']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      checked: serializer.fromJson<bool>(json['checked']),
      note: serializer.fromJson<String?>(json['note']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String?>(category),
      'unit': serializer.toJson<String>(unit),
      'quantity': serializer.toJson<double>(quantity),
      'estimatedUnitPriceCents': serializer.toJson<int?>(
        estimatedUnitPriceCents,
      ),
      'estimateSource': serializer.toJson<String?>(estimateSource),
      'productId': serializer.toJson<String?>(productId),
      'barcode': serializer.toJson<String?>(barcode),
      'checked': serializer.toJson<bool>(checked),
      'note': serializer.toJson<String?>(note),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ShoppingListItemRow copyWith({
    String? id,
    String? listId,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? unit,
    double? quantity,
    Value<int?> estimatedUnitPriceCents = const Value.absent(),
    Value<String?> estimateSource = const Value.absent(),
    Value<String?> productId = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    bool? checked,
    Value<String?> note = const Value.absent(),
    int? sortOrder,
  }) => ShoppingListItemRow(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    category: category.present ? category.value : this.category,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    estimatedUnitPriceCents: estimatedUnitPriceCents.present
        ? estimatedUnitPriceCents.value
        : this.estimatedUnitPriceCents,
    estimateSource: estimateSource.present
        ? estimateSource.value
        : this.estimateSource,
    productId: productId.present ? productId.value : this.productId,
    barcode: barcode.present ? barcode.value : this.barcode,
    checked: checked ?? this.checked,
    note: note.present ? note.value : this.note,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ShoppingListItemRow copyWithCompanion(ShoppingListItemsCompanion data) {
    return ShoppingListItemRow(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      estimatedUnitPriceCents: data.estimatedUnitPriceCents.present
          ? data.estimatedUnitPriceCents.value
          : this.estimatedUnitPriceCents,
      estimateSource: data.estimateSource.present
          ? data.estimateSource.value
          : this.estimateSource,
      productId: data.productId.present ? data.productId.value : this.productId,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      checked: data.checked.present ? data.checked.value : this.checked,
      note: data.note.present ? data.note.value : this.note,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListItemRow(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('estimatedUnitPriceCents: $estimatedUnitPriceCents, ')
          ..write('estimateSource: $estimateSource, ')
          ..write('productId: $productId, ')
          ..write('barcode: $barcode, ')
          ..write('checked: $checked, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    name,
    brand,
    category,
    unit,
    quantity,
    estimatedUnitPriceCents,
    estimateSource,
    productId,
    barcode,
    checked,
    note,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListItemRow &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.quantity == this.quantity &&
          other.estimatedUnitPriceCents == this.estimatedUnitPriceCents &&
          other.estimateSource == this.estimateSource &&
          other.productId == this.productId &&
          other.barcode == this.barcode &&
          other.checked == this.checked &&
          other.note == this.note &&
          other.sortOrder == this.sortOrder);
}

class ShoppingListItemsCompanion extends UpdateCompanion<ShoppingListItemRow> {
  final Value<String> id;
  final Value<String> listId;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> category;
  final Value<String> unit;
  final Value<double> quantity;
  final Value<int?> estimatedUnitPriceCents;
  final Value<String?> estimateSource;
  final Value<String?> productId;
  final Value<String?> barcode;
  final Value<bool> checked;
  final Value<String?> note;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ShoppingListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.estimatedUnitPriceCents = const Value.absent(),
    this.estimateSource = const Value.absent(),
    this.productId = const Value.absent(),
    this.barcode = const Value.absent(),
    this.checked = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListItemsCompanion.insert({
    required String id,
    required String listId,
    required String name,
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    required String unit,
    required double quantity,
    this.estimatedUnitPriceCents = const Value.absent(),
    this.estimateSource = const Value.absent(),
    this.productId = const Value.absent(),
    this.barcode = const Value.absent(),
    this.checked = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       listId = Value(listId),
       name = Value(name),
       unit = Value(unit),
       quantity = Value(quantity);
  static Insertable<ShoppingListItemRow> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<double>? quantity,
    Expression<int>? estimatedUnitPriceCents,
    Expression<String>? estimateSource,
    Expression<String>? productId,
    Expression<String>? barcode,
    Expression<bool>? checked,
    Expression<String>? note,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (estimatedUnitPriceCents != null)
        'estimated_unit_price_cents': estimatedUnitPriceCents,
      if (estimateSource != null) 'estimate_source': estimateSource,
      if (productId != null) 'product_id': productId,
      if (barcode != null) 'barcode': barcode,
      if (checked != null) 'checked': checked,
      if (note != null) 'note': note,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? listId,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? category,
    Value<String>? unit,
    Value<double>? quantity,
    Value<int?>? estimatedUnitPriceCents,
    Value<String?>? estimateSource,
    Value<String?>? productId,
    Value<String?>? barcode,
    Value<bool>? checked,
    Value<String?>? note,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ShoppingListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (estimatedUnitPriceCents.present) {
      map['estimated_unit_price_cents'] = Variable<int>(
        estimatedUnitPriceCents.value,
      );
    }
    if (estimateSource.present) {
      map['estimate_source'] = Variable<String>(estimateSource.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('estimatedUnitPriceCents: $estimatedUnitPriceCents, ')
          ..write('estimateSource: $estimateSource, ')
          ..write('productId: $productId, ')
          ..write('barcode: $barcode, ')
          ..write('checked: $checked, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultUnitMeta = const VerificationMeta(
    'defaultUnit',
  );
  @override
  late final GeneratedColumn<String> defaultUnit = GeneratedColumn<String>(
    'default_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presentationQuantityMeta =
      const VerificationMeta('presentationQuantity');
  @override
  late final GeneratedColumn<double> presentationQuantity =
      GeneratedColumn<double>(
        'presentation_quantity',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _presentationUnitMeta = const VerificationMeta(
    'presentationUnit',
  );
  @override
  late final GeneratedColumn<String> presentationUnit = GeneratedColumn<String>(
    'presentation_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    brand,
    barcode,
    defaultUnit,
    presentationQuantity,
    presentationUnit,
    category,
    favorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('default_unit')) {
      context.handle(
        _defaultUnitMeta,
        defaultUnit.isAcceptableOrUnknown(
          data['default_unit']!,
          _defaultUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultUnitMeta);
    }
    if (data.containsKey('presentation_quantity')) {
      context.handle(
        _presentationQuantityMeta,
        presentationQuantity.isAcceptableOrUnknown(
          data['presentation_quantity']!,
          _presentationQuantityMeta,
        ),
      );
    }
    if (data.containsKey('presentation_unit')) {
      context.handle(
        _presentationUnitMeta,
        presentationUnit.isAcceptableOrUnknown(
          data['presentation_unit']!,
          _presentationUnitMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      defaultUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_unit'],
      )!,
      presentationQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}presentation_quantity'],
      ),
      presentationUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presentation_unit'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String name;
  final String? brand;
  final String? barcode;
  final String defaultUnit;
  final double? presentationQuantity;
  final String? presentationUnit;
  final String? category;
  final bool favorite;
  const ProductRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    required this.defaultUnit,
    this.presentationQuantity,
    this.presentationUnit,
    this.category,
    required this.favorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['default_unit'] = Variable<String>(defaultUnit);
    if (!nullToAbsent || presentationQuantity != null) {
      map['presentation_quantity'] = Variable<double>(presentationQuantity);
    }
    if (!nullToAbsent || presentationUnit != null) {
      map['presentation_unit'] = Variable<String>(presentationUnit);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['favorite'] = Variable<bool>(favorite);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      defaultUnit: Value(defaultUnit),
      presentationQuantity: presentationQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(presentationQuantity),
      presentationUnit: presentationUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(presentationUnit),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      favorite: Value(favorite),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      defaultUnit: serializer.fromJson<String>(json['defaultUnit']),
      presentationQuantity: serializer.fromJson<double?>(
        json['presentationQuantity'],
      ),
      presentationUnit: serializer.fromJson<String?>(json['presentationUnit']),
      category: serializer.fromJson<String?>(json['category']),
      favorite: serializer.fromJson<bool>(json['favorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'barcode': serializer.toJson<String?>(barcode),
      'defaultUnit': serializer.toJson<String>(defaultUnit),
      'presentationQuantity': serializer.toJson<double?>(presentationQuantity),
      'presentationUnit': serializer.toJson<String?>(presentationUnit),
      'category': serializer.toJson<String?>(category),
      'favorite': serializer.toJson<bool>(favorite),
    };
  }

  ProductRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? defaultUnit,
    Value<double?> presentationQuantity = const Value.absent(),
    Value<String?> presentationUnit = const Value.absent(),
    Value<String?> category = const Value.absent(),
    bool? favorite,
  }) => ProductRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    barcode: barcode.present ? barcode.value : this.barcode,
    defaultUnit: defaultUnit ?? this.defaultUnit,
    presentationQuantity: presentationQuantity.present
        ? presentationQuantity.value
        : this.presentationQuantity,
    presentationUnit: presentationUnit.present
        ? presentationUnit.value
        : this.presentationUnit,
    category: category.present ? category.value : this.category,
    favorite: favorite ?? this.favorite,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      defaultUnit: data.defaultUnit.present
          ? data.defaultUnit.value
          : this.defaultUnit,
      presentationQuantity: data.presentationQuantity.present
          ? data.presentationQuantity.value
          : this.presentationQuantity,
      presentationUnit: data.presentationUnit.present
          ? data.presentationUnit.value
          : this.presentationUnit,
      category: data.category.present ? data.category.value : this.category,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('defaultUnit: $defaultUnit, ')
          ..write('presentationQuantity: $presentationQuantity, ')
          ..write('presentationUnit: $presentationUnit, ')
          ..write('category: $category, ')
          ..write('favorite: $favorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    name,
    brand,
    barcode,
    defaultUnit,
    presentationQuantity,
    presentationUnit,
    category,
    favorite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.barcode == this.barcode &&
          other.defaultUnit == this.defaultUnit &&
          other.presentationQuantity == this.presentationQuantity &&
          other.presentationUnit == this.presentationUnit &&
          other.category == this.category &&
          other.favorite == this.favorite);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> barcode;
  final Value<String> defaultUnit;
  final Value<double?> presentationQuantity;
  final Value<String?> presentationUnit;
  final Value<String?> category;
  final Value<bool> favorite;
  final Value<int> rowid;
  const ProductsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    this.defaultUnit = const Value.absent(),
    this.presentationQuantity = const Value.absent(),
    this.presentationUnit = const Value.absent(),
    this.category = const Value.absent(),
    this.favorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String name,
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    required String defaultUnit,
    this.presentationQuantity = const Value.absent(),
    this.presentationUnit = const Value.absent(),
    this.category = const Value.absent(),
    this.favorite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       defaultUnit = Value(defaultUnit);
  static Insertable<ProductRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? barcode,
    Expression<String>? defaultUnit,
    Expression<double>? presentationQuantity,
    Expression<String>? presentationUnit,
    Expression<String>? category,
    Expression<bool>? favorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (barcode != null) 'barcode': barcode,
      if (defaultUnit != null) 'default_unit': defaultUnit,
      if (presentationQuantity != null)
        'presentation_quantity': presentationQuantity,
      if (presentationUnit != null) 'presentation_unit': presentationUnit,
      if (category != null) 'category': category,
      if (favorite != null) 'favorite': favorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? barcode,
    Value<String>? defaultUnit,
    Value<double?>? presentationQuantity,
    Value<String?>? presentationUnit,
    Value<String?>? category,
    Value<bool>? favorite,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      presentationQuantity: presentationQuantity ?? this.presentationQuantity,
      presentationUnit: presentationUnit ?? this.presentationUnit,
      category: category ?? this.category,
      favorite: favorite ?? this.favorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (defaultUnit.present) {
      map['default_unit'] = Variable<String>(defaultUnit.value);
    }
    if (presentationQuantity.present) {
      map['presentation_quantity'] = Variable<double>(
        presentationQuantity.value,
      );
    }
    if (presentationUnit.present) {
      map['presentation_unit'] = Variable<String>(presentationUnit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('defaultUnit: $defaultUnit, ')
          ..write('presentationQuantity: $presentationQuantity, ')
          ..write('presentationUnit: $presentationUnit, ')
          ..write('category: $category, ')
          ..write('favorite: $favorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductInternalCodesTable extends ProductInternalCodes
    with TableInfo<$ProductInternalCodesTable, ProductInternalCodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductInternalCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _storeMeta = const VerificationMeta('store');
  @override
  late final GeneratedColumn<String> store = GeneratedColumn<String>(
    'store',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [productId, store, code];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_internal_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductInternalCodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('store')) {
      context.handle(
        _storeMeta,
        store.isAcceptableOrUnknown(data['store']!, _storeMeta),
      );
    } else if (isInserting) {
      context.missing(_storeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId, store, code};
  @override
  ProductInternalCodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductInternalCodeRow(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      store: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
    );
  }

  @override
  $ProductInternalCodesTable createAlias(String alias) {
    return $ProductInternalCodesTable(attachedDatabase, alias);
  }
}

class ProductInternalCodeRow extends DataClass
    implements Insertable<ProductInternalCodeRow> {
  final String productId;
  final String store;
  final String code;
  const ProductInternalCodeRow({
    required this.productId,
    required this.store,
    required this.code,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['store'] = Variable<String>(store);
    map['code'] = Variable<String>(code);
    return map;
  }

  ProductInternalCodesCompanion toCompanion(bool nullToAbsent) {
    return ProductInternalCodesCompanion(
      productId: Value(productId),
      store: Value(store),
      code: Value(code),
    );
  }

  factory ProductInternalCodeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductInternalCodeRow(
      productId: serializer.fromJson<String>(json['productId']),
      store: serializer.fromJson<String>(json['store']),
      code: serializer.fromJson<String>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'store': serializer.toJson<String>(store),
      'code': serializer.toJson<String>(code),
    };
  }

  ProductInternalCodeRow copyWith({
    String? productId,
    String? store,
    String? code,
  }) => ProductInternalCodeRow(
    productId: productId ?? this.productId,
    store: store ?? this.store,
    code: code ?? this.code,
  );
  ProductInternalCodeRow copyWithCompanion(ProductInternalCodesCompanion data) {
    return ProductInternalCodeRow(
      productId: data.productId.present ? data.productId.value : this.productId,
      store: data.store.present ? data.store.value : this.store,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductInternalCodeRow(')
          ..write('productId: $productId, ')
          ..write('store: $store, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, store, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductInternalCodeRow &&
          other.productId == this.productId &&
          other.store == this.store &&
          other.code == this.code);
}

class ProductInternalCodesCompanion
    extends UpdateCompanion<ProductInternalCodeRow> {
  final Value<String> productId;
  final Value<String> store;
  final Value<String> code;
  final Value<int> rowid;
  const ProductInternalCodesCompanion({
    this.productId = const Value.absent(),
    this.store = const Value.absent(),
    this.code = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductInternalCodesCompanion.insert({
    required String productId,
    required String store,
    required String code,
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       store = Value(store),
       code = Value(code);
  static Insertable<ProductInternalCodeRow> custom({
    Expression<String>? productId,
    Expression<String>? store,
    Expression<String>? code,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (store != null) 'store': store,
      if (code != null) 'code': code,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductInternalCodesCompanion copyWith({
    Value<String>? productId,
    Value<String>? store,
    Value<String>? code,
    Value<int>? rowid,
  }) {
    return ProductInternalCodesCompanion(
      productId: productId ?? this.productId,
      store: store ?? this.store,
      code: code ?? this.code,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (store.present) {
      map['store'] = Variable<String>(store.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductInternalCodesCompanion(')
          ..write('productId: $productId, ')
          ..write('store: $store, ')
          ..write('code: $code, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PriceObservationsTable extends PriceObservations
    with TableInfo<$PriceObservationsTable, PriceObservationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _storeMeta = const VerificationMeta('store');
  @override
  late final GeneratedColumn<String> store = GeneratedColumn<String>(
    'store',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(unitPriceCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedAtMeta = const VerificationMeta(
    'observedAt',
  );
  @override
  late final GeneratedColumn<String> observedAt = GeneratedColumn<String>(
    'observed_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promoMeta = const VerificationMeta('promo');
  @override
  late final GeneratedColumn<bool> promo = GeneratedColumn<bool>(
    'promo',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("promo" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    productId,
    store,
    unit,
    unitPriceCents,
    observedAt,
    source,
    sessionId,
    promo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceObservationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('store')) {
      context.handle(
        _storeMeta,
        store.isAcceptableOrUnknown(data['store']!, _storeMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('observed_at')) {
      context.handle(
        _observedAtMeta,
        observedAt.isAcceptableOrUnknown(data['observed_at']!, _observedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_observedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('promo')) {
      context.handle(
        _promoMeta,
        promo.isAcceptableOrUnknown(data['promo']!, _promoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PriceObservationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceObservationRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      store: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observed_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      promo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}promo'],
      ),
    );
  }

  @override
  $PriceObservationsTable createAlias(String alias) {
    return $PriceObservationsTable(attachedDatabase, alias);
  }
}

class PriceObservationRow extends DataClass
    implements Insertable<PriceObservationRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String productId;
  final String? store;
  final String unit;
  final int unitPriceCents;
  final String observedAt;
  final String source;
  final String? sessionId;
  final bool? promo;
  const PriceObservationRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    required this.productId,
    this.store,
    required this.unit,
    required this.unitPriceCents,
    required this.observedAt,
    required this.source,
    this.sessionId,
    this.promo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    if (!nullToAbsent || store != null) {
      map['store'] = Variable<String>(store);
    }
    map['unit'] = Variable<String>(unit);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['observed_at'] = Variable<String>(observedAt);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    if (!nullToAbsent || promo != null) {
      map['promo'] = Variable<bool>(promo);
    }
    return map;
  }

  PriceObservationsCompanion toCompanion(bool nullToAbsent) {
    return PriceObservationsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      productId: Value(productId),
      store: store == null && nullToAbsent
          ? const Value.absent()
          : Value(store),
      unit: Value(unit),
      unitPriceCents: Value(unitPriceCents),
      observedAt: Value(observedAt),
      source: Value(source),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      promo: promo == null && nullToAbsent
          ? const Value.absent()
          : Value(promo),
    );
  }

  factory PriceObservationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceObservationRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      store: serializer.fromJson<String?>(json['store']),
      unit: serializer.fromJson<String>(json['unit']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      observedAt: serializer.fromJson<String>(json['observedAt']),
      source: serializer.fromJson<String>(json['source']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      promo: serializer.fromJson<bool?>(json['promo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'store': serializer.toJson<String?>(store),
      'unit': serializer.toJson<String>(unit),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'observedAt': serializer.toJson<String>(observedAt),
      'source': serializer.toJson<String>(source),
      'sessionId': serializer.toJson<String?>(sessionId),
      'promo': serializer.toJson<bool?>(promo),
    };
  }

  PriceObservationRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    String? productId,
    Value<String?> store = const Value.absent(),
    String? unit,
    int? unitPriceCents,
    String? observedAt,
    String? source,
    Value<String?> sessionId = const Value.absent(),
    Value<bool?> promo = const Value.absent(),
  }) => PriceObservationRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    productId: productId ?? this.productId,
    store: store.present ? store.value : this.store,
    unit: unit ?? this.unit,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    observedAt: observedAt ?? this.observedAt,
    source: source ?? this.source,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    promo: promo.present ? promo.value : this.promo,
  );
  PriceObservationRow copyWithCompanion(PriceObservationsCompanion data) {
    return PriceObservationRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      store: data.store.present ? data.store.value : this.store,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
      source: data.source.present ? data.source.value : this.source,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      promo: data.promo.present ? data.promo.value : this.promo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceObservationRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('store: $store, ')
          ..write('unit: $unit, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('observedAt: $observedAt, ')
          ..write('source: $source, ')
          ..write('sessionId: $sessionId, ')
          ..write('promo: $promo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    productId,
    store,
    unit,
    unitPriceCents,
    observedAt,
    source,
    sessionId,
    promo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceObservationRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.store == this.store &&
          other.unit == this.unit &&
          other.unitPriceCents == this.unitPriceCents &&
          other.observedAt == this.observedAt &&
          other.source == this.source &&
          other.sessionId == this.sessionId &&
          other.promo == this.promo);
}

class PriceObservationsCompanion extends UpdateCompanion<PriceObservationRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String> productId;
  final Value<String?> store;
  final Value<String> unit;
  final Value<int> unitPriceCents;
  final Value<String> observedAt;
  final Value<String> source;
  final Value<String?> sessionId;
  final Value<bool?> promo;
  final Value<int> rowid;
  const PriceObservationsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.store = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.promo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PriceObservationsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    required String productId,
    this.store = const Value.absent(),
    required String unit,
    required int unitPriceCents,
    required String observedAt,
    required String source,
    this.sessionId = const Value.absent(),
    this.promo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       productId = Value(productId),
       unit = Value(unit),
       unitPriceCents = Value(unitPriceCents),
       observedAt = Value(observedAt),
       source = Value(source);
  static Insertable<PriceObservationRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? store,
    Expression<String>? unit,
    Expression<int>? unitPriceCents,
    Expression<String>? observedAt,
    Expression<String>? source,
    Expression<String>? sessionId,
    Expression<bool>? promo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (store != null) 'store': store,
      if (unit != null) 'unit': unit,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (observedAt != null) 'observed_at': observedAt,
      if (source != null) 'source': source,
      if (sessionId != null) 'session_id': sessionId,
      if (promo != null) 'promo': promo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PriceObservationsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String>? productId,
    Value<String?>? store,
    Value<String>? unit,
    Value<int>? unitPriceCents,
    Value<String>? observedAt,
    Value<String>? source,
    Value<String?>? sessionId,
    Value<bool?>? promo,
    Value<int>? rowid,
  }) {
    return PriceObservationsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      productId: productId ?? this.productId,
      store: store ?? this.store,
      unit: unit ?? this.unit,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      observedAt: observedAt ?? this.observedAt,
      source: source ?? this.source,
      sessionId: sessionId ?? this.sessionId,
      promo: promo ?? this.promo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (store.present) {
      map['store'] = Variable<String>(store.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<String>(observedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (promo.present) {
      map['promo'] = Variable<bool>(promo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceObservationsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('store: $store, ')
          ..write('unit: $unit, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('observedAt: $observedAt, ')
          ..write('source: $source, ')
          ..write('sessionId: $sessionId, ')
          ..write('promo: $promo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingSessionsTable extends ShoppingSessions
    with TableInfo<$ShoppingSessionsTable, ShoppingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeMeta = const VerificationMeta('store');
  @override
  late final GeneratedColumn<String> store = GeneratedColumn<String>(
    'store',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetCentsMeta = const VerificationMeta(
    'budgetCents',
  );
  @override
  late final GeneratedColumn<int> budgetCents = GeneratedColumn<int>(
    'budget_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(['active', 'finished', 'abandoned']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<String> finishedAt = GeneratedColumn<String>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptAccessKeyMeta = const VerificationMeta(
    'receiptAccessKey',
  );
  @override
  late final GeneratedColumn<String> receiptAccessKey = GeneratedColumn<String>(
    'receipt_access_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    store,
    listId,
    budgetCents,
    status,
    startedAt,
    finishedAt,
    transactionId,
    receiptAccessKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store')) {
      context.handle(
        _storeMeta,
        store.isAcceptableOrUnknown(data['store']!, _storeMeta),
      );
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    }
    if (data.containsKey('budget_cents')) {
      context.handle(
        _budgetCentsMeta,
        budgetCents.isAcceptableOrUnknown(
          data['budget_cents']!,
          _budgetCentsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('receipt_access_key')) {
      context.handle(
        _receiptAccessKeyMeta,
        receiptAccessKey.isAcceptableOrUnknown(
          data['receipt_access_key']!,
          _receiptAccessKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingSessionRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      store: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store'],
      ),
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      ),
      budgetCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_cents'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finished_at'],
      ),
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      receiptAccessKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_access_key'],
      ),
    );
  }

  @override
  $ShoppingSessionsTable createAlias(String alias) {
    return $ShoppingSessionsTable(attachedDatabase, alias);
  }
}

class ShoppingSessionRow extends DataClass
    implements Insertable<ShoppingSessionRow> {
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int version;
  final String deviceId;
  final bool dirty;
  final String id;
  final String? store;
  final String? listId;
  final int? budgetCents;
  final String status;
  final String startedAt;
  final String? finishedAt;
  final String? transactionId;
  final String? receiptAccessKey;
  const ShoppingSessionRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.deviceId,
    required this.dirty,
    required this.id,
    this.store,
    this.listId,
    this.budgetCents,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.transactionId,
    this.receiptAccessKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || store != null) {
      map['store'] = Variable<String>(store);
    }
    if (!nullToAbsent || listId != null) {
      map['list_id'] = Variable<String>(listId);
    }
    if (!nullToAbsent || budgetCents != null) {
      map['budget_cents'] = Variable<int>(budgetCents);
    }
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<String>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<String>(finishedAt);
    }
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    if (!nullToAbsent || receiptAccessKey != null) {
      map['receipt_access_key'] = Variable<String>(receiptAccessKey);
    }
    return map;
  }

  ShoppingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingSessionsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      deviceId: Value(deviceId),
      dirty: Value(dirty),
      id: Value(id),
      store: store == null && nullToAbsent
          ? const Value.absent()
          : Value(store),
      listId: listId == null && nullToAbsent
          ? const Value.absent()
          : Value(listId),
      budgetCents: budgetCents == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetCents),
      status: Value(status),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      receiptAccessKey: receiptAccessKey == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptAccessKey),
    );
  }

  factory ShoppingSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingSessionRow(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<String>(json['id']),
      store: serializer.fromJson<String?>(json['store']),
      listId: serializer.fromJson<String?>(json['listId']),
      budgetCents: serializer.fromJson<int?>(json['budgetCents']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      finishedAt: serializer.fromJson<String?>(json['finishedAt']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      receiptAccessKey: serializer.fromJson<String?>(json['receiptAccessKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<String>(id),
      'store': serializer.toJson<String?>(store),
      'listId': serializer.toJson<String?>(listId),
      'budgetCents': serializer.toJson<int?>(budgetCents),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<String>(startedAt),
      'finishedAt': serializer.toJson<String?>(finishedAt),
      'transactionId': serializer.toJson<String?>(transactionId),
      'receiptAccessKey': serializer.toJson<String?>(receiptAccessKey),
    };
  }

  ShoppingSessionRow copyWith({
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    int? version,
    String? deviceId,
    bool? dirty,
    String? id,
    Value<String?> store = const Value.absent(),
    Value<String?> listId = const Value.absent(),
    Value<int?> budgetCents = const Value.absent(),
    String? status,
    String? startedAt,
    Value<String?> finishedAt = const Value.absent(),
    Value<String?> transactionId = const Value.absent(),
    Value<String?> receiptAccessKey = const Value.absent(),
  }) => ShoppingSessionRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    store: store.present ? store.value : this.store,
    listId: listId.present ? listId.value : this.listId,
    budgetCents: budgetCents.present ? budgetCents.value : this.budgetCents,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    receiptAccessKey: receiptAccessKey.present
        ? receiptAccessKey.value
        : this.receiptAccessKey,
  );
  ShoppingSessionRow copyWithCompanion(ShoppingSessionsCompanion data) {
    return ShoppingSessionRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      store: data.store.present ? data.store.value : this.store,
      listId: data.listId.present ? data.listId.value : this.listId,
      budgetCents: data.budgetCents.present
          ? data.budgetCents.value
          : this.budgetCents,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      receiptAccessKey: data.receiptAccessKey.present
          ? data.receiptAccessKey.value
          : this.receiptAccessKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingSessionRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('store: $store, ')
          ..write('listId: $listId, ')
          ..write('budgetCents: $budgetCents, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('transactionId: $transactionId, ')
          ..write('receiptAccessKey: $receiptAccessKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    version,
    deviceId,
    dirty,
    id,
    store,
    listId,
    budgetCents,
    status,
    startedAt,
    finishedAt,
    transactionId,
    receiptAccessKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingSessionRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.store == this.store &&
          other.listId == this.listId &&
          other.budgetCents == this.budgetCents &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.transactionId == this.transactionId &&
          other.receiptAccessKey == this.receiptAccessKey);
}

class ShoppingSessionsCompanion extends UpdateCompanion<ShoppingSessionRow> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<bool> dirty;
  final Value<String> id;
  final Value<String?> store;
  final Value<String?> listId;
  final Value<int?> budgetCents;
  final Value<String> status;
  final Value<String> startedAt;
  final Value<String?> finishedAt;
  final Value<String?> transactionId;
  final Value<String?> receiptAccessKey;
  final Value<int> rowid;
  const ShoppingSessionsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.store = const Value.absent(),
    this.listId = const Value.absent(),
    this.budgetCents = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.receiptAccessKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingSessionsCompanion.insert({
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.dirty = const Value.absent(),
    required String id,
    this.store = const Value.absent(),
    this.listId = const Value.absent(),
    this.budgetCents = const Value.absent(),
    required String status,
    required String startedAt,
    this.finishedAt = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.receiptAccessKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<ShoppingSessionRow> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<bool>? dirty,
    Expression<String>? id,
    Expression<String>? store,
    Expression<String>? listId,
    Expression<int>? budgetCents,
    Expression<String>? status,
    Expression<String>? startedAt,
    Expression<String>? finishedAt,
    Expression<String>? transactionId,
    Expression<String>? receiptAccessKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (store != null) 'store': store,
      if (listId != null) 'list_id': listId,
      if (budgetCents != null) 'budget_cents': budgetCents,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (transactionId != null) 'transaction_id': transactionId,
      if (receiptAccessKey != null) 'receipt_access_key': receiptAccessKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingSessionsCompanion copyWith({
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<int>? version,
    Value<String>? deviceId,
    Value<bool>? dirty,
    Value<String>? id,
    Value<String?>? store,
    Value<String?>? listId,
    Value<int?>? budgetCents,
    Value<String>? status,
    Value<String>? startedAt,
    Value<String?>? finishedAt,
    Value<String?>? transactionId,
    Value<String?>? receiptAccessKey,
    Value<int>? rowid,
  }) {
    return ShoppingSessionsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      store: store ?? this.store,
      listId: listId ?? this.listId,
      budgetCents: budgetCents ?? this.budgetCents,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      transactionId: transactionId ?? this.transactionId,
      receiptAccessKey: receiptAccessKey ?? this.receiptAccessKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (store.present) {
      map['store'] = Variable<String>(store.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (budgetCents.present) {
      map['budget_cents'] = Variable<int>(budgetCents.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<String>(finishedAt.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (receiptAccessKey.present) {
      map['receipt_access_key'] = Variable<String>(receiptAccessKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingSessionsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('store: $store, ')
          ..write('listId: $listId, ')
          ..write('budgetCents: $budgetCents, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('transactionId: $transactionId, ')
          ..write('receiptAccessKey: $receiptAccessKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingSessionLinesTable extends ShoppingSessionLines
    with TableInfo<$ShoppingSessionLinesTable, ShoppingSessionLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingSessionLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shopping_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    check: () => ComparableExpr(quantity).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    check: () => ComparableExpr(unitPriceCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountCentsMeta = const VerificationMeta(
    'discountCents',
  );
  @override
  late final GeneratedColumn<int> discountCents = GeneratedColumn<int>(
    'discount_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountPercentMeta = const VerificationMeta(
    'discountPercent',
  );
  @override
  late final GeneratedColumn<double> discountPercent = GeneratedColumn<double>(
    'discount_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promoTakeMeta = const VerificationMeta(
    'promoTake',
  );
  @override
  late final GeneratedColumn<int> promoTake = GeneratedColumn<int>(
    'promo_take',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promoPayMeta = const VerificationMeta(
    'promoPay',
  );
  @override
  late final GeneratedColumn<int> promoPay = GeneratedColumn<int>(
    'promo_pay',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceSourceMeta = const VerificationMeta(
    'priceSource',
  );
  @override
  late final GeneratedColumn<String> priceSource = GeneratedColumn<String>(
    'price_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listItemIdMeta = const VerificationMeta(
    'listItemId',
  );
  @override
  late final GeneratedColumn<String> listItemId = GeneratedColumn<String>(
    'list_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkedMeta = const VerificationMeta(
    'checked',
  );
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
    'checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _advertisedPriceCentsMeta =
      const VerificationMeta('advertisedPriceCents');
  @override
  late final GeneratedColumn<int> advertisedPriceCents = GeneratedColumn<int>(
    'advertised_price_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wholesalePriceCentsMeta =
      const VerificationMeta('wholesalePriceCents');
  @override
  late final GeneratedColumn<int> wholesalePriceCents = GeneratedColumn<int>(
    'wholesale_price_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wholesaleMinQuantityMeta =
      const VerificationMeta('wholesaleMinQuantity');
  @override
  late final GeneratedColumn<int> wholesaleMinQuantity = GeneratedColumn<int>(
    'wholesale_min_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chargedUnitPriceCentsMeta =
      const VerificationMeta('chargedUnitPriceCents');
  @override
  late final GeneratedColumn<int> chargedUnitPriceCents = GeneratedColumn<int>(
    'charged_unit_price_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    position,
    productId,
    name,
    brand,
    barcode,
    unit,
    quantity,
    unitPriceCents,
    discountCents,
    discountPercent,
    promoTake,
    promoPay,
    priceSource,
    confidence,
    listItemId,
    checked,
    note,
    advertisedPriceCents,
    wholesalePriceCents,
    wholesaleMinQuantity,
    chargedUnitPriceCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_session_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingSessionLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('discount_cents')) {
      context.handle(
        _discountCentsMeta,
        discountCents.isAcceptableOrUnknown(
          data['discount_cents']!,
          _discountCentsMeta,
        ),
      );
    }
    if (data.containsKey('discount_percent')) {
      context.handle(
        _discountPercentMeta,
        discountPercent.isAcceptableOrUnknown(
          data['discount_percent']!,
          _discountPercentMeta,
        ),
      );
    }
    if (data.containsKey('promo_take')) {
      context.handle(
        _promoTakeMeta,
        promoTake.isAcceptableOrUnknown(data['promo_take']!, _promoTakeMeta),
      );
    }
    if (data.containsKey('promo_pay')) {
      context.handle(
        _promoPayMeta,
        promoPay.isAcceptableOrUnknown(data['promo_pay']!, _promoPayMeta),
      );
    }
    if (data.containsKey('price_source')) {
      context.handle(
        _priceSourceMeta,
        priceSource.isAcceptableOrUnknown(
          data['price_source']!,
          _priceSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priceSourceMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('list_item_id')) {
      context.handle(
        _listItemIdMeta,
        listItemId.isAcceptableOrUnknown(
          data['list_item_id']!,
          _listItemIdMeta,
        ),
      );
    }
    if (data.containsKey('checked')) {
      context.handle(
        _checkedMeta,
        checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('advertised_price_cents')) {
      context.handle(
        _advertisedPriceCentsMeta,
        advertisedPriceCents.isAcceptableOrUnknown(
          data['advertised_price_cents']!,
          _advertisedPriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('wholesale_price_cents')) {
      context.handle(
        _wholesalePriceCentsMeta,
        wholesalePriceCents.isAcceptableOrUnknown(
          data['wholesale_price_cents']!,
          _wholesalePriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('wholesale_min_quantity')) {
      context.handle(
        _wholesaleMinQuantityMeta,
        wholesaleMinQuantity.isAcceptableOrUnknown(
          data['wholesale_min_quantity']!,
          _wholesaleMinQuantityMeta,
        ),
      );
    }
    if (data.containsKey('charged_unit_price_cents')) {
      context.handle(
        _chargedUnitPriceCentsMeta,
        chargedUnitPriceCents.isAcceptableOrUnknown(
          data['charged_unit_price_cents']!,
          _chargedUnitPriceCentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingSessionLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingSessionLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      discountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_cents'],
      ),
      discountPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_percent'],
      ),
      promoTake: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}promo_take'],
      ),
      promoPay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}promo_pay'],
      ),
      priceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_source'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      listItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_item_id'],
      ),
      checked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}checked'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      advertisedPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}advertised_price_cents'],
      ),
      wholesalePriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wholesale_price_cents'],
      ),
      wholesaleMinQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wholesale_min_quantity'],
      ),
      chargedUnitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charged_unit_price_cents'],
      ),
    );
  }

  @override
  $ShoppingSessionLinesTable createAlias(String alias) {
    return $ShoppingSessionLinesTable(attachedDatabase, alias);
  }
}

class ShoppingSessionLineRow extends DataClass
    implements Insertable<ShoppingSessionLineRow> {
  final String id;
  final String sessionId;
  final int position;
  final String? productId;
  final String name;
  final String? brand;
  final String? barcode;
  final String unit;
  final double quantity;
  final int unitPriceCents;
  final int? discountCents;
  final double? discountPercent;
  final int? promoTake;
  final int? promoPay;
  final String priceSource;
  final double? confidence;
  final String? listItemId;
  final bool checked;
  final String? note;
  final int? advertisedPriceCents;
  final int? wholesalePriceCents;
  final int? wholesaleMinQuantity;
  final int? chargedUnitPriceCents;
  const ShoppingSessionLineRow({
    required this.id,
    required this.sessionId,
    required this.position,
    this.productId,
    required this.name,
    this.brand,
    this.barcode,
    required this.unit,
    required this.quantity,
    required this.unitPriceCents,
    this.discountCents,
    this.discountPercent,
    this.promoTake,
    this.promoPay,
    required this.priceSource,
    this.confidence,
    this.listItemId,
    required this.checked,
    this.note,
    this.advertisedPriceCents,
    this.wholesalePriceCents,
    this.wholesaleMinQuantity,
    this.chargedUnitPriceCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['unit'] = Variable<String>(unit);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    if (!nullToAbsent || discountCents != null) {
      map['discount_cents'] = Variable<int>(discountCents);
    }
    if (!nullToAbsent || discountPercent != null) {
      map['discount_percent'] = Variable<double>(discountPercent);
    }
    if (!nullToAbsent || promoTake != null) {
      map['promo_take'] = Variable<int>(promoTake);
    }
    if (!nullToAbsent || promoPay != null) {
      map['promo_pay'] = Variable<int>(promoPay);
    }
    map['price_source'] = Variable<String>(priceSource);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || listItemId != null) {
      map['list_item_id'] = Variable<String>(listItemId);
    }
    map['checked'] = Variable<bool>(checked);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || advertisedPriceCents != null) {
      map['advertised_price_cents'] = Variable<int>(advertisedPriceCents);
    }
    if (!nullToAbsent || wholesalePriceCents != null) {
      map['wholesale_price_cents'] = Variable<int>(wholesalePriceCents);
    }
    if (!nullToAbsent || wholesaleMinQuantity != null) {
      map['wholesale_min_quantity'] = Variable<int>(wholesaleMinQuantity);
    }
    if (!nullToAbsent || chargedUnitPriceCents != null) {
      map['charged_unit_price_cents'] = Variable<int>(chargedUnitPriceCents);
    }
    return map;
  }

  ShoppingSessionLinesCompanion toCompanion(bool nullToAbsent) {
    return ShoppingSessionLinesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      position: Value(position),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      unit: Value(unit),
      quantity: Value(quantity),
      unitPriceCents: Value(unitPriceCents),
      discountCents: discountCents == null && nullToAbsent
          ? const Value.absent()
          : Value(discountCents),
      discountPercent: discountPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(discountPercent),
      promoTake: promoTake == null && nullToAbsent
          ? const Value.absent()
          : Value(promoTake),
      promoPay: promoPay == null && nullToAbsent
          ? const Value.absent()
          : Value(promoPay),
      priceSource: Value(priceSource),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      listItemId: listItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(listItemId),
      checked: Value(checked),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      advertisedPriceCents: advertisedPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(advertisedPriceCents),
      wholesalePriceCents: wholesalePriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(wholesalePriceCents),
      wholesaleMinQuantity: wholesaleMinQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(wholesaleMinQuantity),
      chargedUnitPriceCents: chargedUnitPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(chargedUnitPriceCents),
    );
  }

  factory ShoppingSessionLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingSessionLineRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      position: serializer.fromJson<int>(json['position']),
      productId: serializer.fromJson<String?>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      unit: serializer.fromJson<String>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      discountCents: serializer.fromJson<int?>(json['discountCents']),
      discountPercent: serializer.fromJson<double?>(json['discountPercent']),
      promoTake: serializer.fromJson<int?>(json['promoTake']),
      promoPay: serializer.fromJson<int?>(json['promoPay']),
      priceSource: serializer.fromJson<String>(json['priceSource']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      listItemId: serializer.fromJson<String?>(json['listItemId']),
      checked: serializer.fromJson<bool>(json['checked']),
      note: serializer.fromJson<String?>(json['note']),
      advertisedPriceCents: serializer.fromJson<int?>(
        json['advertisedPriceCents'],
      ),
      wholesalePriceCents: serializer.fromJson<int?>(
        json['wholesalePriceCents'],
      ),
      wholesaleMinQuantity: serializer.fromJson<int?>(
        json['wholesaleMinQuantity'],
      ),
      chargedUnitPriceCents: serializer.fromJson<int?>(
        json['chargedUnitPriceCents'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'position': serializer.toJson<int>(position),
      'productId': serializer.toJson<String?>(productId),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'barcode': serializer.toJson<String?>(barcode),
      'unit': serializer.toJson<String>(unit),
      'quantity': serializer.toJson<double>(quantity),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'discountCents': serializer.toJson<int?>(discountCents),
      'discountPercent': serializer.toJson<double?>(discountPercent),
      'promoTake': serializer.toJson<int?>(promoTake),
      'promoPay': serializer.toJson<int?>(promoPay),
      'priceSource': serializer.toJson<String>(priceSource),
      'confidence': serializer.toJson<double?>(confidence),
      'listItemId': serializer.toJson<String?>(listItemId),
      'checked': serializer.toJson<bool>(checked),
      'note': serializer.toJson<String?>(note),
      'advertisedPriceCents': serializer.toJson<int?>(advertisedPriceCents),
      'wholesalePriceCents': serializer.toJson<int?>(wholesalePriceCents),
      'wholesaleMinQuantity': serializer.toJson<int?>(wholesaleMinQuantity),
      'chargedUnitPriceCents': serializer.toJson<int?>(chargedUnitPriceCents),
    };
  }

  ShoppingSessionLineRow copyWith({
    String? id,
    String? sessionId,
    int? position,
    Value<String?> productId = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? unit,
    double? quantity,
    int? unitPriceCents,
    Value<int?> discountCents = const Value.absent(),
    Value<double?> discountPercent = const Value.absent(),
    Value<int?> promoTake = const Value.absent(),
    Value<int?> promoPay = const Value.absent(),
    String? priceSource,
    Value<double?> confidence = const Value.absent(),
    Value<String?> listItemId = const Value.absent(),
    bool? checked,
    Value<String?> note = const Value.absent(),
    Value<int?> advertisedPriceCents = const Value.absent(),
    Value<int?> wholesalePriceCents = const Value.absent(),
    Value<int?> wholesaleMinQuantity = const Value.absent(),
    Value<int?> chargedUnitPriceCents = const Value.absent(),
  }) => ShoppingSessionLineRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    position: position ?? this.position,
    productId: productId.present ? productId.value : this.productId,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    barcode: barcode.present ? barcode.value : this.barcode,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    discountCents: discountCents.present
        ? discountCents.value
        : this.discountCents,
    discountPercent: discountPercent.present
        ? discountPercent.value
        : this.discountPercent,
    promoTake: promoTake.present ? promoTake.value : this.promoTake,
    promoPay: promoPay.present ? promoPay.value : this.promoPay,
    priceSource: priceSource ?? this.priceSource,
    confidence: confidence.present ? confidence.value : this.confidence,
    listItemId: listItemId.present ? listItemId.value : this.listItemId,
    checked: checked ?? this.checked,
    note: note.present ? note.value : this.note,
    advertisedPriceCents: advertisedPriceCents.present
        ? advertisedPriceCents.value
        : this.advertisedPriceCents,
    wholesalePriceCents: wholesalePriceCents.present
        ? wholesalePriceCents.value
        : this.wholesalePriceCents,
    wholesaleMinQuantity: wholesaleMinQuantity.present
        ? wholesaleMinQuantity.value
        : this.wholesaleMinQuantity,
    chargedUnitPriceCents: chargedUnitPriceCents.present
        ? chargedUnitPriceCents.value
        : this.chargedUnitPriceCents,
  );
  ShoppingSessionLineRow copyWithCompanion(ShoppingSessionLinesCompanion data) {
    return ShoppingSessionLineRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      position: data.position.present ? data.position.value : this.position,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      discountCents: data.discountCents.present
          ? data.discountCents.value
          : this.discountCents,
      discountPercent: data.discountPercent.present
          ? data.discountPercent.value
          : this.discountPercent,
      promoTake: data.promoTake.present ? data.promoTake.value : this.promoTake,
      promoPay: data.promoPay.present ? data.promoPay.value : this.promoPay,
      priceSource: data.priceSource.present
          ? data.priceSource.value
          : this.priceSource,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      listItemId: data.listItemId.present
          ? data.listItemId.value
          : this.listItemId,
      checked: data.checked.present ? data.checked.value : this.checked,
      note: data.note.present ? data.note.value : this.note,
      advertisedPriceCents: data.advertisedPriceCents.present
          ? data.advertisedPriceCents.value
          : this.advertisedPriceCents,
      wholesalePriceCents: data.wholesalePriceCents.present
          ? data.wholesalePriceCents.value
          : this.wholesalePriceCents,
      wholesaleMinQuantity: data.wholesaleMinQuantity.present
          ? data.wholesaleMinQuantity.value
          : this.wholesaleMinQuantity,
      chargedUnitPriceCents: data.chargedUnitPriceCents.present
          ? data.chargedUnitPriceCents.value
          : this.chargedUnitPriceCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingSessionLineRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('discountCents: $discountCents, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('promoTake: $promoTake, ')
          ..write('promoPay: $promoPay, ')
          ..write('priceSource: $priceSource, ')
          ..write('confidence: $confidence, ')
          ..write('listItemId: $listItemId, ')
          ..write('checked: $checked, ')
          ..write('note: $note, ')
          ..write('advertisedPriceCents: $advertisedPriceCents, ')
          ..write('wholesalePriceCents: $wholesalePriceCents, ')
          ..write('wholesaleMinQuantity: $wholesaleMinQuantity, ')
          ..write('chargedUnitPriceCents: $chargedUnitPriceCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionId,
    position,
    productId,
    name,
    brand,
    barcode,
    unit,
    quantity,
    unitPriceCents,
    discountCents,
    discountPercent,
    promoTake,
    promoPay,
    priceSource,
    confidence,
    listItemId,
    checked,
    note,
    advertisedPriceCents,
    wholesalePriceCents,
    wholesaleMinQuantity,
    chargedUnitPriceCents,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingSessionLineRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.position == this.position &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.barcode == this.barcode &&
          other.unit == this.unit &&
          other.quantity == this.quantity &&
          other.unitPriceCents == this.unitPriceCents &&
          other.discountCents == this.discountCents &&
          other.discountPercent == this.discountPercent &&
          other.promoTake == this.promoTake &&
          other.promoPay == this.promoPay &&
          other.priceSource == this.priceSource &&
          other.confidence == this.confidence &&
          other.listItemId == this.listItemId &&
          other.checked == this.checked &&
          other.note == this.note &&
          other.advertisedPriceCents == this.advertisedPriceCents &&
          other.wholesalePriceCents == this.wholesalePriceCents &&
          other.wholesaleMinQuantity == this.wholesaleMinQuantity &&
          other.chargedUnitPriceCents == this.chargedUnitPriceCents);
}

class ShoppingSessionLinesCompanion
    extends UpdateCompanion<ShoppingSessionLineRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> position;
  final Value<String?> productId;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> barcode;
  final Value<String> unit;
  final Value<double> quantity;
  final Value<int> unitPriceCents;
  final Value<int?> discountCents;
  final Value<double?> discountPercent;
  final Value<int?> promoTake;
  final Value<int?> promoPay;
  final Value<String> priceSource;
  final Value<double?> confidence;
  final Value<String?> listItemId;
  final Value<bool> checked;
  final Value<String?> note;
  final Value<int?> advertisedPriceCents;
  final Value<int?> wholesalePriceCents;
  final Value<int?> wholesaleMinQuantity;
  final Value<int?> chargedUnitPriceCents;
  final Value<int> rowid;
  const ShoppingSessionLinesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.position = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.discountCents = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.promoTake = const Value.absent(),
    this.promoPay = const Value.absent(),
    this.priceSource = const Value.absent(),
    this.confidence = const Value.absent(),
    this.listItemId = const Value.absent(),
    this.checked = const Value.absent(),
    this.note = const Value.absent(),
    this.advertisedPriceCents = const Value.absent(),
    this.wholesalePriceCents = const Value.absent(),
    this.wholesaleMinQuantity = const Value.absent(),
    this.chargedUnitPriceCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingSessionLinesCompanion.insert({
    required String id,
    required String sessionId,
    required int position,
    this.productId = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    required String unit,
    required double quantity,
    required int unitPriceCents,
    this.discountCents = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.promoTake = const Value.absent(),
    this.promoPay = const Value.absent(),
    required String priceSource,
    this.confidence = const Value.absent(),
    this.listItemId = const Value.absent(),
    this.checked = const Value.absent(),
    this.note = const Value.absent(),
    this.advertisedPriceCents = const Value.absent(),
    this.wholesalePriceCents = const Value.absent(),
    this.wholesaleMinQuantity = const Value.absent(),
    this.chargedUnitPriceCents = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       position = Value(position),
       name = Value(name),
       unit = Value(unit),
       quantity = Value(quantity),
       unitPriceCents = Value(unitPriceCents),
       priceSource = Value(priceSource);
  static Insertable<ShoppingSessionLineRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? position,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? barcode,
    Expression<String>? unit,
    Expression<double>? quantity,
    Expression<int>? unitPriceCents,
    Expression<int>? discountCents,
    Expression<double>? discountPercent,
    Expression<int>? promoTake,
    Expression<int>? promoPay,
    Expression<String>? priceSource,
    Expression<double>? confidence,
    Expression<String>? listItemId,
    Expression<bool>? checked,
    Expression<String>? note,
    Expression<int>? advertisedPriceCents,
    Expression<int>? wholesalePriceCents,
    Expression<int>? wholesaleMinQuantity,
    Expression<int>? chargedUnitPriceCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (position != null) 'position': position,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (barcode != null) 'barcode': barcode,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (discountCents != null) 'discount_cents': discountCents,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (promoTake != null) 'promo_take': promoTake,
      if (promoPay != null) 'promo_pay': promoPay,
      if (priceSource != null) 'price_source': priceSource,
      if (confidence != null) 'confidence': confidence,
      if (listItemId != null) 'list_item_id': listItemId,
      if (checked != null) 'checked': checked,
      if (note != null) 'note': note,
      if (advertisedPriceCents != null)
        'advertised_price_cents': advertisedPriceCents,
      if (wholesalePriceCents != null)
        'wholesale_price_cents': wholesalePriceCents,
      if (wholesaleMinQuantity != null)
        'wholesale_min_quantity': wholesaleMinQuantity,
      if (chargedUnitPriceCents != null)
        'charged_unit_price_cents': chargedUnitPriceCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingSessionLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? position,
    Value<String?>? productId,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? barcode,
    Value<String>? unit,
    Value<double>? quantity,
    Value<int>? unitPriceCents,
    Value<int?>? discountCents,
    Value<double?>? discountPercent,
    Value<int?>? promoTake,
    Value<int?>? promoPay,
    Value<String>? priceSource,
    Value<double?>? confidence,
    Value<String?>? listItemId,
    Value<bool>? checked,
    Value<String?>? note,
    Value<int?>? advertisedPriceCents,
    Value<int?>? wholesalePriceCents,
    Value<int?>? wholesaleMinQuantity,
    Value<int?>? chargedUnitPriceCents,
    Value<int>? rowid,
  }) {
    return ShoppingSessionLinesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      position: position ?? this.position,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      discountCents: discountCents ?? this.discountCents,
      discountPercent: discountPercent ?? this.discountPercent,
      promoTake: promoTake ?? this.promoTake,
      promoPay: promoPay ?? this.promoPay,
      priceSource: priceSource ?? this.priceSource,
      confidence: confidence ?? this.confidence,
      listItemId: listItemId ?? this.listItemId,
      checked: checked ?? this.checked,
      note: note ?? this.note,
      advertisedPriceCents: advertisedPriceCents ?? this.advertisedPriceCents,
      wholesalePriceCents: wholesalePriceCents ?? this.wholesalePriceCents,
      wholesaleMinQuantity: wholesaleMinQuantity ?? this.wholesaleMinQuantity,
      chargedUnitPriceCents:
          chargedUnitPriceCents ?? this.chargedUnitPriceCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (discountCents.present) {
      map['discount_cents'] = Variable<int>(discountCents.value);
    }
    if (discountPercent.present) {
      map['discount_percent'] = Variable<double>(discountPercent.value);
    }
    if (promoTake.present) {
      map['promo_take'] = Variable<int>(promoTake.value);
    }
    if (promoPay.present) {
      map['promo_pay'] = Variable<int>(promoPay.value);
    }
    if (priceSource.present) {
      map['price_source'] = Variable<String>(priceSource.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (listItemId.present) {
      map['list_item_id'] = Variable<String>(listItemId.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (advertisedPriceCents.present) {
      map['advertised_price_cents'] = Variable<int>(advertisedPriceCents.value);
    }
    if (wholesalePriceCents.present) {
      map['wholesale_price_cents'] = Variable<int>(wholesalePriceCents.value);
    }
    if (wholesaleMinQuantity.present) {
      map['wholesale_min_quantity'] = Variable<int>(wholesaleMinQuantity.value);
    }
    if (chargedUnitPriceCents.present) {
      map['charged_unit_price_cents'] = Variable<int>(
        chargedUnitPriceCents.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingSessionLinesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('discountCents: $discountCents, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('promoTake: $promoTake, ')
          ..write('promoPay: $promoPay, ')
          ..write('priceSource: $priceSource, ')
          ..write('confidence: $confidence, ')
          ..write('listItemId: $listItemId, ')
          ..write('checked: $checked, ')
          ..write('note: $note, ')
          ..write('advertisedPriceCents: $advertisedPriceCents, ')
          ..write('wholesalePriceCents: $wholesalePriceCents, ')
          ..write('wholesaleMinQuantity: $wholesaleMinQuantity, ')
          ..write('chargedUnitPriceCents: $chargedUnitPriceCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingSessionEventsTable extends ShoppingSessionEvents
    with TableInfo<$ShoppingSessionEventsTable, ShoppingSessionEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingSessionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shopping_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<String> lineId = GeneratedColumn<String>(
    'line_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    sessionId,
    at,
    type,
    lineId,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_session_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingSessionEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  ShoppingSessionEventRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingSessionEventRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_id'],
      ),
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
    );
  }

  @override
  $ShoppingSessionEventsTable createAlias(String alias) {
    return $ShoppingSessionEventsTable(attachedDatabase, alias);
  }
}

class ShoppingSessionEventRow extends DataClass
    implements Insertable<ShoppingSessionEventRow> {
  final int seq;
  final String sessionId;
  final String at;
  final String type;
  final String? lineId;
  final String? detail;
  const ShoppingSessionEventRow({
    required this.seq,
    required this.sessionId,
    required this.at,
    required this.type,
    this.lineId,
    this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['session_id'] = Variable<String>(sessionId);
    map['at'] = Variable<String>(at);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || lineId != null) {
      map['line_id'] = Variable<String>(lineId);
    }
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  ShoppingSessionEventsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingSessionEventsCompanion(
      seq: Value(seq),
      sessionId: Value(sessionId),
      at: Value(at),
      type: Value(type),
      lineId: lineId == null && nullToAbsent
          ? const Value.absent()
          : Value(lineId),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
    );
  }

  factory ShoppingSessionEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingSessionEventRow(
      seq: serializer.fromJson<int>(json['seq']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      at: serializer.fromJson<String>(json['at']),
      type: serializer.fromJson<String>(json['type']),
      lineId: serializer.fromJson<String?>(json['lineId']),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'sessionId': serializer.toJson<String>(sessionId),
      'at': serializer.toJson<String>(at),
      'type': serializer.toJson<String>(type),
      'lineId': serializer.toJson<String?>(lineId),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  ShoppingSessionEventRow copyWith({
    int? seq,
    String? sessionId,
    String? at,
    String? type,
    Value<String?> lineId = const Value.absent(),
    Value<String?> detail = const Value.absent(),
  }) => ShoppingSessionEventRow(
    seq: seq ?? this.seq,
    sessionId: sessionId ?? this.sessionId,
    at: at ?? this.at,
    type: type ?? this.type,
    lineId: lineId.present ? lineId.value : this.lineId,
    detail: detail.present ? detail.value : this.detail,
  );
  ShoppingSessionEventRow copyWithCompanion(
    ShoppingSessionEventsCompanion data,
  ) {
    return ShoppingSessionEventRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      at: data.at.present ? data.at.value : this.at,
      type: data.type.present ? data.type.value : this.type,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingSessionEventRow(')
          ..write('seq: $seq, ')
          ..write('sessionId: $sessionId, ')
          ..write('at: $at, ')
          ..write('type: $type, ')
          ..write('lineId: $lineId, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, sessionId, at, type, lineId, detail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingSessionEventRow &&
          other.seq == this.seq &&
          other.sessionId == this.sessionId &&
          other.at == this.at &&
          other.type == this.type &&
          other.lineId == this.lineId &&
          other.detail == this.detail);
}

class ShoppingSessionEventsCompanion
    extends UpdateCompanion<ShoppingSessionEventRow> {
  final Value<int> seq;
  final Value<String> sessionId;
  final Value<String> at;
  final Value<String> type;
  final Value<String?> lineId;
  final Value<String?> detail;
  const ShoppingSessionEventsCompanion({
    this.seq = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.at = const Value.absent(),
    this.type = const Value.absent(),
    this.lineId = const Value.absent(),
    this.detail = const Value.absent(),
  });
  ShoppingSessionEventsCompanion.insert({
    this.seq = const Value.absent(),
    required String sessionId,
    required String at,
    required String type,
    this.lineId = const Value.absent(),
    this.detail = const Value.absent(),
  }) : sessionId = Value(sessionId),
       at = Value(at),
       type = Value(type);
  static Insertable<ShoppingSessionEventRow> custom({
    Expression<int>? seq,
    Expression<String>? sessionId,
    Expression<String>? at,
    Expression<String>? type,
    Expression<String>? lineId,
    Expression<String>? detail,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (sessionId != null) 'session_id': sessionId,
      if (at != null) 'at': at,
      if (type != null) 'type': type,
      if (lineId != null) 'line_id': lineId,
      if (detail != null) 'detail': detail,
    });
  }

  ShoppingSessionEventsCompanion copyWith({
    Value<int>? seq,
    Value<String>? sessionId,
    Value<String>? at,
    Value<String>? type,
    Value<String?>? lineId,
    Value<String?>? detail,
  }) {
    return ShoppingSessionEventsCompanion(
      seq: seq ?? this.seq,
      sessionId: sessionId ?? this.sessionId,
      at: at ?? this.at,
      type: type ?? this.type,
      lineId: lineId ?? this.lineId,
      detail: detail ?? this.detail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<String>(lineId.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingSessionEventsCompanion(')
          ..write('seq: $seq, ')
          ..write('sessionId: $sessionId, ')
          ..write('at: $at, ')
          ..write('type: $type, ')
          ..write('lineId: $lineId, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }
}

class $ShoppingEvidenceTable extends ShoppingEvidence
    with TableInfo<$ShoppingEvidenceTable, ShoppingEvidenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingEvidenceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shopping_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<String> lineId = GeneratedColumn<String>(
    'line_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    check: () => role.isIn(['label', 'product', 'receipt', 'other']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    check: () => ComparableExpr(sizeBytes).isBetweenValues(0, 8 * 1024 * 1024),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<String> capturedAt = GeneratedColumn<String>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ocrJsonMeta = const VerificationMeta(
    'ocrJson',
  );
  @override
  late final GeneratedColumn<String> ocrJson = GeneratedColumn<String>(
    'ocr_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    lineId,
    role,
    mimeType,
    sizeBytes,
    sha256,
    width,
    height,
    data,
    capturedAt,
    ocrJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_evidence';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingEvidenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('ocr_json')) {
      context.handle(
        _ocrJsonMeta,
        ocrJson.isAcceptableOrUnknown(data['ocr_json']!, _ocrJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingEvidenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingEvidenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_id'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}captured_at'],
      )!,
      ocrJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_json'],
      ),
    );
  }

  @override
  $ShoppingEvidenceTable createAlias(String alias) {
    return $ShoppingEvidenceTable(attachedDatabase, alias);
  }
}

class ShoppingEvidenceRow extends DataClass
    implements Insertable<ShoppingEvidenceRow> {
  final String id;
  final String sessionId;
  final String? lineId;
  final String role;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  final int? width;
  final int? height;
  final Uint8List data;
  final String capturedAt;
  final String? ocrJson;
  const ShoppingEvidenceRow({
    required this.id,
    required this.sessionId,
    this.lineId,
    required this.role,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    this.width,
    this.height,
    required this.data,
    required this.capturedAt,
    this.ocrJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || lineId != null) {
      map['line_id'] = Variable<String>(lineId);
    }
    map['role'] = Variable<String>(role);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['sha256'] = Variable<String>(sha256);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['data'] = Variable<Uint8List>(data);
    map['captured_at'] = Variable<String>(capturedAt);
    if (!nullToAbsent || ocrJson != null) {
      map['ocr_json'] = Variable<String>(ocrJson);
    }
    return map;
  }

  ShoppingEvidenceCompanion toCompanion(bool nullToAbsent) {
    return ShoppingEvidenceCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      lineId: lineId == null && nullToAbsent
          ? const Value.absent()
          : Value(lineId),
      role: Value(role),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      sha256: Value(sha256),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      data: Value(data),
      capturedAt: Value(capturedAt),
      ocrJson: ocrJson == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrJson),
    );
  }

  factory ShoppingEvidenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingEvidenceRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      lineId: serializer.fromJson<String?>(json['lineId']),
      role: serializer.fromJson<String>(json['role']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      data: serializer.fromJson<Uint8List>(json['data']),
      capturedAt: serializer.fromJson<String>(json['capturedAt']),
      ocrJson: serializer.fromJson<String?>(json['ocrJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'lineId': serializer.toJson<String?>(lineId),
      'role': serializer.toJson<String>(role),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sha256': serializer.toJson<String>(sha256),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'data': serializer.toJson<Uint8List>(data),
      'capturedAt': serializer.toJson<String>(capturedAt),
      'ocrJson': serializer.toJson<String?>(ocrJson),
    };
  }

  ShoppingEvidenceRow copyWith({
    String? id,
    String? sessionId,
    Value<String?> lineId = const Value.absent(),
    String? role,
    String? mimeType,
    int? sizeBytes,
    String? sha256,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Uint8List? data,
    String? capturedAt,
    Value<String?> ocrJson = const Value.absent(),
  }) => ShoppingEvidenceRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    lineId: lineId.present ? lineId.value : this.lineId,
    role: role ?? this.role,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256 ?? this.sha256,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    data: data ?? this.data,
    capturedAt: capturedAt ?? this.capturedAt,
    ocrJson: ocrJson.present ? ocrJson.value : this.ocrJson,
  );
  ShoppingEvidenceRow copyWithCompanion(ShoppingEvidenceCompanion data) {
    return ShoppingEvidenceRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      role: data.role.present ? data.role.value : this.role,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      data: data.data.present ? data.data.value : this.data,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      ocrJson: data.ocrJson.present ? data.ocrJson.value : this.ocrJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingEvidenceRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lineId: $lineId, ')
          ..write('role: $role, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('data: $data, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('ocrJson: $ocrJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    lineId,
    role,
    mimeType,
    sizeBytes,
    sha256,
    width,
    height,
    $driftBlobEquality.hash(data),
    capturedAt,
    ocrJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingEvidenceRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.lineId == this.lineId &&
          other.role == this.role &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          other.width == this.width &&
          other.height == this.height &&
          $driftBlobEquality.equals(other.data, this.data) &&
          other.capturedAt == this.capturedAt &&
          other.ocrJson == this.ocrJson);
}

class ShoppingEvidenceCompanion extends UpdateCompanion<ShoppingEvidenceRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String?> lineId;
  final Value<String> role;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String> sha256;
  final Value<int?> width;
  final Value<int?> height;
  final Value<Uint8List> data;
  final Value<String> capturedAt;
  final Value<String?> ocrJson;
  final Value<int> rowid;
  const ShoppingEvidenceCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.lineId = const Value.absent(),
    this.role = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.data = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.ocrJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingEvidenceCompanion.insert({
    required String id,
    required String sessionId,
    this.lineId = const Value.absent(),
    required String role,
    required String mimeType,
    required int sizeBytes,
    required String sha256,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required Uint8List data,
    required String capturedAt,
    this.ocrJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       role = Value(role),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       sha256 = Value(sha256),
       data = Value(data),
       capturedAt = Value(capturedAt);
  static Insertable<ShoppingEvidenceRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? lineId,
    Expression<String>? role,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<int>? width,
    Expression<int>? height,
    Expression<Uint8List>? data,
    Expression<String>? capturedAt,
    Expression<String>? ocrJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (lineId != null) 'line_id': lineId,
      if (role != null) 'role': role,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (data != null) 'data': data,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (ocrJson != null) 'ocr_json': ocrJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingEvidenceCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String?>? lineId,
    Value<String>? role,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String>? sha256,
    Value<int?>? width,
    Value<int?>? height,
    Value<Uint8List>? data,
    Value<String>? capturedAt,
    Value<String?>? ocrJson,
    Value<int>? rowid,
  }) {
    return ShoppingEvidenceCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      lineId: lineId ?? this.lineId,
      role: role ?? this.role,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      width: width ?? this.width,
      height: height ?? this.height,
      data: data ?? this.data,
      capturedAt: capturedAt ?? this.capturedAt,
      ocrJson: ocrJson ?? this.ocrJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<String>(lineId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<String>(capturedAt.value);
    }
    if (ocrJson.present) {
      map['ocr_json'] = Variable<String>(ocrJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingEvidenceCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lineId: $lineId, ')
          ..write('role: $role, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('data: $data, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('ocrJson: $ocrJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingReceiptLinesTable extends ShoppingReceiptLines
    with TableInfo<$ShoppingReceiptLinesTable, ShoppingReceiptLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingReceiptLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shopping_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchedLineIdMeta = const VerificationMeta(
    'matchedLineId',
  );
  @override
  late final GeneratedColumn<String> matchedLineId = GeneratedColumn<String>(
    'matched_line_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchStatusMeta = const VerificationMeta(
    'matchStatus',
  );
  @override
  late final GeneratedColumn<String> matchStatus = GeneratedColumn<String>(
    'match_status',
    aliasedName,
    false,
    check: () => matchStatus.isIn([
      'equal',
      'divergent',
      'suspected',
      'confirmed',
      'unmatched',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchScoreMeta = const VerificationMeta(
    'matchScore',
  );
  @override
  late final GeneratedColumn<double> matchScore = GeneratedColumn<double>(
    'match_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    position,
    rawText,
    description,
    quantity,
    unit,
    unitPriceCents,
    totalCents,
    code,
    matchedLineId,
    matchStatus,
    matchScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_receipt_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingReceiptLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('matched_line_id')) {
      context.handle(
        _matchedLineIdMeta,
        matchedLineId.isAcceptableOrUnknown(
          data['matched_line_id']!,
          _matchedLineIdMeta,
        ),
      );
    }
    if (data.containsKey('match_status')) {
      context.handle(
        _matchStatusMeta,
        matchStatus.isAcceptableOrUnknown(
          data['match_status']!,
          _matchStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_matchStatusMeta);
    }
    if (data.containsKey('match_score')) {
      context.handle(
        _matchScoreMeta,
        matchScore.isAcceptableOrUnknown(data['match_score']!, _matchScoreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingReceiptLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingReceiptLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      ),
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      matchedLineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_line_id'],
      ),
      matchStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_status'],
      )!,
      matchScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}match_score'],
      ),
    );
  }

  @override
  $ShoppingReceiptLinesTable createAlias(String alias) {
    return $ShoppingReceiptLinesTable(attachedDatabase, alias);
  }
}

class ShoppingReceiptLineRow extends DataClass
    implements Insertable<ShoppingReceiptLineRow> {
  final String id;
  final String sessionId;
  final int position;
  final String rawText;
  final String description;
  final double quantity;
  final String unit;
  final int? unitPriceCents;
  final int totalCents;
  final String? code;
  final String? matchedLineId;
  final String matchStatus;
  final double? matchScore;
  const ShoppingReceiptLineRow({
    required this.id,
    required this.sessionId,
    required this.position,
    required this.rawText,
    required this.description,
    required this.quantity,
    required this.unit,
    this.unitPriceCents,
    required this.totalCents,
    this.code,
    this.matchedLineId,
    required this.matchStatus,
    this.matchScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['position'] = Variable<int>(position);
    map['raw_text'] = Variable<String>(rawText);
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || unitPriceCents != null) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents);
    }
    map['total_cents'] = Variable<int>(totalCents);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || matchedLineId != null) {
      map['matched_line_id'] = Variable<String>(matchedLineId);
    }
    map['match_status'] = Variable<String>(matchStatus);
    if (!nullToAbsent || matchScore != null) {
      map['match_score'] = Variable<double>(matchScore);
    }
    return map;
  }

  ShoppingReceiptLinesCompanion toCompanion(bool nullToAbsent) {
    return ShoppingReceiptLinesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      position: Value(position),
      rawText: Value(rawText),
      description: Value(description),
      quantity: Value(quantity),
      unit: Value(unit),
      unitPriceCents: unitPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPriceCents),
      totalCents: Value(totalCents),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      matchedLineId: matchedLineId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedLineId),
      matchStatus: Value(matchStatus),
      matchScore: matchScore == null && nullToAbsent
          ? const Value.absent()
          : Value(matchScore),
    );
  }

  factory ShoppingReceiptLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingReceiptLineRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      position: serializer.fromJson<int>(json['position']),
      rawText: serializer.fromJson<String>(json['rawText']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      unitPriceCents: serializer.fromJson<int?>(json['unitPriceCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      code: serializer.fromJson<String?>(json['code']),
      matchedLineId: serializer.fromJson<String?>(json['matchedLineId']),
      matchStatus: serializer.fromJson<String>(json['matchStatus']),
      matchScore: serializer.fromJson<double?>(json['matchScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'position': serializer.toJson<int>(position),
      'rawText': serializer.toJson<String>(rawText),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'unitPriceCents': serializer.toJson<int?>(unitPriceCents),
      'totalCents': serializer.toJson<int>(totalCents),
      'code': serializer.toJson<String?>(code),
      'matchedLineId': serializer.toJson<String?>(matchedLineId),
      'matchStatus': serializer.toJson<String>(matchStatus),
      'matchScore': serializer.toJson<double?>(matchScore),
    };
  }

  ShoppingReceiptLineRow copyWith({
    String? id,
    String? sessionId,
    int? position,
    String? rawText,
    String? description,
    double? quantity,
    String? unit,
    Value<int?> unitPriceCents = const Value.absent(),
    int? totalCents,
    Value<String?> code = const Value.absent(),
    Value<String?> matchedLineId = const Value.absent(),
    String? matchStatus,
    Value<double?> matchScore = const Value.absent(),
  }) => ShoppingReceiptLineRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    position: position ?? this.position,
    rawText: rawText ?? this.rawText,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    unitPriceCents: unitPriceCents.present
        ? unitPriceCents.value
        : this.unitPriceCents,
    totalCents: totalCents ?? this.totalCents,
    code: code.present ? code.value : this.code,
    matchedLineId: matchedLineId.present
        ? matchedLineId.value
        : this.matchedLineId,
    matchStatus: matchStatus ?? this.matchStatus,
    matchScore: matchScore.present ? matchScore.value : this.matchScore,
  );
  ShoppingReceiptLineRow copyWithCompanion(ShoppingReceiptLinesCompanion data) {
    return ShoppingReceiptLineRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      position: data.position.present ? data.position.value : this.position,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      code: data.code.present ? data.code.value : this.code,
      matchedLineId: data.matchedLineId.present
          ? data.matchedLineId.value
          : this.matchedLineId,
      matchStatus: data.matchStatus.present
          ? data.matchStatus.value
          : this.matchStatus,
      matchScore: data.matchScore.present
          ? data.matchScore.value
          : this.matchScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingReceiptLineRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('rawText: $rawText, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('code: $code, ')
          ..write('matchedLineId: $matchedLineId, ')
          ..write('matchStatus: $matchStatus, ')
          ..write('matchScore: $matchScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    position,
    rawText,
    description,
    quantity,
    unit,
    unitPriceCents,
    totalCents,
    code,
    matchedLineId,
    matchStatus,
    matchScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingReceiptLineRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.position == this.position &&
          other.rawText == this.rawText &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.unitPriceCents == this.unitPriceCents &&
          other.totalCents == this.totalCents &&
          other.code == this.code &&
          other.matchedLineId == this.matchedLineId &&
          other.matchStatus == this.matchStatus &&
          other.matchScore == this.matchScore);
}

class ShoppingReceiptLinesCompanion
    extends UpdateCompanion<ShoppingReceiptLineRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> position;
  final Value<String> rawText;
  final Value<String> description;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<int?> unitPriceCents;
  final Value<int> totalCents;
  final Value<String?> code;
  final Value<String?> matchedLineId;
  final Value<String> matchStatus;
  final Value<double?> matchScore;
  final Value<int> rowid;
  const ShoppingReceiptLinesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.position = const Value.absent(),
    this.rawText = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.code = const Value.absent(),
    this.matchedLineId = const Value.absent(),
    this.matchStatus = const Value.absent(),
    this.matchScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingReceiptLinesCompanion.insert({
    required String id,
    required String sessionId,
    required int position,
    required String rawText,
    required String description,
    required double quantity,
    required String unit,
    this.unitPriceCents = const Value.absent(),
    required int totalCents,
    this.code = const Value.absent(),
    this.matchedLineId = const Value.absent(),
    required String matchStatus,
    this.matchScore = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       position = Value(position),
       rawText = Value(rawText),
       description = Value(description),
       quantity = Value(quantity),
       unit = Value(unit),
       totalCents = Value(totalCents),
       matchStatus = Value(matchStatus);
  static Insertable<ShoppingReceiptLineRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? position,
    Expression<String>? rawText,
    Expression<String>? description,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? unitPriceCents,
    Expression<int>? totalCents,
    Expression<String>? code,
    Expression<String>? matchedLineId,
    Expression<String>? matchStatus,
    Expression<double>? matchScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (position != null) 'position': position,
      if (rawText != null) 'raw_text': rawText,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (code != null) 'code': code,
      if (matchedLineId != null) 'matched_line_id': matchedLineId,
      if (matchStatus != null) 'match_status': matchStatus,
      if (matchScore != null) 'match_score': matchScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingReceiptLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? position,
    Value<String>? rawText,
    Value<String>? description,
    Value<double>? quantity,
    Value<String>? unit,
    Value<int?>? unitPriceCents,
    Value<int>? totalCents,
    Value<String?>? code,
    Value<String?>? matchedLineId,
    Value<String>? matchStatus,
    Value<double?>? matchScore,
    Value<int>? rowid,
  }) {
    return ShoppingReceiptLinesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      position: position ?? this.position,
      rawText: rawText ?? this.rawText,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      totalCents: totalCents ?? this.totalCents,
      code: code ?? this.code,
      matchedLineId: matchedLineId ?? this.matchedLineId,
      matchStatus: matchStatus ?? this.matchStatus,
      matchScore: matchScore ?? this.matchScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (matchedLineId.present) {
      map['matched_line_id'] = Variable<String>(matchedLineId.value);
    }
    if (matchStatus.present) {
      map['match_status'] = Variable<String>(matchStatus.value);
    }
    if (matchScore.present) {
      map['match_score'] = Variable<double>(matchScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingReceiptLinesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('rawText: $rawText, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('code: $code, ')
          ..write('matchedLineId: $matchedLineId, ')
          ..write('matchStatus: $matchStatus, ')
          ..write('matchScore: $matchScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvTable extends Kv with TableInfo<$KvTable, KvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, json, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KvTable createAlias(String alias) {
    return $KvTable(attachedDatabase, alias);
  }
}

class KvRow extends DataClass implements Insertable<KvRow> {
  final String key;
  final String json;
  final String updatedAt;
  const KvRow({required this.key, required this.json, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['json'] = Variable<String>(json);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  KvCompanion toCompanion(bool nullToAbsent) {
    return KvCompanion(
      key: Value(key),
      json: Value(json),
      updatedAt: Value(updatedAt),
    );
  }

  factory KvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvRow(
      key: serializer.fromJson<String>(json['key']),
      json: serializer.fromJson<String>(json['json']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'json': serializer.toJson<String>(json),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  KvRow copyWith({String? key, String? json, String? updatedAt}) => KvRow(
    key: key ?? this.key,
    json: json ?? this.json,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KvRow copyWithCompanion(KvCompanion data) {
    return KvRow(
      key: data.key.present ? data.key.value : this.key,
      json: data.json.present ? data.json.value : this.json,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvRow(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, json, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvRow &&
          other.key == this.key &&
          other.json == this.json &&
          other.updatedAt == this.updatedAt);
}

class KvCompanion extends UpdateCompanion<KvRow> {
  final Value<String> key;
  final Value<String> json;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const KvCompanion({
    this.key = const Value.absent(),
    this.json = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvCompanion.insert({
    required String key,
    required String json,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       json = Value(json),
       updatedAt = Value(updatedAt);
  static Insertable<KvRow> custom({
    Expression<String>? key,
    Expression<String>? json,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (json != null) 'json': json,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvCompanion copyWith({
    Value<String>? key,
    Value<String>? json,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return KvCompanion(
      key: key ?? this.key,
      json: json ?? this.json,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvCompanion(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangeLogEntriesTable extends ChangeLogEntries
    with TableInfo<$ChangeLogEntriesTable, ChangeLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    check: () => op.isIn(['upsert', 'delete', 'restore']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    op,
    payload,
    version,
    deviceId,
    at,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChangeLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $ChangeLogEntriesTable createAlias(String alias) {
    return $ChangeLogEntriesTable(attachedDatabase, alias);
  }
}

class ChangeLogRow extends DataClass implements Insertable<ChangeLogRow> {
  final String id;
  final String entityType;
  final String entityId;
  final String op;
  final String? payload;
  final int version;
  final String deviceId;
  final String at;
  final bool synced;
  const ChangeLogRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.op,
    this.payload,
    required this.version,
    required this.deviceId,
    required this.at,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['version'] = Variable<int>(version);
    map['device_id'] = Variable<String>(deviceId);
    map['at'] = Variable<String>(at);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ChangeLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChangeLogEntriesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      op: Value(op),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      version: Value(version),
      deviceId: Value(deviceId),
      at: Value(at),
      synced: Value(synced),
    );
  }

  factory ChangeLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeLogRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      payload: serializer.fromJson<String?>(json['payload']),
      version: serializer.fromJson<int>(json['version']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      at: serializer.fromJson<String>(json['at']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'payload': serializer.toJson<String?>(payload),
      'version': serializer.toJson<int>(version),
      'deviceId': serializer.toJson<String>(deviceId),
      'at': serializer.toJson<String>(at),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ChangeLogRow copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? op,
    Value<String?> payload = const Value.absent(),
    int? version,
    String? deviceId,
    String? at,
    bool? synced,
  }) => ChangeLogRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    payload: payload.present ? payload.value : this.payload,
    version: version ?? this.version,
    deviceId: deviceId ?? this.deviceId,
    at: at ?? this.at,
    synced: synced ?? this.synced,
  );
  ChangeLogRow copyWithCompanion(ChangeLogEntriesCompanion data) {
    return ChangeLogRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      payload: data.payload.present ? data.payload.value : this.payload,
      version: data.version.present ? data.version.value : this.version,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      at: data.at.present ? data.at.value : this.at,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('at: $at, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    op,
    payload,
    version,
    deviceId,
    at,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeLogRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.payload == this.payload &&
          other.version == this.version &&
          other.deviceId == this.deviceId &&
          other.at == this.at &&
          other.synced == this.synced);
}

class ChangeLogEntriesCompanion extends UpdateCompanion<ChangeLogRow> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String?> payload;
  final Value<int> version;
  final Value<String> deviceId;
  final Value<String> at;
  final Value<bool> synced;
  final Value<int> rowid;
  const ChangeLogEntriesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.payload = const Value.absent(),
    this.version = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.at = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChangeLogEntriesCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String op,
    this.payload = const Value.absent(),
    required int version,
    required String deviceId,
    required String at,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       op = Value(op),
       version = Value(version),
       deviceId = Value(deviceId),
       at = Value(at);
  static Insertable<ChangeLogRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? payload,
    Expression<int>? version,
    Expression<String>? deviceId,
    Expression<String>? at,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (payload != null) 'payload': payload,
      if (version != null) 'version': version,
      if (deviceId != null) 'device_id': deviceId,
      if (at != null) 'at': at,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChangeLogEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? op,
    Value<String?>? payload,
    Value<int>? version,
    Value<String>? deviceId,
    Value<String>? at,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return ChangeLogEntriesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      payload: payload ?? this.payload,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      at: at ?? this.at,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('version: $version, ')
          ..write('deviceId: $deviceId, ')
          ..write('at: $at, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictsTable extends Conflicts
    with TableInfo<$ConflictsTable, ConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localJsonMeta = const VerificationMeta(
    'localJson',
  );
  @override
  late final GeneratedColumn<String> localJson = GeneratedColumn<String>(
    'local_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteJsonMeta = const VerificationMeta(
    'remoteJson',
  );
  @override
  late final GeneratedColumn<String> remoteJson = GeneratedColumn<String>(
    'remote_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<String> detectedAt = GeneratedColumn<String>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<String> resolvedAt = GeneratedColumn<String>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chosenSideMeta = const VerificationMeta(
    'chosenSide',
  );
  @override
  late final GeneratedColumn<String> chosenSide = GeneratedColumn<String>(
    'chosen_side',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    field,
    localJson,
    remoteJson,
    detectedAt,
    resolvedAt,
    chosenSide,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('local_json')) {
      context.handle(
        _localJsonMeta,
        localJson.isAcceptableOrUnknown(data['local_json']!, _localJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_localJsonMeta);
    }
    if (data.containsKey('remote_json')) {
      context.handle(
        _remoteJsonMeta,
        remoteJson.isAcceptableOrUnknown(data['remote_json']!, _remoteJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteJsonMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('chosen_side')) {
      context.handle(
        _chosenSideMeta,
        chosenSide.isAcceptableOrUnknown(data['chosen_side']!, _chosenSideMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId, field};
  @override
  ConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictRow(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      localJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_json'],
      )!,
      remoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_json'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_at'],
      ),
      chosenSide: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chosen_side'],
      ),
    );
  }

  @override
  $ConflictsTable createAlias(String alias) {
    return $ConflictsTable(attachedDatabase, alias);
  }
}

class ConflictRow extends DataClass implements Insertable<ConflictRow> {
  final String entityType;
  final String entityId;
  final String field;
  final String localJson;
  final String remoteJson;
  final String detectedAt;
  final String? resolvedAt;
  final String? chosenSide;
  const ConflictRow({
    required this.entityType,
    required this.entityId,
    required this.field,
    required this.localJson,
    required this.remoteJson,
    required this.detectedAt,
    this.resolvedAt,
    this.chosenSide,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    map['local_json'] = Variable<String>(localJson);
    map['remote_json'] = Variable<String>(remoteJson);
    map['detected_at'] = Variable<String>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<String>(resolvedAt);
    }
    if (!nullToAbsent || chosenSide != null) {
      map['chosen_side'] = Variable<String>(chosenSide);
    }
    return map;
  }

  ConflictsCompanion toCompanion(bool nullToAbsent) {
    return ConflictsCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      field: Value(field),
      localJson: Value(localJson),
      remoteJson: Value(remoteJson),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      chosenSide: chosenSide == null && nullToAbsent
          ? const Value.absent()
          : Value(chosenSide),
    );
  }

  factory ConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictRow(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      localJson: serializer.fromJson<String>(json['localJson']),
      remoteJson: serializer.fromJson<String>(json['remoteJson']),
      detectedAt: serializer.fromJson<String>(json['detectedAt']),
      resolvedAt: serializer.fromJson<String?>(json['resolvedAt']),
      chosenSide: serializer.fromJson<String?>(json['chosenSide']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'localJson': serializer.toJson<String>(localJson),
      'remoteJson': serializer.toJson<String>(remoteJson),
      'detectedAt': serializer.toJson<String>(detectedAt),
      'resolvedAt': serializer.toJson<String?>(resolvedAt),
      'chosenSide': serializer.toJson<String?>(chosenSide),
    };
  }

  ConflictRow copyWith({
    String? entityType,
    String? entityId,
    String? field,
    String? localJson,
    String? remoteJson,
    String? detectedAt,
    Value<String?> resolvedAt = const Value.absent(),
    Value<String?> chosenSide = const Value.absent(),
  }) => ConflictRow(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    localJson: localJson ?? this.localJson,
    remoteJson: remoteJson ?? this.remoteJson,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    chosenSide: chosenSide.present ? chosenSide.value : this.chosenSide,
  );
  ConflictRow copyWithCompanion(ConflictsCompanion data) {
    return ConflictRow(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      localJson: data.localJson.present ? data.localJson.value : this.localJson,
      remoteJson: data.remoteJson.present
          ? data.remoteJson.value
          : this.remoteJson,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      chosenSide: data.chosenSide.present
          ? data.chosenSide.value
          : this.chosenSide,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictRow(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('chosenSide: $chosenSide')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityType,
    entityId,
    field,
    localJson,
    remoteJson,
    detectedAt,
    resolvedAt,
    chosenSide,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictRow &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.localJson == this.localJson &&
          other.remoteJson == this.remoteJson &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.chosenSide == this.chosenSide);
}

class ConflictsCompanion extends UpdateCompanion<ConflictRow> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String> localJson;
  final Value<String> remoteJson;
  final Value<String> detectedAt;
  final Value<String?> resolvedAt;
  final Value<String?> chosenSide;
  final Value<int> rowid;
  const ConflictsCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.localJson = const Value.absent(),
    this.remoteJson = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.chosenSide = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflictsCompanion.insert({
    required String entityType,
    required String entityId,
    required String field,
    required String localJson,
    required String remoteJson,
    required String detectedAt,
    this.resolvedAt = const Value.absent(),
    this.chosenSide = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       field = Value(field),
       localJson = Value(localJson),
       remoteJson = Value(remoteJson),
       detectedAt = Value(detectedAt);
  static Insertable<ConflictRow> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? localJson,
    Expression<String>? remoteJson,
    Expression<String>? detectedAt,
    Expression<String>? resolvedAt,
    Expression<String>? chosenSide,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (localJson != null) 'local_json': localJson,
      if (remoteJson != null) 'remote_json': remoteJson,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (chosenSide != null) 'chosen_side': chosenSide,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflictsCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? field,
    Value<String>? localJson,
    Value<String>? remoteJson,
    Value<String>? detectedAt,
    Value<String?>? resolvedAt,
    Value<String?>? chosenSide,
    Value<int>? rowid,
  }) {
    return ConflictsCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      localJson: localJson ?? this.localJson,
      remoteJson: remoteJson ?? this.remoteJson,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      chosenSide: chosenSide ?? this.chosenSide,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (localJson.present) {
      map['local_json'] = Variable<String>(localJson.value);
    }
    if (remoteJson.present) {
      map['remote_json'] = Variable<String>(remoteJson.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<String>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<String>(resolvedAt.value);
    }
    if (chosenSide.present) {
      map['chosen_side'] = Variable<String>(chosenSide.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('chosenSide: $chosenSide, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportReportsTable extends ImportReports
    with TableInfo<$ImportReportsTable, ImportReportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportJsonMeta = const VerificationMeta(
    'reportJson',
  );
  @override
  late final GeneratedColumn<String> reportJson = GeneratedColumn<String>(
    'report_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, source, at, reportJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportReportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('report_json')) {
      context.handle(
        _reportJsonMeta,
        reportJson.isAcceptableOrUnknown(data['report_json']!, _reportJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_reportJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportReportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportReportRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      reportJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_json'],
      )!,
    );
  }

  @override
  $ImportReportsTable createAlias(String alias) {
    return $ImportReportsTable(attachedDatabase, alias);
  }
}

class ImportReportRow extends DataClass implements Insertable<ImportReportRow> {
  final String id;
  final String source;
  final String at;
  final String reportJson;
  const ImportReportRow({
    required this.id,
    required this.source,
    required this.at,
    required this.reportJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['at'] = Variable<String>(at);
    map['report_json'] = Variable<String>(reportJson);
    return map;
  }

  ImportReportsCompanion toCompanion(bool nullToAbsent) {
    return ImportReportsCompanion(
      id: Value(id),
      source: Value(source),
      at: Value(at),
      reportJson: Value(reportJson),
    );
  }

  factory ImportReportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportReportRow(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      at: serializer.fromJson<String>(json['at']),
      reportJson: serializer.fromJson<String>(json['reportJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'at': serializer.toJson<String>(at),
      'reportJson': serializer.toJson<String>(reportJson),
    };
  }

  ImportReportRow copyWith({
    String? id,
    String? source,
    String? at,
    String? reportJson,
  }) => ImportReportRow(
    id: id ?? this.id,
    source: source ?? this.source,
    at: at ?? this.at,
    reportJson: reportJson ?? this.reportJson,
  );
  ImportReportRow copyWithCompanion(ImportReportsCompanion data) {
    return ImportReportRow(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      at: data.at.present ? data.at.value : this.at,
      reportJson: data.reportJson.present
          ? data.reportJson.value
          : this.reportJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportReportRow(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('at: $at, ')
          ..write('reportJson: $reportJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, source, at, reportJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportReportRow &&
          other.id == this.id &&
          other.source == this.source &&
          other.at == this.at &&
          other.reportJson == this.reportJson);
}

class ImportReportsCompanion extends UpdateCompanion<ImportReportRow> {
  final Value<String> id;
  final Value<String> source;
  final Value<String> at;
  final Value<String> reportJson;
  final Value<int> rowid;
  const ImportReportsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.at = const Value.absent(),
    this.reportJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportReportsCompanion.insert({
    required String id,
    required String source,
    required String at,
    required String reportJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       source = Value(source),
       at = Value(at),
       reportJson = Value(reportJson);
  static Insertable<ImportReportRow> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<String>? at,
    Expression<String>? reportJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (at != null) 'at': at,
      if (reportJson != null) 'report_json': reportJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? source,
    Value<String>? at,
    Value<String>? reportJson,
    Value<int>? rowid,
  }) {
    return ImportReportsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      at: at ?? this.at,
      reportJson: reportJson ?? this.reportJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (reportJson.present) {
      map['report_json'] = Variable<String>(reportJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportReportsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('at: $at, ')
          ..write('reportJson: $reportJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $CreditCardsTable creditCards = $CreditCardsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $LoansTable loans = $LoansTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionTagsTable transactionTags = $TransactionTagsTable(
    this,
  );
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurrenceRulesTable recurrenceRules = $RecurrenceRulesTable(
    this,
  );
  late final $ShoppingListsTable shoppingLists = $ShoppingListsTable(this);
  late final $ShoppingListItemsTable shoppingListItems =
      $ShoppingListItemsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductInternalCodesTable productInternalCodes =
      $ProductInternalCodesTable(this);
  late final $PriceObservationsTable priceObservations =
      $PriceObservationsTable(this);
  late final $ShoppingSessionsTable shoppingSessions = $ShoppingSessionsTable(
    this,
  );
  late final $ShoppingSessionLinesTable shoppingSessionLines =
      $ShoppingSessionLinesTable(this);
  late final $ShoppingSessionEventsTable shoppingSessionEvents =
      $ShoppingSessionEventsTable(this);
  late final $ShoppingEvidenceTable shoppingEvidence = $ShoppingEvidenceTable(
    this,
  );
  late final $ShoppingReceiptLinesTable shoppingReceiptLines =
      $ShoppingReceiptLinesTable(this);
  late final $KvTable kv = $KvTable(this);
  late final $ChangeLogEntriesTable changeLogEntries = $ChangeLogEntriesTable(
    this,
  );
  late final $ConflictsTable conflicts = $ConflictsTable(this);
  late final $ImportReportsTable importReports = $ImportReportsTable(this);
  late final Index idxAccountsDeleted = Index(
    'idx_accounts_deleted',
    'CREATE INDEX idx_accounts_deleted ON accounts (deleted_at)',
  );
  late final Index idxCategoriesParent = Index(
    'idx_categories_parent',
    'CREATE INDEX idx_categories_parent ON categories (parent_id)',
  );
  late final Index idxTxDate = Index(
    'idx_tx_date',
    'CREATE INDEX idx_tx_date ON transactions (date)',
  );
  late final Index idxTxKindDate = Index(
    'idx_tx_kind_date',
    'CREATE INDEX idx_tx_kind_date ON transactions (kind, date)',
  );
  late final Index idxTxAccount = Index(
    'idx_tx_account',
    'CREATE INDEX idx_tx_account ON transactions (account_id)',
  );
  late final Index idxTxCardInvoice = Index(
    'idx_tx_card_invoice',
    'CREATE INDEX idx_tx_card_invoice ON transactions (card_id, invoice_month)',
  );
  late final Index idxTxCategory = Index(
    'idx_tx_category',
    'CREATE INDEX idx_tx_category ON transactions (category_id)',
  );
  late final Index idxTxSeries = Index(
    'idx_tx_series',
    'CREATE INDEX idx_tx_series ON transactions (series_id)',
  );
  late final Index idxTxDeleted = Index(
    'idx_tx_deleted',
    'CREATE INDEX idx_tx_deleted ON transactions (deleted_at)',
  );
  late final Index idxTxDue = Index(
    'idx_tx_due',
    'CREATE INDEX idx_tx_due ON transactions (due_date)',
  );
  late final Index idxTxExternalRef = Index(
    'idx_tx_external_ref',
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_tx_external_ref ON transactions (external_ref) WHERE external_ref IS NOT NULL',
  );
  late final Index idxTxTagsTag = Index(
    'idx_tx_tags_tag',
    'CREATE INDEX idx_tx_tags_tag ON transaction_tags (tag_id)',
  );
  late final Index idxAttachmentsTx = Index(
    'idx_attachments_tx',
    'CREATE INDEX idx_attachments_tx ON attachments (transaction_id)',
  );
  late final Index idxBudgetsMonth = Index(
    'idx_budgets_month',
    'CREATE INDEX idx_budgets_month ON budgets (month)',
  );
  late final Index idxListsArchived = Index(
    'idx_lists_archived',
    'CREATE INDEX idx_lists_archived ON shopping_lists (archived)',
  );
  late final Index idxListItemsList = Index(
    'idx_list_items_list',
    'CREATE INDEX idx_list_items_list ON shopping_list_items (list_id)',
  );
  late final Index idxProductsBarcode = Index(
    'idx_products_barcode',
    'CREATE INDEX idx_products_barcode ON products (barcode)',
  );
  late final Index idxObsProductAt = Index(
    'idx_obs_product_at',
    'CREATE INDEX idx_obs_product_at ON price_observations (product_id, observed_at)',
  );
  late final Index idxSessionsStatus = Index(
    'idx_sessions_status',
    'CREATE INDEX idx_sessions_status ON shopping_sessions (status)',
  );
  late final Index idxSessionsStarted = Index(
    'idx_sessions_started',
    'CREATE INDEX idx_sessions_started ON shopping_sessions (started_at)',
  );
  late final Index idxSessionLinesSession = Index(
    'idx_session_lines_session',
    'CREATE INDEX idx_session_lines_session ON shopping_session_lines (session_id)',
  );
  late final Index idxSessionEventsSession = Index(
    'idx_session_events_session',
    'CREATE INDEX idx_session_events_session ON shopping_session_events (session_id)',
  );
  late final Index idxEvidenceSession = Index(
    'idx_evidence_session',
    'CREATE INDEX idx_evidence_session ON shopping_evidence (session_id)',
  );
  late final Index idxReceiptLinesSession = Index(
    'idx_receipt_lines_session',
    'CREATE INDEX idx_receipt_lines_session ON shopping_receipt_lines (session_id)',
  );
  late final Index idxChangeLogSynced = Index(
    'idx_change_log_synced',
    'CREATE INDEX idx_change_log_synced ON change_log_entries (synced, at)',
  );
  late final Index idxChangeLogEntity = Index(
    'idx_change_log_entity',
    'CREATE INDEX idx_change_log_entity ON change_log_entries (entity_type, entity_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    tags,
    creditCards,
    goals,
    loans,
    transactions,
    transactionTags,
    attachments,
    budgets,
    recurrenceRules,
    shoppingLists,
    shoppingListItems,
    products,
    productInternalCodes,
    priceObservations,
    shoppingSessions,
    shoppingSessionLines,
    shoppingSessionEvents,
    shoppingEvidence,
    shoppingReceiptLines,
    kv,
    changeLogEntries,
    conflicts,
    importReports,
    idxAccountsDeleted,
    idxCategoriesParent,
    idxTxDate,
    idxTxKindDate,
    idxTxAccount,
    idxTxCardInvoice,
    idxTxCategory,
    idxTxSeries,
    idxTxDeleted,
    idxTxDue,
    idxTxExternalRef,
    idxTxTagsTag,
    idxAttachmentsTx,
    idxBudgetsMonth,
    idxListsArchived,
    idxListItemsList,
    idxProductsBarcode,
    idxObsProductAt,
    idxSessionsStatus,
    idxSessionsStarted,
    idxSessionLinesSession,
    idxSessionEventsSession,
    idxEvidenceSession,
    idxReceiptLinesSession,
    idxChangeLogSynced,
    idxChangeLogEntity,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaction_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaction_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shopping_list_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('product_internal_codes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('price_observations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shopping_session_lines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shopping_session_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shopping_evidence', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shopping_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shopping_receipt_lines', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
