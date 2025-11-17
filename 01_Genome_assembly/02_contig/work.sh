#!/bin/bash
##### De novo Assembly Using HiFi,ONT-ultralong, or HiFi-ONT Reads
HiFi=/path_to/hifi
ONT=/path_to/ont
### ont only
hifiasm -o ont_only -t 32 --ont $ont/ont.fq.gz -r 5 -n 15 -l 2 --dual-scaf --primary
### hifi only
hifiasm -o hifi_only -t 32  -r 10 -n 15 -l 2 --dual-scaf --primary  $hifi/hifi.fq.gz
### hifi-ont 
hifiasm -o hifi_ont_all -t 14 --ul $ont/ont.fq.gz $hifi/hifi.fq.gz  -r 4 --primary --hg-size 390m
