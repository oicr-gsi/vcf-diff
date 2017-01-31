#!/usr/bin/env Rscript
library(lattice)

vcf.diff <- function(args) {
  # test if there is at least one argument: if not, return an error
  if (length(args)==0) {
    stop("At least one argument must be supplied (input file).n", call.=FALSE)
  }

  #iterate through file paths and bind them together in massive data frame
  DATA<-do.call(rbind, lapply(args,read.table, header=T) )
  
  DATA.nona<-DATA[!is.na(DATA$GATK),]
  DATA.nona<-DATA.nona[!is.na(DATA.nona$Sentieon),]
  sapply(levels(DATA.nona$Type), plotthings, DATA=DATA.nona)

  png("summary.png")
  with(DATA,xyplot(Sentieon ~ GATK | Type))
  dev.off()
}

plotthings <- function(lvl, DATA) {
   print(paste("Starting level: ",lvl))
   sub<-DATA[DATA$Type==lvl,]
   sub<-sub[!is.na(sub$GATK),]
   sub<-sub[!is.na(sub$Sentieon),]
   
   png(paste("comparison",lvl,"png",sep="."))
   plot(sub$GATK, sub$Sentieon, 
        type="p", 
        main=paste("Comparison of", lvl,"scores in GATK and Sentieon variants", sep=" "), 
        xlab=paste("GATK",lvl, sep=" "), 
        ylab=paste("Sentieon",lvl, sep=" "),
        col="blue")
   abline(a=0,b=1, col="gray60")
   fit<-lm(Sentieon~GATK,sub)
   if (!is.na(fit$coefficients[2])) {
    abline(fit, col="blue")
   }
   r2=summary(fit)$r.squared
   eqn <- bquote(r^2 == .(r2))
   text (2, max(sub$Sentieon), eqn, pos=4, col="blue")
   dev.off()
}

args = commandArgs(trailingOnly=TRUE)
vcf.diff(args)
