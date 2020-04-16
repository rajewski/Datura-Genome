#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=7G
#SBATCH --time 4-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Predict-%A.out
set -e

ASSEM=Dstr_v1.5.masked.fa
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

funannotate predict \
    -i $ASSEM \
    -s "Datura stramonium 4" \
    -o Dstr_v1.5_predict \
    --weights augustus:1 hiq:6 genemark:0 pasa:10 codingquarry:0 snap:0 glimmerhmm:0 proteins:1 transcripts:1 \
    --name HAX54_ \
    --organism other \
    --genemark_mode ES \
    --repeats2evm \
    --optimize_augustus \
    --busco_db embryophyta_odb9 \
    --cpus $SLURM_CPUS_PER_TASK
