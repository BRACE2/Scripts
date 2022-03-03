import os
import re
import numpy as np
import matplotlib as mpl
from matplotlib import pyplot as plt
from matplotlib import animation

X = []
Y = []
files = []
epsRaw = []
for file in os.listdir(os.getcwd()):
    if file.startswith("allFibers"):
        files.append(file)
        x = re.search('allFibers_(.+?)_', file).group(1)
        y = re.search('([\d.-]+?).txt', file).group(1)
        X.append(float(x))
        Y.append(float(y))
        print(np.loadtxt(file)[:, 1])
        epsRaw.append(np.loadtxt(file)[:, 1])

eps = np.zeros([len(X), len(epsRaw[0])])
for i in range(len(X)):
    file = files[i]
    eps[i, :] = epsRaw[i].T


def animate_heat_map():
    vminset = -0.1
    vmaxset = 0.005
    fig = plt.figure(figsize=(6, 5))
    nx = ny = len(X)
    data = eps[:, 0]
    ax = plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
    plt.colorbar()

    def init():
        plt.clf()
        ax = plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
        plt.colorbar()

    def animate(i):
        plt.clf()
        data = eps[:, i]
        ax = plt.scatter(X, Y, c=data, vmin=vminset, vmax=vmaxset)
        plt.colorbar()

    anim = animation.FuncAnimation(fig, animate, init_func=init, interval=5)
    plt.show()


if __name__ == "__main__":
    animate_heat_map()