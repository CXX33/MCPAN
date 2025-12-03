#!/public/software/bin/python
# calculate each seq length 


import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

flag=0
for eachline in f1:
	line=eachline.split()
	if ">" in eachline:
		name=line[0][1:]
		flag+=1
	elif flag>0:
		eachlen=len(line[0])
#		print(eachlen)
		f2.write("%s\t%s\n"%(name,eachlen))
		flag=0
f1.close()
f2.close()	
