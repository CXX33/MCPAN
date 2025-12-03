#!/usr/bin/env python3
#program name: extract_function.py
###program information###
#	version: 1.0		author: lintao <lintao19870305@gmail.com>	date: 2016-09-22
"""
		module description
				verion: 1.0	author: lintao <lintao19870305@gmail.com>   date: 2016-09-22
"""

#include the required module
import sys
import os
import re
import argparse

#command-line interface setting
parser = argparse.ArgumentParser(description = 'Statistics information to New file')
parser.add_argument('-i1', type = argparse.FileType('r'), help = 'Database function ID file')
parser.add_argument('-i2', type = argparse.FileType('r'), help = 'Blast results file')
parser.add_argument('-o', type = argparse.FileType('w'), help = 'Output of results')

args = parser.parse_args()


#global variable
debug = True


#function definition
def Function(input1, input2, output):

	first_list = []
	ID_set = set()
	dict_ID = {}

	for eachline in input1:		# function ID file
		eachline = eachline.strip()
		if not eachline or eachline[0] == '#':
			continue
		if eachline[0] == '>':
			first_list = eachline.split()
			dict_ID[first_list[0][1:]] = eachline[1:]

	for eachline in input2:		# blast results file
		eachline = eachline.strip()
		if not eachline or eachline[0] == '#':
			continue
		first_list = eachline.split()
		if first_list[0] not in ID_set:
			ID_set.add(first_list[0])
			output.write('{0}\t{1}\n'.format(first_list[0], dict_ID[first_list[1]]))
			

if __name__ == "__main__":
	Function(args.i1, args.i2, args.o)
	args.i1.close()
	args.i2.close()
	args.o.close()
