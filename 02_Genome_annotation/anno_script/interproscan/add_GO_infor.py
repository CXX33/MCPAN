#!/usr/bin/env python
##find GO annot acord the interpro_GO result

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3],'w')

flag=0
dict={}
dict2={}
for eachline in f1:
	line=eachline.split()
	w=" ".join(line[1:])
	if "[Term]" in eachline:
		flag+=1
	elif flag>0:
		if "id:" in eachline:
			id=line[1]
		elif "name:" in eachline:
			dict[id]=w
			flag=0
#print(dict)
for eachline in f2:
	i=eachline.split()
#	print(len(i))
	length=len(i)
	dict2[i[0]]=i[0]+"\t"
	for num in range(1,length):
		GO_id=i[num]
		if GO_id in dict:
			GO_infor=dict[GO_id]
			dict2[i[0]]=dict2[i[0]]+GO_id+" "+GO_infor+";"
		else:
			GO_infor='-'
			dict2[i[0]]=dict2[i[0]]+GO_id+" "+GO_infor+";"
for a in dict2:
	f3.write("%s\n"%(dict2[a]))
