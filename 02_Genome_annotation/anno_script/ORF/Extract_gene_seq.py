#!/usr/bin/python
########extract cds sequence and the sequence between gene start/end  and cds

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3])
f4=open(sys.argv[4],'w')

dict={}
for eachline in f1:    #####err gene name
        line=eachline.split()
        dict[line[0]]=line[0]

dict_chr={}
for eachline in f2:        #### sequences
        a=eachline.split()
        if ">" in eachline:
                flag_chr=1
                name=''.join(a[0][1:])
                dict[name]=name
                dict[name]=[]
        elif flag_chr>=1:
                for b in a[0]:
                        dict[name].append(b)


flag=0
cal=0
for eachline in f3:   ###gff3
	if eachline!="\n":
		i=eachline.split()
		if i[2]=="gene":
			gene=''.join(i[8].split(";")[0][3:])
			flag=0
			#length=int(i[4])-int(i[3])+1
			length=int(i[4])-int(i[3])
			#print(gene,length)
			if gene in dict:
				cal+=1
				cds_number=0
				if cal<=1:
					w=[]
					for aa in range(0,length):
						w.append('N')
					flag=1
					stand=i[6]
					f4.write("%s%s\n"%(">",gene))
					#print(gene)
					Start=int(i[3])-1
					End=int(i[4])
				elif cal>1:
					if stand=="+":
						cds=''.join(dict[i[0]][cds_e:End])
						##print(cds_e,End)
						w[end:-1]=cds
						seq_re=''.join(w[0:])
						f4.write("%s\n"%(seq_re))
						Start=int(i[3])-1
						End=int(i[4])
					elif stand=="-":
						cds=''.join(dict[i[0]][Start:cds_s])
						#print(Start,cds_s,start)
						w[:start]=cds
						seq=[]
						for e  in w:
							if e=="A":
								seq.append("T")
							elif e=="T":
								seq.append("A")
							elif e=="C":
								seq.append("G")
							elif e=="G":
								seq.append("C")
							elif e=="N":
								seq.append("N")
						seq.reverse()
						seq_re=''.join(seq[0:])
						gene=''.join(i[8].split(";")[0][3:])
						Start=int(i[3])-1
						End=int(i[4])
						f4.write("%s\n"%(seq_re))
					w=[]
					cds_number=0
					for aa in range(0,length):
						w.append('N')
					flag=1
					stand=i[6]
					f4.write("%s%s\n"%(">",gene))
					#print(gene)
		elif flag>=1 and i[2]=="CDS":
				cds_number+=1
				start=int(i[3])-Start-1
				end=int(i[4])-Start
				cds_s=int(i[3])-1
				cds_e=int(i[4])
				if stand=="+":
					if cds_number >1:
						cds=''.join(dict[i[0]][cds_s:cds_e])
						w[start:end]=cds
						##print(start,end,cds_s,cds_e)
					elif cds_number<=1:
						cds=''.join(dict[i[0]][Start:cds_e])
						w[:end]=cds
						##print(0,end,Start,cds_e)
				elif stand=="-":
					if cds_number >1:
						cds=''.join(dict[i[0]][cds_s:cds_e])
						w[start:end]=cds
					elif cds_number<=1:
						cds=''.join(dict[i[0]][cds_s:End])
						w[start:]=cds
						#print(start,cds_s,End,len(w))
f1.close()
f2.close()
f3.close()
f4.close()		
