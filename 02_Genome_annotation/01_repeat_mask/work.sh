#!/bin/bash
# ==============================================================================
# Repeat masking using EDTA
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Identify and mask repetitive elements (especially transposable
# elements) in the assembled genome using EDTA: first run de novo
# TE discovery (EDTA_raw.pl), then the full EDTA pipeline with
# annotation, evaluation and masking, producing a repeat-masked
# genome for downstream analyses.
#
# Main analyses
# -------------
#  1. De novo TE identification (EDTA_raw.pl, --type all)
#  2. TE library construction + genome masking (EDTA.pl, --step all)
#  3. TE annotation with evaluation (--anno 1, --evaluate 1)
#
# Software and versions
# ---------------------
#   EDTA            (EDTA_raw.pl / EDTA.pl; run in dedicated conda env)
#   (dependencies inside env: LTR_retriever, TIR-Learner, HelitronScanner,
#    RepeatMasker, etc.)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   genome.fa       assembly to be masked (FASTA)
#
# Output files
# ------------
#   *.fasta.mod                    soft-masked genome
#   *.fasta.mod.MAKER.masked       hard-masked genome (for MAKER annotation)
#   *.mod.EDTA.TElib.fa            non-redundant TE library
#   *.mod.EDTA.TEanno.gff3         TE annotation (GFF3)
#   *.mod.EDTA.combine.*.gff       combined TE evidence
#   run1.log / run2.log            EDTA run logs
#
# Notes
# -----
# - Replace $ref with the actual assembly path; run within the EDTA
#   conda environment (source activate ~/miniconda3/envs/EDTA).
# - --type all: discover all TE types (LTR/TIR/Helitron/non-TIR);
#   --species others: use for non-model species.
# - --sensitive 1: slower but more complete TE discovery;
#   --evaluate 1: run benchmark evaluation.
# - The hard-masked genome (*.MAKER.masked) is the input for MAKER
#   gene annotation; the TE library is reused across samples if multiple
#   genomes of the same species are annotated.
# Recommended: record exact software versions before publication.
# ==============================================================================

source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/EDTA
ref=genome.fa
EDTA_raw.pl --genome $ref --type all --species others --force 1 --threads 18 &>run1.log
EDTA.pl --overwrite 0 --genome $ref  --anno 1  --step all  --species others --force 1 --sensitive 1 --anno 1 --evaluate 1 --threads 18 &>run2.log
### *.fasta.mod.MAKER.masked:genome of repeat-masked sequences
