class Item {
  final int typeID;
  final String typeName;
  final double volume;
  final int iconID;

  const Item(this.typeID, this.typeName, this.volume, this.iconID);

  @override
  String toString() {
    return {'typeID': typeID, 'typeName': typeName, 'volume': volume, 'iconID': iconID}.toString();
  }
}
