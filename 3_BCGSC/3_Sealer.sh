#!/bin/bash -l
#SBATCH --cpus-per-task=16
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Sealer-%A.out
set -e
MEMORY=$((SLURM_MEM_PER_CPU/1024))G

#Get env right
module load ABYSS/2.0.2
ASSEM=Dstr_v1.4_ntEdit_RAILS/lordecreads.fa_vs_Dstr_v1.4_ntEdit3_RAILS_ntEdit2_edited.fa_250_0.9_rails.scaffolds.fa

#with pre-built bloom filters from 3a_BloomBuild.sh

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
   -i k30.bloom \
   -i k35.bloom \
   -i k40.bloom \
   -i k45.bloom \
   -i k50.bloom \
   -i k55.bloom \
   -i k60.bloom \
   -i k65.bloom \
   -i k70.bloom \
   -i k75.bloom \
   -i k80.bloom \
   -i k85.bloom \
   -i k90.bloom \
   -i k95.bloom \
   -i k100.bloom \
   -i k105.bloom \
   -i k110.bloom \
   -i k115.bloom \
   -i k120.bloom \
   -i k125.bloom \
    -o Dstr_v1.4_RAILS2_Sealer \
    -S $ASSEM
#    /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq
    

scontrol show job $SLURM_JOB_ID
