# Converts all the yaml files into pickled dicts.

import yaml
import pickle as pkl
import os

sde = "sde/fsd/"
sdePkl = "pickled/"

for fileName in os.listdir(sde):
    loadPath = os.path.join(sde, fileName)
    if os.path.isfile(loadPath) and loadPath.endswith('.yaml'):
        print("Pickling:", loadPath)

        with open(loadPath, 'rb') as handle:
            fileContent = yaml.load(handle, Loader=yaml.FullLoader)

        dumpPath = os.path.join(sdePkl, fileName.replace('yaml', 'dict.pkl'))
        with open(dumpPath, 'wb') as handle:
            pkl.dump(fileContent, handle, protocol=pkl.HIGHEST_PROTOCOL)
