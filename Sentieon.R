# Script for making sense of Sinteion/GATK comparisons
#library(lattice)
library(package = "lattice")

GATK.TAB<-read.table("gatk.f10.tabbed",header=F)
SINT.TAB<-read.table("sint.f10.tabbed",header=F)

colnames(GATK.TAB)<-c("GT","AD","DP","GQ","PL")
colnames(SINT.TAB)<-c("GT","AD","DP","GQ","PL")


DP<-as.data.frame(cbind(GATK=GATK.TAB$DP,SINT=SINT.TAB$DP))
GQ<-as.data.frame(cbind(GATK=GATK.TAB$GQ,SINT=SINT.TAB$GQ))

with(DP, xyplot(GATK ~ SINT))
with(GQ, xyplot(GATK ~ SINT))

# Working with better organized data frame

DATA<-read.table("sentieon.gatk_data.csv", header = T)

DATA<-read.table("DCIS_0029_Br_P_TS_2.isec_data.csv", header = T)
DATA<-read.table("DCIS_0034_Br_R_TS_1.isec_data.csv", header = T)
DATA<-read.table("DCIS_0038_Br_R_TS_1.isec_data.csv", header = T)
DATA<-read.table("DCIS_0046_Br_P_TS_1.isec_data.csv", header = T)
DATA<-read.table("DCIS_0048_Br_P_TS_1.isec_data.csv", header = T)

DATA<-read.table("HALT_0220_Pb_R_EX_31001210.isec_data.csv", header = T)
DATA<-read.table("HALT_0238_Bm_R_EX_31001419.isec_data.csv", header = T)
DATA<-read.table("HALT_1617_Bm_P_EX_31001234.isec_data.csv", header = T)
DATA<-read.table("HALT_1643_Pb_P_EX_31001184.isec_data.csv", header = T)
DATA<-read.table("HALT_1644_Pb_R_EX_31001189.isec_data.csv", header = T)
DATA<-read.table("HALT_1646_Pb_R_EX_31001194.isec_data.csv", header = T)

with(DATA[DATA$Type!="Score",],xyplot(Sentineon ~ GATK | Type))
with(DATA[DATA$Type=="Score",],xyplot(Sentineon ~ GATK | Type))

