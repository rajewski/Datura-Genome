library("GenomicAlignments")
library("Rsamtools")
library("GenomicFeatures")
library("DESeq2")
library(BiocParallel)

# Make results folder
system("mkdir -p DESeq")

# Create a transcript database
DstrGenes <- tryCatch(readRDS("DESeq/DstrGenes.rds"),
	   error=function(e){
	   	   Dstrtxdb <- makeTxDbFromGFF("../5_Funannotate/Dstr_v1.7_Annotation/predict_results/Datura_stramonium.gff3", organism="Datura stramonium")
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
Results_Dstr <- results(DDS_Dstr)
ResultsSig_Dstr <- subset(Results_Dstr, padj < 0.05)
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



# to hone in on the proximal TE genes, consider making a new txdb object with only certain classes of genes, OR try to pull out rows of the Assay(counts), maybe add the proximinallnes to the design matrix somehow??

# ORRRRRR  ignore it and then do a hypergeometric test to see if the proximal TE genes are enriched in the set of DEGs!!