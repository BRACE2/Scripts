from ssid import *
import sys
import quakeio
from pathlib import Path

def test_petrolia():

    channels = [[17, 3, 20], [9, 7, 4]]

    event = quakeio.read("tests/RioDell_Petrolia_Processed_Data.zip")

    inputs = np.array([
        event.at(file_name=f"CHAN{i:03d}.V2").accel.data for i in channels[0]
    ]).T
    outputs = np.array([
        event.at(file_name=f"CHAN{i:03d}.V2").accel.data for i in channels[1]
    ]).T
    npoints = len(inputs[:,0])
    dt = event.at(file_name=f"CHAN{channels[0][0]:03d}.V2").accel["time_step"]

    configsrim = {
        "p"  :  5,
        "dt" : dt,
        "dn" : npoints - 1,
        "orm":  4
    }

    A,B,C,D = srim(inputs, outputs, **configsrim)
    freqdmpSRIM, modeshapeSRIM, *_ = ComposeModes(dt, A, B, C, D)
    print(1/freqdmpSRIM[:,0])


