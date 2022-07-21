import re
import numpy as np
from collections import defaultdict
import xml.etree.ElementTree as ET

re_elem_tag = re.compile(rb'eleTag="([0-9]*)"')
re_sect_num = re.compile(rb'number="([0-9]*)"')
resp_tag = re.compile(rb"<ResponseType>([A-z0-9]*)</ResponseType>")

def getDictData(allData, curDict):
    if isinstance(curDict, (defaultdict,dict)):
        for key, item in curDict.items():
            if isinstance(item, (defaultdict,dict)):
                getDictData(allData, item)
            elif isinstance(item, int):
                curDict[key] = allData[:, item]


def read_sect_xml3(filename: str)->dict:
    data_dict = defaultdict(lambda: defaultdict(dict))
    counter = 0

    with open(filename, "rb") as f:
        for line in f:
            if b"<ElementOutput" in line and (elem := re_elem_tag.search(line)):
                elem_tag = elem.group(1).decode()
                while b"</ElementOutput>" not in line:
                    line = next(f)
                    if b"<GaussPointOutput" in line:
                        sect = re_sect_num.search(line).group(1).decode()

                    elif b"<ResponseType" in line:
                        r_label =  resp_tag.search(line).group(1).decode()
                        while r_label in data_dict[elem_tag][sect]:
                            r_label += "_"
                        data_dict[elem_tag][sect][r_label] = counter
                        counter += 1


            elif b"<Data>" in line:
                lines = f.read()
                lines = lines[:lines.find(b"</Data>")].split()
                data = np.fromiter(lines, dtype=np.float64, count=len(lines))
                # data = csv.read_csv(f.readlines()[:-3]).to_numpy().reshape((-1, counter))
                # data = np.genfromtxt(f, skip_footer=3).reshape((-1,counter))
                # data = np.loadtxt(lines, dtype=np.float64)#.reshape((-1,counter))
                # data = np.fromiter(
                #     (i for dline in lines for i in dline.split()), dtype=np.float64, count=len(lines)*counter
                # )
                # data = np.array(lines.replace(b"\n", b"").decode().split(), dtype=float)
                # data = data[~np.isnan(data)].reshape((-1, counter))

    getDictData(data.reshape((-1, counter)), data_dict)
    return data_dict

def read_sect_xml1(xml_file):
    root = ET.parse(xml_file).getroot()

    dataDict = {}
    colCtr = 0

    # time_output = root.find("TimeOutput")
    # if time_output:
    #     hdrs.append(child[0].text)
    #     dataDict[child[0].text] = colCtr
    #     colCtr += 1

    elems = root.findall("ElementOutput")
    for child in elems:

        eleKey = child.attrib["eleTag"]
        secKey = child[0].attrib["number"]

        dataDict[eleKey] = {secKey: {}}

        for respCtr in range(len(child[0][0])):
            respKey = child[0][0][respCtr].text
            if respKey in dataDict[eleKey][secKey].keys():
                respKey = respKey + "_"
            dataDict[eleKey][secKey][respKey] = colCtr
            colCtr += 1
                
    data_element = root.find("Data")
    data = np.array(data_element.text.split(), dtype=float)
    getDictData(data.reshape((-1, colCtr)), dataDict)
    return dataDict

def read_sect_xml2(xml_file):
    root = ET.parse(xml_file).getroot()

    dataDict = {}
    colCtr = 0

    # time_output = root.find("TimeOutput")
    # if time_output:
    #     hdrs.append(child[0].text)
    #     dataDict[child[0].text] = colCtr
    #     colCtr += 1

    elems = root.findall("ElementOutput")
    for child in elems:

        eleKey = child.attrib["eleTag"]
        secKey = child[0].attrib["number"]

        dataDict[eleKey] = {secKey: {}}

        for respCtr in range(len(child[0][0])):
            respKey = child[0][0][respCtr].text
            if respKey in dataDict[eleKey][secKey].keys():
                respKey = respKey + "_"
            dataDict[eleKey][secKey][respKey] = colCtr
            colCtr += 1
                
    data_element = root.find("Data")
    data = np.fromiter(
        (i for text in data_element.itertext() for i in text.split()), dtype=float,
    ).reshape((-1, colCtr))
    # data = np.fromstring(data_element.text, dtype=float).reshape((-1, colCtr))
    getDictData(data, dataDict)
    return dataDict

def read_sect_xml0(xml_file):
    "Arpit Nema"
    root = ET.parse(xml_file).getroot()

    hdrs = []
    dataDict = {}
    colCtr = 0
    for i, child in enumerate(root):
        if child.tag == "TimeOutput":
            hdrs.append(child[0].text)
            dataDict[child[0].text] = colCtr
            colCtr += 1
        elif child.tag == "ElementOutput":
            eleKey = child.attrib["eleTag"]
            secKey = child[0].attrib["number"]
            hdrPre = eleKey + "_" + secKey + "_" + child[0][0].attrib["secTag"]

            dataDict[eleKey] = {secKey: {}}
            for respCtr in range(len(child[0][0])):
                hdrs.append(hdrPre + "_" + child[0][0][respCtr].text)
                respKey = child[0][0][respCtr].text
                if respKey in dataDict[eleKey][secKey].keys():
                    respKey = respKey + "_"
                dataDict[eleKey][secKey][respKey] = colCtr
                colCtr += 1
        elif child.tag == "Data":
            tmp = child.text

    data = np.array(tmp.replace("\n", "").split(), dtype=float)
    
    data = data.reshape((-1, len(hdrs)))
    getDictData(data, dataDict)
    return dataDict

