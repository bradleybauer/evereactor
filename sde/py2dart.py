from ccp_sde import CCP_SDE
from sde_extractor import SDE_Extractor


class Py2Dart:
    """
    Generate dart code from the sde extracted info.
    """

    def __init__(self, extractor) -> None:
        self.extractor = extractor

    def _str(self, obj) -> str:
        return '"' + obj + '"'

    def _int(self, obj) -> str:
        return str(obj)

    def _listInt(self, obj) -> str:
        code = ''
        return code

    def _structure(self, obj) -> str:
        code = ''
        return code

    def _rig(self, obj) -> str:
        code = ''
        return code

    def _skill(self, obj) -> str:
        code = ''
        return code

    def _implant(self, obj) -> str:
        code = ''
        return code

    def _blueprint(self, obj) -> str:
        code = ''
        return code

    def _item(self, obj) -> str:
        code = ''
        return code

    def _marketGroupGraphNode(self, obj) -> str:
        code = ''
        return code

    def _dict2map(self, name, fromType, toType, dic, objMaker) -> str:
        code = 'const Map<' + fromType + ',' + toType + '>' + name + '={'
        for k in dic:
            code += str(k) + ':' + objMaker(dic[k]) + ','
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
        code += "import 'item.dart';"
        code += "import 'blueprint.dart';"
        code += "import 'structure.dart';"
        code += "import 'implant.dart';"
        code += "import 'rig.dart';"
        code += "import 'skill.dart';"

        code += self._dict2map('structures', 'int', 'Structure', structures, self._structure)
        code += self._dict2map('rigs', 'int', 'Rig', rigs, self._rig)
        code += self._dict2map('skills', 'int', 'Skill', productionSkills, self._skill)
        code += self._dict2map('implants', 'int', 'Implant', implants, self._implant)
        code += self._dict2map('blueprints', 'int', 'Implant', bps, self._blueprint)
        code += self._dict2map('items', 'int', 'Item', items, self._item)
        code += self._dict2map('marketGroups', 'int', 'List<int>', marketGroupGraph, self._listInt)
        code += self._dict2map('marketGroupNames', 'int', 'String', marketGroupNames, self._str)
        code += self._dict2map('group2category', 'int', 'int', group2category, self._int)
        code += self._dict2map('regions', 'int', 'List<int>', regions, self._listInt)
        code += self._dict2map('systems', 'int', 'int', systems, self._int)

        return code


if __name__ == '__main__':
    py2dart = Py2Dart(SDE_Extractor(CCP_SDE()))
    print(py2dart.generate())
