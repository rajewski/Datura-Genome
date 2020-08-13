#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=7G
##SBATCH --time 10-00:00:00
#SBATCH --mail-user=araje002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH -o ../history/IPRScan-%A_%a.out
set -e

# This script is meant to be run as an array job with array IDs equal to the number of chunks the protein fasta was split into
WORKDIR=Dstr_v1.7_Annotation/update_results
NUMCHUNKS=6
# Split the Proetins fasta file into smaller chunks
if [ ! -e $WORKDIR/Datura_stramonium.proteins.fa.$NUMCHUNKS ]; then
    echo $(date): Splitting protein fasta file into chunks...
    module load genometools
    gt splitfasta \
	--numfiles $NUMCHUNKS \
	$WORKDIR/Datura_stramonium.proteins.fa
    echo $(date): Done.
    exit 0
fi

echo $(date): Running IPR Scan on chunk $SLURM_ARRAY_TASK_ID...
module load iprscan
module swap miniconda2 miniconda3
interproscan.sh \
    -i $WORKDIR/Datura_stramonium.proteins.fa.$SLURM_ARRAY_TASK_ID \
    -f XML \
    -o $WORKDIR/IPRout.$SLURM_ARRAY_TASK_ID.xml \
    --goterms \
    -appl Pfam,TIGRFAM,PRINTS,ProSiteProfiles,CDD,SFLD,SignalP_EUK,Gene3D,SMART,SUPERFAMILY,MobiDBLite,Coils,TMHMM,PIRSF,PANTHER,Phobius \
    -dra \
    -cpu $SLURM_CPUS_PER_TASK
echo $(date): Done.

#combine them all into a single xml file
if [ -e $WORKDIR/IPRout.$NUMCHUNKS.xml ]; then
    echo $(date): Combining IPR scan outputs into one file...
    grep -v "/protein-matches" $WORKDIR/IPRout.1.xml > $WORKDIR/IPRout.final.xml
    for ((c=2; c<="$NUMCHUNKS-1"; c++))
    do
	grep -v "protein-matches" $WORKDIR/IPRout.$c.xml | grep -v "xml " >> $WORKDIR/IPRout.final.xml
    done
    grep -v "xml " $WORKDIR/IPRout.$NUMCHUNKS.xml | grep -v "<protein-matches" >> $WORKDIR/IPRout.final.xml
fi
