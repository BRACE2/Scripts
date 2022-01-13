#!/bin/env python
#!/bin/env -S ipython --

# >**Arpit Nema**, **Chrystal Chern**, and **Claudio Perez**
# 
#
# This script plots the geometry of a structural
# model given a SAM JSON file. The SAM JSON structure
# was developed by the NHERI SimCenter.
#
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
usage: {NAME} <sam-file>
       {NAME} [options] <sam-file>
       {NAME} [options] <sam-file> <res-file>

Generate a plot of a structural model.

Positional Arguments:
    <sam-file>                     JSON file defining the structural model.
    <res-file>                     JSON or YAML file defining a structural
                                   response.

Options:
    -s, --scale  <scale>           Set displacement scale factor.
    -d, --displ  <node>:<dof>...   Apply a unit displacement at node with tag
                                   <node> in direction <dof>.
    -V, --view   {{elev|plan|sect}}  Set camera view.
    -p           <plot-option>     Specify plotting option.
        --vert   <vertical-axis>   Specify vertical axis.

    -o, --write  <out-file>        Save plot to <out-file>.
    -h, --help                     Print this message and exit.

    -T, --tcl    {{sam|res}}
"""

EXAMPLES="""
Examples:
        $ {NAME} sam.json

    Plot displaced structure with unit translation at nodes
    5, 3 and 2 in direction 2 at scale of 100:

        $ {NAME} -d 5:2,3:2,2:2 -s100 --vert 2 sam.json
"""

# The following Tcl script can be used to create a results
# file

EIG_SCRIPT = """
for {set m 1} {$m <= 3} {incr m} {
  puts "$m:"
  foreach n [getNodeTags] {
    puts "  $n: \[[join [nodeEigenvector $n $m] {, }]\]";
  }
}
"""

# The following Python packages are required by this script:

REQUIREMENTS = """
pyyaml
scipy
numpy
matplotlib
"""

import sys
try:
    import yaml
    import numpy as np
    Array = np.ndarray
    from scipy.linalg import block_diag
except:
    yaml = None
    Array = list
NDM=3 # this script currently assumes ndm=3

# Data shaping / Misc.
#----------------------------------------------------

# The following functions are used for reshaping data
# and carrying out other miscellaneous operations.

def wireframe(sam:dict)->dict:
    """
    Process OpenSees JSON output and return dict with the form:

        {<elem tag>: {"crd": [<coordinates>], ...}}
    """
    geom  = sam["geometry"]
    coord = np.array([n["crd"] for n in geom["nodes"]])
    nodes = {n["name"]: n for n in geom["nodes"]}
    trsfm = {t["name"]: t for t in sam["properties"]["crdTransformations"]}
    elems =  {
      e["name"]: dict(
        **e, 
        crd=np.array([nodes[n]["crd"] for n in e["nodes"]]),
        trsfm=trsfm[e["crdTransformation"]] if "crdTransformation" in e else None
      ) for e in geom["elements"]
    }
    return dict(nodes=nodes, elems=elems, coord=coord)

def read_model(filename:str)->dict:
    import json
    with open(filename,"r") as f:
        return wireframe(json.load(f)["StructuralAnalysisModel"])

# Kinematics
#----------------------------------------------------

# The following functions implement various kinematic
# relations for standard frame models.

# Helper functions for extracting rotations in planes
elev_dofs = lambda u: u[[1,2]]
plan_dofs = lambda u: u[[3,4]]

def get_dof_num(dof:str, axes:list):
    try: return int(dof)
    except: return {
            "long": axes[0],
            "vert": axes[2],
            "tran": axes[1],
            "sect": axes[0]+3,
            "plan": axes[2]+3,
            "elev": axes[1]+3
    }[dof]

def elastic_curve(x: Array, v: Array, L:float)->Array:
    "compute points along Euler's elastica"
    vi, vj = v
    xi = x/L                        # local coordinates
    N1 = 1.-3.*xi**2+2.*xi**3
    N2 = L*(xi-2.*xi**2+xi**3)
    N3 = 3.*xi**2-2*xi**3
    N4 = L*(xi**3-xi**2)
    y = np.array(vi*N2+vj*N4)
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


def rotation(xyz: Array, vert=(0,0,-1))->Array:
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
        coord: Array,
        displ: Array,  #: Displacements
        vect=None,         #: Element orientation vector
        glob:bool=True,    #: Transform to global coordinates
    )->Array:
    n = 40
    #          (---ndm---)
    rep = 4 if len(coord[0])==3 else 2
    Q = rotation(coord, vect)
    L = np.linalg.norm(coord[1] - coord[0])
    v = linear_deformations(block_diag(*[Q]*rep)@displ, L)
    Lnew = L+v[0,0]
    xaxis = np.linspace(0.0, Lnew, n)

    plan_curve = elastic_curve(xaxis, plan_dofs(v), Lnew)
    elev_curve = elastic_curve(xaxis, elev_dofs(v), Lnew)

    #dy,dz = Q[1:,1:]@np.linspace(displ[1:3], displ[7:9], n).T
    dx,dy,dz = Q@np.linspace(displ[:3], displ[6:9], n).T
    local_curve = np.stack([xaxis+displ[0], plan_curve+dy, elev_curve+dz])

    if glob:
        global_curve = Q.T@local_curve + coord[0][None,:].T

    return global_curve



# Plotting
#----------------------------------------------------

VIEWS = { # pre-defined plot views
    "plan":    dict(azim= 0, elev=90),
    "sect":    dict(azim= 0, elev= 0),
    "elev":    dict(azim=90, elev= 0),
    "iso":     dict(azim=45, elev=35)
}

def new_3d_axis():
    import matplotlib.pyplot as plt
    _, ax = plt.subplots(1, 1, subplot_kw={"projection": "3d"})
    ax.set_autoscale_on(True)
    ax.set_axis_off()
    return ax

def add_origin(ax,scale):
    xyz = np.zeros((3,3))
    uvw = np.eye(3)*scale
    ax.quiver(*xyz, *uvw, arrow_length_ratio=0.1, color="black")
    return ax

def set_axis_limits(ax):
    "Find and set axes limits"
    aspect = [ub - lb for lb, ub in (getattr(ax, f'get_{a}lim')() for a in 'xyz')]
    aspect = [max(a,max(aspect)/8) for a in aspect]
    ax.set_box_aspect(aspect)

def plot_skeletal(frame, axes=None):
    if axes is None: axes = [0,2,1]
    props = {"frame": {"color": "grey", "alpha": 0.6}}
    ax = new_3d_axis()
    for e in frame["elems"].values():
        x,y,z = np.array(e["crd"]).T[axes]
        ax.plot(x,y,z, **props["frame"])
    return ax


def plot_nodes(frame, displ=None, axes=None, ax=None):
    if axes is None: axes = [0,2,1]
    ax = ax or new_3d_axis()
    displ = displ or {}
    Zero = np.zeros(NDM)
    props = {"color": "black",
             "marker": "s",
             "s": 3,
             "zorder": 2}

    coord = frame["coord"]
    for i,n in enumerate(frame["nodes"].values()):
        coord[i,:] += displ.get(n["name"],Zero)[:3]

    x,y,z = coord.T[axes]
    ax.scatter(x, y, z, **props)
    return ax

def plot_displ(frame:dict, res:dict, ax=None, axes=None):
    props = {"color": "red"}
    ax = ax or new_3d_axis()
    if axes is None: axes = [0,2,1]
    for el in frame["elems"].values():
        # exclude zero-length elements
        if "zero" not in el["type"].lower():
            glob_displ = [
                u for n in el["nodes"] 
                #   extract displ from node, default to ndf zeros
                    for u in res.get(n,[0.0]*frame["nodes"][n]["ndf"])
            ]
            vect = el["trsfm"]["vecInLocXZPlane"]
            x,y,z = displaced_profile(el["crd"], glob_displ, vect=vect)[axes]
            ax.plot(x,y,z, **props)
    return ax

class PlotlyPlotter:
    def __init__(self,axes):
        self.axes = axes
    
    def plot(x,y,**opts):
        pass

    def plot_frames():
        pass

def plot_skeletal_plotly(model, axes=None):
    if axes is None: axes = [0,2,1]
    props = {"color": "#808080", "alpha": 0.6}
    ax = new_3d_axis()
    coords = np.zeros((len(model["elems"])*3,NDM))
    coords.fill(np.nan)
    for i,e in enumerate(model["elems"].values()):
        coords[3*i:3*i+2,:] = np.array(e["crd"])[:,axes]
    x,y,z = coords.T
    return {"mode": "lines", "x": x, "y": y, "z": z, "line": {"color":props["color"]}}
    

def plot_plotly(model, axes=None):
    import plotly.graph_objects as go
    fig = go.Figure(
            go.Scatter3d(**plot_skeletal_plotly(model,axes)),
            go.Layout(
                scene=dict(aspectmode='data',
                     xaxis_visible=False,
                     yaxis_visible=False,
                     zaxis_visible=False,
                     camera=dict(
                         projection={"type": "perspective"}
                     )
                ),
                showlegend=False
            )
        )
    return fig

# Script functions
#----------------------------------------------------

# Argument parsing is implemented manually because in
# the past I have found the standard library module
# `argparse` to be slow.

def parse_args(argv)->dict:
    # default options
    opts = {
        "mode":       1,
        "sam_file":   None,
        "res_file":   None,
        "write_file": None,
        "displ":      [],
        "scale":      100.0,
        "axes" :      [0,2,1],
        "displ_only": False,
        "plot_opts":  [],
        "view":       "iso"
    }
    args = iter(argv[1:])
    for arg in args:
        try:
            if arg == "--help" or arg == "-h":
                print(HELP)
                sys.exit()

            elif arg == "--install":
                try:
                    install_me(next(args))
                except StopIteration:
                    install_me()
                sys.exit()

            elif arg[:2] == "-d":
                node_dof = arg[2:] if len(arg) > 2 else next(args)
                for nd in node_dof.split(","):
                    node, dof = nd.split(":")
                    opts["displ"].append((int(node), get_dof_num(dof, opts["axes"])))

            elif arg[:2] == "-s":
                opts["scale"] = float(arg[2:]) if len(arg) > 2 else float(next(args))

            elif arg == "--scale":
                opts["scale"] = float(next(args))

            elif arg == "--vert":
                vert = int(next(args))
                tran = 2 if vert == 1 else 1
                opts["axes"][1:] = [tran, vert]

            elif arg[:2] == "-p":
                opts["plot_opts"].append(arg[2:] if len(arg) > 2 else next(args))
            
            elif arg[:2] == "-V":
                opts["view"] = arg[2:] if len(arg) > 2 else next(args)
            elif arg == "--view":
                opts["view"] = next(args)

            elif arg[:2] == "-m":
                opts["mode"] = int(arg[2]) if len(arg) > 2 else int(next(args))

            elif arg[:2] == "-o":
                opts["write_file"] = arg[2:] if len(arg) > 2 else next(args)

            elif arg == "--displ-only":
                opts["displ_only"] = True

            # Final check on options
            elif arg[0] == "-":
                print(f"ERROR - unknown option '{arg}'")
                sys.exit()

            elif not opts["sam_file"]:
                opts["sam_file"] = arg

            else:
                opts["res_file"] = arg

        except StopIteration:
            # `next(args)` was called without successive arg
            print(f"ERROR -- Argument '{arg}' expected value")
            print(f"         Run '{NAME} --help' for more information")
            sys.exit()
    return opts

def install_me(install_dir=None):
    import subprocess
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', *REQUIREMENTS.strip().split("\n")])

TESTS = [
    (False,"{NAME} sam.json -d 2:plan -s"),
    (True, "{NAME} sam.json -d 2:plan -s50"),
    (True, "{NAME} sam.json -d 2:3    -s50"),
    (True, "{NAME} sam.json -d 5:2,3:2,2:2 -s100 --vert 2 sam.json")
]

# Main script
#----------------------------------------------------
# The following code is only executed when the file
# is invoked as a script.

def render(sam_file, res_file=None, **opts):
    axes = opts["axes"]

    if sam_file is None:
        print("ERROR -- expected positional argument <sam-file>")
        sys.exit()

    model = read_model(sam_file)

    if not opts["displ_only"]:
        ax = plot_skeletal(model,axes=axes)
    else:
        ax = None
       
    if res_file is not None:
        with open(res_file, "r") as f:
            res = yaml.load(f,Loader=yaml.Loader)[opts["mode"]]
    else:
        res = {}
    for n,d in opts["displ"]:
        v = res.setdefault(n,[0.0]*model["nodes"][n]["ndf"])
        if d < 3: # translational dof
            v[d] += 1.0
        else:
            v[d] += 0.1

    # apply scale
    scale = opts["scale"]
    if scale != 1.0:
        for n in res.values():
            for i in range(len(n)):
                n[i] *= scale


    ax = plot_nodes(model, res, ax=ax, axes=axes)
    if res:
        plot_displ(model, res, axes=axes, ax=ax)

    # Handle plot formatting
    set_axis_limits(ax)
    ax.view_init(**VIEWS[opts["view"]])
    if "origin" in opts["plot_opts"]: add_origin(ax, scale)

    if opts["write_file"]:
    # write plot to file if file name provided
        if "html" in opts["write_file"]:
            fig = plot_plotly(model,axes)
            import plotly
            plotly.offline.plot(fig,
                    filename=opts["write_file"],
                    auto_open=False)
        else:
            ax.figure.savefig(opts["write_file"])
    else:
    # otherwise show in new window
        import matplotlib.pyplot as plt
        plt.show()
    return ax

if __name__ == "__main__":

    opts = parse_args(sys.argv)
    try:
        render(**opts)
    except Exception as e:
        print(e, file=sys.stderr)
        print(f"         Run '{NAME} --help' for more information")
        sys.exit()

#    axes = opts["axes"]
#
#    if opts["sam_file"] is None:
#        print("ERROR -- expected positional argument <sam-file>")
#        sys.exit()
#
#    model = read_model(opts["sam_file"])
#
#    if not opts["displ_only"]:
#        ax = plot_skeletal(model,axes=axes)
#    else:
#        ax = None
#       
#    if opts["res_file"] is not None:
#        with open(opts["res_file"], "r") as f:
#            res = yaml.load(f,Loader=yaml.Loader)[opts["mode"]]
#    else:
#        res = {}
#    for n,d in opts["displ"]:
#        v = res.setdefault(n,[0.0]*model["nodes"][n]["ndf"])
#        if d < 3: # translational dof
#            v[d] += 1.0
#        else:
#            v[d] += 0.1
#
#    # apply scale
#    scale = opts["scale"]
#    if scale != 1.0:
#        for n in res.values():
#            for i in range(len(n)):
#                n[i] *= scale
#
#
#    ax = plot_nodes(model, res, ax=ax, axes=axes)
#    if res:
#        plot_displ(model, res, axes=axes, ax=ax)
#
#    # Handle plot formatting
#    set_axis_limits(ax)
#    ax.view_init(**VIEWS[opts["view"]])
#    if "origin" in opts["plot_opts"]: add_origin(ax, scale)
#
#    if opts["write_file"]:
#    # write plot to file if file name provided
#        ax.figure.savefig(opts["write_file"])
#    else:
#    # otherwise show in new window
#        import matplotlib.pyplot as plt
#        plt.show()


