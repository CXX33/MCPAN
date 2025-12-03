#!/bin/bash
### Repeat masking using EDTA
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/EDTA
ref=genome.fa
EDTA_raw.pl --genome $ref --type all --species others --force 1 --threads 18 &>run1.log
EDTA.pl --overwrite 0 --genome $ref  --anno 1  --step all  --species others --force 1 --sensitive 1 --anno 1 --evaluate 1 --threads 18 &>run2.log
### *.fasta.mod.MAKER.masked:genome of repeat-masked sequences
