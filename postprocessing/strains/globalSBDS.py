import numpy as np
import pandas as pd

num_GM = 755

# Get Strain-Based Damage States By Element and Extract maxGlobal and pctGlobal DS
sbPoint = [None] * num_GM
sbInfo1 = pd.read_csv("GM1/DamageStatesByElement.csv")
elemList = sbInfo1["Element"].astype(int).tolist()
sbDS = np.empty([num_GM, len(elemList)+2])
for i in range(num_GM):
    # Get strain-based DS values
    sbFile = "GM" + str(i+1) + "/DamageStatesByElement.csv"
    sbInfo = pd.read_csv(sbFile)
    eleSBDS = sbInfo["DS"].astype(int).tolist()    
    maxGlobal = [max(eleSBDS)]
    pctGlobal = [len(sbInfo[sbInfo["DS"] > 0]) / len(elemList)]
    sbDS[i] = eleSBDS+maxGlobal+pctGlobal
    
SB_DS_Summary = pd.DataFrame(np.column_stack((np.arange(1,num_GM+1), sbDS)), columns=["GM"]+elemList+["global (max)", "global (%)"])
SB_DS_Summary.to_csv("SB_DS_global.csv", index=False)