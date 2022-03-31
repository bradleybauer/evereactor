import 'package:EveIndy/cache_database/cache_database.dart';
import 'package:EveIndy/cache_database/platform.dart';
import 'package:EveIndy/model/context.dart';
import 'package:EveIndy/model/order_filter.dart';
import 'package:drift/drift.dart';
import 'package:tuple/tuple.dart';

import '../model/market.dart';
import '../model/market_order.dart';
import 'cache_database.dart';

class CacheDatabaseAdapter {
  final CacheDatabase cache = CacheDatabase(Platform.createDatabaseConnection('EveReactorCache'));

  Future<void> _clearCache(table) async {
    await cache.delete(table).go();
  }

  Future<Map<int, List<Order>>> getOrders() async {
    Map<int, List<Order>> orders = {};
    for (int id in Market.restrictToTypeIDs) {
      orders[id] = [];
      final rows = await (cache.select(cache.marketOrdersCache)..where((r) => r.typeID.equals(id))).get();
      for (MarketOrdersCacheEntry entry in rows) {
        orders[id]!.add(Order(id, entry.systemID, entry.regionID, entry.isBuy, entry.price, entry.volumeRemaining));
      }
    }
    return orders;
  }

  Future<void> setOrders(Map<int, List<Order>> orders) async {
    await _clearCache(cache.marketOrdersCache);
    List<MarketOrdersCacheCompanion> inserts = [];
    for (int id in orders.keys) {
      inserts.addAll(orders[id]!.map((o) => MarketOrdersCacheCompanion.insert(
          typeID: o.typeID, systemID: o.systemID, regionID: o.regionID, isBuy: o.isBuy, price: o.price, volumeRemaining: o.volumeRemaining)));
    }
    await cache.batch((batch) {
      batch.insertAll(cache.marketOrdersCache, inserts);
    });
  }

  Future<OrderFilter> getOrderFilter(bool buy) async {
    if (buy) {
      final systems = await cache.select(cache.buyOrderFilterCache).get();
      return OrderFilter(systems.map((s) => s.systemId).toList());
    } else {
      final systems = await cache.select(cache.sellOrderFilterCache).get();
      return OrderFilter(systems.map((s) => s.systemId).toList());
    }
  }

  Future<void> setOrderFilter(OrderFilter filter, bool isBuy) async {
    if (isBuy) {
      await _clearCache(cache.buyOrderFilterCache);
      final inserts = filter.systems.map((e) => BuyOrderFilterCacheCompanion.insert(systemId: e));
      await cache.batch((batch) => batch.insertAll(cache.buyOrderFilterCache, inserts));
    } else {
      await _clearCache(cache.sellOrderFilterCache);
      final inserts = filter.systems.map((e) => SellOrderFilterCacheCompanion.insert(systemId: e));
      await cache.batch((batch) => batch.insertAll(cache.sellOrderFilterCache, inserts));
    }
  }

  Future<void> setBuildContext(EveBuildContext ctx) async {
    await _clearCache(cache.eveBuildContextCache);
    final companion = EveBuildContextCacheCompanion(
        reactionsSkillLevel: Value(ctx.reactionSkillLevel),
        structureMaterialBonus: Value(ctx.structureMaterialBonus),
        structureTimeBonus: Value(ctx.structureTimeBonus),
        systemCostIndex: Value(ctx.systemCostIndex),
        salesTaxPercent: Value(ctx.salesTaxPercent));
    await cache.into(cache.eveBuildContextCache).insert(companion);
  }

  Future<EveBuildContext?> getBuildContext() async {
    final rows = await cache.select(cache.eveBuildContextCache).get();
    if (rows.isEmpty) {
      return null;
    }
    return EveBuildContext(rows[0].reactionsSkillLevel, rows[0].structureMaterialBonus, rows[0].structureTimeBonus, rows[0].systemCostIndex,
        rows[0].salesTaxPercent, 0);
  }

  Future<Iterable<Tuple3<int, int, int>>> getReactions() async {
    final xs = await cache.select(cache.reactionsCache).get();
    return xs.map((e) => Tuple3(e.id, e.runs, e.lines));
  }

  Future<Iterable<int>> getIntermediatesToBuy() async {
    return (await cache.select(cache.intermediatesToBuyCache).get()).map((e) => e.id);
  }

  Future<Map<int, int>> getInventoryItemsAndQuantities() async {
    Map<int, int> ret = {};
    final inventory = await cache.select(cache.inventoryCache).get();
    for (var item in inventory) {
      ret[item.id] = item.quantity;
    }
    return ret;
  }

  Future<void> clearInventoryCache() async {
    await _clearCache(cache.inventoryCache);
  }

  Future<void> setInventory(Map<int, int> inventory) async {
    clearInventoryCache();
    var inserts = inventory.entries.map((e) => InventoryCacheCompanion.insert(id: Value(e.key), quantity: e.value));
    await cache.batch((batch) => batch.insertAll(cache.inventoryCache, inserts));
  }

  Future<void> setIntermediatesToBuy(Iterable<int> ids) async {
    _clearCache(cache.intermediatesToBuyCache);
    var inserts = ids.map((id) => IntermediatesToBuyCacheCompanion.insert(id: Value(id)));
    await cache.batch((batch) => batch.insertAll(cache.intermediatesToBuyCache, inserts));
  }

  Future<void> setReactions(Iterable<Tuple3<int, int, int>> idRunsLines) async {
    _clearCache(cache.reactionsCache);
    var inserts = idRunsLines.map((e) => ReactionsCacheCompanion.insert(id: Value(e.item1), runs: e.item2, lines: e.item3));
    await cache.batch((batch) => batch.insertAll(cache.reactionsCache, inserts));
  }

  void clear() {
    for (var table in cache.allTables) {
      cache.delete(table);
    }
  }
}
