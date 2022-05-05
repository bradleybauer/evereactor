import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../models/blueprint_options.dart';
import '../models/market_order.dart';
import '../models/options.dart';
import '../models/order_filter.dart';
import '../platform_stub.dart' if (dart.library.io) '../platform_desktop.dart' if (dart.library.html) '../platform_web.dart';
import 'database.dart';

class Persistence {
  final CacheDatabase cache = CacheDatabase(Platform.createDatabaseConnection('EveReactorCache'));

  Future<void> _clearCache(table) async {
    await cache.delete(table).go();
  }

  Future<Map<int, int>> getTargets2Runs() async {
    final xs = await cache.select(cache.targetsCache).get();
    return Map.fromEntries(xs.map((e) => MapEntry(e.id, e.runs)));
  }

  Future<void> setTargets2Runs(Map<int, int> tid2runs) async {
    await _clearCache(cache.targetsCache);
    var inserts = tid2runs.entries.map((e) => TargetsCacheCompanion.insert(id: Value(e.key), runs: e.value));
    await cache.batch((batch) => batch.insertAll(cache.targetsCache, inserts));
  }

  Future<Map<int, BpOptions>> getBpOptions() async {
    final xs = await cache.select(cache.itemBpOptionsCache).get();
    return Map.fromEntries(xs.map((e) => MapEntry(e.id, BpOptions(ME: e.ME, TE: e.TE, maxNumRuns: e.MaxRuns, maxNumBPs: e.MaxBps))));
  }

  Future<void> setBpOptions(Map<int, BpOptions> bps) async {
    await _clearCache(cache.itemBpOptionsCache);
    final inserts = bps.entries
        .map((o) => ItemBpOptionsCacheCompanion.insert(
              id: Value(o.key),
              ME: Value(o.value.ME),
              TE: Value(o.value.TE),
              MaxBps: Value(o.value.maxNumBPs),
              MaxRuns: Value(o.value.maxNumRuns),
            ))
        .toList();
    await cache.batch((batch) {
      batch.insertAll(cache.itemBpOptionsCache, inserts);
    });
  }

  Future<Map<int,bool>> getShouldBuild() async {
    return Map.fromEntries((await cache.select(cache.shouldBuildCache).get()).map((e) => MapEntry(e.id, e.shouldBuild)));
  }

  Future<void> setShouldBuild(Map<int, bool> shouldBuilds) async {
    await _clearCache(cache.shouldBuildCache);
    var inserts = shouldBuilds.entries.map((e) => ShouldBuildCacheCompanion.insert(id: Value(e.key), shouldBuild: e.value));
    await cache.batch((batch) => batch.insertAll(cache.shouldBuildCache, inserts));
  }

  Future<Map<int, int>> getInventory() async {
    Map<int, int> result = {};
    final inventory = await cache.select(cache.inventoryCache).get();
    for (var item in inventory) {
      result[item.id] = item.quantity;
    }
    return result;
  }

  Future<void> clearInventoryCache() async {
    await _clearCache(cache.inventoryCache);
  }

  Future<void> setInventory(Map<int, int> inventory) async {
    await clearInventoryCache();
    var inserts = inventory.entries.map((e) => InventoryCacheCompanion.insert(id: Value(e.key), quantity: e.value));
    await cache.batch((batch) => batch.insertAll(cache.inventoryCache, inserts));
  }

  Future<Map<int, List<Order>>> getOrders() async {
    Map<int, List<Order>> orders = {};
    final rows = await cache.select(cache.marketOrdersCache).get();
    for (MarketOrdersCacheEntry entry in rows) {
      final tid = entry.typeID;
      if (!orders.containsKey(tid)) {
        orders[tid] = [];
      }
      orders[tid]!.add(Order(tid, entry.systemID, entry.regionID, entry.isBuy, entry.price, entry.volumeRemaining));
    }
    return orders;
  }

  Future<void> setOrders(Map<int, List<Order>> orders) async {
    await _clearCache(cache.marketOrdersCache);
    List<MarketOrdersCacheCompanion> inserts = [];
    for (int id in orders.keys) {
      inserts.addAll(orders[id]!.map((o) => MarketOrdersCacheCompanion.insert(
            typeID: o.typeID,
            systemID: o.systemID,
            regionID: o.regionID,
            isBuy: o.isBuy,
            price: o.price,
            volumeRemaining: o.volumeRemaining,
          )));
    }
    await cache.batch((batch) {
      batch.insertAll(cache.marketOrdersCache, inserts);
    });
  }

  Future<Map<int, double>> getAdjustedPrices() async {
    Map<int, double> prices = {};
    final rows = await cache.select(cache.adjustedPricesCache).get();
    for (var entry in rows) {
      prices[entry.typeID] = entry.price;
    }
    return prices;
  }

  Future<void> setAdjustedPrices(Map<int, double> prices) async {
    await _clearCache(cache.adjustedPricesCache);
    final inserts = prices.entries.map((o) => AdjustedPricesCacheCompanion.insert(typeID: o.key, price: o.value));
    await cache.batch((batch) {
      batch.insertAll(cache.adjustedPricesCache, inserts);
    });
  }

  Future<OrderFilter> getOrderFilter() async {
    final systems = await cache.select(cache.orderFilterCache).get();
    return OrderFilter(systems.map((s) => s.systemId));
  }

  Future<void> setOrderFilter(OrderFilter filter) async {
    await _clearCache(cache.orderFilterCache);
    final inserts = filter.getSystems().map((e) => OrderFilterCacheCompanion.insert(systemId: e));
    await cache.batch((batch) => batch.insertAll(cache.orderFilterCache, inserts));
  }

  Future<Options?> getOptions() async {
    final rows = await cache.select(cache.optionsCache).get();
    if (rows.isEmpty) {
      return null;
    }
    final options = Options();
    options.setReactionSlots(rows[0].reactionJobs);
    options.setManufacturingSlots(rows[0].manufacturingJobs);
    options.setME(rows[0].ME);
    options.setTE(rows[0].TE);
    options.setMaxNumBlueprints(rows[0].MaxBps);
    options.setManufacturingStructure(rows[0].manufacturingStructure);
    options.setReactionStructure(rows[0].reactionStructure);
    options.setManufacturingSystemCostIndex(rows[0].manufacturingCostIndex);
    options.setReactionSystemCostIndex(rows[0].reactionCostIndex);
    options.setSalesTaxPercent(rows[0].salesTaxPercent);
    return options;
  }


  Future<void> setOptions(Options options) async {
    await _clearCache(cache.optionsCache);
    final companion = OptionsCacheCompanion.insert(
      reactionJobs: (options.getReactionSlots()),
      manufacturingJobs: (options.getManufacturingSlots()),
      ME: (options.getME()),
      TE: (options.getTE()),
      MaxBps: (options.getMaxNumBlueprints()),
      manufacturingStructure: (options.getManufacturingStructure()),
      reactionStructure: (options.getReactionStructure()),
      manufacturingCostIndex: (options.getManufacturingSystemCostIndex()),
      reactionCostIndex: (options.getReactionSystemCostIndex()),
      salesTaxPercent: (options.getSalesTaxPercent()),
    );
    await cache.into(cache.optionsCache).insert(companion);
  }

  Future<Map<int, int>> getSkills2Level() async {
    final rows = await cache.select(cache.skillsLevelCache).get();
    final skills2level = <int, int>{};
    for (var row in rows) {
      skills2level[row.skillId] = row.level;
    }
    return skills2level;
  }

  Future<void> setSkills2Level(Map<int, int> skills2level) async {
    await _clearCache(cache.skillsLevelCache);
    final inserts = skills2level.entries.map((e) => SkillsLevelCacheCompanion.insert(
          skillId: e.key,
          level: e.value,
        ));
    await cache.batch((batch) => batch.insertAll(cache.skillsLevelCache, inserts));
  }

  Future<Set<int>> getManufacturingRigs() async {
    final rows = await cache.select(cache.manufacturingRigsCache).get();
    return rows.map((e) => e.tid).toSet();
  }

  Future<void> setManufacturingRigs(Set<int> rigs) async {
    await _clearCache(cache.manufacturingRigsCache);
    final inserts = rigs.map((e) => ManufacturingRigsCacheCompanion.insert(tid: e));
    await cache.batch((batch) => batch.insertAll(cache.manufacturingRigsCache, inserts));
  }

  Future<Set<int>> getReactionRigs() async {
    final rows = await cache.select(cache.reactionRigsCache).get();
    return rows.map((e) => e.tid).toSet();
  }

  Future<void> setReactionRigs(Set<int> rigs) async {
    await _clearCache(cache.reactionRigsCache);
    final inserts = rigs.map((e) => ReactionRigsCacheCompanion.insert(tid: e));
    await cache.batch((batch) => batch.insertAll(cache.reactionRigsCache, inserts));
  }

  Future<bool> getIsDarkMode() async {
    final statement = cache.select(cache.darkModeCache);
    final rows = await statement.get();
    if (rows.isEmpty) {
      return false;
    }
    return rows[0].isDarkMode;
  }

  Future<void> setIsDarkMode(bool x) async {
    await _clearCache(cache.darkModeCache);
    await cache.into(cache.darkModeCache).insert(DarkModeCacheCompanion.insert(isDarkMode: x));
  }

  Future<Color> getColor() async {
    final rows = await cache.select(cache.colorCache).get();
    if (rows.isEmpty) {
      return Colors.pink;
    }
    return Color(rows[0].color);
  }

  Future<void> setColor(Color x) async {
    await _clearCache(cache.colorCache);
    await cache.into(cache.colorCache).insert(ColorCacheCompanion.insert(color: x.value));
  }

  Future<void> clear() async {
    for (var table in cache.allTables) {
      await cache.delete(table).go();
    }
  }
}
