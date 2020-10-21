# Code for custom functions to keep the scripts more streamlined

# DESeq Spline -----------------------------------------------------------
DESeqSpline <- function(se=se, 
                        timeVar="DAP",
                        CaseCtlVar="Genotype",
                        SetDF="",
                        vsNoise=FALSE,
                        CollapseTechRep=FALSE) {
  #calculate spline df as the number of times -1
  if (is.na(as.numeric(SetDF))){
    dfSpline <- (length(unique(colData(se)[,timeVar]))-1)
  } else if (as.numeric(SetDF)>0) {
    dfSpline <- SetDF
  } else {
    stop("Either leave SetDF blank or provide a positive integer for spline degrees of freedom")
  }
  message("Fitting spline regression with ", dfSpline, " degrees of freedom")
  design <- tryCatch(ns(colData(se)[,timeVar], df=dfSpline),
           error=function(e){
             message("There was an error with the design matrix.\nNo internal knots included, which is maybe ok, but check this.")
             design <- ns(colData(se)[,timeVar], df=dfSpline, knots=numeric(0))
             return(design)
           })
  
  colnames(design) <- paste0("spline", seq(1:dim(design)[2]))
  colData(se) <- cbind(colData(se), design)
  if (length(unique(colData(se)[,CaseCtlVar]))>1) {
    message(length(unique(colData(se)[,CaseCtlVar])), " entries detected for ", CaseCtlVar,". Incorporating this into the model")
    if (is(se, "RangedSummarizedExperiment")) {
      dds <- DESeqDataSet(se,
                          design = as.formula(paste0("~",
                                                     CaseCtlVar,
                                                     "+",
                                                     paste(paste0(CaseCtlVar,":",colnames(design)), collapse = "+"))))
    } else if (is(se, "SummarizedExperiment")) {
      dds <- DESeqDataSetFromMatrix(countData = assays(se)$counts,
                                    colData = colData(se),
                                    design = as.formula(paste0("~",
                                                               CaseCtlVar,
                                                               "+",
                                                               paste(paste0(CaseCtlVar,":",colnames(design)), collapse = "+"))))
    }
  } else {
    message("Only one entry detected for ", CaseCtlVar,". Ignoring this variable for model building")
    if (is(se, "RangedSummarizedExperiment")) {
      dds <- DESeqDataSet(se,
                          design = as.formula(paste0("~",
                                                     paste(colnames(design), collapse = "+"))))
    } else if (is(se, "SummarizedExperiment")) {
      dds <- DESeqDataSetFromMatrix(countData = assays(se)$counts,
                                    colData = colData(se),
                                    design = as.formula(paste0("~",
                                                               paste(colnames(design), collapse = "+"))))
    }
  }
  if (CollapseTechRep) {
    #Collapse technical replicates
    #Assumes tech reps share an accession name with ".1" or ".2" to differentiate them
    dds$Accession <- sub("\\.\\d", "", dds$Accession) #converted to char, FYI
    dds <- collapseReplicates(dds, dds$Accession)
  }
  
  dds <- estimateSizeFactors(dds)
  # in case of a Slyc vs Spimp comparision, make sure the DEGs aren't ones where Spimp has no counts. This could represent a mapping problem to the Slyc genome, but I dont know if this is legit
  # if(CaseCtlVar=="Species" && length(levels(dds$Species))) {
  #   nc1 <- counts(subset(dds, select=Species==levels(dds$Species)[1]), normalized=TRUE)
  #   nc2 <- counts(subset(dds, select=Species==levels(dds$Species)[2]), normalized=TRUE)
  #   filter1 <- rowSums(nc1 >=10) >= (dim(nc1)[[2]]*0.2)
  #   filter2 <- rowSums(nc2 >=10) >= (dim(nc2)[[2]]*0.2)
  #   filter <- filter1 & filter2
  #   dds <- dds[filter,]
  # }
  if (vsNoise) {
    dds <- DESeq(dds,test="LRT", reduced = ~ 1)
  }  else if (length(unique(colData(se)[,CaseCtlVar]))>1) {
    dds <- DESeq(dds,test="LRT", reduced = as.formula(paste0("~",paste(colnames(design), collapse = "+"))))
  } else {
    dds <- DESeq(dds,test="LRT", reduced = ~ 1)
  }
  return(dds)
}


# DESeq Clustering --------------------------------------------------------
DESeqCluster <- function(dds=dds,
                         numGenes=c("1000", "3000", "all"),
                         FDRthreshold=0.01,
                         timeVar="DAP",
                         CaseCtlVar="Genotype",
                         Diagnostic=FALSE){
  #this section is HEAVILY borrowed from:
  #https://hbctraining.github.io/DGE_workshop/lessons/08_DGE_LRT.html
  numGenes=match.arg(numGenes)
  message("Normalizing counts")
  rld <- rlog(dds, blind=FALSE)
  message("Done.")
  if (Diagnostic) {
    message("Now for some diagnostic plots:")
    plot( assay(rld)[ , 1:2], col=rgb(0,0,0,.2), pch=16, cex=0.3, )
    plot <- plotPCA(rld, intgroup = c(CaseCtlVar, timeVar))
    print(plot)
  }
  message("Filtering DEGs to FDR threshold less than ", FDRthreshold)
  res_LRT <- results(dds)
  sig_res <- res_LRT %>%
    data.frame() %>%
    rownames_to_column(var="gene") %>% 
    as_tibble() %>% 
    filter(padj < FDRthreshold)
  message(nrow(sig_res), " genes remaining")
  # Subset results for faster clustering
  if (numGenes=="all") {
    numGenes <- nrow(sig_res)
    message("Using all ", numGenes, " DEGs. Maybe consider fewer to speed clustering?")
  } else {
    message("Using ", numGenes, " for clustering")
  }
  clustering_sig_genes <- sig_res %>%
    arrange(padj) %>%
    head(n=as.numeric(numGenes))
  # Obtain rlog values for those significant genes
  cluster_rlog <- rld[clustering_sig_genes$gene, ]
  colData(cluster_rlog)[,timeVar] <- as.factor(colData(cluster_rlog)[,timeVar])
  if (length(unique(colData(cluster_rlog)[,CaseCtlVar]))>1) {
    message("Two entries detected for ", CaseCtlVar,". Plots will be colored by ", CaseCtlVar)
    clusters <- degPatterns(assay(cluster_rlog), metadata = colData(cluster_rlog), time = timeVar, col=CaseCtlVar, reduce = T)
  } else {
    message("Only one entry detected for ", CaseCtlVar, ". Ignoring ", CaseCtlVar, " for plotting.")
    clusters <- degPatterns(assay(cluster_rlog), metadata = colData(cluster_rlog), time = timeVar, col=NULL, reduce = T)
  }
  return(clusters)
}


# Just a basic negation of another function -------------------------------
`%notin%` <- Negate(`%in%`)


# Converting Gene names to Orthogene names --------------------------------
ConvertGenes2Orthos <- function(OrthogroupMappingFile="",
                                GeneWiseExpt="",
                                SingleCopyOrthoOnly=FALSE,
                                Arabidopsis=TRUE) {
  require(tidyr)
  Orthogroups <- read.table(OrthogroupMappingFile,
                            sep="\t",
                            stringsAsFactors = F,
                            header=T)
  if(!Arabidopsis) {
    Orthogroups <- Orthogroups[,-2]
  }
  if (SingleCopyOrthoOnly) {
    Orthogroups <- Orthogroups %>% filter_all(all_vars(!grepl(',',.))) #Remove multiples
    Orthogroups <- Orthogroups %>% filter_all(all_vars(!grepl("^$",.))) # Remove empties
  }
  if(Arabidopsis) {
    Orthogroups <- Orthogroups %>% unite("Concatenated", 2:length(Orthogroups), sep=", ")
  } else {
    #Assumes Arabidopsis is the 2nd column
    Orthogroups <- Orthogroups %>% unite("Concatenated", 3:length(Orthogroups), sep=", ")
    }
  Orthogroups <- separate_rows(as.data.frame(Orthogroups[,c("Orthogroup", "Concatenated")]), 2, sep=", ")
  # Extract, subset, and aggregate count matrix from SummarizedExperiment
  Counts <- assay(GeneWiseExpt)
  Counts <- Counts[rownames(Counts) %in% as.character(Orthogroups$Concatenated),]
  rownames(Counts) <- as.character(Orthogroups$Orthogroup[match(rownames(Counts), Orthogroups$Concatenated)])
  Counts <- as.data.frame(cbind(rownames(Counts), Counts), row.names = F)
  if (!SingleCopyOrthoOnly) {
    # Average expression of multi copy genes
    Counts <- aggregate(.~Counts$V1,data=Counts[,2:dim(Counts)[2]], FUN=mean)
  }
  rownames(Counts) <- Counts[,1]
  Counts <- Counts[,-1]
  Counts <- apply(Counts, c(1,2), as.numeric)
  if (!SingleCopyOrthoOnly) {
    # Include orthogroups that have no data
    Counts <- rbind(Counts,
                    setNames(data.frame(matrix(0L,ncol = length(colnames(Counts)), nrow = length(levels(as.factor(Orthogroups$V1))[levels(as.factor(Orthogroups$V1)) %notin% rownames(Counts)])),
                                        row.names = levels(as.factor(Orthogroups$V1))[levels(as.factor(Orthogroups$V1)) %notin% rownames(Counts)]),
                             colnames(Counts)))
  }
  OrthoExpt <- SummarizedExperiment(assays = list("counts"=Counts),
                                    colData = colData(GeneWiseExpt))
  return(OrthoExpt)
}


# Do A Go Enrichment ------------------------------------------------------
# Function to do the enrichment
GOEnrich <- function(gene2go="",
                     GOIs="",
                     GOCategory="BP",
                     NumCategories=20) {
  require(topGO)
  require(Rgraphviz)
  require(tidyr)
  require(dplyr)
  # Clean the lists of GO terms from the bash script and convert to a named list object
  GO <- read.table(gene2go, stringsAsFactors = F)
  GO <- separate_rows(as.data.frame(GO[,c(1,2)]), 2, sep="\\|")
  GO <- GO %>% 
    distinct() %>% 
    group_by(V1) %>% 
    mutate(V2 = paste0(V2, collapse = "|")) %>%
    distinct()
  GO <- setNames(strsplit(x = unlist(GO$V2), split = "\\|"), GO$V1)
  # Read in the genes of interest to be tested for GO enrichment
  # create if to handle if the gene list is passed from a named factor object
  if (is(GOIs, "factor")){
    message("You passed a named factor list for genes. Make sure that's correct.")
    GOI <- GOIs
  } else {
    GOI <- scan(file=GOIs,
                what = list(""))[[1]]
    GOI <- factor(as.integer(names(GO) %in% GOI))
    names(GOI) <- names(GO)
  }
  # Create a TopGO object with the necessary data, also get a summary with
  GOData <- new("topGOdata",
                description = "Slyc Cluster 1",
                ontology = GOCategory,
                allGenes = GOI,
                nodeSize = 5,
                annot = annFUN.gene2GO,
                gene2GO=GO)
  # Do the enrichment test
  GOResults <- runTest(GOData,
                       algorithm="weight01", #classic is best, then lea?
                       statistic = "fisher")
  # Summarize the test with a table
  GOTable <- GenTable(GOData,
                      Fisher = GOResults,
                      orderBy = "Fisher",
                      ranksOf = "Fisher",
                      topNodes = NumCategories)
  # Summarize with a prettier graph from https://www.biostars.org/p/350710/
  GOTable$Fisher <- gsub("^< ", "", GOTable$Fisher) #remove too low pvals
  GoGraph <- GOTable[as.numeric(GOTable$Fisher)<0.05, c("GO.ID", "Term", "Fisher", "Significant")]
  if(dim(GoGraph)[1]==0){
    return(NULL) #stop empty graphs
  }
  GoGraph$Term <- gsub(" [a-z]*\\.\\.\\.$", "", GoGraph$Term) #clean elipses
  GoGraph$Term <- gsub("\\.\\.\\.$", "", GoGraph$Term)
  GoGraph$Term <- substring(GoGraph$Term,1,26)
  GoGraph$Term <- paste(GoGraph$GO.ID, GoGraph$Term, sep=", ")
  GoGraph$Term <- factor(GoGraph$Term, levels=rev(GoGraph$Term))
  GoGraph$Fisher <- as.numeric(GoGraph$Fisher)
  return(GoGraph)
}



# Make a Plot of these GO Enrichments -------------------------------------
GOPlot <- function(GoGraph=X,
                   Title="",
                   LegendLimit=max(GoGraph$Significant),
                   colorHex="#5d3f6a99") 
{
  require(ggplot2)
  GoPlot <- ggplot(GoGraph, aes(x=Term, y=-log10(Fisher), fill=Significant)) +
    stat_summary(geom = "bar", fun = mean, position = "dodge") +
    xlab(element_blank()) +
    ylab("Log Fold Enrichment") +
    scale_fill_gradientn(colours = c("#87868140", colorHex), #0000ff40
                         limits=c(1,LegendLimit),
                         breaks=c(1,LegendLimit)) +
    ggtitle(Title) +
    scale_y_continuous(breaks=round(seq(0, max(-log10(GoGraph$Fisher),3)), 1)) +
    #theme_bw(base_size=12) +
    theme(
      panel.grid = element_blank(),
      legend.position=c(0.8,.3),
      legend.background=element_blank(),
      legend.key=element_blank(),     #removes the border
      legend.key.size=unit(0.5, "cm"),      #Sets overall area/size of the legend
      #legend.text=element_text(size=18),  #Text size
      legend.title=element_blank(),
      plot.title=element_text(angle=0, face="bold", vjust=1, size=25),
      axis.text.x=element_text(angle=0, hjust=0.5),
      axis.text.y=element_text(angle=0, vjust=0.5),
      axis.title=element_text(hjust=0.5),
      #title=element_text(size=18)
    ) +
    guides(fill=guide_colorbar(ticks=FALSE, label.position = 'left')) +
    coord_flip()
  print(GoPlot)
}


# IPR Domain Enrichment ---------------------------------------------------
#this  borrows heavily from the supplement of https://doi.org/10.1104/pp.108.132985
PfamEnrichment <- function(AllGenesFile = "",
                           AllIPRFile = "",
                           IPRDescFile = "",
                           ExcludedGenesFile = "",
                           TopGenesFile = "",
                           OutputFile = "",
                           p_cut_off = 0.1,
                           WriteToFile=TRUE) {
  # Read in files to lists
  AllIPR <- scan(file=AllIPRFile,
                 what = list("",""),
                 sep = "\t")
  IPRDesc <- scan(file=IPRDescFile,
                  what = list("",""),
                  sep = "\t",
                  quote = "")
  ExcludedGenes <- scan(file=ExcludedGenesFile,
                        what = list(""))[[1]]
  AllGenes <- scan(file=AllGenesFile,
                   what=list(""))[[1]]
  top_genes <- scan(file=TopGenesFile,
                    what = list(""))[[1]] 
  output_file = OutputFile
  # Clean lists
  AllGenes <- AllGenes[AllGenes %notin% ExcludedGenes]
  top_genes <- top_genes[top_genes %notin% ExcludedGenes]
  top_genes <- top_genes[top_genes %in% AllGenes]
  # Split list of domains
  domain_grouping <- split(AllIPR[[1]], AllIPR[[2]])
  # Set up hypergeometric test
  ## q: Genes with given domain that are in the top set are the white balls drawn from the urn.
  ## m: Genes with given domain are white balls.
  ## n: Genes without given domain are black balls.
  ## k: The balls drawn are the genes in the top set.
  p_value_vector = c() 
  enrichment_vector = c() 
  q_vector = c()
  m_vector = c()
  # Do hypergeometric test
  for (index in 1:length(domain_grouping)){
    domain = names(domain_grouping)[index] 
    genes_with_domain = domain_grouping[[index]]
    q = sum(genes_with_domain %in% top_genes)
    m = length(genes_with_domain)
    n = length(AllGenes) - m
    k = length(top_genes)
    p_value = phyper(q - 1, m, n, k, lower.tail = FALSE) 
    p_value_vector[index] = p_value
    enrichment = q/(m*k/(n+m)) 
    enrichment_vector[index] = enrichment 
    q_vector[index] = q
    m_vector[index] = m
  }
  # Adjust p-values
  library(multtest)
  adjusted_p <- mt.rawp2adjp(p_value_vector, proc = c("BH"))
  # Write result
  significant_indices = adjusted_p$index[adjusted_p$adjp[,2] < p_cut_off]
  if (length(significant_indices) == 0 ) {
    warning("No significantly enriched domains in this group. Skipping")
    return(NULL)
  }
  significant_enrichments = enrichment_vector[significant_indices] 
  indices_by_enrichment = significant_indices[sort(significant_enrichments, decreasing = TRUE, index.return = TRUE)[[2]]]
  sorted_descriptions = IPRDesc[[2]][match(names(domain_grouping)[indices_by_enrichment], IPRDesc[[1]])]
  sorted_IPR_ID = names(domain_grouping)[indices_by_enrichment] 
  sorted_full_descriptions = paste0(sorted_descriptions, " (", sorted_IPR_ID, ")") 
  sorted_enrichment = enrichment_vector[indices_by_enrichment]
  sorted_p_values = adjusted_p$adjp[match(indices_by_enrichment, adjusted_p$index),2] 
  sorted_q = q_vector[indices_by_enrichment]
  sorted_m = m_vector[indices_by_enrichment]
  sorted_gene_groups = c()
  for (index in 1:length(indices_by_enrichment)){
    temp_genes = top_genes[as.vector(na.omit(match(domain_grouping[[indices_by_enrichment[index]]], top_genes)))]
    sorted_gene_groups[index] = paste(temp_genes, sep = ",", collapse = ",") 
  }
  output = cbind(Description=sorted_full_descriptions, 
                 Enrichment=round(sorted_enrichment, digits = 1), 
                 Enrichment_pval=as.character(format(signif(sorted_p_values, digits = 1), scientific = TRUE)), 
                 Hits=sorted_q, 
                 Total=sorted_m, 
                 Gene_IDs=sorted_gene_groups)
  if(WriteToFile) {
    write.table(output, file = output_file, sep = "\t", quote=FALSE, row.names = FALSE)
  }
  return(output)
}


# Common Color Palette  ---------------------------------------------------
library("wesanderson")
palw <- wes_palette("Zissou1",4,"continuous") 
#Blue=Pimpinellifolium
#Green=Arabidopsis
#Yellow=Obtusifolia or dry
#Red=Lycopersicum or fleshy




