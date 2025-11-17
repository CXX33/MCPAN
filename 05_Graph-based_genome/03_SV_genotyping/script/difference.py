#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'r')
f3=open(sys.argv[3],'w')
d1={}
for line1 in f1:
	list1=line1.strip().split()
	d1[list1[0]+"_"+list1[1]]=""
for line2 in f2:
	if "#" not in line2:
		list2=line2.strip().split()
		if str(int(list2[0][3:]))+"_"+list2[1] in d1:
			continue
		else:
			list2[0]=str(int(list2[0][3:]))
			f3.write("{0}\n".format("\t".join(list2)))
f1.close()
f2.close()
f3.close()
