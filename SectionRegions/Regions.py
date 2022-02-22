from opensees import section, patch, layer
import opensees.render.mpl as render
from math import *

#
# PART 1: Define section
#
Dcol = 20.0*inch
cover = 2*inch
#sect = BuildOctColSection(1,  Dcol,  8,  4,  3)


# # add damage region to section that were plotting
# sect.fibers.extend(DS["dsr3"][0].fibers)

ax = render.section(sect)

# #
# # Test
# #
# # Create grid of points
# import numpy as np

# grid = np.array([[x,y]
#     for x in np.linspace(-15,15,50)
#     for y in np.linspace(-15,15,50)
# ])



# grid = [point for point in grid if point in DS["dsr3"][0]]

# ax.scatter(*list(zip(*grid)), color="red", s=0.5)
# #ax.scatter(*list(zip(*[point for point in XY if point in DS["ds1"]])), color="red")
# render.show()



