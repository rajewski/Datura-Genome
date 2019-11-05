#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=101G
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ../history/5_ScaffMatch-%A.out
set -e

module load bowtie2/2.3.4.1
module swap miniconda3 miniconda2
conda activate DaturaPy2

/rhome/arajewski/bigdata/Datura/software/ScaffMatch/scaffmatch \
  -m \
  -w Dstr_v1.3_k101-K22_z100 \
  -c /rhome/arajewski/bigdata/Datura/2_ABySS/k_101/Dstr_v1.3_k101-scaffolds.fa \
  -s 41,92,193,396,599,802,1000,1208,1400,1600,1800,2000,3000,4000,5000,6000,7000,8000,10000,12000,15000,18000 \
  -i 414,921,1934,3961,5990,8019,10042,12067,14000,16000,18000,20000,30000,40000,50000,60000,70000,80000,100000,120000,150000,180000 \
  -p fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr \
  -1 ultra_ont_raw.I500.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I1000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I2000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I4000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I6000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I8000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I10000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I12000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I14000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I16000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I18000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I20000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I30000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I40000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I50000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I60000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I70000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I80000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I100000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I120000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I150000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I180000.FastSG_K22.sam.fwd.sam \
  -2 ultra_ont_raw.I500.FastSG_K22.sam.rev.sam,ultra_ont_raw.I1000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I2000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I4000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I6000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I8000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I10000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I12000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I14000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I16000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I18000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I20000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I30000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I40000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I50000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I60000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I70000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I80000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I100000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I120000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I150000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I180000.FastSG_K22.sam.rev.sam



scontrol show job $SLURM_JOB_ID
