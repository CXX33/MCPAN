#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
f2.write("#A\tT\tC\tG\n")
n=0
for line1 in f1:
	list1=line1.strip().split()
	a=list1[0].count("A")
	t=list1[0].count("T")
	c=list1[0].count("C")
	g=list1[0].count("G")
	n+=1
	f2.write("{0}\t{1}\t{2}\t{3}\t{4}\n".format(a,t,c,g,n))
f1.close()
f2.close()
