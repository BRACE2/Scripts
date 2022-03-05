# Chrystal Chern cchern@berkeley.edu

import os, re, sys
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation

def print_help():
    print("""
    fiberStrains.py -a -dsr dsr -sec sec ...

    a is analysis type and can be any one of: [po cyclic]
    dsr can be any one of: [dsr1 dsr2 dsr3 dsr4 dsr5 dsr6 all]
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
            opts["dsr"] = next(argi)

        elif arg == "-sec":
            opts["sec"] = next(argi)

        elif arg == "-vmin":
            opts["vminset"] = next(argi)

        elif arg == "-vmax":
            opts["vmaxset"] = next(argi)

    return opts

def getStrains(a, dsr, sec, vminset, vmaxset):
    if a == "po":
        intFrames = 10
    if a == "cyclic":
        intFrames = 1
    if dsr == "dsr6":
        if vminset is None:
            vminset = -30.0
        if vmaxset is None:
            vmaxset = 30.0
    else:
        if vminset is None:
            vminset = -7.0
        if vmaxset is None:
            vmaxset = 1.0
    startSeq = dsr + "_" + sec + "_"
    X = []
    Y = []
    files = []
    epsRaw = []
    dataDir = os.getcwd()+"\\data_hwd_col_4010_"+a
    for file in os.listdir(dataDir):
        if file.startswith(startSeq):
            files.append(file)
            x = re.search(startSeq+'(.+?)_', file).group(1)
            y = re.search('([e\d.-]+?).txt', file).group(1)
            X.append(float(x))
            Y.append(float(y))
            epsRaw.append(np.loadtxt(dataDir+"\\"+file)[:, 1])
    if len(X) == 0:
        print("no fibers to plot! check DS definition and/or dsr option")
        return None, None, None, None, None, None
    else:
        eps = np.zeros([len(X), len(epsRaw[0])])
        for i in range(len(X)):
            file = files[i]
            eps[i, :] = epsRaw[i].T
        return X, Y, eps, intFrames, vminset, vmaxset


def animate_heat_map(X, Y, eps, intFrames, vminset, vmaxset):
    if X is None:
        return None
    fig = plt.figure(figsize=(6, 5))
    nx = ny = len(X)
    data = eps[:, 0]
    ax = plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
    plt.colorbar()
    plt.grid()
    plt.xlim([-50,50])
    plt.ylim([-50,50])

    def init():
        plt.clf()
        ax = plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
        plt.colorbar()
        plt.grid()
        plt.xlim([-50,50])
        plt.ylim([-50,50])

    def animate(i):
        plt.clf()
        data = eps[:, i]
        plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
        plt.colorbar()
        plt.grid()
        plt.xlim([-50,50])
        plt.ylim([-50,50])

    anim = animation.FuncAnimation(fig, animate, init_func=init, interval=intFrames, frames=eps.shape[1], repeat=True)
    plt.show()


if __name__ == "__main__":
    opts = parse_args(sys.argv[1:])
    X, Y, eps, intFrames, vminset, vmaxset = getStrains(opts["a"], opts["dsr"], opts["sec"], opts["vminset"], opts["vmaxset"])
    animate_heat_map(X, Y, eps, intFrames, vminset, vmaxset)