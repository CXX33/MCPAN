library(data.table)
library(tidyverse)
## agrestis
dat.ld_agrestis<-fread("SNP_InDel_SV.agrestis.ld.gz")
dat.ld_agrestis%>%filter(abs(BP_A-BP_B)<=5000) -> dat.ld_agrestis
save(dat.ld_agrestis,file = "SNP_InDel_SV.ld.agrestis.5k.Rdata")
## melo
dat.ld_melo<-fread("SNP_InDel_SV.melo.ld.gz")
dat.ld_melo%>%filter(abs(BP_A-BP_B)<=5000) -> dat.ld_melo
save(dat.ld_melo,file = "SNP_InDel_SV.ld.melo.5k.Rdata")
