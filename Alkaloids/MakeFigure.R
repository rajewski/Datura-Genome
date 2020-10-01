library(phytools)
source("~/bigdata/FULTranscriptomes/X_Functions.R")
library(ggplot2)
library(cowplot)
theme_set(theme_cowplot())

# Summarize Genes ---------------------------------------------------------
setwd("Alkaloids/")
DstrGenes <- readRDS("../6_DEGs/DESeq/DstrGenes.rds")

intron_size <- tryCatch(read.table("intron_size.txt")$V1,error=function(e){
  intron_size <- c()
  # I can't find a way to do this without a loop. It takes forever...
  for ( i in 1:length(DstrGenes)) {
    if(length(gaps(DstrGenes[[i]]))>1) {
      intron_size <- c(intron_size, width(gaps(DstrGenes[[i]])[2:length(gaps(DstrGenes[[i]]))]))
    }
  }
  write.table(intron_size, file = "../Manuscript/intron_size.txt", row.names = F, quote = F, col.names = F)
  return(intron_size)
})
exon_num <- as.data.frame(cbind(strtrim(DstrGenes@unlistData@elementMetadata@listData[["exon_name"]],15), DstrGenes@unlistData@elementMetadata@listData[["exon_rank"]]))
exon_num <- as.integer(aggregate(as.integer(exon_num$V2), by=list(exon_num$V1), FUN=max)$x)
exon_size <- DstrGenes@unlistData@ranges@width
cds_size <- as.data.frame(cbind(strtrim(DstrGenes@unlistData@elementMetadata@listData[["exon_name"]],15),
                                DstrGenes@unlistData@ranges@width))
cds_size <- aggregate(as.numeric(cds_size$V2), by=list(cds_size$V1), FUN=sum)$x

# Get summaries of each
summary(cds_size)
summary(exon_num)
summary(exon_size)
summary(intron_num)
summary(intron_size)

# Plot Densities of feature sizes
max_num=1500
plot(density(exon_size), 
     main="Gene Feature Sizes",
     yaxt="n",
     ylab="",
     xlab="Length (bp)",
     xlim=c(0,max_num))
lines(density(cds_size),col="red")
lines(density(intron_size), col="purple")
legend("topright", legend=c("Exon Length", "CDS Length", "Intron Length"),
       col=c("black", "red", "purple"),
       lty=1,
       cex=0.8,
       bty = "n")


# Assemble Orthogroup Plots ----------------------------------------------
of_species <- read.newick("Orthologies/OrthoFinder/Results_Sep28/Gene_Duplication_Events/SpeciesTree_Gene_Duplications_0.5_Support.txt")
of_species <- reroot(of_species, interactive = T) # im tired and its easier for a figure
plotTree(of_species, node.numbers=T)
of_species <- rotateNodes(of_species, nodes=c(15,18,21))
of_species$tip.label <- c("A. coerulea", "A. officinalis", "O. sativa", "Z. mays",
                          "A. thaliana", "G. max", "V. vinifera", "L. sativa",
                          "H. annuus", "P. axillaris", "N. attenuata", "C. annuum",
                          "S. lycopersicum", "D. stramonium")
plotTree(of_species)


# GO Plots ----------------------------------------------------------------
duplications <- read.table("Orthologies/OrthoFinder/Results_Sep28/Gene_Duplication_Events/Duplications.tsv", header=T, sep="\t")
#make symlinks to GO tables in the ExternalData directory first
speciesGO <- list()
i=1
for (spAbbr in c("Dstr", "Slyc", "Atha")) {
  Specific <- duplications[duplications$Species.Tree.Node==spAbbr,]
  Genes <- paste(Specific$Genes.1, collapse = ", ")
  Genes1 <- paste(Specific$Genes.2, collapse = ", ")
  Genes <- as.data.frame(strsplit(Genes, ", "))
  Genes1 <- as.data.frame(strsplit(Genes1, ", "))
  names(Genes) <- "GeneName"
  names(Genes1) <- "GeneName"
  Genes <- rbind(Genes, Genes1)
  Genes <- unique(Genes)
  Genes$GeneName <- gsub(paste0(spAbbr,"_"), "", Genes$GeneName)
  write.table(Genes, file=paste0("./",spAbbr, "Specific.tsv"), quote = F, row.names = F, col.names = F)
  speciesGO[[i]] <- GOEnrich(GOIs = paste0("./",spAbbr, "Specific.tsv"), 
                             gene2go = paste0("ExternalData/", spAbbr, ".genes2go.tsv"),
                             NumCategories = 40)
  i=i+1
}

GOPlot(speciesGO[[1]], Title="D. stramonium GO Enrichment")
GOPlot(speciesGO[[2]], Title="S. lycopersicum GO Enrichment")
GOPlot(speciesGO[[3]], Title="A. thaliana GO Enrichment")

# Gene Trees --------------------------------------------------------------
of_tropinone <- read.newick("Orthologies/OrthoFinder/Results_Sep28/Resolved_Gene_Trees/OG0000081_tree.txt")
findMRCA(of_tropinone, c("Cann_CA05g12020", "Natt_NIATv7_g04127.t1"))
of_TRI <- extract.clade(of_tropinone, node=302)
of_TRI$tip.label <- c("NIATv7_g04127","Peaxi162Scf00564g00516","CA05g12020",
                      "Solyc04g007400","HAX54_003045","HAX54_027976")
plot(of_TRI, underscore=T)

findMRCA(of_tropinone, c("Dstr_HAX54_008481-T1", "Natt_NIATv7_g64838.t1"))
of_TRII <- extract.clade(of_tropinone, node=307)
of_TRII$tip.label <- c("HAX54_008481","HAX54_047488","Solyc10g081560",
                       "CA10g18210","NIATv7_g05545","NIATv7_g64838")
plot(of_TRII, underscore=T)
