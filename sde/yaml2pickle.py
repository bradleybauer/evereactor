# Converts all the yaml files into pickled dicts.
import yaml
import pickle as pkl
import os

from unicode_normalizer import normalizeStringsInMap

sde = "sde/fsd/"
sdePkl = "pickled/"

def yaml2pickle():
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
                # # This can be used to verify that my recursive function 'normalizeStringsInMap' works.
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

if __name__=='__main__':
    yaml2pickle()