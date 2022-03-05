import json, sys, fnmatch
import numpy as np
from opensees import patch, section
from opensees.section import ConfinedOctagon as Octagon

# --8<--------------------------------------------------------
def damage_states(Dcol):
    cover = 2.0
    Rcol = Dcol/2
    coverl = cover + Rcol*(1-np.cos(np.pi/8))
    return {
        "dsr1" : {
            "regions": [
                 # external radius    internal radius
                Octagon(Rcol,         Rcol-1e-14)
            ]
        },
        "dsr2" : {
            "regions": [
                Octagon(Rcol,         Rcol-coverl/4)
            ]
        },
        "dsr3" : {
            "regions": [
                Octagon(Rcol-coverl/2+0.25, Rcol-3*coverl/4-0.25)
            ],
            "material": "*concr*"
        },
        "dsr4" : {
            "regions": [
                Octagon(Rcol-3*coverl/4, Rcol-coverl)
            ],
            "material": "*concr*"
        },
        "dsr5": {
            "regions": [
                section.FiberSection(areas=[
                    patch.circ(intRad=Rcol - cover - 2, extRad=Rcol - cover)
                ])
            ],
            "material": "*concr*"
        },
        "dsr6": {
            "regions": [
                section.FiberSection(areas=[
                    patch.circ(intRad=Rcol - cover - 2, extRad=Rcol - cover)
                ])
            ],
            "material": "*steel*"
        },
        "all" : {
            "regions": [
                Octagon(Rcol, Rcol-10)
            ]
        }
    }

# --8<--------------------------------------------------------

def iter_elem_fibers(model:dict, elements:list, sections: list, damage_state:dict=None):
    sam = model["StructuralAnalysisModel"]
    model["sections"] = {
        str(s["name"]): s for s in sam["properties"]["sections"]
    }
    model["materials"] = {
        str(m["name"]): m for m in sam["properties"]["uniaxialMaterials"]
    }
    for el in sam["geometry"]["elements"]:
        if el["name"] in elements and "sections" in el:
            #for tag in el["sections"]:
            for i in sections:
                idx = len(el["sections"]) - 1 if i==-1 else i
                tag = el["sections"][idx]
                s = model["sections"][tag]
                if "section" in s:
                    s = model["sections"][s["section"]]
                    for s,f in iter_section_fibers(model, s, damage_state):
                        yield el,idx+1,f

def iter_section_fibers(model, s, damage_state=None):
    if damage_state is not None:
        if "material" not in damage_state:
            damage_state["material"] = "*"
        for fiber in s["fibers"]:
            if any(
                fiber["coord"] in region
                for region in damage_state["regions"]
            ) and fnmatch.fnmatch(
                model["materials"][fiber["material"]]["type"].lower(),
                damage_state["material"]
            ):
                yield s,fiber
    else:
        for fiber in s["fibers"]:
            yield s,fiber

def print_fiber(c, s, base_cmd, options):
    out_file = options["record_file"] +f"_{s}" + "_" + str(c[0]) + "_" + str(c[1]) + ".txt"
    base_cmd = base_cmd.format(fmt=options["format"],out_file=out_file)
    fiber_cmd = base_cmd + f"fiber {c[0]} {c[1]} stressStrain;\n"
    print(fiber_cmd)
    if options["logging"]:
        print("puts \""+fiber_cmd+"\"")


def print_help():
    print("""
    get_fibers model.json output.txt -d Dcol -e E... -l STATE

    Options
    -file | -xml
    -logging <int>
    -d[iameter] <float>
""")

def parse_args(args)->dict:
    opts = {
        "model_file": None,
        "record_file": None,
        "logging": 0,
        "format": "file"
    }
    argi = iter(args)
    for arg in argi:
        if arg[:2] == "-h":
            print_help()
            sys.exit()

        if arg[:2] == "-d":
            opts["Dcol"] = float(next(argi))

        elif arg == "-e":
            opts["elements"] =  [
                int(e) for e in next(argi).split(",")
            ]

        elif arg == "-s":
            opts["sections"] = [int(s) for s in next(argi).split(",")]

        elif arg == "-l":
            opts["state"] = next(argi)
        
        # Formats
        elif arg == "-file":
            opts["format"] = "file"
        elif arg == "-xml":
            opts["format"] = "xml"

        elif arg == "-logging":
            opts["logging"] = next(argi)

        elif opts["model_file"] is None:
            opts["model_file"] = arg


        else:
            opts["record_file"] = arg

    return opts

base_cmd = "recorder Element -{fmt} {out_file} -time "


if __name__=="__main__":

    opts = parse_args(sys.argv[1:])

    damage_state = damage_states(opts["Dcol"])[opts["state"]]

    elements = opts["elements"]

    sections = opts["sections"]

    with open(opts["model_file"], "r") as f:
        model = json.load(f)

    for e,s,f in iter_elem_fibers(model, elements, sections, damage_state):
        elem_cmd = base_cmd + f"-ele {e['name']} "
        print_fiber(f["coord"], s, elem_cmd + f"section {s} ", opts)

