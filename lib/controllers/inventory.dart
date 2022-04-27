import 'package:EveIndy/models/inventory.dart';
import 'package:flutter/material.dart';

class InventoryController with ChangeNotifier {
  final _inventory = Inventory.empty();

  Inventory getInventoryCopy() => Inventory.cloneOf(_inventory);
}