#!/bin/bash -l
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=13G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/Trinity-%A.out
set -eu

GZLOC=/rhome/arajewski/bigdata/Datura/Alkaloids/Abel_trinity/Rcorrector

module load trinity-rnaseq/2.8.5
Trinity \
    --seqType fq \
    --left $GZLOC/ERR2040625_1_val_1.cor.fq.gz,$GZLOC/unfixrm_SRR118430_1_val_1.cor.fq.gz,$GZLOC/unfixrm_SRR192881_1_val_1.cor.fq.gz,$GZLOC/unfixrm_SRR9888536_1_val_1.cor.fq.gz,$GZLOC/unfixrm_SRR192882_1_val_1.cor.fq.gz,$GZLOC/unfixrm_SRR118431_1_val_1.cor.fq.gz,$GZLOC/unfixrm_SRR118439_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118440_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118438_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118432_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118435_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118436_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118437_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118433_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118429_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118441_1_trimmed.cor.fq.gz,$GZLOC/unfixrm_SRR118434_1_trimmed.cor.fq.gz  \
    --right $GZLOC/ERR2040625_2_val_2.cor.fq.gz,$GZLOC/unfixrm_SRR118430_2_val_2.cor.fq.gz,$GZLOC/unfixrm_SRR192881_2_val_2.cor.fq.gz,$GZLOC/unfixrm_SRR9888536_2_val_2.cor.fq.gz,$GZLOC/unfixrm_SRR192882_2_val_2.cor.fq.gz,$GZLOC/unfixrm_SRR118431_2_val_2.cor.fq.gz \
    --CPU $SLURM_CPUS_PER_TASK \
    --max_memory $((SLURM_MEM_PER_CPU*SLURM_CPUS_PER_TASK/1024))'G' \
    --output $GZLOC/Trinity
