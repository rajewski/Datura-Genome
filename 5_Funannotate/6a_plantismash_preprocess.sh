#!/bin/bash -l
WORKDIR=Dstr_v1.7_Annotation_largeIntrons_174/predict_results

grep "scaffold" $WORKDIR/Datura_stramonium.gff3 | cut -f1 |sort |uniq > $WORKDIR/scaffs_to_keep.txt

module load qiime

filter_fasta.py -f $WORKDIR/Datura_stramonium.scaffolds.fa -o $WORKDIR/Datura_stramonium.genicScaffolds.fa -s $WORKDIR/scaffs_to_keep.txt
