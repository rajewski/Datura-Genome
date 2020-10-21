#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=09:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/4a_BUSCO-%A.out
set -eu


#the point of this script is to assess the assembly with the BUSCO database
module swap miniconda2 miniconda3
module load busco/3.0.2
#We need to downgrade our blast version to make it work
module swap ncbi-blast ncbi-blast/2.2.30+

ASSEM=Dstr_v1.7_lnr13_500bp_Sealer_ntEdit2_edited.fa
ASSEMPATH=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.7_Iterative/$ASSEM
BUSCOOUT=20201005_MS_Final

#BUSCO also needs augustus, and because of the cluster environment I have to install it separately
export PATH="/rhome/arajewski/bigdata/Datura/software/augustus/bin:$PATH"
export PATH="/rhome/arajewski/bigdata/Datura/software/augustus/scripts:$PATH"
export AUGUSTUS_CONFIG_PATH="/rhome/arajewski/bigdata/Datura/software/augustus/config/"

# Remove the -r flag if you're starting fresh
run_BUSCO.py \
    -m genome \
    -sp tomato \
    -z \
    -c $SLURM_CPUS_PER_TASK \
    -i $ASSEMPATH \
    -o $BUSCOOUT \
    -l /srv/projects/db/BUSCO/v9/embryophyta_odb9/ \
    -r

scontrol show job $SLURM_JOB_ID
