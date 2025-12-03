#!/bin/bash
### Homology-based prediction
ref=genome.fa
ref_masked=genome_masked.fa
thread=36
# maker
mpiexec -n 20  maker  -base MC maker_opts.ctl maker_bopts.ctl maker_exe.ctl
~/software/maker/bin/gff3_merge -d MC.maker.output/MC_master_datastore_index.log
awk '$2=="maker"' MC.all.gff > ${i}.all.gff3
cat MC.maker.output/*_datastore/*/*/*/the*/eviden* | grep protein2genome > maker_exonerate.out
/path_to/EvmUtils/misc/maker_match_gff_to_gene_gff3.pl maker_exonerate.out | grep --color=auto CDS | sed 's/protein2genome/exonerate/g' | sed 's/CDS/nucleotide_to_protein_match/g' > ${i}.exonerate.gff3

