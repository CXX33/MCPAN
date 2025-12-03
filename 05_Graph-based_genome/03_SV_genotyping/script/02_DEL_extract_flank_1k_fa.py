#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r') ###fasta
f2=open(sys.argv[2],'r') ###TE info
f3=open(sys.argv[3],'w')

gene={}
name=''
seq=''
for line1 in f1:
	line1=line1.strip()
	if '>' in line1:
		gene[name]=seq
		seq=''
		name=line1.split()[0][1:]
	elif '>' not in line1:
		seq+=line1
gene[name]=seq
gene.pop('')
for line2 in f2:
	list2=line2.strip().split()
	sta=int(list2[1])-1-1000
	end=int(list2[2])+1000
	target_seq=gene[list2[0]][sta:end]
	f3.write(">{0}\n{1}\n".format(list2[3],target_seq))	

f1.close()
f2.close()
f3.close()
