This folder contains an SDE conversion program written in python that converts key parts of the SDE into a dart data file.

**download.py**

Downloads the SDE from CCP and downloads a few supporting data files from Hoboleaks.

**yaml2pickle.py**

Converts the SDE files (yaml files) into python dictionaries, pickles them, and the stores them to disk.
The reason I do this is because loading yaml files is **SLOW** but loading python pickled dicts is fast.

**ccp_sde.py**

This just loads the pickled dictionaries into a class for storage and easy access.

**sde_extractor.py**

This is the meat of the conversion program. Here I filter out unwanted data and store everything I do want into dictionaries.

**py2dart.py**

Takes the filtered data and converts it into valid dart code.