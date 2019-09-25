#!/bin/bash -l
#SBATCH --ntasks=10
#SBATCH --nodes=1
#SBATCH --mem=80G
#SBATCH --time=7-20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p batch,intel
#SBATCH -o ./history/2x_Flye-%A.out
set -euv

module load miniconda3
source activate masurca
GS=`cat ESTIMATED_GENOME_SIZE.txt`
OUTDIR=flye_assembly
CORR=mr.41.15.15.0.02.1.fa

if [ ! -d "./flye_assembly" ]; then
    echo $(date): Running Flye
    flye --nano-corr $CORR -t $SLURM_NTASKS -g $GS -m 2000 -o $OUTDIR -i 0
    echo $(date): Flye is complete
else
    flye --resume --nano-corr $CORR -t $SLURM_NTASKS -g $GS -m 2000 -o $OUTDIR -i 0
fi
scontrol show job $SLURM_JOB_ID
