#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=31
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Train-%A.out
set -e

ASSEMPATH=/rhome/arajewski/bigdata/Datura/5_Funannotate
RNAPATH=/rhome/arajewski/bigdata/Datura/RNA-seq
BASE=Dstr_v1.4

#actually train the predictor
module load funannotate/1.6.0
#change PASA directory becuase the flag below doesnt work
PASAHOME=/opt/linux/centos/7.x/x86_64/pkgs/PASA/2.3.3/

funannotate  train \
    -i $BASE.masked.l5000.fa \
    -o predict \
    -l $RNAPATH/SRR9888534_Trimmed_1P.fastq.gz $RNAPATH/MedPlantTrimmed_1P.fastq.gz \
    -r $RNAPATH/SRR9888534_Trimmed_2P.fastq.gz $RNAPATH/MedPlantTrimmed_2P.fastq.gz \
    --no_trimmomatic \
    --no_normalize_reads \
    --max_intronlen 6000 \
    --species "Datura stramonium" \
    --cpus $SLURM_CPUS_PER_TASK 
