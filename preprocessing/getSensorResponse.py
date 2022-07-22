#!/usr/bin/env python

import sys
from math import pi
from collections import defaultdict
import quakeio


"""
flags are:
    --veloc/displ/accel

"""

def get_node_values(filename, channels, quant=None):
    if quant is None:
        quant = "accel"

    event = quakeio.read(filename)
    rotated = set()

    # create dict of dicts that maps like [node_tag][dof][time]
    nodes = defaultdict(dict)
    for nm,ch in channels.items():
        channel = event.match("l", station_channel=nm)
        if id(channel._parent) not in rotated:
            channel._parent.rotate(ch[2])
            rotated.add(id(channel._parent))
        series = getattr(channel, quant).data
        nodes[ch[0]][ch[1]] = series

    return nodes

def print_node_values(nodes):
    ndf = 6

    i = 0
    while True:
        try:
            string = "\n".join(f"  {node}: [{','.join(str(nodes[node][dof][i]) if dof in nodes[node] else '0.0' for dof in range(1,ndf+1))}]"
                    for node, dofs in nodes.items()
            )

        except IndexError:
            break

        print(f"{i}:\n"+string)
        i += 1


if __name__ == "__main__":
    #
    # Hard-coded options
    #

    # scale = 1.0
    scale = 0.393700787     # cm/s^2 to in/s^2

    # rotation angle in radians

    channels = {
    # channel  node dof
        "2": (1031, 2, 37.66*pi/180),
        "3": (1031, 1, 37.66*pi/180),
        "6": (307, 1, 31.02*pi/180),
        "7": (307, 2, 31.02*pi/180),
        "12": (1030, 1, 37.66*pi/180),
        "13": (1030, 2, 37.66*pi/180),
        "14": (304, 1, 31.02*pi/180),
        "15": (304, 2, 31.02*pi/180),
        "17": (401, 1, 26.26*pi/180),
        "18": (401, 2, 26.26*pi/180),
        "19": (402, 1, 26.26*pi/180),
        "20": (402, 2, 26.26*pi/180),
        "22": (405, 1, 26.26*pi/180),
        "23": (405, 2, 26.26*pi/180),
        "24": (407, 1, 26.26*pi/180),
        "25": (407, 2, 26.26*pi/180),
    }


    #
    # Parsed options
    #


    if len(sys.argv) == 1:
        print(HELP)
        sys.exit()

    filename = sys.argv[1]

    format = sys.argv[2][2:]
    
    nodes = get_node_values(filename, channels, quant=format)

    print_node_values(nodes)


