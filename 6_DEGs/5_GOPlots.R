source("../../FULTranscriptomes/X_Functions.R")
library("ggplot2")
library("cowplot")
theme_set(theme_cowplot())



# Make a GO Enrichment of the Up and Down Regulated Genes
GO_Down <- GOEnrich(gene2go = "DESeq/Dstr.genes2go.tsv",
                    GOIs="DESeq/Result_Down.tsv")
GOPlot(GO_Down)
GO_Up <- GOEnrich(gene2go = "DESeq/Dstr.genes2go.tsv",
                  GOIs="DESeq/Result_Up.tsv")
GO_All <- GOEnrich(gene2go = "DESeq/Dstr.genes2go.tsv",
                   GOIs="DESeq/Result_DEGs.tsv")
