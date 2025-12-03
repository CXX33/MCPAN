#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	if "Query_id" in line1:continue
	list1=line1.strip().split()
	pos=list1[0].split("_")[1]
	chr=list1[0].split("_")[0]
	sta=int(pos)-5000
	end=int(pos)+5000
	f2.write("{0}\t{1}\t{2}\n".format(chr,sta,end))
f1.close()
f2.close()
