// import 'constants.dart';
import 'market_order.dart';

class OrderFilter {
  static Map<int, String> possibleSystems = {};

  List<int> systems = [];

  OrderFilter(List<int> _systems) {
    List<int> allowedSystems = [];
    for (int system in _systems) {
      if (possibleSystems.containsKey(system)) {
        allowedSystems.add(system);
      }
    }
    systems = allowedSystems;
  }

  OrderFilter.acceptAll() : systems = possibleSystems.keys.toList();

  bool filter(Order order) {
    if (systems.isEmpty) return possibleSystems.keys.contains(order.systemID);
    return systems.contains(order.systemID);
  }
}