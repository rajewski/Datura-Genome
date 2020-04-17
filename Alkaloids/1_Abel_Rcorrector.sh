#!/bin/bash -l
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=5G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/Rcorrector-%A.out
set -eu

GZLOC=/rhome/arajewski/bigdata/Datura/Alkaloids/Abel_trinity
mkdir -p $GZLOC/Rcorrector
module load jellyfish/2.3.0

# Do a kmer based read correction with RCorrector
perl /bigdata/littlab/arajewski/Datura/software/rcorrector/run_rcorrector.pl \
    -s $GZLOC/SRR118439_1_trimmed.fq.gz,$GZLOC/SRR118440_1_trimmed.fq.gz,$GZLOC/SRR118438_1_trimmed.fq.gz,$GZLOC/SRR118432_1_trimmed.fq.gz,$GZLOC/SRR118435_1_trimmed.fq.gz,$GZLOC/SRR118436_1_trimmed.fq.gz,$GZLOC/SRR118437_1_trimmed.fq.gz,$GZLOC/SRR118433_1_trimmed.fq.gz,$GZLOC/SRR118429_1_trimmed.fq.gz,$GZLOC/SRR118441_1_trimmed.fq.gz,$GZLOC/SRR118434_1_trimmed.fq.gz \
    -1 $GZLOC/ERR2040625_1_val_1.fq.gz,$GZLOC/SRR118430_1_val_1.fq.gz,$GZLOC/SRR192881_1_val_1.fq.gz,$GZLOC/SRR9888536_1_val_1.fq.gz,$GZLOC/SRR192882_1_val_1.fq.gz,$GZLOC/SRR118431_1_val_1.fq.gz \
    -2 $GZLOC/ERR2040625_2_val_2.fq.gz,$GZLOC/SRR118430_2_val_2.fq.gz,$GZLOC/SRR192881_2_val_2.fq.gz,$GZLOC/SRR9888536_2_val_2.fq.gz,$GZLOC/SRR192882_2_val_2.fq.gz,$GZLOC/SRR118431_2_val_2.fq.gz \
    -t $SLURM_CPUS_PER_TASK \
    -od $GZLOC/Rcorrector

