#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=9-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Predict-%A.out
set -e

ASSEM=Dstr_v1.4.masked.fa
BASE=Dstr_v1.4
RNAPATH=/rhome/arajewski/bigdata/Datura/RNA-seq


module load funannotate/1.6.0

funannotate predict \
    -i $ASSEM \
    -s "Datura stramonium" \
    --transcript_evidence $RNAPATH/20101112_Contigs.fa $RNAPATH/20100406_Contigs.fa \
    -o predict \
    --name Dstr \
    --organism other \
    --busco_seed_species arabidopsis \
    --busco_db embryophyta_odb9 \
    --max_intronlen 6000 \
    --cpus $SLURM_CPUS_PER_TASK

