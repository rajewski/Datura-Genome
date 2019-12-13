#!/bin/bash -l
#SBATCH --cpus-per-task=16
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/ntEdit-%A.out
set -e
MEMORY=$((SLURM_MEM_PER_CPU/1024))G
ASSEM=Dstr_v1.3_LINKS14_RAILS_Sealer_scaffold.fa
kmer=50
#Get env right
export PATH=/rhome/arajewski/bigdata/Datura/software/bin:$PATH
export PATH=/rhome/arajewski/bigdata/Datura/software/ntEdit:$PATH

#Make bloom filter for desired kmer size
nthits \
    -t $SLURM_CPUS_PER_TASK \
    -k $kmer \
    -p Dstr_$kmer \
    --outbloom \
    --solid \
    /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq

ntedit \
    -f $ASSEM \
    -k $kmer \
#    -r Dstr_$kmer.bf \
    -b Dstr_v1.3_ntEdit \
    -v

scontrol show job $SLURM_JOB_ID
