##!/bin/bash
#### Intergrated all annotation using EVidenceModeler (EVM)
ref=genome.fa
ref_masked=genome_masked.fa
evm_script=/path_to/anno_script/EVM
#Augustus
ln -s /path_to/denovo/${i}/Augustus/augustus_format.out
python $evm_script/Augustus_change_format_for_evm.py augustus_format.out augustus_evm.gff

#SNAP
ln -s /path_to/denovo/${i}/SNAP/snap.gff
python $evm_script/Snap_change_format_to_evm.py snap.gff snap_evm.gff3
#GeneMark
ln -s /path_to/denovo/${i}/GeneMark-ET/genemark_out/${i}.genemark.gff3
#other
grep -v "^$" /path_to/transcript/${i}/stringtie_out/transcripts.fasta.transdecoder.genome.gff3|sed 's/transdecoder/OTHER_PREDICTION/g' > transcripts_stringtie.gff3
#merge
cat augustus_evm.gff snap_evm.gff3  ${i}.genemark.gff3  transcripts_stringtie.gff3 > evm_denovo.gff3
cat augustus_evm.gff snap_evm.gff3  transcripts_stringtie.gff3 > evm_denovo.gff3
#maker
ln -s /path_to/homologous/${i}/${i}.exonerate.gff3
#stringtie
ln -s /path_to/transcript/${i}/stringtie_out/${i}_all_RNA_stringtie_out
python $evm_script/stringtie_change_format_to_evm.py ${i}_all_RNA_stringtie_out > stringtie_evm.gff
cat  stringtie_evm.gff /path_to/transcript/${i}/PASA/test_Cme_${i}_V1.pasa_assemblies.gff3  > evm_rnaseq.gff3
# EVM
EVM_HOME=/path_to/EVidenceModeler-v2.1.0
$EVM_HOME/EVidenceModeler \
        --sample_id ${i} \
        --genome ${ref} \
        --weights $work_path/EVM/${i}_weights.txt \
        --gene_predictions evm_denovo.gff3 \
        --protein_alignments ${i}.exonerate.gff3 \
        --transcript_alignments evm_rnaseq.gff3 \
        --segmentSize 100000 \
        --CPU 20 \
        --overlapSize 10000

