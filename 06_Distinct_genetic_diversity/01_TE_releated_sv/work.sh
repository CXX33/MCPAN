#!/bin/bash
#### TE-related SVs identification
# Prediction of TE in genomes using EDTA
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/EDTA
cat all_genomes.txt | while read i
do

	EDTA_raw.pl --genome $ref --type all --species others --force 1 --threads 18 &>run1.log && EDTA.pl --overwrite 0 --genome $ref  --anno 1  --step all  --species others --force 1 --sensitive 1 --anno 1 --evaluate 1 --threads 18 &>run2.log
done
# Construction of TE libraries
cat *.fa.mod.EDTA.final/${i}.fa.mod.EDTA.raw.fa >> TE.raw.fa
cd-hit -i TE.raw.fa -o TE_library.fa -c 0.70 -aS 0.70 -aL 0.70 -d 0 -n 4 -T 0 -l 100 -g 1 -M 24000
# BLAST
./extract_sv_sequence.py  ins_del.merge.final.vcf ins_del.fa
ref=TE_library.fa
blastall -p blastn -d $ref -i ins_del.fa -o sv_TE.out -F F -m 9 -b 5  -e 1e-5 -a 30
less -S sv_TE.out  | grep -v "#" | awk '$3>=80' | awk '$4>=150' > test
best_hit.py sv_TE.out sv_TE.best.hit.out
# Categories
less -S sv_TE.out | grep '^chr' | awk '{print $1}' | sort | uniq > sv_aligned_te.xls
SV_TE_coverage.py ins_del.info total.raw_TE.format.info sv_TE.out sv_TE_raw.coverage.xls
less -S sv_TE_raw.coverage.xls | awk '$2>=0.8' | awk '$4>=0.8' > complete_SV_TE.txt
less -S sv_TE_raw.coverage.xls | awk '$2<0.8' | awk '$4>=0.8' > SV_contain.txt
less -S sv_TE_raw.coverage.xls | awk '$2>=0.8' | awk '$4<0.8' > TE_contain.txt
less -S sv_TE_raw.coverage.xls | awk '$2<0.8' | awk '$4<0.8' > overlap_SV_TE.txt

# LTR subfamily
less -S sv_TE_raw.coverage.xls | grep 'LTR'  | awk '{print $3}' | sort | uniq > LTR_SV.xls
seqkit grep -f LTR_SV.xls TE.raw.fa -o LTR_sv.fa
qry=LTR_sv.fa
~/miniconda3/envs/EDTA/bin/TEsorter -db rexdb-plant -st nucl -pre LTR_sv -p 20 LTR_sv.fa 

for i in Gypsy Copia DTC Helitron  DTA DTM DTH DTT unknown
do
        less -S complete_SV_TE.txt | grep ${i} | wc -l
        less -S overlap_SV_TE.txt | grep ${i} | wc -l
	less -S TE_contain.txt  | grep ${i} | wc -l
        less -S SV_contain.txt | grep ${i} | wc -l
done

for i in complete_SV_TE overlap_SV_TE TE_contain SV_contain
do
        ./add_length.py ins_del.info ${i}.txt  ${i}.length.xls
done
