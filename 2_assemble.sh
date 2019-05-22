#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=200G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ../history/slurm-%A.out
set -euv

# $((SLURM_MEM_PER_NODE/1000))'G'

#Although I think velvet can handle many files of the same library type, I want to simplify the command line options to reduce my chances for error. 
#I have used the following commands to combine all of my surviving paired end files into two files
#cat Dstr1Trim_1P.fq.gz Dstr2Trim_1P.fq.gz Dstr3Trim_1P.fq.gz > DstrTrim_1P.fq.gz
#cat Dstr1Trim_2P.fq.gz Dstr2Trim_2P.fq.gz Dstr3Trim_2P.fq.gz > DstrTrim_2P.fq.gz
#cat Dstr1Trim_1U.fq.gz Dstr2Trim_1U.fq.gz Dstr3Trim_1U.fq.gz > DstrTrim_1U.fq.gz
#cat Dstr1Trim_2U.fq.gz Dstr2Trim_2U.fq.gz Dstr3Trim_2U.fq.gz > DstrTrim_2U.fq.gz

#load velvet
module load velvet/1.2.10
#Load velvet optimizer to test the assembly parameters
echo $(date): Loading Velvet Optimizer
velvetoptimiser/2.2.5

#the command have been adapted from https://github.com/tseemann/VelvetOptimiser
echo $(date): Running optimization
VelvetOptimiser.pl -s 19 -e 57 -f '-fastq.gz -shortPaired -separate Dstr1Trim_1P.fq.gz Dstr1Trim_2P.fq.gz -short DstrTrim_1U.fq.gz DstrTrim_2U.fq.gz' -g 2000 -t $SLURM_NTASKS
echo $(date): Done
