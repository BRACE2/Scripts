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
  -n, --node                    node to compare. default 402.
  -d, --dof                     dof to compare. default 1 (longitudinal)
  -t, --dt                      timestep. default None (1)
  -p, --plot                    generate RH comparison plot. default False.
  -s, --plothusid               generate husid plot. default False.
  -h, --help                    Print this message and exit.
"""

EXAMPLES="""
Examples:
    Obtain the relative difference between the RH in `trueRH.txt` and `testRH.txt`:
        $ {NAME} Diff trueRH.txt testRH.txt
    Obtain the RMS difference between the RH in `trueRH.txt` and `testRH.txt` at
    node 405, dof 2, and generate RH comparison plot
        $ {NAME} -p -n 405 -d 2 RMS trueRH.txt testRH.txt
"""


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
            opts["node"] = int(next(args))
        elif arg in ["--dof","-d"]:
            opts["dof"] = int(next(args))
        elif arg in ["--dt","-t"]:
            opts["dt"] = float(next(args))
        elif arg in ["--plot","-p"]:
            opts["plot"] = True
        elif arg in ["--plothusid","-s"]:
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
    print("N", N)
    am = np.median(abs(trueRH)) # median absolute true response value
    print("am", am)
    print("(testRH - trueRH)**2", (testRH - trueRH)**2)
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
    METRICS[0] : (Diff, "difference of response at each time step"),
    METRICS[1] : (RMS, "unitless root-mean-squared difference (RMS)"),
    METRICS[2] : (AMX, "percent absolute maximum difference (AMX)"),
    METRICS[3] : (CAV, "percent CAV difference (CAV)")
}

# Plotting functions
def husid(accRH, plothusid, dt, lb=0.05, ub=0.95):
    ai = np.tril(np.ones(len(accRH)))@accRH**2
    husid = ai/ai[-1]
    ilb = next(x for x, val in enumerate(husid) if val > lb)
    iub = next(x for x, val in enumerate(husid) if val > ub)
    if plothusid:
        fig, ax = plt.subplots()
        if dt is not None:
            print("duration between ", f"{100*lb}%", " and ", f"{100*ub}%", " (s): ", dt*(iub-ilb))
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

def plot(trueRH, testRH, dt):
    fig, ax = plt.subplots()
    if dt is not None: # Given dt, we can set the x axis to actual time rather than timestep.
        tScale = dt
        xlabel = "time (s)"
    else: # Without dt, x axis can only show timestep.
        tScale = 1
        xlabel = "timestep"
    ax.plot(tScale*np.arange(len(trueRH)), trueRH, linewidth=0.75, label="true RH")
    ax.plot(tScale*np.arange(len(testRH)), testRH, ":", linewidth=1.5, label="test RH")
    ax.set_xlabel(xlabel)
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
            trueData = yaml.load(f, Loader=yaml.CSafeLoader)
        trueRH = np.array([trueData[t][opts["node"]][opts["dof"]-1] for t in trueData])
    else:
        trueRH = np.loadtxt(opts["trueRH-file"])
    trueRH = trueRH - [trueRH[0]]*len(trueRH)
    testRH = np.loadtxt(opts["testRH-file"])
    testRH = testRH - [testRH[0]]*len(testRH)
    
    # If accel RH (as opposed to disp or vel), generate husid plot and restrict
    # time window to significant duration portion of the record.
    # keep track of response type as a string
    if "AA" in opts["trueRH-file"] or "acc" in opts["trueRH-file"]:
        window = husid(trueRH, opts["plothusid"], opts["dt"], lb=0.005, ub=0.995)
        if opts["plothusid"]:
            if opts["dt"] is not None:
                print("time window containing significant duration of Arias intensity (s)", opts["dt"]*window[0], ",", opts["dt"]*window[1])
            else:
                print("time window containing significant duration of Arias intensity (timestep)", window)
    else:
        window = None
    
    # Print message about what we're comparing
    print("Comparing " + opts["trueRH-file"] + " and " + opts["testRH-file"])
    
    # Determine the portion of the RHs to compare
    if window is not None:
        trueRH = trueRH[window[0]:window[1]]
        testRH = testRH[window[0]:window[1]]

    # Output the difference or error metric.
    print(func_dict[opts["metric"]][1] + ":")
    func_dict[opts["metric"]][0](trueRH, testRH)
    
    # Generate RH comparison plot
    if opts["plot"]: 
        plot(trueRH, testRH, opts["dt"])
