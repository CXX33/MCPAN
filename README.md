# MCPAN

Melon graph-based pangenome: a chromosome-level, graph-based pangenome
of melon (Cucumis melo) with genome assembly, gene annotation,
pan-genome construction, centromere analysis and population-scale
structural variant (SV) analyses (SV/SNP/TE genotyping, phylogenetics,
GWAS).

---

## 1. Content

The repository is organised into seven analysis modules. Each module
directory contains a `work.sh` that provides the **complete runnable
pipeline with small test datasets** (paths and example inputs included)
so that every step can be reproduced on a standard desktop before
scaling to the full dataset on a cluster.

| Module | Workflow |
|--------|----------|
| `01_Genome_assembly` | Genome survey (K-mer), de novo assembly (hifiasm), Hi-C anchoring (Juicer/3D-DNA), genetic-map anchoring (ALLMAPS), gap filling, polishing (Pilon), BUSCO assessment |
| `02_Genome_annotation` | Repeat masking (EDTA), transcriptome-based gene prediction (StringTie/TransDecoder, Cufflinks, Trinity, PASA), ab initio prediction (SNAP/AUGUSTUS/GeneMark-ET), functional annotation (InterProScan, BLAST) |
| `03_Pan_genome` | Whole-genome SV identification (SYRI), graph-based SV genotyping (vg), flanking-sequence TE-insertion genotyping (ITIP), TE-related SV classification |
| `04_Centromere_analysis` | CmSat354 centromeric satellite composition and variant-site analysis |
| `05_Graph-based_genome` | Pangenome graph construction and SV genotyping (vg) |
| `06_Distinct_genetic_diversity` | Polymorphic-variant counting, phylogenetic trees (4d-SNP/InDel/SV/TE), TE insertion-time estimation (GEVA) |
| `07_Genome-wide_association_studies` | GWAS of traits against SV genotypes (EMMAX) |

> **Test data**: partial/small test datasets and the commands to run them
> are placed in each `Content/<module>/work.sh`. See Section 4 (Demo).

---

## 2. System requirements

- **Operating system**: Linux (tested on Ubuntu 20.04/22.04, x86-64).
- **Non-standard hardware**: None required for the test datasets.
  The full-scale analyses require a compute cluster
  (PBS-like scheduler, `quick_qsub` wrapper) and 20-64 cores per job;
  ~390 Mb melon genome, high RAM (see per-module notes).
- **Interpreters / environments**:
  - Python 3.8+ (most modules) and Python 2 (legacy tools:
    HiC-Pro, HiCPlotter, some custom scripts);
  - Perl 5; Java 8+ (Pilon, GEC);
  - Conda environments: `EDTA`, `Syri` (see work.sh).

### Software dependencies (by module, with versions used)

**01_Genome_assembly**
- kmerfreq / GCE (genome survey)
- hifiasm (>= 0.16.1 for --ont/--ul)
- bwa (0.7.x), samtools (1.17)
- Juicer 1.6 (CPU), 3D-DNA (run-asm-pipeline), Juicebox
- HiC-Pro 2.11.4, HiCPlotter (Python 2)
- jcvi (allmaps), BLAST+ (makeblastdb/blastn/blastall)
- TGS_Gapcloser, LR_Gapcloser
- MUMmer (nucmer/delta-filter/show-coords/show-snps)
- meryl, winnowmap
- Pilon 1.23
- BUSCO 5.5.0 + lineage `embryophyta_odb10`

**02_Genome_annotation**
- EDTA (repeat masking; conda env `EDTA`)
- hisat2, StringTie, Cufflinks, Trinity
- TransDecoder v5.5.0, PASApipeline v2.4.1
- SNAP, AUGUSTUS 3.3.3, GeneMark-ET (gmes_petap.pl/gmhmme3), STAR, seqkit
- BLAST+ (blastp), HMMER (hmmsearch), Pfam-A, UniProt-SwissProt (plants)
- InterProScan 5.48-83.0, OrthoFinder (Orthogroups.txt)

**03_Pan_genome**
- MUMmer, minimap2 (asm5), SYRI 1.4 (incl. plotsr)
- vg (giraffe/pack/call)
- bwa, vcftools, bcftools/bgzip/tabix, plink 1.9
- TEsorter (rexdb-plant), cd-hit, seqkit
- ITIP scripts (03.TE_insertions_genotype.pl, etc.)

**04_Centromere_analysis**
- TRF (tandem repeat finder), TRASH, StainedGlass, Barrnap, BLAST+, samtools

**05_Graph-based_genome**
- vg, bcftools, plink

**06_Distinct_genetic_diversity**
- vcftools 0.1.16, plink 1.9, bcftools
- IQ-TREE 2 (MFP, UFBoot), vcf2phylip.py
- SHAPEIT4, GEVA v1beta

**07_Genome-wide_association_studies**
- plink 1.9, EMMAX (emmax, emmax-kin-intel64), GEC (gec.jar)

**Custom scripts** (project-specific, all documented in the workflow
headers of each `work.sh`): `extract_*.py`, `format*.py`,
`correct_*.py`, `01_random_cent1/2.py`, `02_format_for_find_diff.py`,
`03.TE_insertions_genotype.pl`, `combine_*.py`, `add_GO_infor.py`,
`extract_function.py`, `format_vcf*.py`, `filter_vcf_ad.py`, etc.

> **Recommended**: record exact software versions before publication
> (see the `# Recommended:` line in each workflow header).

---

## 3. Installation

1. Clone this repository.
2. Create the conda environments used by the pipelines
(e.g. `EDTA`, `Syri`) and install the tools listed in Section 2
(most are available via conda/bioconda).
3. Adjust the absolute paths (`/path_to/...`, `/home/...`) inside each
`work.sh` to your local installation.
4. Expected installation time on a normal desktop: **< 30 minutes**
(excluding conda environment creation / download time).

---

## 4. Demo / Reproduction

- Each `Content/<module>/work.sh` runs the module pipeline on a **small
test dataset** (input paths and example sample IDs are embedded in the
script).
- Run, e.g.:
bash Content/01_Genome_assembly/work.sh

- **Expected output**: the intermediate and final files described in the
workflow header of each script (e.g. `*.vcf`, `*.fa`, `*.treefile`,
`*.xls`, summary logs).
- **Expected run time**: on a standard desktop, the test datasets
complete within minutes per step; full-scale genome/pangenome
analyses require a cluster (see Section 2).

---

## 5. Usage

To apply a pipeline to your own data:

1. Prepare your input files in the format described in the workflow
 header of the corresponding `work.sh` (input files / output files
 sections).
2. Edit the file paths, sample IDs and parameters
 (threads, memory, MAF/coverage thresholds, outgroup, etc.) at the
 top of the script.
3. Execute step by step (recommended) to check intermediate outputs
 before running the full chain.

Reproduction of the manuscript results is achieved by running the
workflows in order (`01` -> `07`) with the parameter sets fixed in the
Methods; the exact version of every tool should be recorded before
publication.

---

## 6. Reference

Graph-based pangenome construction and SV genotyping sections were
based on https://github.com/HongboDoll/TomatoSuperPanGenome;

TE genotyping section was based on https://github.com/caixu0518/ITIPs;

Heritability calculation section was based on
https://github.com/YaoZhou89/TGG.

Demographic history and estimation of variant age section was based on https://github.com/xuebozhao16/CucurbitGenomics.

## 7. Citation

[to be filled after publication]

## 8. License

MIT License (free for academic and commercial use)

## 9. Contacts

Xinxiu Chen (cxxlddx@163.com)

