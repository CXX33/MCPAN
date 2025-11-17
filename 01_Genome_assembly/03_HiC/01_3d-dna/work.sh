#!/bin/bash
###Contig anchored using 3D-DNA with Juicebox
ref=contig.fa
mkdir scripts references fastq restriction_sites
cp -r /path_to/juicer-1.6/CPU/common scripts/
cd references/
ln -s $ref
bwa index $ref
cp /path_to/juicer-1.6/misc/generate_site_positions.py $PWD/../
python ../generate_site_positions.py DpnII $ref $ref
awk 'BEGIN{OFS="\t"}{print $1, $NF}'  ${ref}_DpnII.txt > ${ref}.chrom.sizes
cd ..
cp references/${ref}_DpnII.txt restriction_sites/
cd fastq
ln -s /path_to/${i}_R1.fastq.gz
ln -s /path_to/${i}_R2.fastq.gz
cd ..
bash /path_to/juicer-1.6/CPU/juicer.sh -t 30 -s DpnII -g ${i} -d /path_to/01_3d_dna/${i} -D /path_to/01_3d_dna/${i} -z /path_to/01_3d_dna/references/${ref} -p /path_to/references/${ref}.chrom.sizes -y /path_to/restriction_sites/${ref}_DpnII.txt
mv /path_to/aligned/merged_nodups.txt /path_to/aligned/${i}.mnd
bash /path_to/3d-dna-master/run-asm-pipeline.sh -m haploid -i 15000 -r 0 /path_to/references/${ref} /path_to/aligned/${i}.mnd
#### ${i}.review.assembly: corrected output by Juicebox
bash /path_to/3d-dna-master/run-asm-pipeline-post-review.sh -r ${i}.review.assembly /path_to/references/${i}.hifiasm.fa /path_to/aligned/${i}.mnd
