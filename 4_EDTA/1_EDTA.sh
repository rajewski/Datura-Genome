#!/bin/bash -l
#SBATCH --cpus-per-task=48
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/EDTA-%A.out
set -e

# Create an alternative conda env to get this working right
#conda create -n EDTA
conda activate EDTA
#conda install -n EDTA -y cd-hit repeatmodeler muscle mdust blast openjdk perl perl-text-soundex multiprocess regex tensorflow=1.14.0 keras=2.2.4 scikit-learn=0.19.0 biopython pandas glob2 python=3.6 tesorter genericrepeatfinder genometools-genometools ltr_retriever ltr_finder numpy=1.16.4
#git clone https://github.com/oushujun/EDTA
export PATH=/bigdata/littlab/arajewski/Datura/software/EDTA/:$PATH

# Reload RepeatMasker to fix a problem with RMblast in the conda env
module load RepeatMasker/4-0-6 
module unload perl

# Link in the genome and CDS for convenience
#ln -sf /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation/Dstr_v1.7.sorted.fa Dstr_v1.7.fa
# Link in the CDS fasta
#ln -sf /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation/predict_results/Datura_stramonium.cds-transcripts.fa Dstr_v1.7.cds.fa

EDTA.pl \
    --genome Dstr_v1.7.fa \
    --species others \
    --cds Dstr_v1.7.cds.fa \
    --anno 1 \
    --sensitive 1 \
    --threads $SLURM_CPUS_PER_TASK
