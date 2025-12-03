#
##remove the same name which the seq have

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3],'w')

dict={}
for eachline in f1:
	line=eachline.split()
	dict[line[0]]=line[0]
#print(dict)
flag=0
for eachline in f2:
	i=eachline.split()	
	if ">" in eachline:
#		print(i[0])
		if i[0] not in dict:
			flag+=1
			f3.write("%s"%(eachline))
		else:
			pass
	elif flag>0:
		f3.write("%s"%(eachline))
		flag=0


f1.close()
f2.close()
f3.close()
