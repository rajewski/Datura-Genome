#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --nodes=1
#SBATCH --mem=300G
#SBATCH --time=05:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ../history/KMC-%A.out
set -euv


echo $(date): Running KMC first.
#Lets run KMC first because it produces a sorted kmer histogram that should be 
#easier and more memory effective for smudgeplot to use
module load KMC/3.1.1
mkdir -p tmp
#counting kmer coverages between 1 and 10000x
kmc -k17 -t$SLURM_CPUS_PER_TASK -m$((SLURM_MEM_PER_NODE/1024)) -ci1 -cs100000 ../2_MaSuRCA338/n2.renamed.fastq kmer_counts tmp
kmc_tools transform kmer_counts histogram kmer_k17.hist -cx10000
echo $(date): Done with KMC.
