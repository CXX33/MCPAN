###!/usr/bin/python

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

flag=0
for eachline in f1:
	line=eachline.split()
	if ">" in eachline:
		name=''.join(line[0][1:])
		flag=1
	elif flag>=1:
		if line[0][0]!="M" or line[0][-1]!="*":
			f2.write("%s%s\n%s"%(">",name,eachline))


