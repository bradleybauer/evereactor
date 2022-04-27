import '../sde.dart';
import 'market_order.dart';

class OrderFilter {
  static Set<int> possibleSystems = SDE.system2name.keys.toSet();

  Set<int> systems = {};

  OrderFilter(Iterable<int> _systems) {
    var allowedSystems = <int>{};
    for (int system in _systems) {
      if (possibleSystems.contains(system)) {
        allowedSystems.add(system);
      }
    }
    systems = allowedSystems;
  }

  OrderFilter.acceptAll() : systems = possibleSystems;

  static bool allSystems(int system) {
    return possibleSystems.contains(system);
  }

  bool filter(Order order) {
    if (systems.isEmpty) {
      return possibleSystems.contains(order.systemID);
    }
    return systems.contains(order.systemID);
  }
}
