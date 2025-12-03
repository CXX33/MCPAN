#!/public/software/bin/python
####chang the stringtie format for EVM

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

flag=0
for eachline in f1:	
	if "#" not in eachline:
		line=eachline.split()
		format=line[2]
		length=int(line[4])-int(line[3])+1
		w="\t".join(line[:8])
		ID="ID="+(''.join(line[9][1:-2]))+";"
		target="Target="+(''.join(line[11][1:-2]))
		#print(length)
		if format=="transcript":
			number=1
			flag=1
		elif format=="exon":
			if flag>0:
				start="1"
				end=1+length
				stand=" "+str(start)+" "+str(end)
				f2.write("%s\t%s%s%s\n"%(w,ID,target,stand))
				flag=0
			else:
				stand=" "+str(end+1)+" "+str(end+length)
				end=end+length
				f2.write("%s\t%s%s%s\n"%(w,ID,target,stand))
f1.close()
f2.close()
			
