#!/bin/bash
#### Population-scale phylogenetic tree construction using 4d-snp,indel,sv,te
# 4d-snp
ref=13C.fa
gff=13C.gff3
perl Get_4_fold_sites.pl $ref $gff 13C_T2T_4_fold_sites.xls
extract_4d_vcf.py 13C_T2T_4_fold_sites.xls ../population.SNP.vcf MS_MC_res.4d_snp.vcf
vcftools --vcf MS_MC_res.4d_snp.vcf --maf 0.05 --max-missing 1 --remove-indels --min-alleles 2 --max-alleles 2 --recode --out MS_MC_res.4d.filter
python3 vcf2phylip.py -i  MS_MC_res.4d_snp.vcf -o MS_MC_res.4d_snp
iqtree2 -s MS_MC_res.4d_snp.min4.phy -m MFP -B 1000  -bnni  --prefix MS_MC -o P14 --mem 10GB -T 30
# indel sv te
for i in InDel SV TE
do
	format.py ../population.${i}.vcf ${i}.format.vcf
	python3 vcf2phylip.py -i ${i}.format.vcf -o ${i}
	iqtree2 -s ${i}.format.min4.phy -m MFP -B 1000  -bnni -o P14 --prefix ${i} --mem 10GB -T AUTO -redo
done

