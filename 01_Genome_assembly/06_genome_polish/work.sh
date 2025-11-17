#!/bin/bash
### Final ONT-only assemblies were polished using Illumina reads
ref=genome.fa
bwa index ${ref}
bwa mem -t 36 ${ref} /path_to/Illumina_R1.fq.gz /path_to/Illumina_R2.fq.gz | samtools sort -@ 36 -O bam -o $name
samtools index ${name}.sort.bam
samtools markdup -@ 30 ${name}.sort.bam ${name}.final.bam
samtools index ${name}.final.bam
rm ${name}.sort.bam 
MEMORY=430 ## set by genome size
java -Xmx${MEMORY}G -jar /path_to/pilon-1.23.jar --genome $ref --frags ${name}.final.bam
    --mindepth 20 \
    --fix bases \
    --output ${name}.polish.fasta  &> pilon1.log
