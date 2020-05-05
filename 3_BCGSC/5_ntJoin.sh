#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=40G
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /bigdata/littlab/arajewski/Datura/history/ntJoin-%A.out
set -e

TARGETPATH=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.5_ntEdit_RAILS/lordecreads.fa_vs_Dstr_v1.5_n9_R1_n3_R1_n2_edited.fa_250_0.9_rails.scaffolds.fa
REFERENCEPATH=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.3_ntEdit_RAILS/Dstr_v1.3_n3_R1_n4_R1_n3_R1_n2_R1_n2_edited.fa
REFERENCESHORT=Dstr_v1.3.fa
ln -sf $TARGETPATH Target.fa
ln -sf $REFERENCEPATH $REFERENCESHORT

conda activate Datura
#had to edit the ntJoin file to change the time command options to no longer include -v and -o
ntJoin assemble \
    target=Target.fa \
    references=$REFERENCESHORT \
    t=$SLURM_CPUS_PER_TASK \
    reference_weights='2' \
    w=300
    
