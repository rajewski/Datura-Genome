#!/bin/bash -l

# Deal with .tbl file
sed -e 's:^>Feature \(scaffold_[0-9]*\):>Feature gnl|WGS\:JACEIK01|\1|gb|JACEIK010:' /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/annotate_results/Datura_stramonium.tbl > tmp_Datura_stramonium.tbl
sed -e 's:|scaffold_\([0-9]*\)|gb|JACEIK010:|scaffold_\1|gb|@000000\1:;s:|@0*\(......\):|JACEIK010\1:' tmp_Datura_stramonium.tbl > Datura_stramonium_NCBI_Renamed.tbl
rm tmp_Datura_stramonium.tbl

# Deal with .gff
gunzip /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/annotate_results/Datura_stramonium.gff3.gz
sed -e 's:^scaffold_\([0-9]*\):_000000\1:;s:_.*\(.......\)fun:JACEIK010\1 fun:' Datura_stramonium.gff3 > Datura_stramonium_NCBI_Renamed.gff3
gzip Datura_stramonium_NCBI_Renamed.gff3

# Deal with .gbk
sed -e 's:       \(scaffold_[0-9]*\) :       gnl|WGS\:JACEIK01|\1|gb|JACEIK010: ;s:|scaffold_\([0-9]*\)|gb|JACEIK010:|scaffold_\1|gb|000000\1:;s:gb|0*\([0-9]\{6\}\):gb|JACEIK010\1:' /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/annotate_results/Datura_stramonium.gbk >Datura_stramonium_NCBI_Rename.gbk

# Deal with FASTA
cp /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation/Dstr_v1.7.masked.NCBIready.fa tmp_Datura_stramonium.scaffolds.fa
sed -e 's:>\(scaffold_[0-9]*\):>gnl|WGS\:JACEIK01|\1|gb|JACEIK010: ;s:|scaffold_\([0-9]*\)|gb|JACEIK010:|scaffold_\1|gb|000000\1:;s:gb|0*\([0-9]\{6\}\):gb|JACEIK010\1:' tmp_Datura_stramonium.scaffolds.fa > Datura_stramonium.scaffolds_NCBI_Rename.fa
rm tmp_Datura_stramonium.scaffolds.fa

