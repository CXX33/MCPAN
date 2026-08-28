#!/bin/bash
# ==============================================================================
# Genome-wide association study (GWAS, EMMAX)
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Perform genome-wide association mapping of traits (e.g. fruit
# bitterness) against SV variants in a subpopulation (here MS), using a
# mixed linear model (EMMAX) that controls for population structure
# (PCA covariates) and relatedness (kinship matrix), with the
# significance threshold corrected for the effective number of
# independent tests (GEC).
#
# Main analyses
# -------------
#  1. Variant QC (plink: --geno 0.2 --maf 0.01 --biallelic-only)
#  2. Population-structure covariates (LD pruning + PCA, top 5 PCs)
#  3. Kinship matrix estimation (emmax-kin-intel64)
#  4. PED/MAP conversion for EMMAX input
#  5. Effective-number-of-tests significance threshold (GEC)
#  6. Mixed-model association test (emmax, per trait)
#
# Software and versions
# ---------------------
#   plink                (QC, LD pruning, PCA, format conversion)
#   EMMAX                (emmax, emmax-kin-intel64; MLM)
#   GEC (gec.jar)        (effective test number / significance threshold)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   MS_population_SV.vcf     SV VCF of the MS subpopulation
#   ${i}.TE.phynotype        phenotype file per trait (e.g. fruit_bitterness)
#
# Output files
# ------------
#   ${spe}.* (ped/map/bed)        plink-formatted genotype data
#   ${spe}_LDpruned*              LD-pruned set for PCA
#   PCA.eigenvec / PCA_SV.txt     PCA covariates (top 5 PCs)
#   ${spe}.kinf                   kinship matrix (EMMAX)
#   ${spe}.efn / .threshold       GEC effective-N / significance threshold
#   total_${i}.ps / .reml.*       EMMAX association results per trait
#
# Notes
# -----
# - Replace /path_to/... and $plink_path/$phynotype_path with actual
#   paths; $i is the trait (fruit_bitterness is an example).
# - QC thresholds: --geno 0.2 (missingness), --maf 0.01,
#   --biallelic-only - state in Methods.
# - LD pruning (--indep-pairwise 50 5 0.2) is applied only for PCA;
#   the full variant set is used for the association test.
# - EMMAX uses the kinship matrix (-k) plus PCA covariates (-c) to
#   control for relatedness and structure; report the genomic-control
#   / lambda values to validate model fit.
# - GEC threshold: the genome-wide significance level is based on the
#   effective number of independent SV tests; report the corrected
#   P-value threshold alongside the Manhattan plot.
# Recommended: record exact software versions before publication.
# ==============================================================================

vcf=MS_population_SV.vcf
spe=MS_population_SV
## plink
plink  --vcf $vcf --recode12 --allow-extra-chr --geno 0.2 --maf 0.01 --allow-no-sex --biallelic-only --out $spe
# pca
plink  --file $spe  --indep-pairwise 50 5 0.2 --recode vcf-iid --out ${spe}_LDpruned
plink --allow-extra-chr --file ${spe} --recode vcf-iid --extract ${spe}_LDpruned.prune.in --out ${spe}_LDpruned
plink --allow-extra-chr --vcf ${spe}_LDpruned.vcf --make-bed --out ${spe}_LDpruned_bfile
plink --bfile ${spe}_LDpruned_bfile --allow-extra-chr --pca 5 --out PCA
awk 'BEGIN{a=1}{printf("%s %s ",$1,$1);printf("%s ",a);for(i=3;i<12;i++){printf("%s ",$i)}printf("%s","\n")}' PCA.eigenvec > PCA_SV.txt
# kin
plink --file ${spe} --allow-extra-chr --recode 12 --output-missing-genotype 0 --transpose --out ${spe}
/path_to/emmax-kin-intel64 -v -d 10 ${spe}
# vcf of ped and map format
plink --tfile ${spe} --recode --out ${spe}
plink --make-bed --out ${spe} --vcf $vcf
# calculating significance thresholds for SV
java -Xmx4g -jar /path_to/gec/gec.jar  --effect-number --linkage-file ${spe} --genome --out ${spe} --maf 0.01
## GWAS
PCA=PCA_SV.txt
kinf=${spe}.kinf
for i in Fruit_bitterness ## as an example
do
	/home/yuqing/bin/emmax  -v -d 10 -t $plink_path/MS_population_SV -o total_${i} -p $phynotype_path/${i}.TE.phynotype -k $kinf -c $PCA

done
