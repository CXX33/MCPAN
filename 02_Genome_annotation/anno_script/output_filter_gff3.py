#!/usr/bin/env python3

import sys

i1 = open(sys.argv[1])  # trainSet.lst
i2 = open(sys.argv[2])  # best_candidates.gff3

d = {}
for line in i1:
	d[line.strip()] = ''
	d[line.strip().replace('|m', '|g')] = ''

for line in i2:
	if len(line.strip()) == 0:
		print(line.strip())
	else:
		line = line.strip()
		sline = line.split()
		if sline[-1].split(';')[0].split('=')[1].split('.exon')[0] in d or sline[-1].split(';')[0].split('=')[1].split('.utr')[0] in d or sline[-1].split(';')[0].split('=')[1].replace('cds.', '') in d:
			print(line)
