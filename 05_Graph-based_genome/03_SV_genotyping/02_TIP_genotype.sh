#!/bin/bash
#### SV genotyping using SV and their flank region sequences
script=./script
# Extract the missing SVs using the VG genotype pipeline
$script/extract_failed_sv.py MC_MS_total_SV.frequency.xls ins_del.merge.final.vcf MC_MS_total_SV.failed_sv.xls
$script/extract_complex_sv.py MC_MS_total_SV.frequency.xls MC_MS_total_SV.complex_sv.frequency.xls
cat MC_MS_total_SV.failed_sv.xls MC_MS_total_SV.complex_sv.xls | sort -k1.4n -k2n,2 > MC_MS_total_SV.problem_sv.xls
## TIP genotyping pipeline
$script/00_TE_index.py MC_MS_total_SV.problem_sv.xls problem_sv.index
  # SV of deletion
mkdir tmp01
cd tmp01
cat all_query_gemomes.txt | while read i
do
       $script/01_ref_DEL_TE_info.py ../problem_sv.index /path_to/${i}/${i}.ins_del.filter.vcf ${i}.del.info ## vcf: SYRI output of 01_SV_identification
done
cat tmp01/* >> tmp
less -S tmp | sort -k4,4 | awk '!seen[$4]++' > ref_DEL.problem_sv.info && rm tmp
  # SV of insertion
mkdir tmp02
cd tmp02
cat ../all_query_gemomes.txt | while read i
do
       $script/01_ref_INS_TE_info.py -TE_index ../problem_sv.index -vcf /path_to/${i}/${i}.ins_del.filter.vcf -name $i -o ${i}.ins.info
done
cat tmp02/* >> tmp
less -S tmp | sort -k4,4 | awk '!seen[$4]++' > ref_INS.problem_sv.info && rm tmp
# sv flank 1k sequence
##ref.Non-referenceTEinsertions_and_flanking1kb.fasta
cat ref_INS.problem_sv.info | while read i
do
       id=`echo $i | awk '{print $5}'`
       chr=`echo $i | awk '{print $1}'`
       sta=`echo $i | awk '{print $2}'`
       end=`echo $i | awk '{print $3}'`
       te=`echo $i | awk '{print $4}'`
       n=1000
       sta_new=$(( $sta - $n ))
       end_new=$(( $end + $n ))
       samtools faidx /path_to/00_database/${id}.fa $chr:$sta_new-$end_new >> ref.Non-referenceTEinsertions_and_flanking1kb.fasta
       sed -i "s/$chr:$sta_new-$end_new/$te/g" ref.Non-referenceTEinsertions_and_flanking1kb.fasta
done

#ref.referenceTEinsertions_and_flanking1kb.fasta
/path_to/02_DEL_extract_flank_1k_fa.py 13C.fa ref_DEL.problem_sv.info ref.referenceTEinsertions_and_flanking1kb.fasta
rm tmp
cat ref.referenceTEinsertions_and_flanking1kb.fasta ref.Non-referenceTEinsertions_and_flanking1kb.fasta >> tmp
########  exclude gap seq
$script/02_exclude_gap.py tmp panTE_seq_flanking1kb.fa 
mkdir tmp_te_genotype && quick_qsub =bwa_index= {-q cu -l nodes=1:ppn=5} "bwa index panTE_seq_flanking1kb.fa"
cat MS_MC_accession.WGS.list | while read i
do
       R1=`echo $i | awk '{print $1}'`
       R2=`echo $i | awk '{print $2}'`
       name=`echo $i | awk '{print $3}'`
       echo "cd tmp_te_genotype && perl $script/03.TE_insertions_genotype.pl -Fasta panTE_seq_flanking1kb.fa -leftRead $R1 -rightRead $R2 -samId ${name} -output ${name}.refereceTEinsertion -script $script -threads 12 && cd -" >> command.sh
done
split -n r/30 -d -a 2 command.sh command_
for i in {00..30}
do
       chmod +x command_${i}
       quick_qsub =ITIPS_${i}= {-q cu -l nodes=1:ppn=12} "./command_${i}"
done

# filter TE genotype
mkdir tmp_te2
cat MS_MC_accession.WGS.list| awk '{print $3}' | while read i
do
       $script/format_genotype.py panTE_seq_flanking1kb.final.xls tmp_te_genotype/${i}.refereceTEinsertion tmp_te2/${i}.format.refereceTEinsertion
       $script/redundancy_same_sv.py tmp_te2/${i}.format.refereceTEinsertion tmp_te2/${i}.final.refereceTEinsertion
       rm tmp_te2/${i}.format.refereceTEinsertion
done

less -S MC_MS.SV.filter.vcf | head -n 1000  |grep '#CHROM' | sed 's/\t/\n/g' > accession.sort.list 
vcftools --vcf ins_del.merge.final.vcf --positions problem_sv.index --recode --recode-INFO-all --out problem_sv
less -S problem_sv.recode.vcf | grep -v "##" | cut -f1-8 > problem_sv.final.vcf
cat accession.sort.list | while read i
do
       name=`echo $i | awk '{print $1}'`
quick_qsub =format_vcf= {-q cu -l nodes=1:ppn=1} "$script/format_vcf.py -vcf problem_sv.final.vcf -TE_geno tmp_te2/${name}.final.refereceTEinsertion -o tmp_vcf/${name}_TE.vcf -header header -name ${name}"
       quick_qsub =$name= {-q cu -l nodes=1:ppn=1}"bcftools sort tmp_vcf/${name}_TE.vcf -o tmp_vcf/${name}_TE.sort.vcf && bgzip -c -f tmp_vcf/${name}_TE.sort.vcf > tmp_vcf/${name}_TE.sort.vcf.gz &&  bcftools index  tmp_vcf/${name}_TE.sort.vcf.gz && rm tmp_vcf/${name}_TE.vcf tmp_vcf/${name}_TE.sort.vcf"
        echo tmp_vcf/${name}_TE.sort.vcf.gz >> merge.sh
done
bash $script/merge.sh
quick_qsub =plink= {-q cu -l nodes=1:ppn=5} "plink --vcf TIP.merge.vcf  --allow-extra-chr --geno 0.4 --mac 10 --recode vcf-iid --biallelic-only --out TIP.SV.filter"

### combine VG and TIP genotyping 
less -S MC_MS.SV.filter.vcf | head -n 100  |grep '#CHROM' | sed 's/\t/\n/g' > tmp1
less -S TIP.SV.filter.vcf | head -n 100  |grep '#CHROM' | sed 's/\t/\n/g' > tmp2
paste tmp1 tmp2  > check_accession.list
rm tmp1 tmp2
less -S TIP.SV.filter.vcf  | grep -v "#" | awk '{print $1"\t"$2}' > TIP.SV.filter.index
less -S MC_MS.SV.filter.vcf | head -n 100 | grep '#' > header
less -S TIP.SV.filter.vcf | grep -v "#" | awk '{print $1"\t"$2"\t"$3}' > TIP.SV.filter.index

$script/difference.py TIP.SV.filter.index MC_MS_total.SV.final.vcf MC_MS.SV.tmp.vcf
less -S TIP.SV.filter.vcf  | grep -v "#" > TIP.SV.tmp.vcf
cat MC_MS.SV.tmp.vcf TIP.SV.tmp.vcf | sort -k1n -k2n,2 > MC_MS.final.tmp.vcf
cat header MC_MS.final.tmp.vcf > MC_MS.SV.has_mullic.vcf
$script/format_mullic.py MC_MS.SV.has_mullic.vcf MC_MS.SV.format_mullic.vcf
rm *tmp.vcf
quick_qsub =plink= {-q cu -l nodes=1:ppn=5} "plink --vcf MC_MS.SV.format_mullic.vcf  --allow-extra-chr --geno 0.2 --mac 10 --recode vcf-iid --biallelic-only --out MC_MS.SV.update"
bcftools stats MC_MS.SV.update.vcf > MC_MS.SV.update.vcf.stat
