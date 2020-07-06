#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Train-%A.out
set -e

RNAPATH=/rhome/arajewski/bigdata/Datura/RNA-seq
ASSEM=Dstr_v1.7_Annotation/Dstr_v1.7.masked.fa

#actually train the predictor
module load funannotate/1.6.0
#change PASA directory becuase the flag below doesnt work
PASAHOME=/opt/linux/centos/7.x/x86_64/pkgs/PASA/2.3.3/

funannotate train \
    -i $ASSEM \
    -o Dstr_v1.7_Annotation \
    -l $RNAPATH/SRR9888534_Trimmed_1P.fastq.gz $RNAPATH/MedPlantTrimmed_1P.fastq.gz $RNAPATH/WT_1_R1_val_1.fq.gz $RNAPATH/WT_2_R1_val_1.fq.gz $RNAPATH/WT_3_R1_val_1.fq.gz \
    -r $RNAPATH/SRR9888534_Trimmed_2P.fastq.gz $RNAPATH/MedPlantTrimmed_2P.fastq.gz $RNAPATH/WT_1_R2_val_2.fq.gz $RNAPATH/WT_1_R2_val_2.fq.gz $RNAPATH/WT_1_R2_val_2.fq.gz \
    --no_trimmomatic \
    --species "Datura stramonium" \
    --cpus $SLURM_CPUS_PER_TASK 
