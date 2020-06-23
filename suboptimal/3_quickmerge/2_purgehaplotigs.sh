#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=7G
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /bigdata/littlab/arajewski/Datura/history/purge_haplotigs-%A.out
set -e

# Index merged genome with HISAT2
module load bwa/0.7.17
if [ ! -e  merged_out.fasta.sa ]; then
    bwa index merged_out.fasta
fi

# Map each library to the reference genome
DNAPATH=/bigdata/littlab/arajewski/Datura/DNA-seq
PELIB=( Alex_S85_L002 Alex_S230_L002 )
for i in ${!PELIB[@]}
do
    if [ ! -e ${PELIB[i]}.sam ]; then
	bwa mem \
	    -t $SLURM_CPUS_PER_TASK \
	    merged_out.fasta \
	    $DNAPATH/${PELIB[i]}_R1_001.fastq.gz \
	    $DNAPATH/${PELIB[i]}_R2_001.fastq.gz > ${PELIB[i]}.sam
    fi
    if [ ! -e ${PELIB[i]}.s.bam ]; then
	echo Sorting and Converting sam file
	module load samtools/1.10
	samtools sort  -o ${PELIB[i]}.s.bam ${PELIB[i]}.sam
    fi
done

SELIB=( Alex-1_S9 Alex-2_S10 )
for i in ${!SELIB[@]}
do
    if [ ! -e ${SELIB[i]}.sam ]; then
        bwa mem \
            -t $SLURM_CPUS_PER_TASK \
            merged_out.fasta \
            $DNAPATH/${SELIB[i]}_R1_001.fastq.gz  > ${SELIB[i]}.sam
    fi
    if [ ! -e ${SELIB[i]}.s.bam ]; then
        echo Sorting and Converting sam file
        module load samtools/1.10
        samtools sort  -o ${SELIB[i]}.s.bam ${SELIB[i]}.sam
    fi
done

# Merge the SAM files
if [ ! -e AllReads.bam ]; then
    module load samtools/1.10
    samtools merge \
	-@ $SLURM_CPUS_PER_TASK \
	AllReads.bam \
	${PELIB[0]}.s.bam \
	${PELIB[1]}.s.bam \
	${SELIB[0]}.s.bam \
	${SELIB[1]}.s.bam 
fi

# Generate haplotug histogram file
module load purge_haplotigs/1.0.4
purge_haplotigs readhist \
    -b AllReads.bam \
    -g merged_out.fasta \
    -t $SLURM_CPUS_PER_TASK
