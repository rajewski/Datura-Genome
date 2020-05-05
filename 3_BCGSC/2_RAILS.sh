#!/bin/bash -l
#SBATCH --cpus-per-task=60
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/RAILS-%A.out
set -e

#Get env right
module load samtools/1.8
module load minimap2/2.17
export PATH=/rhome/arajewski/bigdata/Datura/software/RAILS_v1.5.1:$PATH
ASSEMBLY=Dstr_v1.3_j1_R1_n3.fa
LONGREADS=lordecreads.fa
ln -sf Dstr_v1.3_ntEdit_RAILS/Dstr_v1.3_j1_R1_n3_edited.fa $ASSEMBLY
# unfold the fasta file if necessary
#awk 'BEGIN {RS=">";FS="\n";OFS=""} NR>1 {print ">"$1; $1=""; print}' /bigdata/littlab/arajewski/Datura/2_MaSuRCA338/flye/assembly.fasta > $ASSEMBLY

runRAILSminimapMod.sh \
    $ASSEMBLY \
    $LONGREADS \
    250 \
    0.9 \
    250 \
    1 \
    ont \
    /opt/linux/centos/7.x/x86_64/pkgs/samtools/1.8/bin/samtools


scontrol show job $SLURM_JOB_ID
