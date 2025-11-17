#!/bin/bash
sof_path=/path_to/software/OrthoFinder-2.5.4
database=/path_to/pangenome_proteins
ulimit -n 1256
$sof_path/orthofinder.py -f database -M msa -T iqtree -t 36 -a 36
