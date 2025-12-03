import sys

input=open(sys.argv[1])

dict={}
for eachline in input:
	if "#"  not in eachline:
		line=eachline.split()
		if line[11][1:-2]  in dict:
			exon+=1
			id='ID='+line[11][1:-2]+'.exon'+str(exon)+';Parent='+line[11][1:-2]
			w=line[0]+'\t'+line[1]+'\t'+line[2]+'\t'+line[3]+'\t'+line[4]+'\t'+line[5]+'\t'+line[6]+'\t'+line[7]+'\t'+id
			print(w)
		if line[11][1:-2] not in dict:
			dict[line[11][1:-2]]=''
			exon=1
			id='ID='+line[11][1:-2]+'.exon'+str(exon)+';Parent='+line[11][1:-2]
			w=line[0]+'\t'+line[1]+'\t'+line[2]+'\t'+line[3]+'\t'+line[4]+'\t'+line[5]+'\t'+line[6]+'\t'+line[7]+'\t'+id
			print(w)
