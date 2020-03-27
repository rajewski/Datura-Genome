#!/bin/bash -l
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=7G
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/Trinity-%A.out
set -e

#Index Genomes
module load samtools/1.10

#Make an associateve array to hold genomes and paths
declare -A GENOMES
GENOMES=([Cann]=GCA_000512255.2_ASM51225v2_genomic.fna [Natt]=GCF_001879085.1_NIATTr2_genomic.fna [Paxi]=Petunia_axillaris_v1.6.2_genome.fasta [Slyc]=S_lycopersicum_chromosomes.4.00.fa )

for GNM in ${!GENOMES[@]}; do
    if [ ! -e ExternalData/$GNM/*.fai ]; then
	echo Indexing $GNM...
	if [ -e ExternalData/$GNM/${GENOMES[$GNM]}.gz ]; then
	    echo Unzipping genome...
	    gunzip ExternalData/$GNM/${GENOMES[$GNM]}.gz
	    echo Done.
	fi
	samtools faidx ExternalData/$GNM/${GENOMES[$GNM]}
	echo Done.
    else
	echo Index for $GNM already completed.
    fi
done

#Extract Transcript Fasta files
module load cufflinks/2.2.1
#Make another associative array for the GFFs
declare -A GFFs
GFFs=([Cann]=GCA_000512255.2_ASM51225v2_genomic.gff [Natt]=GCF_001879085.1_NIATTr2_genomic.gff [Paxi]=Petunia_axillaris_v1.6.2_gene_models.gff [Slyc]=ITAG4.0_gene_models.gff )

for GNOM in ${!GFFs[@]}; do
    if [ ! -e ExternalData/$GNOM/$GNOM.transcripts.fa ]; then
	echo Extracting $GNOM transcriptomes from the genome...
	if [ -e ExternalData/$GNOM/${GTFs[$GNOM]}.gz ]; then
	    echo Unzipping GFF...
	    gunzip ExternalData/$GNOM/${GTFs[$GNOM]}.gz
	    echo Done.
	fi
	gffread -w ExternalData/$GNOM/$GNOM.transcripts.fa -g ExternalData/$GNOM/${GENOMES[$GNOM]} ExternalData/$GNOM/${GFFs[$GNOM]}
	echo Done.
    else
	echo $GNOM transciptome already extracted.
    fi
done

#Make BLAST (or DIAMOND? databases
