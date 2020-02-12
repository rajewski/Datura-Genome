#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH --time=9-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/FA_Train-%A.out
set -e

ASSEMPATH=/rhome/arajewski/bigdata/Datura/3_BCGSC
RNAPATH=/rhome/arajewski/bigdata/Datura/RNA-seq
BASE=Dstr_v1.4

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


#actually train the predictor
module load funannotate/1.6.0
funannotate train \
    -i $BASE.masked.fa \
    -o train \
    -l $RNAPATH/SRR9888534_1.fastq.gz $RNAPATH/ERR2040631_1.fastq.gz \
    -r $RNAPATH/SRR9888534_2.fastq.gz $RNAPATH/ERR2040631_2.fastq.gz \
    --max_intronlen 6000 \
    --species "Datura stramonium" \
    --cpus $SLURM_CPUS_PER_TASK \
    --PASAHOME /opt/linux/centos/7.x/x86_64/pkgs/PASA/2.3.3/
