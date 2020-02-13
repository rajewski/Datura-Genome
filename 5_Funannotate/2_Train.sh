#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=9-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Train-%A.out
set -e

#I cant get this working and I suspect it has something to do with formatting issues with reads from SRA


ASSEMPATH=/rhome/arajewski/bigdata/Datura/3_BCGSC
RNAPATH=/rhome/arajewski/bigdata/Datura/RNA-seq
BASE=Dstr_v1.4


#actually train the predictor
module load funannotate/1.6.0
funannotate train \
    -i $BASE.masked.fa \
    -o train \
    -l $RNAPATH/SRR9888534_1.fastq.gz $RNAPATH/ERR2040631_1.fastq.gz \
    -r $RNAPATH/SRR9888534_2.fastq.gz $RNAPATH/ERR2040631_2.fastq.gz \
    --max_intronlen 6000 \
    --species "Datura stramonium" \
    --cpus $SLURM_CPUS_PER_TASK \
    --PASAHOME /opt/linux/centos/7.x/x86_64/pkgs/PASA/2.3.3/
