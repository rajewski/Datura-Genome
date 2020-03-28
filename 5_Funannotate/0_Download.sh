#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=02:00:00
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
    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --defline-qual '+$sn[_$rn]/$ri' --split-files --gzip -B ERR2040631/
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
    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --defline-qual '+$sn[_$rn]/$ri' --split-files -B --gzip SRR9888534/
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
    echo Done.
    echo Editing sequence and quality headers to match...
    gunzip s_2_1_DATST_plant_1.fastq.gz
    gunzip s_2_2_DATST_plant_1.fastq.gz
    sed -i 's/\(^@[[:graph:]]*\)\( [[:graph:]]*\)/\1/g' s_2_1_DATST_plant_1.fastq
    sed -i 's/\(^@[[:graph:]]*\)\( [[:graph:]]*\)/\1/g' s_2_2_DATST_plant_1.fastq
    pigz s_2_1_DATST_plant_1.fastq
    pigz s_2_2_DATST_plant_1.fastq
    #I think you may need to load BBMap's reformat.sh to convert the ASCII of the phred scores
    rm -Rf Datura_stramonium
    cd $SLURM_SUBMIT_DIR
    echo Done.
else
    echo MedPlantsRNAseq data already present.
fi

#Download the assembled contigs for the MEdPlan Data
if [ ! -e $RNAPATH/20100406_Contigs.fa ]; then
	echo Downloading MedPlantRNAseq Transcriptome 1...
	cd $RNAPATH
	wget https://medplantrnaseq.org/assemblies/datura_stramonium-20100406.tgz
	tar xf datura_stramonium-20100406.tgz
	mv datura_stramonium-20100406/contigs.fa ./20100406_Contigs.fa
	rm -Rf datura_stramonium-20100406
	cd $SLURM_SUBMIT_DIR
	echo Done.
else
    echo MedPlantRNAseq Transcriptome 1 already present.
fi

if [ ! -e $RNAPATH/20101112_Contigs.fa ]; then
    echo Downloading MedPlantRNAseq Transcriptome 2...
    cd $RNAPATH
    wget https://medplantrnaseq.org/assemblies/datura_stramonium-20101112.tgz
    tar xf datura_stramonium-20101112.tgz
    mv datura_stramonium-20101112/contigs.fa ./20101112_Contigs.fa
    rm -Rf datura_stramonium-20101112
    cd $SLURM_SUBMIT_DIR
    echo Done.
else
    echo MedPantRNAseq Transcriptome 2 already present.
fi

#Trim the Downloaded RNA seq data. I think this is necessary because of differing phred scores and some formatting between the various sources
if [ ! -e $RNAPATH/MedPlantTrimmed_2P.fastq.gz ]; then
    echo Running Trimmomatic on MedPlantRNAseq and converting phred scores...
    module load trimmomatic
    java -jar $TRIMMOMATIC PE \
	-threads $SLURM_CPUS_PER_TASK \
	-phred64 \
	$RNAPATH/s_2_1_DATST_plant_1.fastq.gz $RNAPATH/s_2_2_DATST_plant_1.fastq.gz \
	-baseout $RNAPATH/MedPlantTrimmed.fastq.gz \
	ILLUMINACLIP:/opt/linux/centos/7.x/x86_64/pkgs/trimmomatic/0.36/adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:5 LEADING:5 TRAILING:5 MINLEN:25 TOPHRED33
    echo Done.
else
    echo MedPlant RNA seq already trimmed and converted.
fi

if [ ! -e $RNAPATH/ERR2040631_Trimmed_2P.fastq.gz ]; then
    echo Running Trimmomatic on ERR2040631 RNAseq...
    module load trimmomatic
    java -jar $TRIMMOMATIC PE \
        -threads $SLURM_CPUS_PER_TASK \
        $RNAPATH/ERR2040631_1.fastq.gz $RNAPATH/ERR2040631_2.fastq.gz \
        -baseout $RNAPATH/ERR2040631_Trimmed.fastq.gz \
        ILLUMINACLIP:/opt/linux/centos/7.x/x86_64/pkgs/trimmomatic/0.36/adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:5 LEADING:5 TRAILING:5 MINLEN:25
    echo Done.
else
    echo  ERR2040631 RNAseq already trimmed.
fi

if [ ! -e $RNAPATH/SRR9888534_Trimmed_2P.fastq.gz ]; then
    echo Running Trimmomatic on SRR9888534 RNAseq...
    module load trimmomatic
    java -jar $TRIMMOMATIC PE \
        -threads $SLURM_CPUS_PER_TASK \
        $RNAPATH/SRR9888534_1.fastq.gz $RNAPATH/SRR9888534_2.fastq.gz \
        -baseout $RNAPATH/SRR9888534_Trimmed.fastq.gz \
        ILLUMINACLIP:/opt/linux/centos/7.x/x86_64/pkgs/trimmomatic/0.36/adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:5 LEADING:5 TRAILING:5 MINLEN:25
    echo Done.
else
    echo SRR9888534 RNAseq already trimmed.
fi
