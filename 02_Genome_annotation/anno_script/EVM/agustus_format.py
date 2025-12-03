#!/public/agis/huangsanwen_group/wangxin/bin/python
#change augusts format

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

for eachline in f1:
	if "#" or "###" not in eachline:
#		line=eachline.split()
		if "gene" and "AUGUSTUS"in eachline:
			line=eachline.split()
#			print(line[7])
			f2.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s%s%s%s%s\n%\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s%s%s%s%s\n'%(line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7],"ID=",line[8],";","Name=",line[8],line[0],line[1],"mRNA",line[3],line[4],line[5],line[6],line[7],"ID=",line[8],";","Parent=",line[8]))
		elif "exon" and "AUGUSTUS" in eachline:
			line=eachline.split()
			a=line[8].split(";")
			f2.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s%s%s%s%s\n'%(line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7],"ID=",a[0],";","Name=",a[1]))
		elif "CDS"and "AUGUSTUS" in eachline:
			line=eachline.split()
			a=line[8].split(";")
			f2.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s%s%s%s%s\n'%(line[0],line[1],line[2],line[3],line[4],line    [5],line[6],line[7],"ID=",a[0],";","Name=",a[1]))
		else:
			pass
f1.close()
f2.close()

