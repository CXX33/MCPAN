#!/bin/bash
#### Functional annotation for orthorgroup protein-coding genes
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

