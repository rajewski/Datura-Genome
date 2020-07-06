#!/bin/bash -l
#SBATCH --cpus-per-task=48
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/RelocaTE2-%A_%a.out
set -e

# Create the conda environment if necessary
# conda create --name RelocaTE2 -c bioconda relocate2
conda activate RelocaTE2

#Maybe unnecessary files?

# Reload RepeatMasker to fix a problem with RMblast in the conda env
#module load RepeatMasker/4-0-6 
#module unload perl

GFP=(GFP_1 GFP_2 GFP_3 )

relocaTE2.py \
    -g ../5_Funannotate/Dstr_v1.7_Annotation/Dstr_v1.7.sorted.fa \
    -r ../4_EDTA/Dstr_v1.7.fa.mod.EDTA.anno/Dstr_v1.7.fa.mod.out.new \
    -t ../4_EDTA/Dstr_v1.7.fa.mod.EDTA.TElib.fa \
    -c $SLURM_CPUS_PER_TASK \
    --size 500 \
    -1 ../DNA-seq/${GFP[$SLURM_ARRAY_TASK_ID]}_R1.fastq.gz \
    -2 ../DNA-seq/${GFP[$SLURM_ARRAY_TASK_ID]}_R2.fastq.gz \
    --sample ${GFP[$SLURM_ARRAY_TASK_ID]} \
    -o ${GFP[$SLURM_ARRAY_TASK_ID]}_RelocaTE2
