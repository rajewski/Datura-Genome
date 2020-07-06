#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=4G
#SBATCH --nodes=1
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Prep-%A.out
set -e

module load funannotate/1.6.0
ASSEMPATH=/rhome/arajewski/bigdata/Datura/3_BCGSC/Dstr_v1.7_Iterative
ASSEM=Dstr_v1.7_lnr13_500bp_Sealer_ntEdit2_edited.fa
BASE=Dstr_v1.7
REPEATS=/bigdata/littlab/arajewski/Datura/4_RepeatModeler/Dstr_v1.7_final_Repeats/FinalRepeats.fa
mkdir -p ${BASE}_Annotation
cd ${BASE}_Annotation

#Clean the repetitive contigs
#skip this for masurca because it takes forever and doesnt remove much
# if [ ! -e $BASE.cleaned.fa ]; then
#     echo $(date): Running funannotate clean on $BASE...
#     funannotate clean \
#	-i $ASSEMPATH/$ASSEM \
#	-o $BASE.cleaned.fa \
#	--cpus $SLURM_CPUS_PER_TASK
#     echo $(date): Done.
# else
#     echo $(date): $BASE already cleaned
# fi

#Perform the sorting and renaming of contigs
if [ ! -e $BASE.sorted.fa ]; then
    echo $(date): Sorting $BASE...
    funannotate sort \
	-i $ASSEMPATH/$ASSEM \
	-o $BASE.sorted.fa
    echo $(date): Done.
else
    echo $(date): $BASE already sorted.
fi

#Repeat mask the assembly
if [ ! -e $BASE.masked.fa ]; then
    echo $(date): Masking $BASE...
    funannotate mask \
	-i $BASE.sorted.fa \
	-o $BASE.masked.fa \
	-l $REPEATS \
	--cpus $SLURM_CPUS_PER_TASK
    echo $(date): Done.
else
    echo $(date): $BASE.fa already masked.
fi
