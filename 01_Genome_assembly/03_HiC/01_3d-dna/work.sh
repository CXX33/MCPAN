#!/bin/bash
# ==============================================================================
# Contig anchoring using 3D-DNA with Juicebox
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Anchor and scaffold contigs into chromosomes using Hi-C data:
#   (1) process Hi-C reads with Juicer (DpnII) to produce contact maps;
#   (2) run the 3D-DNA assembly pipeline to order/orient contigs;
#   (3) manually correct the assembly in Juicebox (.review.assembly)
#       and re-run the post-review pipeline to finalize scaffolds.
#
# Main analyses
# -------------
#  1. Reference indexing (bwa index)
#  2. Restriction-site generation (DpnII) and chrom.sizes preparation
#  3. Hi-C read processing with Juicer (merged_nodups.txt)
#  4. 3D-DNA assembly (run-asm-pipeline.sh, haploid mode)
#  5. Juicebox manual curation (.review.assembly)
#  6. Post-review re-assembly (run-asm-pipeline-post-review.sh)
#
# Software and versions
# ---------------------
#   Juicer 1.6 (CPU)          (juicer.sh, generate_site_positions.py)
#   3D-DNA (run-asm-pipeline) (misc/run-asm-pipeline*.sh)
#   bwa                       (read/ref alignment)
#   Juicebox                  (manual review / curation)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   $ref                       contig-level reference assembly (FASTA)
#   ${i}_R1/R2.fastq.gz        Hi-C paired-end reads (per library ${i})
#
# Output files
# ------------
#   ${ref}_DpnII.txt           restriction-site positions (DpnII)
#   ${ref}.chrom.sizes         chromosome sizes table
#   aligned/${i}.mnd           merged_nodups.txt (Juicer contact file)
#   ${i}.review.assembly       Juicebox-curated assembly (post 3D-DNA)
#   final scaffolds            run-asm-pipeline-post-review output
#
# Notes
# -----
# - Replace /path_to/juicer-1.6, /path_to/3d-dna-master and /path_to/01_3d_dna
#   with actual paths; ${i} is the sample/library ID.
# - -s DpnII: restriction enzyme; must match the enzyme used in the Hi-C
#   library (change generate_site_positions.py accordingly if different).
# - -m haploid: use haploid mode for a homozygous genome; use diploid
#   mode if haplotypes are to be resolved.
# - Juicebox curation is a manual step: load .review.assembly in Juicebox,
#   fix misjoins/duplications, then save and re-run post-review pipeline.
# Recommended: record exact software versions before publication.
# ==============================================================================

ref=contig.fa
mkdir scripts references fastq restriction_sites
cp -r /path_to/juicer-1.6/CPU/common scripts/
cd references/
ln -s $ref
bwa index $ref
cp /path_to/juicer-1.6/misc/generate_site_positions.py $PWD/../
python ../generate_site_positions.py DpnII $ref $ref
awk 'BEGIN{OFS="\t"}{print $1, $NF}'  ${ref}_DpnII.txt > ${ref}.chrom.sizes
cd ..
cp references/${ref}_DpnII.txt restriction_sites/
cd fastq
ln -s /path_to/${i}_R1.fastq.gz
ln -s /path_to/${i}_R2.fastq.gz
cd ..
bash /path_to/juicer-1.6/CPU/juicer.sh -t 30 -s DpnII -g ${i} -d /path_to/01_3d_dna/${i} -D /path_to/01_3d_dna/${i} -z /path_to/01_3d_dna/references/${ref} -p /path_to/references/${ref}.chrom.sizes -y /path_to/restriction_sites/${ref}_DpnII.txt
mv /path_to/aligned/merged_nodups.txt /path_to/aligned/${i}.mnd
bash /path_to/3d-dna-master/run-asm-pipeline.sh -m haploid -i 15000 -r 0 /path_to/references/${ref} /path_to/aligned/${i}.mnd
#### ${i}.review.assembly: corrected output by Juicebox
bash /path_to/3d-dna-master/run-asm-pipeline-post-review.sh -r ${i}.review.assembly /path_to/references/${i}.hifiasm.fa /path_to/aligned/${i}.mnd
