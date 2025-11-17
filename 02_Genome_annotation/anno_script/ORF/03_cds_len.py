#!/usr/bin/python
###########the length of cds most > 30bp

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3],'w')

dict={}

for eachline in f1:
	line=eachline.split()
	infor=line[1]+"\t"+line[2]+"\t"+line[3]+"\t"+line[4]
	dict[">"+line[0]]=infor

flag=0
for eachline in f2:
	i=eachline.split()
	if ">" in eachline :
		if i[0] in dict:
			flag=1
			name=''.join(i[0][1:])
			gene=i[0]
			start=int(dict[i[0]].split("\t")[0])-1
			end=int(dict[i[0]].split("\t")[1])
			number=0
		else:
			flag=0
			
	elif flag>=1:
		for a in i[0][start:end]:
			if a!="N":
				number+=1

		f3.write("%s\t%s\t%s\n"%(name,dict[gene],number))
f1.close()
f2.close()
f3.close()
