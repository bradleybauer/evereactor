import requests
import zipfile
import io
import os


def download():
    # Make directories
    os.mkdir('sde/sde/')
    os.mkdir('sde/sde/hoboleaks')
    os.mkdir('sde/sde/pickled')

    # Download Hoboleaks data
    print('Downloading data from Hoboleaks.')
    baseUrl = "https://sde.hoboleaks.space/tq/"
    files = ["industrytargetfilters.json", "industrymodifiersources.json", "repackagedvolumes.json"]
    for file in files:
        with open('./sde/sde/hoboleaks/' + file, 'wb') as handle:
            handle.write(requests.get(baseUrl + file).content)
    print('Done.')

    # Download SDE from CCP
    print('Downloading SDE from CCP.')
    url = "https://eve-static-data-export.s3-eu-west-1.amazonaws.com/tranquility/sde.zip"
    z = zipfile.ZipFile(io.BytesIO(requests.get(url).content))
    print('Extracting SDE.')
    z.extractall('./sde/sde')
    print('Done.')


if __name__ == '__main__':
    download()
