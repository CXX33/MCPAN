#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
groups = []
current_group = []
for line1 in f1:
	list1=line1.strip().split()
	seq1,seq2 = list1[0],list1[1]	
	if not current_group:
		current_group.append(seq1)
		current_group.append(seq2)
	elif seq1 == current_group[-1]:
		current_group.append(seq2)
	else:
		groups.append(current_group)
		current_group = [seq1, seq2]
if current_group:
	groups.append(current_group)
print(groups)
for group in groups:
	f2.write("{0}\n".format("\t".join(group)))
