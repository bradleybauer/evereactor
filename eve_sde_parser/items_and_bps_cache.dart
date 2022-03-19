import 'eve_sde.dart';
import '../lib/model/blueprint.dart';
import '../lib/model/item.dart';

class ItemsAndBPsCache {
  final EveSDE _sde;

  bool _isInitialized = false;

  final List<int> _ids;

  final Map<int, Item> _id2item = {};
  final Map<int, Blueprint> _id2blueprint = {};
  final Map<String, int> _name2id = {};

  // final List<int> fuelBlockIds = []; // TODO

  ItemsAndBPsCache(this._ids, this._sde);

  // bool isBuildable(int id) {
  //   return false;
  // }
  // bool isFuelBlock(int id) {
  //   return false;
  // }

  void _initialize() {
    for (var id in _ids) {
      _cacheItemAndBP(id);
    }
  }

  Map<int, Item> getItems() {
    if (!_isInitialized) {
      _initialize();
      _isInitialized = true;
    }
    return _id2item;
  }

  Map<int, Blueprint> getBlueprints() {
    if (!_isInitialized) {
      _initialize();
      _isInitialized = true;
    }
    return _id2blueprint;
  }

  static int _getBlueprintTypeID(int typeID, EveSDE sde) {
    final int TEST_REACTION_BP_TYPE_ID = sde.constants.TEST_REACTION_BP_TYPE_ID;
    final query = sde.bpProduct.select(['typeID'], 'productTypeID=$typeID and typeID<>$TEST_REACTION_BP_TYPE_ID');
    return query.last['typeID'];
  }

  static bpfrom(int productTypeID, EveSDE sde) {
    final blueprintID = _getBlueprintTypeID(productTypeID, sde);
    final time = sde.bpTime.select(['time'], 'typeID=$blueprintID').last;
    final type = sde.types.select(['typeName', 'iconID'], 'typeID=$blueprintID').last;
    final mats = sde.bpMaterials.select(['materialTypeID', 'quantity'], 'typeID=$blueprintID');
    final quantity = sde.bpProduct.select(['quantity'], 'typeID=$blueprintID').last;
    final inputTypeIDs = mats.map((e) => e['materialTypeID'] as int).toList();
    final inputQuantities = mats.map((e) => e['quantity'] as int).toList();
    return Blueprint(
        blueprintID, type['typeName'], productTypeID, type['iconID'], quantity['quantity'], inputTypeIDs, inputQuantities, time['time']);
  }

  static itemfrom(int typeID, EveSDE _sde) {
    final query = _sde.types.select(['*'], 'typeID=$typeID').last;
    return Item(query['typeID'], query['typeName'], query['volume'], query['iconID']);
  }

  void _cacheItemAndBP(int typeID) {
    if (_id2item.containsKey(typeID) || _id2blueprint.containsKey(typeID)) {
      return;
    }
    _id2item[typeID] = itemfrom(typeID, _sde);
    _name2id[getName(typeID)] = typeID;
    if (!_sde.isBuildable(typeID) || _sde.isFuelBlock(typeID)) {
      return;
    }
    final productTypeID = typeID;
    final blueprint = bpfrom(productTypeID, _sde);
    _name2id[getName(blueprint.typeID)] = blueprint.typeID;
    _id2blueprint[productTypeID] = blueprint;
    for (var inputTypeID in blueprint.inputTypeIDs) {
      _cacheItemAndBP(inputTypeID);
    }
  }

  String getName(int typeID) {
    if (_id2item.containsKey(typeID)) {
      return _id2item[typeID]!.typeName;
    } else if (_id2blueprint.containsKey(typeID)) {
      return _id2blueprint[typeID]!.typeName;
    }
    return "";
  }

  int getID(String name) {
    if (_name2id.containsKey(name)) {
      return _name2id[name]!;
    }
    return -1;
  }
}
