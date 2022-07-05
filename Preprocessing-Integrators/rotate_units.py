# Rotates sensor data from local to global coordinate system for hayward bridge.

sensorDataDir = '../datahwd10.1.0/DynResponse/sensors/'
import numpy as np

sensorLocs = np.array([ [2, 3],
                        [6, 7],
                        [12, 13],
                        [14, 15],
                        [17, 18],
                        [19, 20],
                        [22, 23],
                        [24, 25]])

bents = np.array([1, 3, 1, 3, 4, 4, 4, 4])

bentAngles =   {1: 37.66 *np.pi/180,
                3: 31.02 *np.pi/180,
                4: 26.26 *np.pi/180}

angles = [bentAngles[bent] for bent in bents]

unitConv = 386.088583 # From g (sensor) to in/s^2 (model)

for i in range(sensorLocs.shape[0]):
    sensorLoc = sensorLocs[i]
    sensorNo1, sensorNo2 = sensorLoc

    Xin = np.loadtxt(sensorDataDir+str(sensorNo1)+'.txt')
    Yin = np.loadtxt(sensorDataDir+str(sensorNo2)+'.txt')

    theta = angles[i]
    MRot = np.array([[np.cos(theta), np.sin(theta)],
                    [-np.sin(theta), np.cos(theta)]]);
    
    Xout, Yout = unitConv*MRot@np.array([Xin, Yin])

    chanNo1 = "{:02d}".format(sensorNo1)
    chanNo2 = "{:02d}".format(sensorNo2)

    np.savetxt(sensorDataDir+'AA_Ch' + chanNo1 + '-' + chanNo2 + '_X.txt', Xout)
    np.savetxt(sensorDataDir+'AA_Ch' + chanNo1 + '-' + chanNo2 + '_Y.txt', Yout)