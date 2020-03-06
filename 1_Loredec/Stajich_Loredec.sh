#!/usr/bin/bash
#SBATCH -p stajichlab -N 1 -n 48 --mem 96gb --out lordec-correct.log

module load loredec
module load boost
module load intel

CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPUS ]; then
 CPU=1
fi
date
echo "${SLURM_ARRAY_JOB_ID}[${SLURM_ARRAY_TASK_ID}]"
sleep 60
hostname

CPU=$SLURM_CPUS_ON_NODE

if [ -z $CPU ]; then
	CPU=1
fi
lordec-correct -2 AV1_paired.fq.gz -k 19 -s 3 -i Pacbio_Cornell.fasta.gz -o pacbio-corrected.fasta -T $CPU
