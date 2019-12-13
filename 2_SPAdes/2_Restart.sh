#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=500G
#SBATCH --time=20-0:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH -p highmem
#SBATCH --mail-type=ALL
#SBATCH -o ../history/spades-%A.out
set -euv

module load SPAdes/3.13.1

spades.py \
    -t $SLURM_CPUS_PER_TASK \
    -m $((SLURM_MEM_PER_NODE/1024)) \
    -o /rhome/arajewski/bigdata/Datura/2_SPAdes \
    --restart-from k77

scontrol show job $SLURM_JOB_ID
