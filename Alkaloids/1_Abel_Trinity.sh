#!/bin/bash -l
#SBATCH --ntasks=32
#SBATCH --nodes=1
#SBATCH --mem=400G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/Trinity-%A.out
set -eu

module load trinity-rnaseq/2.8.5

Trinity \
    --seqType fq \
    --max_memory $((SLURM_MEM_PER_CPU/1024))'G' \
    --left ExternalData/Abel/ERR2040625_1.fastq.gz,ExternalData/Abel/SRR118430_1.fastq.gz,ExternalData/Abel/SRR118431_1.fastq.gz,ExternalData/Abel/SRR192881_1.fastq.gz,ExternalData/Abel/SRR192882_1.fastq.gz,ExternalData/Abel/SRR9888536_1.fastq.gz  \
    --right ExternalData/Abel/ERR2040625_2.fastq.gz,ExternalData/Abel/SRR118430_2.fastq.gz,ExternalData/Abel/SRR118431_2.fastq.gz,ExternalData/Abel/SRR192881_2.fastq.gz,ExternalData/Abel/SRR192882_2.fastq.gz,ExternalData/Abel/SRR9888536_2.fastq.gz \
    --single ExternalData/Abel/SRR118429_1.fastq.gz,ExternalData/Abel/SRR118432_1.fastq.gz,ExternalData/Abel/SRR118433_1.fastq.gz,ExternalData/Abel/SRR118434_1.fastq.gz,ExternalData/Abel/SRR118435_1.fastq.gz,ExternalData/Abel/SRR118436_1.fastq.gz,ExternalData/Abel/SRR118437_1.fastq.gz,ExternalData/Abel/SRR118438_1.fastq.gz,ExternalData/Abel/SRR118439_1.fastq.gz,ExternalData/Abel/SRR118440_1.fastq.gz,ExternalData/Abel/SRR118441_1.fastq.gz \
    --CPU $SLURM_CPUS_PER_TASK \
    --max_memory 400G \
    --trimmomatic \
    --output Abel_trinity
