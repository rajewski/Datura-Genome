#!/bin/bash -l
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=7G
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o /rhome/arajewski/bigdata/Datura/history/GetGenomes-%A.out
set -e

# Assume that the GFF, GBK, and/or FASTA files are already present, unzipped, and named in the species.tsv file
while read ABBREV FASTA GFF
do
        echo "Name     : $ABBREV"
        echo "Sequence: $FASTA"
        echo "Annotations  : $GFF"
done < ./species.tsv


SpeciesList=./species.tsv
SpeciesData=(awk "NR==$SLURM_ARRAY_TASK_ID" $SpeciesList) #this file has a header so start arrays at 1
ABBREV=$(echo $SpeciesData | cut -f 1)




#Index Genomes
#Make an associateve array to hold genomes and paths
declare -A GENOMES
GENOMES=([Cann]=GCA_000512255.2_ASM51225v2_genomic.fna [Natt]=GCF_001879085.1_NIATTr2_genomic.fna [Paxi]=Petunia_axillaris_v1.6.2_genome.fasta [Slyc]=S_lycopersicum_chromosomes.4.00.fa )
module load samtools/1.10
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

#Why is petunia the problem child?? 
sed 's/PredictionNote/prediction_note/' ExternalData/Paxi/Petunia_axillaris_v1.6.2_gene_models.gff > ExternalData/Paxi/Petunia_axillaris_v1.6.2_gene_models.gff1
sed 's/AltID/alt_id/' ExternalData/Paxi/Petunia_axillaris_v1.6.2_gene_models.gff1 > ExternalData/Paxi/Petunia_axillaris_v1.6.2_gene_models.gff

#Extract Transcript Fasta files
#Make another associative array for the GFFs
declare -A GFFs
#There is a problem with the petunia genome annotation so I'm excluding it for now
#GFFs=([Cann]=GCA_000512255.2_ASM51225v2_genomic.gff [Natt]=GCF_001879085.1_NIATTr2_genomic.gff [Paxi]=Petunia_axillaris_v1.6.2_gene_models.gff [Slyc]=ITAG4.0_gene_models.gff )
GFFs=([Cann]=GCA_000512255.2_ASM51225v2_genomic.gff [Natt]=GCF_001879085.1_NIATTr2_genomic.gff [Slyc]=ITAG4.0_gene_models.gff )
module load genometools/1.5.9
for GNOM in ${!GFFs[@]}; do
    if [ ! -e ExternalData/$GNOM/$GNOM.transcripts.fa ]; then
	echo Extracting $GNOM transcriptomes from the genome...
	if [ -e ExternalData/$GNOM/${GTFs[$GNOM]}.gz ]; then
	    echo Unzipping GFF...
	    gunzip ExternalData/$GNOM/${GTFs[$GNOM]}.gz
	    echo Done.
	fi
	gt gff3 -sortlines -retainids yes -force yes -checkids yes -o ExternalData/$GNOM/${GFFs[$GNOM]}.1 ExternalData/$GNOM/${GFFs[$GNOM]}
	mv ExternalData/$GNOM/${GFFs[$GNOM]}.1 ExternalData/$GNOM/${GFFs[$GNOM]}
	gt extractfeat -type CDS -join yes -retainids yes -seqfile ExternalData/$GNOM/${GENOMES[$GNOM]} -o ExternalData/$GNOM/$GNOM.transcripts.fa -matchdescstart ExternalData/$GNOM/${GFFs[$GNOM]}
	gt extractfeat -type CDS -join yes -retainids yes -translate yes -seqfile ExternalData/$GNOM/${GENOMES[$GNOM]} -o ExternalData/$GNOM/$GNOM.proteins.fa -matchdescstart ExternalData/$GNOM/${GFFs[$GNOM]}
	echo Done.
    else
	echo $GNOM transciptome already extracted.
    fi
done

#Fix Bad Translations
sed -i 's/\*$//g' ExternalData/Slyc/Slyc.proteins.fa 
sed -i 's/\*/N/g' ExternalData/Slyc/Slyc.proteins.fa 
sed -i 's/\*$//g' ExternalData/Nobt/Nobt.proteins.fa
sed -i 's/\*/N/g' ExternalData/Nobt/Nobt.proteins.fa
sed -i 's/mRNA\://g' ExternalData/Slyc/Slyc.proteins.fa

#Fix duplicate transcripts by hand
#grep -iPA1 "\>\S+$" ExternalData/Paxi/Paxi.transcripts.fa > Paxi.transcripts.fa1
#mv ExternalData/Paxi/Paxi.transcripts.fa1 ExternalData/Paxi/Paxi.transcripts.fa

#Make BLAST databases
module load ncbi-blast/2.2.30+
for GNOM in ${!GFFs[@]}; do
    if [ ! -e ExternalData/$GNOM/$GNOM.transcripts.blastdb.nhr ]; then
	echo Making BLAST database for $GNOM...
	makeblastdb -in ExternalData/$GNOM/$GNOM.transcripts.fa \
	    -dbtype nucl \
	    -parse_seqids \
	    -out ExternalData/$GNOM/$GNOM.transcripts.blastdb \
	    -title "$GNOM Transcriptome"
	echo Done.
    else
	echo $GNOM BLAST database already present.
    fi
done
