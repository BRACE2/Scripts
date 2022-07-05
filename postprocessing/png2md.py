#!/bin/python

import sys
from pathlib import Path


HELP = """
png2md <png>...

run in pipe like:
    png2md path/to/dir/*.png | pandoc -f markdown -o FILE.pptx


NOTES: 
    - in markdown, images look like:

        ![My caption](path/to/image.png)

    - to install pandoc:

        sudo apt install pandoc
    
    - 

"""

script = "<h1>Test</h1>\n"
for i,file in enumerate(sys.argv[1:]):
    script += f"# {i} - `{file}`\n"
    script += f"![caption {i}]({file})\n\n"

print(script)


