#!/bin/bash
### Identity heatmaps of centrometic sequence
conda activate snakemake
cat P114.Cent.bed | while read i
do
       chr=`echo $i | awk '{print $1}'`
       sta=`echo $i | awk '{print $2}'`
       end=`echo $i | awk '{print $3}'`
       samtools faidx /path_to/P114.final.fasta $chr:$sta-$end > ${chr}/${chr}.cent.fa
       samtools faidx ${chr}/${chr}.cent.fa
done
source activate
source deactivate
conda activate snakemake

cat P114.Cent.other.bed | while read i
do
        n1=`echo $i | awk '{print $1}'`
        n4=`echo $i | awk '{print $4}'`
        mkdir $n1
        cd /path_to/software/StainedGlass-0.6
        snakemake --cores 24 --config sample=${n1} fasta=${path}/${n1}/${n1}.cent.fa window=${n4}
        snakemake --cores 24 make_figures --config sample=${n1} fasta=${path}/${n1}/${n1}.cent.fa window=${n4}
        mv results ${path}/${n1}
done
conda deactivate
