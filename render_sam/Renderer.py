#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""

@author: Arpit
"""

from pyqtgraph.Qt import QtCore, QtGui
import pyqtgraph.opengl as gl
import pyqtgraph as pg
import numpy as np
import os.path as path
import json
import math
import sys

##############################################
sqrt = math.sqrt
quadLocs = dict()
quadLocs["Lobatto"] = [
    0,
    0,
    [-0.5, 0.5],
    [-1, 0, 1],
    [-1, -sqrt(1/5), sqrt(1/5), 1],
]
quadLocs["Legendre"] = [
    0,
    0,
    [-sqrt(1/3),    sqrt(1/3)],
    [-sqrt(3/5), 0, sqrt(3/5)],
    [-0.861136, -0.339981, 0.339981, 0.861136],
]

eleC = {
    "ForceBeamColumn3d": "b",
    "DispBeamColumn3d": "r",
    "Truss2": "g",
    "Truss": "y",
    "ZeroLength": "b",
    "ElasticBeam3d": "w",
    "TwoNodeLink": 1,
}
eleW = {
    "ForceBeamColumn3d": 2,
    "DispBeamColumn3d": 1,
    "Truss2": 0.5,
    "Truss": 0.5,
    "ZeroLength": "b",
    "ElasticBeam3d": 4,
    "TwoNodeLink": 1,
}
fibClrs = ["r", "g", "b", "c", "m", "y", "w", "r", "g", "b", "c", "m", "y", "w"]
##############################################
# Get model data

# dataDir=path.join(path.expanduser("~"),'BRACE2','CalTrans.Hayward-main','Procedures','datahwd8')
# json_data=open(path.join(dataDir,'modelDetails.json')).read()
# data = json.loads(json_data)
with open("modelDetails.json", "r") as f:
    data = json.load(f)
# with open(sys.argv[1], "r") as f:
#    data = json.load(f)

nodes = dict()
elements = dict()
eleTypes = []
mTot = [0, 0, 0, 0, 0]

# nodeDisp=np.genfromtxt(path.join(dataDir,'Cyclic','CyclicPushRecorders','nodeRecCycl.txt'),skip_footer=1);
# nodeDisp=np.loadtxt(path.join(dataDir,'Dynamic','EQ47','allNodes.disp'));
nodeList = []
SFunit = 0.01
for node in data["StructuralAnalysisModel"]["geometry"]["nodes"]:
    node["crd"] = np.array(node["crd"]) * SFunit
    nodes["%d" % (node["name"])] = node
    nodeList.append(node["name"])
    if "mass" in node.keys():
        if node["crd"][2] <= 10:
            mTot[0] += node["mass"][0]
        else:
            mTot[node["crd"][2] // 84] += node["mass"][0]

for i, n in enumerate(nodeList):
    nodes["%d" % (n)]["disp"] = np.zeros((6, 2))


for ele in data["StructuralAnalysisModel"]["geometry"]["elements"]:
    elements["%d" % (ele["name"])] = ele
    # if ele['type'] not in eleTypes:
    #    eleTypes.append(ele['type'])

eleTypes = list({e["type"] for e in elements.values()})

crdTranfs = {
    t["name"]: t
    for t in data["StructuralAnalysisModel"]["properties"]["crdTransformations"]
}
sections = {
    s["name"]: s for s in data["StructuralAnalysisModel"]["properties"]["sections"]
}

##############################################


def getFibLocs(ele):
    eleNodeCrds = []
    for nodeNum in elements[ele]["nodes"]:
        eleNodeCrds.append(nodes["%d" % nodeNum]["crd"])
    eleNodeCrds = np.array(eleNodeCrds)
    # print(eleNodeCrds)
    eleVec = eleNodeCrds[1] - eleNodeCrds[0]
    eleLen = (eleVec ** 2).sum() ** 0.5
    eleLocX = eleVec / eleLen
    eleVecXZ = crdTransfs[elements[ele]["crdTransformation"]]["vecInLocXZPlane"]
    eleLocY = np.cross(eleVecXZ, eleLocX)
    eleLocZ = np.cross(eleLocX, eleLocY)

    ijkMat = np.row_stack([eleLocX, eleLocY, eleLocZ])

    eleSec = elements[ele]["sections"]
    eleNIP = len(eleSec)
    eleInt = elements[ele]["integration"]["type"]
    if eleInt in ["Lobatto", "Legendre"]:
        intLocs = np.asarray(quadLocs[eleInt][eleNIP]) * 0.5 + 0.5
    elif eleInt == "UserDefined":
        intLocs = elements[ele]["integration"]["points"]
    else:
        intLocs = 0.5
    secPts = np.empty((0, 3))
    secClr = []
    secSz = []
    secCtr = 0

    fibTypes = []
    fibClrSec = dict()
    fibClrCtr = 0
    for sec in eleSec:
        secData = sections[sec]
        while secData["type"] == "SectionAggregator":
            secData = sections[secData["section"]]
        tmpFibLocs = []
        secOrig = eleNodeCrds[0] + eleLocX * eleLen * intLocs[secCtr]
        # print(secOrig)
        for fiber in secData["fibers"]:
            tmpFibLocs.append([0, fiber["coord"][0], fiber["coord"][1]])
            secSz.append(sqrt(fiber["area"]))
            if fiber["material"] in fibTypes:
                secClr.append(pg.glColor(fibClrSec[fiber["material"]]))
            else:
                fibTypes.append(fiber["material"])
                fibClrSec[fiber["material"]] = fibClrs[fibClrCtr]
                fibClrCtr += 1
                secClr.append(pg.glColor(fibClrSec[fiber["material"]]))
        tmpFibLocs = np.array(tmpFibLocs)
        gFibLocs = tmpFibLocs.dot(ijkMat) + secOrig
        secPts = np.row_stack([secPts, gFibLocs])
        if len(eleSec) == len(intLocs):
            secCtr += 1
    return (secPts, np.array(secClr), np.array(secSz))


##############################################

app = QtCore.QCoreApplication.instance()
if app is None:
    app = QtGui.QApplication([])
w = gl.GLViewWidget()
w.opts["distance"] = 1200
w.show()
w.setWindowTitle("Test Render")
# gx = gl.GLGridItem()
# gx.setSize(x=480,y=300)
# gx.setSpacing(x=12,y=12)
# w.addItem(gx)

# def onClick(event):
#    items = w.scene().items(event.scenePos())
#    print("Plots:", [x for x in items if isinstance(x, pg.PlotItem)])
# w.scene().sigMouseClicked.connect(onClick)

xl = gl.GLLinePlotItem(
    pos=np.array([[0, 0, 0], [75, 0, 0]]),
    color=pg.glColor("r"),
    width=2,
    antialias=True,
)
xl.setDepthValue(-1)
w.addItem(xl)
yl = gl.GLLinePlotItem(
    pos=np.array([[0, 0, 0], [0, 75, 0]]),
    color=pg.glColor("g"),
    width=2,
    antialias=True,
)
yl.setDepthValue(-1)
w.addItem(yl)
zl = gl.GLLinePlotItem(
    pos=np.array([[0, 0, 0], [0, 0, 75]]),
    color=pg.glColor("w"),
    width=2,
    antialias=True,
)
zl.setDepthValue(-1)
w.addItem(zl)
eleBRD_FD = [
    "15979",
    "25979",
    "35979",
    "45979",
    "16979",
    "26979",
    "36979",
    "46979",
    "17979",
    "27979",
    "37979",
    "47979",
    "5991",
    "6991",
    "7991",
]
lineData = []
meshData = []
for key, ele in elements.items():
    eleType = ele["type"]
    eleClr = eleC[eleType]
    eleNodeCrds = []
    eleNodeDisps = []
    for nodeNum in ele["nodes"]:
        eleNodeCrds.append(nodes["%d" % nodeNum]["crd"])
        eleNodeDisps.append(nodes["%d" % nodeNum]["disp"][:, :3])
    eleNodeCrds = np.array(eleNodeCrds)
    eleNodeDisps = np.array(eleNodeDisps).transpose((1, 0, 2))
    #    if np.any(eleNodeCrds[:,2]>90):# and np.any(eleNodeCrds[:,2]<250) : #np.any(eleNodeCrds[:,2]>80) or
    #        continue;
    if eleType == "ShellMITC4":
        verts = eleNodeCrds
        shellFaces = np.array([[0, 1, 2], [2, 3, 0]])
        shellColors = np.array([[0.5, 0.5, 0.5, 0.3], [0.5, 0.5, 0.5, 0.3]])
        m1 = gl.GLMeshItem(
            vertexes=verts, faces=shellFaces, faceColors=shellColors, smooth=False
        )
        m1.setGLOptions("additive")
        w.addItem(m1)
        meshData.append([m1, eleNodeDisps, eleNodeCrds])
    elif eleType != "Truss2" and (
        eleType != "Truss" or ele in eleBRD_FD
    ):  # and eleType!='DispBeamColumn3d':
        # else:
        lColor = pg.glColor(eleClr)
        l1 = gl.GLLinePlotItem(
            pos=eleNodeCrds, width=eleW[eleType], antialias=True, color=lColor
        )
        w.addItem(l1)
        lineData.append([l1, eleNodeDisps, eleNodeCrds])
#        if eleType=='ForceBeamColumn3d' or eleType=='DispBeamColumn3d':
#            tmpF=getFibLocs(ele)
#            tf1=gl.GLScatterPlotItem(pos=tmpF[0],size=tmpF[2]*5,color=tmpF[1]*5)
#            w.addItem(tf1)

# eleType=ele['type']
# eleNodeCrds=[[-240,-150,0],[240,-150,0],[240,150,0],[-240,150,0]]
# eleNodeCrds=np.array(eleNodeCrds)
# verts=eleNodeCrds;
# shellFaces=np.array([[0,1,2],[2,3,0]])
# shellColors=np.array([[0.5,0.0,0.0,1.0],[0.5,0.0,0.0,1.0]]);
# m1=gl.GLMeshItem(vertexes=verts,faces=shellFaces,faceColors=shellColors,smooth=False)
# m1.setGLOptions('additive')
##m1.setDepthValue(-1)
# w.addItem(m1)


def updateRender(i, SF):
    for line in lineData:
        line[0].setData(pos=line[1][i, :, :] * SF + line[2])
    for mesh in meshData:
        verts = mesh[1][i, :, :] * SF + mesh[2]
        # verts=np.array([verts[[0,1,2],:],verts[[2,3,0],:]])
        mesh[0].setMeshData(
            vertexes=verts, faces=shellFaces, faceColors=shellColors, smooth=False
        )


i = 0
di = 1
SF = 50


def update():
    global i
    i = i + di
    if i > nodeDisp.shape[0]:
        i = 0
    updateRender(i, SF)
    w.setWindowTitle("Test Render : %0.3f" % (i / 240))


t = QtCore.QTimer()
t.timeout.connect(update)
# t.start(1)
