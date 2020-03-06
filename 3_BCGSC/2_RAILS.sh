#!/bin/bash -l
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/RAILS-%A.out
set -e

#Get env right
module load samtools/1.8
module load minimap2/2.17
export PATH=/rhome/arajewski/bigdata/Datura/software/RAILS_v1.5.1:$PATH
ASSEMBLY=Dstr_v1.4_links13_k19.scaffolds.fa
LONGREADS=lordecreads.fa


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
