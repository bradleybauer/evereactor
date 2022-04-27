import '../sde.dart';
import 'market_order.dart';

class OrderFilter {
  static Set<int> possibleSystems = SDE.system2name.keys.toSet();

  Set<int> _systems = {};

  OrderFilter(Iterable<int> systems) {
    var allowedSystems = <int>{};
    for (int system in systems) {
      allowedSystems.add(system);
    }
    _systems = allowedSystems;
  }

  OrderFilter.acceptAll() : _systems = possibleSystems;

  bool filter(Order order) {
    if (_systems.isEmpty) {
      return possibleSystems.contains(order.systemID);
    }
    return _systems.contains(order.systemID);
  }

  static bool allSystems(int system) {
    return possibleSystems.contains(system);
  }

  OrderFilter copyWith(int systemID) => OrderFilter({..._systems}.union({systemID}));

  OrderFilter copyWithout(int systemID) => OrderFilter({..._systems}..remove(systemID));

  Set<int> getSystems() => {..._systems};
}
