#!/usr/bin/python
#change pasa.gff format


import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

for eachline in f1:
	line=eachline.split()
	a=line[8].split("=")[1]
#	b=(a.join("\t")+"\n")
	f2.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s%s%s%s\n'%(line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7],line[8],";"," Parent=",a))
