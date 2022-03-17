class Blueprint {
  final int typeID;
  final String typeName;
  final int productTypeID;
  final int iconID;
  final int numProducedPerRun;
  final List<int> inputTypeIDs;
  final List<int> inputQuantities;
  final int baseTimePerRunSeconds;

  const Blueprint(
    this.typeID,
    this.typeName,
    this.productTypeID,
    this.iconID,
    this.numProducedPerRun,
    this.inputTypeIDs,
    this.inputQuantities,
    this.baseTimePerRunSeconds,
  );

  int getBaseNumChildNeeded(int childID) {
    for (int i = 0; i < inputTypeIDs.length; i++) {
      if (childID == inputTypeIDs[i]) {
        return inputQuantities[i];
      }
    }
    return 0;
  }

  @override
  String toString() {
    return {
      'typeID': typeID,
      'typeName': typeName,
      'productTypeID': productTypeID,
      'iconID': iconID,
      'quantity': numProducedPerRun,
      'inputTypeIDs': inputTypeIDs,
      'inputQuantities': inputQuantities,
      'baseTimePerRunSeconds': baseTimePerRunSeconds
    }.toString();
  }
}
