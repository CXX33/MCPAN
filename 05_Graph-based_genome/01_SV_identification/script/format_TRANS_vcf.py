#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
f3=open(sys.argv[3],'w')
n=0
f3.write("Translocation_ID\tseq_ref\tseq_alt\n")
for line1 in f1:
	if "#" in line1:
		f2.write(line1)
	else:
		list1=line1.strip().split()
		n+=1
		id="TRANS_"+str(n)
		seq1=list1[3]
		seq2=list1[4]
		f3.write("{0}\t{1}\t{2}\n".format(id,seq1,seq2))
		f2.write("{0}\t{1}\t{2}\t{3}\n".format(list1[0],list1[1],id,"\t".join(list1[9:])))
f1.close()
f2.close()
f3.close()
