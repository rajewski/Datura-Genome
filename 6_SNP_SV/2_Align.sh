#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem=15G
#SBATCH --time=2:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -p short
#SBATCH -o ../history/Align-%A_%a.out

ASSEM=Datura_stramonium.scaffolds.5kb.fa
# Process the three samples as arrays with 0-2 as indicies
GFPFiles=( GFP_1 GFP_2 GFP_3 )
mkdir -p results/

module load bwa/0.7.17
# Make the index if necessary, but really do this ahead of time
if [ ! -e Indices/$ASSEM.ann ]; then
    echo $(date): Making BWA index of $ASSEM. This will need A LOT of RAM...
    bwa index -p Indices/$ASSEM $ASSEM
    echo $(date): Done.
else
    echo $(date): BWA index of $ASSEM found.
fi 

# Do the alignment
if [ ! -e results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.sam ]; then
    echo $(date): Aligning reads for ${GFPFiles[$SLURM_ARRAY_TASK_ID]}...
    bwa mem \
	-t $SLURM_CPUS_PER_TASK \
	Indices/$ASSEM \
	-M \
	-R "@RG\tID:${GFPFiles[$SLURM_ARRAY_TASK_ID]}\tSM:${GFPFiles[$SLURM_ARRAY_TASK_ID]}\tLB:lib" \
	../DNA-seq/${GFPFiles[$SLURM_ARRAY_TASK_ID]}_Trim/${GFPFiles[$SLURM_ARRAY_TASK_ID]}_R1_val_1.fq.gz ../DNA-seq/${GFPFiles[$SLURM_ARRAY_TASK_ID]}_Trim/${GFPFiles[$SLURM_ARRAY_TASK_ID]}_R2_val_2.fq.gz > results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.sam
    echo $(date): Done.
else
    echo $(date): ${GFPFiles[$SLURM_ARRAY_TASK_ID]} already aligned.
fi

# Remove duplicates, flag split and discordant reads
if [ ! -e results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.bam ]; then
    echo $(date): Deduplicating then finding split or discordant reads...
    export PATH=/bigdata/littlab/arajewski/Datura/software/samblaster-v.0.1.26:$PATH
    samblaster \
	-i results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.sam \
	-e \
	-M \
	-o results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.sam \
	-d results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.sam \
	-s results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.sam
    if [ -e results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.sam ]; then
	module load samtools/1.10
	echo $(date): Compressing and cleaning up SAM files...
	samtools view -bS -@ $((SLURM_CPUS_PER_TASK-1)) results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.sam > results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.bam
	if [ -e results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.bam ]; then
	    rm results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.sam
	    samtools sort -@ $((SLURM_CPUS_PER_TASK-1)) -o results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.sort.bam results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.bam
            samtools index -@ $((SLURM_CPUS_PER_TASK-1)) results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.sort.bam
	fi
	if [ -e results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.sam ]; then
	    samtools view -bS -@ $((SLURM_CPUS_PER_TASK-1)) results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.sam > results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.bam
	    if [ -e results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.bam ]; then
		rm results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.sam
                samtools sort -@ $((SLURM_CPUS_PER_TASK-1)) -o results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.sort.bam results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.bam
		samtools index -@ $((SLURM_CPUS_PER_TASK-1)) results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.disc.sort.bam
	    fi
	fi
	if [ -e results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.sam ]; then
            samtools view -bS -@ $((SLURM_CPUS_PER_TASK-1)) results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.sam > results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.bam
            if [ -e results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.bam ]; then
                rm results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.sam
		samtools sort -@ $((SLURM_CPUS_PER_TASK-1)) -o results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.sort.bam results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.bam
                samtools index -@ $((SLURM_CPUS_PER_TASK-1)) results/${GFPFiles[$SLURM_ARRAY_TASK_ID]}.dedup.split.sort.bam
            fi
        fi
    fi
    echo $(date): Done.
else
    echo $(date): Deduplicated alignment already present.
fi
