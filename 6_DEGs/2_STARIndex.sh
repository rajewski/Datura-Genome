#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=20G
#SBATCH --nodes=1
#SBATCH --time=2:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/STARIndex-%A.out
set -e

DstrDIR=/rhome/arajewski/bigdata/Datura/6_DEGs/Index
mkdir -p $DstrDIR

module load STAR/2.5.3a
# Make index files for Nobt
if [ ! -e $DstrDIR/SAindex ]; then
    echo Making STAR index for D. stramonium...
    STAR \
        --runThreadN $SLURM_CPUS_PER_TASK \
        --runMode genomeGenerate \
        --genomeDir $DstrDIR/ \
        --genomeFastaFiles ../5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/predict_results/Datura_stramonium.scaffolds.fa \
        --sjdbGTFfile ../5_Funannotate/Dstr_v1.7_Annotation_largeIntrons_174/predict_results/Datura_stramonium.gff3  \
        --sjdbOverhang 100 \
        --sjdbGTFtagExonParentTranscript Parent \
	--genomeChrBinNbits 16 \
	--limitSjdbInsertNsj 300000 \
	--limitGenomeGenerateRAM  75000000000
    #Add limitSjdbInsertNsj because of error (https://groups.google.com/forum/#!msg/rna-star/ddhJDgvZfNA/ULUGGYb0BgAJ)
    #Change genomeChrBinNbits because the genome is highly fragmented
    echo Done.
else
    echo STAR index for D. stramonium already present.
fi
