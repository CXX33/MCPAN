#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	if "#" in line1:
		f2.write(line1)
	else:
		list1=line1.strip().split()
		list1[3]="0"
		list1[4]="1"
		f2.write("{0}\n".format("\t".join(list1)))
