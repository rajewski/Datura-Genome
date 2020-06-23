#!/bin/bash -l
#SBATCH --cpus-per-task=16
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH -p short
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Sealer-%A_%a.out
set -e
MEMORY=$((SLURM_MEM_PER_CPU/1024))G

#Get env right
module load ABYSS/2.0.2
mkdir -p Bloomfilters

abyss-bloom build \
    -vv \
    -k$SLURM_ARRAY_TASK_ID \
    -j$SLURM_CPUS_PER_TASK \
    -b40G \
    -l2 \
    Bloomfilters/k$SLURM_ARRAY_TASK_ID.bloom \
    /rhome/arajewski/bigdata/Datura/1_QCQA/PE2_1.fq.gz /rhome/arajewski/bigdata/Datura/1_QCQA/PE2_2.fq.gz
   

scontrol show job $SLURM_JOB_ID
