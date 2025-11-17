#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	if "#" in line1:
		f2.write(line1)
	else:
		list1=line1.strip().split()
		sorted_data = sorted([int(x) for x in list1[0:4]], reverse=True)
	#	print(sorted_data)
		second_largest = int(sorted_data[1])
		if second_largest >=300:
			f2.write(line1)
f1.close()
f2.close()

