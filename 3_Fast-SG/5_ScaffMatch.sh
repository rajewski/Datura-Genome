#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=101G
#SBATCH --time=20:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ../history/5_ScaffMatch-%A.out
set -eu

module load bowtie2/2.3.4.1
conda activate DaturaPy2

/rhome/arajewski/bigdata/Datura/software/ScaffMatch/scaffmatch \
  -m \
  -w Dstr-K22 \
  -c /rhome/arajewski/bigdata/Datura/2_MaSuRCA333/flye/assembly.fasta.2kb.fa \
  -s  194,397,600,803,1005,1208,1411,1614,1817,2020,3036,4050,5068,6092\
  -i  1943,3970,5998,8025,10053,12082,14111,16141,18172,20202,30359,40497,50681,60923 \
  -p fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr,fr \
  -1 ultra_ont_raw.I2000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I4000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I6000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I8000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I10000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I12000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I14000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I16000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I18000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I20000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I30000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I40000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I50000.FastSG_K22.sam.fwd.sam,ultra_ont_raw.I60000.FastSG_K22.sam.fwd.sam \
  -2 ultra_ont_raw.I2000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I4000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I6000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I8000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I10000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I12000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I14000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I16000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I18000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I20000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I30000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I40000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I50000.FastSG_K22.sam.rev.sam,ultra_ont_raw.I60000.FastSG_K22.sam.rev.sam



scontrol show job $SLURM_JOB_ID
