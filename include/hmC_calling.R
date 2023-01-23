library(methylKit)
library(genomation)

#fichier cov rrbs
fileRR <- snakemake@input[[1]]
#fichier cov oxrrbs
fileOxRR <- snakemake@input[[2]]


file.list <- c(fileRR, fileOxRR)

# read the files to a methylRawList object: myobj
myobj=methRead(file.list,
               sample.id=c(0,1),
               assembly="hg36",
               pipeline = "bismarkCoverage",
               treatment=gplist,
               context="CpG",
               header=FALSE
)

#filtres les coverages extrêmes
filtered.myobj=filterByCoverage(myobj,lo.count=10,lo.perc=NULL,
                                hi.count=NULL,hi.perc=99.9)



#conserve uniquement les CpG communs
meth=unite(filtered.myobj, destrand=FALSE)

#DMC calling
myDiff=calculateDiffMeth(meth)

# get hypo methylated bases
myDiff25p.hypo=getMethylDiff(myDiff,difference=25,qvalue=0.01,type="hypo")

outname1=paste0(fileRR,"_hmC.cov.txt")
outname2=paste0(fileRR,"_MC.cov.txt")
outname3=paste0(fileRR,"_uC.cov.txt")
#Ecriture d'une table contenant les CpG différentiellements exprimés
#chr start end strand pvalue qvalue meth.diff
write.table(myDiff25p.hypo,file = outname1, sep="\t", col.names=FALSE, row.names = F,quote = F)
write.table(myobj[[2]][which(myobj[[2]]$numCs/myobj[[2]]$coverage >0.7)],file = outname2, sep="\t", col.names=FALSE, row.names = F,quote = F)
write.table(myobj[[1]][which(myobj[[1]]$numCs/myobj[[1]]$coverage <0.3)],file = outname3, sep="\t", col.names=FALSE, row.names = F,quote = F)
