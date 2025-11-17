# encoding : utf-8
#gff to zff to snap

import sys

input=open(sys.argv[1])#gff file

dict={}
list=[]
dict2={}
for eachline in input:
	line=eachline.split()
	if line!=[] and line[0][0]!='#' and line[0][0]!='S' and line[2]=='exon':
#		t=line[8].split(";")
#		key=t[0][3:]
		key=line[9]
#		print(key)
		name=line[0]
		dict2[name]="jugde"
		if key in dict:
			if line[6]=="+":
				w=line[3]+'\t'+line[4]
				dict[key].append(w)
			if line[6]=="-":
				w=line[4]+'\t'+line[3]
				dict[key].append(w)
		if key not in dict:
			dict[key]=[]
			dict[key].append(line[0])
			dict[key].append(line[6])
			if line[6]=="+":
				w=line[3]+'\t'+line[4]
				dict[key].append(w)
				list.append(key)
			if line[6]=="-":
				w=line[4]+'\t'+line[3]
				dict[key].append(w)
				list.append(key)
for i in list:
	utg=dict[i][0]
	if len(dict[i])==3:
		if utg in dict2:
#			print(dict2[utg])
			print('>'+dict[i][0])
			w='Esngl'+'\t'+dict[i][2]+'\t'+i
			print(w)
			dict2.pop(utg)
		elif utg not in dict2:
			w='Esngl'+'\t'+dict[i][2]+'\t'+i
			print(w)
	if len(dict[i])>3:
		if utg in dict2:
			print('>'+dict[i][0])
			dict2.pop(utg)
		elif dict[i][1]=="+":
			for j in dict[i][2:]:
				if dict[i].index(j)==2:
					w='Einit'+'\t'+j+'\t'+i
					print(w)
				elif dict[i].index(j)==len(dict[i])-1:
					w='Eterm'+'\t'+j+'\t'+i
					print(w)
				else:
					w='Exon'+'\t'+j+'\t'+i
					print(w)
		elif dict[i][1]=="-":
			dict[i].reverse()
			for j in dict[i][0:-2]:
				if dict[i].index(j)==0:
					w='Einit'+'\t'+j+'\t'+i
					print(w)
				elif dict[i].index(j)==len(dict[i])-3:
					w='Eterm'+'\t'+j+'\t'+i
					print(w)
				else:
					w='Exon'+'\t'+j+'\t'+i
					print(w)
input.close()
