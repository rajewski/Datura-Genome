#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --mem=500G
#SBATCH --time=30-0:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/spades-%A.out
set -euv

module load SPAdes/3.13.1

spades.py \
    --pe1-1 /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq \
    --pe1-2 /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq \
    --pe1-s /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1U.fq \
    --nanopore /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fastq.gz \
    -t $SLURM_CPUS_PER_TASK \
    -m $((SLURM_MEM_PER_NODE/1024)) \
    -o /rhome/arajewski/bigdata/Datura/2_SPAdes

scontrol show job $SLURM_JOB_ID
