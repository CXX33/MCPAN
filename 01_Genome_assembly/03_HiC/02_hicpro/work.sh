#!/bin/bash
# ==============================================================================
# Final Hi-C heatmap plot
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Generate a chromatin contact heatmap of the chromosome-level assembly:
#   (1) process Hi-C reads with HiC-Pro (DpnII) to build raw/iced contact
#       matrices at a given resolution;
#   (2) plot the final contact heatmap with HiCPlotter for visual
#       validation of chromosome-scale scaffolding.
#
# Main analyses
# -------------
#  1. Restriction-site digestion map (digest_genome.py, DpnII)
#  2. Reference indexing and chromosome sizes (samtools faidx)
#  3. HiC-Pro pipeline run (alignment + matrix building)
#  4. ICE normalisation (iced matrix) at 100 kb resolution
#  5. Contact heatmap visualisation (HiCPlotter, PDF)
#
# Software and versions
# ---------------------
#   HiC-Pro 2.11.4      (Hi-C data processing; requires python2)
#   HiCPlotter          (heatmap plotting; requires python2)
#   samtools            (faidx)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   $ref (genome.fa)         chromosome-level reference assembly (FASTA)
#   ${i}_R1.fq.gz / ${i}_R2.fq.gz   Hi-C paired-end reads
#
# Output files
# ------------
#   ${i}_chromosome.dpnii.txt      restriction-site positions (DpnII)
#   ${ref}.fai / ${ref}.size       reference index / chromosome sizes
#   hicpro_output_chromosome/      HiC-Pro output (raw + iced matrices)
#   ${i}_HiCPlot_100000.pdf        final contact heatmap (100 kb, chr-level)
#
# Notes
# -----
# - Replace /path_to/HiC-Pro-2.11.4 and /path_to/HiCPlotter-master with
#   actual paths; ${i} is the sample/library ID.
# - HiC-Pro and HiCPlotter require a python2 environment
#   (e.g. ~/miniconda2/bin/python2 as used here).
# - win_size=100000: bin/resolution (100 kb); adjust per genome size and
#   sequencing depth. -chr chr12 is an example; loop over all chromosomes
#   (or use -wg 1 for the whole-genome view) as needed.
# - The iced matrix is used for plotting to remove distance/bias effects.
# Recommended: record exact software versions before publication.
# ==============================================================================

ref=genome.fa
mkdir 01.ref 02.reads  
cd 01.ref
ln -s $ref
cd ..
cd 02.reads
ln -s /path_to/${i}_R1.fq.gz 
ln -s /path_to/${i}_R2.fq.gz
hicpro=/path_to/HiC-Pro-2.11.4/bin
python2 $hicpro/utils/digest_genome.py -r dpnii -o ${i}_chromosome.dpnii.txt ${ref}
samtools faidx ${ref}
awk '{print $1"\t"$2}'  ${ref}.fai > ${ref}.size
cp /path_to/HiC-Pro-2.11.4/config-hicpro.txt ./
mkdir $PWD/02.reads/sample
mv $PWD/02.reads/*.gz $PWD/02.reads/sample
HiC-Pro --input /path_to/$i/02.reads --output hicpro_output_chromosome --conf ./config-hicpro.txt
win_size=100000
~/miniconda2/bin/python2 /path_to/HiCPlotter-master/HiCPlotter.py -tri 1 -f /path_to/00_hicpro/$i/hicpro_output_chromosome/hic_results/matrix/sample/iced/${win_size}/sample_${win_size}_iced.matrix -bed /path_to/00_hicpro/$i/hicpro_output_chromosome/hic_results/matrix/sample/raw/${win_size}/sample_${win_size}_abs.bed -wg 1 -n ${i} -chr chr12 -fh 0 -r $win_size -hmc 3 -o ${i}_HiCPlot_${win_size} -ext pdf -dpi 226 -mm 10
