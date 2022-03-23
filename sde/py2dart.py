from ccp_sde import CCP_SDE
from sde_extractor import SDE_Extractor


class Py2Dart:

    def __init__(self, extractor) -> None:
        self.extractor = extractor

    def generate(self):
        return "print('hello world!');"


if __name__ == '__main__':
    py2dart = Py2Dart(SDE_Extractor(CCP_SDE()))
    print(py2dart.generate())
