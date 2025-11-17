#!/bin/bash
###  Predicts the location of ribosomal RNA genes in genomes.
ref=genome.fa
~/miniconda3/bin/barrnap -k euk --threads 18 -o ${id}_rDNA.fa < $ref > ${id}_rDNA.gff
