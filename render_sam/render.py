#!/bin/env -S ipython --
# This script plots the geometry of a structural
# model given a SAM JSON file. The SAM JSON structure
# was developed by the NHERI SimCenter.
#
# This script is broken into the following sections:
#
# - Data shaping / Misc.
# - Kinematics
# - Plotting
# - Script functions
# - Main script

# The script may be invoked from the command line as follows:

NAME = "elastica.py"
HELP = f"""
usage: {NAME} [OPTIONS] SAM_FILE
       {NAME} [OPTIONS] SAM_FILE RES_FILE

Positional Arguments:

    SAM_FILE               JSON file defining the structural model.

    RES_FILE               JSON or YAML file defining a structural response.

Options
    -h/--help              Print this message and exit.
    -o/--write FILE        Save plot to FILE.

    -C/--coord [L,T,]V     Define global coordinate system.
    -d/--displ NODE:DOF    Apply a unit displacement at node with tag NODE
                           in direction DOF

"""

# The following Python packages are required by this script:

REQUIREMENTS = """
scipy
numpy
matplotlib
"""

import sys
import numpy as np
from scipy.linalg import block_diag
import matplotlib.pyplot as plt

# Data shaping / Misc.
#----------------------------------------------------

# The following functions are used for reshaping data
# and carrying out other miscellaneous operations.

def wireframe(sam:dict)->dict:
    """
    return dict with the form:
        {<elem tag>: {"crd": [<coordinates>], ...}}
    """
    geom = sam["geometry"]
    trsfm = {t["name"]: t for t in sam["properties"]["crdTransformations"]}
    nodes = {n["name"]: n for n in geom["nodes"]}
    elems =  {
      e["name"]: dict(
        **e, 
        crd=np.array([nodes[n]["crd"] for n in e["nodes"]]),
        trsfm=trsfm[e["crdTransformation"]] if "crdTransformation" in e else None
      ) for e in geom["elements"]
    }
    return dict(nodes=nodes, elems=elems)

# Kinematics
#----------------------------------------------------

# The following functions implement various kinematic
# relations for standard frame models.

# Helper functions for extracting rotations in planes
elev_dofs = lambda u: u[[1,2]]
plan_dofs = lambda u: u[[3,4]]

def elastic_curve(x, v, L, scale=1.0)->np.ndarray:
    "compute points along Euler's elastica"
    vi, vj = v
    xi = x/L                        # local coordinates
    N1 = 1.-3*xi**2+2*xi**3
    N2 = L*(xi-2*xi**2+xi**3)
    N3 = 3.*xi**2-2*xi**3
    N4 = L*(xi**3-xi**2)
    y = np.array(vi*N2+vj*N4)*scale
    return y.flatten()

def linear_deformations(u,L):
    "compute local frame deformations assuming small displacements"
    xi, yi, zi, si, ei, pi = range(6)    # Define variables to aid
    xj, yj, zj, sj, ej, pj = range(6,12) # reading array indices.

    elev_chord = (u[zj]-u[zi]) / L       # Chord rotations
    plan_chord = (u[yj]-u[yi]) / L
    return np.array([
        [u[xj] - u[xi]],                 # xi
        [u[ei] - elev_chord],            # vi_elev
        [u[ej] - elev_chord],            # vj_elev

        [u[pi] - plan_chord],
        [u[pj] - plan_chord],
        [u[sj] - u[si]],
    ])


def rotation(xyz:np.ndarray, vert=(0,0,-1))->np.ndarray:
    "Create a rotation matrix between local e and global E"
    dx = xyz[1] - xyz[0]
    L = np.linalg.norm(dx)
    e1 = dx/L
    v13 = np.atleast_1d(vert)
    v2 = -np.cross(e1,v13)
    e2 = v2 / np.linalg.norm(v2)
    v3 =  np.cross(e1,e2)
    e3 = v3 / np.linalg.norm(v3)
    return np.stack([e1,e2,e3])


def displaced_profile(
        coord: np.ndarray,
        displ:np.ndarray,  #: Displacements
        vect=None,         #: Element orientation vector
        scale:float = 1.0, #: Scale factor
        glob:bool=True,    #: Transform to global coordinates
    )->np.ndarray:
    n = 40
    #          (---ndm---)
    rep = 4 if len(coord[0])==3 else 2
    Q = rotation(coord, vect)
    L = np.linalg.norm(coord[1] - coord[0])
    v = linear_deformations(block_diag(*[Q]*rep)@displ, L)
    xaxis = np.linspace(0.0, L, n)

    plan_curve = elastic_curve(xaxis, plan_dofs(v), L, scale=scale)
    elev_curve = elastic_curve(xaxis, elev_dofs(v), L, scale=scale)

    dy,dz = Q[1:,1:]@np.linspace(displ[1:3], displ[7:9], n).T
    local_curve = np.stack([xaxis, plan_curve+dy, elev_curve+dz])

    if glob:
        global_curve = Q.T@local_curve + coord[0][None,:].T

    return global_curve



# Plotting
#----------------------------------------------------

def new_3d_axis():
    _, ax = plt.subplots(1, 1, subplot_kw={"projection": "3d"})
    ax.set_autoscale_on(True)
    ax.set_axis_off()
    return ax

def set_axis(ax):
    # Make axes limits 
    aspect = [ub - lb for lb, ub in (getattr(ax, f'get_{a}lim')() for a in 'xyz')]
    aspect = [max(a,max(aspect)/8) for a in aspect]
    ax.set_box_aspect(aspect)

def plot(frame):
    props = {"frame": {"color": "grey", "alpha": 0.6}}
    ax = new_3d_axis()
    for e in frame["elems"].values():
        x,y,z = np.array(e["crd"]).T
        ax.plot(x,z,y, **props["frame"])
    return ax


def plot_displ(frame, res, scale=1.0, ax=None):
    props = {"color": "red"}
    for el in frame["elems"].values():
        if "zero" not in el["type"].lower():
            glob_displ = [
                u for n in el["nodes"] 
                #   extract displ from node, default to ndf zeros
                    for u in res.get(n,[0.0]*frame["nodes"][n]["ndf"])
            ]
            vect = el["trsfm"]["vecInLocXZPlane"]
            x,y,z = displaced_profile(el["crd"], glob_displ, scale=scale, vect=vect)
            ax.plot(x,z,y, **props)
    return ax


# Script functions
#----------------------------------------------------


def parse_args(argv)->dict:
    opts = {
        "mode": 1,
        "sam_file":   None,
        "res_file":   None,
        "write_file": None,
        "displ": [],
    }
    args = iter(argv[1:])
    for arg in iter(args):
        if arg == "--help" or arg == "-h":
            print(HELP) is None and sys.exit()
        elif arg == "--install":
            pass
        elif arg[:2] == "-d":
            node_dof = arg[2:] if len(arg) > 2 else next(args)
            for nd in node_dof.split(","):
                opts["displ"].append(tuple(map(int,nd.split(":"))))
            print(opts["displ"])
        elif arg[:2] == "-m":
            opts["mode"] = int(arg[2]) if len(arg) > 2 else int(next(args))
        elif arg[:2] == "-o":
            opts["write_file"] = arg[2:] if len(arg) > 2 else next(args)
        elif not opts["sam_file"]:
            opts["sam_file"] = arg
        else:
            opts["res_file"] = arg
    return opts

# Main script
#----------------------------------------------------

if __name__ == "__main__":
    import json, yaml
    opts = parse_args(sys.argv)

    with open(opts["sam_file"], "r") as f:
        frm = wireframe(json.load(f)["StructuralAnalysisModel"])

    ax = plot(frm)
    if opts["res_file"] is not None:
        with open(opts["res_file"], "r") as f:
            res = yaml.load(f,Loader=yaml.Loader)[opts["mode"]]
    else:
        res = {}
    for n,d in opts["displ"]:
        v = res.setdefault(n,[0.0]*frm["nodes"][n]["ndf"])
        v[d] += 1.0

    if res:
        plot_displ(frm, res, ax=ax)
    print(res)

    set_axis(ax)

    import matplotlib.pyplot as plt
    plt.show()

