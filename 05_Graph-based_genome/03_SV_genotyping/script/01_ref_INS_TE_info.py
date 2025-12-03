#!/usr/bin/env python3
import os
import sys
import argparse
parser=argparse.ArgumentParser(description='Extract INS information from sv vcf')
parser.add_argument('-TE_index', type =argparse.FileType('r'),help='the TE index file')
parser.add_argument('-vcf', type =argparse.FileType('r'),help='the vcf file')
parser.add_argument('-o', type =argparse.FileType('w'),help='the output vcf file name')
parser.add_argument('-name', type =str,help='Query name')

args=parser.parse_args()
debug=True
d1={} ## TE index
for line1 in args.TE_index:
	list1=line1.strip().split()
	d1[list1[-1]]=line1
for line2 in args.vcf:
	if "#" in line2:continue
	list2=line2.strip().split()
	name="TE_"+list2[0]+"_"+list2[1]
	chr_qry=list2[-1].split(";")[1].split("=")[1]
	sta_qry=list2[-1].split(";")[2].split("=")[1]
	end_qry=list2[-1].split(";")[3].split("=")[1]
	if "INS" in list2[2]:
		if name in d1:
			args.o.write("{0}\t{1}\t{2}\t{3}\t{4}\n".format(chr_qry,sta_qry,end_qry,name,args.name))
args.o.close()
