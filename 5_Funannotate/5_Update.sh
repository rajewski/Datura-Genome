#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=15
#SBATCH --mem-per-cpu=7G
#SBATCH --time 12-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Update-%A.out
set -e

WORKDIR=Dstr_v1.7_Annotation_largeIntrons_174
module unload miniconda2
module unload anaconda3
module load miniconda3
module unload perl
module unload python
module load funannotate/1.7.4
#source activate funannotate-1.8
#module load funannotate/1.6.0
#change PASA directory becuase the flag below doesnt work
#PASAHOME=/opt/linux/centos/7.x/x86_64/pkgs/PASA/2.3.3/
export PASACONF=/bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/pasa.CONFIG.template

funannotate update \
    -i $WORKDIR \
    --cpus $SLURM_CPUS_PER_TASK \
    --sbt template.sbt \
    --pasa_config $PASACONF \
    --pasa_db mysql \
    --max_intronlen 7000 \
    --SeqCenter "University of California"
