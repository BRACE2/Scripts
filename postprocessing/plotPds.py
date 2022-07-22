'''Script for plotting fundamental frequencies, comparing before and after gravity.
 Use modeID.py to identify the mode labels modeA, modeB, and modeC.
 Use system ID procedures to identify the baseline period values periodA, periodB, periodC.'''

import sys
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
plt.style.use('science')
plt.rcParams.update({'font.size': 14})

# Primary Mode Names
MODENAMES = ["transverse", "longitudinal", "torsional"]


# Script functions
#----------------------------------------------------

# Argument parsing
def parse_args(argv) -> dict:
    opts = {
        "inDir": None,  # Read the PeriodsPreG.txt and PeriodsPostG.txt files in from here
        "outDir": None, # Output the barplot image here
        "primaryModes": None, # A list of the mode numbers for the primary modes, e.g. [0,1,6]
        "sysIDpds": None # A list of the system-identified periods for the primary modes, e.g. [1.14,0.97,0.67]
    }
    args = iter(argv[1:])
    for arg in args:
        # if arg == "--help" or arg == "-h":
        #     print(HELP)
        #     sys.exit()
        if not opts["inDir"]:
            opts["inDir"] = arg
        elif not opts["outDir"]:
            opts["outDir"] = arg
        elif not opts["primaryModes"]:
            if arg == "-": arg = sys.stdin
            opts["primaryModes"] = arg
        else:
            opts["sysIDpds"] = arg
    return opts


def plot_pds(inDir, outDir, primaryModes, sysIDpds):
    perPreG = np.loadtxt(inDir+'PeriodsPreG.txt')[primaryModes]
    perPostG = np.loadtxt(inDir+'PeriodsPostG.txt')[primaryModes]
    dfs = pd.DataFrame(index=MODENAMES, data={
                                'pre-gravity': perPreG,
                                'post-gravity': perPostG})
    fig, axs = plt.subplots(nrows=1, ncols=1, figsize=(6,4), dpi=200)
    ax = dfs.plot.bar(rot=0, ax=axs, legend=False)
    ax.axhline([sysIDpds[0]], xmin=0, xmax=1/3, color='k', linestyle='--', label='system ID')
    ax.axhline([sysIDpds[1]], xmin=1/3, xmax=2/3, color='k', linestyle='--')
    ax.axhline([sysIDpds[2]], xmin=2/3, xmax=1, color='k', linestyle='--')
    ax.set_ylim([0,1.5])
    ax.grid(axis="y", zorder=0)
    ax.set_axisbelow(True)
    ax.set_xlabel('Mode')
    ax.set_ylabel('Period [s]')
    ax.set_title('Fundamental Periods')
    fig.legend(bbox_to_anchor=(0.4,0.4,0.5,0.5))
    fig.savefig(outDir+'plotPds.png', dpi=fig.dpi)
    # plt.show()


# Main script
#----------------------------------------------------

if __name__ == "__main__":
    opts = parse_args(sys.argv)
    # plot_pds(opts["inDir"], opts["outDir"], opts["primaryModes"], opts["sysIDpds"])    
    plot_pds(opts["inDir"], opts["outDir"], [0,1,6], [1.14,0.97,0.67])