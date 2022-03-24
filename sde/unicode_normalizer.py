import unicodedata


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
