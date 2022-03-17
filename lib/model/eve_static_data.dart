import 'eve_static_data_raw.dart';

import 'item.dart';
import 'blueprint.dart';

class EveStaticData {
  static const List<int> advancedMoonGooIds = advancedMoonGooIds_;
  static const List<int> fuelBlockIds = fuelBlockIds_;

  static const Map<int, Item> items = items_;
  static const Map<int, Blueprint> blueprints = blueprints_;
  static const Map<String, int> name2id = name2id_;

  static bool isBuildable(int id) {
    return blueprints.containsKey(id);
  }

  static bool isFuelBlock(int id) {
    return fuelBlockIds.contains(id);
  }

  static String getName(int typeID) {
    if (items.containsKey(typeID)) {
      return items[typeID]!.typeName;
    } else if (blueprints.containsKey(typeID)) {
      return blueprints[typeID]!.typeName;
    }
    return "";
  }

  static int getID(String name) {
    if (name2id.containsKey(name)) {
      return name2id[name]!;
    }
    return -1;
  }

  // is a ancestor of b
  // ie is b in a's build tree
  static bool isAncestor(int a, int b) {
    if (isBuildable(a) && !isFuelBlock(a)) {
      for (int childId in blueprints[a]!.inputTypeIDs) {
        if (childId == b) {
          return true;
        }
        if (isBuildable(childId) && !isFuelBlock(childId)) {
          for (int grandChildId in blueprints[childId]!.inputTypeIDs) {
            if (grandChildId == b) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  // is a descendant of b
  // ie is a in b's build tree
  static bool isDescendant(int a, int b) {
    return isAncestor(b, a);
  }
}
