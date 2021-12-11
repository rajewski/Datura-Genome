#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Phylogeny-%A.out
set -e

module load mafft/7.471
mafft \
    --maxiterate 1000 \
    --thread $SLURM_CPUS_PER_TASK \
    TR.fasta > TR.aligned.fasta

module load RAxML_NG/0.9.0
raxml-ng \
    --all \
    --threads 8 \
    --model JTT+G+I \
    --msa TR.aligned.fasta \
    --bs-trees 1000
