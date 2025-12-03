#!/public/software/bin/python
# extract each seq

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

number=0
for eachline in f1:
	line=eachline.split()
	name=line[0][1:]
	number+=1
	f2.write("%s%s%s%s%s%s\n"%("/home/chenxinxiu/bin/give_me_one_seq.pl ","/home/chenxinxiu/work/pan-genome_for_melon/10_genome_assembly/10_genome_annotation/ref_masked/MC115_chromosome.final.fasta.mod.MAKER.masked ",name," >./seq/",number,".fa"))


f1.close()
f2.close() 
