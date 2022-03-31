This folder contains an SDE conversion program written in python that converts key parts of the SDE into a dart data file.

**convert.py**

Simply starts the conversion process.

**download.py**

Downloads the SDE from CCP and a few supporting data files from Hoboleaks. Puts the SDE into `./sde/` and the hoboleaks files into `./hoboleaks/` also creates the empty folder `./pickled/`.

**yaml2pickle.py**

Converts the SDE files (yaml files) into python dictionaries, pickles them, and the stores them to disk.
The reason I do this is because loading yaml files is **SLOW** but loading python pickled dicts is fast.
This file can be executed by itself so long as the SDE has been extracted into `./sde/`.

**ccp_sde.py**

This just loads the pickled dictionaries into a class for storage and easy access.

**sde_extractor.py**

This is the meat of the conversion program. Here I filter out unwanted data and store everything I do want into dictionaries.
Can be ran by itself if `yaml2pickle.py` and `download.py` have completed successfully.

**py2dart.py**

Takes the filtered data and converts it into valid dart code.
Can be ran by itself if `yaml2pickle.py` and `download.py` have completed successfully.