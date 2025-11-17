#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	if "#" in line1:
		f2.write(line1)
	else:
		list1=line1.strip().split()
		#if "," in list1[3]:
		#	print(line1)
		if "," in list1[4]:
			list1[4]=list1[4].split(",")[0]
			for i in range(9,len(list1)):
				if list1[i] !="0/0" and list1[i].split("/")[0] == list1[i].split("/")[1]:
					list1[i]="1/1"
		f2.write("{0}\n".format("\t".join(list1)))
f1.close()
f2.close()
