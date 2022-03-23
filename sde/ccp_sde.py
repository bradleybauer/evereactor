import pickle as pkl
import json


def _openFile(file):
    # SDE files are pickled dicts.
    with open('pickled/' + file + '.dict.pkl', 'rb') as handle:
        contents = pkl.load(handle)
    return contents


class CCP_SDE:
    """Loads and stores the sde as it is provided by CCP."""

    def __init__(self):
        self.typeIDs = _openFile('typeIDs')
        self.blueprints = _openFile('blueprints')

        self.typeDogma = _openFile('typeDogma')
        self.typeMaterials = _openFile('typeMaterials')
        self.dogmaEffects = _openFile('dogmaEffects')
        self.dogmaAttributes = _openFile('dogmaAttributes')

        self.groupIDs = _openFile('groupIDs')
        self.categoryIDs = _openFile('categoryIDs')
        self.marketGroups = _openFile('marketGroups')

        self.hoboleaksModifierSources = None
        self.hoboleaksTargetFilters = None
        self.hoboleaksRepackagedVolumes = None

        with open('./hoboleaks/industrymodifiersources.json', 'r') as f:
            d = json.loads(f.read())
            self.hoboleaksModifierSources = {}
            for k, v in d.items():
                self.hoboleaksModifierSources[int(k)] = v
        with open('./hoboleaks/industrytargetfilters.json', 'r') as f:
            d = json.loads(f.read())
            self.hoboleaksTargetFilters = {}
            for k, v in d.items():
                self.hoboleaksTargetFilters[int(k)] = v
        with open('./hoboleaks/repackagedvolumes.json', 'r') as f:
            d = json.loads(f.read())
            self.hoboleaksRepackagedVolumes = {}
            for k, v in d.items():
                self.hoboleaksRepackagedVolumes[int(k)] = v
