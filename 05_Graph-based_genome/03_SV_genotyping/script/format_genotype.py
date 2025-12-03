#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'r')
f3=open(sys.argv[3],'w')
d1={}
for line1 in f1:
	list1=line1.strip().split()
	for w in list1:
		d1[w]=list1[1]
for line2 in f2:
	list2=line2.strip().split()
	if "TEindex" ==list2[0]:
		f3.write("{0}\n".format("\t".join(list2)))
	else:
		if list2[0] in d1:
			list2[0]=d1[list2[0]]
		num=[int(i) for i in list2[1:6]]
		if sum(num)>=2:
			f3.write("{0}\n".format("\t".join(list2)))
f1.close()
f2.close()
f3.close()
