import 'package:flutter/material.dart';

import '../models/inventory.dart';

class InventoryController with ChangeNotifier {
  final _inventory = Inventory.empty();

  Inventory getInventoryCopy() => Inventory.cloneOf(_inventory);
}
