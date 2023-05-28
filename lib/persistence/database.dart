import 'package:drift/drift.dart';

// assuming that your file is called filename.dart. This will give an error at first,
// but it's needed for drift to know about the generated code
part 'database.g.dart';

@DataClassName("TargetsCacheEntry")
class TargetsCache extends Table {
  IntColumn get id => integer()();

  IntColumn get runs => integer()();


  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("ItemBpOptionsCacheEntry")
class ItemBpOptionsCache extends Table {
  IntColumn get id => integer()();

  IntColumn get ME => integer().nullable()();

  IntColumn get TE => integer().nullable()();

  IntColumn get MaxRuns => integer().nullable()();

  IntColumn get MaxBps => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("ShouldBuildCacheEntry")
class ShouldBuildCache extends Table {
  IntColumn get id => integer()();

  BoolColumn get shouldBuild => boolean()();

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

@DataClassName("AdjustedPricesCacheEntry")
class AdjustedPricesCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get typeID => integer()();

  RealColumn get price => real()();
}

@DataClassName("OptionsCacheEntry")
class OptionsCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get reactionJobs => integer()();

  IntColumn get manufacturingJobs => integer()();

  IntColumn get ME => integer()();

  IntColumn get TE => integer()();

  IntColumn get MaxBps => integer()();

  IntColumn get manufacturingStructure => integer()();

  IntColumn get reactionStructure => integer()();

  RealColumn get reactionCostIndex => real()();

  RealColumn get manufacturingCostIndex => real()();

  RealColumn get salesTaxPercent => real()();
}

@DataClassName("SkillsLevelCacheEntry")
class SkillsLevelCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get skillId => integer()();

  IntColumn get level => integer()();
}

@DataClassName("ManufacturingRigsCacheEntry")
class ManufacturingRigsCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get tid => integer()();
}

@DataClassName("ReactionRigsCacheEntry")
class ReactionRigsCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get tid => integer()();
}

@DataClassName("OrderFilterCacheEntry")
class OrderFilterCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get systemId => integer()();
}

// @DataClassName("SelectedLanguageCache")
// class SelectedLanguageCache extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   IntColumn get selectedLanguage => integer()();
// }

@DataClassName("DarkModeCacheEntry")
class DarkModeCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  BoolColumn get isDarkMode => boolean()();
}

@DataClassName("ColorCacheEntry")
class ColorCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get color => integer()();
}

@DriftDatabase(tables: [
  TargetsCache,
  ItemBpOptionsCache,
  ShouldBuildCache,
  InventoryCache,
  MarketOrdersCache,
  AdjustedPricesCache,
  OrderFilterCache,
  OptionsCache,
  SkillsLevelCache,
  ManufacturingRigsCache,
  ReactionRigsCache,
  DarkModeCache,
  ColorCache,
])
class CacheDatabase extends _$CacheDatabase {
  CacheDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll(); // create all tables
      },
      onUpgrade: (Migrator m, int from, int to) async {
        await m.createAll();
      }
    );
  }
}
