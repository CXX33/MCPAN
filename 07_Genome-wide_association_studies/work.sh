#!/bin/bash
#### Genome-wide association studies
## Taking the SV in total of the MS population as an example.

vcf=MS_population_SV.vcf
spe=MS_population_SV
## plink
plink  --vcf $vcf --recode12 --allow-extra-chr --geno 0.2 --maf 0.01 --allow-no-sex --biallelic-only --out $spe
# pca
plink  --file $spe  --indep-pairwise 50 5 0.2 --recode vcf-iid --out ${spe}_LDpruned
plink --allow-extra-chr --file ${spe} --recode vcf-iid --extract ${spe}_LDpruned.prune.in --out ${spe}_LDpruned
plink --allow-extra-chr --vcf ${spe}_LDpruned.vcf --make-bed --out ${spe}_LDpruned_bfile
plink --bfile ${spe}_LDpruned_bfile --allow-extra-chr --pca 5 --out PCA
awk 'BEGIN{a=1}{printf("%s %s ",$1,$1);printf("%s ",a);for(i=3;i<12;i++){printf("%s ",$i)}printf("%s","\n")}' PCA.eigenvec > PCA_SV.txt
# kin
plink --file ${spe} --allow-extra-chr --recode 12 --output-missing-genotype 0 --transpose --out ${spe}
/path_to/emmax-kin-intel64 -v -d 10 ${spe}
# vcf of ped and map format
plink --tfile ${spe} --recode --out ${spe}
plink --make-bed --out ${spe} --vcf $vcf
# calculating significance thresholds for SV
java -Xmx4g -jar /path_to/gec/gec.jar  --effect-number --linkage-file ${spe} --genome --out ${spe} --maf 0.01
## GWAS
PCA=PCA_SV.txt
kinf=${spe}.kinf
for i in Fruit_bitterness ## as an example
do
	/home/yuqing/bin/emmax  -v -d 10 -t $plink_path/MS_population_SV -o total_${i} -p $phynotype_path/${i}.TE.phynotype -k $kinf -c $PCA

done
