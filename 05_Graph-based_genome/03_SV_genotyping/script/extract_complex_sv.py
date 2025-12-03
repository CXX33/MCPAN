#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	if "#" not in line1:
		list1=line1.strip().split()
		if sum([float(i) for i in list1[3:7]]) <= 0.1:
			f2.write("{0}\n".format("\t".join(list1)))
f1.close()
f2.close()
