#!/bin/bash
### Whole-genome coverage analysis using ONT and HiFi reads
# ONT bam
meryl count k=15 output merylDB ${ref} && winnowmap -W repetitive_k15.txt -t 30 -ax map-ont $ref $ont | samtools view -@ 30 -bS - > ${i}.ont.bam && samtools sort -@ 30 ${i}.ont.bam -o ${i}.ont.sort.bam && samtools index  ${i}.ont.sort.bam && rm  ${i}.ont.bam
# HiFi bam
winnowmap -W repetitive_k15.txt -t 24 -ax map-pb $ref $hifi | samtools view -@ 24 -bS - > ${i}.hifi.bam && samtools sort -@ 24 ${i}.hifi.bam -o ${i}.hifi.sort.bam && samtools index ${i}.hifi.sort.bam && rm ${i}.hifi.bam
# Get the detailed mapping information from bwa bam file
perl /path_to/get_the_detailed_mapping_information_from_bwa_bam_file.pl ${i}.hifi.sort.bam 0 > ${i}.hifi.sort.bam.info
perl /path_to/get_the_detailed_mapping_information_from_bwa_bam_file.pl ${i}.ont.sort.bam 0 > ${i}.ont.sort.bam.info
# Get mapped region
perl /path_to/get_mapped_bed.ont.pl ${i}.ont.sort.bam.info ${i}_chromosome_map.ont.bed ${i}_chromosome_maybemap.ont.bed
perl /path_to/get_mapped_bed.hifi.pl ${i}.hifi.sort.bam.info ${i}_chromosome_map.hifi.bed ${i}_chromosome_maybemap.hifi.bed
for w in hifi ont
do
less -S ${i}_chromosome_map.${w}.bed | sort -k1,1 -k2,2n >  ${i}_chromosome_map.${w}.final.bed && rm ${i}_chromosome_map.${w}.bed
less -S ${i}_chromosome_maybemap.${w}.bed | sort -k1,1 -k2,2n >  ${i}_chromosome_maybemap.${w}.final.bed && rm ${i}_chromosome_maybemap.${w}.bed
done
# Calculate coverage per window
samtools faidx genome.fa && less -S /path_to/genome.fai | awk '{print $1"\t"$2}' > genome.size
for w in hifi ont
do
bedtools genomecov -i ${i}_chromosome_map.${w}.final.bed  -g genome.size -bga -split > ${i}.${w}.filtered.depth.bed
bedtools genomecov -i ${i}_chromosome_maybemap.${w}.final.bed  -g genome.size -bga -split > ${i}.${w}.filtered.depth.bed
perl  /path_to/make_1kb_depth_line.pl  genome.size ${i}.${w}_map.filtered.depth.bed ${i}.${w}_map.filtered.5k.depth.bed 5000
perl  /path_to/make_1kb_depth_line.pl  genome.size ${i}.${w}_maybemap.filtered.depth.bed ${i}.${w}_maybemap.filtered.5k.depth.bed 5000
done
# Extract coverage information
filteredDepth_ont=${i}.ont.filtered.5k.depth.bed
filteredDepth_hifi=${i}.hifi.filtered.5k.depth.bed
mkdir chr_depth_tmp
for j in {01..12}
do
less -S $filteredDepth_ont | grep chr${j} | awk '{if($4<=150){print $1"\t"$2"\t"$3"\t"$4;}else{print $1"\t"$2"\t"$3"\t150"}}' | sort -k1,1 -k2,2n - > Depth.chr${j}.ont.filter
less -S $filteredDepth_hifi | grep chr${j} | awk '{if($4<=150){print $1"\t"$2"\t"$3"\t"$4;}else{print $1"\t"$2"\t"$3"\t150"}}' | sort -k1,1 -k2,2n - > Depth.chr${j}.hifi.filter
done
less -S chr_depth_tmp/Depth.chr${j}.ont.filter | awk '$4<10 || $4>=100'  > chr_depth_tmp/Depth.chr${j}.abnormal.ont.filter
less -S chr_depth_tmp/Depth.chr${j}.hifi.filter | awk '$4<10 || $4>=100'  > chr_depth_tmp/Depth.chr${j}.abnormal.hifi.filter
# Plot
for i in {01..12}

do
        python ./depth_fig_for_one_chr_V2.py genome.size Cent-Telo-45S-5S.bed $path/chr_depth_tmp/Depth.chr${i}.ont.filter $path/chr_depth_tmp/Depth.chr${i}.abnormal.ont.filter $path/chr_depth_tmp/Depth.chr${i}.hifi.filter ${path}/chr_depth_tmp/Depth.chr${i}.abnormal.hifi.filter chr${i} chr${i}_ont-hifi_depth.svg

done
