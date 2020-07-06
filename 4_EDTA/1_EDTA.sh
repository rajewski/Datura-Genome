#!/bin/bash -l
#SBATCH --cpus-per-task=48
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/EDTA-%A.out
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
ln -sf /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation/Dstr_v1.7.sorted.fa Dstr_v1.7.fa

# Trim the long scaffold names if necessary
#sed 's/\s.*$//' Dstr_v1.5.fa > Dstr_v1.5..trim.fa

# Link in the CDS fasta
#ln -sf /bigdata/littlab/arajewski/Datura/5_Funannotate/20200426_Dstr_v1.5/predict_results/Datura_stramonium.cds-transcripts.fa Dstr_v1.5.cds.fa

EDTA.pl \
    --genome Dstr_v1.7.fa \
    --species others \
    --cds Dstr_v1.5.cds.fa \
    --anno 1 \
    --sensitive 1 \
    --threads $SLURM_CPUS_PER_TASK
