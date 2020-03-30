#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time 03:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Fix-%A.out
set -e

WORKDIR=predict_20200329/predict_results
GBKASSEM=$WORKDIR/Datura_stramonium.gbk
GBKANNOT=$WORKDIR/Datura_stramonium.tbl

#make file of models to delete, default to deleting al problematic models
touch $WORKDIR/Datura_stramonium.models-to-delete.txt
grep -v "#" $WORKDIR/Datura_stramonium.models-need-fixing.txt | cut -f1 > $WORKDIR/Datura_stramonium.models-to-delete.txt
echo Running Funannotate fix on $GBKASSEM

module load funannotate/1.6.0

funannotate fix \
    -i $GBKASSEM \
    -t $GBKANNOT \
    -o $WORKDIR \
    -d $WORKDIR/Datura_stramonium.models-to-delete.txt
