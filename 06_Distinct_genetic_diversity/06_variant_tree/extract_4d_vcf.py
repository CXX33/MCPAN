#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'r')
f3=open(sys.argv[3],'w')
d={}
for line1 in f1:
	list1=line1.strip().split()
	d[list1[0]+"~"+list1[1]]=""
for line2 in f2:
	if "#" in line2:
		f3.write(line2)
	else:
		list2=line2.strip().split()
		if list2[0]+"~"+list2[1] in d:
			f3.write(line2)
f1.close()
f2.close()
f3.close()	
