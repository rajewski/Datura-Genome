# Make summary Tables
system("PATH=/bigdata/littlab/arajewski/Datura/software/phantomjs-2.1.1-linux-x86_64/bin:$PATH")
setwd("/bigdata/littlab/arajewski/Datura/")
TEsummary <- read.csv2("4_EDTA/Dstr_v1.7.fa.mod.EDTA.anno/Dstr_v1.7.fa.mod.EDTA.TEanno.sum",
                       nrows = 39,
                       sep="",
                       header=F,strip.white = T)
# Remove unneeded lines 
names(TEsummary) <- TEsummary[5,]
TEsummary <- TEsummary[-c(1:7,15,17,21,28,36:39),]

# Recode %masked as percent and convert formats
TEsummary$`%masked` <- as.numeric(gsub("%", "", TEsummary$`%masked`))
TEsummary$Count <- as.integer(TEsummary$Count)
TEsummary$bpMasked <- as.integer(TEsummary$bpMasked)

# Rename based on Wicker 2007 codes
TEsummary$Class <- as.factor(c("DTA","DTC","DTH","DTM","DTT","DHH","DHH","RIX","RLC","RLG",
                     "RLX","DTA","DTC","DTH","DTM","DTT","DMM","DTC","DTM",
                     "DTH","DTT","DTA","XXX","RLR"))

# Aggregate by Repeat class
TEsummary <- aggregate(TEsummary[,2:4], by=list(TEsummary$Class), FUN=sum)

# Whip this ish into a table for publication
library(gt)
library(tidyverse)

TEsummary %>%
  gt(
    rowname_col = "Group.1"
  ) %>%
  tab_header(
    title = "Transposable Elements by Superfamily") %>%
  fmt_number(
    columns = vars(`%masked`)) %>%
  fmt_number(
    columns =vars(Count, bpMasked),
    suffixing=FALSE,
    decimals=0) %>%
  tab_row_group(
    group = "Unknown",
    rows = 13) %>%
  tab_row_group(
    group = "Class II: Retrotransposons",
    rows = 1:7) %>%
  tab_row_group(
    group = "Class I: DNA Transposons",
    rows = 8:12) %>%
  cols_align(
    align="right",
    columns = vars(Count, bpMasked, `%masked`)) %>%
  cols_align(
    align="left",
    columns = vars(Group.1)) %>%
  cols_label(
    Group.1 =md("**Superfamily**"),
    Count = md("**Num. Elements**"),
    bpMasked = md("**Total Length** (bp)"),
    `%masked` = md("**% of Genome**")) %>%
  grand_summary_rows(
    columns = vars(Count, bpMasked),
    fns=list("Total"=~sum(.)),
    formatter = fmt_number,
    decimals=0,
    suffixing=FALSE) %>% 
  grand_summary_rows(
    columns = vars(`%masked`),
    fns=list("Total"=~sum(.)),
    formatter = fmt_number,
    decimals=2,
    suffixing=FALSE) %>%
  tab_source_note(
    source_note = "Superfamilies named according to Wicker et al, 2007") %>%
  tab_footnote(
    footnote="Based on ungapped genome size of 1.6Gbp",
    locations = cells_column_labels(
      columns = vars(`%masked`))) %>%
  gtsave(filename = "Manuscript/TE_Summary.png")

#scratch for individual TES
#TE_00002490      38188        17272638     1.08% 
#TE_00002738_LTR      46332        26332360     1.65% 
#TE_00002802_INT      14403        19117587     1.20% 
#TE_00002822_INT      19095        27805839     1.74% 
#TE_00003261_INT      19344        19799492     1.24% 
#TE_00003800_LTR      44872        21406350     1.34% 
