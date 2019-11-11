#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=270G
#SBATCH --time=4-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/LINKS_k%a-%A.out
set -e

#Get env right
module load samtools/1.8
module load minimap2/2.17
export PATH=/rhome/arajewski/bigdata/Datura/software/RAILS_v1.5.1:$PATH
ASSEMBLY=/rhome/arajewski/bigdata/Datura/3_BCGSC/Dstr_v1.3_links11_k15.scaffolds.fa
LONGREADS=/rhome/arajewski/bigdata/Datura/2_MASURCA333/mr.41.15.15.0.02.1.fa

#consider running cobbler and RAILS separately
cobbler.pl \
    -f $ASSEMBLY \
    -q $LONGREADS \
    -p samtools \
    -d 250 \
    -g 250 \
    -v 1


exit 0

runRAILSminimap.sh \
    $ASSEMBLY \
    $LONGREADS \
    250 \
    0.95 \
    <max. softclip eg. 250bp> \
    2 \
    ont \
    samtools


scontrol show job $SLURM_JOB_ID
