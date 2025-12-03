#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
d1={}
for line1 in f1:
	if "#" not in line1:
		list1=line1.strip().split()
		if float(list1[2]) >=95:
			if list1[0] != list1[1]:
				if list1[0].split("_")[0]==list1[1].split("_")[0]:
					if abs(int(list1[0].split("_")[1])-int(list1[1].split("_")[1]))<=5:
						if list1[0] not in d1 and list1[1] not in d1:
							d1[list1[0]]=list1
for k in d1.keys():
	f2.write("{0}\n".format("\t".join(d1[k])))
f1.close()
f2.close()
