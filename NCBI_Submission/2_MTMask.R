library(tidyverse)
setwd("~/Downloads/")
# Convert NCBI Errors intervals to a bed file
contam <- read_tsv("Contamination.txt", skip = 57,
                   col_names = c("Chrom", "Length", "Interval", "Source")) %>% 
  separate_rows(Interval, sep = ",") %>% 
  mutate(chromStart = gsub("(\\d+)\\.\\.(\\d+)", "\\1", Interval),
         chromStop = gsub("(\\d+)\\.\\.(\\d+)", "\\2", Interval),
         Interval = NULL,
         Length = NULL) %>% 
  dplyr::select(!Source) %>% 
  write_tsv(file = "Contamination.bed",
            col_names = F)

# Use the bed file to mask out those regions in the fasta
system("bedtools maskfasta -fi Datura_stramonium.scaffolds_NCBI_Rename.fa -bed Contamination.bed -fo Datura_stramonium.scaffolds_NCBI_Rename_MTmask.fa")

