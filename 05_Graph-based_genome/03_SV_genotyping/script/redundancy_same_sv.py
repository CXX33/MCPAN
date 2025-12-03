#!/usr/bin/env python3
import sys
from collections import Counter
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
d1={}
d2={}
for line1 in f1:
	list1=line1.strip().split()
	if list1[0] in d1:
		d1[list1[0]].append(list1[-1])
	else:
		d1[list1[0]]=[list1[-1]]
for k1 in d1.keys():
	counter = Counter(d1[k1])
	d2[k1]=counter.most_common(1)[0][0]
for k2 in d2.keys():
	f2.write("{0}\t{1}\n".format(k2,d2[k2]))
f1.close()
f2.close()
