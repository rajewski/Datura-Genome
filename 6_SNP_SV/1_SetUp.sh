#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --mem=7G
##SBATCH --time=2:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
##SBATCH -p short
#SBATCH -o ./history/SetUp-%A_%a.out

ln -sf ../5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/predict_results/Datura_stramonium.scaffolds.fa Datura_stramonium.scaffolds.fa
ASSEM=Datura_stramonium.scaffolds.5kb.unfold.fa
# Make indices of the genom
if [ ! -f $ASSEM.ann ]; then
    module load bwa/0.7.12
    bwa index $ASSEM
fi

if [ ! -f $ASSEM.fai ]; then
    module load samtools/1.8
    samtools faidx $ASSEM
fi

if [ ! -f $ASSEM.dict ]; then
    module load picard/2.18.3
    picard CreateSequenceDictionary R=$ASSEM O=$ASSEM.dict
fi
