#!/bin/bash
# Genome survey using HiFi reads
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Estimate genome size, heterozygous rate and repeat content of the target
# genome from HiFi reads using a K-mer frequency spectrum approach.
#
# Main analyses
# -------------
#  1. K-mer frequency counting (kmerfreq, K=17)
#  2. Genome size estimation (GCE)
#  3. Heterozygous ratio estimation
#  4. Repeat content estimation
#
# Software and versions
# ---------------------
#   kmerfreq   (K-mer counting)
#   gce        (genome size / heterozygosity / repeat estimation)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   hifi.fa         HiFi reads (FASTA)
#   read.list       list of input FASTA files, one per line
#
# Output files
# ------------
#   17.kmer.freq.stat          raw K-mer frequency table
#   17kmer.freq.stat.2colum    2-column frequency table for GCE
#   17.gce.stat1               1st-round GCE estimate
#   17.gce.log1                 1st-round GCE log
#   17.gce.stat2               2nd-round GCE estimate (with -c/-H)
#   17.gce.log2                 2nd-round GCE log
#
# Notes
# -----
# - Replace /path_to/HiFi with the actual path to your HiFi reads.
# - K (17), threads (-t 12) and cutoff (-c) may need adjustment
#   depending on genome size, depth and read length.
# - genome_size    = effective_kmer_individuals / coverage_depth
# - heterozygous   = a[1/2] / (2 - a[1/2])
# - repeat content = 1 - b[1/2] - b[1]
# ==============================================================================
# Recommended: record exact software versions before publication.

path=/path_to/HiFi
ls $path/hifi.fa > read.list
/path_to/kmerfreq -k 17 -t 12 -p 17 -f 2 read.list
less  17.kmer.freq.stat | perl -ne 'next if(/^#/ || /^\s/); print; ' | awk '{print $1"\t"$2}' > 17kmer.freq.stat.2colum
num1=$(grep '#Kmer indivdual number' 17.kmer.freq.stat | awk -F: '{print $2}')
gce -g  "$num1" -f  17kmer.freq.stat.2colum  >17.gce.stat1  2>17.gce.log1
num2=$(cat  17.gce.log1 | tail -n 3 | head -n 1 | awk '{print $1}')
gce -g "$num1" -f 17kmer.freq.stat.2colum -c "$num2" -H 1 >17.gce.stat2 2>17.gce.log2
