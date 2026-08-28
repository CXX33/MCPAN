#!/bin/bash
# ==============================================================================
# Estimating TE insertion time using SNPs in the 10-kb flanking regions
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Estimate the insertion time of complete SV-TEs in each subpopulation
# (agrestis / melo) using the GEVA method: extract SNPs in the 10 kb
# flanking regions of the TE-insertion sites, phase haplotypes with
# SHAPEIT4, and apply GEVA (an ARG-based dating approach) to infer the
# allele age / insertion time from the surrounding SNP diversity.
#
# Main analyses
# -------------
#  1. Extraction of 10-kb TE flanking regions (complete_SV_TE -> BED)
#  2. Flanking-SNP extraction per subpopulation
#     (vcftools --bed; plink biallelic)
#  3. SNP annotation for GEVA input (bcftools annotate, unique IDs)
#  4. Haplotype phasing (SHAPEIT4, per chromosome)
#  5. GEVA conversion (--vcf -> .bin + marker) and execution
#     (--Ne 300000 --mut 7e-9; HMM files)
#  6. Insertion-age extraction and per-subpopulation summary
#
# Software and versions
# ---------------------
#   vcftools           (flanking-SNP extraction)
#   plink              (biallelic filtering)
#   bcftools/bgzip/tabix (annotate / indexing)
#   SHAPEIT4           (haplotype phasing)
#   GEVA v1beta        (geva_v1beta; ARG-based dating)
#   custom scripts     (00_extract_TE_flank_region.py, 01_extract_age.py)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   complete_SV_TE.txt               complete SV-TE list (from TE-related SV)
#   agrestis/melo.filter_maf.snp.recode.vcf   subpopulation SNP VCFs
#
# Output files
# ------------
#   complete_TE_10k.bed                    10-kb flanking regions
#   ${w}_TE_flank10k.final.vcf             flanking SNP VCFs
#   ${w}.SNPannotated.forGEVA.vcf(.gz)     annotated VCFs
#   shapeit4/${w}.${chrom}.phased.vcf      phased haplotypes
#   geva_Conversion/${w}.${chrom}.bin      GEVA binary input
#   geva_Execution/${w}.${chrom}.sites.txt(.final)   per-site ages
#   ${w}.sites.final.xls                   per-subpopulation insertion times
#
# Notes
# -----
# - Replace /home/chenxinxiu/software/... with actual paths; $w is the
#   subpopulation (agrestis/melo), $chrom ranges 1-12.
# - Key parameters: --rec 1e-8 (recombination), --Ne 300000 (effective
#   population size), --mut 7e-9 (mutation rate per site per year) -
#   all must be stated in the Methods with justification.
# - GEVA requires phased haplotypes; SNPs are annotated with unique IDs
#   (CHROM_POS) so GEVA can track sites across the flanking window.
# - Report insertion-time distributions (e.g. median age, bursts) per
#   subpopulation; note that --Ne/--mut strongly affect absolute dates.
# Recommended: record exact software versions before publication.
# ==============================================================================

## Extracting SNPs in the 10-kb flanking region of TEs.
./00_extract_TE_flank_region.py complete_SV_TE.txt complete_TE_10k.bed
agrestis_vcf=agrestis.filter_maf.snp.recode.vcf
melo_vcf=melo.filter_maf.snp.recode.vcf
quick_qsub =vcftools1= {-q cu_new -l nodes=1:ppn=2} "vcftools --vcf $agrestis_vcf --bed complete_TE_10k.bed --recode --out agrestis_TE_flank10k"
quick_qsub =vcftools2= {-q cu_new -l nodes=1:ppn=2} "vcftools --vcf $melo_vcf --bed complete_TE_10k.bed --recode --out melo_TE_flank10k"
quick_qsub =plink1= {-q cu_new -l nodes=1:ppn=2} "plink --allow-extra-chr --biallelic-only --out agrestis_TE_flank10k.final.vcf --recode vcf-iid --vcf agrestis_TE_flank10k.recode.vcf"
quick_qsub =plink2= {-q cu_new -l nodes=1:ppn=2} "plink --allow-extra-chr --biallelic-only --out melo_TE_flank10k.final.vcf --recode vcf-iid --vcf melo_TE_flank10k.recode.vcf"
## add annotation
bcftools query -f '%CHROM\t%POS\t%POS\t%CHROM\_%POS\n' agrestis_TE_flank10k.final.vcf > agrestis.annotation.txt
bcftools query -f '%CHROM\t%POS\t%POS\t%CHROM\_%POS\n' melo_TE_flank10k.final.vcf > melo.annotation.txt 
#Index the annotation
bgzip agrestis.annotation.txt
bgzip melo.annotation.txt 
tabix -s1 -b2 -e2 agrestis.annotation.txt.gz
tabix -s1 -b2 -e2 melo.annotation.txt.gz
# Add annotation
mkdir shapeit4
for w in agrestis melo
do
	bcftools annotate -a ${w}.annotation.txt.gz -c CHROM,FROM,TO,ID ${w}_TE_flank10k.final.vcf > ${w}.SNPannotated.forGEVA.vcf
	bgzip ${w}.SNPannotated.forGEVA.vcf
	tabix ${w}.SNPannotated.forGEVA.vcf.gz
	for chrom in {1..12}
	do
		quick_qsub =shapeit4= {-q cu -l nodes=1:ppn=1} "shapeit4 --input ${w}.SNPannotated.forGEVA.vcf.gz --region ${chrom} -T 1 -O shapeit4/${w}.${chrom}.phased.vcf"
	done
done
## GEVA estimates the timing of mutation occurrence.
##Conversion
mkdir geva_Conversion geva_Execution
for w in agrestis melo
do
	for chrom in {1..12}
	do
## Conversion
		quick_qsub =geva1= {-q fat_3T_new -l nodes=1:ppn=1} "/home/chenxinxiu/software/geva-master/geva_v1beta --vcf shapeit4/${w}.${chrom}.phased.vcf --rec 1e-8 --out geva_Conversion/${w}.${chrom}"
		less -S geva_Conversion/${w}.${chrom}.marker.txt | sed '1d' | awk '{print $3}' > geva_Execution/${w}.${chrom}.pos
## Execution
		quick_qsub =geva= {-q fat_3T_new -l nodes=1:ppn=1} "/home/chenxinxiu/software/geva-master/geva_v1beta -i geva_Conversion/${w}.${chrom}.bin -o geva_Execution/${w}.${chrom} --positions  geva_Execution/${w}.${chrom}.pos  --Ne 300000 --mut 7e-9 --hmm /home/chenxinxiu/software/geva-master/hmm/hmm_initial_probs.txt /home/chenxinxiu/software/geva-master/hmm/hmm_emission_probs.txt"
		cat geva_Execution/${w}.${chrom}.sites.txt >> ${w}.sites.txt
		./01_extract_age.py  geva_Execution/${w}.${chrom}.sites.txt geva_Execution/${w}.${chrom}.sites.final.txt
		cat geva_Execution/${w}.${chrom}.sites.final.txt >> ${w}.sites.final.xls
	done

done

