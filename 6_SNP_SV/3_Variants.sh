#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem=10G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Genotype-%A_%a.out

ASSEM=Datura_stramonium.scaffolds.5kb.fa
ln -sf ../$ASSEM Indices/$ASSEM

# Process the three samples as arrays with 0-2 as indicies
#GFPFiles=( GFP_1 GFP_2 GFP_3 )

# Use SpeedSeq to find variants
module load speedseq/a95704a
# First SNPs
if [ ! -e results/GFP_All.var.vcf.gz ]; then
    echo $(date): Calling SNPs, MNPs, and short InDels...
    speedseq var \
	-t $SLURM_CPUS_PER_TASK \
	-o results/GFP_All.var \
	-K ./speedseq.config \
	Indices/$ASSEM \
	results/GFP_1.dedup.sort.bam results/GFP_2.dedup.sort.bam results/GFP_3.dedup.sort.bam
    echo $(date): Done.
fi

# Then structural variants
if [ ! -e results/GFP_All.sv.vcf* ]; then
    echo $(date): Finding structural variants...
    conda activate speedseqEnv
    speedseq sv \
	-B results/GFP_1.dedup.sort.bam,results/GFP_2.dedup.sort.bam,results/GFP_3.dedup.sort.bam \
	-S results/GFP_1.dedup.split.sort.bam,results/GFP_2.dedup.split.sort.bam,results/GFP_3.dedup.split.sort.bam \
	-D results/GFP_1.dedup.disc.sort.bam,results/GFP_2.dedup.disc.sort.bam,results/GFP_3.dedup.disc.sort.bam \
	-t $SLURM_CPUS_PER_TASK \
	-R Indices/$ASSEM \
	-o results/GFP_All \
	-K ./speedseq.config
    echo $(date): Done.
fi
