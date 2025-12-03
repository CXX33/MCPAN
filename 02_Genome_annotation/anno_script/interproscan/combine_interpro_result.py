#!/usr/bin/env python3

import sys

i1 = open(sys.argv[1])

d = {}
for line in i1:
	line = line.strip().split('~')
	d[line[0]] = []
i1.seek(0)

for line in i1:
	line = line.strip().split('~')
	d[line[0]].append(line[1]+' '+line[2]+';')

for k in d:
	print(k,end='\t')
	for i in d[k]:
		print(i,end='')
	print('')
		

	


