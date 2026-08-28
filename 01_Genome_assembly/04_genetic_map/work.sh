#!/bin/bash
# ==============================================================================
# Contig anchoring using genetic maps
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Anchor and order contigs into linkage groups / chromosomes using two
# genetic maps: BLAST map markers against the contig assembly, then
# merge the two maps with ALLMAPS (jcvi) and order/orient contigs
# along the integrated genetic map.
#
# Main analyses
# -------------
#  1. BLAST database build for the contig assembly (makeblastdb)
#  2. Marker mapping of two genetic maps onto contigs (blastn)
#  3. BLAST-to-map conversion (pre_map_ctg.py -> map1.csv / map2.csv)
#  4. Map merging (jcvi.assembly.allmaps merge)
#  5. Contig ordering/orientation (jcvi.assembly.allmaps path)
#
# Software and versions
# ---------------------
#   BLAST+              (makeblastdb, blastn)
#   jcvi (allmaps)      (python -m jcvi.assembly.allmaps)
#   pre_map_ctg.py      (project-specific conversion script)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   contig.fa (contig)      contig-level assembly (FASTA)
#   map1.fa / map2.fa       marker sequences of two genetic maps (FASTA)
#   map1.csv / map2.csv     genetic map files (after conversion)
#
# Output files
# ------------
#   ${name}_final_contig_map1.blast / _map2.blast   BLAST hits (outfmt 6)
#   map1.csv / msp2.csv                            converted map files
#   2_maps_${name}.bed                              merged genetic map
#   weights.txt                                     marker weights for merging
#   ALLMAPS path output                             anchored/ordered contigs
#
# Notes
# -----
# - Replace /path_to/pre_map_ctg.py with the actual path; ${name} is the
#   sample ID.
# - map1.fa / map2.fa: use high-confidence, evenly distributed markers
#   (e.g. SSR/SNP linkage groups) for robust anchoring.
# - -max_target_seqs 5: allow multi-hits; manually resolve markers with
#   conflicting best hits before merging.
# - The merged map (2_maps_${name}.bed) integrates both maps; weights.txt
#   can prioritise the more reliable map.
# Recommended: record exact software versions before publication.
# ==============================================================================

map1=map1.fa
map2=map2.fa
contig=contig.fa
makeblastdb -in $contig -dbtype nucl -out $contig
blastn -db $contig -query $map1 -out ${name}_final_contig_map1.blast -max_target_seqs 5 -outfmt 6 -num_threads 5 -evalue 1e-5
blastn -db  $contig -query $map2 -out ${name}_final_contig_map2.blast -max_target_seqs 5 -outfmt 6 -num_threads 5 -evalue 1e-5
/path_to/pre_map_ctg.py ${name}_final_contig_map1.blast map1.csv
/path_to/pre_map_ctg.py ${name}_final_contig_map2.blast msp2.csv
~/miniconda2/bin/python -m jcvi.assembly.allmaps merge map1.csv  map2.csv -o 2_maps_${name}.bed  -w weights.txt
~/miniconda2/bin/python -m jcvi.assembly.allmaps path 2_maps_${name}.bed $contig -w weights.txt

