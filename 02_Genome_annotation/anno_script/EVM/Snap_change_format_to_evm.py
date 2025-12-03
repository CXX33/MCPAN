#!/public/agis/huangsanwen_group/zhangshu/Bin/python3

import re
import sys

input=open(sys.argv[1])#augustus_out
output=open(sys.argv[2],'w')#out file
output1=open('log','w')#log
gene_list={}

dict_log={}
for eachline in input:
	line=eachline.split()
	if line!=[] and line[0][0]!="#":
		if line[6]=="-":
			if line[-1] in dict_log:
				dict_log[line[-1]].append(eachline.strip())
			if line[-1] not in dict_log:
				dict_log[line[-1]]=[]		
				dict_log[line[-1]].append(eachline.strip())
input.seek(0)
list=[]
for eachline in input:
	line=eachline.split()
	if line!=[] and line[0][0]!="#":
		if line[6]=="+":
			output1.write(eachline)
		if line[6]=="-":
			if line[-1] not in list:
				list.append(line[-1])
				dict_log[line[-1]].reverse()			
				for i in dict_log[line[-1]]:
					output1.write(i+'\n')

output1.close()
input.close()

input=open('log')


dict={}
for eachline in input:
	line=eachline.split()
	if line!=[] and line[0][0]!="#":
		if line[-1] in dict:
			end=max(int(line[4]),end)
			dict[line[-1]][1]=end
		if line[-1] not in dict:
			start=int(line[3])
			dict[line[-1]]=[0,0]
			dict[line[-1]][0]=start
			end=int(line[4])
			dict[line[-1]][1]=end

input.seek(0)
for eachline in input:
	line=eachline.split()
	if line!=[] and line[0][0]!="#":
		if line[-1] in gene_list:
			exon+=1
			cds+=1
			exon_id='ID='+line[-1].split('=')[1]+'.exon'+str(exon)+';Parent='+line[-1].split('=')[1]+'.m1'
			cds_id='ID='+line[-1].split('=')[1]+'.cds'+str(cds)+';Parent='+line[-1].split('=')[1]+'.m1'
			output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(line[0],line[1],'exon',line[3],line[4],line[5],line[6],'0',exon_id))
			output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(line[0],line[1],'CDS',line[3],line[4],line[5],line[6],'0',cds_id))
		if line[-1] not in gene_list:
			gene_list[line[-1]]=''
			gene_id='ID='+line[-1].split('=')[1]+';'+line[-1]+'.gene'
			mrna_id='ID='+line[-1].split('=')[1]+'.m1;Parent='+line[-1].split('=')[1]
			exon=1
			cds=1
			exon_id='ID='+line[-1].split('=')[1]+'.exon'+str(exon)+';Parent='+line[-1].split('=')[1]+'.m1'
			cds_id='ID='+line[-1].split('=')[1]+'.cds'+str(cds)+';Parent='+line[-1].split('=')[1]+'.m1'
			output.write('%s\t%s\t%s\t%d\t%d\t%s\t%s\t%s\t%s\n'%(line[0],line[1],'gene',dict[line[-1]][0],dict[line[-1]][1],line[5],line[6],'0',gene_id))
			output.write('%s\t%s\t%s\t%d\t%d\t%s\t%s\t%s\t%s\n'%(line[0],line[1],'mRNA',dict[line[-1]][0],dict[line[-1]][1],line[5],line[6],'0',mrna_id))
			output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(line[0],line[1],'exon',line[3],line[4],line[5],line[6],'0',exon_id))
			output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(line[0],line[1],'CDS',line[3],line[4],line[5],line[6],'0',cds_id))
input.close();output.close()
