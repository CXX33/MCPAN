#!/bin/bash
# ==============================================================================
# Functional annotation of orthogroup protein-coding genes
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Annotate functions of orthogroup protein-coding genes (from OrthoFinder)
# by combining: (1) InterProScan domain/GO annotation, (2) BLAST-based
# homology against Arabidopsis (Araport11) and UniProt-SwissProt, and
# (3) GO term information retrieval. Runs are parallelised across 100
# protein partitions on a cluster (quick_qsub).
#
# Main analyses
# -------------
#  1. Orthogroup gene extraction (Orthofinder Orthogroups.txt -> gene list)
#  2. Protein sequence retrieval and split into 100 partitions (seqkit)
#  3. InterProScan annotation (domains/IPR/GO/Pfam) and result merging
#  4. GO annotation assembly (combined GO + goterm information)
#  5. BLASTp homology: Arabidopsis Araport11 (Arablast)
#  6. BLASTp homology: UniProt-SwissProt (swiss_prot)
#
# Software and versions
# ---------------------
#   InterProScan 5.48-83.0   (domain/GO/Pfam annotation)
#   BLAST+ (blastall)        (blastp homology search)
#   seqkit                   (grep / split2)
#   OrthoFinder              (Orthogroups.txt source)
#   custom python scripts    (extract_Orthogroup_gene.py,
#                             combine_interpro_result.py,
#                             combine_GO_result.py, add_GO_infor.py,
#                             extract_function.py)
#   quick_qsub               (cluster job submission wrapper)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   Orthogroups.txt            OrthoFinder orthogroup table
#   total_MC.pep               merged proteomes of all species
#   Araport11_genes.201606.pep.fasta   Arabidopsis proteome
#   uniprot_sprot_20201221.fasta       Swiss-Prot proteome
#   goterm.txt                 GO term definitions
#
# Output files
# ------------
#   Orthogroup2Gene.xls                 gene-to-orthogroup table
#   Orthogroup2Gene.pep                 orthogroup proteins
#   Orthogroup2Gene_interpro.xls        InterPro domain annotations
#   Orthogroup2Gene_GO_combine_info.xls GO annotations (+ term info)
#   Orthogroup2Gene_to_Aradatabase.out  Araport11 homology annotation
#   Orthogroup2Gene_to_Swissprot.out    Swiss-Prot homology annotation
#
# Notes
# -----
# - Replace /path_to/... with actual paths.
# - InterProScan uses -goterms -iprlookup -pa -f TSV; retain the exact
#   database set (Pfam, PANTHER, etc.) in the Methods.
# - IPR/GO lines are parsed from the TSV with awk; final annotation is
#   de-duplicated (sort | uniq) before combination.
# - quick_qsub is a cluster scheduler wrapper (here 1 CPU per partition);
#   adjust -q and resource flags to your cluster.
# - BLAST threshold used: -e 1e-5, -F F (no low-complexity filter),
#   top 3 hits (-b 3); state this in the Methods.
# - Record database versions: Araport11 (2016-06), Swiss-Prot
#   (2020-12-21), InterProScan (5.48-83.0) - all required for
#   reproducibility.
# Recommended: record exact software versions before publication.
# ==============================================================================

ln -s /path_to/Orthogroups/Orthogroups.txt
./extract_Orthogroup_gene.py Orthogroups.txt Orthogroup2Gene.xls
cat /path_to/database/*.pep >> total_MC.pep
less -S Orthogroup2Gene.xls | awk '{print $2}' > gene_list
seqkit grep -f gene_list total_MC.pep -o Orthogroup2Gene.pep

mkdir split_Orthogroup2Gene_pep
seqkit split2 -p 100 Orthogroup2Gene.pep -O split_Orthogroup2Gene_pep
for i in {001..100}
do       
       quick_qsub =interproscan= {-q cu -l nodes=1:ppn=1} "/path_to/anno_data/interproscan-5.48-83.0/interproscan.sh -i ./split_Orthogroup2Gene_pep/Orthogroup2Gene.part_${i}.pep -o interscan_${i}.tsv -goterms -iprlookup -pa -f TSV -cpu 1 "
	mv interscan_*.tsv split_Orthogroup2Gene_pep
done
mv interscan_*.tsv split_Orthogroup2Gene_pep
cat split_Orthogroup2Gene_pep/interscan_*.tsv >> Orthogroup2Gene_interproscan.tsv
awk 'BEGIN{FS = "\t"}{for (f=1; f <= NF; f+=1) {if ($f ~ /IPR/) {print $1"\t"$f"\t"$(f+1)}}}' Orthogroup2Gene_interproscan.tsv > Orthogroup2Gene_interproscan_all
awk 'BEGIN{FS = "\t"}{for (f=1; f <= NF; f+=1) {if ($f ~ /GO:/) {print $1"\t"$f}}}' Orthogroup2Gene_interproscan.tsv > Orthogroup2Gene_go_annot_all
sed -i 's/|GO/\tGO/g' Orthogroup2Gene_go_annot_all
awk -F '\t' 'BEGIN{OFS="~"}{print $1,$2,$3}' Orthogroup2Gene_interproscan_all |sort |uniq > Orthogroup2Gene_interproscan_all_uniq
anno_script=/path_to/anno_script/interproscan
anno_data=/path_to/chenxinxiu/anno_data
######################## interpro final file
python3 $anno_script/combine_interpro_result.py Orthogroup2Gene_interproscan_all_uniq> Orthogroup2Gene_interpro.xls
python3 $anno_script/combine_GO_result.py Orthogroup2Gene_go_annot_all Orthogroup2Gene_GO_combine.xls ; grep -v "^$" Orthogroup2Gene_GO_combine.xls > 1 ; mv 1 Orthogroup2Gene_GO_combine.xls
########################GO final file
python3 $anno_script/add_GO_infor.py $anno_data/goterm.txt Orthogroup2Gene_GO_combine.xls Orthogroup2Gene_GO_combine_info.xls
########### Arablast pep work
mkdir blast_work
cd blast_work
mkdir 01_Arablast
cd 01_Arablast
for i in {001..100}
do
	quick_qsub =Ara= {-q cu -l nodes=1:ppn=1} "blastall -p blastp -d /path_to/anno_data/Araport11_genes.201606.pep.fasta -i /path_to/split_Orthogroup2Gene_pep/Orthogroup2Gene.part_${i}.pep -o Orthogroup2Gene_ara_${i}.out -F F -m 9 -b 3 -e 1e-5 -a 1"	
done
cat *.out > Orthogroup2Gene_ara.result
python3 $anno_script/extract_function.py -i1 /path_to/anno_data/Araport11_genes.201606.pep.fasta -i2 Orthogroup2Gene_ara.result -o Orthogroup2Gene_to_Aradatabase.out

############swiss_prot work ##
cd blast_work
mkdir 02_swiss_prot_work
cd 02_swiss_prot_work
for i in {001..100}
do
       quick_qsub =swiss= {-q cu -l nodes=1:ppn=1} "blastall -p blastp -d /path_to/anno_data/uniprot_sprot_20201221.fasta -i /path_to/split_Orthogroup2Gene_pep/Orthogroup2Gene.part_${i}.pep -o blast_${i}.out -F F -m 9 -b 3 -e 1e-5 -a 1"
done
cat *.out > blast.result
python3 $anno_script/extract_function.py -i1 /path_to/anno_data/uniprot_sprot_20201221.fasta -i2 blast.result  -o Orthogroup2Gene_to_Swissprot.out

