#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/getOrganelle-%A.out

#conda create -n organelleEnv python=3.7 getorganelle
conda activate organelleEnv

get_organelle_from_reads.py \
    -1 ../DNA-seq/Alex_S230_L002_R1_001.fastq.gz \
    -2 ../DNA-seq/Alex_S230_L002_R2_001.fastq.gz \
    -o 20201009_Ref_plastome \
    -s ./NC_018117.1.fasta \
    -R 15 \
    -k 21,45,65,85,105  \
    -F embplant_pt \
    -t $SLURM_CPUS_PER_TASK

