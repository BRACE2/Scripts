# Chrystal Chern cchern@berkeley.edu

import os, re, sys
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib import animation
from fiberRecorders import iter_elem_fibers, damage_states, read_sect_xml, fiber_strain

plt.style.use('brace2.mplstyle')

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
        "section_deformations": False,
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
        elif arg == "-sd":
            opts["section_deformations"] = True

        elif arg == "-sec":
            opts["sec"] = next(argi)

        elif arg == "-vmin":
            opts["vminset"] = next(argi)

        elif arg == "-vmax":
            opts["vmaxset"] = next(argi)

    return opts

def getSectionStrains(a, dsr, sec):
    recorder_data = read_sect_xml(a)
    intFrames = 1
    X = []
    Y = []
    X,Y,epsRaw = tuple(zip(*(
            (
                fib["coord"][0], 
                fib["coord"][1],
                 fiber_strain(recorder_data, elem["name"], sec, fib)
            ) for ds in ["dsr1", "dsr2"] 
        for elem, sec, fib in iter_elem_fibers(model, elems, [3], filt=regions[ds])
    )))
    eps = np.array([e.T for e in epsRaw])
    return X, Y, eps, intFrames, np.arange(eps.size[1])

def getStrains(a, dsr, sec):
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
        return None, None, None, None, None
    else:
        eps = np.zeros([len(X), len(epsRaw[0])])
        for i in range(len(X)):
            eps[i, :] = epsRaw[i].T
        return X, Y, eps, intFrames, times

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
            plt.figure(figsize=(6, 5))
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

def ultimatePt(X5, Y5, eps5, times5, X6, Y6, eps6, times6):
    for t in range(eps5.shape[1]):
        epst5 = eps5[:,t]
        epst6 = eps6[:,t]
        if any(epst5 <= -0.011)  or  any(epst6 >= 0.09):
            timeUlt = t
            print("\nthe ultimate point occurs at timepoint ", t, ".")
            iUltFibers5 = np.arange(len(X5))[epst5 <= -0.011]
            XUltFibers5 = np.array(X5)[iUltFibers5]
            YUltFibers5 = np.array(Y5)[iUltFibers5]
            coordsUltFibers5 = np.column_stack((XUltFibers5, YUltFibers5))
            epsUltFibers5 = epst5[iUltFibers5]
            iUltFibers6 = np.arange(len(X6))[epst6 >= 0.09]
            XUltFibers6 = np.array(X6)[iUltFibers6]
            YUltFibers6 = np.array(Y6)[iUltFibers6]
            coordsUltFibers6 = np.column_stack((XUltFibers6, YUltFibers6))
            epsUltFibers6 = epst6[iUltFibers6]
            ultSummary5 = pd.DataFrame(np.column_stack( (coordsUltFibers5, epsUltFibers5, [t]*len(coordsUltFibers5), ["concrete"]*len(coordsUltFibers5)) ), columns = ["Fiber X Coord", "Fiber Y Coord", "Strain", "Timepoint", "Material"])
            ultSummary6 = pd.DataFrame(np.column_stack( (coordsUltFibers6, epsUltFibers6, [t]*len(coordsUltFibers6), ["steel"]*len(coordsUltFibers6)) ), columns = ["Fiber X Coord", "Fiber Y Coord", "Strain", "Timepoint", "Material"])
            ultSummary = ultSummary5.append(ultSummary6)
            ultSummary.to_csv("UltimateSummary.csv", index=False)
            print("the coordinates and corresponding strains of failed fibers are:")
            print(ultSummary)
            plt.figure(figsize=(6, 5))
            plt.scatter(np.append(X5, X6), np.append(Y5, Y6), c=np.append(eps5[:, timeYield], eps6[:, timeYield]), vmin=-0.003, vmax=0.003)
            plt.colorbar(label="strain")
            plt.scatter(np.append(XUltFibers5, XUltFibers6), np.append(YUltFibers5, YUltFibers6), marker='x', color="r", label="Failed Fibers")
            plt.xlabel("Section Horizontal (X) Axis [inches]")
            plt.ylabel("Section Vertical (Y) Axis [inches]")
            plt.title("Strains at point of ultimate curvature (timepoint "+str(t)+")")
            plt.grid()
            plt.xlim([-50, 50])
            plt.ylim([-50, 50])
            plt.legend()
            plt.gcf().savefig("UltimatePoint.png")
            plt.show()
            return timeUlt, list(coordsUltFibers5).append(list(coordsUltFibers6)), list(epsUltFibers5).append(list(epsUltFibers6))

def get_DS(a, sec):
    dsrs = ["dsr6", "dsr5", "dsr4", "dsr3", "dsr2", "dsr1"]
    thresholds = [0.09, -0.011, -0.005, -0.005, -0.005, 1.32e-4]
    # Get timepoints at which each strain-based damage state occurs
    timeDS = np.zeros([len(dsrs), 1])
    for i in range(len(dsrs)):
        dsr = dsrs[i]
        th = thresholds[i]
        X, Y, eps = getStrains(a, [dsr], sec)[:3]
        for t in range(eps.shape[1]):
            epst = eps[:, t]
            if (th < 0 and any(epst <= th)) or (th > 0 and any(epst >= th)):
                timeDS[i] = t
                print("DS", 6-i, " occurs at timepoint ", t, ".")
                iDSFibers = [i for i in range(len(X)) if (0 > th >= epst[i]) or (0 < th <= epst[i])]
                XDSFibers = np.array(X)[iDSFibers]
                YDSFibers = np.array(Y)[iDSFibers]
                coordsDSFibers = np.column_stack((XDSFibers, YDSFibers))
                epsDSFibers = epst[iDSFibers]
                DSsummary = pd.DataFrame(np.column_stack((coordsDSFibers, epsDSFibers, [t] * len(coordsDSFibers))),
                                           columns=["Fiber X Coord", "Fiber Y Coord", "Strain", "Timepoint"])
                DSsummary.to_csv("DS"+str(6-i)+"Summary.csv", index=False)
                # print("the coordinates and corresponding strains of failed fibers at DS", 6-i, " are:")
                # print(DSsummary)
                plt.figure(figsize=(6, 5))
                plt.scatter(X, Y, c=epst, vmin=-0.01, vmax=0.01)
                plt.colorbar(label="strain")
                plt.scatter(XDSFibers, YDSFibers, marker='x', color="r", label="Failed Fibers at DS"+str(6-i))
                plt.xlabel("Section Horizontal (X) Axis [inches]")
                plt.ylabel("Section Vertical (Y) Axis [inches]")
                plt.title("Strains at point of DS"+str(6-i)+" (timepoint " + str(t) + ")")
                plt.grid()
                plt.xlim([-50, 50])
                plt.ylim([-50, 50])
                plt.legend()
                plt.gcf().savefig("DS"+str(6-i)+".png")
                plt.show()
                break

    for i in range(len(dsrs)):
        dsr = dsrs[i]
        th = thresholds[i]
        X, Y, eps = getStrains(a, [dsr], sec)[:3]
        # Get overall strain-based damage state (over all time points)
        if (th < 0 and np.any(eps <= th)) or (th > 0 and np.any(eps >= th)):
            print("The strain-based damage state is DS", 6-i)
            return dsr, timeDS


def getPushover(a, timeYield, timeUlt, timeDS):
    if a == "cyclic":
        return None
    else:
        dataDir = os.getcwd()+"\\"+currentDataFolder+"_"+a
        curv = -(np.loadtxt(dataDir+"\\eleDef1.txt"))[:,2]
        mom = -(np.loadtxt(dataDir+"\\eleForce1.txt"))[:,2]

        # Plot moment-curvature and yield and ultimate points
        plt.figure(figsize=(6, 5))
        plt.plot(np.append([0],curv), np.append([0],mom), zorder=0)
        curvYield = curv[timeYield]
        momYield = mom[timeYield]
        curvUlt = curv[timeUlt]
        momUlt = mom[timeUlt]
        print("\nYield curvature = ", curvYield, " rad/in, Yield moment = ", momYield, " kip-in")
        print("Ultimate curvature = ", curvUlt, " rad/in, Ultimate moment = ", momUlt, " kip-in")
        plt.scatter(curvYield, momYield, label="Yield Point ("+str(curvYield)+", "+str(momYield)+")", marker="o", color=[0.0, 0.0, 0.0])
        plt.scatter(curvUlt, momUlt, label="Ultimate Point ("+str(curvUlt)+", "+str(momUlt)+")", marker="s", color=[0.0, 0.0, 0.0])
        plt.xlabel("Curvature [rad/in]")
        plt.ylabel("Moment [kip-in]")
        plt.title("Pushover Curve - Moment Curvature Analysis")
        plt.legend()
        plt.grid()
        plt.tight_layout()
        plt.gcf().savefig("Pushover.png")
        plt.show()

        # Plot force-displacement with PDCA and strain-based DS
        disp = (np.loadtxt(dataDir+"\\nodeDisp.txt"))[:,0]
        force = -(np.loadtxt(dataDir+"\\nodeReaction.txt"))[:,0]
        DI = [8.73, 14.37, 21.889999999999997, 29.41, 38.81, 46.33]
        dispDI = []
        forceDI = []
        plt.figure(figsize=(6, 5))
        plt.plot(np.append([0],disp), np.append([0],force), zorder=0)
        plt.xlabel("Displacement [in]")
        plt.ylabel("Force [kip]")
        plt.title("Force Displacement Pushover Curve")
        for i in range(len(DI)):
            iDI = DI[i]
            diPoint = np.arange(len(disp))[disp >= iDI][0]
            dispDI.append(disp[diPoint])
            forceDI.append(force[diPoint])
            plt.scatter(disp[diPoint], force[diPoint], label="PDCA DS " + str(i+1), marker="o")
        for i in range(len(timeDS)):
            tDS = int(timeDS[-i-1])
            plt.scatter(disp[tDS], force[tDS], label="Strain-Based DS " + str(i+1), marker="x")
        plt.legend()
        plt.grid()
        plt.tight_layout()
        plt.gcf().savefig("PushoverFDwDS.png")
        plt.show()

def getCyclic(a):
    if a == "po":
        return None
    else:
        dataDir = os.getcwd()+"\\"+currentDataFolder+"_"+a
        disp = (np.loadtxt(dataDir+"\\nodeDisp.txt"))[:,0]
        force = -(np.loadtxt(dataDir+"\\nodeReaction.txt"))[:,0]

        # Plot force-displacement
        plt.figure(figsize=(6, 5))
        plt.plot(np.append([0],disp), np.append([0],force), zorder=0)
        plt.xlabel("Displacement [in]")
        plt.ylabel("Force [kip]")
        plt.title("Cyclic Curve")
        plt.xlim([0, max(disp)+5])
        plt.ylim([0, max(force)+50])
        plt.grid()
        plt.tight_layout()
        plt.gcf().savefig("Cyclic.png")
        plt.show()

def animate_heat_map(X, Y, eps, intFrames, vminset, vmaxset):
    if X is None:
        return None
    fig = plt.figure(figsize=(6, 5))
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
    if opts["section_deformations"]:
        X, Y, eps, intFrames, times = getSectionStrains(opts["a"], opts["dsr"], opts["sec"])
    else:
        X, Y, eps, intFrames, times = getStrains(opts["a"], opts["dsr"], opts["sec"])

    if opts["a"] == 'po':
        if opts["vminset"] is None:
            vminset = -0.02
        if opts["vmaxset"] is None:
            vmaxset = 0.04
    else:
        if opts["vminset"] is None:
            vminset = -0.001
        if opts["vmaxset"] is None:
            vmaxset = 0.001
    animate_heat_map(X, Y, eps, intFrames, vminset, vmaxset)

    if np.all(np.isin(["dsr1", "dsr2", "dsr3", "dsr4", "dsr5", "dsr6"], opts["dsr"])):
        print("Calculating Strain-Based Damage State...")
        dsr, timeDS = get_DS(opts["a"], opts["sec"])

    if np.isin("dsr6", opts["dsr"]) and np.isin("dsr5", opts["dsr"]) and opts["a"] == 'po':
        X6, Y6, eps6, intFrames6, times6 = getStrains(opts["a"], ["dsr6"], opts["sec"])
        timeYield, coordsYieldedFibers, epsYieldedFibers = yieldpt(X6, Y6, eps6, times6)

        X5, Y5, eps5, intFrames5, times5 = getStrains(opts["a"], ["dsr5"], opts["sec"])
        timeUlt, coordsUltFibers, epsUltFibers = ultimatePt(X5, Y5, eps5, times5, X6, Y6, eps6, times6)

        getPushover(opts["a"], timeYield, timeUlt, timeDS)

    if opts["a"] == 'cyclic':
        getCyclic(opts["a"])
