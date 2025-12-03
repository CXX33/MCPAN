#!/usr/bin/env python3
import sys
f1=open(sys.argv[1],'r')
f2=open(sys.argv[2],'w')
l_WA=[]
l_CA=[]
l_WM=[]
l_CM=[]
for line1 in f1:
	list1=line1.strip().split()
	if list1[-1] == "WA":
		l_WA.append(str(int(list1[0])+8))
	if list1[-1] == "CA":
		l_CA.append(str(int(list1[0])+8))
	if list1[-1] == "WM":
		l_WM.append(str(int(list1[0])+8))
	if list1[-1] == "CM":
		l_CM.append(str(int(list1[0])+8))
f2.write("WA:{0}\nCA:{1}\nWM:{2}\nCM:{3}\n".format(l_WA,l_CA,l_WM,l_CM))
f1.close()
f2.close()
