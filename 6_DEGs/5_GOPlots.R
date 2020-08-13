source("../../FULTranscriptomes/X_Functions.R")

# Make a GO Enrichment of the Up and Down Regulated Genes
GO_Down <- GOEnrich(gene2go = "DESeq/Dstr.genes2go.tsv",
                    GOIs="DESeq/Result_Down.tsv")
GO_Up <- GOEnrich(gene2go = "DESeq/Dstr.genes2go.tsv",
                  GOIs="DESeq/Result_Up.tsv")
