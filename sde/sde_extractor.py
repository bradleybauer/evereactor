class SDE_Extractor:
    """This class extracts and filters information from the SDE."""

    def __init__(self):
        pass

    def _isPublished(self, tid):
        """Returns whether the type is published."""
        return self.typeIDs[tid]['published'] == 1

    def _getIfInMarketGroup(self, marketGroup, group):
        """Returns whether marketGroup is a subgroup of group."""
        if marketGroup == group:
            return True
        if 'parentGroupID' in self.marketGroups[marketGroup]:
            parentGroup = self.marketGroups[marketGroup]['parentGroupID']
        else:
            return False
        return parentGroup == group or self.getIfInMarketGroup(parentGroup, group)

    def getItems():
        """Returns the typeIDs of all published."""
        pass

    def getBuildableItems():
        """Returns the typeIDs of all buildable items."""
        pass

    def getBlueprints():
        """Returns the blueprints of all items returned by getBuildableItems()."""
        pass

    def getProductionSkills():
        """Returns all skills that have some bonus to some kind of production."""
        pass

    def getStructuresAndBonuses():
        """Returns all structures and structure bonuses."""
        pass

    def getIndustryRigsAndBonuses():
        """Returns all industry rigs and their bonuses."""
        pass

    def getImplants():
        """Returns all industry implants and their bonuses."""
        pass
