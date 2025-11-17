#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')

for line1 in f1:
	if "#" in line1:continue
	list1=line1.strip().split()
	name="TE_"+list1[0]+"_"+list1[1]
	f2.write("{0}\t{1}\t{2}\t{3}\n".format(list1[0],list1[1],list1[2],name))

f1.close()
f2.close()
