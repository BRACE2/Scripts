#!/bin/env python

__version__ = "0.0.4"

# # Synopsis
#
# >`render.py [<options>] <model-file>`
#
# >**Arpit Nema**, **Chrystal Chern**, and **Claudio Perez**
# 
#
# This script plots the geometry of a structural
# model given a SAM JSON file. The SAM JSON structure
# was developed by the NHERI SimCenter.
#
#
# # Installation
#
# The simplest way to install this script is to run
# 
#     $ python render.py --install
#
# from a terminal that has python installed, in a
# directory containing the `render.py` file. This
# will install the following packages:


REQUIREMENTS = """
pyyaml
scipy
numpy
plotly
matplotlib
"""

# ## Matlab
# In order to install the Matlab bindings, open Matlab in a
# directory containing the files `render.py` and `render.m`,
# and run the following command in the Matlab interpreter:
#
#     render --install
#
# Once this process is complete, the command `render` can be
# called from Matlab, just as described below for the command
# line.
#
# # Usage
# This script can be used either as a module, or as a command
# line utility. When invoked from the command line on
# **Windows**, {NAME} should be `python -m render`. For example:
#
#     python -m render model.json --axes 2 --view elev
#
# The script may be invoked with the following options:

NAME = "skeletal.py"
HELP = f"""
usage: {NAME} <sam-file>
       {NAME} --setup ...
       {NAME} [options] <sam-file>
       {NAME} [options] <sam-file> <res-file>
       {NAME} --section <py-file>#<py-object>

Generate a plot of a structural model.

Positional Arguments:
  <sam-file>                     JSON file defining the structural model.
  <res-file>                     JSON or YAML file defining a structural
                                 response.

Options:
  DISPLACEMENTS
  -s, --scale  <scale>           Set displacement scale factor.
  -d, --disp   <node>:<dof>...   Apply a unit displacement at node with tag
                                 <node> in direction <dof>.
  VIEWING
  -V, --view   {{elev|plan|sect}}  Set camera view.
      --vert   <int>             Specify index of model's vertical coordinate
      --hide   <object>          Hide <object>; see '--show'.
      --show   <object>          Show <object>; accepts any of:
                                    {{origin|frames|frames.displ|nodes|nodes.displ|extrude}}

  MISC.
  -o, --save   <out-file>        Save plot to <out-file>.
  -c, --conf

      --install                  Install script dependencies.
      --setup                    Run setup operations.
      --script {{sam|res}}
      --version                  Print version and exit.
  -h, --help                     Print this message and exit.



  <dof>        {{long | tran | vert | sect | elev | plan}}
               {{  0  |   1  |   2  |   3  |   4  |   5 }}
  <object>     {{origin|frames|frames.displ|nodes|nodes.displ}}
"""

EXAMPLES="""
Examples:
    Plot the structural model defined in the file `sam.json`:
        $ {NAME} sam.json

    Plot displaced structure with unit translation at nodes
    5, 3 and 2 in direction 2 at scale of 100:

        $ {NAME} -d 5:2,3:2,2:2 -s100 --vert 2 sam.json
"""

# The remainder of this script is broken into the following sections:
#
# - Data shaping / Misc.
# - Kinematics
# - Plotting
# - Command line processing
#

# Defaults
#=========
# The following configuration options are available:

Config = lambda : {
  "show_objects": ["frames", "frames.displ", "nodes"],
  "mode_num"    : None,
  "hide_objects": ["origin"],
  "sam_file":     None,
  "res_file":     None,
  "write_file":   None,
  "displ":        defaultdict(list),
  "scale":        100.0,
  "vert":         2,
  "view":         "iso",
  "plotter":      "matplotlib",

  "camera": {
      "view": "iso",               # iso | plan| elev[ation] | sect[ion]
      "projection": "orthographic" # perspective | orthographic
  },

  "displacements": {"scale": 100, "color": "#660505"},

  "objects": {
      "origin": {"color": "black"},
      "frames" : {
          "displaced": {"color": "red", "npoints": 20}
      },
      "nodes": {
          "default": {"size": 3, "color": "#000000"},
          "displaced" : {},
          "fixed"  : {},
      },
  },
  "save_options": {
      # Options for when writing to an HTML file.
      "html": {
          "include_plotlyjs": True,
          "include_mathjax" : "cdn",
          "full_html"       : True
      }
  }
}

def _apply_config(conf, opts):
    for k,v in conf.items():
        if isinstance(v,dict):
            _apply_config(v, opts[k])
        else:
            opts[k] = v


# The following Tcl script can be used to create a results
# file

import sys, os
from collections import defaultdict

try:
    import yaml
    import numpy as np
    Array = np.ndarray
    FLOAT = np.float32
    from scipy.linalg import block_diag
except:
    # prevent undefined variables when run in install mode
    yaml = None
    Array = list
    FLOAT =  float

NDM=3 # this script currently assumes ndm=3

# Data shaping / Misc.
#----------------------------------------------------

# The following functions are used for reshaping data
# and carrying out other miscellaneous operations.

class RenderError(Exception): pass

def clean_model(sam:dict, shift: Array = None, rot=None)->dict:
    """
    Process OpenSees JSON output and return dict with the form:

        {<elem tag>: {"crd": [<coordinates>], ...}}
    """
    try:
        sam = sam["StructuralAnalysisModel"]
    except KeyError:
        pass

    R = np.eye(3) if rot is None else rot

    geom = sam.get("geometry", sam.get("assembly"))
    if shift is None:
        shift = np.zeros(3)
    else:
        shift = np.asarray(shift)

    coord = np.array([R@n.pop("crd") for n in geom["nodes"]], dtype=FLOAT) + shift
    nodes = {
            n["name"]: {**n, "crd": coord[i], "idx": i} 
                for i,n in enumerate(geom["nodes"])
    }

    try:
        trsfm = {t["name"]: t for t in sam["properties"]["crdTransformations"]}
    except KeyError:
        trsfm = {}

    elems =  {
      e["name"]: dict(
        **e, 
        crd=np.array([nodes[n]["crd"] for n in e["nodes"]], dtype=FLOAT),
        trsfm=trsfm[e["crdTransformation"]] 
            if "crdTransformation" in e and e["crdTransformation"] in trsfm else None
      ) for e in geom["elements"]
    }
    return dict(nodes=nodes, assembly=elems, coord=coord)


def read_displacements(res_file):
    from urllib.parse import urlparse
    res_path = urlparse(res_file)
    with open(res_path[2], "r") as f:
        res = yaml.load(f,Loader=yaml.Loader)
    if res_path[4]: # query parameters passed
        res = res[int(res_path[4].split("=")[-1])]
    return res

def read_model(filename:str, shift=None)->dict:
    import json
    try:
        with open(filename,"r") as f:
            sam = json.load(f)
    except TypeError:
        sam = json.load(filename)
    return sam



# Kinematics
#----------------------------------------------------

# The following functions implement various kinematic
# relations for standard frame models.

def elastic_curve(x: Array, v: Array, L:float)->Array:
    "compute points along Euler's elastica"
    if len(v) == 2: ui, uj, (vi, vj) = 0.0, 0.0, v
    else:  ui, vi, uj, vj = v
    xi = x/L                        # local coordinates
    N1 = 1.-3.*xi**2+2.*xi**3
    N2 = L*(xi-2.*xi**2+xi**3)
    N3 = 3.*xi**2-2*xi**3
    N4 = L*(xi**3-xi**2)
    y = ui*N1 + vi*N2 + uj*N3 + vj*N4
    return y.flatten()


def rotation(xyz: Array, vert=None)->Array:
    """Create a rotation matrix between local e and global E
    """
    if vert is None: vert = (0,0,1)
    dx = xyz[1] - xyz[0]
    L = np.linalg.norm(dx)
    e1 = dx/L
    v13 = np.atleast_1d(vert)
    v2 = -np.cross(e1,v13)
    norm_v2 = np.linalg.norm(v2)
    if norm_v2 < 1e-8:
        v2 = -np.cross(e1,np.array([*reversed(vert)]))
        norm_v2 = np.linalg.norm(v2)
    e2 = v2 / norm_v2
    v3 =  np.cross(e1,e2)
    e3 = v3 / np.linalg.norm(v3)
    R = np.stack([e1,e2,e3])
    return R

def displaced_profile(
        coord: Array,
        displ: Array,        #: Displacements
        vect : Array = None, #: Element orientation vector
        npoints:int = 10,
    )->Array:
    n = npoints
    #           (------ndm------)
    reps = 4 if len(coord[0])==3 else 2

    # 3x3 rotation to local system
    Q = rotation(coord, vect)
    # Local displacements
    u_local = block_diag(*[Q]*reps)@displ
    # Element length
    L = np.linalg.norm(coord[1] - coord[0])

    # longitudinal, transverse, vertical, section, elevation, plan
    li, ti, vi, si, ei, pi = u_local[:6]
    lj, tj, vj, sj, ej, pj = u_local[6:]

    Lnew = L + lj - li
    xaxis = np.linspace(0.0, Lnew, n)

    plan_curve = elastic_curve(xaxis, [ti, pi, tj, pj], Lnew)
    elev_curve = elastic_curve(xaxis, [vi,-ei, vj,-ej], Lnew)

    local_curve = np.stack([xaxis + li, plan_curve, elev_curve])

    return Q.T@local_curve + coord[0][None,:].T




VIEWS = { # pre-defined plot views
    "plan":    dict(azim=  0, elev= 90),
    "sect":    dict(azim=  0, elev=  0),
    "elev":    dict(azim=-90, elev=  0),
    "iso":     dict(azim= 45, elev= 35)
}

class SkeletalRenderer:
    def __init__(self, model, response=None, loc=None, vert=2, **kwds):
        self.ndm = 3
        ndf = 6

        if vert == 3:
            R = np.eye(3)
        else:
            R = np.array(((1,0, 0),
                          (0,0,-1),
                          (0,1, 0)))

        rep = self.ndm - 1
        self.dofs2plot = block_diag(*[R]*rep)

        self.model = clean_model(model, shift=loc, rot=R)

        self.response_layers = defaultdict(lambda : np.zeros((len(self.model["nodes"]), ndf)))


        config = Config()
        if "config" in kwds:
            _apply_config(kwds.pop("config"), config)
        _apply_config(kwds, config)
        self.config = config


        plotter = config.get("plotter")
        if plotter == "matplotlib":
            self.canvas = MatplotlibCanvas()
        elif plotter == "plotly":
            self.canvas = PlotlyCanvas()
        else:
            raise ValueError("Unknown plotter " + str(plotter))

        self.canvas.config = config

    def add_point_displacements(self, displ, scale=1.0, name=None):
        displ_array = self.response_layers[name]
        for i,n in enumerate(self.model["nodes"]):
            for dof in displ[n]:
                displ_array[i, dof] = 1.0

        displ_array[:,3:] *= scale/100
        displ_array[:,:3] *= scale
        return name
            
    
    def add_displacement_case(self, displ, name=None, scale=1.0):
        tol = 1e-14
        displ_array = self.response_layers[name]

        for i,n in enumerate(self.model["nodes"]):
            try:
                displ_array[i,:] = self.dofs2plot@displ[n]
            except KeyError:
                pass

        # apply cutoff
        displ_array[np.abs(displ_array) < tol] = 0.0
        # apply scale
        displ_array *= scale
        return name


    def add_displacements(self, res_file, scale=1.0, name=None):
        model = self.model

        if not isinstance(res_file, (dict, Array)):
            displ = read_displacements(res_file)
        else:
            displ = res_file

        # Test type of first item in dict; if dict of dicts,
        # its a collection of responses, otherwise, just a
        # single response
        if isinstance(next(iter(displ.values())), dict):
            if name is not None:
                yield self.add_displacement_case(displ[name], name=name, scale=scale)
            else:
                for k, v in displ.items():
                    yield self.add_displacement_case(v, name=k, scale=scale)
        else:
            yield self.add_displacement_case(displ, scale=scale)


    def label_nodes(self): ...



    def plot_origin(self, scale):
        xyz = np.zeros((3,3))
        uvw = np.eye(3)*scale
        self.canvas.plot_vectors(xyz, uvw)

    def plot_frame_axes(self): ...

    def plot_frame_names(self):
        coords = self._frame_coords.reshape(-1,4,3)[:,-3]

    def plot_chords(self, assembly, displ=None):
        frame = self.model
        nodes = self.model["nodes"]
        N = 10 if displ is not None else 2
        coords = np.zeros((len(frame["assembly"])*(N+1),self.ndm))
        coords.fill(np.nan)

        for i,el in enumerate(frame["assembly"].values()):
            coords[(N+1)*i:(N+1)*i+N,:] = np.linspace(*el["crd"], N)

        self.canvas.plot_lines(coords)

    def plot_extruded_frames(self):
        sections = {"name": ((+0.5, -2.0), 
                             (+0.5,  1.5),
                             (+2.0,  1.5),
                             (+2.0,  2.0),
                             (-2.0,  2.0), 
                             (-2.0,  1.5),
                             (-0.5,  1.5),
                             (-0.5, -2.0))}
        name = "name"
        nodes = self.model["nodes"]
        N = 2
        #N = 11 if displ is not None else 2

        coords = []
        triang = []
        I = 0
        for i,el in enumerate(self.model["assembly"].values()):
            sect = sections[name]
            ne = len(sect)
            X  = np.linspace(*el["crd"], N)
            R  = rotation(el["crd"], None)
            for j in range(N):
                for k,edge in enumerate(sect):
                    coords.append(X[j  , :] + 25*R.T@[0, *edge])
                    if j == 0:
                        continue

                    elif k < ne-1:
                        triang.extend([
                            [I+    ne*j + k, I+    ne*j + k + 1, I+ne*(j-1) + k],
                            [I+ne*j + k + 1, I+ne*(j-1) + k + 1, I+ne*(j-1) + k]
                        ])
                    else:
                        triang.extend([
                            [I+    ne*j + k,    I + ne*j , I+ne*(j-1) + k],
                            [      I + ne*j, I + ne*(j-1), I+ne*(j-1) + k]
                        ])

            I += N*ne

        x,y,z = zip(*coords)
        i,j,k = zip(*triang)
        self.canvas.data.append({
            #"name": label if label is not None else "",
            "type": "mesh3d",
            "x": x, "y": y, "z": z, "i": i, "j": j, "k": k,
            "hoverinfo":"skip",
            # "opacity": 0.65
        })

        show_edges = False
        if show_edges:
            coords = np.array(coords)
            tri_points = np.array([
                coords[i] for i in np.array(triang).reshape(-1)
            ])
            Xe, Ye, Ze = tri_points.T 
            self.canvas.data.append({
                "type": "scatter3d",
                "mode": "lines",
                "x": Xe, "y": Ye, "z": Ze,

                "hoverinfo":"skip",
                "opacity": 0.65,
            })



    def plot_displaced_assembly(self, assembly, displ=None, label=None):
        frame = self.model
        nodes = self.model["nodes"]
        N = 10 if displ is not None else 2
        coords = np.zeros((len(frame["assembly"])*(N+1),self.ndm))
        coords.fill(np.nan)

        for i,el in enumerate(frame["assembly"].values()):
            # exclude zero-length elements
            if "zero" not in el["type"].lower() and displ is not None:
                glob_displ = [
                    u for n in el["nodes"]
                        for u in displ[nodes[n]["idx"]]
                ]
                vect = None #np.array(el["trsfm"]["vecInLocXZPlane"])[axes]
                coords[(N+1)*i:(N+1)*i+N,:] = displaced_profile(el["crd"], glob_displ, vect=vect, npoints=N).T
            else:
                coords[(N+1)*i:(N+1)*i+N,:] = np.linspace(*el["crd"], N)

        self.canvas.plot_lines(coords, color="red", label=label)

    def plot_nodes(self, displ=None):
        coord = self.model["coord"]
        if displ is not None:
            coord = coord + displ[:, :self.ndm]
        self.canvas.plot_nodes(coord)


    def plot(self):
        if "frames" in self.config["show_objects"]:
            self.plot_chords(self.model["assembly"])
        if "nodes" in self.config["show_objects"]:
            self.plot_nodes()
        if "origin" in self.config["show_objects"]:
            self.plot_origin(self.config["scale"])

        for layer, displ in self.response_layers.items():
            self.plot_displaced_assembly(self.model["assembly"], displ=displ, label=layer)

        if "extrude" in self.config["show_objects"]:
            try:
                self.plot_extruded_frames()
            except AttributeError:
                pass

        self.canvas.build()
        return self

    def write(self, filename):
        self.canvas.write(filename)

class MatplotlibCanvas:
    def __init__(self, ax=None):
        if ax is None:
            import matplotlib.pyplot as plt
            _, ax = plt.subplots(1, 1, subplot_kw={"projection": "3d"})
            ax.set_autoscale_on(True)
            ax.set_axis_off()

        self.ax = ax

    def show(self):
        import matplotlib.pyplot as plt
        plt.show()

    def build(self):
        ax = self.ax
        opts = self.config
        aspect = [ub - lb for lb, ub in (getattr(ax, f'get_{a}lim')() for a in 'xyz')]
        aspect = [max(a,max(aspect)/8) for a in aspect]
        ax.set_box_aspect(aspect)
        ax.view_init(**VIEWS[opts["view"]])

        return ax

    def write(self, filename=None):
        self.ax.figure.savefig(self.config["write_file"])

    def plot_lines(self, coords, label=None, conf=None, color=None):
        props = conf or {"color": color or "grey", "alpha": 0.6, "linewidth": 0.5}
        self.ax.plot(*coords.T, **props)

    def plot_nodes(self, coords, label=None, conf=None):
        ax = self.ax
        props = {"color": "black",
                 "marker": "s",
                 "s": 2,
                 "zorder": 2
        }
        self.ax.scatter(*coords.T, **props)

    def plot_vectors(self, locs, vecs, **kwds):
        self.ax.quiver(*locs, *vecs, arrow_length_ratio=0.1, color="black")

    def plot_trisurf(self, xyz, ijk):
        ax.plot_trisurf(*xyz.T, triangles=ijk)
    


class PlotlyCanvas:
    def __init__(self, config=None):
        self.data = []
        self.config = config

    def show(self):
        self.fig.show(renderer="browser")

    def build(self):
        opts = self.config
        import plotly.graph_objects as go
        fig = go.Figure(dict(
                data=self.data,
                layout=go.Layout(
                  scene=dict(aspectmode='data',
                     xaxis_visible=False,
                     yaxis_visible=False,
                     zaxis_visible=False,
                     camera=dict(
                         projection={"type": opts["camera"]["projection"]}
                     )
                  ),
                  showlegend=True
                )
            ))
        self.fig = fig
        return self

    def write(self, filename=None):
        opts = self.config
        if "html" in filename:
            import plotly
            fig = self.fig
            html = plotly.io.to_html(fig, div_id=str(id(self)), **opts["save_options"]["html"])
            with open(opts["write_file"],"w+") as f:
                f.write(html)
        elif "json" in opts["write_file"]:
            with open(opts["write_file"],"w+") as f:
                self.fig.write_json(f)

    def make_hover_data(self, data, ln=None):
        if ln is None:
            items = np.array([d.values for d in data])
            keys = data[0].keys()
        else:
            items = np.array([list(data.values())]*ln)
            keys = data.keys()
        return {
            "hovertemplate": "<br>".join(f"{k}: %{{customdata[{v}]}}" for v,k in enumerate(keys)),
            "customdata": list(items),
        }


    def plot_nodes(self, coords, label = None, props=None):
        name = label or "nodes"
        x,y,z = coords.T
        keys  = ["tag",]
        # nodes = np.array(list(self.model["nodes"].keys()),dtype=FLOAT)[:,None]

        data = {
                "name": name,
                "x": x, "y": y, "z": z,
                "type": "scatter3d","mode": "markers",
                "hovertemplate": "<br>".join(f"{k}: %{{customdata[{v}]}}" for v,k in enumerate(keys)),
                # "customdata": list(nodes),
                "marker": {
                    "symbol": "square",
                    **self.config["objects"]["nodes"]["default"]
                },
                "showlegend": False
        }
        self.data.append(data)

    def plot_lines(self, coords, label=None, props=None, color=None):
        x,y,z = coords.T
        props = {"color": color or "#808080", "alpha": 0.6}
        data = {
            "name": label if label is not None else "",
            "type": "scatter3d",
            "mode": "lines",
            "x": x, "y": y, "z": z,
            "line": {"color": props["color"]},
            "hoverinfo":"skip"
        }
        self.data.append(data)

    def plot_vectors(self, locs, vecs, label=None, **kwds):
        x,y,z = locs
        u,v,w = vecs
        data = {
            "name": label if label is not None else "",
            "type": "cone",
            "x": x, "y": y, "z": z,
            "u": u, "v": v, "w": w,
            # "line": {"color": props["color"]},
            "hoverinfo": "skip"
        }
        self.data.append(data)



# Script functions
#----------------------------------------------------

# Argument parsing is implemented manually because in
# the past I have found the standard library module
# `argparse` to be slow.

AXES = dict(zip(("long","tran","vert","sect","elev", "plan"), range(6)))

def dof_index(dof:str):
    try: return int(dof)
    except: return AXES[dof]


def parse_args(argv)->dict:
    opts = Config()
    if os.path.exists(".render.yaml"):
        with open(".render.yaml", "r") as f:
            presets = yaml.load(f, Loader=yaml.Loader)

        _apply_config(presets,opts)

    args = iter(argv[1:])
    for arg in args:
        try:
            if arg == "--help" or arg == "-h":
                print(HELP)
                sys.exit()

            elif arg == "--gnu":
                opts["plotter"] = "gnu"
            elif arg == "--plotly":
                opts["plotter"] = "plotly"

            elif arg == "--install":
                try: install_me(next(args))
                # if no directory is provided, use default
                except StopIteration: install_me()
                sys.exit()

            elif arg == "--version":
                print(__version__)
                sys.exit()

            elif arg[:2] == "-d":
                node_dof = arg[2:] if len(arg) > 2 else next(args)
                for nd in node_dof.split(","):
                    node, dof = nd.split(":")
                    opts["displ"][int(node)].append(dof_index(dof))
            elif arg[:6] == "--disp":
                node_dof = next(args)
                for nd in node_dof.split(","):
                    node, dof = nd.split(":")
                    opts["displ"][int(node)].append(dof_index(dof))


            elif arg[:2] == "-s":
                opts["scale"] = float(arg[2:]) if len(arg) > 2 else float(next(args))
            elif arg == "--scale":
                opts["scale"] = float(next(args))

            elif arg == "--vert":
                opts["vert"] = int(next(args))

            elif arg == "--show":
                opts["show_objects"].extend(next(args).split(","))

            elif arg == "--hide":
                opts["show_objects"].pop(next(args))
            
            elif arg[:2] == "-V":
                opts["view"] = arg[2:] if len(arg) > 2 else next(args)
            elif arg == "--view":
                opts["view"] = next(args)

            elif arg[:2] == "-m":
                opts["mode_num"] = int(arg[2]) if len(arg) > 2 else int(next(args))

            elif arg[:2] == "-o":
                filename = arg[2:] if len(arg) > 2 else next(args)
                opts["write_file"] = filename
                if "html" in filename or "json" in filename:
                    opts["plotter"] = "plotly"


            # Final check on options
            elif arg[0] == "-" and len(arg) > 1:
                raise RenderError(f"ERROR - unknown option '{arg}'")

            elif not opts["sam_file"]:
                if arg == "-": arg = sys.stdin
                opts["sam_file"] = arg

            else:
                if arg == "-": arg = sys.stdin
                opts["res_file"] = arg

        except StopIteration:
            # `next(args)` was called in parse loop without successive arg
            raise RenderError(f"ERROR -- Argument '{arg}' expected value")

    return opts

def install_me(install_opt=None):
    import os
    import subprocess
    import textwrap
    if install_opt == "dependencies":
        subprocess.check_call([
            sys.executable, "-m", "pip", "install", *REQUIREMENTS.strip().split("\n")
        ])
        sys.exit()
    try:
        from setuptools import setup
    except ImportError:
        from distutils.core import setup

    sys.argv = sys.argv[:1] + ["develop", "--user"]
    print(sys.argv)

    setup(name="skeletal",
          version=__version__,
          description="",
          long_description=textwrap.indent(HELP),
          author="", 
          author_email="", 
          url="",
          py_modules=["skeletal"],
          scripts=["skeletal.py"],
          license="",
          install_requires=[*REQUIREMENTS.strip().split("\n")],
    )

TESTS = [
    (False,"{NAME} sam.json -d 2:plan -s"),
    (True, "{NAME} sam.json -d 2:plan -s50"),
    (True, "{NAME} sam.json -d 2:3    -s50"),
    (True, "{NAME} sam.json -d 5:2,3:2,2:2 -s100 --vert 2 sam.json")
]

def render(sam_file, res_file=None, **opts):
    # Configuration is determined by successively layering
    # from sources with the following priorities:
    #      defaults < file configs < kwds 

    config = Config()


    if sam_file is None:
        raise RenderError("ERROR -- expected positional argument <sam-file>")

    # Read and clean model
    if not isinstance(sam_file, dict):
        model = read_model(sam_file)
    else:
        model = sam_file

    if "RendererConfiguration" in model: 
        _apply_config(model["RendererConfiguration"], config)

    _apply_config(opts, config)

    renderer = SkeletalRenderer(model, **config)

    # Read and clean displacements 
    if res_file is not None:
        cases = renderer.add_displacements(res_file, scale=config["scale"], name=config["mode_num"])
        list(cases)

    elif config["displ"] is not None:
        cases = [renderer.add_point_displacements(config["displ"], scale=config["scale"])]

    renderer.plot()

    # write plot to file if file name provided
    if config["write_file"]:
        renderer.write(config["write_file"])

    else:
        renderer.canvas.show()

    return renderer




if __name__ == "__main__":
    config = parse_args(sys.argv)

    try:
        render(**config)
    except (FileNotFoundError,RenderError) as e:
        # Catch expected errors to avoid printing an ugly/unnecessary
        # stack trace.
        print(e, file=sys.stderr)
        print(f"         Run '{NAME} --help' for more information", file=sys.stderr)
        sys.exit()

