'''Script for plotting fundamental frequencies, comparing before and after gravity.
 Use modeID.py to identify the mode labels modeA, modeB, and modeC.
 Use system ID procedures to identify the baseline period values periodA, periodB, periodC.'''

import sys
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
plt.style.use('science')
plt.rcParams.update({'font.size': 14})


# Script functions
#----------------------------------------------------

# Argument parsing
def parse_args(argv) -> dict:
    opts = {
        "inDir": None,
        "outDir": None
    }
    args = iter(argv[1:])
    for arg in args:
        # if arg == "--help" or arg == "-h":
        #     print(HELP)
        #     sys.exit()
        if not opts["inDir"]:
            if arg == "-": arg = sys.stdin
            opts["inDir"] = arg
        else:
            opts["outDir"] = arg
    return opts

modeA = 0
modeB = 1
modeC = 6

periodA = 1.14
periodB = 0.97
periodC = 0.67

modes = ["transverse", "longitudinal", "torsional"]


# Main script
#----------------------------------------------------

if __name__ == "__main__":
    opts = parse_args(sys.argv)
    perPreG = np.loadtxt(opts["inDir"]+'PeriodsPreG.txt')[[modeA,modeB,modeC]]
    perPostG = np.loadtxt(opts["inDir"]+'PeriodsPostG.txt')[[modeA,modeB,modeC]]
    dfs = pd.DataFrame(index=modes, data={
                                'pre-gravity': perPreG,
                                'post-gravity': perPostG})
    fig, axs = plt.subplots(nrows=1, ncols=1, figsize=(6,4), dpi=200)
    ax = dfs.plot.bar(rot=0, ax=axs, legend=False)
    ax.axhline([periodA], xmin=0, xmax=1/3, color='k', linestyle='--', label='system ID')
    ax.axhline([periodB], xmin=1/3, xmax=2/3, color='k', linestyle='--')
    ax.axhline([periodC], xmin=2/3, xmax=1, color='k', linestyle='--')
    ax.set_ylim([0,1.5])
    ax.grid(axis="y", zorder=0)
    ax.set_axisbelow(True)
    ax.set_xlabel('Mode')
    ax.set_ylabel('Period [s]')
    ax.set_title('Fundamental Periods')
    fig.legend(bbox_to_anchor=(0.4,0.4,0.5,0.5))
    fig.savefig(opts["outDir"]+'plotPds.png', dpi=fig.dpi)
    # plt.show()