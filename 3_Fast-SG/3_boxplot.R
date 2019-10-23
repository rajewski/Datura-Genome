files=read.table(file="files-sort.txt")
pdf(file="Insert-Dstr.pdf")
par(mfrow=c(5,4),mar=c(1, 4, 2, 1))
b<-c("2kb","4kb","6kb","8kb","10kb","12kb","14kb",
     "16kb","18kb","20kb","30kb","40kb","50kb","60kb","70kb",
     "80kb","100kb","120kb","150kb","180kb")
for(i in 1:length(files$V1)){
  b[i]=read.table(file=as.vector(files$V1[i]))
  boxplot(b[[i]],outline=F,ylab="Insert size (kb)",las=2,boxwex=0.3)
}
dev.off()