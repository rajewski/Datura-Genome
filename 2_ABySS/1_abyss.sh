#!/bin/bash -l
#SBATCH --ntasks=32
#SBATCH --nodes=1
#SBATCH --mem=300G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/1_abyss-%A_%a.out
set -eu

#try a short read only assembly
#pass a kmer size with the array task id variable
module load ABYSS/2.0.2

mkdir -p k_$SLURM_ARRAY_TASK_ID
abyss-pe \
    np=$SLURM_NTASKS \
    name=Dstr_v1.3_k$SLURM_ARRAY_TASK_ID \
    -C k_$SLURM_ARRAY_TASK_ID \
    k=$SLURM_ARRAY_TASK_ID \
    lib='petrim' \
    petrim='/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq' \
    se='/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1U.fq /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2U.fq' 
 


scontrol show job $SLURM_JOB_ID
