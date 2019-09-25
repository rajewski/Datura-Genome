#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=40G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p batch
#SBATCH -o ./history/3a_BUSCO-%A.out
set -euv


#the point of this script is to assess the assembly with the BUSCO database

module load busco/3.0.2
ASSEM=Dstr_v1.0
ASSEMPATH=~/bigdata/Datura/flye_assembly/assembly.fasta

run_BUSCO.py \
    -m genome \
    -c $SLURM_NTASKS \
    -i $ASSEMPATH \
    -o $ASSEM \
    -l embryophyta_odb9 \

scontrol show job $SLURM_JOB_ID
