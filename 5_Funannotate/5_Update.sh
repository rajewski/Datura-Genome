#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=7G
#SBATCH --time 2-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Fix-%A.out
set -e

WORKDIR=predict_20200329

module load funannoate/1.6.0

funannotate update \
    -i $WORKDIR \
    --cpus $SLURM_CPUS_PER_TASK
