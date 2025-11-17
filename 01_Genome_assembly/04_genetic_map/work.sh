#!/bin/bash
### Contig  anchored using genetic maps
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

