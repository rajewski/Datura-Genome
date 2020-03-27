#!/bin/bash -l
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=13G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/Trinity-%A.out
set -eu

GZLOC=/rhome/arajewski/bigdata/Datura/Alkaloids/Abel_trinity

module load trinity-rnaseq/2.8.5
Trinity \
    --seqType fq \
    --left $GZLOC/ERR2040625_1_val_1.fq.gz,$GZLOC/SRR118430_1_val_1.fq.gz,$GZLOC/SRR192881_1_val_1.fq.gz,$GZLOC/SRR9888536_1_val_1.fq.gz,$GZLOC/SRR192882_1_val_1.fq.gz,$GZLOC/SRR118431_1_val_1.fq.gz,$GZLOC/SRR118439_1_trimmed.fq.gz,$GZLOC/SRR118440_1_trimmed.fq.gz,$GZLOC/SRR118438_1_trimmed.fq.gz,$GZLOC/SRR118432_1_trimmed.fq.gz,$GZLOC/SRR118435_1_trimmed.fq.gz,$GZLOC/SRR118436_1_trimmed.fq.gz,$GZLOC/SRR118437_1_trimmed.fq.gz,$GZLOC/SRR118433_1_trimmed.fq.gz,$GZLOC/SRR118429_1_trimmed.fq.gz,$GZLOC/SRR118441_1_trimmed.fq.gz,$GZLOC/SRR118434_1_trimmed.fq.gz  \
    --right $GZLOC/ERR2040625_2_val_2.fq.gz,$GZLOC/SRR118430_2_val_2.fq.gz,$GZLOC/SRR192881_2_val_2.fq.gz,$GZLOC/SRR9888536_2_val_2.fq.gz,$GZLOC/SRR192882_2_val_2.fq.gz,$GZLOC/SRR118431_2_val_2.fq.gz  \
    --CPU $SLURM_CPUS_PER_TASK \
    --max_memory $((SLURM_MEM_PER_CPU*SLURM_CPUS_PER_TASK/1024))'G' \
    --output $GZLOC
