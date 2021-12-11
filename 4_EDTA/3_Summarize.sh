#! /bin/bash -l

ASSEMBase=Dstr_v1.7

# Generate scaffold lengths
if [ ! -e$ASSEMBase.scaffLengths.tsv ]; then
    awk '$0 ~ ">" {if (NR > 1) {print c;} c=0;printf substr($0,2,100) "\t"; } $0 !~ ">" {c+=length($0);} END { print c; }' $ASSEMBase.fa > $ASSEMBase.scaffLengths.tsv
fi

module load RepeatMasker/4-0-6 
buildSummary.pl \
    -species "Datura stramonium" \
    -genome $ASSEMBase.scaffLengths.tsv \
    $ASSEMBase.fa.mod.EDTA.anno/$ASSEMBase.fa.mod.out.new > $ASSEMBase.EDTA.Summary.txt
