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

MASURCA=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.5_Iterative/lordecreads.fa_vs_Dstr_v1.5_n5r1_n4r1_n2.fa_250_0.9_rails.scaffolds.fa
ABYSS=/bigdata/littlab/arajewski/Datura/3_BCGSC/Dstr_v1.3_Iterative/lordecreads.fa_vs_Dstr_v1.3_n2r1_n4r1_n3r1_n2r1_n2.fa_250_0.9_rails.scaffolds.fa
ln -sf $MASURCA masurca.fa
ln -sf $ABYSS abyss.fa

# Query then reference assemblies, first with abyss as the reference, n50 is the l parameter
if [ ! -d ABySS_Ref ]; then
merge_wrapper.py \
    -l 5000 \
    -v \
    -t $SLURM_CPUS_PER_TASK \
    masurca.fa abyss.fa
mkdir -p ABySS_Ref
mv anchor_summary_out.txt merged_out.fasta aln_summary_out.tsv param_summary_out.txt out.delta out.rq.delta ABySS_Ref/mv  ABySS_Ref/
rm hybrid_oneline.fa self_oneline.fa
fi

# second with masruca as the reference
if [ ! -d MaSuRCA_Ref ]; then
merge_wrapper.py \
    -l 100000 \
    -v \
    -t $SLURM_CPUS_PER_TASK \
    abyss.fa masurca.fa
mkdir -p MaSuRCA_Ref
 mv anchor_summary_out.txt merged_out.fasta aln_summary_out.tsv param_summary_out.txt out.delta out.rq.delta MaSuRCA_Ref/
rm hybrid_oneline.fa self_oneline.fa
fi

# Merge the most contiguous 
ln -sf ABySS_Ref/merged_out.fasta abyss_ref.fa
merge_wrapper.py \
    -l 100000 \
    -v \
    -t $SLURM_CPUS_PER_TASK \
    abyss.fa abyss_ref.fa
