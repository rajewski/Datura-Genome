#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=7G
#SBATCH --time 9-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Predict-%A.out
set -e

ASSEM=subset_test/Dstr_v1.4.subset.fa
echo Running Funannotate predict on $ASSEM

module load funannotate/1.6.0
module unload CodingQuarry #unload the module or set the EVM weight to 0. it takes five-ever to complete!

#Set AUGUSTUS paths to the local copy
echo Setting AUGUSTUS path to local directories
AUGUSTUS_SCRIPTS_PATH=$(realpath ./augustus/scripts )
AUGUSTUS_BIN_PATH=$(realpath ./augustus/bin )
AUGUSTUS_CONFIG_PATH=$(realpath ./augustus/config )
echo $AUGUSTUS_SCRIPTS_PATH is the scripts path
echo $AUGUSTUS_BIN_PATH is the binaries path
echo $AUGUSTUS_CONFIG_PATH is the config path

<<<<<<< HEAD
funannotate predict \
    -i $ASSEM \
    -s "Datura stramonium Test 2" \
    -o subset_test \
    --name HAX54_ \
    --organism other \
    --genemark_mode ES \
    --repeats2evm \
    --optimize_augustus \
    --augustus_species datura_stramonium_test_1 \
    --busco_seed_species tomato \
    --busco_db embryophyta_odb9 \
    --cpus $SLURM_CPUS_PER_TASK
