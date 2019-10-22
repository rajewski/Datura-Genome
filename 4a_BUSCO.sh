#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=100G
#SBATCH --time=6-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ./history/4a_BUSCO-%A.out
set -euv


#the point of this script is to assess the assembly with the BUSCO database

module load busco/3.0.2
#We need to downgrade our blast version to make it work
module unload ncbi-blast
module load ncbi-blast/2.2.30+
ASSEM=Dstr_v1.1_SolanaceaeBUSCO
ASSEMPATH=/rhome/arajewski/bigdata/Datura/2_MaSuRCA333/flye/assembly.fasta

#BUSCO also needs augustus, and because of the cluster environment I have to install it separately
export PATH="/rhome/arajewski/bigdata/Datura/software/augustus/bin:$PATH"
export PATH="/rhome/arajewski/bigdata/Datura/software/augustus/scripts:$PATH"
export AUGUSTUS_CONFIG_PATH="/rhome/arajewski/bigdata/Datura/software/augustus/config/"

#I really don't like this sincle core blast, but i can't get it to run correctly otherwise.
#also remove the -r flag if you're starting fresh
run_BUSCO.py \
    -m genome \
    -c $SLURM_NTASKS \
    -i $ASSEMPATH \
    -o $ASSEM \
    -l /rhome/arajewski/bigdata/Datura/software/solanaceae_odb10

scontrol show job $SLURM_JOB_ID
