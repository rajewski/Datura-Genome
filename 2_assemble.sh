#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=200G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o history/slurm-%A.out
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
echo $(date): Running velveth on a small subset
velveth 2_assemble/ 19 -fastq.gz -shortPaired -separate  1_QCQA/Dstr1Trim_1P.fq.gz 1_QCQA/Dstr1Trim_2P.fq.gz -short 1_QCQA/Dstr1Trim1U.fq.gz 1_QCQA/Dstr1Trim2U.fq.gz
echo $(done): Done.

#Load velvet optimizer to test the assembly parameters
#echo $(date): Loading Velvet Optimizer
#velvetoptimiser/2.2.5

#the command have been adapted from https://github.com/tseemann/VelvetOptimiser
# I can't seem to get the optimizer to run because of some problem wit hthe fastq files. I am going to try to run Velvet and see if the problem crops of there too
#echo $(date): Running optimization
#VelvetOptimiser.pl -s 19 -e 31 -f '-fastq.gz -shortPaired -separate  1_QCQA/Dstr1Trim_1P.fq.gz 1_QCQA/Dstr1Trim_2P.fq.gz' -g 2000 -t $SLURM_NTASKS
#echo $(date): Done
