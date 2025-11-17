#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
n1=0
n2=0
for line1 in f1:
	if "#" in line1:
		f2.write(line1)
	else:
		list1=line1.strip().split()
		list1[3]=list1[3].upper()
		list1[4]=list1[4].upper()
		list1[7]="."
		if len(list1[3])>len(list1[4]):
			n1+=1
			list1[2]="DEL_"+str(n1)
			
		if len(list1[3])<len(list1[4]):
			n2+=1
			list1[2]="INS_"+str(n2)
		f2.write("{0}\n".format("\t".join(list1)))
f1.close()
f2.close()
