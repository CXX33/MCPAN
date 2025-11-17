#!/bin/bash
### Validate centromeric and telomeric regions of TRF results
for j in {01..12}
do
	/path_to/software/TRASH/TRASH_run.sh /path_to/22_Cent_analysis/database/chr${j}.fa --horclass CmCent --seqt /path_to/CmCent_CmTelo_templates.csv --par 3 --o /path_to/22_Cent_analysis/chr${j}
	less -S /path_to/22_Cent_analysis/chr${j}/Summary.of.repetitive.regions.chr${j}.fa.csv |  grep "CmCent" | awk -F ',' '$5>80 {print $2,$3,$4,$5,$6}' OFS="\t" > chr${j}.Cent.region
done
