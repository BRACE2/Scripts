dimensionsDir = "../../CalTrans.Hayward/Procedures/Dimensions/"
imageDir = "../../CalTrans.Hayward/Procedures/Images/"

import numpy as np
from matplotlib import pyplot as plt
plt.style.use('science')

vecxzXraw = np.loadtxt(dimensionsDir+'vecxzXcol.txt')
vecxzYraw = np.loadtxt(dimensionsDir+'vecxzYcol.txt')
vecxzNorms = np.linalg.norm(np.array((vecxzXraw,vecxzYraw)), axis=0)
vecxzX = vecxzXraw/vecxzNorms
vecxzY = vecxzYraw/vecxzNorms
nVecs = len(vecxzX)
nc = 2
nr = nVecs//nc+1

fig, axs = plt.subplots(nrows=nr, ncols=nc, figsize=(6,6.5), dpi=150, 
                        sharex=True, sharey=True)
for i in range(nVecs):
    axs[int((i//nc)%nr),int(i%nc)].arrow(0, 0, vecxzX[i], vecxzY[i], head_width=0.05, overhang=1)
    axs[int((i//nc)%nr),int(i%nc)].set_title('vecxz bent '+str(i+2))
fig.supxlabel('vecxz X (direction 1) component')
fig.supylabel('vecxz Y (direction 2) component')
fig.tight_layout()
fig.savefig(imageDir+"plotVecXZ.png", dpi=fig.dpi)
plt.show()