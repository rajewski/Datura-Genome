library(phytools)
source("~/bigdata/Datura/X_Functions.R")
library(ggplot2)
library(cowplot)
theme_set(theme_cowplot())
library(patchwork)
library(reshape2)
library(ggtree)
library(gt)
library(ggridges)
library(tidyverse)


# Summarize Genes ---------------------------------------------------------
setwd("Alkaloids/")
DstrGenes <- readRDS("../6_DEGs/DESeq/DstrGenes.rds")

intron_size <- tryCatch(read.table("../Alkaloids/intron_size.txt")$V1,error=function(e){
  intron_size <- c()
  # I can't find a way to do this without a loop. It takes forever...
  for ( i in 1:length(DstrGenes)) {
    if(length(gaps(DstrGenes[[i]]))>1) {
      intron_size <- c(intron_size, width(gaps(DstrGenes[[i]])[2:length(gaps(DstrGenes[[i]]))]))
    }
  }
  write.table(intron_size, file = "../Manuscript/intron_size_slyc.txt", row.names = F, quote = F, col.names = F)
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
summary(intron_size)

# Plot Densities of feature sizes
max_num=1500
gene_stats <- list(Exons=exon_size,Introns=intron_size,CDS=cds_size)
gene_stats_plotting <- melt(gene_stats)
p1 <- ggplot(gene_stats_plotting[gene_stats_plotting$value <= max_num,], aes(x=value, fill=L1)) + 
  geom_density(alpha=0.60) +
  labs(y=NULL, x="Length (bp)") +
  scale_fill_manual(values=c("#5d3f6aff", "#87868140", "white")) +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        legend.title = element_blank(),
        legend.position=c(0.8,0.8),
        plot.title = element_text(hjust = 0.5,
                                  face="plain",
                                  size=25)) +
  ggtitle(bquote(paste(italic("D. stramonium "),"Gene Feature Sizes")))

# Compare to tomato
SlycGenes <- readRDS("../../FULTranscriptomes/DEGAnalysis/RNA-seq/Slycgenes.rds") #test with Slyc genes
intron_size_slyc <- tryCatch(read.table("../Manuscript/intron_size_slyc.txt")$V1,error=function(e){
  intron_size_slyc <- c()
  # I can't find a way to do this without a loop. It takes forever...
  for ( i in 1:length(SlycGenes)) {
    if(length(gaps(DstrGenes[[i]]))>1) {
      intron_size_slyc <- c(intron_size_slyc, width(gaps(SlycGenes[[i]])[2:length(gaps(SlycGenes[[i]]))]))
    }
  }
  write.table(intron_size_slyc, file = "../Manuscript/intron_size_slyc.txt", row.names = F, quote = F, col.names = F)
  return(intron_size_slyc)
})
exon_num_slyc <- as.data.frame(cbind(strtrim(SlycGenes@unlistData@elementMetadata@listData[["exon_name"]],15), SlycGenes@unlistData@elementMetadata@listData[["exon_rank"]]))
exon_num_slyc <- as.integer(aggregate(as.integer(exon_num_slyc$V2), by=list(exon_num_slyc$V1), FUN=max)$x)
exon_size_slyc <- SlycGenes@unlistData@ranges@width
cds_size_slyc <- as.data.frame(cbind(strtrim(SlycGenes@unlistData@elementMetadata@listData[["exon_name"]],15),
                                SlycGenes@unlistData@ranges@width))
cds_size_slyc <- aggregate(as.numeric(cds_size_slyc$V2), by=list(cds_size_slyc$V1), FUN=sum)$x
  
gene_stats_slyc <- list(Exons=exon_size_slyc,Introns=intron_size_slyc,CDS=cds_size_slyc)
gene_stats_slyc_plotting <- melt(gene_stats_slyc)
p2 <- ggplot(gene_stats_slyc_plotting[gene_stats_slyc_plotting$value <= max_num,], aes(x=value, fill=L1)) + 
  geom_density(alpha=0.60) +
  labs(y=NULL, x="Length (bp)") +
  scale_fill_manual(values=c("#b21807ff", "#87868140", "white")) +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        legend.title = element_blank(),
        legend.position=c(0.8,0.8),
        plot.title = element_text(hjust = 0.5,
                                  face="plain",
                                  size=25)) +
  ggtitle(bquote(paste(italic("S. lycopersicum "),"Gene Feature Sizes")))


# Orthogroup Plots ----------------------------------------------
of_species <- read.tree("Orthologies/OrthoFinder/Results_Sep28/Species_Tree/SpeciesTree_rooted.txt")
of_species <- reroot(of_species, 4, position=0.1)
of_species <- rotateNodes(of_species, nodes=c(15,18,21))
plotTree(of_species, node.numbers=T, tip.numbers=T)
of_species$tip.label <- c(expression(paste(italic("A. coerulea"))),
                          expression(paste(italic("A. officinalis"))),
                          expression(paste(italic("O. sativa"))),
                          expression(paste(italic("Z. mays"))),
                          expression(paste(italic("A. thaliana"))),
                          expression(paste(italic("G. max"))),
                          expression(paste(italic("V. vinifera"))),
                          expression(paste(italic("L. sativa"))),
                          expression(paste(italic("H. annuus"))),
                          expression(paste(italic("P. axillaris"))),
                          expression(paste(italic("N. attenuata"))),
                          expression(paste(italic("C. annuum"))),
                          expression(paste(italic("S. lycopersicum"))),
                          expression(paste(italic("D. stramonium"))))
# Pretty up the support values
#of_species$node.label[1] <- ""
of_species$node.label <- as.numeric(of_species$node.label)*100
of_species$node.label <- round(as.numeric(of_species$node.label),0)
of_species$tip.label <- c(expression(paste(italic("A. coerulea"))),
                          expression(paste(italic("A. officinalis"))),
                          expression(paste(italic("O. sativa"))),
                          expression(paste(italic("Z. mays"))),
                          expression(paste(italic("A. thaliana"))),
                          expression(paste(italic("G. max"))),
                          expression(paste(italic("V. vinifera"))),
                          expression(paste(italic("L. sativa"))),
                          expression(paste(italic("H. annuus"))),
                          expression(paste(italic("P. axillaris"))),
                          expression(paste(italic("N. attenuata"))),
                          expression(paste(italic("C. annuum"))),
                          expression(paste(italic("S. lycopersicum"))),
                          expression(paste(italic("D. stramonium"))))
t1 <- ggtree(of_species) + 
  geom_tiplab(label=of_species$tip.label,
              size=10) +
  ggplot2::xlim(0,0.8) +
  geom_text2(aes(subset = !isTip & !is.na(label),
                 label=label, 
                 vjust=-0.5,
                 hjust=1.1)) +
  geom_cladelabel(node=23, label="Solanoideae", align=TRUE, hjust=0.5, 
                  extend=0.5, fontsize = 5, offset.text = 0.005,
                  angle=90, barsize = 1.5, offset = .14, color='black') +
  theme(plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25)) +
  ggtitle("OrthoFinder2 Species Tree")

# Tree without Soybeans
of_species2 <- read.tree("Orthologies/OrthoFinder/Results_Sep28/WorkingDirectory/OrthoFinder/Results_Oct26_2/Species_Tree/SpeciesTree_rooted.txt")
of_species2 <- reroot(of_species2, 4, position=0.1)
plotTree(of_species2, node.numbers=T, tip.numbers=T)
of_species2$tip.label <- c(expression(paste(italic("A. officinalis"))),
                           expression(paste(italic("Z. mays"))),
                           expression(paste(italic("O. sativa"))),
                           expression(paste(italic("A. coerulea"))),
                           expression(paste(italic("A. thaliana"))),
                           expression(paste(italic("V. vinifera"))),
                           expression(paste(italic("H. annuus"))),
                           expression(paste(italic("L. sativa"))),
                           expression(paste(italic("N. attenuata"))),
                           expression(paste(italic("C. annuum"))),
                           expression(paste(italic("S. lycopersicum"))),
                           expression(paste(italic("D. stramonium"))),
                           expression(paste(italic("P. axillaris"))))
# Get support
of_species2$node.label <- as.numeric(of_species2$node.label)*100
of_species2$node.label <- round(as.numeric(of_species2$node.label),0)
t6 <- ggtree(of_species2) + 
  geom_tiplab(label=of_species2$tip.label,
              size=10) +
  ggplot2::xlim(0,0.9) +
  geom_text2(aes(subset = !isTip & !is.na(label),
                 label=label, 
                 vjust=-0.5,
                 hjust=1.1)) +
  geom_cladelabel(node=23, label="Solanoideae", align=TRUE, hjust=0.5, 
                  extend=0.5, fontsize = 5, offset.text = 0.005,
                  angle=90, barsize = 1.5, offset = .2, color='black') +
  theme(plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25)) +
  ggtitle("OrthoFinder2 Species Tree")
  

# Orthogroup Table ---------------------------------------------------------
#system("PATH=/bigdata/littlab/arajewski/Datura/software/phantomjs-2.1.1-linux-x86_64/bin:$PATH")
LSDE <- read.table("../Alkaloids/Orthologies/OrthoFinder/Results_Sep28/Comparative_Genomics_Statistics/Duplications_per_Species_Tree_Node.tsv",
                   header=T,
                   sep="\t")
ortho_table <- read.table("../Alkaloids/Orthologies/OrthoFinder/Results_Sep28/Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv",
                          header = T,
                          nrows = 10,
                          sep="\t")
ortho_table <- as.data.frame(t(ortho_table))
names(ortho_table) <- ortho_table[1,]
ortho_table <- ortho_table[-1,-c(6:8)]
ortho_table[,c(1:3,6)] <- apply(ortho_table[,c(1:3,6)], 2, as.integer)  
ortho_table[,c(4,5,7)] <- apply(ortho_table[,c(4,5,7)], 2, as.numeric)
LSDE <- LSDE[LSDE$Species.Tree.Node %in% row.names(ortho_table),]
ortho_table <- merge(LSDE, ortho_table, by.x="Species.Tree.Node", by.y=0)[,c(4,3,5:10)]
row.names(ortho_table)<- c("A. coerulea",
                           "A. officinalis",
                           "A. thaliana",
                           "C. annuum",
                           "D. stramonium",
                           "G. max",
                           "H. annuus",
                           "L. sativa",
                           "N. attenuata",
                           "O. sativa",
                           "P. axillaris",
                           "S. lycopersicum",
                           "V. vinifera",
                           "Z. mays")

ortho_table %>%
  gt(
    rownames_to_stub = T
  ) %>%
  tab_style(
    location = cells_stub(),
    style = list(
      cell_text(style="italic"))
  ) %>%
  fmt_number(
    columns = vars(`Number of genes`, `Number of genes in orthogroups`, `Number of unassigned genes`, `Number of genes in species-specific orthogroups`, `Duplications..50..support.`),
    decimals=0,
    sep_mark = ","
  ) %>%
  cols_merge(
    columns = vars(`Number of genes in orthogroups`, `Percentage of genes in orthogroups`),
    hide_columns = vars(`Percentage of genes in orthogroups`),
    pattern = "{1}</br>({2}%)"
  ) %>%
  cols_merge(
    columns = vars(`Number of unassigned genes`, `Percentage of unassigned genes`),
    hide_columns = vars(`Percentage of unassigned genes`),
    pattern = "{1}</br>({2}%)"
  ) %>%
  cols_merge(
    columns = vars(`Number of genes in species-specific orthogroups`, `Percentage of genes in species-specific orthogroups`),
    hide_columns = vars(`Percentage of genes in species-specific orthogroups`),
    pattern = "{1}</br>({2}%)"
  ) %>%
  tab_spanner(
    label=md("**Orthofinder Genes**"),
    columns = vars(`Number of genes in orthogroups`, `Number of unassigned genes`, `Number of genes in species-specific orthogroups`)
  )  %>%
  cols_label(
    `Number of genes in orthogroups` = md("Assigned</br>Orthogroup"),
    `Number of unassigned genes` = md("Unassigned"),
    `Number of genes in species-specific orthogroups` = md("Lineage-specific"),
    `Duplications..50..support.` = md("Lineage-specific</br>Gene Duplication Events") 
  ) %>%
  gtsave("../Manuscript/Orthofinder.html")

# Orthogroup table (No Soy) -----------------------------------------------------
LSDE_2 <- read.table("../Alkaloids/Orthologies/OrthoFinder/Results_Sep28/WorkingDirectory/OrthoFinder/Results_Oct26_2/Comparative_Genomics_Statistics/Duplications_per_Species_Tree_Node.tsv",
                   header=T,
                   sep="\t")
ortho_table_2 <- read.table("../Alkaloids/Orthologies/OrthoFinder/Results_Sep28/WorkingDirectory/OrthoFinder/Results_Oct26_2/Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv",
                          header = T,
                          nrows = 10,
                          sep="\t")
ortho_table_2 <- as.data.frame(t(ortho_table_2))
names(ortho_table_2) <- ortho_table_2[1,]
ortho_table_2 <- ortho_table_2[-1,-c(6:8)]
ortho_table_2[,c(1:3,6)] <- apply(ortho_table_2[,c(1:3,6)], 2, as.integer)  
ortho_table_2[,c(4,5,7)] <- apply(ortho_table_2[,c(4,5,7)], 2, as.numeric)
LSDE_2 <- LSDE_2[LSDE_2$Species.Tree.Node %in% row.names(ortho_table_2),]
ortho_table_2 <- merge(LSDE_2, ortho_table_2, by.x="Species.Tree.Node", by.y=0)[,c(4,3,5:10)]
row.names(ortho_table_2)<- c("A. coerulea",
                           "A. officinalis",
                           "A. thaliana",
                           "C. annuum",
                           "D. stramonium",
                           "H. annuus",
                           "L. sativa",
                           "N. attenuata",
                           "O. sativa",
                           "P. axillaris",
                           "S. lycopersicum",
                           "V. vinifera",
                           "Z. mays")

ortho_table_2 %>%
  gt(
    rownames_to_stub = T
  ) %>%
  tab_style(
    location = cells_stub(),
    style = list(
      cell_text(style="italic"))
  ) %>%
  fmt_number(
    columns = vars(`Number of genes`, `Number of genes in orthogroups`, `Number of unassigned genes`, `Number of genes in species-specific orthogroups`, `Duplications..50..support.`),
    decimals=0,
    sep_mark = ","
  ) %>%
  cols_merge(
    columns = vars(`Number of genes in orthogroups`, `Percentage of genes in orthogroups`),
    hide_columns = vars(`Percentage of genes in orthogroups`),
    pattern = "{1}</br>({2}%)"
  ) %>%
  cols_merge(
    columns = vars(`Number of unassigned genes`, `Percentage of unassigned genes`),
    hide_columns = vars(`Percentage of unassigned genes`),
    pattern = "{1}</br>({2}%)"
  ) %>%
  cols_merge(
    columns = vars(`Number of genes in species-specific orthogroups`, `Percentage of genes in species-specific orthogroups`),
    hide_columns = vars(`Percentage of genes in species-specific orthogroups`),
    pattern = "{1}</br>({2}%)"
  ) %>%
  tab_spanner(
    label=md("**Orthofinder Genes**"),
    columns = vars(`Number of genes in orthogroups`, `Number of unassigned genes`, `Number of genes in species-specific orthogroups`)
  )  %>%
  cols_label(
    `Number of genes in orthogroups` = md("Assigned</br>Orthogroup"),
    `Number of unassigned genes` = md("Unassigned"),
    `Number of genes in species-specific orthogroups` = md("Lineage-specific"),
    `Duplications..50..support.` = md("Lineage-specific</br>Gene Duplication Events") 
  ) %>%
  #gtsave("../Manuscript/Orthofinder_NoSoy.pdf")
gtsave("../Manuscript/Orthofinder_NoSoy.png")

# GO Plots ----------------------------------------------------------------
duplications <- read.table("Orthologies/OrthoFinder/Results_Sep28/Gene_Duplication_Events/Duplications.tsv", header=T, sep="\t")
#make symlinks to GO tables in the ExternalData directory first
speciesGO <- list()
i=1
for (spAbbr in c("Dstr", "Slyc")) {
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
                             NumCategories = 20)
  i=i+1
}

g1 <- GOPlot(speciesGO[[1]], 
             Title=expression(paste(italic("D. stramonium")," GO Enrichment")))
g2 <- GOPlot(speciesGO[[2]], 
             Title=expression(paste(italic("S. lycopersicum"), " GO Enrichment")),
             colorHex = "#b2180799")

# Gene Trees --------------------------------------------------------------
of_tropinone <- read.newick("Orthologies/OrthoFinder/Results_Sep28/Resolved_Gene_Trees/OG0000081_tree.txt")
findMRCA(of_tropinone, c("Cann_CA05g12020", "Natt_NIATv7_g04127.t1"))
of_TRI <- extract.clade(of_tropinone, node=302)
of_TRI$tip.label <- c(expression(paste(italic("NIATv7_g04127"))),
                      expression(paste(italic("Peaxi162Scf00564g00516"))),
                      expression(paste(italic("CA05g12020"))),
                      expression(paste(italic("Solyc04g007400"))),
                      expression(paste(italic("HAX54_003045"))),
                      expression(paste(italic("HAX54_027976"))))
t2 <- ggtree(of_TRI) +
  geom_tiplab(label=of_TRI$tip.label,
              size=8) +
  ggplot2::xlim(0, 1.3)  +
  theme(plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25)) +
  ggtitle("Tropinone Reductase I")

findMRCA(of_tropinone, c("Dstr_HAX54_008481-T1", "Natt_NIATv7_g64838.t1"))
of_TRII <- extract.clade(of_tropinone, node=307)
of_TRII$tip.label <- c(expression(paste(italic("HAX54_008481"))),
                       expression(paste(italic("HAX54_047488"))),
                       expression(paste(italic("Solyc10g081560"))),
                       expression(paste(italic("CA10g18210"))),
                       expression(paste(italic("NIATv7_g05545"))),
                       expression(paste(italic("NIATv7_g64838"))))
of_TRII <- rotateNodes(of_TRII, nodes=8)
t3 <- ggtree(of_TRII) +
  geom_tiplab(label=of_TRII$tip.label,
              size=8) +
  ggplot2::xlim(0,0.3)  +
  theme(plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25)) +
  ggtitle("Tropinone Reductase II")

#rm_tropinone <- read.tree("TR/TR.aligned.fasta.raxml.support.converted")
rm_tropinone <- read.tree("TR/TR.aligned.fasta.raxml.support")
plotTree(rm_tropinone, node.numbers=F)
rm_tropinone <- rotateNodes(rm_tropinone, nodes=20)
rm_tropinone <- reroot(rm_tropinone, 20, position=0.1)

rm_tropinone$tip.label <- c(expression(paste(italic("HAX54_047488"))),
                            expression(paste(italic("HAX54_008481"))),
                            expression(paste(italic("CA10g18210"), " (TRI)")),
                            expression(paste(italic("Solyc10g081560"), " (TRI)")),
                            expression(paste(italic("NIATv7_g04127"))),
                            expression(paste(italic("NIATv7_g05545"))),
                            expression(paste(italic("NIATv7_g64838"))),
                            expression(paste(italic("CA05g12020"), " (TRII)")),
                            expression(paste(italic("Solyc04g007400"), " (TRII)")),
                            expression(paste(italic("HAX54_027976"))),
                            expression(paste(italic("Peaxi162Scf00564g00516"))),
                            expression(paste(italic("Aqcoe4G241800"), " (TRII-like)")),
                            expression(paste(italic("Aqcoe4G010900"), " (TRI-like)")))

rm_tropinone$node.label <- round(as.numeric(rm_tropinone$node.label),0)
t4 <- ggtree(rm_tropinone) +
  geom_tiplab(label=rm_tropinone$tip.label,
              size=8) +
  ggplot2::xlim(0,1.5)  +
  geom_text2(aes(subset = !isTip & !is.na(label),
                 label=label, 
                 vjust=-0.5,
                 hjust=1.1)) +
  theme(plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25)) +
  ggtitle("Tropinone Reductase")

rm_h6h <- read.newick("H6H/H6H.Curated.align.fasta.raxml.support")
plotTree(rm_h6h, node.numbers=T)
rm_h6h <- rotateNodes(rm_h6h, nodes=15)
rm_h6h$tip.label <- c(expression(paste(italic("Peaxi162Scf00141g00025"))),
                      expression(paste(italic("Peaxi162Scf00075g01545"), " (C-Term)")),
                      expression(paste(italic("Peaxi162Scf00075g01545"), " (N-Term)")),
                      expression(paste(italic("HAX54_051520"))),
                      expression(paste(italic("HAX54_051521"))),
                      expression(paste(italic("Solyc06g073580"))),
                      expression(paste(italic("Solyc11g072200"))),
                      expression(paste(italic("CA11g14590"))),
                      expression(paste(italic("CA11g16030"))),
                      expression(paste(italic("AT5G24530"))),
                      expression(paste(italic("Aqcoe4G163300"))))

#rm_h6h <- as.polytomy(rm_h6h, feature='node.label', fun=function(x) as.numeric(x) < 70)
rm_h6h$node.label[2] <- "100" #this gets dropped somehow

t5 <- flip(ggtree(rm_h6h),16, 17) +
  geom_tiplab(label=rm_h6h$tip.label,
              size=8) +
  ggplot2::xlim(0,3.3)  +
  geom_text2(aes(subset = !isTip & !is.na(label),
                 label=label, 
                 vjust=-0.5,
                 hjust=1.1)) +
  theme(plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25)) +
  ggtitle(expression(bold(paste("Hyoscyamine 6 ", beta,"-Hydroxylase"))))


# Ks Plots ----------------------------------------------------------------
# read in data
DstrKsd = read.csv("../Alkaloids/wgd_ksd/Datura_stramonium.proteins.fa.ks.tsv", sep="\t")
SlycKsd = read.csv("../Alkaloids/wgd_ksd/ITAG4.0_proteins.fasta.ks.tsv", sep="\t")
#VvinKsd = read.csv("../Alkaloids/wgd_ksd/Vvinifera_457_v2.1.protein_primaryTranscriptOnly.fa.ks.tsv", sep="\t")
#S_VKsd = read.csv("../Alkaloids/wgd_ksd/Sl_Vv_proteins.fasta.ks.tsv", sep="\t")
S_DKsd = read.csv("../Alkaloids/wgd_ksd/Sl_Ds_proteins.fasta.ks.tsv", sep="\t")

# filter Ks distribution (0.001 < Ks < 5) 
lower_bound = 0.001
upper_bound = 3
DstrKsd = DstrKsd[DstrKsd$Ks < upper_bound & DstrKsd$Ks > lower_bound,]
SlycKsd = SlycKsd[SlycKsd$Ks < upper_bound & SlycKsd$Ks > lower_bound,]
#VvinKsd = VvinKsd[VvinKsd$Ks < upper_bound & VvinKsd$Ks > lower_bound,]
#S_VKsd = S_VKsd[S_VKsd$Ks < upper_bound & S_VKsd$Ks > lower_bound,]
S_DKsd = S_DKsd[S_DKsd$Ks < upper_bound & S_DKsd$Ks > lower_bound,]

# perform node-averaging (redo when applying other filters)
DstrKsdAvg = aggregate(DstrKsd$Ks, list(DstrKsd$Family, DstrKsd$Node), mean)
SlycKsdAvg = aggregate(SlycKsd$Ks, list(SlycKsd$Family, SlycKsd$Node), mean)
#VvinKsdAvg = aggregate(VvinKsd$Ks, list(VvinKsd$Family, VvinKsd$Node), mean)
#S_VKsdAvg = aggregate(S_VKsd$Ks, list(S_VKsd$Family, S_VKsd$Node), mean)
S_DKsdAvg = aggregate(S_DKsd$Ks, list(S_DKsd$Family, S_DKsd$Node), mean)

# reflect the data around the lower Ks bound to account for boundary effects
Dstrks = c(DstrKsdAvg$x, -DstrKsdAvg$x + lower_bound)
Slycks = c(SlycKsdAvg$x, -SlycKsdAvg$x + lower_bound)
#Vvinks = c(VvinKsdAvg$x, -VvinKsdAvg$x + lower_bound)
#S_Vks = c(S_VKsdAvg$x, -S_VKsdAvg$x + lower_bound)
S_Dks = c(S_DKsdAvg$x, -S_DKsdAvg$x + lower_bound)

kds_data <- list(Datura=Dstrks,
                 Solanum=Slycks,
                 `Solanum vs. Datura`=S_Dks)
kds_data_plotting <- melt(kds_data)
kds_data_plotting$PlotGroup <- "Paralogs"
kds_data_plotting$PlotGroup[grep("vs",kds_data_plotting$L1)] <- "Orthologs"
kds_data_plotting$PlotGroup <- factor(kds_data_plotting$PlotGroup, levels=c("Paralogs", "Orthologs"))

k1 <- ggplot(kds_data_plotting[kds_data_plotting$value <= upper_bound & kds_data_plotting$value >= lower_bound,], aes(x=value,fill=L1)) + 
  geom_density(alpha=0.25,
                       aes(linetype=L1)) +
  geom_vline(xintercept = 0.194) +
  labs(y=NULL, x="Ks") +
  scale_fill_manual(values=c("black", "white", "black")) +
  scale_linetype_manual(values=c("solid","longdash","solid"))+
  scale_x_continuous(breaks=seq(0,3,0.5)) +
  facet_wrap(~PlotGroup,
             scales="free",
             nrow=2) +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        legend.title = element_blank(),
        legend.position=c(0.8,0.8),
        strip.background = element_blank(),
        plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25))

k2 <- ggplot(kds_data_plotting[kds_data_plotting$value <= upper_bound & kds_data_plotting$value >= lower_bound & kds_data_plotting$PlotGroup=="Paralogs",], aes(x=value,fill=L1)) + 
  geom_density(alpha=0.60) +
  geom_vline(xintercept = 0.194) +
  labs(y=NULL, x="Ks") +
  scale_fill_manual(values=c("#5d3f6aff", "#b21807ff"),
                    labels=c(bquote(italic("Datura")), bquote(italic("Solanum")))) +
  scale_x_continuous(breaks=seq(0,3,0.5)) +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        legend.title = element_blank(),
        legend.position=c(0.5,0.8),
        strip.background = element_blank(),
        plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25))

k3 <- ggplot(kds_data_plotting[kds_data_plotting$value <= upper_bound & kds_data_plotting$value >= lower_bound & kds_data_plotting$PlotGroup=="Orthologs",], aes(x=value,fill=L1)) + 
  geom_density(alpha=0.60) +
  geom_vline(xintercept = 0.194) +
  labs(y=NULL, x="Ks") +
  scale_fill_manual(values=c("#878681"), labels=c("Orthologs")) +
  scale_x_continuous(breaks=seq(0,3,0.5)) +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        legend.title = element_blank(),
        legend.position=c(0.5,0.8),
        strip.background = element_blank(),
        plot.title = element_text(hjust = 0.5,
                                  face="bold",
                                  size=25)) +
  ggtitle(" ")

# Assemble Figure ---------------------------------------------------------
(( p1 / t1 + plot_layout(heights = c(1, 2.15)) ) | ( g1 / g2 / g3) | ( t2 / t3 )) +
  plot_annotation(tag_levels = "A") +
  plot_layout(widths=c(1,1,1.5))
ggsave2("../Manuscript/GeneAnnotation.pdf", height=25, width=30)

((p1 /p2 ) | (k2 / k3) | (g1 / g2) )+
  plot_annotation(tag_levels = "A") 
ggsave2("../Manuscript/AnnotationConfirmation.png", height = 10, width=24)

(t1 | (t4 / t5)) +
  plot_annotation(tag_levels = "A")
ggsave2("../Manuscript/Trees.pdf", height=15, width=20)
ggsave2("../Manuscript/Trees.png", height=15, width=20)

(t6 | (t4 / t5)) +
  plot_annotation(tag_levels = "A")
ggsave2("../Manuscript/Trees_NoSoy.pdf", height=15, width=20)
ggsave2("../Manuscript/Trees_NoSoy.png", height=15, width=20)

