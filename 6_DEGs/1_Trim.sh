#!/bin/bash -l
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=7G
##SBATCH --time=6:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/TrimGalore-%A.out
set -e

# Trim with Trim_Galore to remove low quality bases and adaptor sequences
module unload perl
module swap miniconda2 miniconda3
module swap python/2.7.5 python/3.6.0
module load fastqc
conda activate cutadaptenv
export PATH=/bigdata/littlab/arajewski/Datura/software/TrimGalore-0.6.5:$PATH

#Pass a list of PE vs SE datasets
PAIRS=(WT_1 WT_2 WT_3 GFP_1 GFP_2 GFP_3 )

#Do PE data
for PESRA in ${PAIRS[@]}; do
    if [ ! -e ../RNA-seq/${PESRA}_R2_val_2.fq.gz ]; then
	echo Running Trim Galore on $PESRA. ...
	trim_galore \
	    --paired \
	    -j $SLURM_CPUS_PER_TASK \
	    -o ../RNA-seq/ \
            ../RNA-seq/${PESRA}_*.fastq.gz 
	echo Done.
    else
	echo $PESRA RNA seq already trimmed.
    fi
done
