#!/bin/bash
ont=ont.fa
hifi=hifi.fa
ref=genome.hifi.fa
qry=genome.ont.fa
#### 01.Gap filling by TGS_Gapcloser
tgsgapcloser --scaff $ref  --reads $ont --output ${i}_gapfill_r1 --minmap_arg '-x ava-ont' --thread 22 --min_match 1000 --ne
#### 02.Gap filling by LR_Gapcloser
LR_Gapcloser.sh -i $ref  -l $ont -s n -t 18  -o ${i}_ont
LR_Gapcloser.sh -i $ref  -l $hifi -s n -t 18  -o ${i}_hifi
#### 03.Gap filling by Complementarity between assmeblies using hifi-only, ont-only and hifi-ont
  # Align generating coordination in assemblies
~/miniconda3/bin/nucmer -t 20 --prefix ${name} $ref $qry && delta-filter -1  -q -r -l 15000 ${name}.delta > ${name}.filter.delta && mummerplot -f -s large -t png ${name}.filter.delta -p ${name} && show-coords -THrcl ${name}.filter.delta > ${name}.filter.coords
  #Organize the information near the gap into gapclosed_fasta.gap_info
  #Further validation alignment using BLAST
cat gapclosed_fasta.gap_info | while read i
do
       chr=`echo $i | awk '{print $1}'`
       s=`echo $i | awk '{print $4}'`
       e=`echo $i | awk '{print $5}'`
       s1=$((s-2000))
       e1=$((s-1))
       s2=$((e+1))
       e2=$((e+2000))
        ##echo "chr: $chr, s1: $s1, e1: $e1, s2: $s2, e2: $e2"
       samtools faidx $qry $chr:$s1-$e1 >> ${chr}_gap.fa
       samtools faidx $qry $chr:$s2-$e2 >> ${chr}_gap.fa
       blastall -p blastn -d $ref -i  ${chr}_gap.fa -o  ${chr}_gap.out -F F -m 9 -b 3 -e 1e-5 -a 1
done
  #Manual gap filling using complementary assemblies in no-gap regions
#### 04.Gap filling by manually retrieving high-quality reads near the gap
  # Aligning by winnowmap
meryl count k=15 output merylDB ${ref} && winnowmap -W repetitive_k15.txt -t 30 -ax map-ont $ref $ont | samtools view -F 256 -bS - > ${i}.ont.bam && samtools sort -@ 30 ${i}.ont.bam -o ${i}.ont.sort.bam && samtools index  ${i}.ont.sort.bam && rm  ${i}.ont.bam
  # Extract alignment information from bam Alignment
perl /path_to/get_the_detailed_mapping_information_from_bwa_bam_file.pl ${i}.ont.sort.bam 0 > ${i}.ont.sort.bam.info
perl /path_to/get_mapped_bed.ont.pl ${i}.ont.sort.bam.info ${i}_chromosome_map.ont.bed ${i}_chromosome_maybemap.ont.bed
  # Manual gap filling using reads in the gap regions of ${i}_chromosome_map.ont.bed
samtools faidx $ont gap.reads > gap_reads.fa
  #filling gap_reads.fa to gap region
