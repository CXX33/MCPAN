#!/bin/bash
# ==============================================================================
# Counting polymorphic variants in subpopulations
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Quantify the number of polymorphic SNPs, InDels, SVs and TE-related
# variants in each subpopulation (agrestis / melo), using a rarefaction
# approach: 100 random subsamples of 200 accessions per subpopulation to
# correct for unequal sample size, then count polymorphic variants per
# subsample (per variant type) for downstream statistical comparison.
#
# Main analyses
# -------------
#  1. Per-subpopulation variant filtering (vcftools)
#     (SNP/InDel: --maf 0.05; SV/TE: --maf 0.01; --max-missing 0.8)
#  2. Random subsampling of 200 accessions per subpopulation
#     (100 replicates, shuf | head -n 200)
#  3. Per-subsample variant filtering and polymorphic-site counting
#     (format.py + wc -l), per variant type (snp/indel/sv/te)
#
# Software and versions
# ---------------------
#   vcftools         (variant filtering)
#   custom scripts   (format.py)
#   shell tools      (shuf, wc)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   population.SNP.vcf / .InDel.vcf / .SV.vcf / .TE.vcf
#                                   population-level VCFs per variant type
#   agrestis.keep / melo.keep       subpopulation sample lists
#
# Output files
# ------------
#   ${k}.filter_maf.snp/indel/sv/te.recode.vcf   filtered subpopulation VCFs
#   random_tmp/random_${k}_${i}.keep             random subsamples (i=001..100)
#   ${k}.snp.info.txt / .indel / .sv / .te       polymorphic-site counts
#
# Notes
# -----
# - Replace /path_to/... with actual paths; $k is the subpopulation
#   (agrestis/melo), $i the replicate index (001-100).
# - MAF thresholds differ by variant type (SNP/InDel 0.05, SV/TE 0.01) -
#   state this in the Methods (reflecting the lower allele frequency of
#   rare structural variants).
# - The random subsampling (n=200, 100 replicates) is a rarefaction
#   design to compare variant counts between subpopulations of unequal
#   size; report mean +/- SD (or distribution) of the 100 replicates.
# - Note: in the indel/sv/te loops the vcftools --vcf argument reuses
#   $snp - verify it points to the correct per-type VCF
#   (the intended file is ${k}.filter_maf.indel/sv/te.recode.vcf).
# Recommended: record exact software versions before publication.
# ==============================================================================

snp=population.SNP.vcf
indel=population.InDel.vcf
SV=population.SV.vcf
TE=population.TE.vcf
# Extract total polymorphic variants in subpopulations
for i in agrestis melo
do
	vcftools --vcf $snp  --keep ${i}.keep --maf 0.05 --max-missing 0.8 --recode --recode-INFO-all --out ${i}.filter_maf.snp
	vcftools --vcf $indel  --keep ${i}.keep --maf 0.05 --max-missing 0.8 --recode --recode-INFO-all --out ${i}.filter_maf.indel
	vcftools --vcf $SV  --keep ${i}.keep --maf 0.01 --max-missing 0.8 --recode --recode-INFO-all --out ${i}.filter_maf.sv
	vcftools --vcf $TE  --keep ${i}.keep --maf 0.01 --max-missing 0.8 --recode --recode-INFO-all --out ${i}.filter_maf.te
done

# 200 accessions were randomly selected from each subpopulation to minimize bias arising from unequal sample sizes
mkdir random_tmp
for i in {001..100}
do
        less -S agrestis.keep | shuf | head -n 200 > random_tmp/random_agrestis_${i}.keep
        less -S melo.keep | shuf | head -n 200 > random_tmp/random_melo_${i}.keep
        for k in agrestis melo
	do
		# snp
		snp=${k}.filter_maf.snp.recode.vcf
		quick_qsub =vcftools= {-q cu -l nodes=1:ppn=1} "cd snp && vcftools --vcf $snp  --keep /path_to/random_tmp/random_${k}_${i}.keep --maf 0.05 --recode --recode-INFO-all --out ${k}.filter_maf.snp.${i}"
		format.py  ${k}.filter_maf.snp.${i}.recode.vcf ${k}.filter_maf.snp.${i}.info && rm ${k}.filter_maf.snp.${i}.recode.vcf && wc -l  ${k}.filter_maf.snp.${i}.info >> ${k}.snp.info.txt
		# indel
		indel=${k}.filter_maf.indel.recode.vcf
		quick_qsub =vcftools= {-q cu -l nodes=1:ppn=1} "cd indel && vcftools --vcf $snp  --keep /path_to/random_tmp/random_${k}_${i}.keep --maf 0.05 --recode --recode-INFO-all --out ${k}.filter_maf.indel.${i}"
		format.py ${k}.filter_maf.indel.${i}.recode.vcf ${k}.filter_maf.indel.${i}.info && rm ${k}.filter_maf.indel.${i}.recode.vcf && wc -l  ${k}.filter_maf.indel.${i}.info >> ${k}.indel.info.txt
		# sv
		sv=${k}.filter_maf.sv.recode.vcf
		quick_qsub =vcftools= {-q cu -l nodes=1:ppn=1} "cd sv && vcftools --vcf $snp  --keep /path_to/random_tmp/random_${k}_${i}.keep --maf 0.01 --recode --recode-INFO-all --out ${k}.filter_maf.sv.${i}"
		 format.py ${k}.filter_maf.indel.${i}.recode.vcf ${k}.filter_maf.sv.${i}.info && rm ${k}.filter_maf.sv.${i}.recode.vcf && wc -l  ${k}.filter_maf.sv.${i}.info >>${k}.sv.info.txt
		# te
		te=${k}.filter_maf.te.recode.vcf
		quick_qsub =vcftools= {-q cu -l nodes=1:ppn=1} "cd te && vcftools --vcf $snp  --keep /path_to/random_tmp/random_${k}_${i}.keep --maf 0.01 --recode --recode-INFO-all --out ${k}.filter_maf.te.${i}"
		 format.py ${k}.filter_maf.te.${i}.recode.vcf ${k}.filter_maf.indel.${i}.info && rm ${k}.filter_maf.te.${i}.recode.vcf && wc -l  ${k}.filter_maf.te.${i}.info >>${k}.te.info.txt
	done
done
