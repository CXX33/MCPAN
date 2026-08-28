#!/bin/bash
# ==============================================================================
# TE-related SV identification
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Classify structural variants according to their transposable-element
# (TE) content: (1) annotate TEs in the genome(s) with EDTA, (2) build a
# non-redundant TE library (cd-hit), (3) BLAST the SV sequences against
# the TE library, and (4) assign each SV to a category
# (complete-SV-TE / SV-containing / TE-containing / overlap) plus TE
# superfamily/subfamily (LTR/Gypsy/Copia/DNA/Helitron via TEsorter).
#
# Main analyses
# -------------
#  1. TE annotation per genome (EDTA raw + full pipeline)
#  2. Non-redundant TE library construction (cd-hit, -c 0.70)
#  3. SV sequence extraction and BLAST against the TE library
#     (blastn, identity >= 80%, alignment length >= 150 bp)
#  4. Best-hit assignment and coverage-based classification
#     (complete_SV_TE / SV_contain / TE_contain / overlap_SV_TE)
#  5. LTR subfamily classification of TE-related SVs (TEsorter,
#     rexdb-plant)
#  6. Category counts and SV-length annotation
#
# Software and versions
# ---------------------
#   EDTA           (TE annotation; conda env EDTA)
#   cd-hit         (TE library redundancy removal)
#   BLAST+ (blastall)  (SV-to-TE search)
#   TEsorter       (LTR/DNA TE classification; rexdb-plant DB)
#   seqkit         (sequence retrieval)
#   custom scripts (extract_sv_sequence.py, best_hit.py,
#                   SV_TE_coverage.py, add_length.py)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   ins_del.merge.final.vcf    SYRI-based INS/DEL SV calls
#   ins_del.info               SV length/coordinate info
#   ${i}.fa.mod.EDTA.raw.fa    per-genome raw TE library (EDTA output)
#   total.raw_TE.format.info   TE annotation info
#
# Output files
# ------------
#   TE_library.fa                  non-redundant TE library
#   ins_del.fa                     SV sequences
#   sv_TE.out / sv_TE.best.hit.out BLAST results / best hits
#   sv_TE_raw.coverage.xls         SV-TE coverage table
#   complete_SV_TE.txt / SV_contain.txt / TE_contain.txt / overlap_SV_TE.txt
#   LTR_sv.fa / LTR_sv.*           LTR-related SVs + TEsorter output
#   *.length.xls                   SV length-annotated tables
#
# Notes
# -----
# - Replace $ref, ./script and /path_to/... with actual paths.
# - cd-hit parameters (-c 0.70 -aS 0.70 -aL 0.70 -l 100) set the TE
#   library identity/length thresholds - state them in the Methods.
# - Classification thresholds: coverage >= 0.8 for both SV and TE
#   (complete), or one side < 0.8 (containing/overlap) - report how
#   each category is defined.
# - TEsorter rexdb-plant assigns LTR families (Gypsy/Copia) and DNA TEs;
#   the four categories x TE-superfamily counts can be reported as a
#   summary table/heatmap in the manuscript.
# Recommended: record exact software versions before publication.
# ==============================================================================

# Prediction of TE in genomes using EDTA
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/EDTA
cat all_genomes.txt | while read i
do

	EDTA_raw.pl --genome $ref --type all --species others --force 1 --threads 18 &>run1.log && EDTA.pl --overwrite 0 --genome $ref  --anno 1  --step all  --species others --force 1 --sensitive 1 --anno 1 --evaluate 1 --threads 18 &>run2.log
done
# Construction of TE libraries
cat *.fa.mod.EDTA.final/${i}.fa.mod.EDTA.raw.fa >> TE.raw.fa
cd-hit -i TE.raw.fa -o TE_library.fa -c 0.70 -aS 0.70 -aL 0.70 -d 0 -n 4 -T 0 -l 100 -g 1 -M 24000
# BLAST
./extract_sv_sequence.py  ins_del.merge.final.vcf ins_del.fa
ref=TE_library.fa
blastall -p blastn -d $ref -i ins_del.fa -o sv_TE.out -F F -m 9 -b 5  -e 1e-5 -a 30
less -S sv_TE.out  | grep -v "#" | awk '$3>=80' | awk '$4>=150' > test
best_hit.py sv_TE.out sv_TE.best.hit.out
# Categories
less -S sv_TE.out | grep '^chr' | awk '{print $1}' | sort | uniq > sv_aligned_te.xls
SV_TE_coverage.py ins_del.info total.raw_TE.format.info sv_TE.out sv_TE_raw.coverage.xls
less -S sv_TE_raw.coverage.xls | awk '$2>=0.8' | awk '$4>=0.8' > complete_SV_TE.txt
less -S sv_TE_raw.coverage.xls | awk '$2<0.8' | awk '$4>=0.8' > SV_contain.txt
less -S sv_TE_raw.coverage.xls | awk '$2>=0.8' | awk '$4<0.8' > TE_contain.txt
less -S sv_TE_raw.coverage.xls | awk '$2<0.8' | awk '$4<0.8' > overlap_SV_TE.txt

# LTR subfamily
less -S sv_TE_raw.coverage.xls | grep 'LTR'  | awk '{print $3}' | sort | uniq > LTR_SV.xls
seqkit grep -f LTR_SV.xls TE.raw.fa -o LTR_sv.fa
qry=LTR_sv.fa
~/miniconda3/envs/EDTA/bin/TEsorter -db rexdb-plant -st nucl -pre LTR_sv -p 20 LTR_sv.fa 

for i in Gypsy Copia DTC Helitron  DTA DTM DTH DTT unknown
do
        less -S complete_SV_TE.txt | grep ${i} | wc -l
        less -S overlap_SV_TE.txt | grep ${i} | wc -l
	less -S TE_contain.txt  | grep ${i} | wc -l
        less -S SV_contain.txt | grep ${i} | wc -l
done

for i in complete_SV_TE overlap_SV_TE TE_contain SV_contain
do
        ./add_length.py ins_del.info ${i}.txt  ${i}.length.xls
done
