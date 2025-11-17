#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
d1={}

for line1 in f1:
	if "#" not in line1:
		list1=line1.strip().split()
		if list1[0]  in d1:
			continue
		else:
			d1[list1[0]]=list1

for k,v in d1.items():
	f2.write("{0}\n".format("\t".join(d1[k])))
f1.close()
f2.close()

