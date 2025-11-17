#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	if "#" in line1:
		#f2.write(line1)
		continue
	else:
		list1=line1.strip().split()
		sorted_data = sorted([int(x) for x in list1[0:4]], reverse=True)
		second_largest = str(int(sorted_data[1]))
		second_largest_index=list1.index(second_largest)
		if second_largest_index==0:
			f2.write("{0}\t{1}\n".format("A",list1[-1]))
		if second_largest_index==1:
			f2.write("{0}\t{1}\n".format("T",list1[-1]))
		if second_largest_index==2:
			f2.write("{0}\t{1}\n".format("C",list1[-1]))
		if second_largest_index==3:
			f2.write("{0}\t{1}\n".format("G",list1[-1]))
f1.close()
f2.close()

