#!/bin/bash
# ==============================================================================
# Polishing ONT-only assemblies with Illumina reads (Pilon)
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Polish the ONT-based assembly using high-accuracy Illumina paired-end
# reads: align short reads to the assembly with BWA-MEM, remove PCR
# duplicates, then run Pilon base correction to fix single-base errors
# introduced by the long-read assembly.
#
# Main analyses
# -------------
#  1. Reference indexing (bwa index)
#  2. Illumina read alignment (bwa mem)
#  3. Sort and duplicate removal (samtools sort / markdup)
#  4. Base-level polishing (Pilon, --fix bases)
#
# Software and versions
# ---------------------
#   bwa          (bwa mem, short-read alignment)
#   samtools     (sort, markdup, index)
#   Pilon 1.23   (base correction; Java)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   $ref (genome.fa)          ONT-only assembly to polish (FASTA)
#   Illumina_R1.fq.gz / R2.fq.gz   paired-end Illumina reads
#
# Output files
# ------------
#   ${name}.final.bam (+ .bai)     duplicate-marked/removed alignments
#   ${name}.polish.fasta           Pilon-polished assembly
#   pilon1.log                     Pilon run log
#
# Notes
# -----
# - Replace /path_to/Illumina_*.fq.gz and /path_to/pilon-1.23.jar with
#   actual paths; $name is the output prefix.
# - MEMORY=430: Java heap (GB), set according to genome size.
# - --mindepth 20: minimum read depth for base correction; adjust to
#   sequencing depth of the Illumina data.
# - --fix bases: only fix single-base errors (no gap/local fixing).
# Recommended: record exact software versions before publication.
# ==============================================================================

ref=genome.fa
bwa index ${ref}
bwa mem -t 36 ${ref} /path_to/Illumina_R1.fq.gz /path_to/Illumina_R2.fq.gz | samtools sort -@ 36 -O bam -o $name
samtools index ${name}.sort.bam
samtools markdup -@ 30 ${name}.sort.bam ${name}.final.bam
samtools index ${name}.final.bam
rm ${name}.sort.bam 
MEMORY=430 ## set by genome size
java -Xmx${MEMORY}G -jar /path_to/pilon-1.23.jar --genome $ref --frags ${name}.final.bam
    --mindepth 20 \
    --fix bases \
    --output ${name}.polish.fasta  &> pilon1.log
