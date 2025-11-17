#!/bin/bash
###Genome Survey Using HiFi Reads
path=/path_to/HiFi
ls $path/hifi.fa > read.list
/path_to/kmerfreq -k 17 -t 12 -p 17 -f 2 read.list
less  17.kmer.freq.stat | perl -ne 'next if(/^#/ || /^\s/); print; ' | awk '{print $1"\t"$2}' > 17kmer.freq.stat.2colum
num1=$(grep '#Kmer indivdual number' 17.kmer.freq.stat | awk -F: '{print $2}')
gce -g  "$num1" -f  17kmer.freq.stat.2colum  >17.gce.stat1  2>17.gce.log1
num2=$(cat  17.gce.log1 | tail -n 3 | head -n 1 | awk '{print $1}')
gce -g "$num1" -f 17kmer.freq.stat.2colum -c "$num2" -H 1 >17.gce.stat2 2>17.gce.log2
#### genome_size: estimated genome size (genome_size = effective_kmer_individuals / coverage_depth)
#### kmer-species heterozygous ratio: a[1/2]/(2-a[1/2])
#### Repeat content: 1-b[1/2]-b[1]
