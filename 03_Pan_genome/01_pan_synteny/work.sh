#!/bin/bash
path=/path_to/genome_database
cat  pan_accession_for_plot.txt | while read i
do
	R1=`echo $i | awk '{print $1}'`
	R2=`echo $i | awk '{print $2}'`
	name=${R1}_${R2}
	mkdir $name
	cd $name
	quick_qsub =minimap= {-q cu -l nodes=1:ppn=12} "minimap2 -ax asm5 -t 12 --eqx $path/${R1}.fa $path/${R2}.fa | samtools sort -O BAM - > ${name}.bam && samtools index ${name}.bam && syri -c ${name}.bam -F B  --nosnp  -r $path/${R1}.fa -q $path/${R2}.fa  --prefix ${name}" 
	cd -
	sr=`echo ${name}/${name}syri.out`
	#echo $sr
	all_genome=`echo $path/${R1}.fa $R1 "lw:1.5;lc:blue"`
	echo $all_genome
done
./plotsr.sh
