// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class ReactionsCacheEntry extends DataClass
    implements Insertable<ReactionsCacheEntry> {
  final int id;
  final int runs;
  final int lines;
  ReactionsCacheEntry(
      {required this.id, required this.runs, required this.lines});
  factory ReactionsCacheEntry.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return ReactionsCacheEntry(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      runs: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}runs'])!,
      lines: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}lines'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['runs'] = Variable<int>(runs);
    map['lines'] = Variable<int>(lines);
    return map;
  }

  ReactionsCacheCompanion toCompanion(bool nullToAbsent) {
    return ReactionsCacheCompanion(
      id: Value(id),
      runs: Value(runs),
      lines: Value(lines),
    );
  }

  factory ReactionsCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionsCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      runs: serializer.fromJson<int>(json['runs']),
      lines: serializer.fromJson<int>(json['lines']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runs': serializer.toJson<int>(runs),
      'lines': serializer.toJson<int>(lines),
    };
  }

  ReactionsCacheEntry copyWith({int? id, int? runs, int? lines}) =>
      ReactionsCacheEntry(
        id: id ?? this.id,
        runs: runs ?? this.runs,
        lines: lines ?? this.lines,
      );
  @override
  String toString() {
    return (StringBuffer('ReactionsCacheEntry(')
          ..write('id: $id, ')
          ..write('runs: $runs, ')
          ..write('lines: $lines')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, runs, lines);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionsCacheEntry &&
          other.id == this.id &&
          other.runs == this.runs &&
          other.lines == this.lines);
}

class ReactionsCacheCompanion extends UpdateCompanion<ReactionsCacheEntry> {
  final Value<int> id;
  final Value<int> runs;
  final Value<int> lines;
  const ReactionsCacheCompanion({
    this.id = const Value.absent(),
    this.runs = const Value.absent(),
    this.lines = const Value.absent(),
  });
  ReactionsCacheCompanion.insert({
    this.id = const Value.absent(),
    required int runs,
    required int lines,
  })  : runs = Value(runs),
        lines = Value(lines);
  static Insertable<ReactionsCacheEntry> custom({
    Expression<int>? id,
    Expression<int>? runs,
    Expression<int>? lines,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runs != null) 'runs': runs,
      if (lines != null) 'lines': lines,
    });
  }

  ReactionsCacheCompanion copyWith(
      {Value<int>? id, Value<int>? runs, Value<int>? lines}) {
    return ReactionsCacheCompanion(
      id: id ?? this.id,
      runs: runs ?? this.runs,
      lines: lines ?? this.lines,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runs.present) {
      map['runs'] = Variable<int>(runs.value);
    }
    if (lines.present) {
      map['lines'] = Variable<int>(lines.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionsCacheCompanion(')
          ..write('id: $id, ')
          ..write('runs: $runs, ')
          ..write('lines: $lines')
          ..write(')'))
        .toString();
  }
}

class $ReactionsCacheTable extends ReactionsCache
    with TableInfo<$ReactionsCacheTable, ReactionsCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionsCacheTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _runsMeta = const VerificationMeta('runs');
  @override
  late final GeneratedColumn<int?> runs = GeneratedColumn<int?>(
      'runs', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _linesMeta = const VerificationMeta('lines');
  @override
  late final GeneratedColumn<int?> lines = GeneratedColumn<int?>(
      'lines', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, runs, lines];
  @override
  String get aliasedName => _alias ?? 'reactions_cache';
  @override
  String get actualTableName => 'reactions_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReactionsCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('runs')) {
      context.handle(
          _runsMeta, runs.isAcceptableOrUnknown(data['runs']!, _runsMeta));
    } else if (isInserting) {
      context.missing(_runsMeta);
    }
    if (data.containsKey('lines')) {
      context.handle(
          _linesMeta, lines.isAcceptableOrUnknown(data['lines']!, _linesMeta));
    } else if (isInserting) {
      context.missing(_linesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReactionsCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    return ReactionsCacheEntry.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $ReactionsCacheTable createAlias(String alias) {
    return $ReactionsCacheTable(attachedDatabase, alias);
  }
}

class IntermediatesToBuyCacheEntry extends DataClass
    implements Insertable<IntermediatesToBuyCacheEntry> {
  final int id;
  IntermediatesToBuyCacheEntry({required this.id});
  factory IntermediatesToBuyCacheEntry.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return IntermediatesToBuyCacheEntry(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    return map;
  }

  IntermediatesToBuyCacheCompanion toCompanion(bool nullToAbsent) {
    return IntermediatesToBuyCacheCompanion(
      id: Value(id),
    );
  }

  factory IntermediatesToBuyCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntermediatesToBuyCacheEntry(
      id: serializer.fromJson<int>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
    };
  }

  IntermediatesToBuyCacheEntry copyWith({int? id}) =>
      IntermediatesToBuyCacheEntry(
        id: id ?? this.id,
      );
  @override
  String toString() {
    return (StringBuffer('IntermediatesToBuyCacheEntry(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntermediatesToBuyCacheEntry && other.id == this.id);
}

class IntermediatesToBuyCacheCompanion
    extends UpdateCompanion<IntermediatesToBuyCacheEntry> {
  final Value<int> id;
  const IntermediatesToBuyCacheCompanion({
    this.id = const Value.absent(),
  });
  IntermediatesToBuyCacheCompanion.insert({
    this.id = const Value.absent(),
  });
  static Insertable<IntermediatesToBuyCacheEntry> custom({
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
    });
  }

  IntermediatesToBuyCacheCompanion copyWith({Value<int>? id}) {
    return IntermediatesToBuyCacheCompanion(
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntermediatesToBuyCacheCompanion(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

class $IntermediatesToBuyCacheTable extends IntermediatesToBuyCache
    with
        TableInfo<$IntermediatesToBuyCacheTable, IntermediatesToBuyCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntermediatesToBuyCacheTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? 'intermediates_to_buy_cache';
  @override
  String get actualTableName => 'intermediates_to_buy_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<IntermediatesToBuyCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntermediatesToBuyCacheEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    return IntermediatesToBuyCacheEntry.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $IntermediatesToBuyCacheTable createAlias(String alias) {
    return $IntermediatesToBuyCacheTable(attachedDatabase, alias);
  }
}

class InventoryCacheEntry extends DataClass
    implements Insertable<InventoryCacheEntry> {
  final int id;
  final int quantity;
  InventoryCacheEntry({required this.id, required this.quantity});
  factory InventoryCacheEntry.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return InventoryCacheEntry(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      quantity: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}quantity'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  InventoryCacheCompanion toCompanion(bool nullToAbsent) {
    return InventoryCacheCompanion(
      id: Value(id),
      quantity: Value(quantity),
    );
  }

  factory InventoryCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  InventoryCacheEntry copyWith({int? id, int? quantity}) => InventoryCacheEntry(
        id: id ?? this.id,
        quantity: quantity ?? this.quantity,
      );
  @override
  String toString() {
    return (StringBuffer('InventoryCacheEntry(')
          ..write('id: $id, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryCacheEntry &&
          other.id == this.id &&
          other.quantity == this.quantity);
}

class InventoryCacheCompanion extends UpdateCompanion<InventoryCacheEntry> {
  final Value<int> id;
  final Value<int> quantity;
  const InventoryCacheCompanion({
    this.id = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  InventoryCacheCompanion.insert({
    this.id = const Value.absent(),
    required int quantity,
  }) : quantity = Value(quantity);
  static Insertable<InventoryCacheEntry> custom({
    Expression<int>? id,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quantity != null) 'quantity': quantity,
    });
  }

  InventoryCacheCompanion copyWith({Value<int>? id, Value<int>? quantity}) {
    return InventoryCacheCompanion(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCacheCompanion(')
          ..write('id: $id, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

class $InventoryCacheTable extends InventoryCache
    with TableInfo<$InventoryCacheTable, InventoryCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryCacheTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _quantityMeta = const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int?> quantity = GeneratedColumn<int?>(
      'quantity', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, quantity];
  @override
  String get aliasedName => _alias ?? 'inventory_cache';
  @override
  String get actualTableName => 'inventory_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<InventoryCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    return InventoryCacheEntry.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $InventoryCacheTable createAlias(String alias) {
    return $InventoryCacheTable(attachedDatabase, alias);
  }
}

class MarketOrdersCacheEntry extends DataClass
    implements Insertable<MarketOrdersCacheEntry> {
  final int id;
  final int typeID;
  final int systemID;
  final int regionID;
  final bool isBuy;
  final double price;
  final int volumeRemaining;
  MarketOrdersCacheEntry(
      {required this.id,
      required this.typeID,
      required this.systemID,
      required this.regionID,
      required this.isBuy,
      required this.price,
      required this.volumeRemaining});
  factory MarketOrdersCacheEntry.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return MarketOrdersCacheEntry(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      typeID: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}type_i_d'])!,
      systemID: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}system_i_d'])!,
      regionID: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}region_i_d'])!,
      isBuy: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_buy'])!,
      price: const RealType()
          .mapFromDatabaseResponse(data['${effectivePrefix}price'])!,
      volumeRemaining: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}volume_remaining'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type_i_d'] = Variable<int>(typeID);
    map['system_i_d'] = Variable<int>(systemID);
    map['region_i_d'] = Variable<int>(regionID);
    map['is_buy'] = Variable<bool>(isBuy);
    map['price'] = Variable<double>(price);
    map['volume_remaining'] = Variable<int>(volumeRemaining);
    return map;
  }

  MarketOrdersCacheCompanion toCompanion(bool nullToAbsent) {
    return MarketOrdersCacheCompanion(
      id: Value(id),
      typeID: Value(typeID),
      systemID: Value(systemID),
      regionID: Value(regionID),
      isBuy: Value(isBuy),
      price: Value(price),
      volumeRemaining: Value(volumeRemaining),
    );
  }

  factory MarketOrdersCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketOrdersCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      typeID: serializer.fromJson<int>(json['typeID']),
      systemID: serializer.fromJson<int>(json['systemID']),
      regionID: serializer.fromJson<int>(json['regionID']),
      isBuy: serializer.fromJson<bool>(json['isBuy']),
      price: serializer.fromJson<double>(json['price']),
      volumeRemaining: serializer.fromJson<int>(json['volumeRemaining']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'typeID': serializer.toJson<int>(typeID),
      'systemID': serializer.toJson<int>(systemID),
      'regionID': serializer.toJson<int>(regionID),
      'isBuy': serializer.toJson<bool>(isBuy),
      'price': serializer.toJson<double>(price),
      'volumeRemaining': serializer.toJson<int>(volumeRemaining),
    };
  }

  MarketOrdersCacheEntry copyWith(
          {int? id,
          int? typeID,
          int? systemID,
          int? regionID,
          bool? isBuy,
          double? price,
          int? volumeRemaining}) =>
      MarketOrdersCacheEntry(
        id: id ?? this.id,
        typeID: typeID ?? this.typeID,
        systemID: systemID ?? this.systemID,
        regionID: regionID ?? this.regionID,
        isBuy: isBuy ?? this.isBuy,
        price: price ?? this.price,
        volumeRemaining: volumeRemaining ?? this.volumeRemaining,
      );
  @override
  String toString() {
    return (StringBuffer('MarketOrdersCacheEntry(')
          ..write('id: $id, ')
          ..write('typeID: $typeID, ')
          ..write('systemID: $systemID, ')
          ..write('regionID: $regionID, ')
          ..write('isBuy: $isBuy, ')
          ..write('price: $price, ')
          ..write('volumeRemaining: $volumeRemaining')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, typeID, systemID, regionID, isBuy, price, volumeRemaining);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketOrdersCacheEntry &&
          other.id == this.id &&
          other.typeID == this.typeID &&
          other.systemID == this.systemID &&
          other.regionID == this.regionID &&
          other.isBuy == this.isBuy &&
          other.price == this.price &&
          other.volumeRemaining == this.volumeRemaining);
}

class MarketOrdersCacheCompanion
    extends UpdateCompanion<MarketOrdersCacheEntry> {
  final Value<int> id;
  final Value<int> typeID;
  final Value<int> systemID;
  final Value<int> regionID;
  final Value<bool> isBuy;
  final Value<double> price;
  final Value<int> volumeRemaining;
  const MarketOrdersCacheCompanion({
    this.id = const Value.absent(),
    this.typeID = const Value.absent(),
    this.systemID = const Value.absent(),
    this.regionID = const Value.absent(),
    this.isBuy = const Value.absent(),
    this.price = const Value.absent(),
    this.volumeRemaining = const Value.absent(),
  });
  MarketOrdersCacheCompanion.insert({
    this.id = const Value.absent(),
    required int typeID,
    required int systemID,
    required int regionID,
    required bool isBuy,
    required double price,
    required int volumeRemaining,
  })  : typeID = Value(typeID),
        systemID = Value(systemID),
        regionID = Value(regionID),
        isBuy = Value(isBuy),
        price = Value(price),
        volumeRemaining = Value(volumeRemaining);
  static Insertable<MarketOrdersCacheEntry> custom({
    Expression<int>? id,
    Expression<int>? typeID,
    Expression<int>? systemID,
    Expression<int>? regionID,
    Expression<bool>? isBuy,
    Expression<double>? price,
    Expression<int>? volumeRemaining,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeID != null) 'type_i_d': typeID,
      if (systemID != null) 'system_i_d': systemID,
      if (regionID != null) 'region_i_d': regionID,
      if (isBuy != null) 'is_buy': isBuy,
      if (price != null) 'price': price,
      if (volumeRemaining != null) 'volume_remaining': volumeRemaining,
    });
  }

  MarketOrdersCacheCompanion copyWith(
      {Value<int>? id,
      Value<int>? typeID,
      Value<int>? systemID,
      Value<int>? regionID,
      Value<bool>? isBuy,
      Value<double>? price,
      Value<int>? volumeRemaining}) {
    return MarketOrdersCacheCompanion(
      id: id ?? this.id,
      typeID: typeID ?? this.typeID,
      systemID: systemID ?? this.systemID,
      regionID: regionID ?? this.regionID,
      isBuy: isBuy ?? this.isBuy,
      price: price ?? this.price,
      volumeRemaining: volumeRemaining ?? this.volumeRemaining,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (typeID.present) {
      map['type_i_d'] = Variable<int>(typeID.value);
    }
    if (systemID.present) {
      map['system_i_d'] = Variable<int>(systemID.value);
    }
    if (regionID.present) {
      map['region_i_d'] = Variable<int>(regionID.value);
    }
    if (isBuy.present) {
      map['is_buy'] = Variable<bool>(isBuy.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (volumeRemaining.present) {
      map['volume_remaining'] = Variable<int>(volumeRemaining.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketOrdersCacheCompanion(')
          ..write('id: $id, ')
          ..write('typeID: $typeID, ')
          ..write('systemID: $systemID, ')
          ..write('regionID: $regionID, ')
          ..write('isBuy: $isBuy, ')
          ..write('price: $price, ')
          ..write('volumeRemaining: $volumeRemaining')
          ..write(')'))
        .toString();
  }
}

class $MarketOrdersCacheTable extends MarketOrdersCache
    with TableInfo<$MarketOrdersCacheTable, MarketOrdersCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketOrdersCacheTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _typeIDMeta = const VerificationMeta('typeID');
  @override
  late final GeneratedColumn<int?> typeID = GeneratedColumn<int?>(
      'type_i_d', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _systemIDMeta = const VerificationMeta('systemID');
  @override
  late final GeneratedColumn<int?> systemID = GeneratedColumn<int?>(
      'system_i_d', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _regionIDMeta = const VerificationMeta('regionID');
  @override
  late final GeneratedColumn<int?> regionID = GeneratedColumn<int?>(
      'region_i_d', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _isBuyMeta = const VerificationMeta('isBuy');
  @override
  late final GeneratedColumn<bool?> isBuy = GeneratedColumn<bool?>(
      'is_buy', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (is_buy IN (0, 1))');
  final VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double?> price = GeneratedColumn<double?>(
      'price', aliasedName, false,
      type: const RealType(), requiredDuringInsert: true);
  final VerificationMeta _volumeRemainingMeta =
      const VerificationMeta('volumeRemaining');
  @override
  late final GeneratedColumn<int?> volumeRemaining = GeneratedColumn<int?>(
      'volume_remaining', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, typeID, systemID, regionID, isBuy, price, volumeRemaining];
  @override
  String get aliasedName => _alias ?? 'market_orders_cache';
  @override
  String get actualTableName => 'market_orders_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<MarketOrdersCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type_i_d')) {
      context.handle(_typeIDMeta,
          typeID.isAcceptableOrUnknown(data['type_i_d']!, _typeIDMeta));
    } else if (isInserting) {
      context.missing(_typeIDMeta);
    }
    if (data.containsKey('system_i_d')) {
      context.handle(_systemIDMeta,
          systemID.isAcceptableOrUnknown(data['system_i_d']!, _systemIDMeta));
    } else if (isInserting) {
      context.missing(_systemIDMeta);
    }
    if (data.containsKey('region_i_d')) {
      context.handle(_regionIDMeta,
          regionID.isAcceptableOrUnknown(data['region_i_d']!, _regionIDMeta));
    } else if (isInserting) {
      context.missing(_regionIDMeta);
    }
    if (data.containsKey('is_buy')) {
      context.handle(
          _isBuyMeta, isBuy.isAcceptableOrUnknown(data['is_buy']!, _isBuyMeta));
    } else if (isInserting) {
      context.missing(_isBuyMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('volume_remaining')) {
      context.handle(
          _volumeRemainingMeta,
          volumeRemaining.isAcceptableOrUnknown(
              data['volume_remaining']!, _volumeRemainingMeta));
    } else if (isInserting) {
      context.missing(_volumeRemainingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MarketOrdersCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    return MarketOrdersCacheEntry.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $MarketOrdersCacheTable createAlias(String alias) {
    return $MarketOrdersCacheTable(attachedDatabase, alias);
  }
}

class BuyOrderFilterCacheEntry extends DataClass
    implements Insertable<BuyOrderFilterCacheEntry> {
  final int id;
  final int systemId;
  BuyOrderFilterCacheEntry({required this.id, required this.systemId});
  factory BuyOrderFilterCacheEntry.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return BuyOrderFilterCacheEntry(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      systemId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}system_id'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['system_id'] = Variable<int>(systemId);
    return map;
  }

  BuyOrderFilterCacheCompanion toCompanion(bool nullToAbsent) {
    return BuyOrderFilterCacheCompanion(
      id: Value(id),
      systemId: Value(systemId),
    );
  }

  factory BuyOrderFilterCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuyOrderFilterCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      systemId: serializer.fromJson<int>(json['systemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'systemId': serializer.toJson<int>(systemId),
    };
  }

  BuyOrderFilterCacheEntry copyWith({int? id, int? systemId}) =>
      BuyOrderFilterCacheEntry(
        id: id ?? this.id,
        systemId: systemId ?? this.systemId,
      );
  @override
  String toString() {
    return (StringBuffer('BuyOrderFilterCacheEntry(')
          ..write('id: $id, ')
          ..write('systemId: $systemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, systemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuyOrderFilterCacheEntry &&
          other.id == this.id &&
          other.systemId == this.systemId);
}

class BuyOrderFilterCacheCompanion
    extends UpdateCompanion<BuyOrderFilterCacheEntry> {
  final Value<int> id;
  final Value<int> systemId;
  const BuyOrderFilterCacheCompanion({
    this.id = const Value.absent(),
    this.systemId = const Value.absent(),
  });
  BuyOrderFilterCacheCompanion.insert({
    this.id = const Value.absent(),
    required int systemId,
  }) : systemId = Value(systemId);
  static Insertable<BuyOrderFilterCacheEntry> custom({
    Expression<int>? id,
    Expression<int>? systemId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (systemId != null) 'system_id': systemId,
    });
  }

  BuyOrderFilterCacheCompanion copyWith(
      {Value<int>? id, Value<int>? systemId}) {
    return BuyOrderFilterCacheCompanion(
      id: id ?? this.id,
      systemId: systemId ?? this.systemId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (systemId.present) {
      map['system_id'] = Variable<int>(systemId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuyOrderFilterCacheCompanion(')
          ..write('id: $id, ')
          ..write('systemId: $systemId')
          ..write(')'))
        .toString();
  }
}

class $BuyOrderFilterCacheTable extends BuyOrderFilterCache
    with TableInfo<$BuyOrderFilterCacheTable, BuyOrderFilterCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuyOrderFilterCacheTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _systemIdMeta = const VerificationMeta('systemId');
  @override
  late final GeneratedColumn<int?> systemId = GeneratedColumn<int?>(
      'system_id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, systemId];
  @override
  String get aliasedName => _alias ?? 'buy_order_filter_cache';
  @override
  String get actualTableName => 'buy_order_filter_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<BuyOrderFilterCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('system_id')) {
      context.handle(_systemIdMeta,
          systemId.isAcceptableOrUnknown(data['system_id']!, _systemIdMeta));
    } else if (isInserting) {
      context.missing(_systemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuyOrderFilterCacheEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    return BuyOrderFilterCacheEntry.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $BuyOrderFilterCacheTable createAlias(String alias) {
    return $BuyOrderFilterCacheTable(attachedDatabase, alias);
  }
}

class SellOrderFilterCacheEntry extends DataClass
    implements Insertable<SellOrderFilterCacheEntry> {
  final int id;
  final int systemId;
  SellOrderFilterCacheEntry({required this.id, required this.systemId});
  factory SellOrderFilterCacheEntry.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SellOrderFilterCacheEntry(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      systemId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}system_id'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['system_id'] = Variable<int>(systemId);
    return map;
  }

  SellOrderFilterCacheCompanion toCompanion(bool nullToAbsent) {
    return SellOrderFilterCacheCompanion(
      id: Value(id),
      systemId: Value(systemId),
    );
  }

  factory SellOrderFilterCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SellOrderFilterCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      systemId: serializer.fromJson<int>(json['systemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'systemId': serializer.toJson<int>(systemId),
    };
  }

  SellOrderFilterCacheEntry copyWith({int? id, int? systemId}) =>
      SellOrderFilterCacheEntry(
        id: id ?? this.id,
        systemId: systemId ?? this.systemId,
      );
  @override
  String toString() {
    return (StringBuffer('SellOrderFilterCacheEntry(')
          ..write('id: $id, ')
          ..write('systemId: $systemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, systemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SellOrderFilterCacheEntry &&
          other.id == this.id &&
          other.systemId == this.systemId);
}

class SellOrderFilterCacheCompanion
    extends UpdateCompanion<SellOrderFilterCacheEntry> {
  final Value<int> id;
  final Value<int> systemId;
  const SellOrderFilterCacheCompanion({
    this.id = const Value.absent(),
    this.systemId = const Value.absent(),
  });
  SellOrderFilterCacheCompanion.insert({
    this.id = const Value.absent(),
    required int systemId,
  }) : systemId = Value(systemId);
  static Insertable<SellOrderFilterCacheEntry> custom({
    Expression<int>? id,
    Expression<int>? systemId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (systemId != null) 'system_id': systemId,
    });
  }

  SellOrderFilterCacheCompanion copyWith(
      {Value<int>? id, Value<int>? systemId}) {
    return SellOrderFilterCacheCompanion(
      id: id ?? this.id,
      systemId: systemId ?? this.systemId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (systemId.present) {
      map['system_id'] = Variable<int>(systemId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SellOrderFilterCacheCompanion(')
          ..write('id: $id, ')
          ..write('systemId: $systemId')
          ..write(')'))
        .toString();
  }
}

class $SellOrderFilterCacheTable extends SellOrderFilterCache
    with TableInfo<$SellOrderFilterCacheTable, SellOrderFilterCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SellOrderFilterCacheTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _systemIdMeta = const VerificationMeta('systemId');
  @override
  late final GeneratedColumn<int?> systemId = GeneratedColumn<int?>(
      'system_id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, systemId];
  @override
  String get aliasedName => _alias ?? 'sell_order_filter_cache';
  @override
  String get actualTableName => 'sell_order_filter_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<SellOrderFilterCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('system_id')) {
      context.handle(_systemIdMeta,
          systemId.isAcceptableOrUnknown(data['system_id']!, _systemIdMeta));
    } else if (isInserting) {
      context.missing(_systemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SellOrderFilterCacheEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    return SellOrderFilterCacheEntry.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SellOrderFilterCacheTable createAlias(String alias) {
    return $SellOrderFilterCacheTable(attachedDatabase, alias);
  }
}

class EveBuildContextCacheEntry extends DataClass
    implements Insertable<EveBuildContextCacheEntry> {
  final int id;
  final int reactionsSkillLevel;
  final double structureMaterialBonus;
  final double structureTimeBonus;
  final double systemCostIndex;
  final double salesTaxPercent;
  EveBuildContextCacheEntry(
      {required this.id,
      required this.reactionsSkillLevel,
      required this.structureMaterialBonus,
      required this.structureTimeBonus,
      required this.systemCostIndex,
      required this.salesTaxPercent});
  factory EveBuildContextCacheEntry.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return EveBuildContextCacheEntry(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      reactionsSkillLevel: const IntType().mapFromDatabaseResponse(
          data['${effectivePrefix}reactions_skill_level'])!,
      structureMaterialBonus: const RealType().mapFromDatabaseResponse(
          data['${effectivePrefix}structure_material_bonus'])!,
      structureTimeBonus: const RealType().mapFromDatabaseResponse(
          data['${effectivePrefix}structure_time_bonus'])!,
      systemCostIndex: const RealType().mapFromDatabaseResponse(
          data['${effectivePrefix}system_cost_index'])!,
      salesTaxPercent: const RealType().mapFromDatabaseResponse(
          data['${effectivePrefix}sales_tax_percent'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reactions_skill_level'] = Variable<int>(reactionsSkillLevel);
    map['structure_material_bonus'] = Variable<double>(structureMaterialBonus);
    map['structure_time_bonus'] = Variable<double>(structureTimeBonus);
    map['system_cost_index'] = Variable<double>(systemCostIndex);
    map['sales_tax_percent'] = Variable<double>(salesTaxPercent);
    return map;
  }

  EveBuildContextCacheCompanion toCompanion(bool nullToAbsent) {
    return EveBuildContextCacheCompanion(
      id: Value(id),
      reactionsSkillLevel: Value(reactionsSkillLevel),
      structureMaterialBonus: Value(structureMaterialBonus),
      structureTimeBonus: Value(structureTimeBonus),
      systemCostIndex: Value(systemCostIndex),
      salesTaxPercent: Value(salesTaxPercent),
    );
  }

  factory EveBuildContextCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EveBuildContextCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      reactionsSkillLevel:
          serializer.fromJson<int>(json['reactionsSkillLevel']),
      structureMaterialBonus:
          serializer.fromJson<double>(json['structureMaterialBonus']),
      structureTimeBonus:
          serializer.fromJson<double>(json['structureTimeBonus']),
      systemCostIndex: serializer.fromJson<double>(json['systemCostIndex']),
      salesTaxPercent: serializer.fromJson<double>(json['salesTaxPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reactionsSkillLevel': serializer.toJson<int>(reactionsSkillLevel),
      'structureMaterialBonus':
          serializer.toJson<double>(structureMaterialBonus),
      'structureTimeBonus': serializer.toJson<double>(structureTimeBonus),
      'systemCostIndex': serializer.toJson<double>(systemCostIndex),
      'salesTaxPercent': serializer.toJson<double>(salesTaxPercent),
    };
  }

  EveBuildContextCacheEntry copyWith(
          {int? id,
          int? reactionsSkillLevel,
          double? structureMaterialBonus,
          double? structureTimeBonus,
          double? systemCostIndex,
          double? salesTaxPercent}) =>
      EveBuildContextCacheEntry(
        id: id ?? this.id,
        reactionsSkillLevel: reactionsSkillLevel ?? this.reactionsSkillLevel,
        structureMaterialBonus:
            structureMaterialBonus ?? this.structureMaterialBonus,
        structureTimeBonus: structureTimeBonus ?? this.structureTimeBonus,
        systemCostIndex: systemCostIndex ?? this.systemCostIndex,
        salesTaxPercent: salesTaxPercent ?? this.salesTaxPercent,
      );
  @override
  String toString() {
    return (StringBuffer('EveBuildContextCacheEntry(')
          ..write('id: $id, ')
          ..write('reactionsSkillLevel: $reactionsSkillLevel, ')
          ..write('structureMaterialBonus: $structureMaterialBonus, ')
          ..write('structureTimeBonus: $structureTimeBonus, ')
          ..write('systemCostIndex: $systemCostIndex, ')
          ..write('salesTaxPercent: $salesTaxPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      reactionsSkillLevel,
      structureMaterialBonus,
      structureTimeBonus,
      systemCostIndex,
      salesTaxPercent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EveBuildContextCacheEntry &&
          other.id == this.id &&
          other.reactionsSkillLevel == this.reactionsSkillLevel &&
          other.structureMaterialBonus == this.structureMaterialBonus &&
          other.structureTimeBonus == this.structureTimeBonus &&
          other.systemCostIndex == this.systemCostIndex &&
          other.salesTaxPercent == this.salesTaxPercent);
}

class EveBuildContextCacheCompanion
    extends UpdateCompanion<EveBuildContextCacheEntry> {
  final Value<int> id;
  final Value<int> reactionsSkillLevel;
  final Value<double> structureMaterialBonus;
  final Value<double> structureTimeBonus;
  final Value<double> systemCostIndex;
  final Value<double> salesTaxPercent;
  const EveBuildContextCacheCompanion({
    this.id = const Value.absent(),
    this.reactionsSkillLevel = const Value.absent(),
    this.structureMaterialBonus = const Value.absent(),
    this.structureTimeBonus = const Value.absent(),
    this.systemCostIndex = const Value.absent(),
    this.salesTaxPercent = const Value.absent(),
  });
  EveBuildContextCacheCompanion.insert({
    this.id = const Value.absent(),
    required int reactionsSkillLevel,
    required double structureMaterialBonus,
    required double structureTimeBonus,
    required double systemCostIndex,
    required double salesTaxPercent,
  })  : reactionsSkillLevel = Value(reactionsSkillLevel),
        structureMaterialBonus = Value(structureMaterialBonus),
        structureTimeBonus = Value(structureTimeBonus),
        systemCostIndex = Value(systemCostIndex),
        salesTaxPercent = Value(salesTaxPercent);
  static Insertable<EveBuildContextCacheEntry> custom({
    Expression<int>? id,
    Expression<int>? reactionsSkillLevel,
    Expression<double>? structureMaterialBonus,
    Expression<double>? structureTimeBonus,
    Expression<double>? systemCostIndex,
    Expression<double>? salesTaxPercent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reactionsSkillLevel != null)
        'reactions_skill_level': reactionsSkillLevel,
      if (structureMaterialBonus != null)
        'structure_material_bonus': structureMaterialBonus,
      if (structureTimeBonus != null)
        'structure_time_bonus': structureTimeBonus,
      if (systemCostIndex != null) 'system_cost_index': systemCostIndex,
      if (salesTaxPercent != null) 'sales_tax_percent': salesTaxPercent,
    });
  }

  EveBuildContextCacheCompanion copyWith(
      {Value<int>? id,
      Value<int>? reactionsSkillLevel,
      Value<double>? structureMaterialBonus,
      Value<double>? structureTimeBonus,
      Value<double>? systemCostIndex,
      Value<double>? salesTaxPercent}) {
    return EveBuildContextCacheCompanion(
      id: id ?? this.id,
      reactionsSkillLevel: reactionsSkillLevel ?? this.reactionsSkillLevel,
      structureMaterialBonus:
          structureMaterialBonus ?? this.structureMaterialBonus,
      structureTimeBonus: structureTimeBonus ?? this.structureTimeBonus,
      systemCostIndex: systemCostIndex ?? this.systemCostIndex,
      salesTaxPercent: salesTaxPercent ?? this.salesTaxPercent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reactionsSkillLevel.present) {
      map['reactions_skill_level'] = Variable<int>(reactionsSkillLevel.value);
    }
    if (structureMaterialBonus.present) {
      map['structure_material_bonus'] =
          Variable<double>(structureMaterialBonus.value);
    }
    if (structureTimeBonus.present) {
      map['structure_time_bonus'] = Variable<double>(structureTimeBonus.value);
    }
    if (systemCostIndex.present) {
      map['system_cost_index'] = Variable<double>(systemCostIndex.value);
    }
    if (salesTaxPercent.present) {
      map['sales_tax_percent'] = Variable<double>(salesTaxPercent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EveBuildContextCacheCompanion(')
          ..write('id: $id, ')
          ..write('reactionsSkillLevel: $reactionsSkillLevel, ')
          ..write('structureMaterialBonus: $structureMaterialBonus, ')
          ..write('structureTimeBonus: $structureTimeBonus, ')
          ..write('systemCostIndex: $systemCostIndex, ')
          ..write('salesTaxPercent: $salesTaxPercent')
          ..write(')'))
        .toString();
  }
}

class $EveBuildContextCacheTable extends EveBuildContextCache
    with TableInfo<$EveBuildContextCacheTable, EveBuildContextCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EveBuildContextCacheTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _reactionsSkillLevelMeta =
      const VerificationMeta('reactionsSkillLevel');
  @override
  late final GeneratedColumn<int?> reactionsSkillLevel = GeneratedColumn<int?>(
      'reactions_skill_level', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _structureMaterialBonusMeta =
      const VerificationMeta('structureMaterialBonus');
  @override
  late final GeneratedColumn<double?> structureMaterialBonus =
      GeneratedColumn<double?>('structure_material_bonus', aliasedName, false,
          type: const RealType(), requiredDuringInsert: true);
  final VerificationMeta _structureTimeBonusMeta =
      const VerificationMeta('structureTimeBonus');
  @override
  late final GeneratedColumn<double?> structureTimeBonus =
      GeneratedColumn<double?>('structure_time_bonus', aliasedName, false,
          type: const RealType(), requiredDuringInsert: true);
  final VerificationMeta _systemCostIndexMeta =
      const VerificationMeta('systemCostIndex');
  @override
  late final GeneratedColumn<double?> systemCostIndex =
      GeneratedColumn<double?>('system_cost_index', aliasedName, false,
          type: const RealType(), requiredDuringInsert: true);
  final VerificationMeta _salesTaxPercentMeta =
      const VerificationMeta('salesTaxPercent');
  @override
  late final GeneratedColumn<double?> salesTaxPercent =
      GeneratedColumn<double?>('sales_tax_percent', aliasedName, false,
          type: const RealType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        reactionsSkillLevel,
        structureMaterialBonus,
        structureTimeBonus,
        systemCostIndex,
        salesTaxPercent
      ];
  @override
  String get aliasedName => _alias ?? 'eve_build_context_cache';
  @override
  String get actualTableName => 'eve_build_context_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<EveBuildContextCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reactions_skill_level')) {
      context.handle(
          _reactionsSkillLevelMeta,
          reactionsSkillLevel.isAcceptableOrUnknown(
              data['reactions_skill_level']!, _reactionsSkillLevelMeta));
    } else if (isInserting) {
      context.missing(_reactionsSkillLevelMeta);
    }
    if (data.containsKey('structure_material_bonus')) {
      context.handle(
          _structureMaterialBonusMeta,
          structureMaterialBonus.isAcceptableOrUnknown(
              data['structure_material_bonus']!, _structureMaterialBonusMeta));
    } else if (isInserting) {
      context.missing(_structureMaterialBonusMeta);
    }
    if (data.containsKey('structure_time_bonus')) {
      context.handle(
          _structureTimeBonusMeta,
          structureTimeBonus.isAcceptableOrUnknown(
              data['structure_time_bonus']!, _structureTimeBonusMeta));
    } else if (isInserting) {
      context.missing(_structureTimeBonusMeta);
    }
    if (data.containsKey('system_cost_index')) {
      context.handle(
          _systemCostIndexMeta,
          systemCostIndex.isAcceptableOrUnknown(
              data['system_cost_index']!, _systemCostIndexMeta));
    } else if (isInserting) {
      context.missing(_systemCostIndexMeta);
    }
    if (data.containsKey('sales_tax_percent')) {
      context.handle(
          _salesTaxPercentMeta,
          salesTaxPercent.isAcceptableOrUnknown(
              data['sales_tax_percent']!, _salesTaxPercentMeta));
    } else if (isInserting) {
      context.missing(_salesTaxPercentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EveBuildContextCacheEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    return EveBuildContextCacheEntry.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $EveBuildContextCacheTable createAlias(String alias) {
    return $EveBuildContextCacheTable(attachedDatabase, alias);
  }
}

abstract class _$CacheDatabase extends GeneratedDatabase {
  _$CacheDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  _$CacheDatabase.connect(DatabaseConnection c) : super.connect(c);
  late final $ReactionsCacheTable reactionsCache = $ReactionsCacheTable(this);
  late final $IntermediatesToBuyCacheTable intermediatesToBuyCache =
      $IntermediatesToBuyCacheTable(this);
  late final $InventoryCacheTable inventoryCache = $InventoryCacheTable(this);
  late final $MarketOrdersCacheTable marketOrdersCache =
      $MarketOrdersCacheTable(this);
  late final $BuyOrderFilterCacheTable buyOrderFilterCache =
      $BuyOrderFilterCacheTable(this);
  late final $SellOrderFilterCacheTable sellOrderFilterCache =
      $SellOrderFilterCacheTable(this);
  late final $EveBuildContextCacheTable eveBuildContextCache =
      $EveBuildContextCacheTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        reactionsCache,
        intermediatesToBuyCache,
        inventoryCache,
        marketOrdersCache,
        buyOrderFilterCache,
        sellOrderFilterCache,
        eveBuildContextCache
      ];
}
