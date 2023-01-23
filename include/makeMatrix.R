library(edgeR)

args = commandArgs(trailingOnly=TRUE)

#arglist :
# 1 : exit_file_path (chr)
# 2 : Betavalue (booleen)
# 3 : Mvalue (booleen)
# 4 : min.cov (num) minimum cpg coverage
# 5+ : file list (chr)
# x+ : sample names (chr)


nb.ech=(length(args)-4)/2 #possible condition nb.ech>1 and int
#message(as.character(nb.ech))
file_list=args[5:(4+nb.ech)]
message(as.character(length(file_list)))
sample_names=args[(5+nb.ech):(4+2*nb.ech)]
message(as.character(length(sample_names)))
yall=edgeR::readBismark2DGE(file_list,sample.names=sample_names)
met=c("Me","Un")
Methylation=rep(met,times=nb.ech)
Coverage=yall$counts[,Methylation=="Me"]+yall$counts[,Methylation=="Un"]
keep=rowSums(Coverage >= as.integer(args[4]))==nb.ech
Coverage=Coverage[keep,]
yall=yall[keep,,keep.lib.sizes =F]
Met_counts=yall$counts[, Methylation =="Me"]
Un_counts=yall$counts[, Methylation =="Un"]
###########################Normalization
Coverage2 <- matrix(data = t(apply(Coverage, 2, function(x) rep(x, 2))), ncol = ncol(Coverage)*2)
normcounts=log2(1 + ((yall$counts/Coverage2) * 100))
norm_met=normcounts[,Methylation == "Me"]
norm_un=normcounts[,Methylation == "Un"]
colnames(norm_met)=sample_names
colnames(norm_un)=sample_names
save(norm_met, file=paste0(args[1],"normalized_counts_met_matrix.RData"))
save(norm_un, file=paste0(args[1], "normalized_counts_unmet_matrix.RData")) 
colnames(Met_counts)=sample_names
colnames(Un_counts)=sample_names
save(Met_counts, file=paste0(args[1],"matrix_met.RData"))
save(Un_counts, file=paste0(args[1],"matrix_unmet.RData"))

if(as.integer(args[2])!=0 | as.integer(args[3])!=0){
#betavalue
    if(as.integer(args[2])!=0){
        beta_val=norm_met/(norm_met+norm_un)
        save(beta_val, file=paste0(args[1],"matrix_beta_val.RData")) 
    }
#M-value
    if(as.integer(args[3])!=0){
        M_val=log2(norm_met+2) - log2(norm_un + 2)
        save(M_val, file=paste0(args[1],"matrix_M_value.RData"))
   }
}

