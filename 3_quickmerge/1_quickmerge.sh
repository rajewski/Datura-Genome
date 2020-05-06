#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=400G
#SBATCH --time=2-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /bigdata/littlab/arajewski/Datura/history/quickmerge-%A.out
set -e

module load mummer/4.0
export PATH=/rhome/arajewski/bigdata/Datura/software/quickmerge:$PATH

MASURCA=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.5_ntEdit_RAILS/lordecreads.fa_vs_Dstr_v1.5_n9_R1_n3_R1_n2_edited.fa_250_0.9_rails.scaffolds.fa
ABYSS=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.3_ntEdit_RAILS/Dstr_v1.3_n3_R1_n4_R1_n3_R1_n2_R1_n2_edited.fa
ln -sf $MASURCA masurca.fa
ln -sf $ABYSS abyss.fa

# Query then reference assemblies
merge_wrapper.py \
    -l 50000 \
    -v \
    -t $SLURM_CPUS_PER_TASK \
    abyss.fa  masurca.fa
