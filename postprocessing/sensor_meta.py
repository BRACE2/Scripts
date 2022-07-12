# Sensor metadata
import numpy as np
from math import pi

sensor_meta = {
  # node    location         (channel long, channel tran)       bent no.
    1031:   ("abutment 1 south end base",           (3,2),      1),
    307:    ("bent 3 south column base",            (6,7),      3),
    1030:   ("abutment 1 south end top",            (12,13),    1),
    304:    ("bent 3 mid bent cap, deck south edge",(14,15),    3),
    401:    ("bent 4 north column base",            (17,18),    4),
    402:    ("bent 4 north column top",             (19,20),    4),
    405:    ("bent 4 deck south edge",              (22,23),    4),
    407:    ("bent 4 south column base",            (24,25),    4)
}

bents = np.array([1, 3, 1, 3, 4, 4, 4, 4])

bentAngles = {
   # bent no.   angle in radians
        1:      37.66*pi/180,
        3:      31.02*pi/180,
        4:      26.26*pi/180
}

angles = [bentAngles[bent] for bent in bents]