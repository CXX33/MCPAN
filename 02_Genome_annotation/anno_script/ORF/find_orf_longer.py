#!/usr/bin/python
############find orf in gene sequence###############2018.04.02############

import sys

f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

dict_seq={}
dict_number={}

flag_seq=0
for eachline in f1:
	z=eachline.split()
	if ">" in eachline:
		z_name=''.join(z[0][1:])
		dict_seq[z_name]=z_name
		dict_seq[z_name]=[]
		flag_seq=1
		z_number=0
		y_number=0
	elif flag_seq>=1 :
		for y in z[0]: 
			z_number+=1
			if y!="N":
				y_number+=1
				y_name=z_name+str(y_number)
				#print(y_name,y_number)
				dict_seq[z_name].append(y)
				dict_number[y_name]=z_number

f1.seek(0)
for eachline in f1:
	line=eachline.split()
	if ">" in eachline:
		flag=1
		cal=0
		name=''.join(line[0][1:])
	elif flag>=1:
		length=len(dict_seq[name])
		for i in range(0,length):
				number=0
				stop=0
				for a in range(i,length,3):
					name_id=name+str(a+1)
					if a<=length-3:
						if dict_seq[name][a]=="T" and dict_seq[name][a+1]=="A" and dict_seq[name][a+2]=="G":
							stop+=1
							if stop<=1 and number>=1:
								f2.write("%s\n"%(dict_number[name_id]))
								cal+=1
							elif number<1:
								pass
						elif dict_seq[name][a]=="T" and dict_seq[name][a+1]=="A" and dict_seq[name][a+2]=="A":
							stop+=1
							if stop<=1 and number>=1:
								f2.write("%s\n"%(dict_number[name_id]))
								cal+=1
							elif number<1:
								a=a-1
						elif dict_seq[name][a]=="T" and dict_seq[name][a+1]=="G" and dict_seq[name][a+2]=="A":
							stop+=1
							if stop<=1 and number>=1:
								f2.write("%s\n"%(dict_number[name_id]))
								cal+=1
							elif number<1:
								pass
						else:
							number+=1
							if number<=1:
								if cal>=1:
									f2.write("%s\t%s\t"%(name,dict_number[name_id]))
									cal=0
								elif cal<1:
									f2.write("%s\n%s\t%s\t"%("Nostop",name,dict_number[name_id]))
							else:
								pass
					elif a>length-3:
						if stop<1 and number>=1:
							f2.write("%s\n"%("Nostop"))	
f1.close()
f2.close()
