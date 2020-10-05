# Make summary Table
library(gt)
library(tidyverse)
system("PATH=/bigdata/littlab/arajewski/Datura/software/phantomjs-2.1.1-linux-x86_64/bin:$PATH")
setwd("/bigdata/littlab/arajewski/Datura/")
assembly <- read.csv2("Manuscript/Assembly.csv", sep=',', header=F)
# Reformat
rownames(assembly) <- assembly$V1
assembly <- assembly[-1,-1]
assembly <- as.data.frame(t(assembly))
rownames(assembly) <- c("Short-Read Assembly", "Scaffolding and Gap Filling", "Length Filtering", "Gap Filling and Polishing")
assembly[,c(1,2)] <- apply(assembly[,c(1,2)], 2, as.integer)
assembly[1,5] <- "0"
assembly[,3:10] <- apply(assembly[,3:10], 2, as.numeric)

assembly %>%
  gt(
    rownames_to_stub = TRUE
  ) %>%
  tab_header(
    title = "Genome Assembly Statistics") %>%
  fmt_number(
    columns = vars(`Contigs (n)`, `Scaffolds (n)`, `Largest Contig (kbp)`, `Largest Scaffold (kbp)`),
    decimals=0,
    sep_mark = ",") %>%
  fmt_number(
    columns =vars(`BUSCO Complete Genes (%)`),
    decimals=1) %>%
  cols_align(
    align="right",
    ) %>%
  cols_label(
    `Contigs (n)` =md("**Contigs**<br/>(n)"),
    `Scaffolds (n)` = md("**Scaffolds**<br/>(n)"),
    `Ungapped Size (Gbp)`= md("**Ungapped Size**<br/>(Gbp)"),
    `Gapped Size (Gbp)` = md("**Gapped Size**<br/>(Gbp)"),
    `Ambiguous Bases (%)` = md("**Ambiguous Bases**<br/> (%)"),
    `Contig N50 (kbp)` = md("**Contig N50**<br/>(kbp)"),
    `Scaffold N50 (kbp)` = md("**Scaffold N50**<br/>(kbp)"),
    `Largest Contig (kbp)` = md("**Largest Contig**<br/>(kbp)"),
    `Largest Scaffold (kbp)` = md("**Largest Scaffold**<br/>(kbp)"),
    `BUSCO Complete Genes (%)` = md("**BUSCO</br>Complete&nbsp;Genes**</br> (%)")) %>%
  tab_footnote(
    footnote="With ONT long reads",
    locations = cells_stub(
      rows = 2)) %>%
  tab_footnote(
    footnote=md("\u2264 500bp"),
    locations = cells_stub(
      rows = 3)) %>%
  tab_footnote(
    footnote="With Illumina short reads",
    locations = cells_stub(
      rows = 4)) %>%
  gtsave(filename = "Manuscript/GenomeStats.pdf")
