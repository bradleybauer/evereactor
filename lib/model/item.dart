class Item {
  final Map<String, String> nameLocalizations;
  final int marketGroupID;
  final int groupID;
  final double volume;

  const Item(this.nameLocalizations, this.marketGroupID, this.groupID, this.volume);

  //@override
  //String toString() {
  //  return {'typeID': typeID, 'typeName': typeName, 'volume': volume, 'iconID': iconID}.toString();
  //}
}
