#!/bin/bash

ASSEMBASE=Dstr_v1.7_lnr13_500bp_Sealer_k125_scaffold
awk 'BEGIN {RS=">";FS="\n";OFS=""} NR>1 {print ">"$1; $1=""; print}' ${ASSEMBASE}.fa | \
grep -v ">"  | \
sed 's/[ATGCatgc]/x/g' | \
sed -e 's/xN/\nN/g' -e 's/Nx/N\n/g' | \
sed 's/x//g' | \
awk '{print length($1)}' | \
grep -vw "^0$" > ${ASSEMBASE}_gaplengths.txt
