#!/bin/bash
# ==============================================================================
# SV genotyping using vg (graph-based pangenome)
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Genotype SVs across all accessions by mapping short WGS reads to a
# graph-based pangenome with vg: (1) map reads with vg giraffe,
# (2) genotype variants with vg pack + vg call, (3) normalise, filter
# and merge per-sample VCFs, (4) correct duplicate-position sites, and
# (5) apply final site/sample filters with plink.
#
# Main analyses
# -------------
#  1. Read mapping to the pangenome graph (vg giraffe; .xg/.gg/.gbwt)
#  2. Variant genotyping (vg pack -Q 5 -> vg call -a)
#  3. Per-sample VCF filtering (allele-depth filter_vcf_ad.py) and
#     normalisation (bcftools norm: -m -both, -d none, --fasta-ref)
#  4. Cross-sample merging (bcftools merge)
#  5. Duplicate-position correction (custom scripts, parallelised)
#  6. Final VCF assembly + plink filtering (--geno 0.4, --mac 5,
#     --biallelic-only)
#
# Software and versions
# ---------------------
#   vg              (giraffe, pack, call; pangenome graph tool)
#   bcftools/tabix/bgzip  (norm, merge, index)
#   plink           (site/sample filtering)
#   custom scripts  (filter_vcf_ad.py, format_vcf.py,
#                    correct_identical_reference_pos_indel.py,
#                    remove_problematic_indel_in_vcf.py)
#   quick_qsub      (cluster submission wrapper)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   MS_MC_accession.WGS.list / supply.list   sample read lists (R1 R2 name)
#   ${spe}.xg / .gg / .gbwt / .min / .dist   vg pangenome graph indexes
#   PAV.vcf                                  presence/absence variant callset
#   $ref                                     reference genome (for norm)
#
# Output files
# ------------
#   gam_file/${name}.pack / ${name}.vcf      per-sample genotyping
#   vcf_filter/${i}.filter                   allele-depth filtered VCFs
#   vcf_file/${i}.filter.norm.vcf.gz         normalised per-sample VCFs
#   MC_MS_total.SV.merge.vcf                 merged raw VCF
#   MC_MS_total.SV.final.vcf                 final merged VCF
#   MC_MS.SV.filter.*                        plink-filtered genotype set
#
# Notes
# -----
# - Replace ${spe} with the pangenome graph prefix and $ref with the
#   reference path; the graph indexes must be built from the same
#   reference/panel used for SV calling (consistency with SYRI calls).
# - vg call -a: allele-aware genotyping; -Q 5 sets the base-quality
#   threshold for vg pack - state these in the Methods.
# - Filtering: allele-depth (AD) filter per sample, then bcftools norm
#   (-m -both split multiallelic; -d none drop duplicates; --fasta-ref
#   left-normalise), merge, duplicate-position correction, and plink
#   filters --geno 0.4 (missingness), --mac 5 (minor allele count),
#   --biallelic-only.
# - Keep the PAV.vcf (presence/absence) separate from the size-polymorphic
#   SV VCF - they are merged here but represent different SV types.
# Recommended: record exact software versions before publication.
# ==============================================================================

script=../01_SV_identification/script
mkdir gam_file
cat MS_MC_accession.WGS.list | while read i
cat supply.list | while read i 
do
       R1=`echo $i | awk '{print $1}'`
       R2=`echo $i | awk '{print $2}'`
       name=`echo $i | awk '{print $3}'`
       echo "vg giraffe -t $threads -f $R1 -f $R2 -x ${spe}.xg -g ${spe}.gg -H ${spe}.gbwt -m ${spe}.min -d ${spe}.dist > gam_file/${name}.gam && vg pack -t $threads -Q 5 -x  ${spe}.xg -g gam_file/${name}.gam -o gam_file/${name}.pack && vg call -t $threads ${spe}.xg -r ${spe}.snarls -k gam_file/${name}.pack -a -s ${name} > gam_file/${name}.vcf && /bin/rm gam_file/${name}.gam" >> vg2.sh
done
split -l 2 -d vg2.sh command2_
for i in {00..10}
do
       chmod +x command2_${i}
       quick_qsub =vg2= {-q cu -l nodes=1:ppn=$threads} "./command2_${i}"
done
for i in {11..73}
do
        chmod +x command_${i}
        quick_qsub =vg= {-q fat_3T_new -l nodes=1:ppn=$threads} "./command_${i}"
done
cd gam_file && ls *.vcf > ../vcf_file.list
mkdir vcf_filter
mkdir vcf_file
cat vcf_file.list | while read i
do
       cat <(grep '#' gam_file/$i) <($script/filter_vcf_ad.py gam_file/$i | grep -v '#') > vcf_filter/${i}.filter
       quick_qsub =bcftools= {-q cu -l nodes=1:ppn=1} "bcftools norm -m -both vcf_filter/${i}.filter | bcftools norm -d none -c x --fasta-ref $ref | bcftools sort | bgzip > vcf_file/${i}.filter.norm.vcf.gz && tabix -f vcf_file/${i}.filter.norm.vcf.gz"
done
bcftools norm -m -both vcf_file/PAV.vcf | bcftools norm -d none -c x --fasta-ref $ref | bcftools sort | bgzip >  vcf_file/PAV.filter.norm.vcf.gz && tabix -f vcf_file/PAV.filter.norm.vcf.gz
VCFS=`ls vcf_file/*filter.norm.vcf.gz`
all_vcf=`echo $VCFS`
quick_qsub =bcftools= {-q cu -l nodes=1:ppn=5} "bcftools merge $all_vcf > MC_MS_total.SV.merge.vcf"
# format problem dup position
vcf=MC_MS_total.SV.merge.vcf
quick_qsub =bcftools= {-q cu -l nodes=1:ppn=5} "bcftools norm -m -both $vcf | bcftools norm -d none -c x --fasta-ref $ref | bcftools sort > MC_MS_total.SV.merge.norm.vcf"
$script/format_vcf.py MC_MS_total.SV.merge.norm.vcf MC_MS_total.SV.merge.format.vcf
rm MC_MS_total.SV.merge.norm.vcf
cat MC_MS_total.SV.merge.norm.vcf |awk '{print $1"~"$2}'|sort | uniq -c | awk '$1!=1'|awk '{print $2}'|awk -F '~' '{print $1,$2}' > duplicated_pos.xls
split -a 2 -d -l 500 duplicated_pos.xls duplicated_pos.xls_
for n in {00..61}
do
       echo -e "cat  duplicated_pos.xls_${n} | while read i;     do         echo \$i > tmp_${n};         $script/correct_identical_reference_pos_indel.py MC_MS_total.SV.merge.format.vcf tmp_${n} >> MC_MS_total.SV.correct.vcf;     done" > correct_indel.sh_${n}
       chmod 755 correct_indel.sh_${n}
        quick_qsub =sv= {-q cu -l nodes=1:ppn=1} "./correct_indel.sh_${n}"
        rm correct_indel.sh_${n} tmp_${n}
done
$script/remove_problematic_indel_in_vcf.py duplicated_pos.xls MC_MS_total.SV.merge.format.vcf > tmp.vcf
cat MC_MS_total.SV.correct.vcf tmp.vcf | sort -k1,1 -k2,2n > tt && mv tt MC_MS_total.SV.merge.correct.vcf
less  -S MC_MS_total.SV.merge.format.vcf | head -n 1000 | grep '#' | grep -v "SAMPLE"> header
cat header MC_MS_total.SV.merge.correct.vcf > MC_MS_total.SV.final.vcf
rm MC_MS_total.SV.merge.format.vcf MC_MS_total.SV.merge.correct.vcf

###########filter
vcf=MC_MS_total.SV.final.vcf
quick_qsub =plink= {-q cu -l nodes=1:ppn=5} "plink --vcf $vcf  --allow-extra-chr --geno 0.4 --mac 5 --recode vcf-iid --biallelic-only --out MC_MS.SV.filter"
