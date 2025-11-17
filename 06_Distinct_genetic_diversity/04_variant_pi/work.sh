#!/bin/bash
#### Calculating nucletide diversity of polymorphic variants using 100kb windows in subpopulations
for i in agrestis melo
do
        quick_qsub =pixy= {-q cu -l nodes=1:ppn=1} "vcftools --vcf ../03_variant_number/${i}.filter_maf.sv.recode.vcf --window-pi 100000 --window-pi-step 10000  --maf 0.01 --out ${i}_sv_100k"
       quick_qsub =pixy= {-q cu -l nodes=1:ppn=1} "vcftools --vcf ../03_variant_number/${i}.TE.filter_maf.recode.vcf --window-pi 100000 --window-pi-step 10000  --maf 0.01 --out ${i}_te_100k"
       quick_qsub =pixy= {-q cu -l nodes=1:ppn=1} "vcftools --vcf ../03_variant_number/${i}.filter_maf.snp.recode.vcf --window-pi 100000 --window-pi-step 10000  --maf 0.05 --out ${i}_snp_100k"
       quick_qsub =pixy= {-q cu -l nodes=1:ppn=1} "vcftools --vcf ../03_variant_number/${i}.filter_maf.indel.recode.vcf --window-pi 100000 --window-pi-step 10000  --maf 0.05 --out ${i}_indel_100k"
done
