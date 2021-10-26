
This script generates a text summary of a given CSMIP zip file.

The variables `ground_channels` and `bridge_channels` must be changed
in order to use this script with different bridges.

Installation
============
This script depends on external libraries which may be installed by
running the following commands from any standard command line shell
(e.g. Bash on Linux, Powershell on Windows)

   python -m pip install --upgrade pip

   python -m pip install --upgrade quakeio


Using the Script
================
This script can be invoked from any modern command line shell as 
follows:

   python Path_to_this_file Path_to_data.zip > Summary.txt


For example, if the contents of the current working directory
is the following:

  .
  ├── 58658_003_20210628_18.29.26.P.zip
  └── summarize.py


Then the script would be invoked as follows to create a summary
named `Summary.txt` in the same directory.

   python summarize.py 58658_003_20210628_18.29.26.P.zip > Summary.txt

