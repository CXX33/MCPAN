#!/usr/bin/python
########change the border of cds

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3],'w')

dict={}
for eachline in f1:   #####cds postion
	i=eachline.split()  
	w=i[1]+"-"+i[2]  
	if int(i[3])>=30:           ###filer length>30bp
		dict[i[0]]=w


dict_cds={}
for eachline in f2:
	if eachline!="\n":
		dd=eachline.split()
		if dd[2]=="gene":
			gene_cal=''.join(dd[8].split(";")[0][3:])
			dict_cds[gene_cal]=0
		elif dd[2]=="CDS":
			dict_cds[gene_cal]=int(dict_cds[gene_cal])+1

f2.seek(0)
flag=0
cal=0
for eachline in f2:
	if eachline=="\n":
		f3.write("%s"%(eachline))
	else:
		line=eachline.split()
		start=int(line[3])
		end=int(line[4])
		stand=line[6]
		if line[2]=="mRNA":
			f3.write("%s"%(eachline))
		if line[2]=="gene":
			gene=''.join(line[8].split(";")[0][3:])
			f3.write("%s"%(eachline))
			if gene in dict:
				cal+=1
				cds=0
				start_cds=start+int(dict[gene].split("-")[0])-1
				end_cds_re=end-int(dict[gene].split("-")[0])+1
				end_cds=start+int(dict[gene].split("-")[1])+1
				start_cds_re=end-int(dict[gene].split("-")[1])-1
			#	if line[6]=="+":
			#		w="samtools faidx Ac_ref_180425.scaf.fa "+line[0]+":"+str(start_cds)+"-"+str(end_cds)+" >>test.fa"
			#		print(w)
		elif line[2]=="CDS":
			if gene not in dict:
				exon=eachline.replace("CDS","exon")
				exon=exon.replace("cds","exon")
				f3.write("%s"%(exon))
				f3.write("%s"%(eachline))
			elif gene in dict:
				cds+=1
				infor_1='\t'.join(line[0:3])
				infor_2="\t".join(line[5:])
				exon_1=infor_1.replace("CDS","exon")
				exon_2=infor_2.replace("cds","exon")
				length=int(line[4])-int(line[3])
				cds_pos=int(line[4])
				start_cds_s=int(line[3])
				if stand=="+":
					if cds<=1:
						#print(gene,eachline,start_cds,end_cds,exon_2)
						if  end_cds<=int(line[4]):
							f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds,end_cds,exon_2))
							f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds,end_cds,infor_2))
							flag=0
						elif start_cds<=int(line[4])  and end_cds>int(line[4]):
							#print(gene,eachline,start_cds,end_cds,exon_2)
							if cds<dict_cds[gene]:
								flag=1
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds,line[4],exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds,line[4],infor_2))
							elif cds >=dict_cds[gene]:
								flag=0
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds,end_cds,exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds,end_cds,infor_2))
						elif start_cds> int(line[4]) :
						#	print(gene,eachline,start_cds,end_cds,exon_2)
						#	start_cds=start_cds-1
						#	end_cds=end_cds-1
							if cds >=dict_cds[gene]:
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds,end_cds,exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds,end_cds,infor_2))
							else:
								flag=2
							#deadline=infor_1+"\t"+str(start_cds)+"\t"+str(end_cds)+"\t"+infor_2
					elif cds>1:
						#print(gene,eachline,start_cds,end_cds,exon_2)
						#cds_pos=int(line[3])+int(line[3])-cds_pos-1+length
						if flag<=0 :
							pass
						elif flag>0 and flag<=1:
							if end_cds<=cds_pos:
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,line[3],end_cds,exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,line[3],end_cds,infor_2))
								flag=0
							elif end_cds>cds_pos:
								if cds<dict_cds[gene]:    #### N in this intron
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,line[3],line[4],exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,line[3],line[4],infor_2))
									flag=1
								elif cds >=dict_cds[gene]:
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,line[3],end_cds,exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,line[3],end_cds,infor_2))
									flag=0
							
						elif flag>=2:
						#	start_cds=start_cds-1
							#print(gene,eachline,start_cds,end_cds,exon_2)
							if end_cds<=cds_pos:
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds,end_cds,exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds,end_cds,infor_2))
								flag=0
							elif start_cds<=cds_pos and end_cds>cds_pos:
								if cds >=dict_cds[gene]:
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds,end_cds,exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds,end_cds,infor_2))
									flag=0
								else:
									flag=1
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds,line[4],exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds,line[4],infor_2))
									#realine_exon=exon_1+"\t"+line[3]+"\t"+str(end_cds)+"\t"+exon_2
									#realine=infor_1+"\t"+line[3]+"\t"+str(end_cds)+"\t"+infor_2
							elif start_cds> cds_pos :
								if cds >=dict_cds[gene]:
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds,end_cds,exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds,end_cds,infor_2))
									flag=0
								else:
									flag=2
									#realine_exon=exon_1+"\t"+str(start_cds)+"\t"+str(end_cds)+"\t"+exon_2
									#realine=infor_1+"\t"+str(start_cds)+"\t"+str(end_cds)+"\t"+infor_2
				elif stand=="-":
					if cds<=1:
						##print(gene,start_cds_re,end_cds_re,line[3],line[4])
						if start_cds_re>=int(line[3]):
							f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds_re,end_cds_re,exon_2))
							f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds_re,end_cds_re,infor_2))
							flag=0
						elif start_cds_re< int(line[3]) and end_cds_re>=int(line[3]):
							if cds<dict_cds[gene]:
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,line[3],end_cds_re,exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,line[3],end_cds_re,infor_2))
								flag=1
							elif cds>=dict_cds[gene]:
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds_re,end_cds_re,exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds_re,end_cds_re,infor_2))
						#	realine_exon=exon_1+"\t"+str(start_cds)+"\t"+line[4]+"\t"+exon_2
								flag=0
						elif end_cds_re<int(line[3]):
							#print(gene,start_cds_re,end_cds_re,line[3],line[4])
							if cds>=dict_cds[gene]:
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds_re,end_cds_re,exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds_re,end_cds_re,infor_2))
								flag=0
							else:
								##print(gene,start_cds_re,end_cds_re,line[3],line[4])
								flag=2
					elif cds>1:
					#	#print(gene,start_cds_re,end_cds_re,line[3],line[4],flag)
						if flag<=0 :
							pass
						elif flag>0 and flag<=1:
							##print(gene,start_cds_re,end_cds_re,line[3],line[4])
							if start_cds_re>=int(line[3]):
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds_re,line[4],exon_2))	
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds_re,line[4],infor_2))
								flag=0
							elif  start_cds_re< int(line[3]):
								##print(gene,start_cds_re,end_cds_re,line[3],line[4])
								if cds<dict_cds[gene]:
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,line[3],line[4],exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,line[3],line[4],infor_2))
									flag=1
								elif cds >=dict_cds[gene]:
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds_re,line[4],exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds_re,line[4],infor_2))
									flag=0
						elif flag>=2:
					#		print(gene,start_cds_re,end_cds_re,line[3],line[4])
							if start_cds_re>=int(line[3]):
								##print(gene,start_cds_re,end_cds_re,line[3],line[4])
								f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds_re,end_cds_re,exon_2))
								f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds_re,end_cds_re,infor_2))
								flag=0
							elif start_cds_re< int(line[3]) and end_cds_re>=int(line[3]):
								##print(gene,start_cds_re,end_cds_re,line[3],line[4])
								if cds<dict_cds[gene]:
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,line[3],end_cds_re,exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,line[3],end_cds_re,infor_2))
									flag=1
								elif cds >=dict_cds[gene]:
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds_re,end_cds_re,exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds_re,end_cds_re,infor_2))
									flag=0
							elif end_cds_re<int(line[3]):
							#	#print(gene,start_cds_re,end_cds_re,line[3],line[4],flag,cds,dict_cds[gene])
								if cds<dict_cds[gene]:
									#print(gene,start_cds_re,end_cds_re,line[3],line[4],flag,cds,dict_cds[gene])
									flag=2
								elif cds>=dict_cds[gene]:
									flag=0
									f3.write("%s\t%s\t%s\t%s\n"%(exon_1,start_cds_re,end_cds_re,exon_2))
									f3.write("%s\t%s\t%s\t%s\n"%(infor_1,start_cds_re,end_cds_re,infor_2))
f1.close()
f2.close()
f3.close()
