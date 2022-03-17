import 'eve_static_data.dart';

class Inventory {
  final Map<int, int> _quantities;

  Inventory(String itemString) : _quantities = {} {
    try {
      for (var line in itemString.split("\n")) {
        var words = line.trim().split('\t');
        var quantity = int.parse(words.last);
        var itemName = words.sublist(0, words.length - 1).join(' ');
        var id = EveStaticData.getID(itemName);
        if (!EveStaticData.items.containsKey(id)) {
          continue;
        }
        if (!_quantities.containsKey(id)) {
          _quantities[id] = 0;
        }
        _quantities[id] = _quantities[id]! + quantity;
      }
    } catch (e) {
      print('Error parsing inventory string.');
    }
  }

  Inventory.empty() : _quantities = {};

  Inventory.cloneOf(Inventory other) : _quantities = other.getQuantities();

  Inventory.fromMap(this._quantities);

  // subtracts quantity from _quantities[id] if id is a key in _quantities
  // returns the amount of quantity not supplied by the inventory
  int useQuantity(int id, int quantity) {
    if (_quantities.containsKey(id)) {
      if (_quantities[id]! >= quantity) {
        _quantities[id] = _quantities[id]! - quantity;
        return 0;
      } else {
        int quantityNotSupplied = quantity - _quantities[id]!;
        _quantities[id] = 0;
        return quantityNotSupplied;
      }
    }
    return quantity;
  }

  int getQuantity(int id, int quantity) {
    if (_quantities.containsKey(id)) {
      return _quantities[id]!;
    }
    return 0;
  }

  Map<int, int> getQuantities() {
    return Map.from(_quantities);
  }
}
