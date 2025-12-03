#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r') ### 0.8
f2=open(sys.argv[2],'r') ### 0.6
f3=open(sys.argv[3],'w')
d1={}
for line1 in f1:
	if "#" in line1:
		f3.write(line1)
	else:
		list1=line1.strip().split()
		d1[list1[0]+"~"+list1[1]]=list1
		f3.write(line1)
for line2 in f2:
	if "#" in line2:
		continue
	else:
		list2=line2.strip().split()
		if list2[0]+"~"+list2[1] in d1:
			#f3.write("{0}\n".format("\t".join(d1[list2[0]+"~"+list2[1]])))
			continue
		else:
			f3.write(line2)
