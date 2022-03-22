import pickle as pkl


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
