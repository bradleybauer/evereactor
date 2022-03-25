from ccp_sde import CCP_SDE
from sde_extractor import SDE_Extractor

# Bonus Type
DART_TIME = 'B.TIME'
DART_MATERIAL = 'B.MATERIAL'
DART_COST = 'B.COST'
PY_TIME = 'time'
PY_MATERIAL = 'material'
PY_COST = 'cost'

# Industry Type
DART_MANUFACTURING = 'I.MANUFACTURING'
DART_REACTION = 'I.REACTION'
PY_REACTION = 'reaction'
PY_MANUFACTURING = 'manufacturing'


class Py2Dart:
    """
    Generate dart code from the sde extracted info.
    """

    def __init__(self, extractor) -> None:
        self.extractor = extractor

    def _str(self, obj) -> str:
        if "'" in obj:
            return '"' + obj + '"'
        else:
            return "'" + obj + "'"

    def _str2str(self, obj) -> str:
        code = '{'
        for k in obj:
            code += self._str(k) + ':' + self._str(obj[k]) + ','
        if len(obj) > 0:
            code = code[:-1]  # trim the final comma
        return code + '}'

    def _int2int(self, obj) -> str:
        code = '{'
        for k in obj:
            code += self._int(k) + ':' + self._int(obj[k]) + ','
        if len(obj) > 0:
            code = code[:-1]  # trim the final comma
        return code + '}'

    def _int(self, obj) -> str:
        return str(obj)

    def _ints(self, obj) -> str:
        code = '['
        for x in obj:
            code += str(x) + ','
        if len(obj) > 0:
            code = code[:-1]  # trim the final comma
        return code + ']'

    def _structure(self, obj) -> str:
        code = 'Structure('
        code += (DART_REACTION if obj['activity'] == PY_REACTION else DART_MANUFACTURING) + ','
        code += '{'
        if 'bonuses' in obj:
            for bonusType in obj['bonuses']:
                if bonusType == PY_TIME:
                    code += DART_TIME + ':' + str(obj['bonuses'][PY_TIME]) + ','
                elif bonusType == PY_COST:
                    code += DART_COST + ':' + str(obj['bonuses'][PY_COST]) + ','
                elif bonusType == PY_MATERIAL:
                    code += DART_MATERIAL + ':' + str(obj['bonuses'][PY_MATERIAL]) + ','
            if 0 < len(obj['bonuses']):
                code = code[:-1]
        code += '},'
        code += self._str2str(obj['name'])
        return code + ')'

    def _rig(self, obj) -> str:
        code = 'Rig('
        code += (DART_REACTION if obj['activity'] == PY_REACTION else DART_MANUFACTURING) + ','
        code += '{'
        if 'bonuses' in obj:
            for bonusType in obj['bonuses']:
                if bonusType == PY_TIME:
                    code += DART_TIME + ':' + str(obj['bonuses'][PY_TIME]) + ','
                elif bonusType == PY_COST:
                    code += DART_COST + ':' + str(obj['bonuses'][PY_COST]) + ','
                elif bonusType == PY_MATERIAL:
                    code += DART_MATERIAL + ':' + str(obj['bonuses'][PY_MATERIAL]) + ','
            if 0 < len(obj['bonuses']):
                code = code[:-1]
        code += '},'
        code += self._ints(obj['domain']['categoryIDs']) + ','
        code += self._ints(obj['domain']['groupIDs']) + ','
        code += self._str2str(obj['name'])
        return code + ')'

    def _skill(self, obj) -> str:
        code = 'Skill('
        code += (DART_REACTION if obj['activity'] == PY_REACTION else DART_MANUFACTURING) + ','
        code += str(obj['bonus']) + ','
        code += self._str2str(obj['name'])
        return code + ')'

    def _implant(self, obj) -> str:
        code = 'Implant('
        code += str(obj['bonus']) + ','
        code += self._str2str(obj['name'])
        return code + ')'

    def _blueprint(self, obj) -> str:
        code = 'Blueprint('
        code += (DART_REACTION if obj['activity'] == PY_REACTION else DART_MANUFACTURING) + ','
        code += str(obj['productID']) + ','
        code += str(obj['productQuantity']) + ','
        code += self._int2int(obj['materials']) + ','
        code += str(obj['time']) + ','
        code += self._ints(obj['skills'])
        return code + ')'

    def _item(self, obj) -> str:
        code = 'Item('
        code += self._str2str(obj['name']) + ','
        code += str(obj['marketGroupID']) + ','
        code += str(obj['groupID']) + ','
        code += str(obj['volume'])
        return code + ')'

    def _dict2map(self, name, fromType, toType, dic, objMaker) -> str:
        code = 'const Map<' + fromType + ',' + toType + '>' + name + '={'
        for k in dic:
            code += str(k) + ':' + objMaker(dic[k]) + ','
        if len(dic) > 0:
            code = code[:-1]  # trim the final comma
        return code + '};\n'

    def generate(self):
        ex = self.extractor
        structures = ex.getStructuresAndBonuses()
        rigs = ex.getIndustryRigsAndBonuses()
        productionSkills = ex.getProductionSkills()
        implants = ex.getImplants()
        bps = ex.getItem2Blueprint(productionSkills.keys())
        items = ex.getIndustryItems(bps)
        marketGroupGraph = ex.getMarketGroupGraph(bps)
        marketGroupNames = ex.getMarketGroupNames(marketGroupGraph)
        group2category = ex.getGroup2Category(bps)
        regions, systems = ex.getTradeHubs()

        code = ''
        code += "import '../lib/model/industry_type.dart';\n"
        code += "import '../lib/model/bonus_type.dart';\n"
        code += "import '../lib/model/item.dart';\n"
        code += "import '../lib/model/blueprint.dart';\n"
        code += "import '../lib/model/structure.dart';\n"
        code += "import '../lib/model/implant.dart';\n"
        code += "import '../lib/model/rig.dart';\n"
        code += "import '../lib/model/skill.dart';\n"

        code += 'typedef I=IndustryType;\n'
        code += 'typedef B=BonusType;\n'

        code += self._dict2map('items', 'int', 'Item', items, self._item)
        code += self._dict2map('blueprints', 'int', 'Blueprint', bps, self._blueprint)
        code += self._dict2map('marketGroupNames', 'int', 'Map<String,String>', marketGroupNames, self._str2str)
        code += self._dict2map('rigs', 'int', 'Rig', rigs, self._rig)
        code += self._dict2map('marketGroupGraph', 'int', 'List<int>', marketGroupGraph, self._ints)
        code += self._dict2map('skills', 'int', 'Skill', productionSkills, self._skill)
        code += self._dict2map('structures', 'int', 'Structure', structures, self._structure)
        code += self._dict2map('implants', 'int', 'Implant', implants, self._implant)
        code += self._dict2map('group2category', 'int', 'int', group2category, self._int)
        code += self._dict2map('regions', 'int', 'List<int>', regions, self._ints)
        code += self._dict2map('systems', 'int', 'Map<String,String>', systems, self._str2str)

        # # Dart run the output to check for syntax errors
        # code += 'void main() {'
        # code += '   print(items.length);'
        # code += '   print(blueprints.length);'
        # code += '   print(marketGroupNames.length);'
        # code += '   print(rigs.length);'
        # code += '   print(marketGroupGraph.length);'
        # code += '   print(skills.length);'
        # code += '   print(structures.length);'
        # code += '   print(implants.length);'
        # code += '   print(group2category.length);'
        # code += '   print(regions.length);'
        # code += '   print(systems.length);'
        # code += '}'
        # with open('hi.dart', 'w', encoding='utf-8') as handle:
        #     handle.write(code)

        return code

def py2dart():
    py2dart = Py2Dart(SDE_Extractor(CCP_SDE()))
    code = py2dart.generate()
    with open('data_file.dart', 'w', encoding='utf-8') as handle:
        handle.write(code)

if __name__ == '__main__':
    py2dart()
