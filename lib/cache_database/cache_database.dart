import 'package:drift/drift.dart';

// assuming that your file is called filename.dart. This will give an error at first,
// but it's needed for drift to know about the generated code
part 'cache_database.g.dart';

@DataClassName("ReactionsCacheEntry")
class ReactionsCache extends Table {
  IntColumn get id => integer()();
  IntColumn get runs => integer()();
  IntColumn get lines => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("IntermediatesToBuyCacheEntry")
class IntermediatesToBuyCache extends Table {
  IntColumn get id => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("InventoryCacheEntry")
class InventoryCache extends Table {
  IntColumn get id => integer()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("MarketOrdersCacheEntry")
class MarketOrdersCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get typeID => integer()();
  IntColumn get systemID => integer()();
  IntColumn get regionID => integer()();
  BoolColumn get isBuy => boolean()();
  RealColumn get price => real()();
  IntColumn get volumeRemaining => integer()();
}

@DataClassName("BuyOrderFilterCacheEntry")
class BuyOrderFilterCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get systemId => integer()();
}

@DataClassName("SellOrderFilterCacheEntry")
class SellOrderFilterCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get systemId => integer()();
}

@DataClassName("EveBuildContextCacheEntry")
class EveBuildContextCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reactionsSkillLevel => integer()();
  RealColumn get structureMaterialBonus => real()();
  RealColumn get structureTimeBonus => real()();
  RealColumn get systemCostIndex => real()();
  RealColumn get salesTaxPercent => real()();
}

@DriftDatabase(tables: [
  ReactionsCache,
  IntermediatesToBuyCache,
  InventoryCache,
  MarketOrdersCache,
  BuyOrderFilterCache,
  SellOrderFilterCache,
  EveBuildContextCache
])
class CacheDatabase extends _$CacheDatabase {
  CacheDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) async {
        await m.createAll(); // create all tables
      });
}
