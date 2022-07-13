# Obtain difference and error metrics between two response histories (RH).
# Usually the two RH are sensor (true) RH and model (test) RH.
# Options to plot response histories against one another.
# Chrystal Chern cchern@berkeley.edu


# Setup
#----------------------------------------------------

import sys, yaml
import numpy as np
from math import pi
from matplotlib import pyplot as plt

NAME = "compareRH.py"

METRICS = ["Diff", "RMS", "AMX", "CAV"]

HELP = f"""
usage: {NAME} <metric> <trueRH-file> <testRH-file>
       {NAME} [options] <metric> <trueRH-file> <testRH-file>

Obtain difference and error metrics between two response histories (RH).
Usually the two RH are sensor (true) RH and model (test) RH.
Options to plot response histories against one another.

Positional Arguments:
  <metric>                      string defining desired RH comparison metric.
                                one of the following metrics:
                                {METRICS}.
  <trueRH-file>                 text file of true response history, or - if from stdin
  <testRH-file>                 text file of test response history.

Options:
  -n, --node                    node number. default 401.
  -c, --channel                 channel number. default 19.
  -d, --dof                     dof. default 1.
  -s, --dt                      timestep. default None (1)
  -p, --plot                    generate RH comparison plot. default False.
  -u, --plothusid               generate husid plot. default False.
  -h, --help                    Print this message and exit.
"""

EXAMPLES="""
Examples:
    Obtain the relative difference between the RH in `trueRH.txt` and `testRH.txt`:
        $ {NAME} Diff trueRH.txt testRH.txt
    Obtain the RMS error between the RH in `trueRH.txt` and `testRH.txt` at node 402, dof 2:
        $ {NAME} -n 402 -d 2 RMS trueRH.txt testRH.txt
"""

CHANNELS = {
# channel  node dof
    "2": (1031, 2, 37.66*pi/180),
    "3": (1031, 1, 37.66*pi/180),
    "6": (307, 1, 31.02*pi/180),
    "7": (307, 2, 31.02*pi/180),
    "12": (1030, 1, 37.66*pi/180),
    "13": (1030, 2, 37.66*pi/180),
    "14": (304, 1, 31.02*pi/180),
    "15": (304, 2, 31.02*pi/180),
    "17": (401, 1, 26.26*pi/180),
    "18": (401, 2, 26.26*pi/180),
    "19": (402, 1, 26.26*pi/180),
    "20": (402, 2, 26.26*pi/180),
    "22": (405, 1, 26.26*pi/180),
    "23": (405, 2, 26.26*pi/180),
    "24": (407, 1, 26.26*pi/180),
    "25": (407, 2, 26.26*pi/180),
}


# Script functions
#----------------------------------------------------

# Argument parsing
def parse_args(argv) -> dict:
    opts = {
        "metric": None,
        "trueRH-file": None,
        "testRH-file": None,
        "node": 401,
        "dof": 1,
        "dt": None,
        "plot": False,
        "plothusid": False
    }
    args = iter(argv[1:])
    for arg in args:
        if arg in ["--help","-h"]:
            print(HELP)
            sys.exit()
        elif arg in ["--node","-n"]:
            opts["node"] = next(args)
        elif arg in ["--channel","-c"]:
            opts["node"] = CHANNELS[str(next(args))][0]
        elif arg in ["--dof","-d"]:
            opts["dof"] = next(args)
        elif arg in ["--dt","-s"]:
            opts["dt"] = next(args)
        elif arg in ["--plot","-p"]:
            opts["plot"] = True
        elif arg in ["--plothusid","-u"]:
            opts["plothusid"] = True
        elif not opts["metric"]:
            opts["metric"] = arg
        elif not opts["trueRH-file"]:
            if arg == "-": arg = sys.stdin
            opts["trueRH-file"] = arg
        else:
            opts["testRH-file"] = arg
    return opts

# Helper functions for each metric
def Diff(trueRH, testRH):
    out = testRH - trueRH
    for diff in out:
        print(diff)

def RMS(trueRH, testRH):
    N = trueRH.shape[0] # number of timesteps
    am = np.median(abs(trueRH)) # median absolute true response value
    out = (np.sum((testRH - trueRH)**2)/N)**0.5/am
    print(out)

def AMX(trueRH, testRH):
    acp = max(abs(testRH))
    amp = max(abs(trueRH))
    out = 100*(acp-amp)/amp
    print(out)

def CAV(trueRH, testRH):
    testCAV = np.trapz(abs(testRH))
    trueCAV = np.trapz(abs(trueRH))
    out = 100*(testCAV - trueCAV) / trueCAV
    print(out)

func_dict = {
    METRICS[0] : Diff,
    METRICS[1] : RMS,
    METRICS[2] : AMX,
    METRICS[3] : CAV,
}

# Plotting functions
def husid(accRH, plothusid, dt, lb=0.05, ub=0.95):
    AI = np.tril(np.ones(len(accRH)))@accRH**2
    husid = AI/AI[-1]
    ilb = next(x for x, val in enumerate(husid) if val > lb)
    iub = next(x for x, val in enumerate(husid) if val > ub)
    if dt is not None:
        print("duration between ", f"{100*lb}%", " and ", f"{100*ub}%", " (s): ", dt*(iub-ilb))
    if plothusid:
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

def plot(trueRH, testRH, dt, window=None):
    if window is not None:
        ts=window
    else:
        ts=(0,-1)
    fig, ax = plt.subplots()
    if dt is not None: # Given dt, we can set the x axis to actual time rather than timestep.
        # ax.plot(dt*np.arange(len(trueRH))[ts[0]:ts[1]], trueRH[ts[0]:ts[1]], ".", label="true")  # Plot RH expected to have virtually exact match
        # ax.plot(dt*np.arange(len(testRH))[ts[0]:ts[1]], testRH[ts[0]:ts[1]], "x", label="test")
        ax.plot(dt*np.arange(len(trueRH))[ts[0]:ts[1]], trueRH[ts[0]:ts[1]], linewidth=0.75, label="sensor")  # Plot RH that doesn't match, usually sensor/model comparison.
        ax.plot(dt*np.arange(len(testRH))[ts[0]:ts[1]], testRH[ts[0]:ts[1]], ":", linewidth=1.5, label="model")
        ax.set_xlabel("time (s)")
    else: # Without dt, x axis can only show timestep.
        # ax.plot(np.arange(len(trueRH))[ts[0]:ts[1]], trueRH[ts[0]:ts[1]], ".", label="true")
        # ax.plot(np.arange(len(testRH))[ts[0]:ts[1]], testRH[ts[0]:ts[1]], "x", label="test")
        ax.plot(np.arange(len(trueRH))[ts[0]:ts[1]], trueRH[ts[0]:ts[1]], linewidth=0.75, label="sensor")
        ax.plot(np.arange(len(testRH))[ts[0]:ts[1]], testRH[ts[0]:ts[1]], ":", linewidth=1.5, label="model")
        ax.set_xlabel("timestep")
    ax.set_title("Response History Comparison")
    ax.legend()
    plt.show()


# Main script
#----------------------------------------------------

if __name__ == "__main__":
    
    # Parse arguments
    opts = parse_args(sys.argv)
    
    # Read in the RH data.
    if ".yaml" in opts["trueRH-file"]:
        with open(opts["trueRH-file"], "r") as f:
            print("yaml parse begin")
            trueData = yaml.load(f, Loader=yaml.CBaseLoader)
            print("yaml parse complete")
        trueRH = np.array([trueData[t][opts["node"]][opts["dof"]] for t in trueData])
        print("trueRH from yaml", trueRH)
    else:
        trueRH = np.loadtxt(opts["trueRH-file"])
    testRH = np.loadtxt(opts["testRH-file"])
    
    # Output the difference or error metric.
    func_dict[opts["metric"]](trueRH, testRH)
    
    # If accel RH (as opposed to disp or vel), generate husid plot and restrict
    # time window to significant duration portion of the record.
    if "AA" in opts["trueRH-file"] or "acc" in opts["trueRH-file"]:
        window = husid(trueRH, opts["plothusid"], opts["dt"], lb=0.005, ub=0.995)
        if opts["dt"] is not None and opts["plothusid"]:
            print("time window containing significant duration of Arias intensity (s)", opts["dt"]*window[0], ",", opts["dt"]*window[1])
        elif opts["plothusid"]:
            print("time window containing significant duration of Arias intensity (timestep)", window)
    else:
        window = None
    
    # Generate RH comparison plot
    if opts["plot"]: 
        plot(trueRH, testRH, window=window, dt=opts["dt"])
