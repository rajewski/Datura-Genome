#!/bin/bash -l
#SBATCH --ntasks=32
#SBATCH --nodes=1
#SBATCH --mem=40G
#SBATCH --time=6-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/hercules-%A.out
set -euv
 
module load hercules/2017-Nov
#hercules -1 \
#    -li /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fastq \
#    -si /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq \
#    -si /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq \
#    -o preprocessing/

#map illumina to nanopore
if [ ! -e alignment.sam ]; then
    module load minimap2
    echo $(date): running minimap2
    minimap2 \
	-a /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fastq \
	-t $SLURM_NTASKS \
	/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq > alignment.sam
    echo $(date) Done with minimap2
else
    echo $(date): minimap2 output SAM found.
fi

#Massage output SAM file
if [ ! -e alignment.bam ]; then
    echo $(date): Converting, sorting, and deduplicating minimap2 output
    module load samtools/1.9
    MEM=$((SLURM_MEM_PER_NODE/1024))
    samtools view -S -u -b alignment.sam | samtools sort -l 0 -@ $SLURM_NTASKS -m $MEM | samtools rmdup -S - alignment.bam
    echo $(date): Done
else
    echo $(date): Output SAM already converted.
fi

#Actually run hercules
if [ ! -e Dstr_Nanopore_HerculesCorrected.fasta ]; then
    echo $(date): Beginning long read correction with hercules
    hercules -2 \
	-li /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fastq \
	-ai alignment.bam \
	-si /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq \
	-si /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq \
	-t $SLURM_NTASKS \
	-o Dstr_Nanopore_HerculesCorrected.fasta
    echo $(date): Done
else
    echo $(date): Hercules correction already completed.
fi
