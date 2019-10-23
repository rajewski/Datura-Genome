#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=4G
#SBATCH --time=00:20:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/4_splitSAM-%A-%a.out
set -eu

SAMList=(ultra_ont_raw.I*.FastSG_K22.sam)
Library=${SAMList[$SLURM_ARRAY_TASK_ID]}

awk -f /rhome/arajewski/bigdata/Datura/software/fastsg/misc/fastSG2scaff.awk -v name=$(basename $Library) -v k=22 $Library
