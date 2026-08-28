#!/bin/bash
# ==============================================================================
# Population-scale phylogenetic tree construction (4d-SNP / InDel / SV / TE)
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Build population-scale phylogenies from four independent variant sets
# for comparative evolutionary inference: (1) 4-fold degenerate sites
# (4d-SNP, neutral coding sites), (2) InDels, (3) SVs, and (4) TE-related
# variants - each converted to a sequence matrix (vcf2phylip) and used
# for maximum-likelihood tree inference with IQ-TREE.
#
# Main analyses
# -------------
#  1. Extraction of 4-fold degenerate sites (Get_4_fold_sites.pl +
#     extract_4d_vcf.py) from the SNP VCF
#  2. 4d-SNP filtering (vcftools: maf 0.05, max-missing 1, biallelic,
#     no indels) and matrix construction (vcf2phylip)
#  3. IQ-TREE inference for 4d-SNP (MFP + 1000 ultrafast bootstraps +
#     -bnni; outgroup P14)
#  4. InDel / SV / TE matrices and IQ-TREE inference (same settings)
#
# Software and versions
# ---------------------
#   vcftools        (variant filtering)
#   IQ-TREE 2       (maximum-likelihood tree; -m MFP -B 1000 -bnni)
#   vcf2phylip.py   (VCF -> PHYLIP matrix conversion)
#   custom scripts  (Get_4_fold_sites.pl, extract_4d_vcf.py, format.py)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   13C.fa / 13C.gff3         reference genome + annotation (4d sites)
#   population.SNP.vcf        population SNP VCF
#   population.InDel.vcf / .SV.vcf / .TE.vcf   other variant-type VCFs
#
# Output files
# ------------
#   13C_T2T_4_fold_sites.xls             4-fold degenerate site table
#   MS_MC_res.4d_snp.vcf / .filter       4d-SNP VCFs
#   MS_MC_res.4d_snp.min4.phy            PHYLIP matrix
#   MS_MC.treefile / ${i}.treefile       IQ-TREE outputs (InDel/SV/TE)
#
# Notes
# -----
# - 4d sites are extracted from the reference CDS annotation and used to
#   filter the SNP VCF; this provides a neutral (non-coding-effect)
#   marker set for the species phylogeny.
# - Filtering: 4d-SNP maf 0.05, max-missing 1 (no missing), biallelic;
#   InDel/SV/TE matrices use format.py output - state per-type filters.
# - IQ-TREE settings: -m MFP (ModelFinder), -B 1000 (UFBoot),
#   -bnni (better NNI) - report the best-fit model chosen by MFP for
#   each tree.
# - P14 is used as the outgroup; confirm it is a distinct accession
#   appropriate for rooting.
# - Comparing the 4d-SNP, InDel, SV and TE trees is a key figure of the
#   manuscript (e.g. congruence/incongruence among variant types).
# Recommended: record exact software versions before publication.
# ==============================================================================

# 4d-snp
ref=13C.fa
gff=13C.gff3
perl Get_4_fold_sites.pl $ref $gff 13C_T2T_4_fold_sites.xls
extract_4d_vcf.py 13C_T2T_4_fold_sites.xls ../population.SNP.vcf MS_MC_res.4d_snp.vcf
vcftools --vcf MS_MC_res.4d_snp.vcf --maf 0.05 --max-missing 1 --remove-indels --min-alleles 2 --max-alleles 2 --recode --out MS_MC_res.4d.filter
python3 vcf2phylip.py -i  MS_MC_res.4d_snp.vcf -o MS_MC_res.4d_snp
iqtree2 -s MS_MC_res.4d_snp.min4.phy -m MFP -B 1000  -bnni  --prefix MS_MC -o P14 --mem 10GB -T 30
# indel sv te
for i in InDel SV TE
do
	format.py ../population.${i}.vcf ${i}.format.vcf
	python3 vcf2phylip.py -i ${i}.format.vcf -o ${i}
	iqtree2 -s ${i}.format.min4.phy -m MFP -B 1000  -bnni -o P14 --prefix ${i} --mem 10GB -T AUTO -redo
done

