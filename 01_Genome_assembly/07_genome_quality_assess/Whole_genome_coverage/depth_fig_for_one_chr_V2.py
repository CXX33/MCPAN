#!/usr/bin/env python
import sys,re
import svgwrite

f1=open(sys.argv[1])  #####chr len
f2=open(sys.argv[2])  ##Cent Telo 45S 5S

f3=open(sys.argv[3])  ##normal ONT
f4=open(sys.argv[4])  ##abnormal ONT

f5=open(sys.argv[5])  ##normal hifi
f6=open(sys.argv[6])  ##abnormal hifi

chrn=sys.argv[7] ###chr name
Output=sys.argv[8]

chr_list=[]
len_dic={}

for line1 in f1:
	list1=line1.strip().split()
	chr_list.append(list1[0])
	len_dic[list1[0]]=list1[1]


width=90 #cm
height=20 #cm
dwg = svgwrite.Drawing(filename = Output ,size=(width,height))

dwg.add(dwg.line(start=(5,2),end=(85,2),stroke="black",stroke_width=0.15))

len_l1=80/2  
for j in range(int(len_l1)+1):
	x=j*2
	y1=1.7
	y2=2
	dwg.add(dwg.line(start=(x+5,y1),end=(x+5,y2),stroke="grey",stroke_width=0.1))

len_l2=80/10 
for i in range(int(len_l2)+1):
	x=i*10
	y1=1.5
	y2=2
	te=str(x/2)
	dwg.add(dwg.line(start=(x+5,y1),end=(x+5,y2),stroke="black",stroke_width=0.15))
	dwg.add(dwg.text(te,insert=(x+5,3),fill="black",font_size=1))


Hstart=5  
Vstart=8 

####chr
dwg.add(dwg.rect(insert=(Hstart,Vstart),size=((int(len_dic[chrn])+0.0)/500000,0.5),rx=0.25,stroke_width=0.05,stroke="grey",fill="grey"))


#########################################################
####Cent Telo 45S 5S 
for line2 in f2:
	line2=line2.strip()
	if line2.startswith('#'):continue
	list2=line2.split()
	xpos=(int(list2[1])+0.0)/500000
	xsize=(int(list2[3])+0.0)/500000
	ysize=0.5
	if list2[0]==chrn and  list2[4]=="45S":
		y1=Vstart
		x1=Hstart+xpos
		dwg.add(dwg.rect(insert=(x1,y1),size=(xsize,ysize),stroke_width=0.0000001,stroke="darkcyan",fill="darkcyan"))
	if list2[0]==chrn and  list2[4]=="5S":
		y1=Vstart
		x1=Hstart+xpos
		dwg.add(dwg.rect(insert=(x1,y1),size=(xsize,ysize),stroke_width=0.0000001,stroke="magenta",fill="magenta"))
	if list2[0]==chrn and  list2[4]=="Cent":
		y1=Vstart
		x1=Hstart+xpos
		dwg.add(dwg.rect(insert=(x1,y1),size=(xsize,ysize),stroke_width=0.0000001,stroke=svgwrite.rgb(212, 29, 0, "RGB"),fill=svgwrite.rgb(212, 29, 0, "RGB")))
	if list2[0]==chrn and  list2[4]=="Telo":
		y1=Vstart
		x1=Hstart+xpos
		dwg.add(dwg.rect(insert=(x1,y1),size=(xsize,ysize),stroke_width=0.0000001,stroke="purple",fill="purple"))


yaxis=3 ####  ######
y2=Vstart
y1=y2-yaxis  ######
dwg.add(dwg.line(start=(4.8,y1),end=(4.8,y2),stroke="black",stroke_width=0.1))
for i in range(yaxis*2+1):
	dwg.add(dwg.line(start=(4.6,y2-float(i)/2),end=(4.8,y2-float(i)/2),stroke="black",stroke_width=0.1))


Vstart2=Vstart+0.5 #####染色体宽度
yaxis=3
y1=Vstart2
y2=y1+yaxis
dwg.add(dwg.line(start=(4.8,y1),end=(4.8,y2),stroke="black",stroke_width=0.1))
for i in range(yaxis*2+1):
	dwg.add(dwg.line(start=(4.6,y2-float(i)/2),end=(4.8,y2-float(i)/2),stroke="black",stroke_width=0.1))

dwg.add(dwg.text(chrn,insert=(4,9),transform="rotate(-90,4,9)",fill="black",font_size=1))

####
for line3 in f3:
	list3=line3.strip().split()
	xpos=(int(list3[1])+0.0)/500000
	ypos=float(list3[3])/50  ####这里150在Y轴上实际是3，所以除以50就好了
	x1=Hstart+xpos
	y2=Vstart
	y1=y2-ypos
	dwg.add(dwg.line(start=(x1,y1),end=(x1,y2),stroke="silver",stroke_width=0.001))

for line4 in f4:
	list4=line4.strip().split()
	xpos=(int(list4[1])+0.0)/500000
	ypos=float(list4[3])/50   ####这里150在Y轴上实际是3，所以除以50就好了
	x1=Hstart+xpos
	y2=Vstart
	y1=y2-ypos
	dwg.add(dwg.line(start=(x1,y1),end=(x1,y2),stroke="black",stroke_width=0.01))

####
for line5 in f5:
	list5=line5.strip().split()
	xpos=(int(list5[1])+0.0)/500000
	ypos=float(list5[3])/50   ####这里150在Y轴上实际是3，所以除以50就好了
	x1=Hstart+xpos
	y1=Vstart2
	y2=y1+ypos
	dwg.add(dwg.line(start=(x1,y1),end=(x1,y2),stroke="silver",stroke_width=0.001))

for line6 in f6:
	list6=line6.strip().split()
	xpos=(int(list6[1])+0.0)/500000
	ypos=float(list6[3])/50   ####这里150在Y轴上实际是3，所以除以50就好
	x1=Hstart+xpos
	y1=Vstart2
	y2=y1+ypos
	dwg.add(dwg.line(start=(x1,y1),end=(x1,y2),stroke="black",stroke_width=0.01))

dwg.save()

f1.close()
f2.close()
f3.close()
f4.close()
f5.close()
f6.close()
