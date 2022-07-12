#!/usr/bin/env python

import sys
from math import pi
from pathlib import Path

import quakeio
import opensees
import opensees.tcl
import numpy as np


HELP = f"""
usage: {Path(__file__).name} motion.zip [format]

Output formats:
    --displ     tab-separated longitudinal and transverse displacement values
    --accel     tab-separated longitudinal and transverse acceleration values
    --veloc     tab-separated longitudinal and transverse velocity values

    --tcl       (Default) OpenSees commands for generating a UniformExcitation
                load pattern.

    --plot

NOTES:
- Longitudinal is X
- Transverse is Y


    Case A:
    positive angle generates **counter-clockwise** rotation

               |
    ========== o-->========
                

    Case B:
    positive angle generates **clockwise** rotation

            OpenSees' Y
                /
    ========== o-->========
               |


"""

# key is the sensor direction, value is the model DOF.

DOFS = {"long": 1, 
        "tran": 2}



def get_motion(filename, location, rotation=None, vertical=-3, scale=1.0):
    motion =  quakeio.read(filename).match("l", key=location)
    if vertical < 0:
        motion.components["tran"].accel._data *= -1
    if rotation is not None:
        motion.rotate(rotation)
    return motion


def get_patterns(motion,  scale=1.0):
    # motion.components["tran"].accel._data *= -1
    # motion.rotate(rotation)
    for component in motion.components.values():
        component.accel._data *= scale
    return [
            opensees.pattern.UniformExcitation(None, dof, motion.components[drn].accel)
                for drn, dof in DOFS.items()
    ]







def plot_rotations(filename, location, angle):
    """
    Debugging/validation function. Plots motion components, and
    their rotations. Assumes vertical-down coordinate system.
    """
    n = 5
    s = 5
    m = quakeio.read(filename).match("l", key=location)
    m.components["tran"].accel._data *= -1

    import matplotlib.pyplot as plt
    fig, ax = plt.subplots()
    X = np.linspace(0, 1e-3, n)

    xy = m.accel
    for xi,(x,y) in zip(X, xy[:n]):
        ax.plot([xi, xi+x], [0, y])

    xy = m.rotate(angle).accel
    for xi,(x,y) in zip(X, xy[:n]):
        ax.plot([xi, xi+x], [0, y], ":")

    ax.axis("equal")
    plt.show()



if __name__ == "__main__":
    #
    # Hard-coded options
    #

    # scale = 1
    scale = 0.393700787     # cm/s^2 to in/s^2
    # scale = 0.00101971621   # cm/s^2 to g

    # rotation angle in radians
    rotation =-26.26*pi/180

    location = "bent_4_south_column_grnd_level"
    #          "abutment_1"
    #          "bent_3_south_column_grnd_level"
    #          "deck_level_near_abut_1"
    #          "bent_3_deck_level"
    #          "midspan_between_bents_3_4_deck"
    #          "bent_4_north_column_grnd_level"
    #          "bent_4_north_column_top"
    #          "bent_4_deck_level"
    #          "bent_4_south_column_grnd_level"


    #
    # Parsed options
    #


    if len(sys.argv) == 1:
        print(HELP)
        sys.exit()

    filename = sys.argv[1]

    if len(sys.argv) > 2:
        format = sys.argv[2][2:]

    else:
        format = "tcl"

    if len(sys.argv) > 3:
        component = sys.argv[3]
    else:
        component = None

    #
    # Process motion
    #

    motion = get_motion(filename, location, rotation)


    if format == "tcl":
        patterns = get_patterns(motion, scale=scale)

        first_component = next(iter(motion.components.values())).accel
        dt, steps = first_component["time_step"], len(first_component.data)

        print(opensees.tcl.dumps(patterns))
        print(f"set _dummy_ {{ {dt} {steps} }}")

    elif format in ["accel", "displ", "veloc"]:
        array = scale*getattr(motion, format)
        if component is not None:
            array = array[:,int(component)]
        np.savetxt(sys.stdout.buffer, array)

    else:
        plot_rotations(filename, location, rotation)

