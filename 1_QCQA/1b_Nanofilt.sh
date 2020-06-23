#!/bin/bash -l
#SBATCH --ntasks=4
#SBATCH --nodes=1
#SBATCH --mem=150G
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p highmem
#SBATCH -o ./history/1b_Nanofilt-%A.out
set -euv

#This uses the output from guppy-gpu (executed by Jason Stajich) and trims the output reads from a Nanopore run

module load miniconda3
source activate nanopore
DIR=/bigdata/stajichlab/shared/projects/nanopore/FlowCells/Dstr1_20190620_2222_MN20245_FAK67939_1d4a8e21/guppy_fastq
SMRY=/bigdata/stajichlab/shared/projects/nanopore/FlowCells/Dstr1_20190620_2222_MN20245_FAK67939_1d4a8e21/logs/sequencing_summary.txt.gz

pigz -dc $DIR/*.fastq.gz | NanoFilt -q 10 -l 500 --headcrop 50 -s $SMRY | pigz -c > Dstr.filt_q10_l500_crop50.fastq.gz
