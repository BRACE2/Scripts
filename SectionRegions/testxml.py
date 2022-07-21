import timeit

from xmlutils import read_sect_xml3, read_sect_xml2, read_sect_xml1, read_sect_xml0


a = read_sect_xml0("GM1/eleDef1.txt")

b = read_sect_xml3("GM1/eleDef1.txt")

for k,v in a.items():
    for kk, vv in v.items():
        for kkk, vvv in vv.items():
            assert not any(vvv - b[k][kk][kkk]), (k, kk, kkk)

n = 100
for i in reversed(range(4)):

    print(i, 
       timeit.timeit(f"read_sect_xml{i}('GM1/eleDef1.txt')", 
           number=n, globals=globals()))


