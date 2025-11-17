#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	if "#" not in line1:
		list1=line1.strip().split()
		ref_chr=list1[0]
		ref_sta=list1[1]
		ref_end=list1[7].split(";")[0].split("=")[1]
		qry_chr=list1[7].split(";")[1].split("=")[1]
		qry_sta=list1[7].split(";")[2].split("=")[1]
		qry_end=list1[7].split(";")[3].split("=")[1]
		f2.write("{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n".format(ref_chr,ref_sta,ref_end,qry_chr,qry_sta,qry_end))
f1.close()
f2.close()
