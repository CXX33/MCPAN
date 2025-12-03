#!/public/software/bin/python
##removed genes encod-ing proteins with less than 50 amino acids and incomplete genes without start and stop codons


import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

for eachline in f1:
	line=eachline.split()
	if ">" in eachline:
		a=eachline
	else:	
		w=line[0]
		len_cds=len(w)
		if (w.startswith('ATG') or w.startswith('GTG')) and (w.endswith('TAA') or w.endswith('TAG') or w.endswith('TGA')) and len_cds>=150:
#				print(w)
			f2.write("%s%s"%(a,eachline))
		elif len_cds>150:
			print("%s%s"%(a,eachline.strip()))
#			pass
		else:
			pass
#			print("%s%s"%(a,eachline.strip()))


f1.close()
f2.close()	
		
			
