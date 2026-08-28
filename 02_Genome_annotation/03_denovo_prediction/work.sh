#!/bin/bash
# ==============================================================================
# Ab initio gene prediction (SNAP / AUGUSTUS / GeneMark-ET)
# ==============================================================================
# Author: Xinxiu Chen
#
# Purpose
# -------
# Perform ab initio gene prediction with three tools, each trained on
# the PASA transcriptome-derived training set (best_candidates.gff3),
# to provide independent de novo gene models for integration in
# EVidenceModeler (EVM).
#
# Main analyses
# -------------
#  1. SNAP: training-set preparation (PASA -> zff), HMM training
#     (fathom/forge/hmm-assembler), and prediction
#  2. AUGUSTUS: genbank-format training set (best_candidates.gff3),
#     iterative training with bad-gene filtering, and prediction
#  3. GeneMark-ET: splice-site training from RNA-seq (STAR SJ),
#     self-training (gmes_petap.pl), and prediction (gmhmme3)
#
# Software and versions
# ---------------------
#   SNAP                (fathom, forge, hmm-assembler.pl, snap)
#   AUGUSTUS 3.3.3      (etraining, augustus, new_species.pl, ...)
#   GeneMark-ET         (gmes_petap.pl, gmhmme3)
#   STAR                (RNA-seq alignment / splice-junction evidence)
#   seqkit              (genome split for parallel AUGUSTUS)
#   EVidenceModeler     (format converters: SNAP_to_GFF3.pl,
#                        convert_genemarkGff3_2_EVMGff3.py)
#   custom python scripts (eachgff2zff.py, changezff2oneline.py,
#                        change_pos_snap.py, filter_ann.py)
#   NOTE: record exact software versions before publication.
#
# Input files
# -----------
#   genome.fa            reference genome (FASTA)
#   genome.mask.fa       repeat-masked genome (prediction input)
#   best_candidates.gff3 PASA-integrated transcriptome (training set)
#   melon_117_tissues_R1/R2.fq.gz  RNA-seq reads (GeneMark-ET, STAR)
#
# Output files
# ------------
#   SNAP:        my-genome.hmm, snap.zff, snap.gff3
#   AUGUSTUS:    Melon_${i} species parameters, augustus.out, augustus_format.out
#   GeneMark-ET: gmhmm.mod, genemark.out, genemark.gff3
#
# Notes
# -----
# - Replace /path_to/... with actual paths; $i is the sample ID.
# - All three tools share the same PASA training set - keep it identical
#   across tools for fair integration in EVM.
# - SNAP: "pos" (locus list) is derived from the zff; the training set is
#   filtered on the "OK" lines from fathom -validate.
# - AUGUSTUS: bad genes are removed (filterGenes.pl) before final
#   training; prediction is split with seqkit for parallelisation.
# - GeneMark-ET: STAR index bases should be tuned with
#   --genomeSAindexNbases (here 13 for ~390 Mb); gmes_petap.pl performs
#   iterative self-training using splice sites (SJ.gff).
# Recommended: record exact software versions before publication.
# ==============================================================================

ref=genome.fa
ref_masked=genome.mask.fa
thread=12
### SNAP
snap_path=/path_to/anno_script
mkdir -p denovo/${i}/SNAP
cd denovo/${i}/SNAP
# SET Train
ln -s /path_to/PASA/best_candidates.gff3 
grep -v "^$" best_candidates.gff3 > best_candidates_format.gff3
python $snap_path/eachgff2zff.py best_candidates_format.gff3 > best_candidates_format.zff
awk '{if($1~/^>..../)print}' best_candidates_format.zff | sort | uniq > pos 
python $snap_path/changezff2oneline.py pos best_candidates_format.zff genome.ann
python $snap_path/change_pos_snap.py $ref pos genome.dna
fathom genome.ann genome.dna -gene-stats > erro
fathom genome.ann genome.dna -validate > validate.log
grep OK validate.log > genome.zff2keep
python $snap_path/filter_ann.py genome.zff2keep genome.ann > tmp
mv tmp genome.ann
fathom genome.ann genome.dna -categorize 1000
fathom uni.ann uni.dna -export 1000 -plus
mkdir params
cd params
forge ../export.ann ../export.dna
cd ..
hmm-assembler.pl my-genome ./params > my-genome.hmm
# Prediction
snap my-genome.hmm $ref_masked  -quiet > snap.zff
/path_to/SNAP-master/zff2gff3.pl snap.zff > snap.gff
/path_to/EVidenceModeler-1.1.1/EvmUtils/misc/SNAP_to_GFF3.pl snap.gff > snap.gff3
### Augustus
export AUGUSTUS_CONFIG_PATH=/path_to/augustus-3.3.3/config
mkdir -p denovo/${i}/Augustus
cd denovo/${i}/Augustus
gff2gbSmallDNA.pl /path_to/PASA/best_candidates.gff3 $ref 1000 genes.raw.gb 
/path_to/augustus-3.3.3/scripts/new_species.pl --species=melon_for_bad_removingall${i}
etraining --species=melon_for_bad_removingall${i} --/genbank/verbosity=2 genes.raw.gb  2> train.err
cat train.err |awk '{print $7}'|sed 's/://g'|grep -v '^$' > badgenes.lst
/path_to/augustus-3.3.3/scripts/filterGenes.pl badgenes.lst genes.raw.gb > train.gb
grep -c "LOCUS" genes.raw.gb train.gb
/path_to/augustus-3.3.3/scripts/randomSplit.pl train.gb 100
/path_to/augustus-3.3.3/scripts/new_species.pl --species=Melon_${i}
etraining --species=Melon_${i} train.gb.train > train.out
augustus --species=Melon_${i} train.gb.test |tee firsttest.out
etraining --species=Melon_${i} train.gb.train
augustus --species=Melon_${i} train.gb.test |tee second.out
seqkit split -p 20 $ref_masked
augustus  --AUGUSTUS_CONFIG_PATH=/path_to/augustus-3.3.3/config --species=Melon_${i}  $ref_masked > augustus.out
grep -v "#" augustus.out > augustus_format.out
### GeneMark-ET
mkdir -p denovo/${i}/GeneMark-ET
cd denovo/${i}/GeneMark-ET
# set train
STAR --runThreadN 20 --runMode genomeGenerate --genomeDir ${i}_star_index --genomeFastaFiles $ref
STAR --runThreadN 12 --runMode alignReads --genomeDir ${i}_star_index --readFilesIn /path_to/melon_117_tissues_R1.fq.gz /path_to/melon_117_tissues_R2.fq.gz  --limitBAMsortRAM 190518930416  --readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outWigType wiggle read2 --genomeSAindexNbases 13
star_to_gff.pl --star SJ.out.tab --gff SJ.gff --label STAR
~/software/gmes_linux_64/gmes_petap.pl  --soft_mask 1 --sequence $ref --ET SJ.gff --cores 20
cp output/gmhmm.mod .
gmhmme3 -m gmhmm.mod -o genemark.out -f gff3 ${ref}
fasta=`grep 'defline' genemark.out | awk '{print $4}' | awk -F '>' '{print $2}'`
sed "s/seq/${fasta}/g" genemark.out | sed 's/GeneMark.hmm3/GenemarkHMM/g' | grep -v '#' | grep -v 'Intron' > genemark.gff
/path_to/GeneMark-ET/convert_genemarkGff3_2_EVMGff3.py genemark.gff > genemark.gff3
