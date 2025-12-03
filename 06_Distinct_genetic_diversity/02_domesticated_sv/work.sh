#!/bin/bash
#### Calculate SV insertion frequencies within the group
vcf=MC_MS.SV.filter.vcf
less -S $vcf | head -n 100 | grep '#CHROM' | sed 's/\t/\n/g' > accession.list
./00add_group.py  MS_MC_group.txt accession.list  accession_group.xls
less -S accession_group.xls | nl > accession_group.add_nl.xls
./01group_index.py accession_group.add_nl.xls accession_group.index.xls
./02calculate_frequency.py  MC_MS.SV.update.vcf MC_MS_total_SV.frequency.xls
less -S MC_MS_total_SV.frequency.xls | awk '$12>=0.5 || $12<=-0.5 || $8 >= 0.50 || $8 <= -0.50 || $9 >= 0.50 || $9 <= -0.5' > MC_MS_total_SV.frequency_diff.xls
less -S MC_MS_total_SV.frequency_diff.xls | awk '$8>= 0.50 || $8 <= -0.50' | awk '{print $1"\t"$2"\t"$4"\t"$5"\t"$8}' > WA_CA.domesticated_sv_frequency.xls
less -S MC_MS_total_SV.frequency_diff.xls | awk '$9>= 0.50 || $9 <= -0.50' | awk '{print $1"\t"$2"\t"$6"\t"$7"\t"$9}' > WM_CM.domesticated_sv_frequency.xls
