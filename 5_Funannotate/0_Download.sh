#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=10:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Download-%A.out
set -e

ASSEMPATH=/rhome/arajewski/bigdata/Datura/3_BCGSC
RNAPATH=/rhome/arajewski/bigdata/Datura/RNA-seq

#download the publically available RNA seq data
if [ ! -e $RNAPATH/ERR2040631_1.fastq.gz ]; then
    echo Downloading ERR2040631 data from SRA...
    cd $RNAPATH
    module load sratoolkit/2.10.0
    if [ ! -d ERR2040631 ]; then
	prefetch ERR2040631
    fi
    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files -B --gzip ERR2040631/
    cd $SLURM_SUBMIT_DIR
    echo Done.
else
    echo ERR2040631 data from SRA already present.
fi

if [ ! -e $RNAPATH/SRR9888534_1.fastq.gz ]; then
    echo Downloading SRR9888534 data from SRA...
    cd $RNAPATH
    module load sratoolkit/2.10.0
    if [ ! -d SRR9888534 ]; then
	prefetch SRR9888534
    fi
    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files -B --gzip SRR9888534/
    cd $SLURM_SUBMIT_DIR
    echo Done.
else
    echo SRR9888534 data from SRA already present.
fi

if [ ! -e $RNAPATH/s_2_1_DATST_plant_1.fastq.gz ]; then
    echo Downloading MedPlantRNAseq data...
    cd $RNAPATH
    curl https://medplantrnaseq.org/assemblies/Datura_stramonium.tar.gz
    tar xf Datura_stramonium.tar.gz
    mv Datura_stramonium/s_2_1_DATST_plant_1.txt.gz ./s_2_1_DATST_plant_1.fastq.gz
    mv Datura_stramonium/s_2_2_DATST_plant_1.txt.gz ./s_2_2_DATST_plant_1.fastq.gz
    #I think you may need to load BBMap's reformat.sh to convert the ASCII of the phred scores
    rm -Rf Datura_stramonium
    cd $SLURM_SUBMIT_DIR
    echo Done.
else
    echo MedPlantsRNAseq data already present.
fi

if [ ! -e $RNAPATH/20100406_Contigs.fa ]; then
	echo Downloading MedPlantRNAseq Transcriptome 1...
	cd $RNAPATH
	wget https://medplantrnaseq.org/assemblies/datura_stramonium-20100406.tgz
	tar xf datura_stramonium-20100406.tgz
	mv datura_stramonium-20100406/contigs.fa ./20100406_Contigs.fa
	rm -Rf datura_stramonium-20100406
	cd $SLURM_SUBMIT_DIR
	echo Done.
fi

if [ ! -e $RNAPATH/20101112_Contigs.fa ]; then
    echo Downloading MedPlantRNAseqTranscriptome 2...
    cd $RNAPATH
    wget https://medplantrnaseq.org/assemblies/datura_stramonium-20101112.tgz
    tar xf datura_stramonium-20101112.tgz
    mv datura_stramonium-20101112/contigs.fa ./20101112_Contigs.fa
    rm -Rf datura_stramonium-20101112
    cd $SLURM_SUBMIT_DIR
    echo Done.
fi
