library("GenomicAlignments")
library("GenomicFeatures")
library("DESeq2")
library("BiocParallel")
library("UpSetR")
library("ggplot2")
library("cowplot")
theme_set(theme_cowplot())
library("lemon")
library("patchwork")


# Differential expression -------------------------------------------------
# Make results folder
setwd("6_DEGs/")
system("mkdir -p DESeq")

# Create a transcript database
DstrGenes <- tryCatch(readRDS("DESeq/DstrGenes.rds"),
	   error=function(e){
	   	   Dstrtxdb <- makeTxDbFromGFF("../5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/predict_results/Datura_stramonium.gff3", organism="Datura stramonium")
	   DstrGenes <- exonsBy(Dstrtxdb, by="tx", use.names=TRUE)
	   saveRDS(DstrGenes, "DESeq/DstrGenes.rds")
	   return(DstrGenes)
})

# Read in metadata
metadata <- read.table("DESeq/metadata.tsv", header=T)

# Produce list of files
DstrBamList <- BamFileList(as.character(metadata$Path), yieldSize=2000000)

# Count Reads
register(MulticoreParam(workers=16)) # or however many
register(SerialParam()) 
Expt_Dstr <- tryCatch(readRDS("DESeq/Expt_Dstr.rds"),
         error=function(e){
           Expt_Dstr <- summarizeOverlaps(features=DstrGenes,
                                  reads=DstrBamList,
                                  mode="Union",
                                  singleEnd=FALSE,
                                  ignore.strand=TRUE,
				  fragments=TRUE,
				  BPPARAM=SerialParam())
  colData(Expt_Dstr) <- DataFrame(metadata)
  saveRDS(Expt_Dstr, "DESeq/Expt_Dstr.rds")
  return(Expt_Dstr)
})

# Make DDS and Call DEGS
DDS_Dstr <- tryCatch(readRDS("DESeq/DDS_Dstr.rds"),
	 error=function(e){
	 DDS_Dstr <- DESeqDataSetFromMatrix(countData = assays(Expt_Dstr)$counts,
                                    colData = colData(Expt_Dstr),
                                    design = ~ Genotype)
	 DDS_Dstr <- estimateSizeFactors(DDS_Dstr)
	 DDS_Dstr <- DESeq(DDS_Dstr, test="LRT", reduced = ~ 1)
	 saveRDS(DDS_Dstr, "DESeq/DDS_Dstr.rds")
	 return(DDS_Dstr)
	 })

# Filter significant DEGs
Results_Dstr <- results(DDS_Dstr, contrast = c("Genotype", "GFP", "WT")) #WT is reference
ResultsSig_Dstr <- subset(Results_Dstr, (padj < 0.01 & abs(log2FoldChange) >2))
plotCounts(DDS_Dstr,
           gene = rownames(ResultsSig_Dstr)[which.min(ResultsSig_Dstr$padj)],
           intgroup = "Genotype") #-lfc = lower in GFP
write.table(ResultsSig_Dstr, "DESeq/Result_DEGs.tsv", quote=F, row.names=T, sep="\t")
write.table(rownames(ResultsSig_Dstr[ResultsSig_Dstr$log2FoldChange>0,]),
            file="DESeq/Result_Up.tsv",
            quote=F,
            row.names = F,
            col.names = F)
write.table(rownames(ResultsSig_Dstr[ResultsSig_Dstr$log2FoldChange<0,]),
            file="DESeq/Result_Down.tsv",
            quote=F,
            row.names = F,
            col.names = F)


# TE Correlation ----------------------------------------------------------
# Code to make the input files
#grep -P "gene\t" ../5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/annotate_results/Datura_stramonium.gff3 | sort -k1,1 -k4,4n > Datura_stramonium.genes.gff3
# Get the closest TE including inside the gene
#bedtools closest -D a -a Datura_stramonium.genes.gff3 -b Dstr_v1.7.fa.mod.EDTA.TEanno.sort.gff > Nearest_TE.tsv
# Get the nearest external TE
#bedtools closest -D a -io -a Datura_stramonium.genes.gff3 -b Dstr_v1.7.fa.mod.EDTA.TEanno.sort.gff > Nearbyest_TE.tsv
TEConversion <- c("DNA/DTA"="DTA",
                  "DNA/DTC"="DTC",
                  "DNA/DTH"="DTH",
                  "DNA/DTM"="DTM",
                  "DNA/DTT"="DTT",
                  "DNA/Helitron"="DHH",
                  "LINE/unknown"="RIX",
                  "LTR/Copia"="RLC",
                  "LTR/Gypsy"="RLG",
                  "LTR/unknown"="RLX",
                  "MITE/DTA"="DTA",
                  "MITE/DTC"="DTC",
                  "MITE/DTM"= "DTM",
                  "MITE/DTT"="DTT",
                  "TIR/PIF_Harbinger"="DTH",
                  "Unknown"="XXX")

# Read in a list of distance to nearest TE for each gene and combine them
TEDist <- read.csv("../4_EDTA/Nearest_TE.tsv", sep="\t", header=F)
TEDist$Method <- "With_Internal"
TEDist2 <- read.csv("../4_EDTA/Nearbyest_TE.tsv", sep="\t", header=F)
TEDist2$Method <- "Only_External"
TEDist <- rbind(TEDist, TEDist2)
rm(TEDist2)
TEDist <- TEDist[,c(9,12:14,18,19,20)]
TEDist$V12 <- as.character(TEConversion[TEDist$V12])
TEDist <- TEDist[!is.na(TEDist$TEAbbrev),]
TEDist$V9 <- gsub(";.*","",gsub("ID=","",TEDist$V9))
TEDist$AbsDis <- abs(TEDist$V19)
names(TEDist) <- c("GeneName", "TEAbbrev", "Start", "Stop", "ID", "Distance", "Method", "AbsDis")

# Add the TE data to the DEG data frame
TE_v_DEG <- as.data.frame(ResultsSig_Dstr)
rownames(TE_v_DEG) <- strtrim(rownames(TE_v_DEG),12)
TE_v_DEG <- merge(TEDist, 
             TE_v_DEG,
             by.x="GeneName", 
             by.y=0,
             all.y=T)

# Examine with/without internal TEs, no categories
summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External",]))
summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal",]))
summary(lm(log2FoldChange~Distance*Method, data=TE_v_DEG[TE_v_DEG$AbsDis<5000,]))
ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000,], 
       aes(x=Distance, y=log2FoldChange)) +
  geom_point() +
  labs(y="log2 Fold Change",
       x="Distance to Nearest TE") +
  facet_rep_wrap(~Method,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

# Examine with/without internal TEs, with categories
TE_lm <- data.frame(matrix(nrow=length(unique(TEConversion))+1, ncol=18),
                    row.names = c(unique(TEConversion), "All"))
# Iterate over all classes of TEs
for (TE in unique(TEConversion)) {
  TE_lm[TE,1] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,2] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,3] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,4] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,5] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,6] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,7] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,8] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,9] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,10] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,11] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,12] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,13] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,14] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,15] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm[TE,16] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm[TE,17] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm[TE,18] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev==TE & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  # Repeat without superfamilies
  TE_lm["All",1] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External",]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",2] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal",]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",3] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="Only_External",]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",4] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="With_Internal",]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",5] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External",]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",6] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal",]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",7] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",8] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",9] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                          error=function(e){"NaN"})
  TE_lm["All",10] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm["All",11] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm["All",12] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$log2FoldChange>0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm["All",13] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm["All",14] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm["All",15] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm["All",16] <- tryCatch(round(summary(lm(log2FoldChange~Distance, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Distance<0 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm["All",17] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  TE_lm["All",18] <- tryCatch(round(summary(lm(log2FoldChange~AbsDis, data=TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$log2FoldChange<0,]))$coefficients[2,4],4),
                           error=function(e){"NaN"})
  
}
colnames(TE_lm) <- c("Ext","Both", "Ext_Upstream", "Both_Upstream", "Ext_AbsDis", "Both_AbsDis", "Ext_UP", "Both_UP", "Ext_Upstream_UP", "Both_Upstream_UP", "Ext_AbsDis_UP", "Both_AbsDis_UP", "Ext_DOWN", "Both_DOWN", "Ext_Upstream_DOWN", "Both_Upstream_DOWN", "Ext_AbsDis_DOWN", "Both_AbsDis_DOWN")
TE_lm[TE_lm>=0.05] <- NA

# Plot significant regressions from the above table
# 1
p1 <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev=="DTM",], 
       aes(x=Distance, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Signed Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

# 2
p2 <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev=="DTH",], 
       aes(x=AbsDis, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Absolute Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

# 3
p3a <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev=="DTH" & TE_v_DEG$log2FoldChange>0,], 
       aes(x=Distance, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Signed Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

p3b <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev=="DTM" & TE_v_DEG$log2FoldChange>0,], 
              aes(x=Distance, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Signed Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

p3c <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="Only_External" & TE_v_DEG$TEAbbrev=="DTT" & TE_v_DEG$log2FoldChange>0,], 
              aes(x=Distance, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Signed Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

# 4
p4 <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev=="DTM" & TE_v_DEG$log2FoldChange>0,], 
       aes(x=Distance, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Signed Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

# 5
p5 <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev=="DTM" & TE_v_DEG$log2FoldChange>0,], 
       aes(x=AbsDis, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Absolute Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

# 6
p6a <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev=="DTC" & TE_v_DEG$log2FoldChange<0,], 
       aes(x=Distance, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Signed Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

p6b <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" &  TE_v_DEG$TEAbbrev=="XXX" & TE_v_DEG$log2FoldChange<0,], 
             aes(x=Distance, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Signed Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

# 7
p7a <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev=="DTA" & TE_v_DEG$log2FoldChange<0,], 
             aes(x=AbsDis, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Absolute Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')
p7b <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev=="DTC"  & TE_v_DEG$log2FoldChange<0,], 
             aes(x=AbsDis, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Absolute Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')
p7c <- ggplot(TE_v_DEG[TE_v_DEG$AbsDis<5000 & TE_v_DEG$Method=="With_Internal" & TE_v_DEG$TEAbbrev=="XXX" & TE_v_DEG$log2FoldChange<0,], 
             aes(x=AbsDis, y=log2FoldChange)) +
  geom_point() +
  labs(y=expression(Log[2]~Fold~Change),
       x="Absolute Distance to Nearest TE") +
  facet_rep_wrap(~TEAbbrev,
                 scales = "free") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust=0.5),
        strip.background = element_rect(fill="#FFFFFF")) +
  geom_smooth(method='lm')

p1 + p3b + p4 + p5 + p3a + p2 + p7b + p6a + p6b + p7c + p7a + p3c 

# Plot absolute distance to show pattern
p7a + p7b + p5 + p7c +
  plot_layout(nrow=4) +
  plot_annotation(tag_levels = "A")
ggsave2("../Manuscript/TEDistance_v_DEG.pdf", width=6, height=20)

# Variant Correlation -----------------------------------------------------
variants <- read.table("../6_SNP_SV/results/Summary/snpEff_Summary.genes.txt",
                       skip=1,
                       comment.char = "",
                       header=T)
DEG_variants <- merge(variants,tmp,
      by.x="GeneId",
      by.y="GeneName",
      all.y=T)
#.....hypergeometric test to see if DEGs are enriched for variants? BY CLASS (will need loop)
 # Set up hypergeometric test
 ## q: Genes with given domain that are in the top set are the white balls drawn from the urn.
 ## m: Genes with given domain are white balls.
 ## n: Genes without given domain are black balls.
 ## k: The balls drawn are the genes in the top set.
 p_value_vector = c() 
 enrichment_vector = c() 
 q_vector = c()
 m_vector = c()
 for (i in grep("variants", names(DEG_variants))) {
 # Do hypergeometric test
   q = sum(variants$GeneId[variants[,i]>0] %in% tmp$GeneName)
   m = dim(variants[variants[,i]>0,])[1]
   n = dim(DDS_Dstr)[1] - m
   k = dim(ResultsSig_Dstr)[1]
   p_value = phyper(q - 1, m, n, k, lower.tail = FALSE) 
   p_value_vector[i] = p_value
   enrichment = q/(m*k/(n+m)) 
   enrichment_vector[i] = enrichment 
   q_vector[i] = q
   m_vector[i] = m
 }
# Clean out the columns that arent significant
variants_hypergeom <- as.data.frame(cbind(Hypergeom_pval=p_value_vector, Enrichment=enrichment_vector, q=q_vector, m=m_vector))
variants_hypergeom <- variants_hypergeom[-c(1:(min(grep("variants", names(DEG_variants)))-1)),]
rownames(variants_hypergeom) <- names(DEG_variants)[grep("variants", names(DEG_variants))]
variants_hypergeom <- variants_hypergeom[variants_hypergeom$Hypergeom_pval<0.05,]

# Is a linear regression of variant number and LFC significant?
for (i in 1:length(variants_hypergeom)) {
  variants_hypergeom$linear_pval[i] <- summary(lm(DEG_variants$log2FoldChange~DEG_variants[,row.names(variants_hypergeom)[i]]))$coefficients[2,4]
  variants_hypergeom$binary_pval[i] <- summary(lm(DEG_variants$log2FoldChange~DEG_variants[,row.names(variants_hypergeom)[i]]>0))$coefficients[2,4]
}

# Intersect DEGs, TEs and SNPs --------------------------------------------
DEG_Up <- list(as.data.frame(unique(strtrim(rownames(ResultsSig_Dstr[ResultsSig_Dstr$log2FoldChange>0,]),12))))
DEG_Down <- list(as.data.frame(unique(strtrim(rownames(ResultsSig_Dstr[ResultsSig_Dstr$log2FoldChange<0,]),12))))
TE_Internal <- list(as.data.frame(unique(TEDist[TEDist$AbsDis==0,"GeneName"])))
TE_External <- list(as.data.frame(unique(TEDist[TEDist$AbsDis<5000 & TEDist$Method=="Only_External","GeneName"])))
VAR_All <- list(as.data.frame(unique(variants$GeneId)))
VAR_High <- list(as.data.frame(unique(variants$GeneId[variants[,5]>0])))
VAR_Moder <- list(as.data.frame(unique(variants$GeneId[variants[,7]>0])))
VAR_Low <- list(as.data.frame(unique(variants$GeneId[variants[,6]>0])))
VAR_Modif <- list(as.data.frame(unique(variants$GeneId[variants[,8]>0])))
VAR_Coding <- list(as.data.frame(unique(variants$GeneId[variants[,5]>0 | variants[,6]>0 | variants[,7]>0])))

List_genes <- Map(list,
                  DEG_Up, DEG_Down, TE_Internal, TE_5kbUpstream, VAR_All, VAR_High, VAR_Moder, VAR_Low, VAR_Modif, VAR_Coding)
Gene_List <- as.data.frame(unique(unlist(List_genes)))
for (GeneTable in c(DEG_Up, DEG_Down, TE_Internal, TE_External, VAR_All, VAR_High, VAR_Moder, VAR_Low, VAR_Modif, VAR_Coding)) {
  Common<-as.data.frame(Gene_List[,1] %in% as.data.frame(GeneTable)[,1])
  Common[,1][Common[,1]==TRUE]<- 1
  Gene_List<-cbind(Gene_List,Common)
}
colnames(Gene_List) <- c("ID","Upregulated", "Downregulated", "TE_Internal", "Proximal Transposon","VAR_All", "VAR_High", "VAR_Moder", "VAR_Low", "Non-coding Variant", "Coding Variant")
pdf(file = "../Manuscript/Upset.pdf", width=10, height=6)
png(file = "../Manuscript/Upset.png", width=1000, height=600)
upset(Gene_List, 
      sets = colnames(Gene_List)[-c(1,4,5,6:9)],
      mainbar.y.label = "Number of Genes", 
      sets.x.label = NULL, 
      keep.order = F,
      text.scale = 1.5,
      point.size = 3, 
      line.size = 1,
      nintersects = 1000)
dev.off()





