#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=40G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/ntJoin-%A.out
set -e

if [ ! -e Target1.fa ]; then
    ln -s ~/bigdata/Datura/3_BCGSC/Dstr_v1.4_ntEdit_edited.fa Target1.fa
fi
if [ ! -e Target2.fa ]; then
    ln -s /rhome/arajewski/bigdata/Datura/2_ABySS/k_101/Dstr_v1.3_k101-8.fa Target2.fa
fi
if [ ! -e SL40.fa ]; then
    ln -s ~/bigdata/Datura/DNA-seq/S_lycopersicum_chromosomes.4.00.fa SL40.fa
fi

conda activate Datura
#had to edit the ntJoin file to change the time command options to no longer include -v and -o
ntJoin assemble \
    target=Target2.fa \
    references=SL40.fa \
    t=$SLURM_CPUS_PER_TASK \
    reference_weights='2' \
    w=300
    
