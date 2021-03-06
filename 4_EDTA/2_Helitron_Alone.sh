#!/bin/bash -l
#SBATCH --cpus-per-task=30
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/EDTA_Helitron-%A.out
set -e

# Create the conda environment if necessary
# conda create -n EDTAenv
# conda activate EDTAenv
# conda install -c bioconda -c conda-forge edta
conda activate EDTAenv
# Reload RepeatMasker to fix a problem with RMblast in the conda env
module load RepeatMasker/4-0-6 
module unload perl

# Link in the genome for convenience
#ln -sf /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation/Dstr_v1.7.sorted.fa Dstr_v1.7.fa

EDTA_raw.pl \
    --genome Dstr_v1.7.fa \
    --species others \
    --type helitron \
    --threads $SLURM_CPUS_PER_TASK
