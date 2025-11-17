#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	list1=line1.strip().split()
	name=list1[8].split(";")[0].split("=")[1]
	cons_seq=list1[8].split(";")[8].split("=")[1]
	f2.write(">{0}\n{1}\n".format(name,cons_seq))
f1.close()
f2.close()
