// import 'constants.dart';
import 'market_order.dart';

class OrderFilter {
  static Map<int, String> possibleSystems = {
    // Constants.JITA_SYSTEM_ID: 'Jita',
    // Constants.PERIMETER_SYSTEM_ID: 'Perimeter',
    // Constants.AMARR_SYSTEM_ID: 'Amarr',
    // Constants.ASHAB_SYSTEM_ID: 'Ashab',
    // Constants.DODIXIE_SYSTEM_ID: 'Dodixie',
    // Constants.BOTANE_SYSTEM_ID: 'Botane',
    // Constants.RENS_SYSTEM_ID: 'Rens',
    // Constants.HEK_SYSTEM_ID: 'Hek',
  };

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
