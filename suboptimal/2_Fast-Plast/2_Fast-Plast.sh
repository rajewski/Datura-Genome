#!/bin/bash -l
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=90G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p batch
#SBATCH -o ../history/2_Fast-Plast-%A.out
#set -eu

module load trimmomatic/0.36
module load bowtie/1.2.2
module load bowtie2/2.3.4.1
module load SPAdes/3.13.1
module load sspace-standard/3.0
module load jellyfish/2.3.0
module load ncbi-blast/2.2.30+

../software/Fast-Plast/fast-plast.pl \
    -1 ../DNA-seq/Alex-1_S9_R1_001.fastq \
    -2 ../DNA-seq/Alex-2_S10_R1_001.fastq \
    -adapters TruSeq \
    -n Dstr \
    --subsample 40000000 \
    --threads $SLURM_NTASKS \
    --coverage_analysis \
    --bowtie_index Solanales \
    --clean light
