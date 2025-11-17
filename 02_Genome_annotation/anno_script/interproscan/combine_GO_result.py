#!/usr/bin/env python
##combin GO annot from interproscan result

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

dict={}
number=0


for eachline in f1:
	line=eachline.split()
	if line[0] not in dict:
		number=0
		for a in line:
			number+=1
			if number<=1:
				dict[line[0]]="\n"+a
			else:		
				dict[line[0]]=dict[line[0]]+"\t"+a
	elif line[0] in dict:
		length=len(line)	
		for i in range(1,length):
			if line[i] in dict[line[0]]:
				pass
			elif line[i] not in dict[line[0]]:
				dict[line[0]]=dict[line[0]]+"\t"+line[i]


for m in dict:
	f2.write("%s"%(dict[m]))

f1.close()
f2.close()	
