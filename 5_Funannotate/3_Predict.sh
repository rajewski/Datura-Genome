#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=7G
#SBATCH --time=4-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Predict-%A.out
set -e

ASSEM=Dstr_v1.4.masked.fa
BASE=Dstr_v1.4
RNAPATH=/rhome/arajewski/bigdata/Datura/RNA-seq

module load funannotate/1.6.0
#unload coding quarry to stop it from taking forever on this step
module unload CodingQuarry

#confirm that augustus config path is present and writeable
if [ ! -w $AUGUSTUS_CONFIG_PATH ]; then
    echo Augustus config path not writeable. Checking if a local directory exists...
    if [ -e ./augustus/config ] && [ -w ./augustus/config ]; then
	echo Local and writeable augustus directory found. 
	AUGUSTUS_CONFIG_PATH=$(realpath ./augustus/config)
	echo Augustus config path changed to local directory.
    else
	echo No locally writeable directory found. Copying shared directory...
	mkdir -p augustus
	cp -R /opt/linux/centos/7.x/x86_64/pkgs/miniconda3/4.3.31/envs/funannotate/config/* augustus/
	AUGUSTUS_CONFIG_PATH=$(realpath ./augustus/config)
	echo Localy writeable directory created. You may proceed.
    fi
else
    echo Augustus config path is writeable. You may proceed.
fi

#I finally got the training algorithm to work, so I am passing in that information instead of the assembled MedPlantRNA seq transcriptome
funannotate predict \
    -i $ASSEM \
    -s "Datura stramonium" \
    -o train \
    --name Dstr \
    --organism other \
    --busco_seed_species tomato \
    --busco_db embryophyta_odb9 \
    --max_intronlen 6000 \
    --cpus $SLURM_CPUS_PER_TASK
