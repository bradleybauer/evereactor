import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/market.dart';
import '../models/market_order.dart';
import '../models/order_filter.dart';
import '../persistence/persistence.dart';
import '../sde.dart';

enum EsiState {
  CurrentlyFetchingData,
  Idle,
}

class MarketController with ChangeNotifier {
  final Persistence _persistence;
  final Market _market = Market();

  EsiState _esiState = EsiState.Idle;

  MarketController(this._persistence);

  Future<void> loadFromCache() async {
    final adjustedPrices = await _persistence.getAdjustedPrices();
    final orders = await _persistence.getOrders();
    final orderFilter = await _persistence.getOrderFilter();
    _market.setAdjustedPrices(adjustedPrices);
    _market.setOrders(orders);
    _market.setOrderFilter(orderFilter);
    notifyListeners();
  }

  Future<void> updateMarketData({required void Function(double) progressCallback}) async {
    _esiState = EsiState.CurrentlyFetchingData;
    progressCallback(0.0);

    Map<int, List<Order>> orders = await _fetchMarketData(callback: progressCallback);
    Map<int, double> adjustedPrices = await _fetchAdjustedPrices();

    _market.setAdjustedPrices(adjustedPrices);
    await _persistence.setAdjustedPrices(adjustedPrices);
    _market.setOrders(orders);
    await _persistence.setOrders(orders);

    // TODO market data is cached every 300 seconds on esi server... so only allow updating once every 300 seconds.
    // _market.setOrderFetchTime(DateTime.now());

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
            _addB2A(result, tid2regionOrders);
          }
        } catch (e) {}

        numRequestsProcessed += numPagesToRequest;
        callback(numRequestsProcessed / totalLen);
      }
    }

    return result;
  }

  Uri _getUri(int region, [int? page]) {
    return Uri.parse('https://esi.evetech.net/latest/markets/$region/orders/?datasource=tranquility&order_type=all&page=${page ?? 1}');
  }

  // static int xxx = 0; // there are about 161k orders that I accept
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
      if (!OrderFilter.allSystems(system)) {
        continue;
      }

      final volume = x['volume_remain'] as int;
      if (volume == 0) {
        continue;
      }
      final price = x['price'] as double;
      if (price == 0.0) {
        continue;
      }
      final isBuy = x['is_buy_order'] as bool;
      if (!ret.containsKey(tid)) {
        ret[tid] = [];
      }
      // xxx += 1;
      ret[tid]!.add(Order(tid, system, region, isBuy, price, volume));
    }
    // print(xxx);
    return ret;
  }

  void _addB2A(Map<int, List<Order>> a, Map<int, List<Order>> b) {
    for (var entry in b.entries) {
      if (a.containsKey(entry.key)) {
        a[entry.key] = a[entry.key]! + entry.value;
      } else {
        a[entry.key] = entry.value;
      }
    }
  }

  OrderFilter getOrderFilter() => _market.getOrderFilter();

  Map<int, double> avgBuyFromSell(Map<int, int> bom) => _market.avgBuyFromSell(bom);

  double avgBuyFromSellItem(int id, int quantity) => _market.avgBuyFromSellItem(id, quantity);

  double avgSellToBuyItem(int tid, int quantity) => _market.avgSellToBuyItem(tid, quantity);

  int buyVolume25Percent(int tid) => _market.buyVolume25Percent(tid);

  void setOrderFilter(OrderFilter newFilter) {
    if (newFilter.getSystems().isEmpty) {
      newFilter = OrderFilter.acceptAll();
    }
    _persistence.setOrderFilter(newFilter);
    _market.setOrderFilter(newFilter);
    notifyListeners();
  }

  void removeSystemFromFilter(int systemID) {
    setOrderFilter(_market.getOrderFilter().copyWithout(systemID));
  }

  void addSystemToFilter(int systemID) {
    setOrderFilter(_market.getOrderFilter().copyWith(systemID));
  }

  Set<int> getOrderFilterSystems() => _market.getOrderFilter().getSystems();

  Map<int, double> getAdjustedPrices() => _market.getAdjustedPrices();

  double? getAdjustedPrice(int tid) => _market.getAdjustedPrice(tid);

  Map<int, Map<int, int>> splitBuyFromSellPerRegion(Map<int, int> bom) => _market.splitBuyFromSellPerRegion(bom);

  Map<int, Map<int, int>> splitSellToBuyPerRegion(Map<int, int> bom) => _market.splitSellToBuyPerRegion(bom);

  Map<int,double> avgSellToBuy(Map<int, int> bom) => _market.avgSellToBuy(bom);
}
