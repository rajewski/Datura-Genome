#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=8G
#SBATCH --nodes=1
#SBATCH --time=4:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/STARAlignment-%A_%a.out
set -e

# This is meant to be run as an array job with IDs between 0 and 5 to specify the experiment to map
Expt=( WT_1 WT_2 WT_3 GFP_1 GFP_2 GFP_3 )
OUTDIR=STAR/${Expt[$SLURM_ARRAY_TASK_ID]}
mkdir -p $OUTDIR

# General STAR commands
module load STAR/2.5.3a
if [ ! -e ${OUTDIR}.Aligned.sortedByCoord.out.bam ]; then
    echo Mapping ${Expt[$SLURM_ARRAY_TASK_ID]}...
    STAR \
	--runThreadN $SLURM_CPUS_PER_TASK \
  	--genomeDir ./Index \
  	--outFileNamePrefix $OUTDIR. \
  	--outSAMtype BAM SortedByCoordinate \
  	--readFilesIn ../RNA-seq/${Expt[$SLURM_ARRAY_TASK_ID]}_R*_val_*.fq.gz \
  	--readFilesCommand zcat
    echo Done.
else
    echo ${Expt[$SLURM_ARRAY_TASK_ID]} already mapped.
fi
  
