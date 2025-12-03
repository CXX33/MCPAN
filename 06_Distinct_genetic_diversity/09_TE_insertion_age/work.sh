#!/bin/bash
#### Estimating the insertion time based on SNPs in the 10-kb flanking region of TEs.
## Extracting SNPs in the 10-kb flanking region of TEs.
./00_extract_TE_flank_region.py complete_SV_TE.txt complete_TE_10k.bed
agrestis_vcf=agrestis.filter_maf.snp.recode.vcf
melo_vcf=melo.filter_maf.snp.recode.vcf
quick_qsub =vcftools1= {-q cu_new -l nodes=1:ppn=2} "vcftools --vcf $agrestis_vcf --bed complete_TE_10k.bed --recode --out agrestis_TE_flank10k"
quick_qsub =vcftools2= {-q cu_new -l nodes=1:ppn=2} "vcftools --vcf $melo_vcf --bed complete_TE_10k.bed --recode --out melo_TE_flank10k"
quick_qsub =plink1= {-q cu_new -l nodes=1:ppn=2} "plink --allow-extra-chr --biallelic-only --out agrestis_TE_flank10k.final.vcf --recode vcf-iid --vcf agrestis_TE_flank10k.recode.vcf"
quick_qsub =plink2= {-q cu_new -l nodes=1:ppn=2} "plink --allow-extra-chr --biallelic-only --out melo_TE_flank10k.final.vcf --recode vcf-iid --vcf melo_TE_flank10k.recode.vcf"
## add annotation
bcftools query -f '%CHROM\t%POS\t%POS\t%CHROM\_%POS\n' agrestis_TE_flank10k.final.vcf > agrestis.annotation.txt
bcftools query -f '%CHROM\t%POS\t%POS\t%CHROM\_%POS\n' melo_TE_flank10k.final.vcf > melo.annotation.txt 
#Index the annotation
bgzip agrestis.annotation.txt
bgzip melo.annotation.txt 
tabix -s1 -b2 -e2 agrestis.annotation.txt.gz
tabix -s1 -b2 -e2 melo.annotation.txt.gz
# Add annotation
mkdir shapeit4
for w in agrestis melo
do
	bcftools annotate -a ${w}.annotation.txt.gz -c CHROM,FROM,TO,ID ${w}_TE_flank10k.final.vcf > ${w}.SNPannotated.forGEVA.vcf
	bgzip ${w}.SNPannotated.forGEVA.vcf
	tabix ${w}.SNPannotated.forGEVA.vcf.gz
	for chrom in {1..12}
	do
		quick_qsub =shapeit4= {-q cu -l nodes=1:ppn=1} "shapeit4 --input ${w}.SNPannotated.forGEVA.vcf.gz --region ${chrom} -T 1 -O shapeit4/${w}.${chrom}.phased.vcf"
	done
done
## GEVA estimates the timing of mutation occurrence.
##Conversion
mkdir geva_Conversion geva_Execution
for w in agrestis melo
do
	for chrom in {1..12}
	do
## Conversion
		quick_qsub =geva1= {-q fat_3T_new -l nodes=1:ppn=1} "/home/chenxinxiu/software/geva-master/geva_v1beta --vcf shapeit4/${w}.${chrom}.phased.vcf --rec 1e-8 --out geva_Conversion/${w}.${chrom}"
		less -S geva_Conversion/${w}.${chrom}.marker.txt | sed '1d' | awk '{print $3}' > geva_Execution/${w}.${chrom}.pos
## Execution
		quick_qsub =geva= {-q fat_3T_new -l nodes=1:ppn=1} "/home/chenxinxiu/software/geva-master/geva_v1beta -i geva_Conversion/${w}.${chrom}.bin -o geva_Execution/${w}.${chrom} --positions  geva_Execution/${w}.${chrom}.pos  --Ne 300000 --mut 7e-9 --hmm /home/chenxinxiu/software/geva-master/hmm/hmm_initial_probs.txt /home/chenxinxiu/software/geva-master/hmm/hmm_emission_probs.txt"
		cat geva_Execution/${w}.${chrom}.sites.txt >> ${w}.sites.txt
		./01_extract_age.py  geva_Execution/${w}.${chrom}.sites.txt geva_Execution/${w}.${chrom}.sites.final.txt
		cat geva_Execution/${w}.${chrom}.sites.final.txt >> ${w}.sites.final.xls
	done

done

