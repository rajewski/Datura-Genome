#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=700G
#SBATCH --time=8-0:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH -p highmem
#SBATCH --mail-type=ALL
#SBATCH -o ../history/spades-%A.out
set -euv

module load SPAdes/3.13.1

spades.py \
    -o /rhome/arajewski/bigdata/Datura/2_SPAdes \
    --continue

scontrol show job $SLURM_JOB_ID
