#!/usr/bin/env python
import sys,re
f1=open(sys.argv[1])
f2=open(sys.argv[2],'w')

for line1 in f1:
	if "#" in line1:
		f2.write(line1)
	else:
		line1=line1.strip()
		list1=line1.split()
#		AF_l=list1[7].split(";")[1].split("=")[1].split(",")
#		max_AF=float(max(AF_l,key=float,default=''))
		if "," not in list1[3] and "," not in list1[4]:
			if abs(len(list1[3])-len(list1[4]))>=20 and "N" not in list1[3] and "N" not in list1[4]:
				f2.write('{0}\n'.format('\t'.join(list1)))
		elif "," in list1[3] and "," not in list1[4]:
			ll=list1[3].split(",")
			max_len=max(ll,key=len,default='')
			min_len=min(ll,key=len,default='')
			if abs(len(max_len)-len(list1[4]))>=20 and "N" not in list1[3] and "N" not in list1[4]:
				f2.write('{0}\n'.format('\t'.join(list1)))
			elif abs(len(min_len)-len(list1[4]))>=20 and "N" not in list1[3] and "N" not in list1[4]:
				f2.write('{0}\n'.format('\t'.join(list1)))
			
		elif "," not in list1[3] and "," in list1[4]:
			ll=list1[4].split(",")
			max_len=max(ll,key=len,default='')
			min_len=min(ll,key=len,default='')
			if abs(len(max_len)-len(list1[3]))>=20 and "N" not in list1[3] and "N" not in list1[4]:
				f2.write('{0}\n'.format('\t'.join(list1)))
			elif abs(len(min_len)-len(list1[3]))>=20 and "N" not in list1[3] and "N" not in list1[4]:
				f2.write('{0}\n'.format('\t'.join(list1)))

f1.close()
f2.close()
