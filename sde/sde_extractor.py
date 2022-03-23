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
            ids = ids.union(set(bp['products']))
        return ids

    def getIndustryItems(self, blueprints):
        """
        Returns the relavent information of all items involved in production.
        typeID -> (name localizations, marketGroupId, volume or repackaged volume)
        """
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

    def _filterBP(self, tid):
        isPublished = self._isPublished(tid)
        hasActivities = 0 < len(set(self.possibleActivities).intersection(set(self.sde.blueprints[tid]['activities'])))
        isProductPublished = True
        isNormalBp = True
        for activity in self.possibleActivities:  # choose the activity
            if activity in self.sde.blueprints[tid]['activities']:
                assert (0 == len((self.possibleActivities - {activity}).intersection(self.sde.blueprints[tid]['activities'])))
                if 'products' not in self.sde.blueprints[tid]['activities'][activity]:
                    isProductPublished = False
                    break
                products = self.sde.blueprints[tid]['activities'][activity]['products']
                assert (len(products) == 1)
                productTID = products[0]['typeID']
                if productTID not in self.sde.typeIDs or not self._isPublished(productTID):
                    isProductPublished = False
                    break
                if 'materials' not in self.sde.blueprints[tid]['activities'][activity]:
                    isNormalBp = False
                    break
                for material in self.sde.blueprints[tid]['activities'][activity]['materials']:
                    if material['typeID'] == productTID:
                        isNormalBp = False
                        break
                break
        return isPublished and hasActivities and isProductPublished and isNormalBp

    def getItem2Blueprint(self):
        """Returns the blueprint info for buildable items."""
        item2bp = {}
        for tid in self.sde.blueprints:
            if not self._filterBP(tid):
                continue
            item2bp[tid] = {}
            bp = self.sde.blueprints[tid]
            for activity in bp['activities']:
                if activity in self.possibleActivities:
                    item2bp[tid]['activity'] = activity
                    item2bp[tid]['materials'] = {}
                    for pair in bp['activities'][activity]['materials']:
                        item2bp[tid]['materials'][pair['typeID']] = pair['quantity']
                    assert (1 == len(bp['activities'][activity]['products']))
                    productID = bp['activities'][activity]['products'][0]['typeID']
                    productQuantity = bp['activities'][activity]['products'][0]['quantity']
                    item2bp[tid]['products'] = {productID: productQuantity}
                    item2bp[tid]['time'] = bp['activities'][activity]['time']
                    if 'skills' in bp['activities'][activity]:
                        item2bp[tid]['skills'] = set()
                        for pair in bp['activities'][activity]['skills']:
                            item2bp[tid]['skills'].add(pair['typeID'])
                    break  # a bp can contain only one of the two possible activities
        return item2bp

    def getSkill2Parents(self):
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

    def getProductionSkills(self):
        """
        Returns all skills that have some bonus to some kind of production.
        skill -> (activity, bonus)
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

            skill = {'activity': activity, 'bonus': bonus}
            # print(tid, sde.typeIDs[tid]['name']['en'], ' ' * (42 - len(str(tid) + sde.typeIDs[tid]['name']['en'])), skill)
            # skill['activity'] = 'manufacturing' if 'manufacturing' in sde.hoboleaksModifierSources[tid] else 'reaction'

            skills[tid] = skill
        return skills

    def getStructuresAndBonuses(self):
        """Returns all structures and structure bonuses."""
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
                        structure[bonusType] = bonus

            structures[tid] = structure
        return structures

    def getIndustryRigsAndBonuses(self):
        """
        Returns all industry rigs with their bonuses and item domains.
        rigId -> (activity type, bonusType -> value, bonus domain)
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

            # output = str(tid) + ", " + self._getName(tid)
            # output += "\n\tDogmaAttributes" + '\n'

            costBonusAttributes = {2595}
            materialBonusAttributes = {2594, 2653, 2714}
            timeBonusAttributes = {2593, 2713}
            securityMultiplierAttributes = {2356, 2357}
            securityEffectIDs = {6842, 6976}

            securityMultiplier = 0.0
            attributes = {}

            for pair in sde.typeDogma[tid]['dogmaAttributes']:
                attributeID = pair['attributeID']
                # if 'displayNameID' in sde.dogmaAttributes[attributeID]:
                #     attribDisplay = sde.dogmaAttributes[attributeID]['displayNameID']['en']
                # elif 'description' in sde.dogmaAttributes[attributeID]:
                #     attribDisplay = sde.dogmaAttributes[attributeID]['description']
                # else:
                #     attribDisplay = attributeID
                # if attributeID in costBonusAttributes or attributeID in materialBonusAttributes or attributeID in timeBonusAttributes or attributeID in securityMultiplierAttributes:
                #     output += '\t\t' + str(attributeID) + ':' + str(attribDisplay) + ':' + str(pair['value']) + '\n'
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
            # output += "\tSecurity Updated Attribs\n"
            for securityEffectID in securityEffectIDs:
                for effect in sde.typeDogma[tid]['dogmaEffects']:
                    if effect['effectID'] == securityEffectID:
                        for modification in sde.dogmaEffects[securityEffectID]['modifierInfo']:
                            modified = modification['modifiedAttributeID']
                            if modified in attributes:
                                attributes[modified] *= securityMultiplier
                                # output += '\t\t' + str(modified) + " : " + str(attributes[modified]) + '\n'
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

            rigs[tid] = rig
            # print(sde.typeIDs[tid]['name']['en'], rig)
            # print(rig)
            # print(output)
        return rigs

    def getImplants(self):
        """Returns all industry implants and their bonuses."""
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
            implants[tid] = {'activity': 'manufacturing', 'bonus': bonus}
        return implants


if __name__ == "__main__":
    from ccp_sde import CCP_SDE
    sde = CCP_SDE()
    extractor = SDE_Extractor(sde)

    print("\n\nBlueprints")
    bps = extractor.getItem2Blueprint()
    for k, v in bps.items():
        print(k, v)
    print('Number of blueprints accepted:', len(extractor.getItem2Blueprint()))

    print('\n\nIndustry Items')
    for k, v in extractor.getIndustryItems(bps).items():
        print(k, v)
    print(len(extractor.getIndustryItems(bps)))

    print("\n\nStructures")
    for k, v in extractor.getStructuresAndBonuses().items():
        print(k, v)

    print("\n\nRigs")
    for k, v in extractor.getIndustryRigsAndBonuses().items():
        print(k, v)

    print("\n\nSkillsParents")
    print(extractor.getSkill2Parents())

    print("\n\nProductionSkills")
    for k, v in extractor.getProductionSkills().items():
        print(k, v)

    print("\n\nImplants")
    for k, v in extractor.getImplants().items():
        print(k, v)
