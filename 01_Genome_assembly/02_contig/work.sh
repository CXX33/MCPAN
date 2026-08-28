#!/bin/bash
# ==============================================================================
# De novo assembly using HiFi, ONT-ultralong, or HiFi-ONT reads
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# De novo genome assembly with hifiasm under three read-input modes:
#   (1) ONT-ultralong only, (2) HiFi only, (3) HiFi + ONT-ultralong hybrid.
# Outputs primary assembly (--primary) with dual assembly scaffolding
# (--dual-scaf) for haplotype-resolved contigs.
#
# Main analyses
# -------------
#  1. ONT-ultralong-only assembly (hifiasm --ont)
#  2. HiFi-only assembly (hifiasm, default mode)
#  3. HiFi-ONT hybrid assembly (hifiasm --ul)
#
# Software and versions
# ---------------------
#   hifiasm   (de novo assembler; --ont/--ul require v0.16.1+)
#   NOTE: record exact hifiasm version before publication.
#
# Input files
# -----------
#   $hifi/hifi.fq.gz     HiFi reads (FASTA/Q, gzipped)
#   $ont/ont.fq.gz       ONT-ultralong reads (FASTA/Q, gzipped)
#
# Output files
# ------------
#   <prefix>.bp.p_ctg.gfa        primary contig assembly graph
#   <prefix>.bp.hap1/hap2.p_ctg.gfa   haplotype-resolved assemblies (--dual-scaf)
#   <prefix>.bp.r_utg.gfa        r-utg graph (repeats)
#   <prefix>.dbg / .bin / .ovlp  intermediate hifiasm files
#
# Notes
# -----
# - Replace /path_to/hifi and /path_to/ont with actual read paths.
# - -r/-n: number of reads used for phasing (r) and initial binning (n);
#   -l 2: minimum read length (kb) kept for phasing.
# - --hg-size 390m: haploid genome size of the target species
#   (adjust to your species; needed for --ul mode).
# - -t: thread count; reduce if running on limited CPUs.
# - Assembly graph (.gfa) must be converted to FASTA (e.g. via
#   hifiasm output <prefix>.bp.p_ctg.fa or awk/gfatools) before
#   downstream scaffolding / polishing.
# ==============================================================================
# Recommended: record exact software versions before publication.

##### De novo Assembly Using HiFi, ONT-ultralong, or HiFi-ONT Reads
HiFi=/path_to/hifi
ONT=/path_to/ont
### ont only
hifiasm -o ont_only -t 32 --ont $ont/ont.fq.gz -r 5 -n 15 -l 2 --dual-scaf --primary
### hifi only
hifiasm -o hifi_only -t 32  -r 10 -n 15 -l 2 --dual-scaf --primary  $hifi/hifi.fq.gz
### hifi-ont 
hifiasm -o hifi_ont_all -t 14 --ul $ont/ont.fq.gz $hifi/hifi.fq.gz  -r 4 --primary --hg-size 390m

