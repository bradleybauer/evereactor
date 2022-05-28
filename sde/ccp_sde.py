import pickle as pkl
import json
import yaml

from unicode_normalizer import normalizeStringsInMap


def _openFile(file):
    # SDE files are pickled dicts.
    with open('sde/pickled/' + file + '.dict.pkl', 'rb') as handle:
        contents = pkl.load(handle)
    return contents


class CCP_SDE:
    """Loads and stores the sde as it is provided by CCP."""

    def __init__(self):
        self.typeIDs = _openFile('typeIDs')
        self.blueprints = _openFile('blueprints')

        self.typeDogma = _openFile('typeDogma')
        self.dogmaEffects = _openFile('dogmaEffects')
        self.dogmaAttributes = _openFile('dogmaAttributes')

        self.groupIDs = _openFile('groupIDs')
        self.categoryIDs = _openFile('categoryIDs')
        self.marketGroups = _openFile('marketGroups')

        self.hoboleaksModifierSources = None
        self.hoboleaksTargetFilters = None
        self.hoboleaksRepackagedVolumes = None

        self.jitaData = None
        self.perimeterData = None
        self.amarrData = None
        self.ashabData = None

        self.theForgeData = None
        self.domainData = None

        with open('./sde/hoboleaks/industrymodifiersources.json', 'r') as handle:
            dic = json.loads(handle.read())
            self.hoboleaksModifierSources = {}
            for k, v in dic.items():
                self.hoboleaksModifierSources[int(k)] = v
        with open('./sde/hoboleaks/industrytargetfilters.json', 'r') as handle:
            dic = json.loads(handle.read())
            self.hoboleaksTargetFilters = {}
            for k, v in dic.items():
                self.hoboleaksTargetFilters[int(k)] = v
        with open('./sde/hoboleaks/repackagedvolumes.json', 'r') as handle:
            dic = json.loads(handle.read())
            self.hoboleaksRepackagedVolumes = {}
            for k, v in dic.items():
                self.hoboleaksRepackagedVolumes[int(k)] = v

        # Jita/Perimeter
        with open('./sde/sde/fsd/universe/eve/TheForge/region.staticdata', 'r', encoding='utf-8') as handle:
            content = yaml.load(handle.read(), Loader=yaml.FullLoader)
            self.theForgeData = normalizeStringsInMap(content)
        with open('./sde/sde/fsd/universe/eve/TheForge/Kimotoro/Jita/solarsystem.staticdata', 'r', encoding='utf-8') as handle:
            content = yaml.load(handle.read(), Loader=yaml.FullLoader)
            self.jitaData = normalizeStringsInMap(content)
        with open('./sde/sde/fsd/universe/eve/TheForge/Kimotoro/Perimeter/solarsystem.staticdata', 'r', encoding='utf-8') as handle:
            content = yaml.load(handle.read(), Loader=yaml.FullLoader)
            self.perimeterData = normalizeStringsInMap(content)

        # Amarr/Ashab
        with open('./sde/sde/fsd/universe/eve/Domain/region.staticdata', 'r', encoding='utf-8') as handle:
            content = yaml.load(handle.read(), Loader=yaml.FullLoader)
            self.domainData = normalizeStringsInMap(content)
        with open('./sde/sde/fsd/universe/eve/Domain/ThroneWorlds/Amarr/solarsystem.staticdata', 'r', encoding='utf-8') as handle:
            content = yaml.load(handle.read(), Loader=yaml.FullLoader)
            self.amarrData = normalizeStringsInMap(content)
        with open('./sde/sde/fsd/universe/eve/Domain/Parud/Ashab/solarsystem.staticdata', 'r', encoding='utf-8') as handle:
            content = yaml.load(handle.read(), Loader=yaml.FullLoader)
            self.ashabData = normalizeStringsInMap(content)
