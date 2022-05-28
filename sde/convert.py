import grequests  # not importing grequests before requests can lead to errors https://github.com/gevent/gevent/issues/1016

from download import download
from yaml2pickle import yaml2pickle
from py2dart import py2dart


def main():
    download()
    yaml2pickle()
    py2dart()


if __name__ == '__main__':
    main()