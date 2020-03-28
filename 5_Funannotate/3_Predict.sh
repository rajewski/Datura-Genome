#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=7G
#SBATCH --time 7-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Predict-%A.out
set -e

ASSEM=Dstr_v1.4.masked.l5000.fa
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
    -s "Datura stramonium" \
    -o predict \
    --name HAX54_ \
    --organism other \
    --weights augustus:1 hiq:2 genemark:1 pasa:10 codingquarry:0 snap:1 glimmerhmm:1 proteins:1 transcripts:3 \
    --genemark_mode ET \
    --repeats2evm \
    --optimize_augustus \
    --busco_db embryophyta_odb9 \
    --max_intronlen 6000 \
    --cpus $SLURM_CPUS_PER_TASK
