# Make summary Tables
library(gt)
library(tidyverse)
system("PATH=/bigdata/littlab/arajewski/Datura/software/phantomjs-2.1.1-linux-x86_64/bin:$PATH")
setwd("/bigdata/littlab/arajewski/Datura/")
snpEff_Region <- read.csv2("6_SNP_SV/results/Summary/snpEff_Region.csv", sep=",")
#snpEff_Type <- read.csv2("6_SNP_SV/results/Summary/snpEff_Type.csv", sep=",")
16152+7146
#Clean up the rows
snpEff_Region$Type <- str_to_title(gsub("_", " ",snpEff_Region$Type))
snpEff_Region$Percent <- as.numeric(snpEff_Region$Percent)
# Group chromo, gene, transcript as other
snpEff_Region[c(1,4,10),1] <- "Other"
snpEff_Region$Type <- gsub("Splice Site .*", "Splice Junction", snpEff_Region$Type)
snpEff_Region <- aggregate(snpEff_Region[,2:3], by=list(snpEff_Region$Type), FUN=sum)
snpEff_Region <- snpEff_Region[c(7,2,6,4,1,3,5),]


#snpEff_Type$Type <- str_to_title(gsub("_", " ",snpEff_Type$Type))
#snpEff_Type$Percent <- as.numeric(snpEff_Type$Percent)


# Whip this ish into a table for publication
snpEff_Region %>%
  gt(
    rowname_col = "Group.1"
  ) %>%
  tab_header(
    title = "Polymorphisms by Location") %>%
  fmt_number(
    columns = vars(`Percent`),
    decimals = 2) %>%
  fmt_number(
    columns =vars(Count),
    suffixing=FALSE,
    decimals=0) %>%
  cols_align(
    align="right",
    columns = vars(Count, Percent)) %>%
  cols_label(
    Group.1 =md("**Region**"),
    Count = md("**Num. Polymorphisms**"),
    Percent = md("**Percent**")) %>%
  grand_summary_rows(
    columns = vars(Count, Percent),
    fns=list("Total"=~sum(.)),
    formatter = fmt_number,
    decimals=0,
    suffixing=FALSE) %>%
  tab_footnote(
    footnote="Including non-coding genes",
    locations = cells_stub(
      rows = 7)) %>%
  tab_footnote(
    footnote=">5kb from gene body",
    locations = cells_stub(
      rows = 6)) %>%
  gtsave(filename = "Manuscript/Mutation_Summary.pdf")