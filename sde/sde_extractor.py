class SDE_Extractor:
    """This class extracts and filters information from the SDE."""

    def __init__(self, sde):
        self.sde = sde
        self.possibleActivities = {'manufacturing', 'reaction'}

    def _isPublished(self, tid):
        """Returns whether the type is published."""
        return self.sde.typeIDs[tid]['published'] == 1

    def _getName(self, tid):
        return self.sde.typeIDs[tid]['name']['en']

    def _getIfInMarketGroup(self, marketGroup, group):
        """Returns whether marketGroup is a subgroup of group."""
        if marketGroup == group:
            return True
        if 'parentGroupID' in self.sde.marketGroups[marketGroup]:
            parentGroup = self.sde.marketGroups[marketGroup]['parentGroupID']
        else:
            return False
        return parentGroup == group or self._getIfInMarketGroup(parentGroup, group)

    def _getAllMaterialsAndProducts(self, blueprints):
        ids = set()
        for bpID in blueprints:
            bp = blueprints[bpID]
            ids = ids.union(set(bp['materials']))
            ids.add(bp['productID'])
        return ids

    def getIndustryItems(self, blueprints):
        """
        Returns the relavent information of all items involved in production.
        id -> (name, marketGroupID, groupID, volume)
        """
        sde = self.sde
        ids: set = self._getAllMaterialsAndProducts(blueprints)
        items = {}
        for tid in self.sde.typeIDs:
            if not self._isPublished(tid):
                continue
            if tid not in ids:
                continue
            item = {}
            item['name'] = sde.typeIDs[tid]['name']
            if 'marketGroupID' in sde.typeIDs[tid]:
                item['marketGroupID'] = sde.typeIDs[tid]['marketGroupID']
            if 'groupID' in sde.typeIDs[tid]:
                item['groupID'] = sde.typeIDs[tid]['groupID']
            if tid in sde.hoboleaksRepackagedVolumes:
                item['volume'] = sde.hoboleaksRepackagedVolumes[tid]
            elif 'volume' in sde.typeIDs[tid]:
                item['volume'] = sde.typeIDs[tid]['volume']
            items[tid] = item
        return items

    def _filterBP(self, bid):
        isPublished = self._isPublished(bid)
        isProductPublished = True
        hasMaterials = True
        hasProductAsAnInput = False
        allMaterialsAreOnTheMarket = True
        productIsOnTheMarket = True
        hasActivities = 0 < len(set(self.possibleActivities).intersection(set(self.sde.blueprints[bid]['activities'])))

        for activity in self.possibleActivities:  # choose the activity
            if activity in self.sde.blueprints[bid]['activities']:
                assert (0 == len((self.possibleActivities - {activity}).intersection(self.sde.blueprints[bid]['activities'])))
                if 'products' not in self.sde.blueprints[bid]['activities'][activity]:
                    isProductPublished = False
                    break
                products = self.sde.blueprints[bid]['activities'][activity]['products']
                assert (len(products) == 1)
                productTID = products[0]['typeID']
                if productTID not in self.sde.typeIDs or not self._isPublished(productTID):
                    isProductPublished = False
                    break
                if 'marketGroupID' not in self.sde.typeIDs[productTID]:
                    productIsOnTheMarket = False
                    break
                if 'materials' not in self.sde.blueprints[bid]['activities'][activity]:
                    hasMaterials = False
                    break
                for material in self.sde.blueprints[bid]['activities'][activity]['materials']:
                    materialID = material['typeID']
                    if materialID == productTID:
                        hasProductAsAnInput = True
                        break
                    if 'marketGroupID' not in self.sde.typeIDs[materialID]:
                        allMaterialsAreOnTheMarket = False
                        break
                break
        return isPublished and hasActivities and isProductPublished and hasMaterials and not hasProductAsAnInput and allMaterialsAreOnTheMarket and productIsOnTheMarket

    def _getNodesInTree(self, root, neighbors):
        ret = {root}
        if root in neighbors:
            for neighbor in neighbors[root]:
                ret |= self._getNodesInTree(neighbor, neighbors)
        return ret

    def _getBlueprintSkills(self, skills, skill2parents, skillsOfInterest):
        """
        Find the intersection between all skills (that are in the skill forest where roots are skills in skills and edges are in skill2parents)
        and skills in skillsOfInterest.
        """
        ret = set()
        for skill in skills:
            ret |= self._getNodesInTree(skill, skill2parents)
        return ret.intersection(set(skillsOfInterest))

    def _getSkill2Parents(self):
        """Returns a map from skill id to skill parents for all skills with parents."""
        sde = self.sde
        skills = {}
        for tid in sde.typeIDs:
            if not self._isPublished(tid):
                continue
            if 'marketGroupID' not in sde.typeIDs[tid]:
                continue
            requiredSkillsAttributes = {182, 183, 184, 1285, 1289}
            parents = set()
            if tid in sde.typeDogma:
                for pair in sde.typeDogma[tid]['dogmaAttributes']:
                    attributeID = pair['attributeID']
                    if attributeID in requiredSkillsAttributes:
                        parents.add(int(pair['value']))
            if len(parents) > 0:
                skills[tid] = parents
        return skills

    def getItem2Blueprint(self, skillsOfInterest):
        """Returns the blueprint info for buildable items."""
        skill2parents = self._getSkill2Parents()
        item2bp = {}
        for bid in self.sde.blueprints:
            if not self._filterBP(bid):
                continue
            item2bp[bid] = {}
            bp = self.sde.blueprints[bid]
            for activity in bp['activities']:
                if activity in self.possibleActivities:
                    item2bp[bid]['activity'] = activity
                    item2bp[bid]['materials'] = {}
                    for pair in bp['activities'][activity]['materials']:
                        item2bp[bid]['materials'][pair['typeID']] = pair['quantity']
                    assert (1 == len(bp['activities'][activity]['products']))
                    productID = bp['activities'][activity]['products'][0]['typeID']
                    productQuantity = bp['activities'][activity]['products'][0]['quantity']
                    item2bp[bid]['productID'] = productID
                    item2bp[bid]['productQuantity'] = productQuantity
                    item2bp[bid]['time'] = bp['activities'][activity]['time']
                    if 'skills' in bp['activities'][activity]:
                        skills = {pair['typeID'] for pair in bp['activities'][activity]['skills']}
                        item2bp[bid]['skills'] = self._getBlueprintSkills(skills, skill2parents, skillsOfInterest)
                    break  # a bp can contain only one of the two possible activities
        return item2bp

    def getProductionSkills(self):
        """
        Returns all skills that have some bonus to some kind of production.
        id -> (activity, bonus, name)
        """
        sde = self.sde
        skills = {}
        for tid in sde.typeIDs:
            if not self._isPublished(tid):
                continue
            if 'marketGroupID' not in sde.typeIDs[tid]:
                continue
            inProduction = self._getIfInMarketGroup(sde.typeIDs[tid]['marketGroupID'], 369)
            inResourceProcessing = self._getIfInMarketGroup(sde.typeIDs[tid]['marketGroupID'], 1323)
            inScience = self._getIfInMarketGroup(sde.typeIDs[tid]['marketGroupID'], 375)
            if not (inProduction or inResourceProcessing or inScience):
                continue

            manufacturingModifiedAttrib = 219
            reactionsModifiedAttrib = 2662
            scienceManufacturingTimeAttrib = 1982

            activity = ''
            bonus = 0
            isScienceMfg = False
            isProductionMfg = False
            isResourceProcessingRtn = False
            attributes = {}
            for pair in sde.typeDogma[tid]['dogmaAttributes']:
                attributeID = pair['attributeID']
                attributeValue = pair['value']
                attributes[attributeID] = attributeValue
                if attributeID == scienceManufacturingTimeAttrib:
                    isScienceMfg = True
                    activity = 'manufacturing'
                    bonus = attributes[attributeID]

            for pair in sde.typeDogma[tid]['dogmaEffects']:
                effectID = pair['effectID']
                for interaction in sde.dogmaEffects[effectID]['modifierInfo']:
                    modifiedAttributeID = interaction['modifiedAttributeID']
                    if modifiedAttributeID == manufacturingModifiedAttrib:
                        isProductionMfg = True
                        activity = 'manufacturing'
                        modifyingAttributeID = interaction['modifyingAttributeID']
                        bonus = attributes[modifyingAttributeID]
                    elif modifiedAttributeID == reactionsModifiedAttrib:
                        isResourceProcessingRtn = True
                        activity = 'reaction'
                        modifyingAttributeID = interaction['modifyingAttributeID']
                        bonus = attributes[modifyingAttributeID]

            if not (isScienceMfg or isProductionMfg or isResourceProcessingRtn):
                continue

            skill = {'name': sde.typeIDs[tid]['name'], 'activity': activity, 'bonus': bonus}

            skills[tid] = skill
        return skills

    def getStructuresAndBonuses(self):
        """
        Returns all structures and structure bonuses.
        id -> (activity, bonuses (bonusType -> bonus), name)
        """
        sde = self.sde
        structures = {}
        for tid in sde.typeIDs:
            if not self._isPublished(tid):
                continue
            if 'marketGroupID' not in sde.typeIDs[tid]:
                continue
            engComplx = self._getIfInMarketGroup(sde.typeIDs[tid]['marketGroupID'], 2324)
            refinery = self._getIfInMarketGroup(sde.typeIDs[tid]['marketGroupID'], 2327)
            if not engComplx and not refinery:  # market group of structure mods
                continue

            structure = {}

            # athanor has no bonuses and so is not in hoboleaksModifierSources
            if tid not in sde.hoboleaksModifierSources:
                structure['activity'] = 'reaction'
                structure['name'] = sde.typeIDs[tid]['name']
                structures[tid] = structure
                continue

            structure['activity'] = 'manufacturing' if 'manufacturing' in sde.hoboleaksModifierSources[tid] else 'reaction'

            attributes = {}
            for pair in sde.typeDogma[tid]['dogmaAttributes']:
                attributeID = pair['attributeID']
                attributeValue = pair['value']
                attributes[attributeID] = attributeValue

            # get bonus domains
            modSource = sde.hoboleaksModifierSources[tid][structure['activity']]
            for bonusType in modSource:
                for bonusDict in modSource[bonusType]:
                    bonusAttrib = bonusDict['dogmaAttributeID']
                    bonus = attributes[bonusAttrib]
                    if abs(bonus) > 0.00001:
                        if 'bonuses' not in structure:
                            structure['bonuses'] = {}
                        structure['bonuses'][bonusType] = bonus

            structure['name'] = sde.typeIDs[tid]['name']
            structures[tid] = structure
        return structures

    def getIndustryRigsAndBonuses(self):
        """
        Returns all industry rigs with their bonuses and item domains.
        id -> (activity, bonuses (bonusType -> bonus), bonus domain, name)
        """
        sde = self.sde
        rigs = {}
        for tid in sde.typeIDs:
            if not self._isPublished(tid):
                continue
            if 'marketGroupID' not in sde.typeIDs[tid]:
                continue
            if not self._getIfInMarketGroup(sde.typeIDs[tid]['marketGroupID'], 2203):  # market group of structure mods
                continue
            if tid not in sde.hoboleaksModifierSources:
                continue
            if 'manufacturing' not in sde.hoboleaksModifierSources[tid] and 'reaction' not in sde.hoboleaksModifierSources[tid]:
                continue

            rig = {}
            rig['activity'] = 'manufacturing' if 'manufacturing' in sde.hoboleaksModifierSources[tid] else 'reaction'

            costBonusAttributes = {2595}
            materialBonusAttributes = {2594, 2653, 2714}
            timeBonusAttributes = {2593, 2713}
            securityMultiplierAttributes = {2356, 2357}
            securityEffectIDs = {6842, 6976}

            securityMultiplier = 0.0
            attributes = {}

            for pair in sde.typeDogma[tid]['dogmaAttributes']:
                attributeID = pair['attributeID']
                attributeValue = pair['value']
                attributes[attributeID] = attributeValue
                if attributeID in securityMultiplierAttributes:
                    securityMultiplier = max(securityMultiplier, attributeValue)

            # which bonus attribs does this rig have
            bonusAttribs = {}
            for pair in sde.typeDogma[tid]['dogmaAttributes']:
                attributeID = pair['attributeID']
                if attributeID in timeBonusAttributes:
                    bonusAttribs['time'] = attributeID
                elif attributeID in costBonusAttributes:
                    bonusAttribs['cost'] = attributeID
                elif attributeID in materialBonusAttributes:
                    bonusAttribs['material'] = attributeID

            # apply security effects
            for securityEffectID in securityEffectIDs:
                for effect in sde.typeDogma[tid]['dogmaEffects']:
                    if effect['effectID'] == securityEffectID:
                        for modification in sde.dogmaEffects[securityEffectID]['modifierInfo']:
                            modified = modification['modifiedAttributeID']
                            if modified in attributes:
                                attributes[modified] *= securityMultiplier
                        break  # there is only one security effect

            rig['bonuses'] = {}
            rig['domain'] = {'categoryIDs': set(), 'groupIDs': set()}

            # get bonus domains
            modSource = sde.hoboleaksModifierSources[tid][rig['activity']]
            for bonusType in modSource:
                for bonusDict in modSource[bonusType]:
                    bonus = attributes[bonusAttribs[bonusType]]
                    if abs(bonus) > 0.00001:
                        rig['bonuses'][bonusType] = bonus
                        attributeID = bonusDict['dogmaAttributeID']
                        filterID = bonusDict['filterID']
                        for cid in sde.hoboleaksTargetFilters[filterID]['categoryIDs']:
                            rig['domain']['categoryIDs'].add(cid)
                        for gid in sde.hoboleaksTargetFilters[filterID]['groupIDs']:
                            rig['domain']['groupIDs'].add(gid)

            rig['name'] = sde.typeIDs[tid]['name']
            rigs[tid] = rig
        return rigs

    def getImplants(self):
        """
        Returns all industry implants and their bonuses.
        id -> (name, activity, bonus)
        """
        sde = self.sde
        implants = {}
        for tid in sde.typeIDs:
            if not self._isPublished(tid):
                continue
            if 'marketGroupID' not in sde.typeIDs[tid]:
                continue
            if not self._getIfInMarketGroup(sde.typeIDs[tid]['marketGroupID'], 1504):  # market group of structure mods
                continue

            mfgBonusAttrib = 440
            bonus = 0
            for attrib in sde.typeDogma[tid]['dogmaAttributes']:
                attributeID = attrib['attributeID']
                if attributeID == mfgBonusAttrib:
                    bonus = attrib['value']
                    break
            implants[tid] = {'name': sde.typeIDs[tid]['name'], 'activity': 'manufacturing', 'bonus': bonus}
        return implants

    def _addSegmentsOfPathToEdgeMap(self, node, edges, getParent):
        """Adds all the edges on the path from node to the root to the edge map."""
        if 'parentGroupID' in self.sde.marketGroups[node]:
            parent = getParent(node)
        else:
            return
        if parent not in edges:
            edges[parent] = set()
        edges[parent].add(node)
        self._addSegmentsOfPathToEdgeMap(parent, edges, getParent)

    def getMarketGroupNames(self, marketGroupGraph):
        """
        Return the market group graph reduced to contain only groups that are relavent to production.
        id -> name
        """
        sde = self.sde

        marketGroupNames = {}
        for k, v in marketGroupGraph.items():
            marketGroupNames[k] = sde.marketGroups[k]['nameID']
            for kk in v:
                marketGroupNames[kk] = sde.marketGroups[kk]['nameID']
        return marketGroupNames

    def getMarketGroupGraph(self, blueprints):
        """
        Return the market group graph reduced to contain only groups that are relavent to production.
        id -> childrenGroupIDs
        """
        sde = self.sde

        marketGraph = {}
        products = {bp['productID'] for bp in blueprints.values()}
        for product in products:
            productMarketGroup = sde.typeIDs[product]['marketGroupID']
            self._addSegmentsOfPathToEdgeMap(productMarketGroup, marketGraph, lambda k: sde.marketGroups[k]['parentGroupID'])
        return marketGraph

    def getGroup2Category(self, blueprints):
        """
        Return the map of inventory group nodes to their parents.
        At the moment, I use this only for calculating which manufacturing/reaction rigs affect which items.
        id -> categoryID
        """
        sde = self.sde
        group2category = {}
        products = {bp['productID'] for bp in blueprints.values()}
        for product in products:
            groupID = sde.typeIDs[product]['groupID']
            group2category[groupID] = sde.groupIDs[groupID]['categoryID']
        return group2category

    def getTradeHubs(self):
        """
        Get region and system ids for major trade hubs.
        regions: id -> solarSystemIDs
        systems: id -> solarSystemName
        """
        sde = self.sde
        jitaID = sde.jitaData['solarSystemID']
        perimeterID = sde.perimeterData['solarSystemID']
        amarrID = sde.amarrData['solarSystemID']
        ashabID = sde.ashabData['solarSystemID']

        theForgeID = sde.theForgeData['regionID']
        domainID = sde.domainData['regionID']

        regions = {theForgeID: [jitaID, perimeterID], domainID: [amarrID, ashabID]}
        systems = {jitaID: 'Jita', perimeterID: 'Perimeter', amarrID: 'Amarr', ashabID: 'Ashab'}

        return regions, systems


def __test():
    from ccp_sde import CCP_SDE
    sde = CCP_SDE()
    extractor = SDE_Extractor(sde)

    print("\n\nStructures")
    structures = extractor.getStructuresAndBonuses()
    for k, v in structures.items():
        print(k, v)

    print("\n\nRigs")
    rigs = extractor.getIndustryRigsAndBonuses()
    for k, v in rigs.items():
        print(k, v)

    print("\n\nProductionSkills")
    productionSkills = extractor.getProductionSkills()
    for k, v in productionSkills.items():
        print(k, v)

    print("\n\nImplants")
    implants = extractor.getImplants()
    for k, v in implants.items():
        print(k, v)

    print("\n\nBlueprints")
    bps = extractor.getItem2Blueprint(productionSkills.keys())
    for k, v in bps.items():
        print(k, v)
    print('Number of blueprints accepted:', len(bps))

    print('\n\nIndustry Items')
    items = extractor.getIndustryItems(bps)
    for k, v in items.items():
        print(k, v)
    print('Number of items:', len(extractor.getIndustryItems(bps)))

    print('\n\nMarketGroups')
    marketGroupGraph = extractor.getMarketGroupGraph(bps)
    marketGroupNames = extractor.getMarketGroupNames(marketGroupGraph)
    for k in sorted(marketGroupGraph, key=lambda x: marketGroupNames[x]['en']):
        marketGroupName = marketGroupNames[k]['en']
        print(marketGroupName + ' ' * (43 - len(marketGroupName)), end=': ')
        for kk in marketGroupGraph[k]:
            marketGroupName = marketGroupNames[kk]['en']
            print(marketGroupName, end=', ')
        print()
    print('Number of market groups:', len(marketGroupNames))

    print('\n\nGroup2Category')
    group2category = extractor.getGroup2Category(bps)
    print(group2category)

    print('\n\nTrade hubs')
    regions, systems = extractor.getTradeHubs()
    print(regions, systems)


if __name__ == "__main__":
    __test()
