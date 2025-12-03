#!/public/software/bin/python
# extract command line from genblasta reslut to do genewise 
###################2016.12.20###############################


import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3],'w')

dict={}
for i in f1:
	name=i.split()
	dict[name[0]]=name[1]	
for eachline in f2:
	line=eachline.split()
#	h="cucumber_contig_oneline_masked_oneline.fa"
	h="9930.fa.masked"
	c=line[1]
	d="/public/agis/huangsanwen_group/wangxin/software/wise2.4.1/src/bin/genewise"
	start=int(float(line[2]))-1000
	end=int(float(line[3]))+1000
	m=str(line[0])+".fa"
	j=str(line[1])+".fa"
	if start <0 and end <dict[c]:
		f3.write('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n'%(d," ","-both"," ","-gff"," ","-quiet"," ","-u"," ","0"," ","-v"," ",end," ","./ref_seq/",m," ./genome_seq/",c,".fa"," ",">> ./genewise_out/hystrix","_",str(line[0]),"_",str(line[1])))
	elif start >0 and end <dict[c]:
		f3.write('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n'%(d," ","-both"," ","-gff"," ","-quiet"," ","-u"," ",start," ","-v"," ",end," ","./ref_seq/",m," ./genome_seq/",c,".fa"," ",">> ./genewise_out/hystrix","_",str(line[0]),"_",str(line[1])))
	elif start >0 and end >dict[c]:
		f3.write('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n'%(d," ","-both"," ","-gff"," ","-quiet"," ","-u"," ",start," ","-v"," ",dict[c]," ","./ref_seq/",m," ./genome_seq/",c,".fa"," ",">> ./genewise_out/hystrix","_",str(line[0]),"_",str(line[1])))
	elif start <0 and end >dict[c]:
		f3.write('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n'%(d," ","-both"," ","-gff"," ","-quiet"," ","-u"," ","0"," ","-v"," ",dict[c]," ","./ref_seq/",m," ./genome_seq/",c,".fa"," ",">> ./genewise_out/hystrix","_",str(line[0]),"_",str(line[1])))


f1.close()
f2.close()
f3.close()
