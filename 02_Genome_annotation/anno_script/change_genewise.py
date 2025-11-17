import sys
import re

input=open(sys.argv[1])

for eachline in input:
	line=eachline.split()
	if line[6]=="+":
		print(eachline.strip())
	if line[6]=="-":
		w=line[0]+'\t'+line[1]+'\t'+line[2]+'\t'+line[4]+'\t'+line[3]+'\t'+line[5]+'\t'+line[6]+'\t'+line[7]+'\t'+line[8]	
		print(w)
