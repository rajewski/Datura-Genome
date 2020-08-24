#!/bin/bash -l
#SBATCH --cpus-per-task=30
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
##SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/RelocaTE2-%A_%a.out
set -e

# Create the conda environment if necessary
# conda create --name RelocaTE2 -c bioconda relocate2
conda activate RelocaTE2

echo $(date): Running RelocaTE2 on large scaffold test genome...

relocaTE2.py \
    --genome_fasta Genome.1Mb.fasta \
    --reference_ins Dstr_v1.7.fa.mod.EDTA.RM.1Mb.out \
    --te_fasta ../4_EDTA/Dstr_v1.7.fa.mod.EDTA.TElib.cleaned.fa \
    --cpu $SLURM_CPUS_PER_TASK \
    --size 500 \
    --fq_dir  ../DNA-seq/GFP_1_Trim/ \
    --sample GFP_1_LargeScaff \
    --outdir GFP_1_LargeScaff_RelocaTE2
