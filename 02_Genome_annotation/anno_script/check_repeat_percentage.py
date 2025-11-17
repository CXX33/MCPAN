#!/public/bin/software
#calculate repeat seq pencentage 
################2016.12.21###############

import sys


f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

flag=0
dict={}

tw=0
th=0
fou=0
for eachline in f1:
	line=eachline.split()
	if ">" in eachline :
		name=line[0][1:]
		dict={name:0}
		flag+=1
	elif flag >0:
		seq_len=len(eachline)
		flag=0
		for i in line[0]:
			if i =="N":
				dict[name]+=1
			else:
				pass
		pencent=float(dict[name])/float(seq_len)
		f2.write("%s\t\t\t%s\t\t%s\n"%(name,pencent,seq_len))
#		if pencent >=0.7:
#			tw+=1
#		elif pencent >=0.7:
#			th+=1
#		elif pencent >=0.9:
#			fou+=1
#print(tw)
f1.close()
f2.close()
