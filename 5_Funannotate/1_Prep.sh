B#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=9-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Prep-%A.out
set -e

module load funannotate/1.6.0
ASSEMPATH=/rhome/arajewski/bigdata/Datura/3_BCGSC
ASSEM=Dstr_v1.4_ntEdit_edited.fa
BASE=Dstr_v1.4

#Clean the repetitive contigs
#this takes forever so I am skipping it for the moment
#if [ ! -e $BASE.cleaned.fa ]; then
#    echo $(date): Running funannotate clean on $ASSEM...
#    funannotate clean \
#	-i $ASSEMPATH/$ASSEM \
#	-o $BASE.cleaned.fa \
#	--cpus $SLURM_CPUS_PER_TASK
#    echo $(date): Done.
#else
#    echo $(date): $ASSEM already cleaned
#fi

#Perform the sorting and renaming of contigs
if [ ! -e $BASE.sorted.fa ]; then
    echo $(date): Sorting $BASE.fa...
    funannotate sort \
	-i $ASSEMPATH/$ASSEM \
	-o $BASE.sorted.fa
    echo $(date): Done.
else
    echo $(date): $BASE.fa already sorted.
fi

#Because the cleaning would remove small (<500bp) contigs. Let's do that here
module load BBMap
reformat.sh in=$BASE.sorted.fa out=$BASE.sorted.1.fa minlength=500
mv $BASE.sorted.1.fa $BASE.sorted.fa

#Repeat mask the assembly
if [ ! -e $BASE.masked.fa ]; then
    echo $(date): Masking $BASE.sorted.fa...
    funannotate mask \
	-i $BASE.sorted.fa \
	-o $BASE.masked.fa \
	-s "arabidopsis" \
	--cpus $SLURM_CPUS_PER_TASK
    echo $(date): Done.
else
    echo $(date): $BASE.sorted.fa already masked.
fi

