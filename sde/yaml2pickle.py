# Converts all the yaml files into pickled dicts.

import unicodedata
import yaml
import pickle as pkl
import os

sde = "sde/fsd/"
sdePkl = "pickled/"


def normalizeStringsInMap(obj):
    if type(obj) is dict:
        ret = {}
        for k, v in obj.items():
            v = normalizeStringsInMap(v)
            if type(k) is str:
                k = unicodedata.normalize("NFKD", k)
            ret[k] = v
        return ret
    elif type(obj) is list:
        ret = []
        for v in obj:
            ret.append(normalizeStringsInMap(v))
        return ret
    elif type(obj) is str:
        return unicodedata.normalize("NFKD", obj)

    return obj


for fileName in os.listdir(sde):
    loadPath = os.path.join(sde, fileName)
    if os.path.isfile(loadPath) and loadPath.endswith('.yaml'):
        print("Pickling:", loadPath)

        with open(loadPath, 'r', encoding='utf-8') as handle:
            # I can not unicode normalize the input to the yaml parser.
            # If I do, then the parser fails with 'mapping value not allowed here' errors.
            fileStr = handle.read()
            fileContent = yaml.load(fileStr, Loader=yaml.FullLoader)

            fileContent = normalizeStringsInMap(fileContent)

            # # I found a string in the SDE that has a \xa0 char in it.
            # # This can be used to verify that my recursive function above works.
            # if 'ancestries' in loadPath:
            #     fun = fileContent[18]['descriptionID']['fr']
            #     print(fun)
            #     f = open('fun.txt', 'w', encoding="utf-8")
            #     # f.write(unicodedata.normalize("NFKD", fun))
            #     f.write(fun)
            #     f.close()
            #     exit()

        dumpPath = os.path.join(sdePkl, fileName.replace('yaml', 'dict.pkl'))
        with open(dumpPath, 'wb') as handle:
            pkl.dump(fileContent, handle, protocol=pkl.HIGHEST_PROTOCOL)
