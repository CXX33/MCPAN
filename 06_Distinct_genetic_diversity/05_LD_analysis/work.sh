#!/bin/bash
#### Assessing linkage disequilibrium (LD) in subpopulations
vcf=SNP_InDel_SV.forLD.final.vcf

for i in agrestis melo
do
	plink --vcf SNP_InDel_SV.forLD.final.vcf \
	--keep ${i}.keep
	--double-id \
	--allow-extra-chr --maf 0.05 \
	--geno 0.2 \
	--mind 0.5 \
	--thin 0.4 \
	--r2 gz \
	--ld-window 100 \
	--ld-window-kb 1000 \
	--ld-window-r2 0 \
	--make-bed \
	--out SNP_InDel_SV.ld.${i}
done
Rscript format.R
Rscript plot.R
