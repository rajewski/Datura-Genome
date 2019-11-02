#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=101G
#SBATCH --time=2-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ../history/5_ScaffMatch-%A.out
set -eu

module load bowtie2/2.3.4.1
conda activate DaturaPy2

/rhome/arajewski/bigdata/Datura/software/ScaffMatch/scaffmatch \
  -m \
  -w Dstr_v1.3_k101-K22 \
  -c /rhome/arajewski/bigdata/Datura/2_ABySS/k_101/Dstr_v1.3_k101-scaffolds.fa.2kb.fa \
  -s  193,396,598,801,1003,1205,1400,1600,1800,2000\
  -i  1931,3955,5983,8009,10032,12053,14111,16141,18172,20000 \
  -p fr,fr,fr,fr,fr,fr,fr,fr,fr,fr \
  -1 ultra_ont_raw.I2000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I4000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I6000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I8000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I10000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I12000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I14000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I16000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I18000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I20000.FastSG_K22.sam.fwd.sam \
  -2 ultra_ont_raw.I2000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I4000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I6000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I8000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I10000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I12000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I14000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I16000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I18000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I20000.FastSG_K22.sam.rev.sam



scontrol show job $SLURM_JOB_ID
