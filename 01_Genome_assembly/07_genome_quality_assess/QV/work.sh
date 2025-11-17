#!/bin/bash
### Qality Value using HiFi reads
hifi=/path_to/hifi.fa
ref=genome.fa
meryl count k=19 $hifi threads=6 output read.meryl && /path_to/merqury.sh read.meryl $ref ${i}
