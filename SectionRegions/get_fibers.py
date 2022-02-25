import json, sys, fnmatch
from opensees import patch, section
from opensees.section import PatchOctagon as Octagon


def iter_elem_fibers(model:dict, elements:list, damage_state:dict=None):
    sam = model["StructuralAnalysisModel"]
    model["sections"] = {
        str(s["name"]): s for s in sam["properties"]["sections"]
    }
    model["materials"] = {
        str(m["name"]): m for m in sam["properties"]["uniaxialMaterials"]
    }
    for el in sam["geometry"]["elements"]:
        if el["name"] in elements and "sections" in el:
            for tag in el["sections"]:
                s = model["sections"][tag]
                if "section" in s:
                    s = model["sections"][s["section"]]
                    for s,f in iter_section_fibers(model, s, damage_state):
                        yield el,s,f

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

def print_fiber(c, base_cmd):
    fiber_cmd = base_cmd + f"fiber {c[0]} {c[1]} stressStrain;\n"
    print(fiber_cmd)

def print_help():
    print("""
    get_fibers model.json output.txt -d Dcol -e E... -s STATE
""")

def parse_args(args)->dict:
    opts = {
        "model_file": None,
        "record_file": None
    }
    argi = iter(args)
    for arg in argi:
        if arg == "-d":
            opts["Dcol"] = float(next(argi))
        elif arg == "-e":
            opts["elements"] =  [
                int(e) for e in next(argi).split(",")
            ]
        elif arg == "-s":
            opts["state"] = next(argi)
        elif opts["model_file"] is None:
            opts["model_file"] = arg
        else:
            opts["record_file"] = arg
    return opts

base_cmd = "recorder Element -xml {out_file} -time "

# --8<--------------------------------------------------------
def damage_states(Dcol):
    cover = 2.0
    Rcol = Dcol/2
    return {
      "dsr1" : {
          "regions": [
              Octagon(Rcol, Rcol)
          ]
      },
      "dsr2" : {
          "regions": [
              section.FiberSection(fibers=[
                  patch.circ(intRad=Rcol-cover-2, extRad=Rcol-cover)
              ])
          ],
          "material": "*steel*"
      },
      "dsr3" : {
          "regions": [
          #             external radius      internal radius
              Octagon(Rcol-cover*(1-0.75), Rcol-cover*(1-0.5))
          ]
      }
}

if __name__=="__main__":

    opts = parse_args(sys.argv[1:])

    damage_state = damage_states(opts["Dcol"])[opts["state"]]

    elements = opts["elements"]

    out_file = opts["record_file"]

    base_cmd = base_cmd.format(out_file=out_file)
    with open(opts["model_file"], "r") as f:
        model = json.load(f)

    for e,s,f in iter_elem_fibers(model, elements, damage_state):
        elem_cmd = base_cmd + f"-ele {e['name']} "
        print_fiber(f["coord"], elem_cmd + f"section {s['name']} ")

