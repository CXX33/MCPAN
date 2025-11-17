#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
for line1 in f1:
	line1=line1.strip()
	s69=line1[68]
	s72=line1[71]
	s131=line1[130]
	s150=line1[149]
	s205=line1[204]
	s239=line1[238]
	s283=line1[282]
	type=s69+s72+s131+s150+s205+s239+s283
	f2.write("{0}\n".format(type))
f1.close()
f2.close()
	
