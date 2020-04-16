#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=7G
#SBATCH --time 5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Update-%A.out
set -e

WORKDIR=predict

module load funannotate/1.6.0
#change PASA directory becuase the flag below doesnt work
PASAHOME=/opt/linux/centos/7.x/x86_64/pkgs/PASA/2.3.3/

funannotate update \
    -i $WORKDIR \
    --cpus $SLURM_CPUS_PER_TASK
