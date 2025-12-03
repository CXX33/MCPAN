#!/bin/bash
#### Counting the number of polymorphic variants in subpopulations
snp=population.SNP.vcf
indel=population.InDel.vcf
SV=population.SV.vcf
TE=population.TE.vcf
# Extract total polymorphic variants in subpopulations
for i in agrestis melo
do
	vcftools --vcf $snp  --keep ${i}.keep --maf 0.05 --max-missing 0.8 --recode --recode-INFO-all --out ${i}.filter_maf.snp
	vcftools --vcf $indel  --keep ${i}.keep --maf 0.05 --max-missing 0.8 --recode --recode-INFO-all --out ${i}.filter_maf.indel
	vcftools --vcf $SV  --keep ${i}.keep --maf 0.01 --max-missing 0.8 --recode --recode-INFO-all --out ${i}.filter_maf.sv
	vcftools --vcf $TE  --keep ${i}.keep --maf 0.01 --max-missing 0.8 --recode --recode-INFO-all --out ${i}.filter_maf.te
done

# 200 accessions were randomly selected from each subpopulation to minimize bias arising from unequal sample sizes
mkdir random_tmp
for i in {001..100}
do
        less -S agrestis.keep | shuf | head -n 200 > random_tmp/random_agrestis_${i}.keep
        less -S melo.keep | shuf | head -n 200 > random_tmp/random_melo_${i}.keep
        for k in agrestis melo
	do
		# snp
		snp=${k}.filter_maf.snp.recode.vcf
		quick_qsub =vcftools= {-q cu -l nodes=1:ppn=1} "cd snp && vcftools --vcf $snp  --keep /path_to/random_tmp/random_${k}_${i}.keep --maf 0.05 --recode --recode-INFO-all --out ${k}.filter_maf.snp.${i}"
		format.py  ${k}.filter_maf.snp.${i}.recode.vcf ${k}.filter_maf.snp.${i}.info && rm ${k}.filter_maf.snp.${i}.recode.vcf && wc -l  ${k}.filter_maf.snp.${i}.info >> ${k}.snp.info.txt
		# indel
		indel=${k}.filter_maf.indel.recode.vcf
		quick_qsub =vcftools= {-q cu -l nodes=1:ppn=1} "cd indel && vcftools --vcf $snp  --keep /path_to/random_tmp/random_${k}_${i}.keep --maf 0.05 --recode --recode-INFO-all --out ${k}.filter_maf.indel.${i}"
		format.py ${k}.filter_maf.indel.${i}.recode.vcf ${k}.filter_maf.indel.${i}.info && rm ${k}.filter_maf.indel.${i}.recode.vcf && wc -l  ${k}.filter_maf.indel.${i}.info >> ${k}.indel.info.txt
		# sv
		sv=${k}.filter_maf.sv.recode.vcf
		quick_qsub =vcftools= {-q cu -l nodes=1:ppn=1} "cd sv && vcftools --vcf $snp  --keep /path_to/random_tmp/random_${k}_${i}.keep --maf 0.01 --recode --recode-INFO-all --out ${k}.filter_maf.sv.${i}"
		 format.py ${k}.filter_maf.indel.${i}.recode.vcf ${k}.filter_maf.sv.${i}.info && rm ${k}.filter_maf.sv.${i}.recode.vcf && wc -l  ${k}.filter_maf.sv.${i}.info >>${k}.sv.info.txt
		# te
		te=${k}.filter_maf.te.recode.vcf
		quick_qsub =vcftools= {-q cu -l nodes=1:ppn=1} "cd te && vcftools --vcf $snp  --keep /path_to/random_tmp/random_${k}_${i}.keep --maf 0.01 --recode --recode-INFO-all --out ${k}.filter_maf.te.${i}"
		 format.py ${k}.filter_maf.te.${i}.recode.vcf ${k}.filter_maf.indel.${i}.info && rm ${k}.filter_maf.te.${i}.recode.vcf && wc -l  ${k}.filter_maf.te.${i}.info >>${k}.te.info.txt
	done
done
