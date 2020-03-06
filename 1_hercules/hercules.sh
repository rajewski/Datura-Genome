#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=5G
#SBATCH --time=20-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/hercules-%A.out
set -eu
 
module load hercules/2017-Nov
module load samtools/1.9
#trying this with fasta long reads instead of fastq
NANOPORE=/rhome/arajewski/bigdata/Datura/1_QCQA/Dstr.filt_q10_l500_crop50.fasta

#subsample the illumina reads to speed things up
if [ ! -e DstrTrim_1P_subsample.fq ]; then
    module load BBMap
    echo $(date): Subsampling short reads to 50%...
    reformat.sh \
	in1=/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_1P.fq \
	in2=/rhome/arajewski/bigdata/Datura/1_QCQA/DstrTrim_2P.fq \
	out1=DstrTrim_1P_subsample.fq \
	out2=DstrTrim_2P_subsample.fq \
	samplerate=0.5
    echo $(date): Done.
else
    echo $(date): Subsampling already complete.
fi

#Preprocess step of hercules
if [ ! -e preprocessing/compressed_short.fasta ]; then
    echo $(date): Preprocessing with hercules...
    hercules -1 \
	-li $NANOPORE \
	-si DstrTrim_1P_subsample.fq \
	-si DstrTrim_2P_subsample.fq \
	-o preprocessing/
    echo $(date): Done.
fi

#map illumina to nanopore
COMPNANOPORE=preprocessing/compressed_Dstr.filt_q10_l500_crop50.fasta
#try mapping with bowtie2, long but maybe it'll actually work
#module load bowtie2/2.3.4.1
#runBowtieRmDup.sh $COMPNANOPORE preprocessing/compressed_short.fasta bowtie $SLURM_CPUS_PER_TASK

if [ ! -e Dstr.CompNanopore.mmi ]; then
    module load minimap2
    echo $(date): Generating minimap2 index...
    minimap2 \
	-x sr \
	-I 7G \
	-d Dstr.CompNanopore.mmi \
	$COMPNANOPORE
    echo $(date): Done.
else
    echo $(date): Minimap2 index already present.
fi

if [ ! -e DstrCompAlignment.sam ]; then
    echo $(date): Generating alignment with Minimap2...
    minimap2 \
	-ax sr \
	-I 7G \
	-t $SLURM_CPUS_PER_TASK \
	Dstr.CompNanopore.mmi \
	preprocessing/compressed_short.fasta \
	-o DstrCompAlignment.sam
    echo $(date) Done with minimap2.
else
    echo $(date): Minimap2 output SAM found.
fi

#Massage output SAM file
if [ ! -e DstrCompAlignment.bam ]; then
    echo $(date): Converting and sorting minimap2 output...
    module load samtools/1.9
    samtools view -S -b -T $COMPNANOPORE DstrCompAlignment.sam | samtools sort -l 0 -@ $SLURM_CPUS_PER_TASK -m $((SLURM_MEM_PER_CPU/1024))G -o DstrCompAlignment.bam
    echo $(date): Done.
else
    echo $(date): BAM file already present.
fi

if [ ! -e DstrCompAlignmentNoDup.bam ]; then
    echo $(date): Deduplicating BAM file...
    module load samtools/1.9
    samtools rmdup -S DstrCompAlignment.bam DstrCompAlignmentNoDup.bam
    echo $(date): Done.
else
    echo $(date): Deduplication already complete.
fi

#echo $(date): rerun this script but alter each cpu to have more memory, I think
#exit 0

#Actually run hercules
if [ ! -e Dstr_Nanopore_Hercules_Corrected.fasta ]; then
    echo $(date): Beginning long read correction with hercules
    hercules -2 \
	-li $NANOPORE \
	-ai DstrCompAlignmentNoDup.bam \
	-si preprocessing/short.fasta \
	-t $SLURM_CPUS_PER_TASK \
	-o Dstr_Nanopore_Hercules_Corrected.fasta
    echo $(date): Done
else
    echo $(date): Hercules correction already completed.
fi
