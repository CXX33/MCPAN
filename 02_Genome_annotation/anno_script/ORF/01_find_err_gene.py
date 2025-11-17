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
		#f2.write("%s%s\n"%(">",name))
	elif flag>=1:
		if "*" in line[0][1:-2]:
			f2.write("%s%s\n%s"%(">",name,eachline))	
		
		

f1.close()
f2.close()
