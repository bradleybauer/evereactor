from ccp_sde import CCP_SDE
from my_requests import ParallelRequest
import json

# TODO handle ESI api call failures


class SDE_Extractor:
    """This class extracts and filters information from the SDE."""

    def __init__(self, sde: CCP_SDE):
        self.sde = sde
        self.possibleActivities = {'manufacturing', 'reaction'}

    def _isPublished(self, tid):
        """Returns whether the type is published."""
        return self.sde.typeIDs[tid]['published'] == 1

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
            ids.add(bpID)
        return ids

    # def _getAllMaterials(self, blueprints):
    #     ids = set()
    #     for bpID in blueprints:
    #         bp = blueprints[bpID]
    #         ids = ids.union(set(bp['materials']))
    #     return ids

    def getIndustryItems(self, blueprints):
        """
        Returns the relevant information of all items involved in production.
        typeID -> (name, marketGroupID, groupID, volume)
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
        requiresSkills = True
        hasActivities = 0 < len(set(self.possibleActivities).intersection(set(self.sde.blueprints[bid]['activities'])))
        notInterestingItem = False

        bp = self.sde.blueprints[bid]

        for activity in self.possibleActivities:
            if activity in bp['activities']:
                # The loop and if statement choose the activity (there is only one activity per bp in the SDE)
                assert (0 == len((self.possibleActivities - {activity}).intersection(bp['activities'])))
                if 'products' not in bp['activities'][activity]:
                    isProductPublished = False
                    break
                products = bp['activities'][activity]['products']
                assert (len(products) == 1)
                productTID = products[0]['typeID']
                if productTID not in self.sde.typeIDs or not self._isPublished(productTID):
                    isProductPublished = False
                    break
                if 'marketGroupID' not in self.sde.typeIDs[productTID]:
                    productIsOnTheMarket = False
                    break
                if 'materials' not in bp['activities'][activity]:
                    hasMaterials = False
                    break
                for material in bp['activities'][activity]['materials']:
                    materialID = material['typeID']
                    if materialID == productTID:
                        hasProductAsAnInput = True
                        break
                    if 'marketGroupID' not in self.sde.typeIDs[materialID]:
                        allMaterialsAreOnTheMarket = False
                        break
                if 'skills' not in bp['activities'][activity]: # allowing items with skills does more harm than it does good
                    requiresSkills = False
                    # print(self.sde.typeIDs[productTID]['name']['en'])
                    break
                if 'Expired' in self.sde.typeIDs[productTID]['name']['en']:
                    notInterestingItem = True
                    break
                if 'Civilian' in self.sde.typeIDs[productTID]['name']['en']:
                    notInterestingItem = True
                    break
                if 'Unrefined' in self.sde.typeIDs[productTID]['name']['en']:
                    notInterestingItem = True
                    break
                if 'Palatine Keepstar' in self.sde.typeIDs[productTID]['name']['en']:
                    notInterestingItem = True
                    break
                if 'R.A.M.' in self.sde.typeIDs[productTID]['name']['en']:
                    notInterestingItem = True
                    break
                break
        return isPublished and hasActivities and isProductPublished and hasMaterials and not hasProductAsAnInput and allMaterialsAreOnTheMarket and productIsOnTheMarket and requiresSkills and not notInterestingItem

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

    def getBlueprints(self, skillsOfInterest):
        """
        Returns the blueprint info for buildable items.
        product type id -> blueprint info
        """
        skill2parents = self._getSkill2Parents()
        blueprints = {}
        for bid in self.sde.blueprints:
            if not self._filterBP(bid):
                continue
            bp = {}
            sdeBP = self.sde.blueprints[bid]
            for activity in sdeBP['activities']:
                if activity in self.possibleActivities:
                    bp['activity'] = activity
                    bp['materials'] = {}
                    for pair in sdeBP['activities'][activity]['materials']:
                        bp['materials'][pair['typeID']] = pair['quantity']
                    assert (1 == len(sdeBP['activities'][activity]['products']))
                    bp['productQuantity'] = sdeBP['activities'][activity]['products'][0]['quantity']
                    bp['time'] = sdeBP['activities'][activity]['time']
                    # bps without skills have been filtered out already since items not needing skills to build are probably
                    # not the type of items I care to use my app with.
                    assert('skills' in sdeBP['activities'][activity])
                    skills = {pair['typeID'] for pair in sdeBP['activities'][activity]['skills']}

                    # (i.e. 'muninn' includes adv small ship constr when it shouldn't)
                    # bp['skills'] = self._getBlueprintSkills(skills, skill2parents, skillsOfInterest) # this includes incorrect skills for certain bps

                    # so just use the top level skills with global skills (adv indy/indy) added below
                    bp['skills'] = skills.intersection(set(skillsOfInterest))

                    break  # a bp can contain only one of the two possible activities
            productID = sdeBP['activities'][activity]['products'][0]['typeID']
            # if activity == 'manufacturing' and 3380 not in bp['skills']:
            #     print(self.sde.typeIDs[bid]['name']['en'],bp['skills'],bp)
            if activity == 'manufacturing':
                bp['skills'].add(3380) # all industry items are affected by adv indy and indy
                bp['skills'].add(3388) # but adv indy and indy not always in the req skills list

            # add meta level to bp
            if 'sofFactionName' in self.sde.typeIDs[productID] and self.sde.typeIDs[productID]['sofFactionName'] == 'upwell-defence':
                bp['techLevel'] = -1
            elif 'sofFactionName' in self.sde.typeIDs[productID] and self.sde.typeIDs[productID]['sofFactionName'] == 'concordcivilian':
                bp['techLevel'] = -1
            elif 'sofFactionName' in self.sde.typeIDs[productID] and ('tournament' in self.sde.typeIDs[productID]['sofFactionName']):
                bp['techLevel'] = -1
            elif 'metaGroupID' in self.sde.typeIDs[productID]:
                bp['techLevel'] = self.sde.typeIDs[productID]['metaGroupID']
            elif 'raceID' in self.sde.typeIDs[productID] and self.sde.typeIDs[productID]['raceID']==135: # 't1' trig ships, not availabe as bpos
                bp['techLevel'] = -1
            blueprints[productID] = bp
        return blueprints

    def getProductionSkills(self):
        """
        Returns all skills that have some bonus to some kind of production.
        typeID -> (activity, bonus, name)
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

            skill = {'marketGroupID': sde.typeIDs[tid]['marketGroupID'], 'name': sde.typeIDs[tid]['name'], 'activity': activity, 'bonus': bonus}

            skills[tid] = skill
        return skills

    def getStructuresAndBonuses(self):
        """
        Returns all structures and structure bonuses.
        typeID -> (activity, bonuses (bonusType -> bonus), name)
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
        typeID -> (activity, bonuses (bonusType -> bonus), bonus domain, name)
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
        typeID -> (name, activity, bonus)
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

    def getMarketGroupNames(self, items, skills):
        """
        Return the names of the groups in the market group graph and of the groups of the skills in the set of skills.
        marketGroupID -> name
        """
        sde = self.sde

        marketGroupGraph = self.getMarketGroupGraph(items)
        marketGroupNames = {}
        for k, v in marketGroupGraph.items():
            marketGroupNames[k] = sde.marketGroups[k]['nameID']
            for kk in v:
                marketGroupNames[kk] = sde.marketGroups[kk]['nameID']

        for skill in skills.values():
            k = skill['marketGroupID']
            marketGroupNames[k] = sde.marketGroups[k]['nameID']

        return marketGroupNames

    def getMarketGroupGraph(self, blueprints):
        """
        Return the market group graph reduced to contain only groups that are relavent to production.
        marketGroupID -> childrenGroupIDs
        """
        sde = self.sde

        marketGraph = {}
        for product in blueprints.keys():
            productMarketGroup = sde.typeIDs[product]['marketGroupID']
            self._addSegmentsOfPathToEdgeMap(productMarketGroup, marketGraph, lambda k: sde.marketGroups[k]['parentGroupID'])
        return marketGraph

    def getMarketGroup2Parent(self, blueprints):
        """
        Return a map from market group to market group's parent, if it has a parent.
        marketGroupID -> parentMarketGroupID
        """
        sde = self.sde

        marketGroup2Parent = {}
        for product in blueprints.keys():
            productMarketGroup = sde.typeIDs[product]['marketGroupID']
            marketGroupID = productMarketGroup
            while 'parentGroupID' in sde.marketGroups[marketGroupID]:
                marketGroup2Parent[marketGroupID] = sde.marketGroups[marketGroupID]['parentGroupID']
                marketGroupID = sde.marketGroups[marketGroupID]['parentGroupID']
        return marketGroup2Parent

    def getGroup2Category(self, blueprints):
        """
        Return the map of inventory group nodes to their parents.
        At the moment, I use this only for calculating which manufacturing/reaction rigs affect which items.
        groupID -> categoryID
        """
        sde = self.sde
        group2category = {}
        for product in blueprints.keys():
            groupID = sde.typeIDs[product]['groupID']
            group2category[groupID] = sde.groupIDs[groupID]['categoryID']
        return group2category

    # def getInventoryGroupNames(self, group2category):
    #     pass

    def getTradeHubs(self):
        """
        Get region and system ids for major trade hubs.
        regions: regionID -> solarSystemIDs
        systems: systemID -> solarSystemName
        """
        sde = self.sde
        jitaID = sde.jitaData['solarSystemID']
        perimeterID = sde.perimeterData['solarSystemID']
        amarrID = sde.amarrData['solarSystemID']
        ashabID = sde.ashabData['solarSystemID']

        theForgeID = sde.theForgeData['regionID']
        domainID = sde.domainData['regionID']

        region2systems = {theForgeID: [jitaID, perimeterID], domainID: [amarrID, ashabID]}
        system2name = {}

        # get localizations for system names
        def getUrl(i, l):
            return "https://esi.evetech.net/latest/universe/systems/{}/?datasource=tranquility&language={}".format(i, l)

        languages = {'en', 'en-us', 'de', 'fr', 'ru', 'ja', 'zh', 'ko', 'es'}
        urls = []
        for language in languages:
            for system in [jitaID, perimeterID, amarrID, ashabID]:
                urls.append(getUrl(system, language))
        req = ParallelRequest(urls)
        for result in req.go():
            language = result.headers['content-language']
            dic = json.loads(result.content)
            name = dic['name']
            systemID = dic['system_id']
            if systemID not in system2name:
                system2name[systemID] = {}
            system2name[systemID][language] = name

        return region2systems, system2name

    def getBuildableItemIDs(self, blueprints):
        return list(blueprints.keys())

    # def getMat2Id(self, items, blueprints):
    #     mat2id = {}
    #     allMaterialsIDs = self._getAllMaterials(blueprints).intersection(set(blueprints))
    #     for mid in allMaterialsIDs:
    #         itemName= items[mid]['name']
    #         for lang in itemName:
    #             mat2id[itemName[lang]] = mid
    #     return mat2id:

    def getItem2marketGroupAncestors(self, items, blueprints):
        marketGroup2Parent = self.getMarketGroup2Parent(items)
        item2marketGroupAncestors = {}
        for tid in items:
            groups = []
            marketGroupID = items[tid]['marketGroupID']
            while marketGroupID in marketGroup2Parent:
                groups.append(marketGroupID)
                marketGroupID = marketGroup2Parent[marketGroupID]
            groups.append(marketGroupID)
            item2marketGroupAncestors[tid] = groups[::-1]
        return item2marketGroupAncestors

def __test():
    extractor = SDE_Extractor(CCP_SDE())

    # print("\n\nStructures")
    structures = extractor.getStructuresAndBonuses()
    # for k, v in structures.items():
    #     print(k, v)

    # print("\n\nRigs")
    rigs = extractor.getIndustryRigsAndBonuses()
    # for k, v in rigs.items():
    #     print(k, v)

    # print("\n\nProductionSkills")
    productionSkills = extractor.getProductionSkills()
    # for k, v in productionSkills.items():
    #     print(k, v)

    # print("\n\nImplants")
    implants = extractor.getImplants()
    # for k, v in implants.items():
    #     print(k, v)

    # print("\n\nBlueprints")
    blueprints = extractor.getBlueprints(productionSkills.keys())
    # for k, v in blueprints.items():
    #     print(k, v)
    # print('Number of blueprints accepted:', len(blueprints))

    # print('\n\nIndustry Items')
    items = extractor.getIndustryItems(blueprints)
    # for k, v in items.items():
    #     print(k, v)
    # print('Number of items:', len(extractor.getIndustryItems(blueprints)))

    # print('\n\nMarketGroups')
    marketGroupGraph = extractor.getMarketGroupGraph(blueprints)
    marketGroupNames = extractor.getMarketGroupNames(marketGroupGraph, productionSkills)
    # for k in sorted(marketGroupGraph, key=lambda x: marketGroupNames[x]['en']):
    #     marketGroupName = marketGroupNames[k]['en']
    #     print(marketGroupName + ' ' * (43 - len(marketGroupName)), end=': ')
    #     for kk in marketGroupGraph[k]:
    #         marketGroupName = marketGroupNames[kk]['en']
    #         print(marketGroupName, end=', ')
    #     print()
    # print('Number of market groups:', len(marketGroupNames))

    #print('\n\nGroup2Category')
    group2category = extractor.getGroup2Category(blueprints)
    #print(group2category)

    # print('\n\nInventoryGroupNames')
    # inventoryGroupNames = extractor.getInventoryGroupNames(group2category)
    # print(inventoryGroupNames)

    marketGroup2Parent = extractor.getMarketGroup2Parent(blueprints)

    # print('\n\nTrade hubs')
    region2systems, system2name = extractor.getTradeHubs()
    # print(region2systems, system2name)

    # # there are bad translations in the eve sde
    # str2tid = {}
    # for tid in items:
    #     for lang in items[tid]['name']:
    #         name = items[tid]['name'][lang]
    #         if name in str2tid:
    #             if (str2tid[name] != tid):
    #                 print(name, ':', items[tid]['name'])
    #                 print(name, ':', items[str2tid[name]]['name'])
    #                 print()
    #         str2tid[name] = tid
    # print(len(str2tid))
    # mat2id = {}
    # allMaterialsIDs = extractor._getAllMaterials(blueprints)
    # print(len(allMaterialsIDs))
    # for k,v in mat2id.items():
    #     print(k,v)

if __name__ == "__main__":
    __test()
