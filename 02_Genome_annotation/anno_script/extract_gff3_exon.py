#extract exon seq

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2])
f3=open(sys.argv[3],'w')

dict={}
flag=0
for eachline in f1:
	line=eachline.split()
	if ">" in eachline:
		id=line[0]
		dict[id]=id
		dict[id]=[]
		flag=1
	elif flag>0:
		for i in line[0]:
			dict[id].append(i[0])
		flag=0

for eachline in f2:
	w=''
	m=eachline.split()
	p=">"+m[0]
	name=m[8].split(";")[0]
	start=int(m[3])-1
	end=int(m[4])
	if p in dict:
		if m[2]=="exon":
#			for number in range(start,end):
#				w=w+dict[p][number]
			if m[6]=="+":
				for number in range(start,end):
					w=w+dict[p][number]
#				print(w)
				f3.write("%s%s\n%s\n"%(">",name,w))
			elif m[6]=="-":
				o=''
				list_em=[]
				for number in range(start-1,end):
					list_em.append(dict[p][number])
				l=list_em[::-1]
				for k in l:
					o=o+k
#				print(o)
				f3.write("%s%s\n%s\n"%(">",name,o))

f1.close()
f2.close()
f3.close()	
