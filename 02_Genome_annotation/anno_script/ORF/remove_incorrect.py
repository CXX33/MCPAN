#!/usr/bin/env python3

import sys

i1 = open(sys.argv[1])  # evm.pep.correct.err.fa
i2 = open(sys.argv[2])  # Cucumber_hx117_chr.gff3_correct

d = []
for line in i1:
	if '>' in line:
		d.append(line.strip()[2:].split('.')[0])

for line in i2:
	if len(line.strip()) == 0:
		print(line.strip())
	else:
		line = line.strip().split()
		if line[-1].split(';')[0].split('=')[1].split('.')[0] not in d:
			print('\t'.join(line))
