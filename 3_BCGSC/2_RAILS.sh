#!/bin/bash -l
#SBATCH --cpus-per-task=60
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH -p short
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/RAILS-%A.out
set -e

#Get env right
module load samtools/1.8
module load minimap2/2.17
export PATH=/rhome/arajewski/bigdata/Datura/software/RAILS_v1.5.1:$PATH

ASSEMBLY=Dstr_v1.7_l1n2r1n3_l1n3r1n3_l1n3r1n3r1n2_l1n2r1n2_l1n2r1n2_l1n2r1n2_l1n2r1n1_l1n2r1n1_l1n2r1n1_l1n2r1n1_l1n2_l1n2_l1n2_edited.fa
LONGREADS=lordecreads.fa
ln -sf Dstr_v1.7_Iterative/Dstr_v1.7_l1n2r1n3_l1n3r1n3_l1n3r1n3r1n2_l1n2r1n2_l1n2r1n2_l1n2r1n2_l1n2r1n1_l1n2r1n1_l1n2r1n1_l1n2r1n1_l1n2_l1n2_l1n2_edited.fa $ASSEMBLY

runRAILSminimapMod.sh \
    $ASSEMBLY \
    $LONGREADS \
    250 \
    0.9 \
    250 \
    1 \
    ont \
    /opt/linux/centos/7.x/x86_64/pkgs/samtools/1.8/bin/samtools

# Clean up and move outputs
mv ${LONGREADS}_* Dstr_v1.7_Iterative/
rm ${LONGREADS}-formatted.fof 
rm ${ASSEMBLY}-formatted.fa
rm $ASSEMBLY

scontrol show job $SLURM_JOB_ID
