#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=7G
#SBATCH --time 5-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Predict-%A.out
set -e
ASSEM=Dstr_v1.7_Annotation/Dstr_v1.7.masked.fa
echo Running Funannotate predict on $ASSEM

module unload perl
module unload python
module unload miniconda2
module unload anaconda3
module load miniconda2
module load funannotate/1.8.0
source activate funannotate-1.8
which diamond
which perl
module unload CodingQuarry #unload the module or set the EVM weight to 0. it takes five-ever to complete!

#Set AUGUSTUS paths to the local copy
echo Setting AUGUSTUS path to local directories
AUGUSTUS_SCRIPTS_PATH=$(realpath ./augustus/scripts )
AUGUSTUS_BIN_PATH=$(realpath ./augustus/bin )
AUGUSTUS_CONFIG_PATH=$(realpath ./augustus/config )
export FUNANNOTATE_DB=/opt/linux/centos/7.x/x86_64/pkgs/funannotate/1.8.0/DB
echo $AUGUSTUS_SCRIPTS_PATH is the scripts path
echo $AUGUSTUS_BIN_PATH is the binaries path
echo $AUGUSTUS_CONFIG_PATH is the config path
echo $FUNANNOTATE_DB is the database path

funannotate predict \
    -i $ASSEM \
    -s "Datura stramonium" \
    -o Dstr_v1.7_Annotation_largeIntrons \
    --name HAX54_ \
    --organism other \
    --genemark_mode ET \
    --repeats2evm \
    --weights augustus:1 hiq:6 genemark:1 pasa:10 codingquarry:0 snap:0 glimmerhmm:0 proteins:1 transcripts:1 \
    --busco_seed_species tomato \
    --busco_db embryophyta_odb9 \
    --cpus $SLURM_CPUS_PER_TASK
