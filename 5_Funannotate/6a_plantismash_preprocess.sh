#!/bin/bash -l

grep "scaffold" Datura_stramonium.gff3 | cut -f1 |sort |uniq >scaffs_to_keep.txt

module load qiime

filter_fasta.py -f Datura_stramonium.scaffolds.fa -o Datura_stramonium.genicScaffolds.fa -s scaffs_to_keep.txt
