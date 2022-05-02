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
  DateTime? _orderFetchTime;
  OrderFilter _orderFilter = OrderFilter.acceptAll();

  OrderFilter getOrderFilter() => _orderFilter;

  double? getAdjustedPrice(int tid) => _adjustedPrices[tid];

  void setAdjustedPrices(Map<int, double> prices) => _adjustedPrices = prices;

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

  void setMarketFilter(OrderFilter filter) {
    _orderFilter = filter;
    _filterMarket();
  }

  void setOrderFetchTime(DateTime dateTime) => _orderFetchTime = dateTime;

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

  Map<int,double> getAdjustedPrices() => {..._adjustedPrices};

// double maxBuy(int id) {
//   if (_filteredMarket[id]!.buys.isEmpty) {
//     return double.negativeInfinity;
//   }
//   return _filteredMarket[id]!.buys[0].price;
// }
//
// double minSell(int id) {
//   if (_filteredMarket[id]!.sells.isEmpty) {
//     return double.infinity;
//   }
//   return _filteredMarket[id]!.sells[0].price;
// }
}
