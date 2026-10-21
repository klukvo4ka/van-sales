// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrucksTable extends Trucks with TableInfo<$TrucksTable, Truck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrucksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plateNumberMeta =
      const VerificationMeta('plateNumber');
  @override
  late final GeneratedColumn<String> plateNumber = GeneratedColumn<String>(
      'plate_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, plateNumber, name, isActive, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trucks';
  @override
  VerificationContext validateIntegrity(Insertable<Truck> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plate_number')) {
      context.handle(
          _plateNumberMeta,
          plateNumber.isAcceptableOrUnknown(
              data['plate_number']!, _plateNumberMeta));
    } else if (isInserting) {
      context.missing(_plateNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Truck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Truck(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      plateNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plate_number'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $TrucksTable createAlias(String alias) {
    return $TrucksTable(attachedDatabase, alias);
  }
}

class Truck extends DataClass implements Insertable<Truck> {
  final String id;
  final String plateNumber;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final bool synced;
  const Truck(
      {required this.id,
      required this.plateNumber,
      required this.name,
      required this.isActive,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plate_number'] = Variable<String>(plateNumber);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  TrucksCompanion toCompanion(bool nullToAbsent) {
    return TrucksCompanion(
      id: Value(id),
      plateNumber: Value(plateNumber),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Truck.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Truck(
      id: serializer.fromJson<String>(json['id']),
      plateNumber: serializer.fromJson<String>(json['plateNumber']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plateNumber': serializer.toJson<String>(plateNumber),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Truck copyWith(
          {String? id,
          String? plateNumber,
          String? name,
          bool? isActive,
          DateTime? createdAt,
          bool? synced}) =>
      Truck(
        id: id ?? this.id,
        plateNumber: plateNumber ?? this.plateNumber,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  Truck copyWithCompanion(TrucksCompanion data) {
    return Truck(
      id: data.id.present ? data.id.value : this.id,
      plateNumber:
          data.plateNumber.present ? data.plateNumber.value : this.plateNumber,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Truck(')
          ..write('id: $id, ')
          ..write('plateNumber: $plateNumber, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, plateNumber, name, isActive, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Truck &&
          other.id == this.id &&
          other.plateNumber == this.plateNumber &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class TrucksCompanion extends UpdateCompanion<Truck> {
  final Value<String> id;
  final Value<String> plateNumber;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const TrucksCompanion({
    this.id = const Value.absent(),
    this.plateNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrucksCompanion.insert({
    required String id,
    required String plateNumber,
    required String name,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        plateNumber = Value(plateNumber),
        name = Value(name);
  static Insertable<Truck> custom({
    Expression<String>? id,
    Expression<String>? plateNumber,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plateNumber != null) 'plate_number': plateNumber,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrucksCompanion copyWith(
      {Value<String>? id,
      Value<String>? plateNumber,
      Value<String>? name,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return TrucksCompanion(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
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
    if (plateNumber.present) {
      map['plate_number'] = Variable<String>(plateNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('TrucksCompanion(')
          ..write('id: $id, ')
          ..write('plateNumber: $plateNumber, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameFaMeta = const VerificationMeta('nameFa');
  @override
  late final GeneratedColumn<String> nameFa = GeneratedColumn<String>(
      'name_fa', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, nameFa, sortOrder, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_fa')) {
      context.handle(_nameFaMeta,
          nameFa.isAcceptableOrUnknown(data['name_fa']!, _nameFaMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameFa: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_fa']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String? nameFa;
  final int sortOrder;
  final DateTime updatedAt;
  const Category(
      {required this.id,
      required this.name,
      this.nameFa,
      required this.sortOrder,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameFa != null) {
      map['name_fa'] = Variable<String>(nameFa);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      nameFa:
          nameFa == null && nullToAbsent ? const Value.absent() : Value(nameFa),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameFa: serializer.fromJson<String?>(json['nameFa']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nameFa': serializer.toJson<String?>(nameFa),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith(
          {String? id,
          String? name,
          Value<String?> nameFa = const Value.absent(),
          int? sortOrder,
          DateTime? updatedAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        nameFa: nameFa.present ? nameFa.value : this.nameFa,
        sortOrder: sortOrder ?? this.sortOrder,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameFa: data.nameFa.present ? data.nameFa.value : this.nameFa,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFa: $nameFa, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameFa, sortOrder, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameFa == this.nameFa &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> nameFa;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameFa = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.nameFa = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nameFa,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameFa != null) 'name_fa': nameFa,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? nameFa,
      Value<int>? sortOrder,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameFa: nameFa ?? this.nameFa,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameFa.present) {
      map['name_fa'] = Variable<String>(nameFa.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFa: $nameFa, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameFaMeta = const VerificationMeta('nameFa');
  @override
  late final GeneratedColumn<String> nameFa = GeneratedColumn<String>(
      'name_fa', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pcs'));
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        nameFa,
        sku,
        unit,
        price,
        categoryId,
        isActive,
        updatedAt,
        createdAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_fa')) {
      context.handle(_nameFaMeta,
          nameFa.isAcceptableOrUnknown(data['name_fa']!, _nameFaMeta));
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameFa: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_fa']),
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String name;
  final String? nameFa;
  final String? sku;
  final String unit;
  final double price;
  final String? categoryId;
  final bool isActive;
  final DateTime updatedAt;
  final DateTime createdAt;
  final bool synced;
  const Product(
      {required this.id,
      required this.name,
      this.nameFa,
      this.sku,
      required this.unit,
      required this.price,
      this.categoryId,
      required this.isActive,
      required this.updatedAt,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameFa != null) {
      map['name_fa'] = Variable<String>(nameFa);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    map['unit'] = Variable<String>(unit);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      nameFa:
          nameFa == null && nullToAbsent ? const Value.absent() : Value(nameFa),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      unit: Value(unit),
      price: Value(price),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameFa: serializer.fromJson<String?>(json['nameFa']),
      sku: serializer.fromJson<String?>(json['sku']),
      unit: serializer.fromJson<String>(json['unit']),
      price: serializer.fromJson<double>(json['price']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nameFa': serializer.toJson<String?>(nameFa),
      'sku': serializer.toJson<String?>(sku),
      'unit': serializer.toJson<String>(unit),
      'price': serializer.toJson<double>(price),
      'categoryId': serializer.toJson<String?>(categoryId),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Product copyWith(
          {String? id,
          String? name,
          Value<String?> nameFa = const Value.absent(),
          Value<String?> sku = const Value.absent(),
          String? unit,
          double? price,
          Value<String?> categoryId = const Value.absent(),
          bool? isActive,
          DateTime? updatedAt,
          DateTime? createdAt,
          bool? synced}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        nameFa: nameFa.present ? nameFa.value : this.nameFa,
        sku: sku.present ? sku.value : this.sku,
        unit: unit ?? this.unit,
        price: price ?? this.price,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameFa: data.nameFa.present ? data.nameFa.value : this.nameFa,
      sku: data.sku.present ? data.sku.value : this.sku,
      unit: data.unit.present ? data.unit.value : this.unit,
      price: data.price.present ? data.price.value : this.price,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFa: $nameFa, ')
          ..write('sku: $sku, ')
          ..write('unit: $unit, ')
          ..write('price: $price, ')
          ..write('categoryId: $categoryId, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameFa, sku, unit, price,
      categoryId, isActive, updatedAt, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameFa == this.nameFa &&
          other.sku == this.sku &&
          other.unit == this.unit &&
          other.price == this.price &&
          other.categoryId == this.categoryId &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> nameFa;
  final Value<String?> sku;
  final Value<String> unit;
  final Value<double> price;
  final Value<String?> categoryId;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameFa = const Value.absent(),
    this.sku = const Value.absent(),
    this.unit = const Value.absent(),
    this.price = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    this.nameFa = const Value.absent(),
    this.sku = const Value.absent(),
    this.unit = const Value.absent(),
    this.price = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nameFa,
    Expression<String>? sku,
    Expression<String>? unit,
    Expression<double>? price,
    Expression<String>? categoryId,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameFa != null) 'name_fa': nameFa,
      if (sku != null) 'sku': sku,
      if (unit != null) 'unit': unit,
      if (price != null) 'price': price,
      if (categoryId != null) 'category_id': categoryId,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? nameFa,
      Value<String?>? sku,
      Value<String>? unit,
      Value<double>? price,
      Value<String?>? categoryId,
      Value<bool>? isActive,
      Value<DateTime>? updatedAt,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameFa: nameFa ?? this.nameFa,
      sku: sku ?? this.sku,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameFa.present) {
      map['name_fa'] = Variable<String>(nameFa.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFa: $nameFa, ')
          ..write('sku: $sku, ')
          ..write('unit: $unit, ')
          ..write('price: $price, ')
          ..write('categoryId: $categoryId, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _driverIdMeta =
      const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
      'driver_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _routeOrderMeta =
      const VerificationMeta('routeOrder');
  @override
  late final GeneratedColumn<int> routeOrder = GeneratedColumn<int>(
      'route_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _routeNameMeta =
      const VerificationMeta('routeName');
  @override
  late final GeneratedColumn<String> routeName = GeneratedColumn<String>(
      'route_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creditLimitMeta =
      const VerificationMeta('creditLimit');
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
      'credit_limit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _photoOutsidePathMeta =
      const VerificationMeta('photoOutsidePath');
  @override
  late final GeneratedColumn<String> photoOutsidePath = GeneratedColumn<String>(
      'photo_outside_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoInsidePathMeta =
      const VerificationMeta('photoInsidePath');
  @override
  late final GeneratedColumn<String> photoInsidePath = GeneratedColumn<String>(
      'photo_inside_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoOutsideUrlMeta =
      const VerificationMeta('photoOutsideUrl');
  @override
  late final GeneratedColumn<String> photoOutsideUrl = GeneratedColumn<String>(
      'photo_outside_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoInsideUrlMeta =
      const VerificationMeta('photoInsideUrl');
  @override
  late final GeneratedColumn<String> photoInsideUrl = GeneratedColumn<String>(
      'photo_inside_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _visitedDateMeta =
      const VerificationMeta('visitedDate');
  @override
  late final GeneratedColumn<DateTime> visitedDate = GeneratedColumn<DateTime>(
      'visited_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        phone,
        address,
        driverId,
        routeOrder,
        routeName,
        creditLimit,
        balance,
        photoOutsidePath,
        photoInsidePath,
        photoOutsideUrl,
        photoInsideUrl,
        visitedDate,
        isActive,
        isDeleted,
        updatedAt,
        createdAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('driver_id')) {
      context.handle(_driverIdMeta,
          driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta));
    }
    if (data.containsKey('route_order')) {
      context.handle(
          _routeOrderMeta,
          routeOrder.isAcceptableOrUnknown(
              data['route_order']!, _routeOrderMeta));
    }
    if (data.containsKey('route_name')) {
      context.handle(_routeNameMeta,
          routeName.isAcceptableOrUnknown(data['route_name']!, _routeNameMeta));
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
          _creditLimitMeta,
          creditLimit.isAcceptableOrUnknown(
              data['credit_limit']!, _creditLimitMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('photo_outside_path')) {
      context.handle(
          _photoOutsidePathMeta,
          photoOutsidePath.isAcceptableOrUnknown(
              data['photo_outside_path']!, _photoOutsidePathMeta));
    }
    if (data.containsKey('photo_inside_path')) {
      context.handle(
          _photoInsidePathMeta,
          photoInsidePath.isAcceptableOrUnknown(
              data['photo_inside_path']!, _photoInsidePathMeta));
    }
    if (data.containsKey('photo_outside_url')) {
      context.handle(
          _photoOutsideUrlMeta,
          photoOutsideUrl.isAcceptableOrUnknown(
              data['photo_outside_url']!, _photoOutsideUrlMeta));
    }
    if (data.containsKey('photo_inside_url')) {
      context.handle(
          _photoInsideUrlMeta,
          photoInsideUrl.isAcceptableOrUnknown(
              data['photo_inside_url']!, _photoInsideUrlMeta));
    }
    if (data.containsKey('visited_date')) {
      context.handle(
          _visitedDateMeta,
          visitedDate.isAcceptableOrUnknown(
              data['visited_date']!, _visitedDateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      driverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_id']),
      routeOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}route_order'])!,
      routeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route_name']),
      creditLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credit_limit'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      photoOutsidePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}photo_outside_path']),
      photoInsidePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}photo_inside_path']),
      photoOutsideUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}photo_outside_url']),
      photoInsideUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}photo_inside_url']),
      visitedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}visited_date']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? driverId;
  final int routeOrder;
  final String? routeName;
  final double creditLimit;
  final double balance;
  final String? photoOutsidePath;
  final String? photoInsidePath;
  final String? photoOutsideUrl;
  final String? photoInsideUrl;
  final DateTime? visitedDate;
  final bool isActive;
  final bool isDeleted;
  final DateTime updatedAt;
  final DateTime createdAt;
  final bool synced;
  const Customer(
      {required this.id,
      required this.name,
      this.phone,
      this.address,
      this.driverId,
      required this.routeOrder,
      this.routeName,
      required this.creditLimit,
      required this.balance,
      this.photoOutsidePath,
      this.photoInsidePath,
      this.photoOutsideUrl,
      this.photoInsideUrl,
      this.visitedDate,
      required this.isActive,
      required this.isDeleted,
      required this.updatedAt,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || driverId != null) {
      map['driver_id'] = Variable<String>(driverId);
    }
    map['route_order'] = Variable<int>(routeOrder);
    if (!nullToAbsent || routeName != null) {
      map['route_name'] = Variable<String>(routeName);
    }
    map['credit_limit'] = Variable<double>(creditLimit);
    map['balance'] = Variable<double>(balance);
    if (!nullToAbsent || photoOutsidePath != null) {
      map['photo_outside_path'] = Variable<String>(photoOutsidePath);
    }
    if (!nullToAbsent || photoInsidePath != null) {
      map['photo_inside_path'] = Variable<String>(photoInsidePath);
    }
    if (!nullToAbsent || photoOutsideUrl != null) {
      map['photo_outside_url'] = Variable<String>(photoOutsideUrl);
    }
    if (!nullToAbsent || photoInsideUrl != null) {
      map['photo_inside_url'] = Variable<String>(photoInsideUrl);
    }
    if (!nullToAbsent || visitedDate != null) {
      map['visited_date'] = Variable<DateTime>(visitedDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      driverId: driverId == null && nullToAbsent
          ? const Value.absent()
          : Value(driverId),
      routeOrder: Value(routeOrder),
      routeName: routeName == null && nullToAbsent
          ? const Value.absent()
          : Value(routeName),
      creditLimit: Value(creditLimit),
      balance: Value(balance),
      photoOutsidePath: photoOutsidePath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoOutsidePath),
      photoInsidePath: photoInsidePath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoInsidePath),
      photoOutsideUrl: photoOutsideUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoOutsideUrl),
      photoInsideUrl: photoInsideUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoInsideUrl),
      visitedDate: visitedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(visitedDate),
      isActive: Value(isActive),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      driverId: serializer.fromJson<String?>(json['driverId']),
      routeOrder: serializer.fromJson<int>(json['routeOrder']),
      routeName: serializer.fromJson<String?>(json['routeName']),
      creditLimit: serializer.fromJson<double>(json['creditLimit']),
      balance: serializer.fromJson<double>(json['balance']),
      photoOutsidePath: serializer.fromJson<String?>(json['photoOutsidePath']),
      photoInsidePath: serializer.fromJson<String?>(json['photoInsidePath']),
      photoOutsideUrl: serializer.fromJson<String?>(json['photoOutsideUrl']),
      photoInsideUrl: serializer.fromJson<String?>(json['photoInsideUrl']),
      visitedDate: serializer.fromJson<DateTime?>(json['visitedDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'driverId': serializer.toJson<String?>(driverId),
      'routeOrder': serializer.toJson<int>(routeOrder),
      'routeName': serializer.toJson<String?>(routeName),
      'creditLimit': serializer.toJson<double>(creditLimit),
      'balance': serializer.toJson<double>(balance),
      'photoOutsidePath': serializer.toJson<String?>(photoOutsidePath),
      'photoInsidePath': serializer.toJson<String?>(photoInsidePath),
      'photoOutsideUrl': serializer.toJson<String?>(photoOutsideUrl),
      'photoInsideUrl': serializer.toJson<String?>(photoInsideUrl),
      'visitedDate': serializer.toJson<DateTime?>(visitedDate),
      'isActive': serializer.toJson<bool>(isActive),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Customer copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> driverId = const Value.absent(),
          int? routeOrder,
          Value<String?> routeName = const Value.absent(),
          double? creditLimit,
          double? balance,
          Value<String?> photoOutsidePath = const Value.absent(),
          Value<String?> photoInsidePath = const Value.absent(),
          Value<String?> photoOutsideUrl = const Value.absent(),
          Value<String?> photoInsideUrl = const Value.absent(),
          Value<DateTime?> visitedDate = const Value.absent(),
          bool? isActive,
          bool? isDeleted,
          DateTime? updatedAt,
          DateTime? createdAt,
          bool? synced}) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        address: address.present ? address.value : this.address,
        driverId: driverId.present ? driverId.value : this.driverId,
        routeOrder: routeOrder ?? this.routeOrder,
        routeName: routeName.present ? routeName.value : this.routeName,
        creditLimit: creditLimit ?? this.creditLimit,
        balance: balance ?? this.balance,
        photoOutsidePath: photoOutsidePath.present
            ? photoOutsidePath.value
            : this.photoOutsidePath,
        photoInsidePath: photoInsidePath.present
            ? photoInsidePath.value
            : this.photoInsidePath,
        photoOutsideUrl: photoOutsideUrl.present
            ? photoOutsideUrl.value
            : this.photoOutsideUrl,
        photoInsideUrl:
            photoInsideUrl.present ? photoInsideUrl.value : this.photoInsideUrl,
        visitedDate: visitedDate.present ? visitedDate.value : this.visitedDate,
        isActive: isActive ?? this.isActive,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      routeOrder:
          data.routeOrder.present ? data.routeOrder.value : this.routeOrder,
      routeName: data.routeName.present ? data.routeName.value : this.routeName,
      creditLimit:
          data.creditLimit.present ? data.creditLimit.value : this.creditLimit,
      balance: data.balance.present ? data.balance.value : this.balance,
      photoOutsidePath: data.photoOutsidePath.present
          ? data.photoOutsidePath.value
          : this.photoOutsidePath,
      photoInsidePath: data.photoInsidePath.present
          ? data.photoInsidePath.value
          : this.photoInsidePath,
      photoOutsideUrl: data.photoOutsideUrl.present
          ? data.photoOutsideUrl.value
          : this.photoOutsideUrl,
      photoInsideUrl: data.photoInsideUrl.present
          ? data.photoInsideUrl.value
          : this.photoInsideUrl,
      visitedDate:
          data.visitedDate.present ? data.visitedDate.value : this.visitedDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('driverId: $driverId, ')
          ..write('routeOrder: $routeOrder, ')
          ..write('routeName: $routeName, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('balance: $balance, ')
          ..write('photoOutsidePath: $photoOutsidePath, ')
          ..write('photoInsidePath: $photoInsidePath, ')
          ..write('photoOutsideUrl: $photoOutsideUrl, ')
          ..write('photoInsideUrl: $photoInsideUrl, ')
          ..write('visitedDate: $visitedDate, ')
          ..write('isActive: $isActive, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      phone,
      address,
      driverId,
      routeOrder,
      routeName,
      creditLimit,
      balance,
      photoOutsidePath,
      photoInsidePath,
      photoOutsideUrl,
      photoInsideUrl,
      visitedDate,
      isActive,
      isDeleted,
      updatedAt,
      createdAt,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.driverId == this.driverId &&
          other.routeOrder == this.routeOrder &&
          other.routeName == this.routeName &&
          other.creditLimit == this.creditLimit &&
          other.balance == this.balance &&
          other.photoOutsidePath == this.photoOutsidePath &&
          other.photoInsidePath == this.photoInsidePath &&
          other.photoOutsideUrl == this.photoOutsideUrl &&
          other.photoInsideUrl == this.photoInsideUrl &&
          other.visitedDate == this.visitedDate &&
          other.isActive == this.isActive &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> driverId;
  final Value<int> routeOrder;
  final Value<String?> routeName;
  final Value<double> creditLimit;
  final Value<double> balance;
  final Value<String?> photoOutsidePath;
  final Value<String?> photoInsidePath;
  final Value<String?> photoOutsideUrl;
  final Value<String?> photoInsideUrl;
  final Value<DateTime?> visitedDate;
  final Value<bool> isActive;
  final Value<bool> isDeleted;
  final Value<DateTime> updatedAt;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.driverId = const Value.absent(),
    this.routeOrder = const Value.absent(),
    this.routeName = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.balance = const Value.absent(),
    this.photoOutsidePath = const Value.absent(),
    this.photoInsidePath = const Value.absent(),
    this.photoOutsideUrl = const Value.absent(),
    this.photoInsideUrl = const Value.absent(),
    this.visitedDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.driverId = const Value.absent(),
    this.routeOrder = const Value.absent(),
    this.routeName = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.balance = const Value.absent(),
    this.photoOutsidePath = const Value.absent(),
    this.photoInsidePath = const Value.absent(),
    this.photoOutsideUrl = const Value.absent(),
    this.photoInsideUrl = const Value.absent(),
    this.visitedDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? driverId,
    Expression<int>? routeOrder,
    Expression<String>? routeName,
    Expression<double>? creditLimit,
    Expression<double>? balance,
    Expression<String>? photoOutsidePath,
    Expression<String>? photoInsidePath,
    Expression<String>? photoOutsideUrl,
    Expression<String>? photoInsideUrl,
    Expression<DateTime>? visitedDate,
    Expression<bool>? isActive,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (driverId != null) 'driver_id': driverId,
      if (routeOrder != null) 'route_order': routeOrder,
      if (routeName != null) 'route_name': routeName,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (balance != null) 'balance': balance,
      if (photoOutsidePath != null) 'photo_outside_path': photoOutsidePath,
      if (photoInsidePath != null) 'photo_inside_path': photoInsidePath,
      if (photoOutsideUrl != null) 'photo_outside_url': photoOutsideUrl,
      if (photoInsideUrl != null) 'photo_inside_url': photoInsideUrl,
      if (visitedDate != null) 'visited_date': visitedDate,
      if (isActive != null) 'is_active': isActive,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? address,
      Value<String?>? driverId,
      Value<int>? routeOrder,
      Value<String?>? routeName,
      Value<double>? creditLimit,
      Value<double>? balance,
      Value<String?>? photoOutsidePath,
      Value<String?>? photoInsidePath,
      Value<String?>? photoOutsideUrl,
      Value<String?>? photoInsideUrl,
      Value<DateTime?>? visitedDate,
      Value<bool>? isActive,
      Value<bool>? isDeleted,
      Value<DateTime>? updatedAt,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      driverId: driverId ?? this.driverId,
      routeOrder: routeOrder ?? this.routeOrder,
      routeName: routeName ?? this.routeName,
      creditLimit: creditLimit ?? this.creditLimit,
      balance: balance ?? this.balance,
      photoOutsidePath: photoOutsidePath ?? this.photoOutsidePath,
      photoInsidePath: photoInsidePath ?? this.photoInsidePath,
      photoOutsideUrl: photoOutsideUrl ?? this.photoOutsideUrl,
      photoInsideUrl: photoInsideUrl ?? this.photoInsideUrl,
      visitedDate: visitedDate ?? this.visitedDate,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (routeOrder.present) {
      map['route_order'] = Variable<int>(routeOrder.value);
    }
    if (routeName.present) {
      map['route_name'] = Variable<String>(routeName.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (photoOutsidePath.present) {
      map['photo_outside_path'] = Variable<String>(photoOutsidePath.value);
    }
    if (photoInsidePath.present) {
      map['photo_inside_path'] = Variable<String>(photoInsidePath.value);
    }
    if (photoOutsideUrl.present) {
      map['photo_outside_url'] = Variable<String>(photoOutsideUrl.value);
    }
    if (photoInsideUrl.present) {
      map['photo_inside_url'] = Variable<String>(photoInsideUrl.value);
    }
    if (visitedDate.present) {
      map['visited_date'] = Variable<DateTime>(visitedDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('driverId: $driverId, ')
          ..write('routeOrder: $routeOrder, ')
          ..write('routeName: $routeName, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('balance: $balance, ')
          ..write('photoOutsidePath: $photoOutsidePath, ')
          ..write('photoInsidePath: $photoInsidePath, ')
          ..write('photoOutsideUrl: $photoOutsideUrl, ')
          ..write('photoInsideUrl: $photoInsideUrl, ')
          ..write('visitedDate: $visitedDate, ')
          ..write('isActive: $isActive, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DriverProfilesTable extends DriverProfiles
    with TableInfo<$DriverProfilesTable, DriverProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriverProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _truckIdMeta =
      const VerificationMeta('truckId');
  @override
  late final GeneratedColumn<String> truckId = GeneratedColumn<String>(
      'truck_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('driver'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, fullName, phone, truckId, role, isActive, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'driver_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<DriverProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('truck_id')) {
      context.handle(_truckIdMeta,
          truckId.isAcceptableOrUnknown(data['truck_id']!, _truckIdMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriverProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriverProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      truckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}truck_id']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $DriverProfilesTable createAlias(String alias) {
    return $DriverProfilesTable(attachedDatabase, alias);
  }
}

class DriverProfile extends DataClass implements Insertable<DriverProfile> {
  final String id;
  final String fullName;
  final String? phone;
  final String? truckId;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final bool synced;
  const DriverProfile(
      {required this.id,
      required this.fullName,
      this.phone,
      this.truckId,
      required this.role,
      required this.isActive,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || truckId != null) {
      map['truck_id'] = Variable<String>(truckId);
    }
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DriverProfilesCompanion toCompanion(bool nullToAbsent) {
    return DriverProfilesCompanion(
      id: Value(id),
      fullName: Value(fullName),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      truckId: truckId == null && nullToAbsent
          ? const Value.absent()
          : Value(truckId),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory DriverProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriverProfile(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String?>(json['phone']),
      truckId: serializer.fromJson<String?>(json['truckId']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String?>(phone),
      'truckId': serializer.toJson<String?>(truckId),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DriverProfile copyWith(
          {String? id,
          String? fullName,
          Value<String?> phone = const Value.absent(),
          Value<String?> truckId = const Value.absent(),
          String? role,
          bool? isActive,
          DateTime? createdAt,
          bool? synced}) =>
      DriverProfile(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        phone: phone.present ? phone.value : this.phone,
        truckId: truckId.present ? truckId.value : this.truckId,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  DriverProfile copyWithCompanion(DriverProfilesCompanion data) {
    return DriverProfile(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      truckId: data.truckId.present ? data.truckId.value : this.truckId,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriverProfile(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('truckId: $truckId, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, fullName, phone, truckId, role, isActive, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriverProfile &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.truckId == this.truckId &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class DriverProfilesCompanion extends UpdateCompanion<DriverProfile> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> phone;
  final Value<String?> truckId;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const DriverProfilesCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.truckId = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DriverProfilesCompanion.insert({
    required String id,
    required String fullName,
    this.phone = const Value.absent(),
    this.truckId = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName);
  static Insertable<DriverProfile> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? truckId,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (truckId != null) 'truck_id': truckId,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DriverProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fullName,
      Value<String?>? phone,
      Value<String?>? truckId,
      Value<String>? role,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return DriverProfilesCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      truckId: truckId ?? this.truckId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
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
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (truckId.present) {
      map['truck_id'] = Variable<String>(truckId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('DriverProfilesCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('truckId: $truckId, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TruckLoadsTable extends TruckLoads
    with TableInfo<$TruckLoadsTable, TruckLoad> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TruckLoadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _truckIdMeta =
      const VerificationMeta('truckId');
  @override
  late final GeneratedColumn<String> truckId = GeneratedColumn<String>(
      'truck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _driverIdMeta =
      const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
      'driver_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _loadDateMeta =
      const VerificationMeta('loadDate');
  @override
  late final GeneratedColumn<DateTime> loadDate = GeneratedColumn<DateTime>(
      'load_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _billPhotoUrlMeta =
      const VerificationMeta('billPhotoUrl');
  @override
  late final GeneratedColumn<String> billPhotoUrl = GeneratedColumn<String>(
      'bill_photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _billPhotoPathMeta =
      const VerificationMeta('billPhotoPath');
  @override
  late final GeneratedColumn<String> billPhotoPath = GeneratedColumn<String>(
      'bill_photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        truckId,
        driverId,
        loadDate,
        status,
        billPhotoUrl,
        billPhotoPath,
        createdAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'truck_loads';
  @override
  VerificationContext validateIntegrity(Insertable<TruckLoad> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('truck_id')) {
      context.handle(_truckIdMeta,
          truckId.isAcceptableOrUnknown(data['truck_id']!, _truckIdMeta));
    } else if (isInserting) {
      context.missing(_truckIdMeta);
    }
    if (data.containsKey('driver_id')) {
      context.handle(_driverIdMeta,
          driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta));
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('load_date')) {
      context.handle(_loadDateMeta,
          loadDate.isAcceptableOrUnknown(data['load_date']!, _loadDateMeta));
    } else if (isInserting) {
      context.missing(_loadDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('bill_photo_url')) {
      context.handle(
          _billPhotoUrlMeta,
          billPhotoUrl.isAcceptableOrUnknown(
              data['bill_photo_url']!, _billPhotoUrlMeta));
    }
    if (data.containsKey('bill_photo_path')) {
      context.handle(
          _billPhotoPathMeta,
          billPhotoPath.isAcceptableOrUnknown(
              data['bill_photo_path']!, _billPhotoPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {truckId, loadDate},
      ];
  @override
  TruckLoad map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TruckLoad(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      truckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}truck_id'])!,
      driverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_id'])!,
      loadDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}load_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      billPhotoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bill_photo_url']),
      billPhotoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bill_photo_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $TruckLoadsTable createAlias(String alias) {
    return $TruckLoadsTable(attachedDatabase, alias);
  }
}

class TruckLoad extends DataClass implements Insertable<TruckLoad> {
  final String id;
  final String truckId;
  final String driverId;
  final DateTime loadDate;
  final String status;
  final String? billPhotoUrl;
  final String? billPhotoPath;
  final DateTime createdAt;
  final bool synced;
  const TruckLoad(
      {required this.id,
      required this.truckId,
      required this.driverId,
      required this.loadDate,
      required this.status,
      this.billPhotoUrl,
      this.billPhotoPath,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['truck_id'] = Variable<String>(truckId);
    map['driver_id'] = Variable<String>(driverId);
    map['load_date'] = Variable<DateTime>(loadDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || billPhotoUrl != null) {
      map['bill_photo_url'] = Variable<String>(billPhotoUrl);
    }
    if (!nullToAbsent || billPhotoPath != null) {
      map['bill_photo_path'] = Variable<String>(billPhotoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  TruckLoadsCompanion toCompanion(bool nullToAbsent) {
    return TruckLoadsCompanion(
      id: Value(id),
      truckId: Value(truckId),
      driverId: Value(driverId),
      loadDate: Value(loadDate),
      status: Value(status),
      billPhotoUrl: billPhotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(billPhotoUrl),
      billPhotoPath: billPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(billPhotoPath),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory TruckLoad.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TruckLoad(
      id: serializer.fromJson<String>(json['id']),
      truckId: serializer.fromJson<String>(json['truckId']),
      driverId: serializer.fromJson<String>(json['driverId']),
      loadDate: serializer.fromJson<DateTime>(json['loadDate']),
      status: serializer.fromJson<String>(json['status']),
      billPhotoUrl: serializer.fromJson<String?>(json['billPhotoUrl']),
      billPhotoPath: serializer.fromJson<String?>(json['billPhotoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'truckId': serializer.toJson<String>(truckId),
      'driverId': serializer.toJson<String>(driverId),
      'loadDate': serializer.toJson<DateTime>(loadDate),
      'status': serializer.toJson<String>(status),
      'billPhotoUrl': serializer.toJson<String?>(billPhotoUrl),
      'billPhotoPath': serializer.toJson<String?>(billPhotoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  TruckLoad copyWith(
          {String? id,
          String? truckId,
          String? driverId,
          DateTime? loadDate,
          String? status,
          Value<String?> billPhotoUrl = const Value.absent(),
          Value<String?> billPhotoPath = const Value.absent(),
          DateTime? createdAt,
          bool? synced}) =>
      TruckLoad(
        id: id ?? this.id,
        truckId: truckId ?? this.truckId,
        driverId: driverId ?? this.driverId,
        loadDate: loadDate ?? this.loadDate,
        status: status ?? this.status,
        billPhotoUrl:
            billPhotoUrl.present ? billPhotoUrl.value : this.billPhotoUrl,
        billPhotoPath:
            billPhotoPath.present ? billPhotoPath.value : this.billPhotoPath,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  TruckLoad copyWithCompanion(TruckLoadsCompanion data) {
    return TruckLoad(
      id: data.id.present ? data.id.value : this.id,
      truckId: data.truckId.present ? data.truckId.value : this.truckId,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      loadDate: data.loadDate.present ? data.loadDate.value : this.loadDate,
      status: data.status.present ? data.status.value : this.status,
      billPhotoUrl: data.billPhotoUrl.present
          ? data.billPhotoUrl.value
          : this.billPhotoUrl,
      billPhotoPath: data.billPhotoPath.present
          ? data.billPhotoPath.value
          : this.billPhotoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TruckLoad(')
          ..write('id: $id, ')
          ..write('truckId: $truckId, ')
          ..write('driverId: $driverId, ')
          ..write('loadDate: $loadDate, ')
          ..write('status: $status, ')
          ..write('billPhotoUrl: $billPhotoUrl, ')
          ..write('billPhotoPath: $billPhotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, truckId, driverId, loadDate, status,
      billPhotoUrl, billPhotoPath, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TruckLoad &&
          other.id == this.id &&
          other.truckId == this.truckId &&
          other.driverId == this.driverId &&
          other.loadDate == this.loadDate &&
          other.status == this.status &&
          other.billPhotoUrl == this.billPhotoUrl &&
          other.billPhotoPath == this.billPhotoPath &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class TruckLoadsCompanion extends UpdateCompanion<TruckLoad> {
  final Value<String> id;
  final Value<String> truckId;
  final Value<String> driverId;
  final Value<DateTime> loadDate;
  final Value<String> status;
  final Value<String?> billPhotoUrl;
  final Value<String?> billPhotoPath;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const TruckLoadsCompanion({
    this.id = const Value.absent(),
    this.truckId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.loadDate = const Value.absent(),
    this.status = const Value.absent(),
    this.billPhotoUrl = const Value.absent(),
    this.billPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TruckLoadsCompanion.insert({
    required String id,
    required String truckId,
    required String driverId,
    required DateTime loadDate,
    this.status = const Value.absent(),
    this.billPhotoUrl = const Value.absent(),
    this.billPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        truckId = Value(truckId),
        driverId = Value(driverId),
        loadDate = Value(loadDate);
  static Insertable<TruckLoad> custom({
    Expression<String>? id,
    Expression<String>? truckId,
    Expression<String>? driverId,
    Expression<DateTime>? loadDate,
    Expression<String>? status,
    Expression<String>? billPhotoUrl,
    Expression<String>? billPhotoPath,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (truckId != null) 'truck_id': truckId,
      if (driverId != null) 'driver_id': driverId,
      if (loadDate != null) 'load_date': loadDate,
      if (status != null) 'status': status,
      if (billPhotoUrl != null) 'bill_photo_url': billPhotoUrl,
      if (billPhotoPath != null) 'bill_photo_path': billPhotoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TruckLoadsCompanion copyWith(
      {Value<String>? id,
      Value<String>? truckId,
      Value<String>? driverId,
      Value<DateTime>? loadDate,
      Value<String>? status,
      Value<String?>? billPhotoUrl,
      Value<String?>? billPhotoPath,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return TruckLoadsCompanion(
      id: id ?? this.id,
      truckId: truckId ?? this.truckId,
      driverId: driverId ?? this.driverId,
      loadDate: loadDate ?? this.loadDate,
      status: status ?? this.status,
      billPhotoUrl: billPhotoUrl ?? this.billPhotoUrl,
      billPhotoPath: billPhotoPath ?? this.billPhotoPath,
      createdAt: createdAt ?? this.createdAt,
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
    if (truckId.present) {
      map['truck_id'] = Variable<String>(truckId.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (loadDate.present) {
      map['load_date'] = Variable<DateTime>(loadDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (billPhotoUrl.present) {
      map['bill_photo_url'] = Variable<String>(billPhotoUrl.value);
    }
    if (billPhotoPath.present) {
      map['bill_photo_path'] = Variable<String>(billPhotoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('TruckLoadsCompanion(')
          ..write('id: $id, ')
          ..write('truckId: $truckId, ')
          ..write('driverId: $driverId, ')
          ..write('loadDate: $loadDate, ')
          ..write('status: $status, ')
          ..write('billPhotoUrl: $billPhotoUrl, ')
          ..write('billPhotoPath: $billPhotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TruckLoadItemsTable extends TruckLoadItems
    with TableInfo<$TruckLoadItemsTable, TruckLoadItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TruckLoadItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _loadIdMeta = const VerificationMeta('loadId');
  @override
  late final GeneratedColumn<String> loadId = GeneratedColumn<String>(
      'load_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requestedQtyMeta =
      const VerificationMeta('requestedQty');
  @override
  late final GeneratedColumn<double> requestedQty = GeneratedColumn<double>(
      'requested_qty', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quantityLoadedMeta =
      const VerificationMeta('quantityLoaded');
  @override
  late final GeneratedColumn<double> quantityLoaded = GeneratedColumn<double>(
      'quantity_loaded', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quantityReturnedMeta =
      const VerificationMeta('quantityReturned');
  @override
  late final GeneratedColumn<double> quantityReturned = GeneratedColumn<double>(
      'quantity_returned', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        loadId,
        productId,
        requestedQty,
        quantityLoaded,
        quantityReturned,
        createdAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'truck_load_items';
  @override
  VerificationContext validateIntegrity(Insertable<TruckLoadItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('load_id')) {
      context.handle(_loadIdMeta,
          loadId.isAcceptableOrUnknown(data['load_id']!, _loadIdMeta));
    } else if (isInserting) {
      context.missing(_loadIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('requested_qty')) {
      context.handle(
          _requestedQtyMeta,
          requestedQty.isAcceptableOrUnknown(
              data['requested_qty']!, _requestedQtyMeta));
    }
    if (data.containsKey('quantity_loaded')) {
      context.handle(
          _quantityLoadedMeta,
          quantityLoaded.isAcceptableOrUnknown(
              data['quantity_loaded']!, _quantityLoadedMeta));
    }
    if (data.containsKey('quantity_returned')) {
      context.handle(
          _quantityReturnedMeta,
          quantityReturned.isAcceptableOrUnknown(
              data['quantity_returned']!, _quantityReturnedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TruckLoadItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TruckLoadItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      loadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}load_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      requestedQty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}requested_qty'])!,
      quantityLoaded: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantity_loaded'])!,
      quantityReturned: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantity_returned'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $TruckLoadItemsTable createAlias(String alias) {
    return $TruckLoadItemsTable(attachedDatabase, alias);
  }
}

class TruckLoadItem extends DataClass implements Insertable<TruckLoadItem> {
  final String id;
  final String loadId;
  final String productId;
  final double requestedQty;
  final double quantityLoaded;
  final double quantityReturned;
  final DateTime createdAt;
  final bool synced;
  const TruckLoadItem(
      {required this.id,
      required this.loadId,
      required this.productId,
      required this.requestedQty,
      required this.quantityLoaded,
      required this.quantityReturned,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['load_id'] = Variable<String>(loadId);
    map['product_id'] = Variable<String>(productId);
    map['requested_qty'] = Variable<double>(requestedQty);
    map['quantity_loaded'] = Variable<double>(quantityLoaded);
    map['quantity_returned'] = Variable<double>(quantityReturned);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  TruckLoadItemsCompanion toCompanion(bool nullToAbsent) {
    return TruckLoadItemsCompanion(
      id: Value(id),
      loadId: Value(loadId),
      productId: Value(productId),
      requestedQty: Value(requestedQty),
      quantityLoaded: Value(quantityLoaded),
      quantityReturned: Value(quantityReturned),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory TruckLoadItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TruckLoadItem(
      id: serializer.fromJson<String>(json['id']),
      loadId: serializer.fromJson<String>(json['loadId']),
      productId: serializer.fromJson<String>(json['productId']),
      requestedQty: serializer.fromJson<double>(json['requestedQty']),
      quantityLoaded: serializer.fromJson<double>(json['quantityLoaded']),
      quantityReturned: serializer.fromJson<double>(json['quantityReturned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'loadId': serializer.toJson<String>(loadId),
      'productId': serializer.toJson<String>(productId),
      'requestedQty': serializer.toJson<double>(requestedQty),
      'quantityLoaded': serializer.toJson<double>(quantityLoaded),
      'quantityReturned': serializer.toJson<double>(quantityReturned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  TruckLoadItem copyWith(
          {String? id,
          String? loadId,
          String? productId,
          double? requestedQty,
          double? quantityLoaded,
          double? quantityReturned,
          DateTime? createdAt,
          bool? synced}) =>
      TruckLoadItem(
        id: id ?? this.id,
        loadId: loadId ?? this.loadId,
        productId: productId ?? this.productId,
        requestedQty: requestedQty ?? this.requestedQty,
        quantityLoaded: quantityLoaded ?? this.quantityLoaded,
        quantityReturned: quantityReturned ?? this.quantityReturned,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  TruckLoadItem copyWithCompanion(TruckLoadItemsCompanion data) {
    return TruckLoadItem(
      id: data.id.present ? data.id.value : this.id,
      loadId: data.loadId.present ? data.loadId.value : this.loadId,
      productId: data.productId.present ? data.productId.value : this.productId,
      requestedQty: data.requestedQty.present
          ? data.requestedQty.value
          : this.requestedQty,
      quantityLoaded: data.quantityLoaded.present
          ? data.quantityLoaded.value
          : this.quantityLoaded,
      quantityReturned: data.quantityReturned.present
          ? data.quantityReturned.value
          : this.quantityReturned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TruckLoadItem(')
          ..write('id: $id, ')
          ..write('loadId: $loadId, ')
          ..write('productId: $productId, ')
          ..write('requestedQty: $requestedQty, ')
          ..write('quantityLoaded: $quantityLoaded, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, loadId, productId, requestedQty,
      quantityLoaded, quantityReturned, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TruckLoadItem &&
          other.id == this.id &&
          other.loadId == this.loadId &&
          other.productId == this.productId &&
          other.requestedQty == this.requestedQty &&
          other.quantityLoaded == this.quantityLoaded &&
          other.quantityReturned == this.quantityReturned &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class TruckLoadItemsCompanion extends UpdateCompanion<TruckLoadItem> {
  final Value<String> id;
  final Value<String> loadId;
  final Value<String> productId;
  final Value<double> requestedQty;
  final Value<double> quantityLoaded;
  final Value<double> quantityReturned;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const TruckLoadItemsCompanion({
    this.id = const Value.absent(),
    this.loadId = const Value.absent(),
    this.productId = const Value.absent(),
    this.requestedQty = const Value.absent(),
    this.quantityLoaded = const Value.absent(),
    this.quantityReturned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TruckLoadItemsCompanion.insert({
    required String id,
    required String loadId,
    required String productId,
    this.requestedQty = const Value.absent(),
    this.quantityLoaded = const Value.absent(),
    this.quantityReturned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        loadId = Value(loadId),
        productId = Value(productId);
  static Insertable<TruckLoadItem> custom({
    Expression<String>? id,
    Expression<String>? loadId,
    Expression<String>? productId,
    Expression<double>? requestedQty,
    Expression<double>? quantityLoaded,
    Expression<double>? quantityReturned,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loadId != null) 'load_id': loadId,
      if (productId != null) 'product_id': productId,
      if (requestedQty != null) 'requested_qty': requestedQty,
      if (quantityLoaded != null) 'quantity_loaded': quantityLoaded,
      if (quantityReturned != null) 'quantity_returned': quantityReturned,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TruckLoadItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? loadId,
      Value<String>? productId,
      Value<double>? requestedQty,
      Value<double>? quantityLoaded,
      Value<double>? quantityReturned,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return TruckLoadItemsCompanion(
      id: id ?? this.id,
      loadId: loadId ?? this.loadId,
      productId: productId ?? this.productId,
      requestedQty: requestedQty ?? this.requestedQty,
      quantityLoaded: quantityLoaded ?? this.quantityLoaded,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      createdAt: createdAt ?? this.createdAt,
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
    if (loadId.present) {
      map['load_id'] = Variable<String>(loadId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (requestedQty.present) {
      map['requested_qty'] = Variable<double>(requestedQty.value);
    }
    if (quantityLoaded.present) {
      map['quantity_loaded'] = Variable<double>(quantityLoaded.value);
    }
    if (quantityReturned.present) {
      map['quantity_returned'] = Variable<double>(quantityReturned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('TruckLoadItemsCompanion(')
          ..write('id: $id, ')
          ..write('loadId: $loadId, ')
          ..write('productId: $productId, ')
          ..write('requestedQty: $requestedQty, ')
          ..write('quantityLoaded: $quantityLoaded, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TruckInitialStocksTable extends TruckInitialStocks
    with TableInfo<$TruckInitialStocksTable, TruckInitialStock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TruckInitialStocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _truckIdMeta =
      const VerificationMeta('truckId');
  @override
  late final GeneratedColumn<String> truckId = GeneratedColumn<String>(
      'truck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, truckId, productId, quantity, updatedAt, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'truck_initial_stocks';
  @override
  VerificationContext validateIntegrity(Insertable<TruckInitialStock> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('truck_id')) {
      context.handle(_truckIdMeta,
          truckId.isAcceptableOrUnknown(data['truck_id']!, _truckIdMeta));
    } else if (isInserting) {
      context.missing(_truckIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {truckId, productId},
      ];
  @override
  TruckInitialStock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TruckInitialStock(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      truckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}truck_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $TruckInitialStocksTable createAlias(String alias) {
    return $TruckInitialStocksTable(attachedDatabase, alias);
  }
}

class TruckInitialStock extends DataClass
    implements Insertable<TruckInitialStock> {
  final String id;
  final String truckId;
  final String productId;
  final double quantity;
  final DateTime updatedAt;
  final DateTime createdAt;
  final bool synced;
  const TruckInitialStock(
      {required this.id,
      required this.truckId,
      required this.productId,
      required this.quantity,
      required this.updatedAt,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['truck_id'] = Variable<String>(truckId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<double>(quantity);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  TruckInitialStocksCompanion toCompanion(bool nullToAbsent) {
    return TruckInitialStocksCompanion(
      id: Value(id),
      truckId: Value(truckId),
      productId: Value(productId),
      quantity: Value(quantity),
      updatedAt: Value(updatedAt),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory TruckInitialStock.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TruckInitialStock(
      id: serializer.fromJson<String>(json['id']),
      truckId: serializer.fromJson<String>(json['truckId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'truckId': serializer.toJson<String>(truckId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<double>(quantity),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  TruckInitialStock copyWith(
          {String? id,
          String? truckId,
          String? productId,
          double? quantity,
          DateTime? updatedAt,
          DateTime? createdAt,
          bool? synced}) =>
      TruckInitialStock(
        id: id ?? this.id,
        truckId: truckId ?? this.truckId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  TruckInitialStock copyWithCompanion(TruckInitialStocksCompanion data) {
    return TruckInitialStock(
      id: data.id.present ? data.id.value : this.id,
      truckId: data.truckId.present ? data.truckId.value : this.truckId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TruckInitialStock(')
          ..write('id: $id, ')
          ..write('truckId: $truckId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, truckId, productId, quantity, updatedAt, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TruckInitialStock &&
          other.id == this.id &&
          other.truckId == this.truckId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class TruckInitialStocksCompanion extends UpdateCompanion<TruckInitialStock> {
  final Value<String> id;
  final Value<String> truckId;
  final Value<String> productId;
  final Value<double> quantity;
  final Value<DateTime> updatedAt;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const TruckInitialStocksCompanion({
    this.id = const Value.absent(),
    this.truckId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TruckInitialStocksCompanion.insert({
    required String id,
    required String truckId,
    required String productId,
    this.quantity = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        truckId = Value(truckId),
        productId = Value(productId);
  static Insertable<TruckInitialStock> custom({
    Expression<String>? id,
    Expression<String>? truckId,
    Expression<String>? productId,
    Expression<double>? quantity,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (truckId != null) 'truck_id': truckId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TruckInitialStocksCompanion copyWith(
      {Value<String>? id,
      Value<String>? truckId,
      Value<String>? productId,
      Value<double>? quantity,
      Value<DateTime>? updatedAt,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return TruckInitialStocksCompanion(
      id: id ?? this.id,
      truckId: truckId ?? this.truckId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (truckId.present) {
      map['truck_id'] = Variable<String>(truckId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('TruckInitialStocksCompanion(')
          ..write('id: $id, ')
          ..write('truckId: $truckId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _truckLoadIdMeta =
      const VerificationMeta('truckLoadId');
  @override
  late final GeneratedColumn<String> truckLoadId = GeneratedColumn<String>(
      'truck_load_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _driverIdMeta =
      const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
      'driver_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceDateMeta =
      const VerificationMeta('invoiceDate');
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
      'invoice_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unpaid'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceNumber,
        truckLoadId,
        customerId,
        driverId,
        invoiceDate,
        totalAmount,
        paidAmount,
        status,
        notes,
        photoPath,
        photoUrl,
        updatedAt,
        createdAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    }
    if (data.containsKey('truck_load_id')) {
      context.handle(
          _truckLoadIdMeta,
          truckLoadId.isAcceptableOrUnknown(
              data['truck_load_id']!, _truckLoadIdMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('driver_id')) {
      context.handle(_driverIdMeta,
          driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta));
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
          _invoiceDateMeta,
          invoiceDate.isAcceptableOrUnknown(
              data['invoice_date']!, _invoiceDateMeta));
    } else if (isInserting) {
      context.missing(_invoiceDateMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number']),
      truckLoadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}truck_load_id']),
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id'])!,
      driverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_id'])!,
      invoiceDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}invoice_date'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String? invoiceNumber;
  final String? truckLoadId;
  final String customerId;
  final String driverId;
  final DateTime invoiceDate;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String? notes;
  final String? photoPath;
  final String? photoUrl;
  final DateTime updatedAt;
  final DateTime createdAt;
  final bool synced;
  const Invoice(
      {required this.id,
      this.invoiceNumber,
      this.truckLoadId,
      required this.customerId,
      required this.driverId,
      required this.invoiceDate,
      required this.totalAmount,
      required this.paidAmount,
      required this.status,
      this.notes,
      this.photoPath,
      this.photoUrl,
      required this.updatedAt,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    if (!nullToAbsent || truckLoadId != null) {
      map['truck_load_id'] = Variable<String>(truckLoadId);
    }
    map['customer_id'] = Variable<String>(customerId);
    map['driver_id'] = Variable<String>(driverId);
    map['invoice_date'] = Variable<DateTime>(invoiceDate);
    map['total_amount'] = Variable<double>(totalAmount);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      truckLoadId: truckLoadId == null && nullToAbsent
          ? const Value.absent()
          : Value(truckLoadId),
      customerId: Value(customerId),
      driverId: Value(driverId),
      invoiceDate: Value(invoiceDate),
      totalAmount: Value(totalAmount),
      paidAmount: Value(paidAmount),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      updatedAt: Value(updatedAt),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      truckLoadId: serializer.fromJson<String?>(json['truckLoadId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      driverId: serializer.fromJson<String>(json['driverId']),
      invoiceDate: serializer.fromJson<DateTime>(json['invoiceDate']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'truckLoadId': serializer.toJson<String?>(truckLoadId),
      'customerId': serializer.toJson<String>(customerId),
      'driverId': serializer.toJson<String>(driverId),
      'invoiceDate': serializer.toJson<DateTime>(invoiceDate),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Invoice copyWith(
          {String? id,
          Value<String?> invoiceNumber = const Value.absent(),
          Value<String?> truckLoadId = const Value.absent(),
          String? customerId,
          String? driverId,
          DateTime? invoiceDate,
          double? totalAmount,
          double? paidAmount,
          String? status,
          Value<String?> notes = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          DateTime? updatedAt,
          DateTime? createdAt,
          bool? synced}) =>
      Invoice(
        id: id ?? this.id,
        invoiceNumber:
            invoiceNumber.present ? invoiceNumber.value : this.invoiceNumber,
        truckLoadId: truckLoadId.present ? truckLoadId.value : this.truckLoadId,
        customerId: customerId ?? this.customerId,
        driverId: driverId ?? this.driverId,
        invoiceDate: invoiceDate ?? this.invoiceDate,
        totalAmount: totalAmount ?? this.totalAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      truckLoadId:
          data.truckLoadId.present ? data.truckLoadId.value : this.truckLoadId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      invoiceDate:
          data.invoiceDate.present ? data.invoiceDate.value : this.invoiceDate,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('truckLoadId: $truckLoadId, ')
          ..write('customerId: $customerId, ')
          ..write('driverId: $driverId, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      invoiceNumber,
      truckLoadId,
      customerId,
      driverId,
      invoiceDate,
      totalAmount,
      paidAmount,
      status,
      notes,
      photoPath,
      photoUrl,
      updatedAt,
      createdAt,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.truckLoadId == this.truckLoadId &&
          other.customerId == this.customerId &&
          other.driverId == this.driverId &&
          other.invoiceDate == this.invoiceDate &&
          other.totalAmount == this.totalAmount &&
          other.paidAmount == this.paidAmount &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath &&
          other.photoUrl == this.photoUrl &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String?> invoiceNumber;
  final Value<String?> truckLoadId;
  final Value<String> customerId;
  final Value<String> driverId;
  final Value<DateTime> invoiceDate;
  final Value<double> totalAmount;
  final Value<double> paidAmount;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> photoPath;
  final Value<String?> photoUrl;
  final Value<DateTime> updatedAt;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.truckLoadId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    this.invoiceNumber = const Value.absent(),
    this.truckLoadId = const Value.absent(),
    required String customerId,
    required String driverId,
    required DateTime invoiceDate,
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        customerId = Value(customerId),
        driverId = Value(driverId),
        invoiceDate = Value(invoiceDate);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? truckLoadId,
    Expression<String>? customerId,
    Expression<String>? driverId,
    Expression<DateTime>? invoiceDate,
    Expression<double>? totalAmount,
    Expression<double>? paidAmount,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<String>? photoUrl,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (truckLoadId != null) 'truck_load_id': truckLoadId,
      if (customerId != null) 'customer_id': customerId,
      if (driverId != null) 'driver_id': driverId,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? invoiceNumber,
      Value<String?>? truckLoadId,
      Value<String>? customerId,
      Value<String>? driverId,
      Value<DateTime>? invoiceDate,
      Value<double>? totalAmount,
      Value<double>? paidAmount,
      Value<String>? status,
      Value<String?>? notes,
      Value<String?>? photoPath,
      Value<String?>? photoUrl,
      Value<DateTime>? updatedAt,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      truckLoadId: truckLoadId ?? this.truckLoadId,
      customerId: customerId ?? this.customerId,
      driverId: driverId ?? this.driverId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (truckLoadId.present) {
      map['truck_load_id'] = Variable<String>(truckLoadId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('truckLoadId: $truckLoadId, ')
          ..write('customerId: $customerId, ')
          ..write('driverId: $driverId, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, invoiceId, productId, quantity, unitPrice, total, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final String id;
  final String invoiceId;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double total;
  final DateTime createdAt;
  final bool synced;
  const InvoiceItem(
      {required this.id,
      required this.invoiceId,
      required this.productId,
      required this.quantity,
      required this.unitPrice,
      required this.total,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total'] = Variable<double>(total);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      total: Value(total),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      total: serializer.fromJson<double>(json['total']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'total': serializer.toJson<double>(total),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  InvoiceItem copyWith(
          {String? id,
          String? invoiceId,
          String? productId,
          double? quantity,
          double? unitPrice,
          double? total,
          DateTime? createdAt,
          bool? synced}) =>
      InvoiceItem(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      total: data.total.present ? data.total.value : this.total,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('total: $total, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, invoiceId, productId, quantity, unitPrice, total, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.total == this.total &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> productId;
  final Value<double> quantity;
  final Value<double> unitPrice;
  final Value<double> total;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.total = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    required String id,
    required String invoiceId,
    required String productId,
    required double quantity,
    required double unitPrice,
    this.total = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        productId = Value(productId),
        quantity = Value(quantity),
        unitPrice = Value(unitPrice);
  static Insertable<InvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? productId,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? total,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (total != null) 'total': total,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<String>? productId,
      Value<double>? quantity,
      Value<double>? unitPrice,
      Value<double>? total,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
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
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('total: $total, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _driverIdMeta =
      const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
      'driver_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        customerId,
        driverId,
        amount,
        paymentMethod,
        paymentDate,
        notes,
        createdAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('driver_id')) {
      context.handle(_driverIdMeta,
          driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta));
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id']),
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id'])!,
      driverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String? invoiceId;
  final String customerId;
  final String driverId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;
  final bool synced;
  const Payment(
      {required this.id,
      this.invoiceId,
      required this.customerId,
      required this.driverId,
      required this.amount,
      required this.paymentMethod,
      required this.paymentDate,
      this.notes,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || invoiceId != null) {
      map['invoice_id'] = Variable<String>(invoiceId);
    }
    map['customer_id'] = Variable<String>(customerId);
    map['driver_id'] = Variable<String>(driverId);
    map['amount'] = Variable<double>(amount);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      invoiceId: invoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceId),
      customerId: Value(customerId),
      driverId: Value(driverId),
      amount: Value(amount),
      paymentMethod: Value(paymentMethod),
      paymentDate: Value(paymentDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String?>(json['invoiceId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      driverId: serializer.fromJson<String>(json['driverId']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String?>(invoiceId),
      'customerId': serializer.toJson<String>(customerId),
      'driverId': serializer.toJson<String>(driverId),
      'amount': serializer.toJson<double>(amount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Payment copyWith(
          {String? id,
          Value<String?> invoiceId = const Value.absent(),
          String? customerId,
          String? driverId,
          double? amount,
          String? paymentMethod,
          DateTime? paymentDate,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          bool? synced}) =>
      Payment(
        id: id ?? this.id,
        invoiceId: invoiceId.present ? invoiceId.value : this.invoiceId,
        customerId: customerId ?? this.customerId,
        driverId: driverId ?? this.driverId,
        amount: amount ?? this.amount,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentDate: paymentDate ?? this.paymentDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('customerId: $customerId, ')
          ..write('driverId: $driverId, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invoiceId, customerId, driverId, amount,
      paymentMethod, paymentDate, notes, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.customerId == this.customerId &&
          other.driverId == this.driverId &&
          other.amount == this.amount &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentDate == this.paymentDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String?> invoiceId;
  final Value<String> customerId;
  final Value<String> driverId;
  final Value<double> amount;
  final Value<String> paymentMethod;
  final Value<DateTime> paymentDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    this.invoiceId = const Value.absent(),
    required String customerId,
    required String driverId,
    required double amount,
    this.paymentMethod = const Value.absent(),
    required DateTime paymentDate,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        customerId = Value(customerId),
        driverId = Value(driverId),
        amount = Value(amount),
        paymentDate = Value(paymentDate);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? customerId,
    Expression<String>? driverId,
    Expression<double>? amount,
    Expression<String>? paymentMethod,
    Expression<DateTime>? paymentDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (customerId != null) 'customer_id': customerId,
      if (driverId != null) 'driver_id': driverId,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? invoiceId,
      Value<String>? customerId,
      Value<String>? driverId,
      Value<double>? amount,
      Value<String>? paymentMethod,
      Value<DateTime>? paymentDate,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      driverId: driverId ?? this.driverId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('customerId: $customerId, ')
          ..write('driverId: $driverId, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DriverSettlementsTable extends DriverSettlements
    with TableInfo<$DriverSettlementsTable, DriverSettlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriverSettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _driverIdMeta =
      const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
      'driver_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _settledDateMeta =
      const VerificationMeta('settledDate');
  @override
  late final GeneratedColumn<DateTime> settledDate = GeneratedColumn<DateTime>(
      'settled_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, driverId, amount, settledDate, notes, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'driver_settlements';
  @override
  VerificationContext validateIntegrity(Insertable<DriverSettlement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('driver_id')) {
      context.handle(_driverIdMeta,
          driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta));
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('settled_date')) {
      context.handle(
          _settledDateMeta,
          settledDate.isAcceptableOrUnknown(
              data['settled_date']!, _settledDateMeta));
    } else if (isInserting) {
      context.missing(_settledDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriverSettlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriverSettlement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      driverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      settledDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}settled_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $DriverSettlementsTable createAlias(String alias) {
    return $DriverSettlementsTable(attachedDatabase, alias);
  }
}

class DriverSettlement extends DataClass
    implements Insertable<DriverSettlement> {
  final String id;
  final String driverId;
  final double amount;
  final DateTime settledDate;
  final String? notes;
  final DateTime createdAt;
  final bool synced;
  const DriverSettlement(
      {required this.id,
      required this.driverId,
      required this.amount,
      required this.settledDate,
      this.notes,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['driver_id'] = Variable<String>(driverId);
    map['amount'] = Variable<double>(amount);
    map['settled_date'] = Variable<DateTime>(settledDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DriverSettlementsCompanion toCompanion(bool nullToAbsent) {
    return DriverSettlementsCompanion(
      id: Value(id),
      driverId: Value(driverId),
      amount: Value(amount),
      settledDate: Value(settledDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory DriverSettlement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriverSettlement(
      id: serializer.fromJson<String>(json['id']),
      driverId: serializer.fromJson<String>(json['driverId']),
      amount: serializer.fromJson<double>(json['amount']),
      settledDate: serializer.fromJson<DateTime>(json['settledDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'driverId': serializer.toJson<String>(driverId),
      'amount': serializer.toJson<double>(amount),
      'settledDate': serializer.toJson<DateTime>(settledDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DriverSettlement copyWith(
          {String? id,
          String? driverId,
          double? amount,
          DateTime? settledDate,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          bool? synced}) =>
      DriverSettlement(
        id: id ?? this.id,
        driverId: driverId ?? this.driverId,
        amount: amount ?? this.amount,
        settledDate: settledDate ?? this.settledDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  DriverSettlement copyWithCompanion(DriverSettlementsCompanion data) {
    return DriverSettlement(
      id: data.id.present ? data.id.value : this.id,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      amount: data.amount.present ? data.amount.value : this.amount,
      settledDate:
          data.settledDate.present ? data.settledDate.value : this.settledDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriverSettlement(')
          ..write('id: $id, ')
          ..write('driverId: $driverId, ')
          ..write('amount: $amount, ')
          ..write('settledDate: $settledDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, driverId, amount, settledDate, notes, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriverSettlement &&
          other.id == this.id &&
          other.driverId == this.driverId &&
          other.amount == this.amount &&
          other.settledDate == this.settledDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class DriverSettlementsCompanion extends UpdateCompanion<DriverSettlement> {
  final Value<String> id;
  final Value<String> driverId;
  final Value<double> amount;
  final Value<DateTime> settledDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const DriverSettlementsCompanion({
    this.id = const Value.absent(),
    this.driverId = const Value.absent(),
    this.amount = const Value.absent(),
    this.settledDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DriverSettlementsCompanion.insert({
    required String id,
    required String driverId,
    this.amount = const Value.absent(),
    required DateTime settledDate,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        driverId = Value(driverId),
        settledDate = Value(settledDate);
  static Insertable<DriverSettlement> custom({
    Expression<String>? id,
    Expression<String>? driverId,
    Expression<double>? amount,
    Expression<DateTime>? settledDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (driverId != null) 'driver_id': driverId,
      if (amount != null) 'amount': amount,
      if (settledDate != null) 'settled_date': settledDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DriverSettlementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? driverId,
      Value<double>? amount,
      Value<DateTime>? settledDate,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return DriverSettlementsCompanion(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      amount: amount ?? this.amount,
      settledDate: settledDate ?? this.settledDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (settledDate.present) {
      map['settled_date'] = Variable<DateTime>(settledDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('DriverSettlementsCompanion(')
          ..write('id: $id, ')
          ..write('driverId: $driverId, ')
          ..write('amount: $amount, ')
          ..write('settledDate: $settledDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrucksTable trucks = $TrucksTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $DriverProfilesTable driverProfiles = $DriverProfilesTable(this);
  late final $TruckLoadsTable truckLoads = $TruckLoadsTable(this);
  late final $TruckLoadItemsTable truckLoadItems = $TruckLoadItemsTable(this);
  late final $TruckInitialStocksTable truckInitialStocks =
      $TruckInitialStocksTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $DriverSettlementsTable driverSettlements =
      $DriverSettlementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        trucks,
        categories,
        products,
        customers,
        driverProfiles,
        truckLoads,
        truckLoadItems,
        truckInitialStocks,
        invoices,
        invoiceItems,
        payments,
        driverSettlements
      ];
}

typedef $$TrucksTableCreateCompanionBuilder = TrucksCompanion Function({
  required String id,
  required String plateNumber,
  required String name,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$TrucksTableUpdateCompanionBuilder = TrucksCompanion Function({
  Value<String> id,
  Value<String> plateNumber,
  Value<String> name,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$TrucksTableFilterComposer
    extends Composer<_$AppDatabase, $TrucksTable> {
  $$TrucksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plateNumber => $composableBuilder(
      column: $table.plateNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$TrucksTableOrderingComposer
    extends Composer<_$AppDatabase, $TrucksTable> {
  $$TrucksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plateNumber => $composableBuilder(
      column: $table.plateNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$TrucksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrucksTable> {
  $$TrucksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plateNumber => $composableBuilder(
      column: $table.plateNumber, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$TrucksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrucksTable,
    Truck,
    $$TrucksTableFilterComposer,
    $$TrucksTableOrderingComposer,
    $$TrucksTableAnnotationComposer,
    $$TrucksTableCreateCompanionBuilder,
    $$TrucksTableUpdateCompanionBuilder,
    (Truck, BaseReferences<_$AppDatabase, $TrucksTable, Truck>),
    Truck,
    PrefetchHooks Function()> {
  $$TrucksTableTableManager(_$AppDatabase db, $TrucksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrucksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrucksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrucksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> plateNumber = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrucksCompanion(
            id: id,
            plateNumber: plateNumber,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String plateNumber,
            required String name,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrucksCompanion.insert(
            id: id,
            plateNumber: plateNumber,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrucksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrucksTable,
    Truck,
    $$TrucksTableFilterComposer,
    $$TrucksTableOrderingComposer,
    $$TrucksTableAnnotationComposer,
    $$TrucksTableCreateCompanionBuilder,
    $$TrucksTableUpdateCompanionBuilder,
    (Truck, BaseReferences<_$AppDatabase, $TrucksTable, Truck>),
    Truck,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  Value<String?> nameFa,
  Value<int> sortOrder,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> nameFa,
  Value<int> sortOrder,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameFa => $composableBuilder(
      column: $table.nameFa, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameFa => $composableBuilder(
      column: $table.nameFa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameFa =>
      $composableBuilder(column: $table.nameFa, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> nameFa = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            nameFa: nameFa,
            sortOrder: sortOrder,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> nameFa = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            nameFa: nameFa,
            sortOrder: sortOrder,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String name,
  Value<String?> nameFa,
  Value<String?> sku,
  Value<String> unit,
  Value<double> price,
  Value<String?> categoryId,
  Value<bool> isActive,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> nameFa,
  Value<String?> sku,
  Value<String> unit,
  Value<double> price,
  Value<String?> categoryId,
  Value<bool> isActive,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameFa => $composableBuilder(
      column: $table.nameFa, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameFa => $composableBuilder(
      column: $table.nameFa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameFa =>
      $composableBuilder(column: $table.nameFa, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> nameFa = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            nameFa: nameFa,
            sku: sku,
            unit: unit,
            price: price,
            categoryId: categoryId,
            isActive: isActive,
            updatedAt: updatedAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> nameFa = const Value.absent(),
            Value<String?> sku = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            nameFa: nameFa,
            sku: sku,
            unit: unit,
            price: price,
            categoryId: categoryId,
            isActive: isActive,
            updatedAt: updatedAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()>;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> driverId,
  Value<int> routeOrder,
  Value<String?> routeName,
  Value<double> creditLimit,
  Value<double> balance,
  Value<String?> photoOutsidePath,
  Value<String?> photoInsidePath,
  Value<String?> photoOutsideUrl,
  Value<String?> photoInsideUrl,
  Value<DateTime?> visitedDate,
  Value<bool> isActive,
  Value<bool> isDeleted,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> driverId,
  Value<int> routeOrder,
  Value<String?> routeName,
  Value<double> creditLimit,
  Value<double> balance,
  Value<String?> photoOutsidePath,
  Value<String?> photoInsidePath,
  Value<String?> photoOutsideUrl,
  Value<String?> photoInsideUrl,
  Value<DateTime?> visitedDate,
  Value<bool> isActive,
  Value<bool> isDeleted,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get routeOrder => $composableBuilder(
      column: $table.routeOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeName => $composableBuilder(
      column: $table.routeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoOutsidePath => $composableBuilder(
      column: $table.photoOutsidePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoInsidePath => $composableBuilder(
      column: $table.photoInsidePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoOutsideUrl => $composableBuilder(
      column: $table.photoOutsideUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoInsideUrl => $composableBuilder(
      column: $table.photoInsideUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get visitedDate => $composableBuilder(
      column: $table.visitedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get routeOrder => $composableBuilder(
      column: $table.routeOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeName => $composableBuilder(
      column: $table.routeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoOutsidePath => $composableBuilder(
      column: $table.photoOutsidePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoInsidePath => $composableBuilder(
      column: $table.photoInsidePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoOutsideUrl => $composableBuilder(
      column: $table.photoOutsideUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoInsideUrl => $composableBuilder(
      column: $table.photoInsideUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get visitedDate => $composableBuilder(
      column: $table.visitedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<int> get routeOrder => $composableBuilder(
      column: $table.routeOrder, builder: (column) => column);

  GeneratedColumn<String> get routeName =>
      $composableBuilder(column: $table.routeName, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get photoOutsidePath => $composableBuilder(
      column: $table.photoOutsidePath, builder: (column) => column);

  GeneratedColumn<String> get photoInsidePath => $composableBuilder(
      column: $table.photoInsidePath, builder: (column) => column);

  GeneratedColumn<String> get photoOutsideUrl => $composableBuilder(
      column: $table.photoOutsideUrl, builder: (column) => column);

  GeneratedColumn<String> get photoInsideUrl => $composableBuilder(
      column: $table.photoInsideUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedDate => $composableBuilder(
      column: $table.visitedDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> driverId = const Value.absent(),
            Value<int> routeOrder = const Value.absent(),
            Value<String?> routeName = const Value.absent(),
            Value<double> creditLimit = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<String?> photoOutsidePath = const Value.absent(),
            Value<String?> photoInsidePath = const Value.absent(),
            Value<String?> photoOutsideUrl = const Value.absent(),
            Value<String?> photoInsideUrl = const Value.absent(),
            Value<DateTime?> visitedDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            name: name,
            phone: phone,
            address: address,
            driverId: driverId,
            routeOrder: routeOrder,
            routeName: routeName,
            creditLimit: creditLimit,
            balance: balance,
            photoOutsidePath: photoOutsidePath,
            photoInsidePath: photoInsidePath,
            photoOutsideUrl: photoOutsideUrl,
            photoInsideUrl: photoInsideUrl,
            visitedDate: visitedDate,
            isActive: isActive,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> driverId = const Value.absent(),
            Value<int> routeOrder = const Value.absent(),
            Value<String?> routeName = const Value.absent(),
            Value<double> creditLimit = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<String?> photoOutsidePath = const Value.absent(),
            Value<String?> photoInsidePath = const Value.absent(),
            Value<String?> photoOutsideUrl = const Value.absent(),
            Value<String?> photoInsideUrl = const Value.absent(),
            Value<DateTime?> visitedDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            address: address,
            driverId: driverId,
            routeOrder: routeOrder,
            routeName: routeName,
            creditLimit: creditLimit,
            balance: balance,
            photoOutsidePath: photoOutsidePath,
            photoInsidePath: photoInsidePath,
            photoOutsideUrl: photoOutsideUrl,
            photoInsideUrl: photoInsideUrl,
            visitedDate: visitedDate,
            isActive: isActive,
            isDeleted: isDeleted,
            updatedAt: updatedAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()>;
typedef $$DriverProfilesTableCreateCompanionBuilder = DriverProfilesCompanion
    Function({
  required String id,
  required String fullName,
  Value<String?> phone,
  Value<String?> truckId,
  Value<String> role,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$DriverProfilesTableUpdateCompanionBuilder = DriverProfilesCompanion
    Function({
  Value<String> id,
  Value<String> fullName,
  Value<String?> phone,
  Value<String?> truckId,
  Value<String> role,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$DriverProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $DriverProfilesTable> {
  $$DriverProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get truckId => $composableBuilder(
      column: $table.truckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$DriverProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $DriverProfilesTable> {
  $$DriverProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get truckId => $composableBuilder(
      column: $table.truckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$DriverProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriverProfilesTable> {
  $$DriverProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get truckId =>
      $composableBuilder(column: $table.truckId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DriverProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriverProfilesTable,
    DriverProfile,
    $$DriverProfilesTableFilterComposer,
    $$DriverProfilesTableOrderingComposer,
    $$DriverProfilesTableAnnotationComposer,
    $$DriverProfilesTableCreateCompanionBuilder,
    $$DriverProfilesTableUpdateCompanionBuilder,
    (
      DriverProfile,
      BaseReferences<_$AppDatabase, $DriverProfilesTable, DriverProfile>
    ),
    DriverProfile,
    PrefetchHooks Function()> {
  $$DriverProfilesTableTableManager(
      _$AppDatabase db, $DriverProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriverProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriverProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriverProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> truckId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DriverProfilesCompanion(
            id: id,
            fullName: fullName,
            phone: phone,
            truckId: truckId,
            role: role,
            isActive: isActive,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fullName,
            Value<String?> phone = const Value.absent(),
            Value<String?> truckId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DriverProfilesCompanion.insert(
            id: id,
            fullName: fullName,
            phone: phone,
            truckId: truckId,
            role: role,
            isActive: isActive,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DriverProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriverProfilesTable,
    DriverProfile,
    $$DriverProfilesTableFilterComposer,
    $$DriverProfilesTableOrderingComposer,
    $$DriverProfilesTableAnnotationComposer,
    $$DriverProfilesTableCreateCompanionBuilder,
    $$DriverProfilesTableUpdateCompanionBuilder,
    (
      DriverProfile,
      BaseReferences<_$AppDatabase, $DriverProfilesTable, DriverProfile>
    ),
    DriverProfile,
    PrefetchHooks Function()>;
typedef $$TruckLoadsTableCreateCompanionBuilder = TruckLoadsCompanion Function({
  required String id,
  required String truckId,
  required String driverId,
  required DateTime loadDate,
  Value<String> status,
  Value<String?> billPhotoUrl,
  Value<String?> billPhotoPath,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$TruckLoadsTableUpdateCompanionBuilder = TruckLoadsCompanion Function({
  Value<String> id,
  Value<String> truckId,
  Value<String> driverId,
  Value<DateTime> loadDate,
  Value<String> status,
  Value<String?> billPhotoUrl,
  Value<String?> billPhotoPath,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$TruckLoadsTableFilterComposer
    extends Composer<_$AppDatabase, $TruckLoadsTable> {
  $$TruckLoadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get truckId => $composableBuilder(
      column: $table.truckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get loadDate => $composableBuilder(
      column: $table.loadDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billPhotoUrl => $composableBuilder(
      column: $table.billPhotoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billPhotoPath => $composableBuilder(
      column: $table.billPhotoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$TruckLoadsTableOrderingComposer
    extends Composer<_$AppDatabase, $TruckLoadsTable> {
  $$TruckLoadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get truckId => $composableBuilder(
      column: $table.truckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get loadDate => $composableBuilder(
      column: $table.loadDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billPhotoUrl => $composableBuilder(
      column: $table.billPhotoUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billPhotoPath => $composableBuilder(
      column: $table.billPhotoPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$TruckLoadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TruckLoadsTable> {
  $$TruckLoadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get truckId =>
      $composableBuilder(column: $table.truckId, builder: (column) => column);

  GeneratedColumn<String> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<DateTime> get loadDate =>
      $composableBuilder(column: $table.loadDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get billPhotoUrl => $composableBuilder(
      column: $table.billPhotoUrl, builder: (column) => column);

  GeneratedColumn<String> get billPhotoPath => $composableBuilder(
      column: $table.billPhotoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$TruckLoadsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TruckLoadsTable,
    TruckLoad,
    $$TruckLoadsTableFilterComposer,
    $$TruckLoadsTableOrderingComposer,
    $$TruckLoadsTableAnnotationComposer,
    $$TruckLoadsTableCreateCompanionBuilder,
    $$TruckLoadsTableUpdateCompanionBuilder,
    (TruckLoad, BaseReferences<_$AppDatabase, $TruckLoadsTable, TruckLoad>),
    TruckLoad,
    PrefetchHooks Function()> {
  $$TruckLoadsTableTableManager(_$AppDatabase db, $TruckLoadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TruckLoadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TruckLoadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TruckLoadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> truckId = const Value.absent(),
            Value<String> driverId = const Value.absent(),
            Value<DateTime> loadDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> billPhotoUrl = const Value.absent(),
            Value<String?> billPhotoPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TruckLoadsCompanion(
            id: id,
            truckId: truckId,
            driverId: driverId,
            loadDate: loadDate,
            status: status,
            billPhotoUrl: billPhotoUrl,
            billPhotoPath: billPhotoPath,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String truckId,
            required String driverId,
            required DateTime loadDate,
            Value<String> status = const Value.absent(),
            Value<String?> billPhotoUrl = const Value.absent(),
            Value<String?> billPhotoPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TruckLoadsCompanion.insert(
            id: id,
            truckId: truckId,
            driverId: driverId,
            loadDate: loadDate,
            status: status,
            billPhotoUrl: billPhotoUrl,
            billPhotoPath: billPhotoPath,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TruckLoadsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TruckLoadsTable,
    TruckLoad,
    $$TruckLoadsTableFilterComposer,
    $$TruckLoadsTableOrderingComposer,
    $$TruckLoadsTableAnnotationComposer,
    $$TruckLoadsTableCreateCompanionBuilder,
    $$TruckLoadsTableUpdateCompanionBuilder,
    (TruckLoad, BaseReferences<_$AppDatabase, $TruckLoadsTable, TruckLoad>),
    TruckLoad,
    PrefetchHooks Function()>;
typedef $$TruckLoadItemsTableCreateCompanionBuilder = TruckLoadItemsCompanion
    Function({
  required String id,
  required String loadId,
  required String productId,
  Value<double> requestedQty,
  Value<double> quantityLoaded,
  Value<double> quantityReturned,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$TruckLoadItemsTableUpdateCompanionBuilder = TruckLoadItemsCompanion
    Function({
  Value<String> id,
  Value<String> loadId,
  Value<String> productId,
  Value<double> requestedQty,
  Value<double> quantityLoaded,
  Value<double> quantityReturned,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$TruckLoadItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TruckLoadItemsTable> {
  $$TruckLoadItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loadId => $composableBuilder(
      column: $table.loadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get requestedQty => $composableBuilder(
      column: $table.requestedQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityLoaded => $composableBuilder(
      column: $table.quantityLoaded,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityReturned => $composableBuilder(
      column: $table.quantityReturned,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$TruckLoadItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TruckLoadItemsTable> {
  $$TruckLoadItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loadId => $composableBuilder(
      column: $table.loadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get requestedQty => $composableBuilder(
      column: $table.requestedQty,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityLoaded => $composableBuilder(
      column: $table.quantityLoaded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityReturned => $composableBuilder(
      column: $table.quantityReturned,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$TruckLoadItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TruckLoadItemsTable> {
  $$TruckLoadItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get loadId =>
      $composableBuilder(column: $table.loadId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get requestedQty => $composableBuilder(
      column: $table.requestedQty, builder: (column) => column);

  GeneratedColumn<double> get quantityLoaded => $composableBuilder(
      column: $table.quantityLoaded, builder: (column) => column);

  GeneratedColumn<double> get quantityReturned => $composableBuilder(
      column: $table.quantityReturned, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$TruckLoadItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TruckLoadItemsTable,
    TruckLoadItem,
    $$TruckLoadItemsTableFilterComposer,
    $$TruckLoadItemsTableOrderingComposer,
    $$TruckLoadItemsTableAnnotationComposer,
    $$TruckLoadItemsTableCreateCompanionBuilder,
    $$TruckLoadItemsTableUpdateCompanionBuilder,
    (
      TruckLoadItem,
      BaseReferences<_$AppDatabase, $TruckLoadItemsTable, TruckLoadItem>
    ),
    TruckLoadItem,
    PrefetchHooks Function()> {
  $$TruckLoadItemsTableTableManager(
      _$AppDatabase db, $TruckLoadItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TruckLoadItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TruckLoadItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TruckLoadItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> loadId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<double> requestedQty = const Value.absent(),
            Value<double> quantityLoaded = const Value.absent(),
            Value<double> quantityReturned = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TruckLoadItemsCompanion(
            id: id,
            loadId: loadId,
            productId: productId,
            requestedQty: requestedQty,
            quantityLoaded: quantityLoaded,
            quantityReturned: quantityReturned,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String loadId,
            required String productId,
            Value<double> requestedQty = const Value.absent(),
            Value<double> quantityLoaded = const Value.absent(),
            Value<double> quantityReturned = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TruckLoadItemsCompanion.insert(
            id: id,
            loadId: loadId,
            productId: productId,
            requestedQty: requestedQty,
            quantityLoaded: quantityLoaded,
            quantityReturned: quantityReturned,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TruckLoadItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TruckLoadItemsTable,
    TruckLoadItem,
    $$TruckLoadItemsTableFilterComposer,
    $$TruckLoadItemsTableOrderingComposer,
    $$TruckLoadItemsTableAnnotationComposer,
    $$TruckLoadItemsTableCreateCompanionBuilder,
    $$TruckLoadItemsTableUpdateCompanionBuilder,
    (
      TruckLoadItem,
      BaseReferences<_$AppDatabase, $TruckLoadItemsTable, TruckLoadItem>
    ),
    TruckLoadItem,
    PrefetchHooks Function()>;
typedef $$TruckInitialStocksTableCreateCompanionBuilder
    = TruckInitialStocksCompanion Function({
  required String id,
  required String truckId,
  required String productId,
  Value<double> quantity,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$TruckInitialStocksTableUpdateCompanionBuilder
    = TruckInitialStocksCompanion Function({
  Value<String> id,
  Value<String> truckId,
  Value<String> productId,
  Value<double> quantity,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$TruckInitialStocksTableFilterComposer
    extends Composer<_$AppDatabase, $TruckInitialStocksTable> {
  $$TruckInitialStocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get truckId => $composableBuilder(
      column: $table.truckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$TruckInitialStocksTableOrderingComposer
    extends Composer<_$AppDatabase, $TruckInitialStocksTable> {
  $$TruckInitialStocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get truckId => $composableBuilder(
      column: $table.truckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$TruckInitialStocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TruckInitialStocksTable> {
  $$TruckInitialStocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get truckId =>
      $composableBuilder(column: $table.truckId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$TruckInitialStocksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TruckInitialStocksTable,
    TruckInitialStock,
    $$TruckInitialStocksTableFilterComposer,
    $$TruckInitialStocksTableOrderingComposer,
    $$TruckInitialStocksTableAnnotationComposer,
    $$TruckInitialStocksTableCreateCompanionBuilder,
    $$TruckInitialStocksTableUpdateCompanionBuilder,
    (
      TruckInitialStock,
      BaseReferences<_$AppDatabase, $TruckInitialStocksTable, TruckInitialStock>
    ),
    TruckInitialStock,
    PrefetchHooks Function()> {
  $$TruckInitialStocksTableTableManager(
      _$AppDatabase db, $TruckInitialStocksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TruckInitialStocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TruckInitialStocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TruckInitialStocksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> truckId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TruckInitialStocksCompanion(
            id: id,
            truckId: truckId,
            productId: productId,
            quantity: quantity,
            updatedAt: updatedAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String truckId,
            required String productId,
            Value<double> quantity = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TruckInitialStocksCompanion.insert(
            id: id,
            truckId: truckId,
            productId: productId,
            quantity: quantity,
            updatedAt: updatedAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TruckInitialStocksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TruckInitialStocksTable,
    TruckInitialStock,
    $$TruckInitialStocksTableFilterComposer,
    $$TruckInitialStocksTableOrderingComposer,
    $$TruckInitialStocksTableAnnotationComposer,
    $$TruckInitialStocksTableCreateCompanionBuilder,
    $$TruckInitialStocksTableUpdateCompanionBuilder,
    (
      TruckInitialStock,
      BaseReferences<_$AppDatabase, $TruckInitialStocksTable, TruckInitialStock>
    ),
    TruckInitialStock,
    PrefetchHooks Function()>;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  required String id,
  Value<String?> invoiceNumber,
  Value<String?> truckLoadId,
  required String customerId,
  required String driverId,
  required DateTime invoiceDate,
  Value<double> totalAmount,
  Value<double> paidAmount,
  Value<String> status,
  Value<String?> notes,
  Value<String?> photoPath,
  Value<String?> photoUrl,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<String> id,
  Value<String?> invoiceNumber,
  Value<String?> truckLoadId,
  Value<String> customerId,
  Value<String> driverId,
  Value<DateTime> invoiceDate,
  Value<double> totalAmount,
  Value<double> paidAmount,
  Value<String> status,
  Value<String?> notes,
  Value<String?> photoPath,
  Value<String?> photoUrl,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get truckLoadId => $composableBuilder(
      column: $table.truckLoadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get truckLoadId => $composableBuilder(
      column: $table.truckLoadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get truckLoadId => $composableBuilder(
      column: $table.truckLoadId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
    Invoice,
    PrefetchHooks Function()> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> invoiceNumber = const Value.absent(),
            Value<String?> truckLoadId = const Value.absent(),
            Value<String> customerId = const Value.absent(),
            Value<String> driverId = const Value.absent(),
            Value<DateTime> invoiceDate = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            invoiceNumber: invoiceNumber,
            truckLoadId: truckLoadId,
            customerId: customerId,
            driverId: driverId,
            invoiceDate: invoiceDate,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            status: status,
            notes: notes,
            photoPath: photoPath,
            photoUrl: photoUrl,
            updatedAt: updatedAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> invoiceNumber = const Value.absent(),
            Value<String?> truckLoadId = const Value.absent(),
            required String customerId,
            required String driverId,
            required DateTime invoiceDate,
            Value<double> totalAmount = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            invoiceNumber: invoiceNumber,
            truckLoadId: truckLoadId,
            customerId: customerId,
            driverId: driverId,
            invoiceDate: invoiceDate,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            status: status,
            notes: notes,
            photoPath: photoPath,
            photoUrl: photoUrl,
            updatedAt: updatedAt,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
    Invoice,
    PrefetchHooks Function()>;
typedef $$InvoiceItemsTableCreateCompanionBuilder = InvoiceItemsCompanion
    Function({
  required String id,
  required String invoiceId,
  required String productId,
  required double quantity,
  required double unitPrice,
  Value<double> total,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$InvoiceItemsTableUpdateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<String> productId,
  Value<double> quantity,
  Value<double> unitPrice,
  Value<double> total,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$InvoiceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (
      InvoiceItem,
      BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>
    ),
    InvoiceItem,
    PrefetchHooks Function()> {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceItemsCompanion(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            total: total,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required String productId,
            required double quantity,
            required double unitPrice,
            Value<double> total = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceItemsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            total: total,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoiceItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (
      InvoiceItem,
      BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>
    ),
    InvoiceItem,
    PrefetchHooks Function()>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  Value<String?> invoiceId,
  required String customerId,
  required String driverId,
  required double amount,
  Value<String> paymentMethod,
  required DateTime paymentDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String?> invoiceId,
  Value<String> customerId,
  Value<String> driverId,
  Value<double> amount,
  Value<String> paymentMethod,
  Value<DateTime> paymentDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> invoiceId = const Value.absent(),
            Value<String> customerId = const Value.absent(),
            Value<String> driverId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            invoiceId: invoiceId,
            customerId: customerId,
            driverId: driverId,
            amount: amount,
            paymentMethod: paymentMethod,
            paymentDate: paymentDate,
            notes: notes,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> invoiceId = const Value.absent(),
            required String customerId,
            required String driverId,
            required double amount,
            Value<String> paymentMethod = const Value.absent(),
            required DateTime paymentDate,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            customerId: customerId,
            driverId: driverId,
            amount: amount,
            paymentMethod: paymentMethod,
            paymentDate: paymentDate,
            notes: notes,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()>;
typedef $$DriverSettlementsTableCreateCompanionBuilder
    = DriverSettlementsCompanion Function({
  required String id,
  required String driverId,
  Value<double> amount,
  required DateTime settledDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$DriverSettlementsTableUpdateCompanionBuilder
    = DriverSettlementsCompanion Function({
  Value<String> id,
  Value<String> driverId,
  Value<double> amount,
  Value<DateTime> settledDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$DriverSettlementsTableFilterComposer
    extends Composer<_$AppDatabase, $DriverSettlementsTable> {
  $$DriverSettlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get settledDate => $composableBuilder(
      column: $table.settledDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$DriverSettlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $DriverSettlementsTable> {
  $$DriverSettlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get settledDate => $composableBuilder(
      column: $table.settledDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$DriverSettlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriverSettlementsTable> {
  $$DriverSettlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get settledDate => $composableBuilder(
      column: $table.settledDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DriverSettlementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriverSettlementsTable,
    DriverSettlement,
    $$DriverSettlementsTableFilterComposer,
    $$DriverSettlementsTableOrderingComposer,
    $$DriverSettlementsTableAnnotationComposer,
    $$DriverSettlementsTableCreateCompanionBuilder,
    $$DriverSettlementsTableUpdateCompanionBuilder,
    (
      DriverSettlement,
      BaseReferences<_$AppDatabase, $DriverSettlementsTable, DriverSettlement>
    ),
    DriverSettlement,
    PrefetchHooks Function()> {
  $$DriverSettlementsTableTableManager(
      _$AppDatabase db, $DriverSettlementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriverSettlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriverSettlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriverSettlementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> driverId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> settledDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DriverSettlementsCompanion(
            id: id,
            driverId: driverId,
            amount: amount,
            settledDate: settledDate,
            notes: notes,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String driverId,
            Value<double> amount = const Value.absent(),
            required DateTime settledDate,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DriverSettlementsCompanion.insert(
            id: id,
            driverId: driverId,
            amount: amount,
            settledDate: settledDate,
            notes: notes,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DriverSettlementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriverSettlementsTable,
    DriverSettlement,
    $$DriverSettlementsTableFilterComposer,
    $$DriverSettlementsTableOrderingComposer,
    $$DriverSettlementsTableAnnotationComposer,
    $$DriverSettlementsTableCreateCompanionBuilder,
    $$DriverSettlementsTableUpdateCompanionBuilder,
    (
      DriverSettlement,
      BaseReferences<_$AppDatabase, $DriverSettlementsTable, DriverSettlement>
    ),
    DriverSettlement,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrucksTableTableManager get trucks =>
      $$TrucksTableTableManager(_db, _db.trucks);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$DriverProfilesTableTableManager get driverProfiles =>
      $$DriverProfilesTableTableManager(_db, _db.driverProfiles);
  $$TruckLoadsTableTableManager get truckLoads =>
      $$TruckLoadsTableTableManager(_db, _db.truckLoads);
  $$TruckLoadItemsTableTableManager get truckLoadItems =>
      $$TruckLoadItemsTableTableManager(_db, _db.truckLoadItems);
  $$TruckInitialStocksTableTableManager get truckInitialStocks =>
      $$TruckInitialStocksTableTableManager(_db, _db.truckInitialStocks);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$DriverSettlementsTableTableManager get driverSettlements =>
      $$DriverSettlementsTableTableManager(_db, _db.driverSettlements);
}
