#!/usr/bin/python
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
		seq=line1[3]+line1[5]+line1[68]+line1[71]+line1[130]+line1[136]+line1[149]+line1[204]+line1[238]+line1[282]
gene[name]=seq
gene.pop('')
for k,v in gene.items():
	f2.write(">{0}\n{1}\n".format(k,v))
