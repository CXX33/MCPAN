#!/bin/bash
# ==============================================================================
# Characterizing centromeric CmSat354 composition
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Characterise the composition and sequence variants of the centromeric
# satellite CmSat354 (354-bp tandem repeat): (1) define centromeric
# regions from TRF tandem-repeat calls, (2) extract and confirm the
# CmSat354 consensus via self-BLAST, (3) sample 500 CmSat354 arrays
# per chromosome (CmCentA / CmCentB classes), and (4) quantify base
# composition and variant sites across arrays.
#
# Main analyses
# -------------
#  1. Centromeric region extraction from TRF output (consensus_size=354)
#  2. CmSat354 consensus sequence extraction and high-copy confirmation
#     (formatdb + blastn self-search)
#  3. Centromeric sequence retrieval from the genome (samtools faidx)
#  4. Random sampling of 500 CmSat354 arrays per chromosome
#     (CmCentA / CmCentB)
#  5. Base-composition analysis of CmCentA arrays (per chromosome)
#  6. Base-composition analysis of CmCentB arrays (genome-wide)
#  7. Variant-site (diff-site) detection between CmCentA/CmCentB
#
# Software and versions
# ---------------------
#   TRF                    (tandem-repeat finding; gff3 input)
#   BLAST+                 (formatdb, blastall blastn)
#   samtools               (faidx)
#   custom python scripts  (01_extract_cons_seq.py, 01random_cent1.py,
#                           01random_cent2.py, 02format_for_find_diff.py,
#                           03count_frequency.py, 04_extract_diff_site.py)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   $input_path/*.gff3          TRF tandem-repeat calls (split per chromosome)
#   $ref (genome.fa)            reference genome (FASTA)
#   CmCent.bed                  final centromeric regions (BED)
#
# Output files
# ------------
#   CmCent_trf.gff3             CmSat354 TRF calls
#   cons_seq.fa / cons_seq.out  consensus sequence + self-BLAST confirmation
#   cent_${chr_id}.fasta        per-chromosome centromeric sequences
#   cent_chr*.random_windows.cent1/cent2.fasta   sampled arrays (A/B)
#   *.format.fasta / *.count / *.diff_site       composition / variant sites
#
# Notes
# -----
# - Replace /path_to/... with actual paths; ${i} is the chromosome ID
#   (01-12) and chr_id is parsed from the BED.
# - TRF: only calls with consensus_size=354 are retained (CmSat354);
#   record the TRF match/parameters used.
# - CmCentA is analysed per chromosome; CmCentB is pooled genome-wide -
#   keep this distinction when reporting array-level composition.
# - The awk transpose block converts sequences into per-site columns
#   before frequency counting; the 10 difference sites listed
#   (S4 S6 S69 S72 S131 S137 S150 S205 S239 S283) are the inferred
#   variant positions - verify they are biologically consistent
#   (e.g. strand/orientation of arrays).
# Recommended: record exact software versions before publication.
# ==============================================================================

# Extract the centromeric region using CmSat354 copy numbers from TRF
input_path=/path_to/02trf/chr_split
cat $input_path/*.gff3 >> total_chromosome_trf.gff3
less -S total_chromosome_trf.gff3 | grep 'consensus_size=354' > CmCent_trf.gff3
01_extract_cons_seq.py CmCent_trf.gff3 cons_seq.fa
cent=CmCent.fa
formatdb -i $cent -o F -p F
# Confirm the high-copy region of CmSat354 based on cons_seq.out
blastall -p blastn -d $cent -i  cons_seq.fa -o  cons_seq.out -F F -m 9 -b 3 -e 1e-5 -a 1

# Analysis CmSat354 type by randomly extract 500 CmSat354 arrays
ref=genome.fa
bed=CmCent.bed # Final centromeric region

# Extract the centromeric sequences from the genome
cat $bed | while read i
do
        chr_id=`echo $i | awk '{print $1}'`
        start=`echo $i | awk '{print $2}'`
        end=`echo $i | awk '{print $3}'`
        samtools faidx $ref ${chr_id}:${start}-${end} > cent_${chr_id}.fasta
done

# Extract 500 CmSat354 arrays from all centromeric sequences of the chromosomes
for i in {01..12}
do
       01random_cent1.py 13C_cent_chr${i}.fasta 13C_cent_chr${i}.random_windows.cent1.fasta ## CmCentA
       01random_cent2.py 13C_cent_chr${i}.fasta 13C_cent_chr${i}.random_windows.cent2.fasta ## CmCentB
done

# Analysis of CmCentA sequence compisation
for i in {01..12}
do
       02format_for_find_diff.py cent_chr${i}.random_windows.cent1.fasta cent_chr${i}.random_windows.cent1.format.fasta
       awk '{for (i=1; i<=length; i++) a[NR,i]=substr($0,i,1)} END {for (i=1; i<=length; i++) {line=""; for (j=1; j<=NR; j++) line=line a[j,i]; print line}}' cent_chr${i}.random_windows.cent1.format.fasta > tmp
       mv tmp cent_chr${i}.random_windows.cent1.format.fasta
       03count_frequency.py cent_chr${i}.random_windows.cent1.format.fasta cent_chr${i}.random_windows.cent1.format.count
       04_extract_diff_site.py cent_chr${i}.random_windows.cent1.format.count cent_chr${i}.random_windows.cent1.diff_site
done

# Analysis of CmCentB sequence compisation
cat  cent_chr*.random_windows.cent2.fasta >> total.random_windows.cent2.fasta
02format_for_find_diff.py total.random_windows.cent2.fasta total.random_windows.cent2.format.fasta
awk '{for (i=1; i<=length; i++) a[NR,i]=substr($0,i,1)} END {for (i=1; i<=length; i++) {line=""; for (j=1; j<=NR; j++) line=line a[j,i]; print line}}' total.random_windows.cent2.format.fasta > tmp_total
mv tmp_total total.random_windows.cent2.format.fasta
03count_frequency.py total.random_windows.cent2.format.fasta total.random_windows.cent2.format.count
# Difference sites: S4 S6 S69 S72 S131 S137 S150 S205 S239 S283
cat cent_chr*.random_windows.cent1.fasta cent_chr*.random_windows.cent2.fasta > total_cent1_cent2.random_windows.fasta
02format_for_find_diff.py total_cent1_cent2.random_windows.fasta total_cent1_cent2.random_windows.format.fasta
awk '{for (i=1; i<=length; i++) a[NR,i]=substr($0,i,1)} END {for (i=1; i<=length; i++) {line=""; for (j=1; j<=NR; j++) line=line a[j,i]; print line}}' total_cent1_cent2.random_windows.format.fasta > tmp  && mv tmp total_cent1_cent2.random_windows.format.fasta
03count_frequency.py total_cent1_cent2.random_windows.format.fasta total_cent1_cent2.random_windows.format.fasta.count

