#!/usr/bin/python
######change augustus format

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')


dict={}
cal_line=0
for eachline in f1:
	cal_line+=1

f1.seek(0)	
exon_cal=0
cal_line_cal=0
for eachline in f1:
	cal_line_cal+=1
	if cal_line_cal<cal_line:
		if eachline=="\n":
			f2.write("%s\n"%(exon_w))
			f2.write("%s"%(eachline))
		else:
			line=eachline.split()
			stand=line[6]
			if line[2]=="gene":
				f2.write("%s"%(eachline))
				gene=''.join(line[8].split(";")[0][3:])
				exon_number=0
			elif line[2]=="mRNA":
				f2.write("%s"%(eachline))
			elif line[2]=="CDS":
				w="\t".join(line[0:])
				exon_infor=w.replace("cds","exon")
				exon_infor=exon_infor.replace("CDS","exon")
				exon_number+=1
				if stand=="-":
					if exon_number<=1:
						start=int(line[3])
						exon_w="\t".join(line[0:])
						exon_w=exon_infor+"\n"+exon_w
					else:
						if int(line[3]) <start:
							exon_w=exon_w+"\n"+exon_infor+"\n"+w
						elif int(line[3])> start:
							exon_w=exon_infor+"\n"+w+"\n"+exon_w
				else:
					if exon_number<=1:
						exon_w="\t".join(line[0:])
						exon_w=exon_infor+"\n"+exon_w
					else:
						exon_w=exon_w+"\n"+exon_infor+"\n"+w
	elif cal_line_cal>=cal_line:
		line=eachline.split()
		exon_number+=1
		w="\t".join(line[0:])
		exon_infor=w.replace("cds","exon")
		exon_infor=exon_infor.replace("CDS","exon")	
		if stand=="-":
			if exon_number<=1:
				f2.write("%s\n"%(exon_w))
				f2.write("%s\n"%(exon_infor))	
			else:
				if int(line[3]) <start:
					exon_w=exon_w+"\n"+exon_infor+"\n"+w
					f2.write("%s\n"%(exon_w))
				elif int(line[3])> start:
					exon_w=exon_infor+"\n"+w+"\n"+exon_w
					f2.write("%s\n"%(exon_w))	
		elif stand=="+":
			if exon_number<=1:
				f2.write("%s\n"%(exon_w))
				f2.write("%s\n"%(exon_infor))
			else:
				exon_w=exon_w+"\n"+exon_infor+"\n"+w
				f2.write("%s\n"%(exon_w))

f1.close()
f2.close()
