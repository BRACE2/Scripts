# Chrystal Chern cchern@berkeley.edu

import os, re, sys
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib import animation

# plt.style.use('brace2.mplstyle')

currentDataFolder = "data_hwd_col_4010"

def print_help():
    print("""
    fiberStrains.py -a -dsr dsr -sec sec ...

    a is analysis type and can be any one of: [po cyclic]
    dsr can be any set of: [dsr1 dsr2 dsr3 dsr4 dsr5 dsr6 all]
    sec can be any one of: [1 np], where np is integer representing last integration point.
    
    Options
    -vmin <float>
    -vmax <float>
    
    vmin and vmax are customized colorbar limits, if defaults must be adjusted.
""")

def parse_args(args) -> dict:
    opts = {
        "dsr": None,
        "sec": None,
        "vminset": None,
        "vmaxset": None
    }
    argi = iter(args)
    for arg in argi:
        if arg[:2] == "-h":
            print_help()
            sys.exit()

        if arg == "-a":
            opts["a"] = next(argi)

        if arg == "-dsr":
            opts["dsr"] =  [
                ds for ds in next(argi).split(",")
            ]

        elif arg == "-sec":
            opts["sec"] = next(argi)

        elif arg == "-vmin":
            opts["vminset"] = next(argi)

        elif arg == "-vmax":
            opts["vmaxset"] = next(argi)

    return opts

def getStrains(a, dsr, sec, vminset, vmaxset):
    dataDir = os.getcwd()+"\\"+currentDataFolder+"_"+a
    times = np.loadtxt(dataDir+"\\"+os.listdir(dataDir)[0])[:, 0]
    if a == "po":
        intFrames = 1
    if a == "cyclic":
        intFrames = 1
    X = []
    Y = []
    files = []
    epsRaw = []
    for ds in dsr:
        if ds == "dsr6":
            if vminset is None:
                vminset = -0.075
            if vmaxset is None:
                vmaxset = 0.075
        else:
            if vminset is None:
                vminset = -0.02
            if vmaxset is None:
                vmaxset = 0.04
        startSeq = ds + "_" + sec + "_"
        for file in os.listdir(dataDir):
            if file.startswith(startSeq):
                files.append(file)
                x = re.search(startSeq+'(.+?)_', file).group(1)
                y = re.search('([e\d.-]+?).txt', file).group(1)
                X.append(float(x))
                Y.append(float(y))
                epsRaw.append(np.loadtxt(dataDir+"\\"+file)[:, 2])
    if len(X) == 0:
        print("no fibers to plot! check DS definition and/or dsr option")
        return None, None, None, None, None, None, None
    else:
        eps = np.zeros([len(X), len(epsRaw[0])])
        for i in range(len(X)):
            eps[i, :] = epsRaw[i].T
        return X, Y, eps, intFrames, vminset, vmaxset, times

def yieldpt(X, Y, eps, times):
    for t in range(eps.shape[1]):
        epst = eps[:,t]
        if any(epst >= 0.002):
            timeYield = t
            print("\nthe yield point occurs at timepoint ", t, ".")
            iYieldedFibers = np.arange(len(X))[epst >= 0.002]
            XyieldedFibers = np.array(X)[iYieldedFibers]
            YyieldedFibers = np.array(Y)[iYieldedFibers]
            coordsYieldedFibers = np.column_stack((XyieldedFibers, YyieldedFibers))
            epsYieldedFibers = epst[iYieldedFibers]
            yieldSummary = pd.DataFrame(np.column_stack( (coordsYieldedFibers, epsYieldedFibers, [t]*len(coordsYieldedFibers)) ), columns = ["Fiber X Coord", "Fiber Y Coord", "Strain", "Timepoint"])
            yieldSummary.to_csv("YieldSummary.csv", index=False)
            print("the coordinates and corresponding strains of yielded fibers are:")
            print(yieldSummary)
            fig = plt.figure(figsize=(6, 5))
            plt.scatter(X, Y, c=eps[:, timeYield], vmin=-0.003, vmax=0.003)
            plt.colorbar(label="strain")
            plt.scatter(XyieldedFibers, YyieldedFibers, marker='x', color="r", label="Yielded Fibers")
            plt.xlabel("Section Horizontal (X) Axis [inches]")
            plt.ylabel("Section Vertical (Y) Axis [inches]")
            plt.title("Strains at point of yield (timepoint "+str(t)+")")
            plt.grid()
            plt.xlim([-50, 50])
            plt.ylim([-50, 50])
            plt.legend()
            plt.gcf().savefig("YieldPoint.png")
            plt.show()
            return timeYield, coordsYieldedFibers, epsYieldedFibers

def plasticHingePt(X5, Y5, eps5, times5, X6, Y6, eps6, times6):
    for t in range(eps5.shape[1]):
        epst5 = eps5[:,t]
        epst6 = eps6[:,t]
        if any(epst5 <= -0.011)  or  any(epst6 >= 0.09):
            timeHinge = t
            print("\nthe plastic hinge point occurs at timepoint ", t, ".")
            iHingeFibers5 = np.arange(len(X5))[epst5 <= -0.011]
            XhingeFibers5 = np.array(X5)[iHingeFibers5]
            YhingeFibers5 = np.array(Y5)[iHingeFibers5]
            coordsHingeFibers5 = np.column_stack((XhingeFibers5, YhingeFibers5))
            epsHingeFibers5 = epst5[iHingeFibers5]
            iHingeFibers6 = np.arange(len(X6))[epst6 >= 0.09]
            XhingeFibers6 = np.array(X6)[iHingeFibers6]
            YhingeFibers6 = np.array(Y6)[iHingeFibers6]
            coordsHingeFibers6 = np.column_stack((XhingeFibers6, YhingeFibers6))
            epsHingeFibers6 = epst6[iHingeFibers6]
            hingeSummary5 = pd.DataFrame(np.column_stack( (coordsHingeFibers5, epsHingeFibers5, [t]*len(coordsHingeFibers5), ["concrete"]*len(coordsHingeFibers5)) ), columns = ["Fiber X Coord", "Fiber Y Coord", "Strain", "Timepoint", "Material"])
            hingeSummary6 = pd.DataFrame(np.column_stack( (coordsHingeFibers6, epsHingeFibers6, [t]*len(coordsHingeFibers6), ["steel"]*len(coordsHingeFibers6)) ), columns = ["Fiber X Coord", "Fiber Y Coord", "Strain", "Timepoint", "Material"])
            hingeSummary = hingeSummary5.append(hingeSummary6)
            hingeSummary.to_csv("HingeSummary.csv", index=False)
            print("the coordinates and corresponding strains of hinged fibers are:")
            print(hingeSummary)
            fig = plt.figure(figsize=(6, 5))
            nx = ny = len(X)
            data = eps[:, 0]
            plt.scatter(np.append(X5, X6), np.append(Y5, Y6), c=np.append(eps5[:, timeYield], eps6[:, timeYield]), vmin=-0.003, vmax=0.003)
            plt.colorbar(label="strain")
            plt.scatter(np.append(XhingeFibers5, XhingeFibers6), np.append(YhingeFibers5, YhingeFibers6), marker='x', color="r", label="Hinged Fibers")
            plt.xlabel("Section Horizontal (X) Axis [inches]")
            plt.ylabel("Section Vertical (Y) Axis [inches]")
            plt.title("Strains at point of plastic hinging (timepoint "+str(t)+")")
            plt.grid()
            plt.xlim([-50, 50])
            plt.ylim([-50, 50])
            plt.legend()
            plt.gcf().savefig("HingePoint.png")
            plt.show()
            return timeHinge, list(coordsHingeFibers5).append(list(coordsHingeFibers6)), list(epsHingeFibers5).append(list(epsHingeFibers6))

def getPushover(a, timeYield, timeHinge):
    if a == "cyclic":
        return None
    else:
        dataDir = os.getcwd()+"\\"+currentDataFolder+"_"+a
        disp = (np.loadtxt(dataDir+"\\nodeDisp.txt"))[:,0]
        force = -(np.loadtxt(dataDir+"\\nodeReaction.txt"))[:,0]
        curv = -(np.loadtxt(dataDir+"\\eleDef1.txt"))[:,2]
        mom = -(np.loadtxt(dataDir+"\\eleForce1.txt"))[:,2]

        # Plot moment-curvature and calculate yield, hinge, and capacity displacement
        fig = plt.figure(figsize=(6, 5))
        plt.plot(np.append([0],curv), np.append([0],mom), zorder=0)
        curvYield = curv[timeYield] # phi_y (SMALL y =
        momYield = mom[timeYield]
        curvHinge = curv[timeHinge]
        momHinge = mom[timeHinge]
        print("\nYield curvature = ", curvYield, " rad/in, Yield moment = ", momYield, " kip-in")
        print("Hinge curvature = ", curvHinge, " rad/in, Hinge moment = ", momHinge, " kip-in")
        plt.scatter(curv[timeYield], mom[timeYield], label="Yield Point ("+str(curv[timeYield])+", "+str(mom[timeYield])+")", marker="o", color=[0.0, 0.0, 0.0])
        plt.scatter(curv[timeHinge], mom[timeHinge], label="Hinge Point ("+str(curv[timeHinge])+", "+str(mom[timeHinge])+")", marker="s", color=[0.0, 0.0, 0.0])
        plt.xlabel("Curvature [rad/in]")
        plt.ylabel("Moment [kip-in]")
        plt.title("Pushover Curve - Moment Curvature Analysis")
        plt.legend()
        plt.grid()
        plt.tight_layout()
        plt.gcf().savefig("PushoverMC.png")
        plt.show()

def animate_heat_map(X, Y, eps, intFrames, vminset, vmaxset):
    if X is None:
        return None
    fig = plt.figure(figsize=(6, 5))
    # nx = ny = len(X)
    data = eps[:, 0]
    plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
    plt.colorbar(label="strain")
    plt.grid()
    plt.xlim([-50,50])
    plt.ylim([-50,50])
    plt.xlabel("Section Horizontal Axis [inches]")
    plt.ylabel("Section Vertical Axis [inches]")
    plt.title("Animation of Strain Distribution Over Time")

    def init():
        plt.clf()
        plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
        plt.colorbar(label="strain")
        plt.grid()
        plt.xlim([-50,50])
        plt.ylim([-50,50])
        plt.xlabel("Section Horizontal Axis [inches]")
        plt.ylabel("Section Vertical Axis [inches]")
        plt.title("Animation of Strain Distribution Over Time")

    def animate(i):
        plt.clf()
        data = eps[:, i]
        plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
        plt.colorbar(label="strain")
        plt.grid()
        plt.xlim([-50,50])
        plt.ylim([-50,50])
        plt.xlabel("Section Horizontal Axis [inches]")
        plt.ylabel("Section Vertical Axis [inches]")
        plt.title("Animation of Strain Distribution Over Time")

    anim = animation.FuncAnimation(fig, animate, init_func=init, interval=intFrames, frames=eps.shape[1], repeat=True)
    plt.show()

if __name__ == "__main__":
    opts = parse_args(sys.argv[1:])
    X, Y, eps, intFrames, vminset, vmaxset, times = getStrains(opts["a"], opts["dsr"], opts["sec"], opts["vminset"], opts["vmaxset"])
    animate_heat_map(X, Y, eps, intFrames, vminset, vmaxset)

    if np.isin("dsr6", opts["dsr"]) and np.isin("dsr5", opts["dsr"]) and opts["a"] == 'po':
        X6, Y6, eps6, intFrames6, vminset6, vmaxset6, times6 = getStrains(opts["a"], ["dsr6"], opts["sec"], opts["vminset"], opts["vmaxset"])
        timeYield, coordsYieldedFibers, epsYieldedFibers = yieldpt(X6, Y6, eps6, times6)

        X5, Y5, eps5, intFrames5, vminset5, vmaxset5, times5 = getStrains(opts["a"], ["dsr5"], opts["sec"], opts["vminset"], opts["vmaxset"])
        timeHinge, coordsHingeFibers, epsHingeFibers = plasticHingePt(X5, Y5, eps5, times5, X6, Y6, eps6, times6)

        getPushover(opts["a"], timeYield, timeHinge)
    