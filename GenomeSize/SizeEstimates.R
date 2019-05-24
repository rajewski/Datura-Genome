setwd("~/bigdata/Datura/GenomeSize")

# One-Library  ------------------------------------------------------------
single12 <- read.table("12mer_out.histo") #load the data into dataframe19
plot(single12[1:100,], type="l") #plots the data points 1 through 200 in the dataframe19 using a line
single12[1:24,]
single12[1:20,2] #find the peak coverage, its 20
sum(as.numeric(single11[2:9910,1]*single11[2:9910,2]))/54


single11 <- read.table("11mer_out.histo", col.names = c("Cov", "mer11"))
single12 <- read.table("12mer_out.histo", col.names = c("Cov", "mer12"))
single13 <- read.table("13mer_out.histo", col.names = c("Cov", "mer13"))
single15 <- read.table("15mer_out.histo", col.names = c("Cov", "mer15"))
single19 <- read.table("19mer_out.histo", col.names = c("Cov", "mer19"))

#merge into single frame (https://stackoverflow.com/questions/14096814/merging-a-lot-of-data-frames)
Single <- Reduce(function(...) merge(..., by="Cov", all=TRUE), list(single11, single12, single13, single15, single19))
plot.ts(Single[,2:6])
plot(Single[1:100,2], type="l")
sum(as.numeric(Single[1:10000,"Cov"]*single12[1:9534,]))/20 #get the genome size

# Two-Library -------------------------------------------------------------
dual9 <- read.table("Dual_9mer_out.histo", col.names = c("Cov", "mer9"))
dual10 <- read.table("Dual_10mer_out.histo", col.names = c("Cov", "mer10"))
dual11 <- read.table("Dual_11mer_out.histo", col.names = c("Cov", "mer11"))
dual12 <- read.table("Dual_12mer_out.histo", col.names = c("Cov", "mer12"))
dual13 <- read.table("Dual_13mer_out.histo", col.names = c("Cov", "mer13"))
dual14 <- read.table("Dual_14mer_out.histo", col.names = c("Cov", "mer14"))
dual15 <- read.table("Dual_15mer_out.histo", col.names = c("Cov", "mer15"))
dual20 <- read.table("Dual_20mer_out.histo", col.names = c("Cov", "mer20"))
dual <- Reduce(function(...) merge(..., by="Cov", all=TRUE), list(dual9, dual10, dual11, dual12, dual13, dual14, dual15, dual20))
plot.ts(dual[,2:9], main="~2.9x Coverage")
sum(as.numeric(dataframed12[2:9976,1]*dataframed12[2:9976,2]))/14

# Arbidopsis Test ---------------------------------------------------------
# made a subsamples fastq using this one-liner:
# cat chi2_r1.fq | awk '{ printf("%s",$0); n++; if(n%4==0) { printf("\n");} else { printf("\t");} }' | awk -v k=10000000 'BEGIN{srand(systime() + PROCINFO["pid"]);}{s=x++<k?x1:int(rand()*x);if(s<k)R[s]=$0}END{for(i in R)print R[i]}' | awk -F"\t" '{print $1"\n"$2"\n"$3"\n"$4 > "chi2_r1_sub10m.fq"}'
# from http://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/subsampling_reads.pdf

# 100k reads subsamples from larger fq file
test100k6 <- read.table("Test_sub100k_6mer_out.histo", col.names = c("Cov", "mer6"))
test100k7 <- read.table("Test_sub100k_7mer_out.histo", col.names = c("Cov", "mer7"))
test100k8 <- read.table("Test_sub100k_8mer_out.histo", col.names = c("Cov", "mer8"))
test100k9 <- read.table("Test_sub100k_9mer_out.histo", col.names = c("Cov", "mer9"))
test100k10 <- read.table("Test_sub100k_10mer_out.histo", col.names = c("Cov", "mer10"))
test100k11 <- read.table("Test_sub100k_11mer_out.histo", col.names = c("Cov", "mer11"))
test100k12 <- read.table("Test_sub100k_12mer_out.histo", col.names = c("Cov", "mer12"))
test100k13 <- read.table("Test_sub100k_13mer_out.histo", col.names = c("Cov", "mer13"))
test100k14 <- read.table("Test_sub100k_14mer_out.histo", col.names = c("Cov", "mer14"))
test100k15 <- read.table("Test_sub100k_15mer_out.histo", col.names = c("Cov", "mer15"))
test100k20 <- read.table("Test_sub100k_20mer_out.histo", col.names = c("Cov", "mer20"))
test100k <- Reduce(function(...) merge(..., by="Cov", all=TRUE), list(test100k6, test100k7, test100k8, test100k9, test100k10, test100k11, test100k12, test100k13, test100k14, test100k15, test100k20))
plot.ts(test100k[,2:11], main="~0.05x Coverage")
plot(test100k8[20:120,], type="l")
SizeTest100k <- sum(as.numeric(test100k8[,1]*test100k8[,2]))/63

# 1m reads subsamples from larger fq file
test1m6 <- read.table("Test_sub1m_6mer_out.histo", col.names = c("Cov", "mer6"))
test1m7 <- read.table("Test_sub1m_7mer_out.histo", col.names = c("Cov", "mer7"))
test1m8 <- read.table("Test_sub1m_8mer_out.histo", col.names = c("Cov", "mer8"))
test1m9 <- read.table("Test_sub1m_9mer_out.histo", col.names = c("Cov", "mer9"))
test1m10 <- read.table("Test_sub1m_10mer_out.histo", col.names = c("Cov", "mer10"))
test1m11 <- read.table("Test_sub1m_11mer_out.histo", col.names = c("Cov", "mer11"))
test1m12 <- read.table("Test_sub1m_12mer_out.histo", col.names = c("Cov", "mer12"))
test1m13 <- read.table("Test_sub1m_13mer_out.histo", col.names = c("Cov", "mer13"))
test1m14 <- read.table("Test_sub1m_14mer_out.histo", col.names = c("Cov", "mer14"))
test1m15 <- read.table("Test_sub1m_15mer_out.histo", col.names = c("Cov", "mer15"))
test1m20 <- read.table("Test_sub1m_20mer_out.histo", col.names = c("Cov", "mer20"))
test1m <- Reduce(function(...) merge(..., by="Cov", all=TRUE), list(test1m6, test1m7, test1m8, test1m9, test1m10, test1m11, test1m12, test1m13, test1m14, test1m15, test1m20))
plot.ts(test1m[,2:11], main="~0.5x Coverage")
plot(test1m[80:150,c(1,5)], type="l") #ax at 98
SizeTest1m <- sum(as.numeric(test1m9[,1]*test1m9[,2]))/98

# 4m reads subsamples from larger fq file to approximate the dual library coverage of datura
test4m6 <- read.table("Test_sub4m_6mer_out.histo", col.names = c("Cov", "mer6"))
test4m7 <- read.table("Test_sub4m_7mer_out.histo", col.names = c("Cov", "mer7"))
test4m8 <- read.table("Test_sub4m_8mer_out.histo", col.names = c("Cov", "mer8"))
test4m9 <- read.table("Test_sub4m_9mer_out.histo", col.names = c("Cov", "mer9"))
test4m10 <- read.table("Test_sub4m_10mer_out.histo", col.names = c("Cov", "mer10"))
test4m11 <- read.table("Test_sub4m_11mer_out.histo", col.names = c("Cov", "mer11"))
test4m12 <- read.table("Test_sub4m_12mer_out.histo", col.names = c("Cov", "mer12"))
test4m13 <- read.table("Test_sub4m_13mer_out.histo", col.names = c("Cov", "mer13"))
test4m14 <- read.table("Test_sub4m_14mer_out.histo", col.names = c("Cov", "mer14"))
test4m15 <- read.table("Test_sub4m_15mer_out.histo", col.names = c("Cov", "mer15"))
test4m20 <- read.table("Test_sub4m_20mer_out.histo", col.names = c("Cov", "mer20"))
test4m <- Reduce(function(...) merge(..., by="Cov", all=TRUE), list(test4m6, test4m7, test4m8, test4m9, test4m10, test4m11, test4m12, test4m13, test4m14, test4m15, test4m20))
plot.ts(test4m[,2:11], main="Arabidopsis ~2x Coverage")

# Full ARabidopsis Data Set
test6 <- read.table("Test__6mer_out.histo", col.names = c("Cov", "mer6"))
test7 <- read.table("Test__7mer_out.histo", col.names = c("Cov", "mer7"))
test8 <- read.table("Test__8mer_out.histo", col.names = c("Cov", "mer8"))
test9 <- read.table("Test__9mer_out.histo", col.names = c("Cov", "mer9"))
test10 <- read.table("Test__10mer_out.histo", col.names = c("Cov", "mer10"))
test11 <- read.table("Test__11mer_out.histo", col.names = c("Cov", "mer11"))
test12 <- read.table("Test__12mer_out.histo", col.names = c("Cov", "mer12"))
test13 <- read.table("Test__13mer_out.histo", col.names = c("Cov", "mer13"))
test14 <- read.table("Test__14mer_out.histo", col.names = c("Cov", "mer14"))
test15 <- read.table("Test__15mer_out.histo", col.names = c("Cov", "mer15"))
test20 <- read.table("Test__20mer_out.histo", col.names = c("Cov", "mer20"))
test <- Reduce(function(...) merge(..., by="Cov", all=TRUE), list(test6, test7, test8, test9, test10, test11, test12, test13, test14, test15, test20))
plot.ts(test[,2:11], main="~12x Coverage")
plot(test20[1:20,], type="l")
SizeTest <- sum(as.numeric(test20[2:6761,1]*test20[2:6761,2]))/9

# Datura ------------------------------------------------------------------
setwd("~/bigdata/Datura/GenomeSize/Results_AllTrim/")
DstrAll11 <- read.table("DstrTrim_11mer_out.histo", col.names = c("Cov", "mer11"))
DstrAll13 <- read.table("DstrTrim_13mer_out.histo", col.names = c("Cov", "mer13"))
DstrAll15 <- read.table("DstrTrim_15mer_out.histo", col.names = c("Cov", "mer15"))
DstrAll17 <- read.table("DstrTrim_17mer_out.histo", col.names = c("Cov", "mer17"))
DstrAll19 <- read.table("DstrTrim_19mer_out.histo", col.names = c("Cov", "mer19"))
DstrAll21 <- read.table("DstrTrim_21mer_out.histo", col.names = c("Cov", "mer21"))
DstrAll25 <- read.table("DstrTrim_25mer_out.histo", col.names = c("Cov", "mer25"))
DstrAll27 <- read.table("DstrTrim_27mer_out.histo", col.names = c("Cov", "mer27"))
DstrAll29 <- read.table("DstrTrim_29mer_out.histo", col.names = c("Cov", "mer29"))
DstrAll31 <- read.table("DstrTrim_31mer_out.histo", col.names = c("Cov", "mer31"))


#merge into 1 DF
#plot your fave
pdf(file="KmerFreq.pdf")
  plot(na.omit(DstrAll31[1:200,]), type="l",ylab="No. Kmer Classes", xlab="Coverage", main="31-mer Plot", log="y")
  abline(v=36, lty=2) #v line at peak, NOTE peak location on graph is != to coverage number
  text(x=200, y=3.0e+08,labels="Local max at 36x\n~2.0Gb Genome")
dev.off()

#get the genome size
sum(DstrAll31[1:5000,"Cov"]*DstrAll31[1:5000,"mer31"])/36 #truncated to reduce overflow and trim errors




