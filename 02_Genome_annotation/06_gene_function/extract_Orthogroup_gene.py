#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	list1=line1.strip().split()
	gene=list1[1]
	f2.write("{0}\t{1}\n".format(list1[0].split(":")[0],gene))
f1.close()
f2.close()
