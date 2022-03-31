import 'package:EveIndy/model/util.dart';
import 'eve_sde.dart';
import 'market_order.dart';
import 'order_filter.dart';

import 'package:tuple/tuple.dart';

class BuysSells {
  List<Order> buys = [];
  List<Order> sells = [];
}

class Market {
  // A map from typeIDs to orders
  // For a typeID given in restrictToTypeIDs, the List<Order> may be empty but it is never null.
  final Map<int, List<Order>> _market = {};

  OrderFilter _buysFilter = OrderFilter.acceptAll();
  OrderFilter _sellsFilter = OrderFilter.acceptAll();
  Map<int, BuysSells> _filteredMarket = {};

  Map<int, double> adjustedPrices = {};

  // static List<int> restrictToTypeIDs = EveStaticData.items.keys.toList();
  static List<int> restrictToTypeIDs = [];

  Market() {
    for (int id in restrictToTypeIDs) {
      _market[id] = [];
    }
    _filteredMarket = {};
    for (var id in _market.keys) {
      _filteredMarket[id] = BuysSells();
    }
  }

  void loadMarketLogs(Map<String, String> filename2content) {
    // TODO show warning that no orders were found for typeID in market logs

    // Make sure that _market does not contain any null values
    for (var typeID in restrictToTypeIDs) {
      _market[typeID] = [];
    }

    List<Tuple3<DateTime, int, String>> content = [];
    for (var entry in filename2content.entries) {
      final name = entry.key;
      final logIdStr = name.substring(0, name.length - 4).split(' ').last;
      final logId = int.parse(logIdStr);
      final dateStr = name.substring(0, name.length - 4).split('-').last.split(' ').first.replaceAll('.', '-'); //.split('.');
      final date = DateTime.parse(dateStr);
      content.add(Tuple3(date, logId, entry.value));
    }
    // sort in decreasing order
    content.sort((a, b) {
      var x = b.item1.compareTo(a.item1);
      if (x == 0) {
        return b.item2.compareTo(a.item2);
      }
      return x;
    });

    Map<int, Set<int>> regionsSeenForTypeID = {};
    for (var _typeID in restrictToTypeIDs) {
      regionsSeenForTypeID[_typeID] = {};
    }

    // Parse orders
    for (var id2content in content) {
      var lines = id2content.item3.split('\n');
      // discard header which is always the first line
      lines = lines.sublist(1, lines.length - 1);

      // What typeID and regionID does this file contain orders for
      int _typeID = -1;
      int _regionID = -1;

      for (var line in lines) {
        try {
          final cols = line.substring(0, line.length - 1).split(',');
          if (_typeID == -1) {
            _typeID = int.parse(cols[2]);
            _regionID = int.parse(cols[11]);
            // We do not care about types that are not in restrictToTypeIDs
            if (!restrictToTypeIDs.contains(_typeID)) {
              break;
            }
            if (!regionsSeenForTypeID[_typeID]!.contains(_regionID)) {
              regionsSeenForTypeID[_typeID]!.add(_regionID);
            } else {
              // we have parsed a more recent log for this region & item pair
              break;
            }
          }

          // TODO handle parsing errors
          final price = double.parse(cols[0]);
          final volumeRemaining = double.parse(cols[1]).toInt();
          final isBuy = cols[7] == 'True';
          final systemID = int.parse(cols[12]);
          final order = Order(_typeID, systemID, _regionID, isBuy, price, volumeRemaining);
          _market[_typeID]!.add(order);
        } catch (e) {
          print('Exception in market log parsing');
          print('Log line:' + line);
        }
      }
    }

    _filterMarket();
  }

  Future<void> loadAdjustedPricesFromESI() async {
    adjustedPrices = await getAdjustedPricesESI(_market.keys.toList());
  }

  Future<void> loadPricesFromESI(List<int> ids) async {
    // TODO bradley delete this fucking bullshit
    if (ids.isEmpty) {
      ids = _market.keys.toList();
    }
    Map<int, List<Order>> orders = await getOrdersFromESI(ids);
    _market.clear();
    for (var key in orders.keys) {
      _market[key] = orders[key]!;
    }
    _filterMarket();
    _sortMarket();
  }

  void _sortMarket() {
    // Sorts sell orders ascending and buy orders descending
    // so the best orders are the first in the front of the array
    for (var id in _filteredMarket.keys) {
      _filteredMarket[id]!.buys.sort((a, b) => b.price.compareTo(a.price));
      _filteredMarket[id]!.sells.sort((a, b) => a.price.compareTo(b.price));
    }
  }

  void _filterMarket() {
    _filteredMarket = {};
    for (var id in _market.keys) {
      _filteredMarket[id] = BuysSells();
      _filteredMarket[id]!.buys = _market[id]!.where((order) => _buysFilter.filter(order) && order.isBuy).toList();
      _filteredMarket[id]!.sells = _market[id]!.where((order) => _sellsFilter.filter(order) && !order.isBuy).toList();
    }
    _sortMarket();
  }

  void setMarketFilter(OrderFilter filter, bool isBuy) {
    if (isBuy) {
      _buysFilter = filter;
    } else {
      _sellsFilter = filter;
    }
    _filterMarket();
  }

  // returns negative if quantity of id is not available on market
  double getAvgMinSellForQuantity(int id, int quantity) {
    var totalCost = 0.0;
    if (quantity == 0) {
      return 0.0;
    }
    int quantityRemaining = quantity;
    for (var order in _filteredMarket[id]!.sells) {
      if (quantityRemaining <= order.volumeRemaining) {
        totalCost += quantityRemaining * order.price;
        quantityRemaining = 0;
        break;
      }
      totalCost += order.volumeRemaining * order.price;
      quantityRemaining -= order.volumeRemaining;
    }
    if (quantityRemaining > 0) {
      return double.infinity;
    }
    return totalCost / quantity;
  }

  Map<int, double> getAvgMinSellForShoppingList(Map<int, int> shoppingList) {
    Map<int, double> avgPrices = {};
    for (var id in shoppingList.keys) {
      avgPrices[id] = getAvgMinSellForQuantity(id, shoppingList[id]!);
    }
    return avgPrices;
  }

  // returns negative if buy volume of id is not available on market
  double getAvgMaxBuyForQuantity(int id, int quantity) {
    var totalValue = 0.0;
    if (quantity == 0) {
      return 0.0;
    }
    int quantityRemaining = quantity;
    for (var order in _filteredMarket[id]!.buys) {
      if (quantityRemaining <= order.volumeRemaining) {
        totalValue += quantityRemaining * order.price;
        quantityRemaining = 0;
        break;
      }
      totalValue += order.volumeRemaining * order.price;
      quantityRemaining -= order.volumeRemaining;
    }
    if (quantityRemaining > 0) {
      return double.negativeInfinity;
    }
    return totalValue / quantity;
  }

  Map<int, double> getAvgMaxBuyForShoppingList(Map<int, int> shoppingList) {
    Map<int, double> avgPrices = {};
    for (var id in shoppingList.keys) {
      avgPrices[id] = getAvgMaxBuyForQuantity(id, shoppingList[id]!);
    }
    return avgPrices;
  }

  double getMaxBuy(int id) {
    if (_filteredMarket[id]!.buys.isEmpty) {
      return double.negativeInfinity;
    }
    return _filteredMarket[id]!.buys[0].price;
  }

  double getMinSell(int id) {
    if (_filteredMarket[id]!.sells.isEmpty) {
      return double.infinity;
    }
    return _filteredMarket[id]!.sells[0].price;
  }

  void setOrders(Map<int, List<Order>> orders) {
    for (int id in orders.keys) {
      _market[id] = orders[id]!;
    }
    _filterMarket();
  }

  List<int> getTypeIds() {
    return restrictToTypeIDs;
  }

  Map<int, List<Order>> getAsMap() {
    return _market;
  }

  OrderFilter getOrderFilter(bool buy) {
    if (buy) {
      return _buysFilter;
    } else {
      return _sellsFilter;
    }
  }
}
