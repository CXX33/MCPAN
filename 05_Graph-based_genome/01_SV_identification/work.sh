#!/bin/bash
#### SV identification using SYRI 
path=/path_to_all_genomes/00_database
ref=/path_to_all_genomes/00_database/13C.fa
PATH_TO_PLOTSR=/path_to/syri-1.4/syri/bin/plotsr
script=/path_to_all_genomes/script
cat all_query_gemomes.txt | while read id
do
	qry=/path_to_all_genomes/00_database/${id}.fa
	quick_qsub =syri_${id}= {-q cu -l nodes=1:ppn=12} "mkdir -p 01_SV_assembly/${id} && cd 01_SV_assembly/${id} && ~/miniconda3/bin/nucmer -t 12  --prefix ${id} $ref $qry && delta-filter -1 -i 95 -l 200 ${id}.delta > ${id}.filter.delta && minimap2 -ax asm5 -t 12 --eqx $ref $qry > ${id}.sam && syri -c ${id}.sam -d ${id}.filter.delta -r $ref -q $qry -k -F S --prefix ${id} && ~/miniconda2/envs/Syri/bin/python3 $PATH_TO_PLOTSR  ${id}syri.out $ref $qry -H 8 -W 5"
	quick_qsub =syri_${id}= {-q cu -l nodes=1:ppn=1} "cd 01_SV_assembly/${id} && show-coords -THrcl ${id}.filter.delta > ${id}.filter.coords && show-snps -Clr -x 1 -T ${id}.filter.delta > ${id}.filter.delta.rsnp && python3 /path_to_all_genomes/software/PythonNGSTools-master/MUMmerSNPs2VCF.py ${id}.filter.delta.rsnp ${id}.filter.delta.rsnp.vcf"
	mv 01_SV_assembly/${id}/syri.pdf 01_SV_assembly/${id}/${id}.syri.pdf
	quick_qsub =syri_${id}= {-q cu -l nodes=1:ppn=1} "$script/extract_mt20bp_pav.py 01_SV_assembly/${id}/${id}syri.vcf 01_SV_assembly/${id}/${id}.ins_del.vcf"
	quick_qsub =syri_${id}= {-q cu -l nodes=1:ppn=1} "$script/exclude_repeat_sv.py 01_SV_assembly/${id}/${id}.ins_del.vcf 01_SV_assembly/${id}/${id}.ins_del.filter.vcf"
	quick_qsub =format_sv= {-q cu -l nodes=1:ppn=1} "$script/format_vcf_ins_del.py -vcf 01_SV_assembly/${id}/${id}.ins_del.filter.vcf -o 01_SV_assembly/${id}/${id}.ins_del.format.vcf -name ${id} -header header"
	quick_qsub =format_vcf= {-q cu -l nodes=1:ppn=1} "cd 01_SV_assembly/${id} && bgzip -c -f ${id}.ins_del.format.vcf >  ${id}.ins_del.format.vcf.gz &&  bcftools index ${id}.ins_del.format.vcf.gz && rm ${id}.ins_del.format.vcf"
	ls 01_SV_assembly/${id}/${id}.ins_del.format.vcf.gz >> vcf.list
	rm 01_SV_assembly/${id}/${id}_syri_TRANS.vcf 01_SV_assembly/${id}/${id}.INV.vcf
########### TRANS
	python3 $script/output_translocation_from_vcf.py 01_SV_assembly/${id}/${id}syri.vcf > 01_SV_assembly/${id}/${id}_TRANS.xls
	cat 01_SV_assembly/${id}/${id}_TRANS.xls | while read n
	do
		chr=`echo $n | awk '{print $2}'`
		pos=`echo $n | awk '{print $3}'`
		ref_pos=`echo $n | awk '{print $2":"$3"-"$4}'`
		alt_pos=`echo $n | awk '{print $6":"$7"-"$8}'`
		ref_seq=`samtools faidx $ref $ref_pos | grep -v '>' | sed ':a;N;s/\n//g;ta'`
		alt_seq=`samtools faidx $qry $alt_pos | grep -v '>' | sed ':a;N;s/\n//g;ta'`
		echo -e "${chr}\t${pos}\t.\t${ref_seq}\t${alt_seq}\t30\tPASS\t.\tGT\t1/1" >> 01_SV_assembly/${id}/${id}_syri_TRANS.vcf
	done
########### INV
	less -S 01_SV_assembly/${id}/${id}invOut.txt | grep '#' > 01_SV_assembly/${id}/${id}.inv.txt
	cat 01_SV_assembly/${id}/${id}.inv.txt | while read n
	do
		chr=`echo $n | awk '{print $2}'`
		pos=`echo $n | awk '{print $3}'`
		ref_pos=`echo $n | awk '{print $2":"$3"-"$4}'`
		alt_pos=`echo $n | awk '{print $6":"$7"-"$8}'`
		ref_seq=`samtools faidx $ref $ref_pos | grep -v '>' | sed ':a;N;s/\n//g;ta'`
		alt_seq=`samtools faidx $qry $alt_pos | grep -v '>' | sed ':a;N;s/\n//g;ta'`
		echo -e "${chr}\t${pos}\t.\t${ref_seq}\t${alt_seq}\t30\tPASS\t.\tGT\t1/1" >> 01_SV_assembly/${id}/${id}.INV.vcf
	done
####################### merge 
	for k in INV TRANS
	do
		echo "#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO" > 01_SV_assembly/${id}/tmp_${k}.vcf
		cat 01_SV_assembly/${id}/${id}.${k}.vcf >>  01_SV_assembly/${id}/tmp_${k}.vcf
		mv 01_SV_assembly/${id}/tmp_${k}.vcf 01_SV_assembly/${id}/${id}.${k}.vcf
		quick_qsub =format_sv= {-q cu -l nodes=1:ppn=1} "$script/format_vcf_trans_inv.py -vcf 01_SV_assembly/${id}/${id}.${k}.vcf -o 01_SV_assembly/${id}/${id}.${k}.format.vcf -name ${id} -header header"
		quick_qsub =vcf_index_${id}_${k}= {-q cu -l nodes=1:ppn=2}"cd 01_SV_assembly/${id} && bgzip -c -f ${id}.${k}.format.vcf >  ${id}.${k}.format.vcf.gz &&  bcftools index ${id}.${k}.format.vcf.gz"
		echo 01_SV_assembly/${id}/${id}.${k}.format.vcf.gz >> ${k}.vcf.list
	done
done
vcf=`awk '{printf "%s ", $0}' vcf.list`
INV_vcf=`awk '{printf "%s ", $0}' INV.vcf.list`
TRANS_vcf=`awk '{printf "%s ", $0}' TRANS.vcf.list`
echo "bcftools merge  -0 --threads 12 $vcf -o ins_del.merge.vcf" > ins_del.merge.sh
echo "bcftools merge  -0 --threads 12 $INV_vcf -o INV.merge.vcf" > INV.merge.sh
echo "bcftools merge  -0 --threads 12 $TRANS_vcf -o TRANS.merge.vcf" > TRANS.merge.sh
quick_qsub =bcftools_merge= {-q cu -l nodes=1:ppn=12} "chmod +x ./ins_del.merge.sh && ./ins_del.merge.sh"
./format_vcf.py ins_del.merge.vcf ins_del.merge.format.vcf
cat ins_del.merge.vcf |awk '{print $1"~"$2}'|sort | uniq -c | awk '$1!=1'|awk '{print $2}'|awk -F '~' '{print $1,$2}' > ins_del.problem.pos.xls
split -a 2 -d -l 50 ins_del.problem.pos.xls ins_del.problem.pos.xls_
for n in {00..13}
do
       for i in ins_del #INV TRANS
       do
               echo -e "cat  ${i}.problem.pos.xls_${n} | while read i;     do         echo \$i > tmp_${i}_${n};         $script/correct_identical_reference_pos_indel.py ${i}.merge.format.vcf tmp_${i}_${n} >> ${i}.problem.pos.correct.vcf;     done" > correct_indel.sh_${i}_${n}
               chmod 755 correct_indel.sh_${i}_${n}
               quick_qsub =sv= {-q cu -l nodes=1:ppn=1} "./correct_indel.sh_${i}_${n}"
       done

done
$script/repos_repeat_pos.py ins_del.merge.format.vcf ins_del.merge.correct.vcf
#correct problem again
$script/correct_ins_del_problem2.py ins_del.problem.pos.correct.vcf ins_del.problem.pos.correct2.vcf
$script/remove_problematic_indel_in_vcf.py ins_del.problem.pos.xls ins_del.merge.format.vcf > tmp
cat ins_del.problem.pos.correct2.vcf tmp | sort -k1,1 -k2,2n > tt && mv tt ins_del.merge.correct3.vcf
less  -S ins_del.merge.format.vcf | head -n 100 | grep '#' > header
cat header ins_del.merge.correct3.vcf >ins_del.merge.correct.vcf
rm ins_del.problem.pos.correct2.vcf ins_del.problem.pos.correct3.vcf

check repeat pos again
cat ins_del.merge.correct.vcf |awk '{print $1"~"$2}'|sort | uniq -c | awk '$1!=1'|awk '{print $2}'|awk -F '~' '{print $1,$2}' > ins_del.correct.problem.pos.xls
## format
$script/format_ins_del_vcf.py ins_del.merge.correct.vcf ins_del.merge.final.vcf
