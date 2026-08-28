#!/bin/bash
# ==============================================================================
# Structural variant (SV) identification using SYRI
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Identify genome-wide structural variants (SVs) between a reference
# (13C) and each query genome using whole-genome alignment (MUMmer +
# minimap2) and SYRI classification: (1) call and classify SVs
# (INS/DEL/INV/TRANS) with SYRI, (2) filter and format variants into
# per-sample VCFs, and (3) merge all samples and correct problematic
# (duplicate-position / repeat-overlapping) sites to produce final
# merged SV VCFs (ins/del, INV, TRANS).
#
# Main analyses
# -------------
#  1. Whole-genome alignment (nucmer + delta-filter; minimap2 asm5)
#  2. SV classification with SYRI (-F S; syri.out / syri.vcf / syri.pdf)
#  3. SNP extraction from MUMmer (show-snps -> MUMmerSNPs2VCF.py)
#  4. INS/DEL filtering (>20 bp), repeat exclusion, VCF formatting
#  5. Translocation (TRANS) extraction and VCF construction
#  6. Inversion (INV) extraction and VCF construction
#  7. Cross-sample merging (bcftools merge) per SV type
#  8. Problem-site correction (duplicate reference positions, repeat
#     overlap) and final VCF formatting
#
# Software and versions
# ---------------------
#   MUMmer             (nucmer, delta-filter, show-coords, show-snps)
#   minimap2           (asm5 alignment, --eqx)
#   SYRI 1.4           (syri; plotsr for visualisation)
#   bcftools / bgzip   (merge, index)
#   samtools           (faidx for TRANS/INV allele extraction)
#   custom scripts     (extract_mt20bp_pav.py, exclude_repeat_sv.py,
#                       format_vcf_ins_del.py, output_translocation_from_vcf.py,
#                       format_vcf_trans_inv.py,
#                       correct_identical_reference_pos_indel.py,
#                       repos_repeat_pos.py, correct_ins_del_problem2.py,
#                       remove_problematic_indel_in_vcf.py,
#                       format_ins_del_vcf.py; MUMmerSNPs2VCF.py external)
#   quick_qsub         (cluster submission wrapper)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   $ref (13C.fa)              reference genome (FASTA)
#   ${id}.fa                   query genomes (from all_query_gemomes.txt)
#   header                     VCF header template
#
# Output files
# ------------
#   ${id}syri.out / ${id}syri.vcf / ${id}.syri.pdf   SYRI SV calls
#   ${id}.filter.delta(.coords/.rsnp/.rsnp.vcf)      alignment + SNP VCF
#   ${id}.ins_del.vcf(.filter/.format.vcf.gz)        INS/DEL VCFs
#   ${id}.INV.vcf / ${id}.TRANS.vcf                  inversion/translocation VCFs
#   ins_del.merge.vcf / INV.merge.vcf / TRANS.merge.vcf   merged VCFs
#   ins_del.merge.final.vcf                          final merged INS/DEL VCF
#
# Notes
# -----
# - Replace /path_to_all_genomes/... with actual paths; ${id} is the
#   query-genome ID (looped from all_query_gemomes.txt).
# - Filtering thresholds: delta-filter -1 -i 95 -l 200; INS/DEL >= 20 bp;
#   repeat-overlapping SVs excluded (exclude_repeat_sv.py) - state all
#   thresholds in the Methods.
# - TRANS/INV alleles are reconstructed from the reference/query
#   sequence (samtools faidx) into VCF REF/ALT; quality set to 30.
# - Problem-site correction is required because multiple SVs can share
#   the same reference position; the final VCF is sorted and de-duplicated.
# - This is the core SV dataset of the manuscript: keep every intermediate
#   (per-sample VCFs + logs) for the code repository.
# Recommended: record exact software versions before publication.
# ==============================================================================

path=/path_to_all_genomes/00_database
ref=/path_to_all_genomes/00_database/13C.fa
PATH_TO_PLOTSR=/path_to/syri-1.4/syri/bin/plotsr
script=/path_to_all_genomes/script
cat all_query_gemomes.txt | while read id
do
	qry=/path_to_all_genomes/00_database/${id}.fa
	quick_qsub =syri_${id}= {-q cu -l nodes=1:ppn=12} "mkdir -p 01_SV_assembly/${id} && cd 01_SV_assembly/${id} && ~/miniconda3/bin/nucmer -t 12  --prefix ${id} $ref $qry && delta-filter -1 -i 95 -l 200 ${id}.delta > ${id}.filter.delta && minimap2 -ax asm5 -t 12 --eqx $ref $qry > ${id}.sam && syri -c ${id}.sam -d ${id}.filter.delta -r $ref -q $qry -k -F S --prefix ${id} && ~/miniconda2/envs/Syri/bin/python3 $PATH_TO_PLOTSR  ${id}syri.out $ref $qry -H 8 -W 5"
	quick_qsub =syri_${id}= {-q cu -l nodes=1:ppn=1} "cd 01_SV_assembly/${id} && show-coords -THrcl ${id}.filter.delta > ${id}.filter.coords && show-snps -Clr -x 1 -T ${id}.filter.delta > ${id}.filter.delta.rsnp && python3 /path_to_all_genomes/software/PythonNGSTools-master/MUMmerSNPs2VCF.py ${id}.filter.delta.rsnp ${id}.filter.delta.rsnp.vcf"
	mv 01_SV_assembly/${id}/syri.pdf 01_SV_assembly/${id}/${id}.syri.pdf
	quick_qsub =syri_${id}= {-q cu -l nodes=1:ppn=1} "$script/extract_mt20bp_pav.py 01_SV_assembly/${id}/${id}syri.vcf 01_SV_assembly/${id}/${id}.ins_del.vcf"
	quick_qsub =syri_${id}= {-q cu -l nodes=1:ppn=1} "$script/exclude_repeat_sv.py 01_SV_assembly/${id}/${id}.ins_del.vcf 01_SV_assembly/${id}/${id}.ins_del.filter.vcf"
	quick_qsub =format_sv= {-q cu -l nodes=1:ppn=1} "$script/format_vcf_ins_del.py -vcf 01_SV_assembly/${id}/${id}.ins_del.filter.vcf -o 01_SV_assembly/${id}/${id}.ins_del.format.vcf -name ${id} -header header"
	quick_qsub =format_vcf= {-q cu -l nodes=1:ppn=1} "cd 01_SV_assembly/${id} && bgzip -c -f ${id}.ins_del.format.vcf >  ${id}.ins_del.format.vcf.gz &&  bcftools index ${id}.ins_del.format.vcf.gz && rm ${id}.ins_del.format.vcf"
	ls 01_SV_assembly/${id}/${id}.ins_del.format.vcf.gz >> vcf.list
	rm 01_SV_assembly/${id}/${id}_syri_TRANS.vcf 01_SV_assembly/${id}/${id}.INV.vcf
########### TRANS
	python3 $script/output_translocation_from_vcf.py 01_SV_assembly/${id}/${id}syri.vcf > 01_SV_assembly/${id}/${id}_TRANS.xls
	cat 01_SV_assembly/${id}/${id}_TRANS.xls | while read n
	do
		chr=`echo $n | awk '{print $2}'`
		pos=`echo $n | awk '{print $3}'`
		ref_pos=`echo $n | awk '{print $2":"$3"-"$4}'`
		alt_pos=`echo $n | awk '{print $6":"$7"-"$8}'`
		ref_seq=`samtools faidx $ref $ref_pos | grep -v '>' | sed ':a;N;s/\n//g;ta'`
		alt_seq=`samtools faidx $qry $alt_pos | grep -v '>' | sed ':a;N;s/\n//g;ta'`
		echo -e "${chr}\t${pos}\t.\t${ref_seq}\t${alt_seq}\t30\tPASS\t.\tGT\t1/1" >> 01_SV_assembly/${id}/${id}_syri_TRANS.vcf
	done
########### INV
	less -S 01_SV_assembly/${id}/${id}invOut.txt | grep '#' > 01_SV_assembly/${id}/${id}.inv.txt
	cat 01_SV_assembly/${id}/${id}.inv.txt | while read n
	do
		chr=`echo $n | awk '{print $2}'`
		pos=`echo $n | awk '{print $3}'`
		ref_pos=`echo $n | awk '{print $2":"$3"-"$4}'`
		alt_pos=`echo $n | awk '{print $6":"$7"-"$8}'`
		ref_seq=`samtools faidx $ref $ref_pos | grep -v '>' | sed ':a;N;s/\n//g;ta'`
		alt_seq=`samtools faidx $qry $alt_pos | grep -v '>' | sed ':a;N;s/\n//g;ta'`
		echo -e "${chr}\t${pos}\t.\t${ref_seq}\t${alt_seq}\t30\tPASS\t.\tGT\t1/1" >> 01_SV_assembly/${id}/${id}.INV.vcf
	done
####################### merge 
	for k in INV TRANS
	do
		echo "#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO" > 01_SV_assembly/${id}/tmp_${k}.vcf
		cat 01_SV_assembly/${id}/${id}.${k}.vcf >>  01_SV_assembly/${id}/tmp_${k}.vcf
		mv 01_SV_assembly/${id}/tmp_${k}.vcf 01_SV_assembly/${id}/${id}.${k}.vcf
		quick_qsub =format_sv= {-q cu -l nodes=1:ppn=1} "$script/format_vcf_trans_inv.py -vcf 01_SV_assembly/${id}/${id}.${k}.vcf -o 01_SV_assembly/${id}/${id}.${k}.format.vcf -name ${id} -header header"
		quick_qsub =vcf_index_${id}_${k}= {-q cu -l nodes=1:ppn=2}"cd 01_SV_assembly/${id} && bgzip -c -f ${id}.${k}.format.vcf >  ${id}.${k}.format.vcf.gz &&  bcftools index ${id}.${k}.format.vcf.gz"
		echo 01_SV_assembly/${id}/${id}.${k}.format.vcf.gz >> ${k}.vcf.list
	done
done
vcf=`awk '{printf "%s ", $0}' vcf.list`
INV_vcf=`awk '{printf "%s ", $0}' INV.vcf.list`
TRANS_vcf=`awk '{printf "%s ", $0}' TRANS.vcf.list`
echo "bcftools merge  -0 --threads 12 $vcf -o ins_del.merge.vcf" > ins_del.merge.sh
echo "bcftools merge  -0 --threads 12 $INV_vcf -o INV.merge.vcf" > INV.merge.sh
echo "bcftools merge  -0 --threads 12 $TRANS_vcf -o TRANS.merge.vcf" > TRANS.merge.sh
quick_qsub =bcftools_merge= {-q cu -l nodes=1:ppn=12} "chmod +x ./ins_del.merge.sh && ./ins_del.merge.sh"
./format_vcf.py ins_del.merge.vcf ins_del.merge.format.vcf
cat ins_del.merge.vcf |awk '{print $1"~"$2}'|sort | uniq -c | awk '$1!=1'|awk '{print $2}'|awk -F '~' '{print $1,$2}' > ins_del.problem.pos.xls
split -a 2 -d -l 50 ins_del.problem.pos.xls ins_del.problem.pos.xls_
for n in {00..13}
do
       for i in ins_del #INV TRANS
       do
               echo -e "cat  ${i}.problem.pos.xls_${n} | while read i;     do         echo \$i > tmp_${i}_${n};         $script/correct_identical_reference_pos_indel.py ${i}.merge.format.vcf tmp_${i}_${n} >> ${i}.problem.pos.correct.vcf;     done" > correct_indel.sh_${i}_${n}
               chmod 755 correct_indel.sh_${i}_${n}
               quick_qsub =sv= {-q cu -l nodes=1:ppn=1} "./correct_indel.sh_${i}_${n}"
       done

done
$script/repos_repeat_pos.py ins_del.merge.format.vcf ins_del.merge.correct.vcf
#correct problem again
$script/correct_ins_del_problem2.py ins_del.problem.pos.correct.vcf ins_del.problem.pos.correct2.vcf
$script/remove_problematic_indel_in_vcf.py ins_del.problem.pos.xls ins_del.merge.format.vcf > tmp
cat ins_del.problem.pos.correct2.vcf tmp | sort -k1,1 -k2,2n > tt && mv tt ins_del.merge.correct3.vcf
less  -S ins_del.merge.format.vcf | head -n 100 | grep '#' > header
cat header ins_del.merge.correct3.vcf >ins_del.merge.correct.vcf
rm ins_del.problem.pos.correct2.vcf ins_del.problem.pos.correct3.vcf

check repeat pos again
cat ins_del.merge.correct.vcf |awk '{print $1"~"$2}'|sort | uniq -c | awk '$1!=1'|awk '{print $2}'|awk -F '~' '{print $1,$2}' > ins_del.correct.problem.pos.xls
## format
$script/format_ins_del_vcf.py ins_del.merge.correct.vcf ins_del.merge.final.vcf
