#!/bin/bash -l
<<<<<<< HEAD
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
=======
#SBATCH --ntasks=16
#SBATCH --nodes=1
#SBATCH --mem=100G
>>>>>>> 9efeed3e9c9b15cbda8836d80196efcbd64ec6f6
#SBATCH --time=09:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/4a_BUSCO-%A.out
set -eu


#the point of this script is to assess the assembly with the BUSCO database
module unload miniconda2
module load miniconda3
module load busco/3.0.2
#We need to downgrade our blast version to make it work
module unload ncbi-blast
module load ncbi-blast/2.2.30+
<<<<<<< HEAD
ASSEM=Slyc.transcripts.fa
ASSEMPATH=/bigdata/littlab/arajewski/Datura/Alkaloids/ExternalData/Slyc/$ASSEM
BUSCOOUT=Slyc4.0
=======
ASSEM=Dstr_v1.4.masked.l5000.fa
ASSEMPATH=/rhome/arajewski/bigdata/Datura/5_Funannotate/$ASSEM 
>>>>>>> 9efeed3e9c9b15cbda8836d80196efcbd64ec6f6

#BUSCO also needs augustus, and because of the cluster environment I have to install it separately
export PATH="/rhome/arajewski/bigdata/Datura/software/augustus/bin:$PATH"
export PATH="/rhome/arajewski/bigdata/Datura/software/augustus/scripts:$PATH"
export AUGUSTUS_CONFIG_PATH="/rhome/arajewski/bigdata/Datura/software/augustus/config/"

#I really don't like this sincle core blast, but i can't get it to run correctly otherwise.
#also remove the -r flag if you're starting fresh
run_BUSCO.py \
<<<<<<< HEAD
    -m transcriptome \
=======
    -m genome \
>>>>>>> 9efeed3e9c9b15cbda8836d80196efcbd64ec6f6
    -sp tomato \
    -z \
    -c $SLURM_NTASKS \
    -i $ASSEMPATH \
<<<<<<< HEAD
    -o $BUSCOOUT \
=======
    -o $ASSEM \
>>>>>>> 9efeed3e9c9b15cbda8836d80196efcbd64ec6f6
    -l /srv/projects/db/BUSCO/v9/embryophyta_odb9/ 

scontrol show job $SLURM_JOB_ID
