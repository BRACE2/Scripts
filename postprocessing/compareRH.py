# Obtain difference and error metrics between sensor and model response histories.
# Chrystal Chern cchern@berkeley.edu


# Setup
#----------------------------------------------------

import sys
import numpy as np
from matplotlib import pyplot as plt

NAME = "compareRH.py"

METRICS = ["Diff", "RMS", "AMX", "CAV"]

HELP = f"""
usage: {NAME} <metric> <sensorRH-file> <modelRH-file>

Obtain errors and differences between model and sensor response histories.

Positional Arguments:
  <metric>                       string defining desired RH comparison metric.
                                 one of the following metrics:
                                 {METRICS}.
  <sensorRH-file>                text file of sensor response history, or - if from stdin
  <modelRH-file>                 text file of model output response history.

Options:
  -h, --help                     Print this message and exit.
"""

EXAMPLES="""
Examples:
    Compare the relative difference between the RH in `sensorRH.txt` and `modelRH.txt`:
        $ {NAME} Diff sensorRH.txt modelRH.txt
"""


# Script functions
#----------------------------------------------------

# Argument parsing
def parse_args(argv) -> dict:
    opts = {
        "metric": None,
        "sensorRH-file": None,
        "modelRH-file": None,
    }
    args = iter(argv[1:])
    for arg in args:
        if arg == "--help" or arg == "-h":
            print(HELP)
            sys.exit()
        elif not opts["metric"]:
            opts["metric"] = arg
        elif not opts["sensorRH-file"]:
            if arg == "-": arg = sys.stdin
            opts["sensorRH-file"] = arg
        else:
            opts["modelRH-file"] = arg
    return opts

# Helper functions for each metric
def Diff(sensorRH, modelRH):
    out = modelRH - sensorRH
    for diff in out:
        print(diff)

def RMS(sensorRH, modelRH):
    N = sensorRH.shape[0] # number of timesteps
    am = np.median(abs(sensorRH)) # median absolute sensor response value
    out = (np.sum((modelRH - sensorRH)**2)/N)**0.5/am
    print(out)

def AMX(sensorRH, modelRH):
    acp = max(abs(modelRH))
    amp = max(abs(sensorRH))
    out = 100*(acp-amp)/amp
    print(out)

def CAV(sensorRH, modelRH):
    modelCAV = np.trapz(abs(modelRH))
    sensorCAV = np.trapz(abs(sensorRH))
    out = 100*(modelCAV - sensorCAV) / sensorCAV
    print(out)

func_dict = {
    METRICS[0] : Diff,
    METRICS[1] : RMS,
    METRICS[2] : AMX,
    METRICS[3] : CAV,
}


# Main script
#----------------------------------------------------

if __name__ == "__main__":
    opts = parse_args(sys.argv)
    sensorRH = np.loadtxt(opts["sensorRH-file"])
    modelRH = np.loadtxt(opts["modelRH-file"])
    func_dict[opts["metric"]](sensorRH, modelRH)
    plt.plot(np.arange(len(sensorRH)), sensorRH, label="sensor")
    plt.plot(np.arange(len(modelRH)), modelRH, label="model")
    plt.legend()
    plt.show()
