#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r') ## TE index
f2=open(sys.argv[2],'r') ## sv vcf of syri
f3=open(sys.argv[3],'w')
d1={} ## TE index
for line1 in f1:
	list1=line1.strip().split()
	d1[list1[-1]]=line1
for line2 in f2:
	if "#" in line2:continue
	list2=line2.strip().split()
	name="TE_"+list2[0]+"_"+list2[1]
	end=list2[-1].split(";")[0].split("=")[1]
	if "DEL" in list2[2]:
		if name in d1:
			f3.write("{0}\t{1}\t{2}\t{3}\n".format(list2[0],list2[1],end,name))
f1.close()
f2.close()
f3.close()
