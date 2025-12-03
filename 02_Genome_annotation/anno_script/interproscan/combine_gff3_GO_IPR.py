#!/usr/bin/env python3

import sys

i1 = open(sys.argv[1]) # go infor
i2 = open(sys.argv[2]) # ipr infor
i3 = open(sys.argv[3]) # gff3

d_go = {}
for line in i1:
	line = line.strip().split('\t')
	d_go[line[0][:-2]] = line[1]

d_ipr = {}
for line in i2:
	line = line.strip().split('\t')
	d_ipr[line[0][:-2]] = line[1]

print('#Chr\tstart\tend\tGene_ID\tGO\tIPR')
for line in i3:
	line = line.strip()
	if len(line) != 0 and "#" not in line:
		if 'gene' in line.split()[2]:
			line = line.split()
			gene_id = line[-1].split(';')[0].split('=')[1]
			if gene_id in d_go and gene_id in d_ipr:
				print(line[0],line[3],line[4],gene_id,d_go[gene_id],d_ipr[gene_id],sep='\t')
			elif gene_id in d_go and gene_id not in d_ipr:
				print(line[0],line[3],line[4],gene_id,d_go[gene_id],'-',sep='\t')
			elif gene_id not in d_go and gene_id in d_ipr:
				print(line[0],line[3],line[4],gene_id,'-',d_ipr[gene_id],sep='\t')
			elif gene_id not in d_go and gene_id not in d_ipr:
				print(line[0],line[3],line[4],gene_id,'-','-',sep='\t')
