#!/bin/bash
#### Estimating heritability of agronomic traits

## Taking the SNP in agrestis of the MS population as an example.
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/ldak_env
# prune the genotype dataset
ldak6 --bfile $path/MS_agrestis_SNP --cut-weights snps --window-prune 0.98 --window-kb 100
# weighting
ldak6 --bfile $path/MS_agrestis_SNP  --calc-weights-all snps 
# calculate kinship
ldak6  --calc-kins-direct LDAK-Thin --bfile  $path/MS_agrestis_SNP  --weights snps/weights.short --power -.5
# estimate heritability
cat phynotype | while read i
do
	ldak6 --pheno /path_to/agrestis_MS/${i}/${i}.phynotype   --grm /path_to/agrestis_MS_snp/LDAK-Thin  --covar /path_to/01_plink/agrestis_MS/PCA.eigenvec --reml ${i} --constrain YES
done
conda deactivate 
