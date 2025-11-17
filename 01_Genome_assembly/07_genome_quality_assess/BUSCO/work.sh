#!/bin/bash
### Assess the completeness of the genome and protein using the embryophyta_odb10 database
export AUGUSTUS_CONFIG_PATH=/path_to/augustus-3.3.3/config
BUSCO_database=/path_to/embryophyta_odb10
# genome
busco -i genome.fa  -l $BUSCO_database -o ${i}_genome --config /path_to/busco-5.5.0/config/config.ini --mode genome -c 20  --offline -f
#protein
busco -i protein.fa  -l $BUSCO_database -o ${i}_protein --config /path_to/busco-5.5.0/config/config.ini --mode protein -c 20  --offline -f
