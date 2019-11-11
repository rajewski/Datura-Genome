#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --nodes=1
#SBATCH --mem=200G
#SBATCH --time=6-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/hercules-%A.out
set -eu
 
module load hercules/2017-Nov
#hercules -1 \
#    -li /rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fastq \
#    -si /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq \
#    -si /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq \
#    -o preprocessing/

#map illumina to nanopore
if [ ! -e DstrAlignment.sam ]; then
    module load minimap2
    echo $(date): generating minimap2 index 
    minimap2 \
	-x sr \
	-d Dstr.Nanopore.mmi \
	/rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fastq
    echo $(date): Minimap2 index created.
    echo $(date): Generating alignment with Minimap2
    minimap2 \
	-ax sr \
	-t $SLURM_CPUS_PER_TASK \
	Dstr.Nanopore.mmi \
	/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq /rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq > DstrAlignment.sam
    echo $(date) Done with minimap2
else
    echo $(date): minimap2 output SAM found.
fi

#Massage output SAM file
if [ ! -e /scratch/DstrAlignment.bam ]; then
    echo $(date): Converting, sorting, and deduplicating minimap2 output
    module load samtools/1.9
    MEM=$((SLURM_MEM_PER_NODE/1024))G
    samtools view -S -u -b DstrAlignment.sam | samtools sort -l 0 -@ $SLURM_CPUS_PER_TASK -m $MEM | samtools rmdup -S - DstrAlignment.bam
    mv /scratch/DstrAlignment.bam /rhome/arajewski/bigdata/Datura/1_hercules/DstrAlignment.bam
    echo $(date): Done
else
    echo $(date): Output SAM already converted.
fi

#only here for testing.
exit o

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
