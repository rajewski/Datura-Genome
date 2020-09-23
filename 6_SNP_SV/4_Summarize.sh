#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=7G
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/Summarize-%A.out

#ASSEM=Datura_stramonium.scaffolds.5kb.fa
#ln -sf ../$ASSEM Indices/$ASSEM

# Process the three samples as arrays with 0-2 as indicies
#GFPFiles=( GFP_1 GFP_2 GFP_3 )

# Summarize the VCFs
if [ ! -e results/GFP_All.summary.txt ]; then
    echo $(date): Summarizing VCFs with bcftools...
    module load bcftools
    bcftools stats \
	--threads $SLURM_CPUS_PER_TASK \
	-s - \
	-c all \
	results/GFP_All.sv.vcf.gz results/GFP_All.var.vcf.gz > results/GFP_All.summary.txt
    echo $(date): Done
fi

# Make some plots of the bcftools sumary
if [ ! -e results/Summary/summary.pdf ]; then
    echo $(date): Plotting results...
    module swap miniconda2 miniconda3
    plot-vcfstats -p ./results/Summary/ \
	results/GFP_All.summary.txt
    echo $(date): Done.
fi

# Now Summarize by genomic interval and effect
if [ ! -e snpEff/Dstr_v1.7/snpEffectPredictor.bin ]; then
    #building this database took about 15 hours, so don't delete it unless you really really need to
    module load snpEff/4.3t
    mkdir -p snpEff/Dstr_v1.7
    ln -sf /bigdata/littlab/arajewski/Datura/5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/annotate_results/Datura_stramonium.gbk snpEff/Dstr_v1.7/genes.gbk
    echo $(date): Make sure you edit the snpEff.config file to add this genome.
    echo $(date): Building database for Dstr_v1.7...
    java -jar $SNPEFFJAR build \
	-genbank \
	-c ./snpEff/snpEff.config \
	-datadir ./ \
	Dstr_v1.7
    echo $(date): Done.
fi

# Merge the VCFs from speedseq for simplicity
if [ ! -e results/GFP_All.merged.vcf.gz ]; then
    echo $(date): Merginf SV and VAR VCF files into one...
    module load bcftools
    bcftools concat \
	-a \
	-d all \
	-o results/GFP_All.merged.vcf.gz \
	-O z \
	--threads $SLURM_CPUS_PER_TASK \
	results/GFP_All.var.vcf.gz results/GFP_All.sv.vcf.gz
    echo $(date): Done.
fi

# Annotate and summarize the SNPs
module load snpEff/4.3t
java -jar $SNPEFFJAR ann \
    -c snpEff/snpEff.config \
    -datadir ./ \
    -s results/Summary/snpEff_Summary.html \
    Dstr_v1.7 \
    results/GFP_All.merged.vcf.gz
