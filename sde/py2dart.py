from ccp_sde import CCP_SDE
from sde_extractor import SDE_Extractor

# Bonus Type
DART_TIME = '_t'
DART_MATERIAL = '_m'
DART_COST = '_c'
PY_TIME = 'time'
PY_MATERIAL = 'material'
PY_COST = 'cost'

# Industry Type
DART_MANUFACTURING = '_M'
DART_REACTION = '_R'
PY_REACTION = 'reaction'
PY_MANUFACTURING = 'manufacturing'


class Py2Dart:
    """Generate dart code from the sde extracted info."""

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
            code += str(k) + ':' + str(obj[k]) + ','
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

    def _intset(self, obj) -> str:
        code = '{'
        for x in obj:
            code += str(x) + ','
        if len(obj) > 0:
            code = code[:-1]  # trim the final comma
        return code + '}'

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
        code += self._intset(obj['domain']['categoryIDs']) + ','
        code += self._intset(obj['domain']['groupIDs']) + ','
        code += self._str2str(obj['name'])
        return code + ')'

    def _skill(self, obj) -> str:
        code = 'Skill('
        code += (DART_REACTION if obj['activity'] == PY_REACTION else DART_MANUFACTURING) + ','
        code += str(obj['marketGroupID']) + ','
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
        code += str(obj['productQuantity']) + ','
        code += self._int2int(obj['materials']) + ','
        code += str(obj['time']) + ','
        if 'techLevel' in obj:
            code += self._ints(obj['skills']) + ','
            code += str(obj['techLevel'])
        else:
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
        code = 'static const Map<' + fromType + ',' + toType + '>' + name + '={'
        for k in dic:
            code += str(k) + ':' + objMaker(dic[k]) + ','
        if len(dic) > 0:
            code = code[:-1]  # trim the final comma
        return code + '};'

    def generate(self):
        ex = self.extractor
        structures = ex.getStructuresAndBonuses()
        rigs = ex.getIndustryRigsAndBonuses()
        productionSkills = ex.getProductionSkills()
        implants = ex.getImplants()
        blueprints = ex.getBlueprints(productionSkills.keys())
        items = ex.getIndustryItems(blueprints)
        # marketGroupGraph = ex.getMarketGroupGraph(blueprints)
        marketGroupNames = ex.getMarketGroupNames(items, productionSkills)
        group2category = ex.getGroup2Category(blueprints)
        region2systems, system2name = ex.getTradeHubs()
        marketGroup2parent = ex.getMarketGroup2Parent(blueprints)
        item2marketGroupAncestors = ex.getItem2marketGroupAncestors(items, blueprints)
        # buildableItemIDs = ex.getBuildableItemIDs(blueprints)

        code = ''
        code += "import 'models/industry_type.dart';"
        code += "import 'models/bonus_type.dart';"
        code += "import 'models/item.dart';"
        code += "import 'models/blueprint.dart';"
        code += "import 'models/structure.dart';"
        code += "import 'models/implant.dart';"
        code += "import 'models/rig.dart';"
        code += "import 'models/skill.dart';"

        code += 'const _m=BonusType.MATERIAL;'
        code += 'const _t=BonusType.TIME;'
        code += 'const _c=BonusType.COST;'
        code += 'const _M=IndustryType.MANUFACTURING;'
        code += 'const _R=IndustryType.REACTION;'

        code += 'abstract class SDE {'
        code += self._dict2map('items', 'int', 'Item', items, self._item)
        code += self._dict2map('blueprints', 'int', 'Blueprint', blueprints, self._blueprint)
        code += self._dict2map('marketGroupNames', 'int', 'Map<String,String>', marketGroupNames, self._str2str)
        code += self._dict2map('rigs', 'int', 'Rig', rigs, self._rig)
        # code += self._dict2map('marketGroupGraph', 'int', 'List<int>', marketGroupGraph, self._ints)
        code += self._dict2map('marketGroup2parent', 'int', 'int', marketGroup2parent, self._int)
        code += self._dict2map('skills', 'int', 'Skill', productionSkills, self._skill)
        code += self._dict2map('structures', 'int', 'Structure', structures, self._structure)
        code += self._dict2map('implants', 'int', 'Implant', implants, self._implant)
        code += self._dict2map('group2category', 'int', 'int', group2category, self._int)
        code += self._dict2map('region2systems', 'int', 'Set<int>', region2systems, self._intset)
        code += self._dict2map('system2name', 'int', 'Map<String,String>', system2name, self._str2str)
        code += self._dict2map('item2marketGroupAncestors', 'int', 'Set<int>', item2marketGroupAncestors, self._intset)
        code += '}'

        # # Dart run the output to check for syntax errors
        # code += 'void main() {\n'
        # code += '   print(items.length);\n'
        # ....
        # code += '}'
        # with open('hi.dart', 'w', encoding='utf-8') as handle:
        #     handle.write(code)

        return code


def py2dart():
    py2dart = Py2Dart(SDE_Extractor(CCP_SDE()))
    code = py2dart.generate()
    with open('../lib/sde.dart', 'w', encoding='utf-8', newline='\n') as handle:
        handle.write(code)


if __name__ == '__main__':
    py2dart()
