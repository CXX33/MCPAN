#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'r')
f3=open(sys.argv[3],'w')
d1={}
for line1 in f1:
	list1=line1.strip().split()
	d1[list1[0]+"~"+list1[1]]=""
for line2 in f2:
	if "#" in line2:continue
	list2=line2.strip().split()
	k=str(int(list2[0][3:]))+"~"+list2[1]
	if k in d1:
		continue
	else:
		f3.write("{0}\t{1}\n".format(list2[0],list2[1]))
f1.close()
f2.close()
f3.close()
