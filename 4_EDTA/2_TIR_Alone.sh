#!/bin/bash -l
#SBATCH --cpus-per-task=30
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/EDTA_TIR-%A.out
set -e

# Set up the files and variables needed
ASSEM=Dstr_v1.7
CUTOFF=1000
#ln -sf /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation/Dstr_v1.7.sorted.fa $ASSEM.fa

# Create the conda environment if necessary
#conda create -n EDTAenv
conda activate EDTAenv
#conda install -c bioconda -c conda-forge edta

# Create an alternative conda env to get this working right
#conda create -n EDTA
conda activate EDTA
#conda install -n EDTA -y cd-hit repeatmodeler muscle mdust blast openjdk perl perl-text-soundex multiprocess regex tensorflow=1.14.0 keras=2.2.4 scikit-learn=0.19.0 biopython pandas glob2 python=3.6 tesorter genericrepeatfinder genometools-genometools ltr_retriever ltr_finder numpy=1.16.4
#git clone https://github.com/oushujun/EDTA
export PATH=/bigdata/littlab/arajewski/Datura/software/EDTA/:$PATH

# Reload RepeatMasker to fix a problem with RMblast in the conda env
module load RepeatMasker/4-0-6 
module unload perl

# Length filter the genome bc TIR-learner has trouble with many small contigs
if [ ! -e $ASSEM.$CUTOFF.fa ]; then
    echo Length filtering the genome to speed TIR-learner
    module load BBMap
    reformat.sh in=$ASSEM.fa out=$ASSEM.$CUTOFF.fa minlength=$CUTOFF
    echo Done.
fi

echo Actually running EDTA
EDTA_raw.pl \
    --genome $ASSEM.$CUTOFF.fa \
    --species others \
    --type tir \
    --threads $SLURM_CPUS_PER_TASK
echo Done.

