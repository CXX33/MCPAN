#!/bin/bash
#### Characterizing centromeric CmSat354 composition
# Extract the centromeric region using CmSat354 copy numbers from TRF
input_path=/path_to/02trf/chr_split
cat $input_path/*.gff3 >> total_chromosome_trf.gff3
less -S total_chromosome_trf.gff3 | grep 'consensus_size=354' > CmCent_trf.gff3
01_extract_cons_seq.py CmCent_trf.gff3 cons_seq.fa
cent=CmCent.fa
formatdb -i $cent -o F -p F
# Confirm the high-copy region of CmSat354 based on cons_seq.out
blastall -p blastn -d $cent -i  cons_seq.fa -o  cons_seq.out -F F -m 9 -b 3 -e 1e-5 -a 1

# Analysis CmSat354 type by randomly extract 500 CmSat354 arrays
ref=genome.fa
bed=CmCent.bed # Final centromeric region

# Extract the centromeric sequences from the genome
cat $bed | while read i
do
        chr_id=`echo $i | awk '{print $1}'`
        start=`echo $i | awk '{print $2}'`
        end=`echo $i | awk '{print $3}'`
        samtools faidx $ref ${chr_id}:${start}-${end} > cent_${chr_id}.fasta
done

# Extract 500 CmSat354 arrays from all centromeric sequences of the chromosomes
for i in {01..12}
do
       01random_cent1.py 13C_cent_chr${i}.fasta 13C_cent_chr${i}.random_windows.cent1.fasta ## CmCentA
       01random_cent2.py 13C_cent_chr${i}.fasta 13C_cent_chr${i}.random_windows.cent2.fasta ## CmCentB
done

# Analysis of CmCentA sequence compisation
for i in {01..12}
do
       02format_for_find_diff.py cent_chr${i}.random_windows.cent1.fasta cent_chr${i}.random_windows.cent1.format.fasta
       awk '{for (i=1; i<=length; i++) a[NR,i]=substr($0,i,1)} END {for (i=1; i<=length; i++) {line=""; for (j=1; j<=NR; j++) line=line a[j,i]; print line}}' cent_chr${i}.random_windows.cent1.format.fasta > tmp
       mv tmp cent_chr${i}.random_windows.cent1.format.fasta
       03count_frequency.py cent_chr${i}.random_windows.cent1.format.fasta cent_chr${i}.random_windows.cent1.format.count
       04_extract_diff_site.py cent_chr${i}.random_windows.cent1.format.count cent_chr${i}.random_windows.cent1.diff_site
done

# Analysis of CmCentB sequence compisation
cat  cent_chr*.random_windows.cent2.fasta >> total.random_windows.cent2.fasta
02format_for_find_diff.py total.random_windows.cent2.fasta total.random_windows.cent2.format.fasta
awk '{for (i=1; i<=length; i++) a[NR,i]=substr($0,i,1)} END {for (i=1; i<=length; i++) {line=""; for (j=1; j<=NR; j++) line=line a[j,i]; print line}}' total.random_windows.cent2.format.fasta > tmp_total
mv tmp_total total.random_windows.cent2.format.fasta
03count_frequency.py total.random_windows.cent2.format.fasta total.random_windows.cent2.format.count
# Difference sites: S4 S6 S69 S72 S131 S137 S150 S205 S239 S283
cat cent_chr*.random_windows.cent1.fasta cent_chr*.random_windows.cent2.fasta > total_cent1_cent2.random_windows.fasta
02format_for_find_diff.py total_cent1_cent2.random_windows.fasta total_cent1_cent2.random_windows.format.fasta
awk '{for (i=1; i<=length; i++) a[NR,i]=substr($0,i,1)} END {for (i=1; i<=length; i++) {line=""; for (j=1; j<=NR; j++) line=line a[j,i]; print line}}' total_cent1_cent2.random_windows.format.fasta > tmp  && mv tmp total_cent1_cent2.random_windows.format.fasta
03count_frequency.py total_cent1_cent2.random_windows.format.fasta total_cent1_cent2.random_windows.format.fasta.count

