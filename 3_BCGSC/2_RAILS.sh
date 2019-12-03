#!/bin/bash -l
#SBATCH --ntasks=32
#SBATCH --nodes=1
#SBATCH --mem=900G
#SBATCH --time=9-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ../history/RAILS-%A.out
set -e

#Get env right
module load samtools/1.8
module load minimap2/2.17
export PATH=/rhome/arajewski/bigdata/Datura/software/RAILS_v1.5.1:$PATH
ASSEMBLY=Dstr_v1.3_links14_k19.scaffolds.fa
LONGREADS=mr.41.15.15.0.02.1.fa


runRAILSminimapMod.sh \
    $ASSEMBLY \
    $LONGREADS \
    250 \
    0.95 \
    250 \
    2 \
    ont \
    ./


scontrol show job $SLURM_JOB_ID
