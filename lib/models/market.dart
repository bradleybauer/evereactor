import '../sde.dart';
import 'market_order.dart';
import 'order_filter.dart';

class _BuysSells {
  List<Order> buys = [];
  List<Order> sells = [];
}

class Market {
  // A map from typeIDs to orders
  // For a typeID given, the List<Order> may be empty but it is never null.
  Map<int, List<Order>> _orders = {};
  Map<int, _BuysSells> _filteredMarket = {};
  Map<int, double> _adjustedPrices = {};
  OrderFilter _orderFilter = OrderFilter.acceptAll();

  double? getAdjustedPrice(int tid) => _adjustedPrices[tid];

  void setAdjustedPrices(Map<int, double> prices) => _adjustedPrices = prices;

  OrderFilter getOrderFilter() => _orderFilter;

  void setOrderFilter(OrderFilter filter) {
    if (filter.getSystems().isEmpty) {
      filter = OrderFilter.acceptAll();
    }
    _orderFilter = filter;
    _filterMarket();
  }

  void setOrders(Map<int, List<Order>> orders) {
    _orders = orders;
    _filterMarket();
  }

  void _filterMarket() {
    _filteredMarket = {};
    for (var id in _orders.keys) {
      _filteredMarket[id] = _BuysSells();
      _filteredMarket[id]!.buys = _orders[id]!.where((order) => _orderFilter.filter(order) && order.isBuy).toList();
      _filteredMarket[id]!.sells = _orders[id]!.where((order) => _orderFilter.filter(order) && !order.isBuy).toList();
    }
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

  // returns infinity if quantity of id is not available on market
  double avgBuyFromSellItem(int id, int quantity) {
    if (quantity == 0) {
      return 0.0;
    }
    if (!_filteredMarket.containsKey(id)) {
      return double.infinity;
    }
    var totalCost = 0.0;
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

  Map<int, double> avgBuyFromSell(Map<int, int> shoppingList) {
    Map<int, double> avgPrices = {};
    for (var id in shoppingList.keys) {
      avgPrices[id] = avgBuyFromSellItem(id, shoppingList[id]!);
    }
    return avgPrices;
  }

  // returns negative if buy volume of id is not available on market
  double avgSellToBuyItem(int id, int quantity) {
    if (quantity == 0) {
      return 0.0;
    }
    if (!_filteredMarket.containsKey(id)) {
      return double.negativeInfinity;
    }
    var totalValue = 0.0;
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

  Map<int, double> avgSellToBuy(Map<int, int> shoppingList) {
    Map<int, double> avgPrices = {};
    for (var id in shoppingList.keys) {
      avgPrices[id] = avgSellToBuyItem(id, shoppingList[id]!);
    }
    return avgPrices;
  }

  Map<int, double> getAdjustedPrices() => {..._adjustedPrices};

  int buyVolume25Percent(int tid) {
    int units = 0;
    if (_filteredMarket.containsKey(tid)) {
      for (var order in _filteredMarket[tid]!.buys) {
        units += order.volumeRemaining;
      }
    }
    return units ~/ 4;
  }

  Map<int, Map<int, int>> splitBuyFromSellPerRegion(Map<int, int> bom) {
    final region2bom = <int, Map<int, int>>{};

    // which regions do we care about
    for (final system in getOrderFilter().getSystems()) {
      SDE.region2systems.forEach((region, systems) {
        if (systems.contains(system) && !region2bom.containsKey(region)) {
          region2bom[region] = {};
        }
      });
    }

    bom.forEach((tid, qty) {
      if (qty != 0 && _filteredMarket.containsKey(tid)) {
        int quantityRemaining = qty;
        for (var order in _filteredMarket[tid]!.sells) {
          int quantityUsed = 0;
          if (quantityRemaining <= order.volumeRemaining) {
            quantityUsed = quantityRemaining;
          } else {
            quantityUsed = order.volumeRemaining;
          }

          if (quantityUsed > 0 && quantityRemaining > 0) {
            region2bom[order.regionID]!.update(tid, (value) => value + quantityUsed, ifAbsent: () => quantityUsed);
          }

          quantityRemaining -= quantityUsed;
        }
      }
    });

    return region2bom;
  }

  Map<int, Map<int, int>> splitSellToBuyPerRegion(Map<int, int> bom) {
    final region2bom = <int, Map<int, int>>{};

    // which regions do we care about
    for (final system in getOrderFilter().getSystems()) {
      SDE.region2systems.forEach((region, systems) {
        if (systems.contains(system) && !region2bom.containsKey(region)) {
          region2bom[region] = {};
        }
      });
    }

    bom.forEach((tid, qty) {
      if (qty != 0 && _filteredMarket.containsKey(tid)) {
        int quantityRemaining = qty;
        for (var order in _filteredMarket[tid]!.buys) {
          int quantityUsed = 0;
          if (quantityRemaining <= order.volumeRemaining) {
            quantityUsed = quantityRemaining;
          } else {
            quantityUsed = order.volumeRemaining;
          }

          if (quantityUsed > 0 && quantityRemaining > 0) {
            region2bom[order.regionID]!.update(tid, (value) => value + quantityUsed, ifAbsent: () => quantityUsed);
          }

          quantityRemaining -= quantityUsed;
        }
      }
    });

    return region2bom;
  }
}
