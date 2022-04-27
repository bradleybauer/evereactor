import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/market.dart';
import '../models/market_order.dart';
import '../models/order_filter.dart';
import '../sde.dart';

enum EsiState {
  CurrentlyFetchingData,
  Idle,
}

class MarketController with ChangeNotifier {
  // final CacheDatabaseController _cache;

  final Market _market = Market();

  EsiState _esiState = EsiState.Idle;

  // MarketController(this._cache);

  // Future<void> updateOrderFilter(List<int> systemIds, bool isBuy) async {
  //   final filter = OrderFilter(systemIds);
  //   market.setMarketFilter(filter, isBuy);
  //   await _cache.setOrderFilter(filter, isBuy);
  //   notifyListeners();
  // }

  Future<void> updateMarketData({required void Function(double) progressCallback}) async {
    _esiState = EsiState.CurrentlyFetchingData;
    progressCallback(0.0);

    Map<int, List<Order>> orders = await _fetchMarketData(callback: progressCallback);
    Map<int, double> adjustedPrices = await _fetchAdjustedPrices();

    _market.setAdjustedPrices(adjustedPrices);
    _market.setOrders(orders);

    // TODO market data is cached every 300 seconds on esi server... so only allow updating once every 300 seconds.
    // _market.setOrderFetchTime(DateTime.now());

    // _cache.setMarket(market);

    _esiState = EsiState.Idle;
    notifyListeners();
  }

  EsiState getEsiState() => _esiState;

  Future<Map<int, double>> _fetchAdjustedPrices() async {
    var response = await http.get(Uri.parse('https://esi.evetech.net/latest/markets/prices/?datasource=tranquility'));
    var data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {};
    }

    Map<int, double> ret = {};

    try {
      for (var x in data) {
        final tid = x['type_id'];
        if (!SDE.items.containsKey(tid)) {
          // only accept industry related items
          continue;
        }
        ret[tid] = x['adjusted_price'];
      }
    } catch (e) {}

    return ret;
  }

  // todo relay any important errors to the user.
  Future<Map<int, List<Order>>> _fetchMarketData({required void Function(double) callback}) async {
    final result = <int, List<Order>>{};
    // Get number of pages
    int numRequestsProcessed = 0;
    final region2pages = <int, int>{};
    for (int region in SDE.region2systems.keys) {
      try {
        final initialReq = await http.get(_getUri(region));
        region2pages[region] = int.parse(initialReq.headers['x-pages']!);
      } catch (e) {}
      numRequestsProcessed += 1;
    }

    // Get pages
    final totalLen = region2pages.values.fold(0, (int p, e) => p + e);
    for (int region in SDE.region2systems.keys) {
      if (!region2pages.containsKey(region)) {
        continue;
      }
      var tid2regionOrders = <int, List<Order>>{};
      var urls = List<Uri>.generate(region2pages[region]! - 1, (page) => _getUri(region, page + 2)); // page starts at 0
      while (urls.isNotEmpty) {
        final numPagesToRequest = min(urls.length, 30);
        final chunk = urls.sublist(0, numPagesToRequest);
        urls = urls.sublist(numPagesToRequest);

        try {
          final chunkResults = await Future.wait(chunk.map((e) => http.get(e)));
          for (var response in chunkResults) {
            if (response.statusCode != 200) {
              continue;
            }
            final data = jsonDecode(response.body);
            tid2regionOrders = _getOrdersFromPage(region, data);
            addB2A(result, tid2regionOrders);
          }
        } catch (e) {}

        numRequestsProcessed += numPagesToRequest;
        callback(numRequestsProcessed / totalLen);
      }
    }

    return result;
  }

  Uri _getUri(int region, [int? page]) {
    return Uri.parse('https://esi.evetech.net/latest/markets/' +
        region.toString() +
        '/orders/?datasource=tranquility&order_type=all&page=' +
        (page ?? 1).toString());
  }

  Map<int, List<Order>> _getOrdersFromPage(int region, data) {
    final ret = <int, List<Order>>{};
    for (var x in data) {
      final tid = x['type_id'];
      final system = x['system_id'];
      if (!SDE.items.containsKey(tid)) {
        // only accept industry related items
        continue;
      }
      // if not in some system that I care about then ignore
      if (OrderFilter.allSystems(system)) {
        continue;
      }

      if (!ret.containsKey(tid)) ret[tid] = [];
      ret[tid]!.add(Order(tid, system, region, x['is_buy_order'], x['price'], x['volume_remain']));
    }
    return ret;
  }

  void addB2A(Map<int, List<Order>> a, Map<int, List<Order>> b) {
    for (var entry in b.entries) {
      if (a.containsKey(entry.key)) {
        a[entry.key] = a[entry.key]! + entry.value;
      } else {
        a[entry.key] = entry.value;
      }
    }
  }

  OrderFilter getOrderFilter() => _market.getOrderFilter();

// Future<void> loadFromCache() async {
// }
}
