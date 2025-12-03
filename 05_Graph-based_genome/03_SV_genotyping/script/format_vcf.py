#!/usr/bin/env python3
import os
import sys
import argparse
parser=argparse.ArgumentParser(description='Add accession name and TE information to TE vcf')
parser.add_argument('-vcf', type =argparse.FileType('r'),help='the TE vcf file')
parser.add_argument('-TE_geno', type =argparse.FileType('r'),help='the TE genotype file')
parser.add_argument('-o', type =argparse.FileType('w'),help='the output vcf file name')
parser.add_argument('-header', type =argparse.FileType('r'),help='the vcf file header')
parser.add_argument('-name', type =str,help='accessions name')

args=parser.parse_args()
debug=True
d1={}
for l in args.header:
	args.o.write(l)
for line1 in args.vcf:
	list1=line1.strip().split()
	if len(list1)<=1 or "##" in list1[0] or "##" in list1[0]:
		continue
	else:
		if "#" in list1[0]:
			list1.append("FORMAT")
			list1.append(args.name)
			args.o.write("{0}\n".format("\t".join(list1)))
		else:
			list1.append("GT")
			d1[list1[0]+"_"+list1[1]]=list1
for line2 in args.TE_geno:
	if "TEindex" in line2:
		continue
	else:
		list2=line2.strip().split()
		if list2[0] in d1:
			if len(d1[list2[0]][3])>=2:
				if list2[-1]=="CC":
					d1[list2[0]].append("1/1")
				elif list2[-1]=="GG":
					d1[list2[0]].append("0/0")
				elif list2[-1]=="CG":
					d1[list2[0]].append("./.")
				elif list2[-1]=="NA":
					d1[list2[0]].append("./.")
			if len(d1[list2[0]][3])==1:
				if list2[-1]=="CC":
					d1[list2[0]].append("0/0")
				elif list2[-1]=="GG":
					d1[list2[0]].append("1/1")
				elif list2[-1]=="CG":
					d1[list2[0]].append("./.")
				elif list2[-1]=="NA":
					d1[list2[0]].append("./.")
			d1[list2[0]][2]=list2[0]
			d1[list2[0]][5]="30"
			d1[list2[0]][7]="PR"
			args.o.write("{0}\n".format("\t".join(d1[list2[0]])))
args.o.close()
