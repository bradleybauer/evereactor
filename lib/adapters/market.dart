import 'package:flutter/material.dart';

class MarketAdapter with ChangeNotifier {
  // final CacheDatabaseAdapter _cache;

  // MarketAdapter(this.market, this._cache);

  // OrderFilter getOrderFilter(bool buy) {
  //   return market.getOrderFilter(buy);
  // }

  // Future<void> updateOrderFilter(List<int> systemIds, bool isBuy) async {
  //   final filter = OrderFilter(systemIds);
  //   market.setMarketFilter(filter, isBuy);
  //   await _cache.setOrderFilter(filter, isBuy);
  //   notifyListeners();
  // }

  // void setMarketLogs(Map<String, String> marketLogsName2Content) {
  //   market.loadMarketLogs(marketLogsName2Content);
  //   Map<int, List<Order>> orders = market.getAsMap();
  //   _cache.setOrders(orders);
  //   notifyListeners();
  // }

  // Future<void> loadFromCache() async {
  // }
}