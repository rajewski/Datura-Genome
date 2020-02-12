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

module load funannotate/git-live
ASSEMPATH=/rhome/arajewski/bigdata/Datura/3_BCGSC
BASE=Dstr_v1.4

#download the publically available RNA seq data
if [ ! -e ../RNA-seq/ERR2040631_1.fastq ]; then
    echo Downloading ERR2040631 data from SRA...
    cd /rhome/arajewski/bigdata/Datura/RNA-seq
    module load sratoolkit/2.10.0
    prefetch ERR2040631
    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files ERR2040631/
    cd /rhome/arajewski/bigdata/Datura/5_Funannotate
    echo Done.
else
    echo ERR2040631 data from SRA already present.
fi

if [ ! -e ../RNA-seq/SRR9888534_1.fastq ]; then
    echo Downloading SRR9888534 data from SRA...
    cd /rhome/arajewski/bigdata/Datura/RNA-seq
    module load sratoolkit/2.10.0
    prefetch SRR9888534
    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files SRR9888534/
    cd /rhome/arajewski/bigdata/Datura/5_Funannotate
    echo Done.
else
    echo SRR9888534 data from SRA already present.
fi

if [ ! -e ../RNA-seq/s_2_1_DATST_plant_1.fastq.gz ]; then
    echo Downloading MedPlantRNAseq data...
    cd /rhome/arajewski/bigdata/Datura/RNA-seq
    curl https://medplantrnaseq.org/assemblies/Datura_stramonium.tar.gz
    tar xf Datura_stramonium.tar.gz
    mv Datura_stramonium/s_2_1_DATST_plant_1.txt.gz ./s_2_1_DATST_plant_1.fastq.gz
    mv Datura_stramonium/s_2_2_DATST_plant_1.txt.gz ./s_2_2_DATST_plant_1.fastq.gz
    rm -Rf Datura_stramonium
    cd cd /rhome/arajewski/bigdata/Datura/5_Funannotate
    echo Done.
else
    echo MedPlantsRNAseq data already present.
fi

#actually train the predictor
funannotate train \
    -i $BASE.masked.fa \
    -o train \
    -l /rhome/arajewski/bigdata/Datura/RNA-seq/SRR9888534_1.fastq /rhome/arajewski/bigdata/Datura/RNA-seq/ERR2040631_1.fastq  \
    -r /rhome/arajewski/bigdata/Datura/RNA-seq/SRR9888534_2.fastq /rhome/arajewski/bigdata/Datura/RNA-seq/ERR2040631_2.fastq  \
    --max_intronlen 6000 \
    --species "Datura stramonium" \
    --cpus $SLURM_CPUS_PER_TASK \
    --PASAHOME /opt/linux/centos/7.x/x86_64/pkgs/PASA/2.3.3/
