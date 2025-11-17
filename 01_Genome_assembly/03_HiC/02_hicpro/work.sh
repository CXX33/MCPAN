#!/bin/bash
###Final Hi-C heatmap plot
ref=genome.fa
mkdir 01.ref 02.reads  
cd 01.ref
ln -s $ref
cd ..
cd 02.reads
ln -s /path_to/${i}_R1.fq.gz 
ln -s /path_to/${i}_R2.fq.gz
hicpro=/path_to/HiC-Pro-2.11.4/bin
python2 $hicpro/utils/digest_genome.py -r dpnii -o ${i}_chromosome.dpnii.txt ${ref}
samtools faidx ${ref}
awk '{print $1"\t"$2}'  ${ref}.fai > ${ref}.size
cp /path_to/HiC-Pro-2.11.4/config-hicpro.txt ./
mkdir $PWD/02.reads/sample
mv $PWD/02.reads/*.gz $PWD/02.reads/sample
HiC-Pro --input /path_to/$i/02.reads --output hicpro_output_chromosome --conf ./config-hicpro.txt
win_size=100000
~/miniconda2/bin/python2 /path_to/HiCPlotter-master/HiCPlotter.py -tri 1 -f /path_to/00_hicpro/$i/hicpro_output_chromosome/hic_results/matrix/sample/iced/${win_size}/sample_${win_size}_iced.matrix -bed /path_to/00_hicpro/$i/hicpro_output_chromosome/hic_results/matrix/sample/raw/${win_size}/sample_${win_size}_abs.bed -wg 1 -n ${i} -chr chr12 -fh 0 -r $win_size -hmc 3 -o ${i}_HiCPlot_${win_size} -ext pdf -dpi 226 -mm 10
