#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=80G
#SBATCH --time=2-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/loredec-%A.out
set -euv

module load loredec/0.9
lordec-correct \
    -i /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fastq \
    -2 /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq,/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq,/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1U.fq,/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2U.fq \
    -k 19 \
    -s 3 \
    -t $SLURM_NTASKS \
    -o Dstr.filt_q10_l500_crop50_loredec.fasta

scontrol show job $SLURM_JOB_ID
