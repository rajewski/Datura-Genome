#!/bin/bash -l
#SBATCH --cpus-per-task=48
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/EDTA_TIR-%A.out
set -e

# Create the conda environment if necessary
# conda create -n EDTAenv
# conda activate EDTAenv
# conda install -c bioconda -c conda-forge edta
conda activate EDTAenv
# Reload RepeatMasker to fix a problem with RMblast in the conda env
module load RepeatMasker/4-0-6 
module unload perl

# Link in the genome and CDS for convenience
# ln -sf /bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.5_Iterative/lordecreads.fa_vs_Dstr_v1.5_n5r1_n4r1_n2.fa_250_0.9_rails.scaffolds.fa Dstr_v1.5.fa
# sed 's/\s.*$//' Dstr_v1.5.fa > Dstr_v1.5..trim.fa
# ln -sf /bigdata/littlab/arajewski/Datura/5_Funannotate/20200426_Dstr_v1.5/predict_results/Datura_stramonium.cds-transcripts.fa Dstr_v1.5.cds.fa

EDTA_raw.pl \
    --genome Dstr_v1.5.trim.fa \
    --species others \
    --type tir \
    --threads $SLURM_CPUS_PER_TASK
