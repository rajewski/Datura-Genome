#!/bin/bash -l
#SBATCH --ntasks=30
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/1_abyss-%A_%a.out
set -eu

# Could also pass a kmer size with the array task id variable
module load ABYSS/2.0.2

mkdir -p k_101
abyss-pe \
    np=$SLURM_NTASKS \
    name=Dstr_v1.3_k101 \
    -C k_101 \
    k=101 \
    lib='petrim1 petrim2' \
    petrim1='/rhome/arajewski/bigdata/Datura/1_QCQA/PE1_1.fq.gz /rhome/arajewski/bigdata/Datura/1_QCQA/PE1_2.fq.gz' \
    petrim2='/rhome/arajewski/bigdata/Datura/1_QCQA/PE2_1.fq.gz /rhome/arajewski/bigdata/Datura/1_QCQA/PE2_2.fq.gz' \
    se='/rhome/arajewski/bigdata/Datura/1_QCQA/SE1.fq.gz /rhome/arajewski/bigdata/Datura/1_QCQA/SE2.fq.gz' 
 


scontrol show job $SLURM_JOB_ID
