#!/bin/bash
### Scanned for repetitive elements
ref=genome.fa
for i in {01..12}
do
	samtools faidx $ref chr${i} > chr${i}.fa
	quick_qsub =trf_${i}= {-q cu -l nodes=1:ppn=1} "trf chr${i}.fa 2 7 7 80 10 50 500 -f -d -m -h &&  trf2gff -i chr${i}.fa.2.7.7.80.10.50.500.dat"

done
