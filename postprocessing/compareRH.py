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
Plot response histories against each other.

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

def husid(accRH, plot=False, dt=None, lb=0.05, ub=0.95):
    AI = np.tril(np.ones(len(accRH)))@accRH**2
    husid = AI/AI[-1]
    ilb = next(x for x, val in enumerate(husid) if val > lb)
    iub = next(x for x, val in enumerate(husid) if val > ub)
    if dt is not None:
        print("duration between ", f"{100*lb}%", " and ", f"{100*ub}%", " (s): ", dt*(iub-ilb))
    if plot:
        fig, ax = plt.subplots()
        if dt is not None:
            ax.plot(dt*np.arange(len(accRH)), husid)
            ax.set_xlabel("time (s)")
        else:
            ax.plot(np.arange(len(accRH)), husid)
            ax.set_xlabel("timestep")
        ax.axhline(husid[ilb], linestyle=":", label=f"{100*lb}%")
        ax.axhline(husid[iub], linestyle="--", label=f"{100*ub}%")
        ax.set_title("Husid Plot")
        ax.legend()
        plt.show()
    return (ilb, iub)

def plot(sensorRH, modelRH, window=None, dt=None):
    if window is not None:
        ts=window
    else:
        ts=(0,-1)
    fig, ax = plt.subplots()
    if dt is not None:
        ax.plot(dt*np.arange(len(sensorRH))[ts[0]:ts[1]], sensorRH[ts[0]:ts[1]], linewidth=0.75, label="sensor")
        ax.plot(dt*np.arange(len(modelRH))[ts[0]:ts[1]], modelRH[ts[0]:ts[1]], ":", linewidth=1.5, label="model")
        ax.set_xlabel("time (s)")
    else:
        ax.plot(np.arange(len(sensorRH))[ts[0]:ts[1]], sensorRH[ts[0]:ts[1]], linewidth=0.75, label="sensor")
        ax.plot(np.arange(len(modelRH))[ts[0]:ts[1]], modelRH[ts[0]:ts[1]], ":", linewidth=1.5, label="model")
        ax.set_xlabel("timestep")
    ax.legend()
    plt.show()


# Main script
#----------------------------------------------------

if __name__ == "__main__":
    opts = parse_args(sys.argv)
    if ".yaml" in opts["sensorRH-file"]:
        import yaml # pip install pyyaml
        with open(opts["sensorRH-file"], "r") as f:
            sensorData = yaml.load(f, Loader=yaml.Loader)
            # sensorData = json.load(f)
        
        sensorRH = ... # reshape

    else:
        sensorRH = np.loadtxt(opts["sensorRH-file"])
    modelRH = np.loadtxt(opts["modelRH-file"])
    func_dict[opts["metric"]](sensorRH, modelRH)
    if "AA" in opts["sensorRH-file"] or "acc" in opts["sensorRH-file"]:
        window = husid(sensorRH, plot=True, dt=0.005, lb=0.0005, ub=0.9995)
    else:
        window = None
    # window = husid(sensorRH, plot=True, dt=0.005, lb=0.005, ub=0.995)
    plot(sensorRH, modelRH, window=window, dt=0.005)
