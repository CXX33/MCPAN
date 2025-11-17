#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	if "#" in line1:continue
	list1=line1.strip().split()
	if len(list1[3].split(",")[0]) >= len(list1[4].split(",")[0]):
		f2.write(">{0}\n{1}\n".format(list1[0]+"_"+list1[1],list1[3].split(",")[0]))
	if len(list1[3].split(",")[0]) <= len(list1[4].split(",")[0]):
		f2.write(">{0}\n{1}\n".format(list1[0]+"_"+list1[1],list1[4].split(",")[0]))

f1.close()
f2.close()
