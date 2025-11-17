#!/usr/bin/python

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3],'w')


dict={}

for eachline in f1:
	line=eachline.split()
	if eachline !="\n":
		if line[2]=="gene":
			gene=''.join(line[8].split(";")[0][3:])
			length=int(line[4])-int(line[3])
			dict[gene]=length

for eachline in f2:
	i=eachline.split()
	cover=int(i[3])/(dict[i[0]]+0.0)
	f3.write("%s\t%s\t%s\t%s\t%s\n"%(i[0],i[1],i[2],i[3],cover))

f1.close()
f2.close()
f3.close()
