#!/usr/bin/env python3
import sys
f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')
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
for k,v in gene.items():
	if "N" not in v:
		f2.write(">{0}\n{1}\n".format(k,v))
f1.close()
f2.close()
