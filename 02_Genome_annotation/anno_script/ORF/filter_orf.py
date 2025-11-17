#!/usr/bin/python
#####filter the longest orf sequences

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

name=''
number=0
for eachline in f1:
	line=eachline.split("\t")
	number+=1
	#print(eachline,line[3])
	if line[0]!=name:
		if number<=1:
			name=line[0]
			start=int(line[1])
			end=int(line[2])
			length=int(line[3])
		elif number>1:
			f2.write("%s\t%s\t%s\t%s\n"%(name,start,end,length))
			name=line[0]
			start=int(line[1])
			end=int(line[2])
			length=int(line[3])
	if line[0]==name:
		#print(eachline)
		if int(line[3])<=length:
			pass
		if int(line[3])>length:
			length=int(line[3])
			start=int(line[1])
			end=int(line[2])
	
f1.close()
f2.close()
