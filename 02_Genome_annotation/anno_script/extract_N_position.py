#!/public/software/bin/python
#find repeat seq position
########2017.08.24##################

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

linenumber=0
for eachline in f1:
	line=eachline.split()
	linenumber+=1
	if ">" in eachline:
		if linenumber>1:
			if number_N>0:
				f2.write("%s\n"%(number))	
				number_N=0
				name=''.join(line[0][1:])
				number=0
			else:
				name=''.join(line[0][1:])
				number=0
				number_N=0
		else:
			name=''.join(line[0][1:])
			number=0
			number_N=0
	else:
		for i in line[0]:
			number+=1
			if i=="N":
				number_N+=1
				if number_N<=1:
					f2.write("%s\t%s\t"%(name,number))
			else:
				if number_N>0:
					f2.write("%s\n"%(number-1))
					number_N=0
				else:
					pass
f1.close()
f2.close()
