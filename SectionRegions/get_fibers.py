import json, sys, fnmatch

from SectionLib import Octagon


def iter_elem_fibers(elements:list, model:dict, damage_state:dict=None):
    model["sections"] = {
        str(s["name"]): s 
        for s in model["StructuralAnalysisModel"]["properties"]["sections"]
    }
    model["materials"] = {
        str(m["name"]): m
        for m in model["StructuralAnalysisModel"]["properties"]["uniaxialMaterials"]
    }
    for el in model["StructuralAnalysisModel"]["geometry"]["elements"]:
        if el["name"] in elements and "sections" in el:
            #elem_cmd = base_cmd + f"-ele {el['name']} "
            for tag in el["sections"]:
                s = model["sections"][tag]
                if "section" in s:
                    s = model["sections"][s["section"]]
                    for s,f in iter_section_fibers(s, model, damage_state):
                        yield el,s,f

def iter_section_fibers(s, model, damage_state):
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
    FiberLib model.json output.txt -d Dcol -e E... -s STATE
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

def damage_states(Dcol):
    cover = 2.0
    return {
      # Any outermost cover fiber
      "dsr1" : {
          "regions": [Octagon(Dcol/2, Dcol/2)]
      },
      "dsr2" : {
          "regions": [Octagon(Dcol/2.1, Dcol/2.2)],
          "material": "*steel*"
      },
      # Any cover fiber at 1/2 - 3/4 cover depth
      "dsr3" : {
          #         internal radius         external radius
          "regions": [Octagon(Dcol/2-cover*(1-0.5), Dcol/2-cover*(1-0.75))],
      },
    }

if __name__=="__main__":

    opts = parse_args(sys.argv[1:])

    damage_state = damage_states(opts["Dcol"])[opts["state"]]

    elements = opts["elements"]

    out_file = opts["record_file"]

    base_cmd = base_cmd.format(out_file=out_file)
    with open(opts["model_file"], "r") as f:
        model = json.load(f)

    for e,s,f in iter_elem_fibers(elements, model, damage_state):
        elem_cmd = base_cmd + f"-ele {e['name']} "
        print_fiber(f["coord"], elem_cmd + f"section {s['name']} ")





