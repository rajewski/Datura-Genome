#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=400G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p batch
#SBATCH -o ../history/slurm-%A.out
set -euv

# $((SLURM_MEM_PER_NODE/1000))'G'
# $SLURM_NTASKS

#Load velvet optimizer to test the assembly parameters
echo $(date): Loading Velvet Optimizer
velvetoptimiser/2.2.5(default)

#the command have been adapted from https://github.com/tseemann/VelvetOptimiser
VelvetOptimiser.pl -s 19 -e 57 -f '-shortPaired -fastq.gz -separate s_1_sequence.txt' -g 4.5 -t 8

