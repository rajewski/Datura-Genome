#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=7G
#SBATCH --nodes=1
#SBATCH -p short
#SBATCH --time=02:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/IPRScan-%A.out
set -e

# This analysis is adapted from the Supplemental Text S1 of https://doi.org/10.1104/pp.108.132985

# Make a variable to store all the protein fasta files
PEPs=../5_Funannotate/Dstr_v1.7_Annotation/predict_results/Datura_stramonium.proteins.fa
#Run an interpro scan on the protein fasta to get a list of PFAM domains for each protein
cd DESeq

module load interproscan
if [ ! -e $(basename ${PEPs}).tsv ]; then
    echo Running IPRScan on $(basename ${PEPs[PEP]})...
    interproscan.sh \
	-i ${PEPs} \
	-f TSV \
	-appl Pfam,TIGRFAM,PRINTS,ProSiteProfiles \
	--goterms \
	-dra \
	-d ./ \
	-cpu $SLURM_CPUS_PER_TASK
    echo Done.
fi

# Clean up the Interpro output files
# Get a list of all proteins' names
grep ">" ../../5_Funannotate/Dstr_v1.7_Annotation/predict_results/Datura_stramonium.proteins.fa | sed 's/\S*\(HAX\S*\)\s.*/\1/' | sort > Dstr.protein.names.txt

# Make an associative array to aid with renaming of the outputs
PFAMs=$(basename ${PEPs}).tsv
cut -f1 $PFAMs | sort | uniq > Dstr.pfamhits.tsv # Names of all genes with a pfam hit
cut -f1,5 $PFAMs |sort | uniq > Dstr.gene2pfam.tsv # Association of all genes and their pfam domains
cut -f1,12 $PFAMs |sort |uniq |grep "IPR" > Dstr.gene2ipr.tsv # Association of all genes and their IPR domains
cut -f5,6 $PFAMs > Dstr.pfam2desc.tsv # Descriptions of pfam domains
cut -f12,13 $PFAMs > Dstr.ipr2desc.tsv # Descriptions of IPR domains
cut -f1,14 $PFAMs | sort |uniq | grep "GO" > Dstr.genes2go.tsv # Get the genes to go mapping
comm -1 -3 Dstr.pfamhits.tsv Dstr.protein.names.txt > Dstr.nopfam.tsv # Names of all genes without a pfam hit

