files=read.table(file="files-sort.txt")
#Get insert expected sizes
inserts <- strsplit(as.character(read.delim("ultra-long-conf.txt", header=F, sep=" ")$V4),",")[[1]]

#Plot insert sizes
pdf(file="Insert-Dstr.pdf")
par(mfrow=c(5,4),mar=c(1, 4, 2, 1))
b<-inserts
for(i in 1:length(files$V1)){
  b[i]=read.table(file=as.vector(files$V1[i]))
  boxplot(b[[i]],
          outline=F,
          ylab="Insert size (kb)",
          las=2,
          boxwex=0.3, 
          main=inserts[i])
  }
dev.off()
