#!/bin/bash
#### Gene prediction using transcriptome evidence
ref=genome.fa
ref_masked=genome_masked.fa
thread=12
export AUGUSTUS_CONFIG_PATH=/path_to/augustus-3.3.3/config
# hisat2_stringtie
mkdir -p transcript/$i/hisat2_stringtie
hisat2-build -p $thread $ref $ref
cat /path_to/RNA_seq.name | while read j
do
	let num=$num+$a
	R1=`echo $j | awk '{print $1}'`
	R2=`echo $j | awk '{print $2}'`
	name=`echo "$num"|bc`
	hisat2 -x  $ref --dta -p $thread -1 $R1 -2 $R2 | samtools view -bS -@ $thread - > ${i}_${name}.bam
done
mkdir tmp_bam && mv *.bam tmp_bam/ && samtools merge -@ $thread ${i}_all_RNA.bam ./tmp_bam/*.bam ## merge all bam
/bin/rm -rf tmp_bam/ 
/path_to/TransDecoder-TransDecoder-v5.5.0/util/gtf_genome_to_cdna_fasta.pl ${i}_all_RNA_stringtie_out $ref_masked > transcripts.fasta && /path_to/TransDecoder-TransDecoder-v5.5.0/util/gtf_to_alignment_gff3.pl  ${i}_all_RNA_stringtie_out > transcripts.gff3 && /path_to/TransDecoder-TransDecoder-v5.5.0/TransDecoder.LongOrfs -t transcripts.fasta -m 100
blastp -query transcripts.fasta.transdecoder_dir/longest_orfs.pep -db /path_to/uniprot_sprot_plants.fasta -max_target_seqs 1 -outfmt 6 -evalue 1e-5 -num_threads 12 > blastp.outfmt6
hmmsearch --cpu 12 -o ttt --domtblout hmmsearch.tmp /path_to/Pfam/Pfam-A.hmm transcripts.fasta.transdecoder_dir/longest_orfs.pep
awk 'BEGIN{OFS=FS=" "} NR<=3{print}; NR>3{tmp=$1; $1=$4; $4=tmp; tmp=$2; $2=$5; $5=tmp; print}' hmmsearch.tmp > pfam.domtblout
/path_to/TransDecoder-TransDecoder-v5.5.0/TransDecoder.Predict -t transcripts.fasta --single_best_only --retain_pfam_hits pfam.domtblout --retain_blastp_hits blastp.outfmt6 && /path_to/TransDecoder-TransDecoder-v5.5.0/util/cdna_alignment_orf_to_genome_orf.pl transcripts.fasta.transdecoder.gff3 transcripts.gff3 transcripts.fasta  > transcripts.fasta.transdecoder.genome.gff3
# cufflink
mkdir transcript/$i/cufflink
cufflinks -p $thread --library-type fr-firststrand -b $ref -u -o cufflink -L GFF /path_to/hisat2_stringtie/${i}_all_RNA.sort.bam 1>>run_cufflinks.log 2>>run_cufflinks.err
Trinity --genome_guided_bam /path_to/transcript/$i/hisat2_stringtie/${i}_all_RNA.sort.bam  --max_memory 50G --genome_guided_max_intron 10000 --output transcript/$i/trinity_ref --CPU $thread 1> run_trinity_ref.log 2> run_trinity_ref.err
# trinity
mkdir transcript/$i/trinity_no_ref transcript/$i/trinity_ref
cat /path_to/RNA_R1.txt | while read j
do
	cat /path_to/RNA_R2.txt | while read k
	do
		Trinity --seqType fq  --max_memory 200G --left $j --right $k --output transcript/$i/trinity_no_ref --min_kmer_cov 2 --trimmomatic --normalize_reads --no_bowtie --CPU $thread 1> run_trinity_no_ref.log 2> run_trinity_no_ref.err
	done
done
# PASA
cat transcript/$i/trinity_ref/Trinity-GG.fasta transcript/$i/trinity_no_ref/trinity_no_ref.Trinity.fasta > transcript/$i/PASA/transcripts.fasta
/path_to/PASApipeline-pasa-v2.4.1/misc_utilities/accession_extractor.pl < transcripts.fasta > tdn.accs
/path_to/PASApipeline-pasa-v2.4.1/bin/seqclean  transcripts.fasta -v /path_to/viral_bacteria_plastid/UniVec
/path_to/PASApipeline.v2.4.1/Launch_PASA_pipeline.pl -c /path_to/PASApipeline.v2.4.1/pasa_conf/configs/${i}_alignAssembly.config --trans_gtf /path_to/transcript/${i}/cufflink/transcripts.gtf --TDN tdn.accs -C  -R -g $ref -t  transcripts.fasta.clean -T -u  transcripts.fasta --ALIGNERS blat --CPU $thread
/path_to/PASApipeline.v2.4.1/scripts/pasa_asmbls_to_training_set.dbi --pasa_transcripts_fasta test_Cme_${i}_V1.assemblies.fasta --pasa_transcripts_gff3 test_Cme_${i}_V1.pasa_assemblies.gff3 && /usr/bin/perl /path_to//PASApipeline.v2.4.1/scripts/pasa_asmbls_to_training_set.extract_reference_orfs.pl test_Cme_${i}_V1.assemblies.fasta.transdecoder.genome.gff3 > best_candidates.gff3
