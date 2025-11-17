#!/public/software/bin/python
# extract command line from genblasta reslut to do genewise 
###################2016.12.20###############################


import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3],'w')
f4=open(sys.argv[4],'w')
dict={}
for i in f1:
	name=i.split()
	dict[name[0]]=name[1]	
for eachline in f2:
	line=eachline.split()
	a="/public/agis/huangsanwen_group/liqing/annot/scripts/give_me_one_seq.pl"
	b="/public/agis/huangsanwen_group/liqing/annot/ref/Ath_SLY_VVY_sprot.fasta"
#	h="cucumber_contig_oneline_masked_oneline.fa"
	h="./9930.fa.masked"
	c=line[1]
	start=int(float(line[2]))-1000
	end=int(float(line[3]))+1000
	m=str(line[0])+".fa"
	j=str(line[1])+".fa"
	if start <0 and end <dict[c]:
		f3.write('%s%s%s%s%s%s%s%s\n'%(a," ",h," ",str(line[1])," ",">./genome_seq/",j))
		f4.write('%s%s%s%s%s%s%s%s\n'%(a," ",b," ",str(line[0])," ",">./ref_seq/",m))
	elif start >0 and end <dict[c]:
		f4.write('%s%s%s%s%s%s%s%s\n'%(a," ",b," ",str(line[0])," ",">./ref_seq/",m))
		f3.write('%s%s%s%s%s%s%s%s\n'%(a," ",h," ",str(line[1])," ",">./genome_seq/",j))
	elif start >0 and end >dict[c]:
		f4.write('%s%s%s%s%s%s%s%s\n'%(a," ",b," ",str(line[0])," ",">./ref_seq/",m))
		f3.write('%s%s%s%s%s%s%s%s\n'%(a," ",h," ",str(line[1])," ",">./genome_seq/",j))
	elif start <0 and end >dict[c]:
		f4.write('%s%s%s%s%s%s%s%s\n'%(a," ",b," ",str(line[0])," ",">./ref_seq/",m))
		f3.write('%s%s%s%s%s%s%s%s\n'%(a," ",h," ",str(line[1])," ",">./genome_seq/",j))


f1.close()
f2.close()
f3.close()
f4.close()
