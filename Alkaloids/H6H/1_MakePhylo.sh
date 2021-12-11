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

INFILE=H6H.Curated

module load mafft/7.471
mafft \
    --maxiterate 1000 \
    --thread $SLURM_CPUS_PER_TASK \
    $INFILE.fasta > $INFILE.align.fasta

module load RAxML_NG/0.9.0
raxml-ng \
    --outgroup Aqcoe4G163300 \
    --all \
    --threads $SLURM_CPUS_PER_TASK \
    --model JTT+G+I \
    --msa $INFILE.align.fasta \
    --bs-trees 1000
