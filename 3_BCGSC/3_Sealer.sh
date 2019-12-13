#!/bin/bash -l
#SBATCH --cpus-per-task=16
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Sealer-%A.out
set -e
MEMORY=$((SLURM_MEM_PER_CPU/1024))G

#Get env right
module load ABYSS/2.0.2
ASSEM=mr.41.15.15.0.02.1.fa_vs_Dstr_v1.3_links14_k19.scaffolds.fa_250_0.9_rails.scaffolds.fa

abyss-sealer \
    -v \
    -j $SLURM_CPUS_PER_TASK \
    -s $MEMORY \
    -b40G \
    -k30 \
    -k35 \
    -k40 \
    -k45 \
    -k50 \
    -k55 \
    -k60 \
    -k65 \
    -k70 \
    -k75 \
    -k80 \
    -k85 \
    -k90 \
    -k95 \
    -k100 \
    -k105 \
    -k110 \
    -k115 \
    -k120 \
    -k125 \
    -o Dstr_v1.3_LINKS14_RAILS_Sealer \
    -S $ASSEM \
    /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq
    

scontrol show job $SLURM_JOB_ID
