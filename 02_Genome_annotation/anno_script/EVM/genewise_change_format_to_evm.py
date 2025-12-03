#!/public/agis/huangsanwen_group/zhangshu/Bin/python3
#sed 's/match/gene/g'
import re
import sys

input=open(sys.argv[1])#genewise out
output=open(sys.argv[2],'w')#out file

a=0
for eachline in input:
	line=eachline.split()
	if "GeneWise"  in eachline:
		if line[2]=="gene":
			a=a+1
			exon=0
			cds=0
			gene_id=line[0]+'-'+'.'+str(a)
			gene_ID='ID='+gene_id
			gene_name='Name='+gene_id+'.gene'
			gene_write=gene_ID+';'+gene_name
			output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7],gene_write))
			mrna_id=gene_ID+'.m1'
			mrna_parent='Parent='+gene_id
			mrna_write=mrna_id+';'+mrna_parent
			output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(line[0],line[1],'mRNA',line[3],line[4],line[5],line[6],line[7],mrna_write))
		if line[2]=="cds":
			cds+=1
			exon+=1
			cds_id=gene_ID+'.cds'+str(cds)
			cds_parent='Parent='+mrna_id[3:]
			cds_write=cds_id+';'+cds_parent
			exon_write=re.sub('cds','exon',cds_write)
			output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(line[0],line[1],'exon',line[3],line[4],line[5],line[6],line[7],exon_write))
			output.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7],cds_write))
input.close();output.close()
